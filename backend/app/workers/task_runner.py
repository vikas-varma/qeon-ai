from dataclasses import dataclass


@dataclass(frozen=True)
class TaskExecutionResult:
    task_id: str
    status: str
    summary: str


async def execute_scheduled_task(task_id: str) -> TaskExecutionResult:
    """Worker entry point.

    Connect this function to Celery/Redis or another durable queue. It must check
    permissions and approval state before any external side effect.
    """
    return TaskExecutionResult(task_id=task_id, status="completed", summary="Demo task completed")
