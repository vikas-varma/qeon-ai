from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.models.tables import AuditLog, Memory
from app.repositories.users import get_or_create_user
from app.schemas.common import MemoryCreate, MemoryOut

router = APIRouter()


def _memory_out(memory: Memory) -> MemoryOut:
    return MemoryOut(
        id=str(memory.id),
        category=memory.category,
        title=memory.title,
        value=memory.value,
        created_at=memory.created_at,
    )


@router.get("", response_model=list[MemoryOut])
async def list_memories(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[MemoryOut]:
    user = await get_or_create_user(session, identity)
    memories = await session.scalars(
        select(Memory)
        .where(Memory.user_id == user.id, Memory.enabled.is_(True))
        .order_by(Memory.created_at.desc())
    )
    await session.commit()
    return [_memory_out(memory) for memory in memories]


@router.post("", response_model=MemoryOut, status_code=status.HTTP_201_CREATED)
async def create_memory(
    payload: MemoryCreate,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> MemoryOut:
    user = await get_or_create_user(session, identity)
    memory = Memory(user_id=user.id, **payload.model_dump())
    session.add(memory)
    await session.flush()
    session.add(
        AuditLog(
            user_id=user.id,
            action="memory.created",
            resource_type="memory",
            resource_id=str(memory.id),
            details={"category": memory.category},
        )
    )
    await session.commit()
    return _memory_out(memory)


@router.delete("/{memory_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_memory(
    memory_id: str,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> Response:
    try:
        parsed_id = UUID(memory_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail="Memory not found") from exc

    user = await get_or_create_user(session, identity)
    memory = await session.scalar(
        select(Memory).where(Memory.id == parsed_id, Memory.user_id == user.id)
    )
    if memory is None:
        raise HTTPException(status_code=404, detail="Memory not found")
    session.add(
        AuditLog(
            user_id=user.id,
            action="memory.deleted",
            resource_type="memory",
            resource_id=str(memory.id),
            details={},
        )
    )
    await session.delete(memory)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def clear_memories(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> Response:
    user = await get_or_create_user(session, identity)
    await session.execute(delete(Memory).where(Memory.user_id == user.id))
    session.add(
        AuditLog(
            user_id=user.id,
            action="memory.cleared",
            resource_type="memory",
            resource_id=None,
            details={},
        )
    )
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
