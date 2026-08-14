import asyncio
from collections.abc import AsyncIterator

from app.ai.base import AIProvider


class MockAIProvider(AIProvider):
    async def stream_text(self, *, message: str, system_prompt: str) -> AsyncIterator[str]:
        del system_prompt
        text = f"Mock Qeon AI response to: {message}"
        for word in text.split():
            yield f"{word} "
            await asyncio.sleep(0.02)
