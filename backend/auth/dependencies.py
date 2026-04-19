from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import SessionLocal
from auth.security import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    user_id = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    user = db.execute(text("""
        SELECT u.user_id, u.house_id, u.email, u.name, u.role, u.is_active,
               h.is_active as house_active
        FROM users u
        JOIN household_master h ON u.house_id = h.household_id
        WHERE u.user_id = CAST(:uid AS uuid)
    """), {"uid": user_id}).fetchone()

    if not user or not user.is_active or not user.house_active:
        raise credentials_exception

    return {
        "user_id":  str(user.user_id),
        "house_id": str(user.house_id),
        "email":    user.email,
        "name":     user.name,
        "role":     user.role
    }

def require_role(*roles):
    async def role_checker(current_user: dict = Depends(get_current_user)) -> dict:
        if current_user["role"] not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action"
            )
        return current_user
    return role_checker
