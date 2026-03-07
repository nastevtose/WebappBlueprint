from authlib.integrations.starlette_client import OAuth
from fastapi import APIRouter, Depends
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.requests import Request

from app.config import settings
from app.database import get_db
from app.jwt_utils import create_access_token, get_current_user
from app.models import User

router = APIRouter(prefix="/auth")

oauth = OAuth()
oauth.register(
    name="google",
    client_id=settings.google_client_id,
    client_secret=settings.google_client_secret,
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"},
)


@router.get("/google")
async def google_login(request: Request):
    redirect_uri = str(request.url_for("google_callback"))
    return await oauth.google.authorize_redirect(request, redirect_uri)


@router.get("/google/callback", name="google_callback")
async def google_callback(request: Request, db: AsyncSession = Depends(get_db)):
    token = await oauth.google.authorize_access_token(request)
    info = token["userinfo"]

    result = await db.execute(select(User).where(User.google_id == info["sub"]))
    user = result.scalar_one_or_none()

    if not user:
        user = User(email=info["email"], name=info["name"], google_id=info["sub"])
        db.add(user)
        await db.commit()

    jwt_token = create_access_token(email=user.email, name=user.name)
    return RedirectResponse(f"{settings.frontend_url}?token={jwt_token}")


@router.get("/me")
async def me(current_user: dict = Depends(get_current_user)) -> dict:
    return {"email": current_user["sub"], "name": current_user["name"]}
