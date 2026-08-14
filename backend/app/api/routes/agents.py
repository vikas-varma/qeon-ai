from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException

from app.core.security import get_current_user
from app.schemas.common import AgentOut

router = APIRouter()

AGENTS = [
    AgentOut(
        id="email",
        name="Email Agent",
        description="Draft and summarize email",
        capabilities=["summarize", "draft", "search"],
    ),
    AgentOut(
        id="calendar",
        name="Calendar Agent",
        description="Plan events and reminders",
        capabilities=["read calendar", "suggest times", "create with approval"],
    ),
    AgentOut(
        id="research",
        name="Research Agent",
        description="Research topics and organize sources",
        capabilities=["search", "summarize", "report"],
    ),
    AgentOut(
        id="finance",
        name="Finance Agent",
        description="Budget and spending insights",
        capabilities=["categorize", "budget", "report"],
    ),
]


@router.get("", response_model=list[AgentOut])
async def list_agents(_: Annotated[dict[str, str], Depends(get_current_user)]) -> list[AgentOut]:
    return AGENTS


@router.patch("/{agent_id}", response_model=AgentOut)
async def update_agent(
    agent_id: str, enabled: bool, _: Annotated[dict[str, str], Depends(get_current_user)]
) -> AgentOut:
    for index, agent in enumerate(AGENTS):
        if agent.id == agent_id:
            AGENTS[index] = agent.model_copy(update={"enabled": enabled})
            return AGENTS[index]
    raise HTTPException(status_code=404, detail="Agent not found")
