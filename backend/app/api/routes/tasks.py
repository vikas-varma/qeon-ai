from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Response, status

from app.core.security import get_current_user
from app.repositories.memory_store import store
from app.schemas.common import TaskCreate, TaskOut

router = APIRouter()


@router.get("", response_model=list[TaskOut])
async def list_tasks(_: Annotated[dict[str, str], Depends(get_current_user)]) -> list[TaskOut]:
    return store.tasks


@router.post("", response_model=TaskOut, status_code=status.HTTP_201_CREATED)
async def create_task(
    payload: TaskCreate, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> TaskOut:
    return store.add_task(payload)


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: str, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> Response:
    before = len(store.tasks)
    store.tasks = [task for task in store.tasks if task.id != task_id]
    if len(store.tasks) == before:
        raise HTTPException(status_code=404, detail="Task not found")
    return Response(status_code=status.HTTP_204_NO_CONTENT)
