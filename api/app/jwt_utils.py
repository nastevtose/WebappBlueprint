from datetime import UTC, datetime, timedelta

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.config import settings

_bearer = HTTPBearer(auto_error=False)

TOKEN_EXPIRE_DAYS = 7


def create_access_token(email: str, name: str) -> str:
    payload = {
        "sub": email,
        "name": name,
        "exp": datetime.now(UTC) + timedelta(days=TOKEN_EXPIRE_DAYS),
    }
    return jwt.encode(payload, settings.secret_key, algorithm="HS256")


def decode_token(token: str) -> dict:
    return jwt.decode(token, settings.secret_key, algorithms=["HS256"])


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> dict:
    if not credentials:
        raise HTTPException(status_code=401, detail="Not authenticated")
    try:
        return decode_token(credentials.credentials)
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
