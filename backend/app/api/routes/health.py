from typing import Annotated

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.session import get_db

router = APIRouter(tags=["system"])


@router.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok", "service": "qeonai-api"}


@router.get("/ready")
async def readiness(
    response: Response,
    session: Annotated[AsyncSession, Depends(get_db)],
) -> dict[str, object]:
    checks: dict[str, bool] = {}
    try:
        await session.execute(text("SELECT 1"))
        checks["database"] = True
    except Exception:
        checks["database"] = False

    production = settings.environment == "production"
    checks["persistent_database"] = not production or not settings.database_url.startswith("sqlite")
    checks["firebase_auth"] = not production or bool(
        settings.firebase_project_id and settings.firebase_credentials_json
    )
    checks["gmail_oauth"] = not production or bool(
        settings.google_client_id
        and settings.google_client_secret
        and settings.token_encryption_key
    )
    checks["real_ai_provider"] = not production or (
        settings.ai_provider == "gemini" and bool(settings.gemini_api_key)
    )
    ready = all(checks.values())
    if not ready:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return {"ready": ready, "checks": checks}
