from html import escape
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.integrations.google_workspace import google_workspace_service
from app.repositories.users import get_or_create_user
from app.schemas.integrations import (
    GmailDraftCreate,
    GmailDraftOut,
    GmailSearchOut,
    GmailSendApproval,
    GmailSendOut,
    GmailSummaryOut,
)

router = APIRouter()


async def _database_user_id(
    identity: CurrentUser,
    session: AsyncSession,
) -> UUID:
    user = await get_or_create_user(session, identity)
    await session.commit()
    return user.id


@router.get("/gmail/status")
async def gmail_status(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> dict[str, object]:
    user_id = await _database_user_id(identity, session)
    return await google_workspace_service.status(user_id, session)


@router.post("/gmail/connect")
async def connect_gmail(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> dict[str, str]:
    user_id = await _database_user_id(identity, session)
    return {"authorization_url": google_workspace_service.authorization_url(user_id)}


@router.get("/gmail/callback", response_class=HTMLResponse)
async def gmail_callback(
    code: Annotated[str, Query(min_length=1)],
    state_value: Annotated[str, Query(alias="state", min_length=1)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> str:
    email = escape(await google_workspace_service.finish_connection(code, state_value, session))
    return (
        "<!doctype html><html><head><meta name='viewport' "
        "content='width=device-width,initial-scale=1'></head>"
        "<body style='font-family:sans-serif;text-align:center;padding:48px'>"
        f"<h2>Gmail connected</h2><p>{email} is ready in Qeon AI.</p>"
        "<p><a href='qeonai://app/gmail-connected' style='display:inline-block;"
        "padding:14px 22px;background:#6d35f6;color:white;text-decoration:none;"
        "border-radius:12px;font-weight:700'>Return to Qeon AI</a></p>"
        "<p>If the app does not open, close this window and tap Check connection "
        "in Qeon AI.</p></body></html>"
    )


@router.get("/gmail/messages", response_model=GmailSearchOut)
async def search_gmail(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    query: Annotated[str, Query(min_length=1, max_length=500)] = "in:inbox",
    limit: Annotated[int, Query(ge=1, le=20)] = 10,
) -> GmailSearchOut:
    user_id = await _database_user_id(identity, session)
    return await google_workspace_service.search_messages(
        user_id, session, query=query, limit=limit
    )


@router.get("/gmail/summary", response_model=GmailSummaryOut)
async def summarize_gmail(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    query: Annotated[str, Query(min_length=1, max_length=500)] = "in:inbox is:unread",
    limit: Annotated[int, Query(ge=1, le=20)] = 10,
) -> GmailSummaryOut:
    user_id = await _database_user_id(identity, session)
    return await google_workspace_service.summarize_messages(
        user_id, session, query=query, limit=limit
    )


@router.post(
    "/gmail/drafts",
    response_model=GmailDraftOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_gmail_draft(
    draft: GmailDraftCreate,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> GmailDraftOut:
    user_id = await _database_user_id(identity, session)
    return await google_workspace_service.create_draft(user_id, session, draft)


@router.post("/gmail/drafts/{approval_id}/send", response_model=GmailSendOut)
async def send_approved_gmail_draft(
    approval_id: UUID,
    approval: GmailSendApproval,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> GmailSendOut:
    assert approval.approved is True
    user_id = await _database_user_id(identity, session)
    return await google_workspace_service.send_draft(user_id, session, approval_id)


@router.delete("/gmail")
async def disconnect_gmail(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> dict[str, bool]:
    user_id = await _database_user_id(identity, session)
    await google_workspace_service.disconnect(user_id, session)
    return {"disconnected": True}
