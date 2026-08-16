import asyncio
import json
import time
from collections import defaultdict, deque
from uuid import UUID, uuid4

from starlette.datastructures import Headers, MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.core.config import settings


class SlidingWindowRateLimiter:
    def __init__(self) -> None:
        self._requests: dict[str, deque[float]] = defaultdict(deque)
        self._lock = asyncio.Lock()

    async def check(
        self,
        key: str,
        *,
        limit: int,
        window_seconds: int = 60,
        now: float | None = None,
    ) -> tuple[bool, int]:
        current = time.monotonic() if now is None else now
        cutoff = current - window_seconds
        async with self._lock:
            timestamps = self._requests[key]
            while timestamps and timestamps[0] <= cutoff:
                timestamps.popleft()
            if len(timestamps) >= limit:
                retry_after = max(1, int(timestamps[0] + window_seconds - current) + 1)
                return False, retry_after
            timestamps.append(current)
            return True, 0


class RateLimitMiddleware:
    _excluded_paths = {"/", "/docs", "/openapi.json", "/api/v1/health", "/api/v1/ready"}

    def __init__(self, app: ASGIApp) -> None:
        self.app = app
        self.limiter = SlidingWindowRateLimiter()

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or scope.get("path") in self._excluded_paths:
            await self.app(scope, receive, send)
            return

        path = str(scope.get("path", ""))
        is_email_send = path.endswith("/send") and "/gmail/drafts/" in path
        limit = (
            settings.rate_limit_email_sends_per_minute
            if is_email_send
            else settings.rate_limit_requests_per_minute
        )
        client = scope.get("client")
        client_ip = str(client[0]) if client else "unknown"
        bucket = "gmail-send" if is_email_send else "api"
        allowed, retry_after = await self.limiter.check(
            f"{client_ip}:{bucket}", limit=max(1, limit)
        )
        if not allowed:
            body = json.dumps({"detail": "Too many requests. Please try again shortly."}).encode()
            await send(
                {
                    "type": "http.response.start",
                    "status": 429,
                    "headers": [
                        (b"content-type", b"application/json"),
                        (b"content-length", str(len(body)).encode()),
                        (b"retry-after", str(retry_after).encode()),
                    ],
                }
            )
            await send({"type": "http.response.body", "body": body})
            return
        await self.app(scope, receive, send)


class SecurityHeadersMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    @staticmethod
    def _request_id(scope: Scope) -> str:
        supplied = Headers(scope=scope).get("x-request-id")
        if supplied:
            try:
                return str(UUID(supplied))
            except ValueError:
                pass
        return str(uuid4())

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request_id = self._request_id(scope)

        async def send_with_headers(message: Message) -> None:
            if message["type"] == "http.response.start":
                headers = MutableHeaders(scope=message)
                headers["x-request-id"] = request_id
                headers["x-content-type-options"] = "nosniff"
                headers["x-frame-options"] = "DENY"
                headers["referrer-policy"] = "no-referrer"
                headers["permissions-policy"] = "camera=(), geolocation=()"
                headers["cache-control"] = "no-store"
                if settings.environment == "production":
                    headers["strict-transport-security"] = "max-age=31536000; includeSubDomains"
            await send(message)

        await self.app(scope, receive, send_with_headers)
