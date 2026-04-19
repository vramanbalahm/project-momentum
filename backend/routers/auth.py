from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime, timedelta
from pydantic import BaseModel, EmailStr
from uuid import uuid4
import hashlib
import os

from database import SessionLocal
from services.otp_service import generate_otp, verify_otp
from services.email_service import send_otp_email

# Feature flag — set EMAIL_VERIFY_ENABLED=false in .env to bypass OTP during testing
EMAIL_VERIFY_ENABLED = os.getenv("EMAIL_VERIFY_ENABLED", "true").lower() == "true"
from auth.security import (
    hash_password, verify_password,
    create_access_token, create_refresh_token,
    decode_access_token, REFRESH_TOKEN_EXPIRE_DAYS
)
from auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/auth", tags=["Authentication"])

# ── DB dependency ─────────────────────────────────────────────────────────────
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ── Schemas ───────────────────────────────────────────────────────────────────
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    name: str
    house_name: str
    primary_region: str = "Tamil Nadu"
    current_city: str = "Bengaluru"
    dietary_preference: str = "Veg"

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class RefreshRequest(BaseModel):
    refresh_token: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class CreateMemberRequest(BaseModel):
    email: EmailStr
    password: str
    name: str

class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

# ── Helpers ───────────────────────────────────────────────────────────────────
def issue_tokens(db: Session, user_id: str, house_id: str, role: str) -> dict:
    access_token = create_access_token(
        sub=user_id,
        org_id=house_id,
        role=role
    )
    plaintext, token_hash = create_refresh_token()
    expires = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    db.execute(text("""
        INSERT INTO refresh_tokens (user_id, house_id, token_hash, expires_at)
        VALUES (CAST(:uid AS uuid), CAST(:hid AS uuid), :hash, :exp)
    """), {"uid": user_id, "hid": house_id, "hash": token_hash, "exp": expires})

    db.execute(text("""
        UPDATE users SET last_login_at = :now
        WHERE user_id = CAST(:uid AS uuid)
    """), {"now": datetime.utcnow(), "uid": user_id})

    db.commit()
    return {"access_token": access_token, "refresh_token": plaintext, "token_type": "bearer"}

# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/register", response_model=TokenResponse)
async def register(req: RegisterRequest, db: Session = Depends(get_db)):
    """
    Self-registration — creates a new household + household_admin user.
    Rules:
    - Email must not already exist in users table
    - Creates household_master record
    - Creates user with role = household_admin
    - Sets household.admin_user_id
    """
    # Check email not already taken
    existing = db.execute(text(
        "SELECT user_id FROM users WHERE email = :email"
    ), {"email": req.email}).fetchone()

    if existing:
        raise HTTPException(
            status_code=409,
            detail="This email is already registered. Please log in instead."
        )

    if len(req.password) < 8:
        raise HTTPException(
            status_code=422,
            detail="Password must be at least 8 characters."
        )

    # Create household
    house_id = str(uuid4())
    db.execute(text("""
        INSERT INTO household_master
            (household_id, house_name, dietary_preference, primary_region,
             native_region, current_city, is_active, onboarding_done)
        VALUES
            (CAST(:hid AS uuid), :hname, CAST(:diet AS diet_pref),
             :region, :region, :city, true, false)
    """), {
        "hid": house_id,
        "hname": req.house_name,
        "diet": req.dietary_preference,
        "region": req.primary_region,
        "city": req.current_city
    })

    # Create household_admin user
    user_id = str(uuid4())
    db.execute(text("""
        INSERT INTO users
            (user_id, house_id, email, name, password_hash, role, is_active)
        VALUES
            (CAST(:uid AS uuid), CAST(:hid AS uuid), :email, :name,
             :pwd, 'household_admin', true)
    """), {
        "uid": user_id,
        "hid": house_id,
        "email": req.email,
        "name": req.name,
        "pwd": hash_password(req.password)
    })

    # Set admin_user_id on household
    db.execute(text("""
        UPDATE household_master
        SET admin_user_id = CAST(:uid AS uuid)
        WHERE household_id = CAST(:hid AS uuid)
    """), {"uid": user_id, "hid": house_id})

    return issue_tokens(db, user_id, house_id, "household_admin")


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: Session = Depends(get_db)):
    """
    Login — checks user exists, password correct, user active, household active.
    """
    row = db.execute(text("""
        SELECT u.user_id, u.house_id, u.password_hash, u.role,
               u.is_active, h.is_active as house_active
        FROM users u
        JOIN household_master h ON u.house_id = h.household_id
        WHERE u.email = :email
    """), {"email": req.email}).fetchone()

    if not row:
        raise HTTPException(status_code=401, detail="Invalid email or password.")

    if not verify_password(req.password, row.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password.")

    if not row.is_active:
        raise HTTPException(status_code=403, detail="Your account has been deactivated. Contact your household admin.")

    if not row.house_active:
        raise HTTPException(status_code=403, detail="This household account is inactive. Please contact support.")

    return issue_tokens(db, str(row.user_id), str(row.house_id), row.role)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(req: RefreshRequest, db: Session = Depends(get_db)):
    token_hash = hashlib.sha256(req.refresh_token.encode()).hexdigest()

    rt = db.execute(text("""
        SELECT rt.user_id, rt.house_id, u.role
        FROM refresh_tokens rt
        JOIN users u ON rt.user_id = u.user_id
        WHERE rt.token_hash = :hash
          AND rt.revoked = false
          AND rt.expires_at > :now
    """), {"hash": token_hash, "now": datetime.utcnow()}).fetchone()

    if not rt:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token.")

    # Revoke old token
    db.execute(text("""
        UPDATE refresh_tokens SET revoked = true
        WHERE token_hash = :hash
    """), {"hash": token_hash})
    db.commit()

    return issue_tokens(db, str(rt.user_id), str(rt.house_id), rt.role)


@router.post("/logout", status_code=204)
async def logout(req: RefreshRequest, db: Session = Depends(get_db)):
    token_hash = hashlib.sha256(req.refresh_token.encode()).hexdigest()
    db.execute(text("""
        UPDATE refresh_tokens SET revoked = true
        WHERE token_hash = :hash
    """), {"hash": token_hash})
    db.commit()


@router.get("/me")
async def me(current_user: dict = Depends(get_current_user),
             db: Session = Depends(get_db)):
    house = db.execute(text("""
        SELECT house_name, dietary_preference, primary_region,
               current_city, subscription_tier, onboarding_done
        FROM household_master
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": current_user["house_id"]}).fetchone()

    return {
        **current_user,
        "house_name":        house.house_name if house else None,
        "dietary_preference": str(house.dietary_preference) if house else None,
        "primary_region":    house.primary_region if house else None,
        "current_city":      house.current_city if house else None,
        "subscription_tier": house.subscription_tier if house else "free",
        "onboarding_done":   house.onboarding_done if house else False
    }


@router.post("/members/create", status_code=201)
async def create_member(
    req: CreateMemberRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Admin-only — creates a household_member under the same household.
    Members cannot self-register into an existing household.
    """
    # Check email not taken
    existing = db.execute(text(
        "SELECT user_id FROM users WHERE email = :email"
    ), {"email": req.email}).fetchone()

    if existing:
        raise HTTPException(
            status_code=409,
            detail="This email is already registered in the system."
        )

    if len(req.password) < 8:
        raise HTTPException(
            status_code=422,
            detail="Password must be at least 8 characters."
        )

    user_id = str(uuid4())
    db.execute(text("""
        INSERT INTO users
            (user_id, house_id, email, name, password_hash, role, is_active, created_by)
        VALUES
            (CAST(:uid AS uuid), CAST(:hid AS uuid), :email, :name,
             :pwd, 'household_member', true, CAST(:admin AS uuid))
    """), {
        "uid": user_id,
        "hid": current_user["house_id"],
        "email": req.email,
        "name": req.name,
        "pwd": hash_password(req.password),
        "admin": current_user["user_id"]
    })
    db.commit()

    return {"user_id": user_id, "message": f"Member {req.name} created successfully."}


@router.post("/change-password", status_code=204)
async def change_password(
    req: ChangePasswordRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    row = db.execute(text(
        "SELECT password_hash FROM users WHERE user_id = CAST(:uid AS uuid)"
    ), {"uid": current_user["user_id"]}).fetchone()

    if not verify_password(req.current_password, row.password_hash):
        raise HTTPException(status_code=401, detail="Current password is incorrect.")

    if len(req.new_password) < 8:
        raise HTTPException(status_code=422, detail="Password must be at least 8 characters.")

    db.execute(text("""
        UPDATE users SET password_hash = :pwd
        WHERE user_id = CAST(:uid AS uuid)
    """), {"pwd": hash_password(req.new_password), "uid": current_user["user_id"]})
    db.commit()


# ── OTP endpoints ─────────────────────────────────────────────────────────────

class SendOtpRequest(BaseModel):
    email: EmailStr
    name: str = ""

class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str

@router.post("/send-otp", status_code=200)
async def send_otp(req: SendOtpRequest):
    """
    Generate and email an OTP to the given address.
    If EMAIL_VERIFY_ENABLED is false, returns success without sending.
    """
    if not EMAIL_VERIFY_ENABLED:
        return {"message": "Email verification disabled — OTP skipped.", "enabled": False}

    otp = generate_otp(req.email)
    sent = send_otp_email(req.email, otp, req.name)
    if not sent:
        raise HTTPException(status_code=500, detail="Failed to send verification email. Check server email config.")
    return {"message": "OTP sent successfully.", "enabled": True}


@router.post("/verify-otp", status_code=200)
async def verify_otp_endpoint(req: VerifyOtpRequest):
    """
    Verify the OTP submitted by the user.
    If EMAIL_VERIFY_ENABLED is false, always returns verified=True.
    """
    if not EMAIL_VERIFY_ENABLED:
        return {"verified": True, "message": "Email verification disabled — auto-verified."}

    valid = verify_otp(req.email, req.otp)
    if not valid:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP. Please try again.")
    return {"verified": True, "message": "Email verified successfully."}
