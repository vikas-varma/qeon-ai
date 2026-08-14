# Database migrations

Initialize Alembic in this directory after selecting the production database URL:

```bash
alembic init migrations
alembic revision --autogenerate -m "initial schema"
alembic upgrade head
```

Import `app.models.Base.metadata` inside Alembic `env.py`.
