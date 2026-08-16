import asyncio
import os

import pytest

os.environ["QEON_ENVIRONMENT"] = "test"
os.environ["QEON_DATABASE_URL"] = "sqlite+aiosqlite:///./test_qeonai.db"

from app.db.session import engine  # noqa: E402
from app.models.tables import Base  # noqa: E402


async def _reset_database() -> None:
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.drop_all)
        await connection.run_sync(Base.metadata.create_all)


@pytest.fixture(autouse=True)
def reset_database() -> None:
    asyncio.run(_reset_database())
