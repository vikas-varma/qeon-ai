from collections.abc import AsyncIterator, Sequence

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


def _system_prompt(history: Sequence[tuple[str, str]]) -> str:
    if not history:
        return SYSTEM_PROMPT
    transcript = "\n".join(f"{role}: {content}" for role, content in history)
    return (
        f"{SYSTEM_PROMPT}\n\n"
        "Continue the current conversation using this recent context. "
        "Do not mention that a transcript was supplied.\n"
        f"{transcript[-12_000:]}"
    )


async def stream_answer(
    message: str, *, history: Sequence[tuple[str, str]] = ()
) -> AsyncIterator[dict[str, str]]:
    try:
        provider = get_ai_provider()
        async for text in provider.stream_text(
            message=message,
            system_prompt=_system_prompt(history),
        ):
            yield {"type": "delta", "text": text}
    except (httpx.HTTPError, RuntimeError) as exc:
        yield {
            "type": "error",
            "message": "The AI service is temporarily unavailable. Please try again.",
            "detail": type(exc).__name__,
        }
    yield {"type": "done"}
