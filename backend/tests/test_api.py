import asyncio
import base64
from email import policy
from email.parser import BytesParser
from unittest.mock import AsyncMock
from uuid import uuid4

from fastapi.testclient import TestClient
from pytest import MonkeyPatch

from app.core import security
from app.core.config import settings
from app.core.middleware import SlidingWindowRateLimiter
from app.integrations.google_workspace import google_workspace_service
from app.main import app
from app.schemas.integrations import GmailDraftCreate, GmailSendOut
from app.services import chat_service

client = TestClient(app)


def test_health() -> None:
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.headers["x-content-type-options"] == "nosniff"
    assert response.headers["x-frame-options"] == "DENY"
    assert response.headers["x-request-id"]


def test_readiness_checks_database() -> None:
    response = client.get("/api/v1/ready")

    assert response.status_code == 200
    assert response.json()["ready"] is True
    assert response.json()["checks"]["database"] is True


def test_sliding_window_rate_limiter_rejects_excess_requests() -> None:
    async def exercise() -> tuple[tuple[bool, int], tuple[bool, int], tuple[bool, int]]:
        limiter = SlidingWindowRateLimiter()
        first = await limiter.check("user", limit=2, now=100)
        second = await limiter.check("user", limit=2, now=101)
        third = await limiter.check("user", limit=2, now=102)
        return first, second, third

    first, second, third = asyncio.run(exercise())

    assert first == (True, 0)
    assert second == (True, 0)
    assert third[0] is False
    assert third[1] > 0


def test_authentication_is_required_when_enabled(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "auth_required", True)

    response = client.get("/api/v1/users/me")

    assert response.status_code == 401
    assert response.headers["www-authenticate"] == "Bearer"


def test_production_never_accepts_demo_identity(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "environment", "production")
    monkeypatch.setattr(settings, "auth_required", False)

    response = client.get("/api/v1/users/me")

    assert response.status_code == 401
    assert response.headers["www-authenticate"] == "Bearer"


def test_malformed_authorization_header_is_rejected() -> None:
    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Basic not-a-bearer-token"},
    )

    assert response.status_code == 401


def test_verified_firebase_identity_is_returned(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "auth_required", True)
    monkeypatch.setattr(
        security,
        "verify_firebase_id_token",
        lambda token: {
            "uid": "firebase-user-123",
            "email": "user@example.com",
            "name": "Example User",
            "tested_token": token,
        },
    )

    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer valid-test-token"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "id": "firebase-user-123",
        "email": "user@example.com",
        "name": "Example User",
    }


def test_agents() -> None:
    response = client.get("/api/v1/agents")
    assert response.status_code == 200
    assert len(response.json()) >= 4


def test_create_task() -> None:
    response = client.post(
        "/api/v1/tasks",
        json={
            "title": "Daily brief",
            "instruction": "Summarize my important tasks",
            "schedule": "daily",
            "requires_approval": True,
        },
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Daily brief"

    listed = client.get("/api/v1/tasks")
    assert listed.status_code == 200
    assert [task["id"] for task in listed.json()] == [response.json()["id"]]


def test_tasks_are_isolated_by_verified_user(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "auth_required", True)
    monkeypatch.setattr(
        security,
        "verify_firebase_id_token",
        lambda token: {
            "uid": token,
            "email": f"{token}@example.com",
            "name": token,
        },
    )
    payload = {
        "title": "Private task",
        "instruction": "Only user one can see this",
        "schedule": "once",
        "requires_approval": True,
    }

    created = client.post(
        "/api/v1/tasks",
        json=payload,
        headers={"Authorization": "Bearer user-one"},
    )
    other_user = client.get(
        "/api/v1/tasks",
        headers={"Authorization": "Bearer user-two"},
    )
    owner = client.get(
        "/api/v1/tasks",
        headers={"Authorization": "Bearer user-one"},
    )

    assert created.status_code == 201
    assert other_user.json() == []
    assert [task["id"] for task in owner.json()] == [created.json()["id"]]


def test_memories_persist_and_can_be_cleared() -> None:
    created = client.post(
        "/api/v1/memories",
        json={
            "category": "Preference",
            "title": "Reply style",
            "value": "Keep email replies concise",
        },
    )
    listed = client.get("/api/v1/memories")
    cleared = client.delete("/api/v1/memories")
    after_clear = client.get("/api/v1/memories")

    assert created.status_code == 201
    assert [memory["id"] for memory in listed.json()] == [created.json()["id"]]
    assert cleared.status_code == 204
    assert after_clear.json() == []


def test_account_data_deletion_requires_typed_confirmation() -> None:
    response = client.request(
        "DELETE",
        "/api/v1/users/me/data",
        json={"confirmation": "delete"},
    )

    assert response.status_code == 422


def test_account_data_deletion_removes_user_records() -> None:
    created = client.post(
        "/api/v1/tasks",
        json={
            "title": "Temporary task",
            "instruction": "Delete this with my account data",
            "schedule": "once",
            "requires_approval": True,
        },
    )
    deleted = client.request(
        "DELETE",
        "/api/v1/users/me/data",
        json={"confirmation": "DELETE"},
    )
    after_delete = client.get("/api/v1/tasks")

    assert created.status_code == 201
    assert deleted.status_code == 204
    assert after_delete.json() == []


def test_gmail_draft_mime_is_encoded_safely() -> None:
    raw = google_workspace_service._encode_message(
        "owner@example.com",
        GmailDraftCreate(
            to="recipient@example.com",
            subject="Project update",
            body="The work is ready for review.",
        ),
    )
    padded = raw + "=" * (-len(raw) % 4)
    message = BytesParser(policy=policy.default).parsebytes(base64.urlsafe_b64decode(padded))

    assert message["From"] == "owner@example.com"
    assert message["To"] == "recipient@example.com"
    assert message["Subject"] == "Project update"
    assert message.get_body(preferencelist=("plain",)).get_content().strip() == (
        "The work is ready for review."
    )


def test_gmail_send_rejects_missing_explicit_approval() -> None:
    response = client.post(
        f"/api/v1/integrations/gmail/drafts/{uuid4()}/send",
        json={"approved": False},
    )

    assert response.status_code == 422


def test_gmail_send_calls_service_after_explicit_approval(
    monkeypatch: MonkeyPatch,
) -> None:
    approval_id = uuid4()
    send = AsyncMock(
        return_value=GmailSendOut(
            approval_id=str(approval_id),
            gmail_message_id="gmail-message-1",
        )
    )
    monkeypatch.setattr(google_workspace_service, "send_draft", send)

    response = client.post(
        f"/api/v1/integrations/gmail/drafts/{approval_id}/send",
        json={"approved": True},
    )

    assert response.status_code == 200
    assert response.json()["status"] == "sent"
    send.assert_awaited_once()


def test_chat_stream(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(chat_service.settings, "ai_provider", "mock")
    response = client.post("/api/v1/chat/stream", json={"message": "Hello"})
    assert response.status_code == 200
    assert '"type": "delta"' in response.text
    assert '"type": "done"' in response.text
