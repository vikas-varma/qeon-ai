from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="QEON_",
        extra="ignore",
    )

    app_name: str = "Qeon AI API"
    environment: str = "development"
    debug: bool = True
    api_prefix: str = "/api/v1"
    database_url: str = "sqlite+aiosqlite:///./qeonai.db"
    redis_url: str = "redis://localhost:6379/0"
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:8080"]
    ai_provider: str = "mock"
    openai_api_key: str | None = None
    gemini_api_key: str | None = None
    gemini_model: str = "gemini-3.5-flash-lite"
    auth_required: bool = False
    firebase_project_id: str | None = None
    firebase_credentials_json: str | None = None
    firebase_check_revoked: bool = True
    jwt_audience: str = "qeonai"
    rate_limit_requests_per_minute: int = 120
    rate_limit_email_sends_per_minute: int = 5
    google_client_id: str | None = None
    google_client_secret: str | None = None
    google_oauth_redirect_uri: str = "http://localhost:8000/api/v1/integrations/gmail/callback"
    token_encryption_key: str | None = None

    @field_validator("database_url", mode="before")
    @classmethod
    def use_async_postgres_driver(cls, value: object) -> object:
        if not isinstance(value, str):
            return value
        if value.startswith("postgres://"):
            return value.replace("postgres://", "postgresql+asyncpg://", 1)
        if value.startswith("postgresql://"):
            return value.replace("postgresql://", "postgresql+asyncpg://", 1)
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
