from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser, get_current_user
from app.db.session import get_db
from app.repositories.users import get_or_create_user

router = APIRouter()


@router.get("/me")
async def me(
    identity: Annotated[CurrentUser, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> CurrentUser:
    await get_or_create_user(session, identity)
    await session.commit()
    return identity
