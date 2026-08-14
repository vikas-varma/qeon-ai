from abc import ABC, abstractmethod
from collections.abc import AsyncIterator


class AIProvider(ABC):
    @abstractmethod
    async def stream_text(self, *, message: str, system_prompt: str) -> AsyncIterator[str]:
        """Stream model text chunks without exposing provider details to routers."""
        raise NotImplementedError
