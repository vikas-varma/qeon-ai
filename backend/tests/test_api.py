from fastapi.testclient import TestClient
from pytest import MonkeyPatch

from app.core import security
from app.core.config import settings
from app.main import app
from app.services import chat_service

client = TestClient(app)


def test_health() -> None:
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_authentication_is_required_when_enabled(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "auth_required", True)

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


def test_chat_stream(monkeypatch: MonkeyPatch) -> None:
    monkeypatch.setattr(chat_service.settings, "ai_provider", "mock")
    response = client.post("/api/v1/chat/stream", json={"message": "Hello"})
    assert response.status_code == 200
    assert '"type": "delta"' in response.text
    assert '"type": "done"' in response.text
