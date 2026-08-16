from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.models.tables import ScheduledTask
from app.repositories.users import get_or_create_user
from app.schemas.common import TaskCreate, TaskOut, TaskStatus

router = APIRouter()


def _task_out(task: ScheduledTask) -> TaskOut:
    return TaskOut(
        id=str(task.id),
        title=task.title,
        instruction=task.instruction,
        schedule=task.schedule,
        status=TaskStatus(task.status),
        requires_approval=task.requires_approval,
        created_at=task.created_at,
    )


@router.get("", response_model=list[TaskOut])
async def list_tasks(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[TaskOut]:
    user = await get_or_create_user(session, identity)
    tasks = await session.scalars(
        select(ScheduledTask)
        .where(ScheduledTask.user_id == user.id)
        .order_by(ScheduledTask.created_at.desc())
    )
    await session.commit()
    return [_task_out(task) for task in tasks]


@router.post("", response_model=TaskOut, status_code=status.HTTP_201_CREATED)
async def create_task(
    payload: TaskCreate,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> TaskOut:
    user = await get_or_create_user(session, identity)
    task = ScheduledTask(user_id=user.id, **payload.model_dump())
    session.add(task)
    await session.commit()
    await session.refresh(task)
    return _task_out(task)


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: str,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> Response:
    try:
        parsed_id = UUID(task_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail="Task not found") from exc

    user = await get_or_create_user(session, identity)
    task = await session.scalar(
        select(ScheduledTask).where(
            ScheduledTask.id == parsed_id,
            ScheduledTask.user_id == user.id,
        )
    )
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    await session.delete(task)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
