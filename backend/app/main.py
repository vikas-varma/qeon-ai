from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import settings
from app.core.middleware import RateLimitMiddleware, SecurityHeadersMiddleware


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Initialize database pools, Redis clients, and provider SDKs here.
    yield
    # Close shared clients here.


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Backend starter for the Qeon AI personal assistant.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(RateLimitMiddleware)
app.add_middleware(SecurityHeadersMiddleware)
app.include_router(api_router, prefix=settings.api_prefix)


@app.get("/", tags=["system"])
async def root() -> dict[str, str]:
    return {"name": settings.app_name, "docs": "/docs", "status": "running"}
