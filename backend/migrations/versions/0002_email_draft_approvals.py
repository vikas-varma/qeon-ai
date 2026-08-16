"""Add explicit Gmail draft approval records.

Revision ID: 0002_email_drafts
Revises: 0001_initial
Create Date: 2026-08-16
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0002_email_drafts"
down_revision: str | Sequence[str] | None = "0001_initial"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "email_draft_approvals",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("connected_account_id", sa.Uuid(), nullable=False),
        sa.Column("gmail_draft_id", sa.String(length=180), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("sent_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["connected_account_id"], ["connected_accounts.id"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("gmail_draft_id"),
    )
    op.create_index(
        "ix_email_draft_approvals_connected_account_id",
        "email_draft_approvals",
        ["connected_account_id"],
    )
    op.create_index("ix_email_draft_approvals_user_id", "email_draft_approvals", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_email_draft_approvals_user_id", table_name="email_draft_approvals")
    op.drop_index(
        "ix_email_draft_approvals_connected_account_id",
        table_name="email_draft_approvals",
    )
    op.drop_table("email_draft_approvals")
