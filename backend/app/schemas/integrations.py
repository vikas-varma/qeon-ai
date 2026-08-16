from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator


def _reject_header_injection(value: str | None) -> str | None:
    if value is not None and ("\r" in value or "\n" in value):
        raise ValueError("Email headers cannot contain line breaks")
    return value


class GmailMessageOut(BaseModel):
    id: str
    thread_id: str
    sender: str
    recipients: str
    subject: str
    date: str
    snippet: str
    unread: bool


class GmailSearchOut(BaseModel):
    messages: list[GmailMessageOut]
    result_size_estimate: int


class GmailSummaryOut(BaseModel):
    summary: str
    messages_considered: int
    query: str


class GmailDraftCreate(BaseModel):
    to: str = Field(min_length=3, max_length=1000)
    cc: str | None = Field(default=None, max_length=1000)
    bcc: str | None = Field(default=None, max_length=1000)
    subject: str = Field(min_length=1, max_length=500)
    body: str = Field(min_length=1, max_length=50_000)

    _safe_to = field_validator("to")(_reject_header_injection)
    _safe_cc = field_validator("cc")(_reject_header_injection)
    _safe_bcc = field_validator("bcc")(_reject_header_injection)
    _safe_subject = field_validator("subject")(_reject_header_injection)


class GmailDraftOut(BaseModel):
    approval_id: str
    gmail_draft_id: str
    to: str
    cc: str | None = None
    bcc: str | None = None
    subject: str
    body: str
    status: str
    created_at: datetime


class GmailSendApproval(BaseModel):
    approved: Literal[True]


class GmailSendOut(BaseModel):
    approval_id: str
    gmail_message_id: str
    status: Literal["sent"] = "sent"
