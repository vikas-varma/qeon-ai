from datetime import datetime, timezone
from enum import Enum
from typing import Literal
from uuid import uuid4

from pydantic import BaseModel, Field


class AgentOut(BaseModel):
    id: str
    name: str
    description: str
    enabled: bool = True
    capabilities: list[str] = Field(default_factory=list)


class TaskStatus(str, Enum):
    running = "running"
    scheduled = "scheduled"
    completed = "completed"


class TaskCreate(BaseModel):
    title: str = Field(min_length=2, max_length=200)
    instruction: str = Field(min_length=2, max_length=4000)
    schedule: str = "once"
    requires_approval: bool = True


class TaskOut(TaskCreate):
    id: str = Field(default_factory=lambda: str(uuid4()))
    status: TaskStatus = TaskStatus.scheduled
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class MemoryCreate(BaseModel):
    category: str = Field(min_length=2, max_length=80)
    title: str = Field(min_length=2, max_length=120)
    value: str = Field(min_length=1, max_length=2000)


class MemoryOut(MemoryCreate):
    id: str = Field(default_factory=lambda: str(uuid4()))
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ChatRequest(BaseModel):
    conversation_id: str | None = None
    message: str = Field(min_length=1, max_length=20_000)
    agent_id: str | None = None


class MessageOut(BaseModel):
    id: str
    role: Literal["user", "assistant"]
    content: str
    created_at: datetime


class ConversationOut(BaseModel):
    id: str
    title: str
    preview: str
    pinned: bool
    message_count: int
    created_at: datetime
    updated_at: datetime


class ConversationDetail(ConversationOut):
    messages: list[MessageOut]


class AccountDataDeletion(BaseModel):
    confirmation: Literal["DELETE"]


class ActivityOut(BaseModel):
    id: str
    action: str
    resource_type: str
    resource_id: str | None
    details: dict
    created_at: datetime
