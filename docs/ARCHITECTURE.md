# Qeon AI architecture

## Client layers

```text
Presentation (screens + reusable widgets)
        ↓
Application state (Riverpod Notifiers)
        ↓
Repositories (mock or remote implementation)
        ↓
Dio API client / secure local storage
```

Each feature can later be split into `data`, `domain`, and `presentation` subfolders without changing the public routes.

## Backend layers

```text
FastAPI router
    ↓
Application service
    ↓
Repository
    ↓
PostgreSQL / Redis / external provider
```

## Main workflow

```text
User input
  → authentication check
  → retrieve allowed memories
  → determine agent/tool
  → request confirmation for side effects
  → execute model/tool
  → stream result
  → save conversation and audit event
```

## Permission model

- Reading connected information requires granted OAuth scopes.
- Drafting is allowed after connection.
- Sending, deleting, purchasing, or changing external data requires explicit confirmation.
- Every side effect should create an audit record.
