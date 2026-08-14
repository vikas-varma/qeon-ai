from fastapi.testclient import TestClient
from pytest import MonkeyPatch

from app.main import app
from app.services import chat_service

client = TestClient(app)


def test_health() -> None:
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


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
