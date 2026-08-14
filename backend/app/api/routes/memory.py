from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Response, status

from app.core.security import get_current_user
from app.repositories.memory_store import store
from app.schemas.common import MemoryCreate, MemoryOut

router = APIRouter()


@router.get("", response_model=list[MemoryOut])
async def list_memories(_: Annotated[dict[str, str], Depends(get_current_user)]) -> list[MemoryOut]:
    return store.memories


@router.post("", response_model=MemoryOut, status_code=status.HTTP_201_CREATED)
async def create_memory(
    payload: MemoryCreate, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> MemoryOut:
    return store.add_memory(payload)


@router.delete("/{memory_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_memory(
    memory_id: str, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> Response:
    before = len(store.memories)
    store.memories = [memory for memory in store.memories if memory.id != memory_id]
    if len(store.memories) == before:
        raise HTTPException(status_code=404, detail="Memory not found")
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def clear_memories(_: Annotated[dict[str, str], Depends(get_current_user)]) -> Response:
    store.memories = []
    return Response(status_code=status.HTTP_204_NO_CONTENT)
