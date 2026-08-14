import json
from collections.abc import AsyncIterator

import httpx

from app.ai.base import AIProvider
from app.ai.providers.gemini import GeminiAIProvider
from app.ai.providers.mock import MockAIProvider
from app.core.config import settings

SYSTEM_PROMPT = "You are Qeon AI, a concise, helpful personal assistant."


def get_ai_provider() -> AIProvider:
    if settings.ai_provider == "gemini":
        if not settings.gemini_api_key:
            raise RuntimeError("QEON_GEMINI_API_KEY is required when QEON_AI_PROVIDER=gemini")
        return GeminiAIProvider(
            api_key=settings.gemini_api_key,
            model=settings.gemini_model,
        )
    return MockAIProvider()


async def stream_answer(message: str) -> AsyncIterator[str]:
    try:
        provider = get_ai_provider()
        async for text in provider.stream_text(message=message, system_prompt=SYSTEM_PROMPT):
            payload = json.dumps({"type": "delta", "text": text})
            yield f"data: {payload}\n\n"
    except (httpx.HTTPError, RuntimeError) as exc:
        payload = json.dumps(
            {
                "type": "error",
                "message": "The AI service is temporarily unavailable. Please try again.",
                "detail": type(exc).__name__,
            }
        )
        yield f"data: {payload}\n\n"
    yield f"data: {json.dumps({'type': 'done'})}\n\n"
