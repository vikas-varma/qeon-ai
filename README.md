# Qeon AI Full Starter

A production-oriented starter monorepo for the Qeon AI personal assistant.

## Included

- Flutter UI for splash, onboarding, sign-in, Home, Chat, Voice, Agents, Agent Detail, Tasks, History, Profile, Memory, Connected Apps, Appearance, Notifications, Privacy and Account.
- Shared Qeon AI design system based on the approved light lavender/purple interface.
- Riverpod state, GoRouter navigation and mock repositories so every screen is interactive without cloud credentials.
- FastAPI backend with modular routers for chat streaming, agents, tasks, memory and user profile.
- PostgreSQL/Redis Docker Compose services and environment templates.
- API contract, workflow notes and implementation checklist.

## Project layout

```text
qeonai_full_starter/
├── mobile/                 Flutter application source
├── backend/                FastAPI application
├── docs/                   Architecture, workflows and design reference
├── docker-compose.yml      PostgreSQL, Redis and backend
└── Makefile                Common commands
```

## Run the Flutter app

Flutter platform folders are generated locally because they contain machine- and SDK-specific files.

```bash
cd mobile
flutter create . --platforms=android,ios,web
flutter pub get
flutter run
```

The `flutter create .` command preserves the supplied `lib/` source and `pubspec.yaml` while creating Android, iOS and web runner folders.

## Run the backend without Docker

```bash
cd backend
python -m venv .venv
source .venv/bin/activate       # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

API documentation: `http://localhost:8000/docs`

## Run the full backend stack

```bash
cp backend/.env.example backend/.env
docker compose up --build
```

## Connect Flutter to the backend

The Flutter app uses mock repositories by default. To connect real APIs:

1. Set `useMockData` to `false` in `mobile/lib/core/config/app_config.dart`.
2. Set the API base URL with `--dart-define`:

```bash
flutter run --dart-define=QEON_API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Use `http://127.0.0.1:8000/api/v1` for iOS Simulator and the computer's LAN IP for a physical phone.

## Important production work

- Add Firebase Authentication configuration.
- Replace mock AI streaming with the selected model provider.
- Encrypt OAuth refresh tokens.
- Add database migrations and production tables.
- Add billing, push notifications and object storage.
- Add legal pages, consent flows and app-store configuration.

The supplied code is an extensive working starter, not a finished audited production service.
