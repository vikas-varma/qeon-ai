import json
import sqlite3
import time
from pathlib import Path
from urllib.parse import urlencode

import httpx
from cryptography.fernet import Fernet
from fastapi import HTTPException, status

from app.core.config import settings

GMAIL_SCOPES = (
    "openid",
    "email",
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.compose",
)
CREATE_CONNECTIONS_TABLE = """
CREATE TABLE IF NOT EXISTS gmail_connections (
    user_id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    connected_at INTEGER NOT NULL
)
"""


class GoogleWorkspaceService:
    def __init__(self) -> None:
        self._db_path = Path(__file__).resolve().parents[2] / "oauth_tokens.db"

    def _require_config(self) -> tuple[str, str, Fernet]:
        if not settings.google_client_id or not settings.google_client_secret:
            raise HTTPException(
                status.HTTP_503_SERVICE_UNAVAILABLE, "Google OAuth is not configured"
            )
        if not settings.token_encryption_key:
            raise HTTPException(
                status.HTTP_503_SERVICE_UNAVAILABLE, "Token encryption is not configured"
            )
        try:
            cipher = Fernet(settings.token_encryption_key.encode())
        except ValueError as exc:
            raise HTTPException(
                status.HTTP_503_SERVICE_UNAVAILABLE, "Token encryption key is invalid"
            ) from exc
        return settings.google_client_id, settings.google_client_secret, cipher

    def _state(self, user_id: str) -> str:
        _, _, cipher = self._require_config()
        payload = json.dumps({"user_id": user_id, "expires": int(time.time()) + 600}).encode()
        return cipher.encrypt(payload).decode()

    def _read_state(self, state_value: str) -> str:
        _, _, cipher = self._require_config()
        try:
            payload = json.loads(cipher.decrypt(state_value.encode(), ttl=600))
        except Exception as exc:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "OAuth state is invalid or expired"
            ) from exc
        return str(payload["user_id"])

    def authorization_url(self, user_id: str) -> str:
        client_id, _, _ = self._require_config()
        query = urlencode(
            {
                "client_id": client_id,
                "redirect_uri": settings.google_oauth_redirect_uri,
                "response_type": "code",
                "scope": " ".join(GMAIL_SCOPES),
                "access_type": "offline",
                "include_granted_scopes": "true",
                "prompt": "consent",
                "state": self._state(user_id),
            }
        )
        return f"https://accounts.google.com/o/oauth2/v2/auth?{query}"

    async def finish_connection(self, code: str, state_value: str) -> str:
        user_id = self._read_state(state_value)
        client_id, client_secret, cipher = self._require_config()
        async with httpx.AsyncClient(timeout=20) as client:
            token_response = await client.post(
                "https://oauth2.googleapis.com/token",
                data={
                    "code": code,
                    "client_id": client_id,
                    "client_secret": client_secret,
                    "redirect_uri": settings.google_oauth_redirect_uri,
                    "grant_type": "authorization_code",
                },
            )
            if token_response.is_error:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST, "Google rejected the authorization code"
                )
            tokens = token_response.json()
            profile_response = await client.get(
                "https://gmail.googleapis.com/gmail/v1/users/me/profile",
                headers={"Authorization": f"Bearer {tokens['access_token']}"},
            )
            profile_response.raise_for_status()
        email = str(profile_response.json()["emailAddress"])
        refresh_token = tokens.get("refresh_token")
        if not refresh_token:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Google did not return offline access")
        self._save(user_id, email, cipher.encrypt(refresh_token.encode()).decode())
        return email

    def _save(self, user_id: str, email: str, encrypted_refresh_token: str) -> None:
        with sqlite3.connect(self._db_path) as db:
            db.execute(CREATE_CONNECTIONS_TABLE)
            db.execute(
                "INSERT OR REPLACE INTO gmail_connections VALUES (?, ?, ?, ?)",
                (user_id, email, encrypted_refresh_token, int(time.time())),
            )

    def status(self, user_id: str) -> dict[str, object]:
        if not self._db_path.exists():
            return {"connected": False, "email": None, "capabilities": []}
        with sqlite3.connect(self._db_path) as db:
            db.execute(CREATE_CONNECTIONS_TABLE)
            row = db.execute(
                "SELECT email FROM gmail_connections WHERE user_id = ?", (user_id,)
            ).fetchone()
        return {
            "connected": row is not None,
            "email": row[0] if row else None,
            "capabilities": ["read", "summarize", "draft"] if row else [],
        }

    async def disconnect(self, user_id: str) -> None:
        if not self._db_path.exists():
            return
        _, _, cipher = self._require_config()
        with sqlite3.connect(self._db_path) as db:
            row = db.execute(
                "SELECT refresh_token FROM gmail_connections WHERE user_id = ?", (user_id,)
            ).fetchone()
            if row:
                token = cipher.decrypt(row[0].encode()).decode()
                async with httpx.AsyncClient(timeout=10) as client:
                    await client.post(
                        "https://oauth2.googleapis.com/revoke", params={"token": token}
                    )
                db.execute("DELETE FROM gmail_connections WHERE user_id = ?", (user_id,))


google_workspace_service = GoogleWorkspaceService()
