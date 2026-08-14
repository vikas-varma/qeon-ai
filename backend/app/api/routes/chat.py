from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse

from app.core.security import get_current_user
from app.schemas.common import ChatRequest
from app.services.chat_service import stream_answer

router = APIRouter()


@router.post("/stream")
async def chat_stream(
    payload: ChatRequest, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> StreamingResponse:
    return StreamingResponse(stream_answer(payload.message), media_type="text/event-stream")
