.PHONY: backend mobile test format

backend:
	cd backend && uvicorn app.main:app --reload

mobile:
	cd mobile && flutter run

test:
	cd backend && pytest -q

format:
	cd backend && ruff format .
	cd mobile && dart format lib test
