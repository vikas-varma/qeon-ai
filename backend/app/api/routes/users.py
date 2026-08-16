from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.integrations.google_workspace import google_workspace_service
from app.models.tables import AuditLog
from app.repositories.users import get_or_create_user
from app.schemas.common import AccountDataDeletion, ActivityOut

router = APIRouter()


@router.get("/me")
async def me(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> CurrentUser:
    await get_or_create_user(session, identity)
    await session.commit()
    return identity


@router.get("/me/activity", response_model=list[ActivityOut])
async def my_activity(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
) -> list[ActivityOut]:
    user = await get_or_create_user(session, identity)
    activity = await session.scalars(
        select(AuditLog)
        .where(AuditLog.user_id == user.id)
        .order_by(AuditLog.created_at.desc())
        .limit(limit)
    )
    await session.commit()
    return [
        ActivityOut(
            id=str(item.id),
            action=item.action,
            resource_type=item.resource_type,
            resource_id=item.resource_id,
            details=item.details,
            created_at=item.created_at,
        )
        for item in activity
    ]


@router.delete("/me/data", status_code=status.HTTP_204_NO_CONTENT)
async def delete_my_data(
    deletion: AccountDataDeletion,
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> Response:
    assert deletion.confirmation == "DELETE"
    user = await get_or_create_user(session, identity)
    await session.commit()
    await google_workspace_service.disconnect(user.id, session)
    await session.delete(user)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
