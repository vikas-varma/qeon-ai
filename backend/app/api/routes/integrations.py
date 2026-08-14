from typing import Annotated

from fastapi import APIRouter, Depends, Query
from fastapi.responses import HTMLResponse

from app.core.security import get_current_user
from app.integrations.google_workspace import google_workspace_service

router = APIRouter()


@router.get("/gmail/status")
async def gmail_status(
    user: Annotated[dict[str, str], Depends(get_current_user)],
) -> dict[str, object]:
    return google_workspace_service.status(user["id"])


@router.post("/gmail/connect")
async def connect_gmail(
    user: Annotated[dict[str, str], Depends(get_current_user)],
) -> dict[str, str]:
    return {"authorization_url": google_workspace_service.authorization_url(user["id"])}


@router.get("/gmail/callback", response_class=HTMLResponse)
async def gmail_callback(code: Annotated[str, Query()], state: Annotated[str, Query()]) -> str:
    email = await google_workspace_service.finish_connection(code, state)
    return (
        "<html><body style='font-family:sans-serif;text-align:center;padding:48px'>"
        f"<h2>Gmail connected</h2><p>{email} is ready in Qeon AI.</p>"
        "<p>You can close this window and return to the app.</p></body></html>"
    )


@router.delete("/gmail")
async def disconnect_gmail(
    user: Annotated[dict[str, str], Depends(get_current_user)],
) -> dict[str, bool]:
    await google_workspace_service.disconnect(user["id"])
    return {"disconnected": True}
