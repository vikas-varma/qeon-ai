from hashlib import sha256

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import CurrentUser
from app.models.tables import User


def _placeholder_email(external_auth_id: str) -> str:
    digest = sha256(external_auth_id.encode()).hexdigest()[:24]
    return f"{digest}@users.qeonai.local"


async def get_or_create_user(session: AsyncSession, identity: CurrentUser) -> User:
    user = await session.scalar(select(User).where(User.external_auth_id == identity["id"]))
    if user is not None:
        return user

    user = User(
        external_auth_id=identity["id"],
        email=identity["email"] or _placeholder_email(identity["id"]),
        display_name=identity["name"],
    )
    session.add(user)
    await session.flush()
    return user
