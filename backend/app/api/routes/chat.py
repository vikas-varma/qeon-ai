import json
from collections.abc import AsyncIterator
from datetime import datetime, timezone
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from fastapi.responses import StreamingResponse
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.models.tables import AuditLog, Conversation, Message
from app.repositories.users import get_or_create_user
from app.schemas.common import (
    ChatRequest,
    ConversationDetail,
    ConversationOut,
    MessageOut,
)
from app.services.chat_service import stream_answer

router = APIRouter()


def _parse_conversation_id(conversation_id: str) -> UUID:
    try:
        return UUID(conversation_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail="Conversation not found") from exc


def _ordered_messages(conversation: Conversation) -> list[Message]:
    return sorted(conversation.messages, key=lambda message: message.created_at)


def _conversation_out(
    conversation: Conversation,
    *,
    preview: str | None = None,
    message_count: int | None = None,
) -> ConversationOut:
    if preview is None or message_count is None:
        messages = _ordered_messages(conversation)
        preview = messages[-1].content[:240] if messages else ""
        message_count = len(messages)
    return ConversationOut(
        id=str(conversation.id),
        title=conversation.title,
        preview=preview,
        pinned=conversation.pinned,
        message_count=message_count,
        created_at=conversation.created_at,
        updated_at=conversation.updated_at,
    )


async def _owned_conversation(
    session: AsyncSession, user_id: UUID, conversation_id: str
) -> Conversation:
    conversation = await session.scalar(
        select(Conversation)
        .options(selectinload(Conversation.messages))
        .where(
            Conversation.id == _parse_conversation_id(conversation_id),
            Conversation.user_id == user_id,
        )
    )
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conversation


@router.get("/conversations", response_model=list[ConversationOut])
async def list_conversations(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
) -> list[ConversationOut]:
    user = await get_or_create_user(session, identity)
    message_count = (
        select(func.count(Message.id))
        .where(Message.conversation_id == Conversation.id)
        .correlate(Conversation)
        .scalar_subquery()
    )
    latest_content = (
        select(Message.content)
        .where(Message.conversation_id == Conversation.id)
        .order_by(Message.created_at.desc())
        .limit(1)
        .correlate(Conversation)
        .scalar_subquery()
    )
    rows = await session.execute(
        select(Conversation, message_count, latest_content)
        .where(Conversation.user_id == user.id)
        .order_by(Conversation.pinned.desc(), Conversation.updated_at.desc())
        .limit(limit)
    )
    await session.commit()
    return [
        _conversation_out(
            conversation,
            preview=(preview or "")[:240],
            message_count=count,
        )
        for conversation, count, preview in rows
    ]


@router.get("/conversations/{conversation_id}", response_model=ConversationDetail)
async def get_conversation(
    conversation_id: str,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> ConversationDetail:
    user = await get_or_create_user(session, identity)
    conversation = await _owned_conversation(session, user.id, conversation_id)
    await session.commit()
    summary = _conversation_out(conversation)
    return ConversationDetail(
        **summary.model_dump(),
        messages=[
            MessageOut(
                id=str(message.id),
                role=message.role,
                content=message.content,
                created_at=message.created_at,
            )
            for message in _ordered_messages(conversation)
        ],
    )


@router.delete(
    "/conversations/{conversation_id}", status_code=status.HTTP_204_NO_CONTENT
)
async def delete_conversation(
    conversation_id: str,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> Response:
    user = await get_or_create_user(session, identity)
    conversation = await _owned_conversation(session, user.id, conversation_id)
    session.add(
        AuditLog(
            user_id=user.id,
            action="conversation.deleted",
            resource_type="conversation",
            resource_id=str(conversation.id),
            details={},
        )
    )
    await session.delete(conversation)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/stream")
async def chat_stream(
    payload: ChatRequest,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> StreamingResponse:
    user = await get_or_create_user(session, identity)
    if payload.conversation_id:
        conversation = await _owned_conversation(session, user.id, payload.conversation_id)
        previous_messages = _ordered_messages(conversation)[-12:]
    else:
        title = " ".join(payload.message.strip().split())[:80]
        conversation = Conversation(user_id=user.id, title=title or "New conversation")
        session.add(conversation)
        await session.flush()
        previous_messages = []

    now = datetime.now(timezone.utc)
    conversation.updated_at = now
    session.add(
        Message(
            conversation_id=conversation.id,
            role="user",
            content=payload.message,
            metadata_json={"agent_id": payload.agent_id} if payload.agent_id else {},
        )
    )
    await session.commit()

    history = [(message.role, message.content) for message in previous_messages]

    async def events() -> AsyncIterator[str]:
        yield f"data: {json.dumps({'type': 'meta', 'conversation_id': str(conversation.id)})}\n\n"
        answer_parts: list[str] = []
        async for event in stream_answer(payload.message, history=history):
            if event["type"] == "delta":
                answer_parts.append(event.get("text", ""))
            if event["type"] == "done" and answer_parts:
                answer = "".join(answer_parts).strip()
                session.add(
                    Message(
                        conversation_id=conversation.id,
                        role="assistant",
                        content=answer,
                        metadata_json={"agent_id": payload.agent_id} if payload.agent_id else {},
                    )
                )
                conversation.summary = answer[:500]
                conversation.updated_at = datetime.now(timezone.utc)
                await session.commit()
            yield f"data: {json.dumps(event)}\n\n"

    return StreamingResponse(events(), media_type="text/event-stream")
