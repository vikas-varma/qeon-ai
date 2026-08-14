# API contract

Base path: `/api/v1`

- `GET /health`
- `GET /users/me`
- `PATCH /users/me`
- `POST /chat/stream` — Server-Sent Events
- `GET /agents`
- `PATCH /agents/{agent_id}`
- `GET /tasks`
- `POST /tasks`
- `PATCH /tasks/{task_id}`
- `DELETE /tasks/{task_id}`
- `GET /memories`
- `POST /memories`
- `DELETE /memories/{memory_id}`
- `DELETE /memories`

The starter returns in-memory demonstration data. Replace repositories with PostgreSQL implementations before production.
