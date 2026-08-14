from app.schemas.common import MemoryCreate, MemoryOut, TaskCreate, TaskOut


class InMemoryStore:
    def __init__(self) -> None:
        self.tasks: list[TaskOut] = []
        self.memories: list[MemoryOut] = [
            MemoryOut(
                category="Preferences", title="UI style", value="Light lavender with purple accents"
            ),
            MemoryOut(category="Goals", title="Product", value="Build and launch Qeon AI"),
        ]

    def add_task(self, payload: TaskCreate) -> TaskOut:
        task = TaskOut(**payload.model_dump())
        self.tasks.append(task)
        return task

    def add_memory(self, payload: MemoryCreate) -> MemoryOut:
        memory = MemoryOut(**payload.model_dump())
        self.memories.append(memory)
        return memory


store = InMemoryStore()
