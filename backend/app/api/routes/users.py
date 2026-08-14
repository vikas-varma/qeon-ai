from typing import Annotated

from fastapi import APIRouter, Depends

from app.core.security import get_current_user

router = APIRouter()


@router.get("/me")
async def me(user: Annotated[dict[str, str], Depends(get_current_user)]) -> dict[str, str]:
    return user
