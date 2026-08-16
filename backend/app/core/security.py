import json
import logging
from functools import lru_cache
from typing import Annotated, TypedDict

import firebase_admin
from fastapi import Header, HTTPException, status
from firebase_admin import auth, credentials
from firebase_admin.exceptions import FirebaseError
from starlette.concurrency import run_in_threadpool

from app.core.config import settings

logger = logging.getLogger(__name__)


class CurrentUser(TypedDict):
    id: str
    name: str
    email: str


class FirebaseConfigurationError(RuntimeError):
    """Raised when server-side Firebase credentials are unavailable or invalid."""


@lru_cache(maxsize=1)
def _firebase_app() -> firebase_admin.App:
    try:
        return firebase_admin.get_app()
    except ValueError:
        pass

    if not settings.firebase_project_id:
        raise FirebaseConfigurationError("Firebase project ID is not configured")
    if not settings.firebase_credentials_json:
        raise FirebaseConfigurationError("Firebase service-account credentials are not configured")

    options = {"projectId": settings.firebase_project_id}
    try:
        service_account = json.loads(settings.firebase_credentials_json)
        credential = credentials.Certificate(service_account)
        return firebase_admin.initialize_app(credential, options)
    except (TypeError, ValueError, KeyError) as exc:
        raise FirebaseConfigurationError(
            "Firebase service-account credentials are invalid"
        ) from exc


def verify_firebase_id_token(id_token: str) -> dict[str, object]:
    """Verify a client Firebase ID token and return its trusted claims."""
    app = _firebase_app()
    return auth.verify_id_token(
        id_token,
        app=app,
        check_revoked=settings.firebase_check_revoked,
    )


def _demo_user() -> CurrentUser:
    return {
        "id": "demo-user",
        "name": "Qeon demo user",
        "email": "demo@qeonai.local",
    }


async def get_current_user(
    authorization: Annotated[str | None, Header()] = None,
) -> CurrentUser:
    """Return the user proven by a Firebase bearer token.

    Staged deployments may temporarily accept a missing token while
    ``QEON_AUTH_REQUIRED`` is false. A supplied token is always verified.
    """
    if authorization is None:
        if settings.auth_required:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication is required",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return _demo_user()

    scheme, separator, id_token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not separator or not id_token.strip():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        claims = await run_in_threadpool(verify_firebase_id_token, id_token.strip())
    except FirebaseConfigurationError as exc:
        logger.error("Firebase authentication is not configured: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is not configured",
        ) from exc
    except (
        auth.ExpiredIdTokenError,
        auth.InvalidIdTokenError,
        auth.RevokedIdTokenError,
        auth.UserDisabledError,
        ValueError,
    ) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
    except FirebaseError as exc:
        logger.exception("Firebase token verification failed")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is temporarily unavailable",
        ) from exc

    uid = str(claims.get("uid") or claims.get("sub") or "").strip()
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token has no user identity",
            headers={"WWW-Authenticate": "Bearer"},
        )

    email = str(claims.get("email") or "").strip()
    name = str(claims.get("name") or "").strip()
    if not name:
        name = email.split("@", maxsplit=1)[0] if email else "Qeon user"
    return {"id": uid, "name": name, "email": email}
