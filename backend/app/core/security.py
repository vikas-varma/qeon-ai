from typing import Annotated

from fastapi import Header, HTTPException, status


async def get_current_user(authorization: Annotated[str | None, Header()] = None) -> dict[str, str]:
    """Demo identity dependency.

    Replace with Firebase Admin token verification. The demo accepts missing
    authorization so the generated mobile UI works immediately.
    """
    if authorization and not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authorization header"
        )
    return {"id": "demo-user", "name": "Vikas", "email": "vikas@example.com"}
