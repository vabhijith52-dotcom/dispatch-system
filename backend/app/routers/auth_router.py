from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.schemas import LoginRequest, TokenResponse
from app.database import get_db
from app.models import User
from app.auth import create_access_token, verify_password

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    # Real DB-backed login: add/remove/rename accounts by editing the
    # `users` table directly (see sql/seed.sql for how to hash a
    # password) — no code or .env change needed anymore.
    user = db.query(User).filter(User.username == payload.username).first()
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password",
        )
    token = create_access_token({"sub": user.username})
    return TokenResponse(access_token=token)
