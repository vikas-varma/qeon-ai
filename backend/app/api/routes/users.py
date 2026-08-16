from typing import Annotated

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.integrations.google_workspace import google_workspace_service
from app.repositories.users import get_or_create_user
from app.schemas.common import AccountDataDeletion

router = APIRouter()


@router.get("/me")
async def me(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> CurrentUser:
    await get_or_create_user(session, identity)
    await session.commit()
    return identity


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
