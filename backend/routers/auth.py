from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime, timedelta, timezone
from pydantic import BaseModel, EmailStr
from uuid import uuid4
import hashlib
import os

from database import SessionLocal
from services.otp_service import generate_otp, verify_otp
from services.email_service import send_otp_email

# Feature flag — set EMAIL_VERIFY_ENABLED=false in .env to bypass OTP during testing
EMAIL_VERIFY_ENABLED = os.getenv("EMAIL_VERIFY_ENABLED", "true").lower() == "true"

# ── Rate limiting — in-memory, per IP ─────────────────────────────────────────
from collections import defaultdict
from datetime import datetime as dt
import time

_rate_store: dict = defaultdict(list)  # { ip: [timestamp, ...] }
RATE_LIMIT_MAX = 5       # max attempts
RATE_LIMIT_WINDOW = 900  # 15 minutes in seconds

# Set RATE_LIMIT_ENABLED=false in .env to disable rate limiting during automated tests
RATE_LIMIT_ENABLED = os.getenv("RATE_LIMIT_ENABLED", "true").lower() == "true"

def check_rate_limit(ip: str):
    if not RATE_LIMIT_ENABLED:
        return  # bypassed — testing mode
    now = time.time()
    window_start = now - RATE_LIMIT_WINDOW
    # Keep only attempts within the window
    _rate_store[ip] = [t for t in _rate_store[ip] if t > window_start]
    if len(_rate_store[ip]) >= RATE_LIMIT_MAX:
        raise HTTPException(
            status_code=429,
            detail="Too many attempts. Please wait 15 minutes before trying again."
        )
    _rate_store[ip].append(now)
from auth.security import (
    hash_password, verify_password, validate_password,
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
    household_allergies: str = None
    cuisine_sub_region_id: int = None

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
    expires = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    db.execute(text("""
        INSERT INTO refresh_tokens (user_id, house_id, token_hash, expires_at)
        VALUES (CAST(:uid AS uuid), CAST(:hid AS uuid), :hash, :exp)
    """), {"uid": user_id, "hid": house_id, "hash": token_hash, "exp": expires})

    db.execute(text("""
        UPDATE users SET last_login_at = :now
        WHERE user_id = CAST(:uid AS uuid)
    """), {"now": datetime.now(timezone.utc), "uid": user_id})

    db.commit()
    return {"access_token": access_token, "refresh_token": plaintext, "token_type": "bearer"}

# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/register", response_model=TokenResponse)
async def register(req: RegisterRequest, request: Request, db: Session = Depends(get_db)):
    check_rate_limit(request.client.host)
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

    pwd_errors = validate_password(req.password)
    if pwd_errors:
        raise HTTPException(status_code=422, detail=" ".join(pwd_errors))

    # Create household
    house_id = str(uuid4())
    db.execute(text("""
        INSERT INTO household_master
            (household_id, house_name, dietary_preference, primary_region,
             native_region, current_city, is_active, onboarding_done,
             household_allergies, cuisine_sub_region_id)
        VALUES
            (CAST(:hid AS uuid), :hname, CAST(:diet AS diet_pref),
             :region, :region, :city, true, false,
             :allergies, :sub_region_id)
    """), {
        "hid":          house_id,
        "hname":        req.house_name,
        "diet":         req.dietary_preference,
        "region":       req.primary_region,
        "city":         req.current_city,
        "allergies":    req.household_allergies,
        "sub_region_id": req.cuisine_sub_region_id
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
async def login(req: LoginRequest, request: Request, db: Session = Depends(get_db)):
    check_rate_limit(request.client.host)
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
    """), {"hash": token_hash, "now": datetime.now(timezone.utc)}).fetchone()

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
               current_city, subscription_tier, onboarding_done,
               household_allergies, cuisine_sub_region_id
        FROM household_master
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": current_user["house_id"]}).fetchone()

    # Resolve cuisine state and region from cuisine_sub_region_id
    cuisine_state = None
    cuisine_region = None
    if house and house.cuisine_sub_region_id:
        cr = db.execute(text("""
            SELECT state, region FROM cuisine_regions
            WHERE id = :id
        """), {"id": house.cuisine_sub_region_id}).fetchone()
        if cr:
            cuisine_state  = cr.state
            cuisine_region = cr.region

    # Resolve city state from current_city
    city_state = None
    if house and house.current_city:
        cs = db.execute(text("""
            SELECT state FROM cities
            WHERE display_name = :city AND is_active = true
            LIMIT 1
        """), {"city": house.current_city}).fetchone()
        if cs:
            city_state = cs.state

    return {
        **current_user,
        "house_name":            house.house_name if house else None,
        "dietary_preference":    str(house.dietary_preference) if house else None,
        "primary_region":        house.primary_region if house else None,
        "current_city":          house.current_city if house else None,
        "subscription_tier":     house.subscription_tier if house else "free",
        "onboarding_done":       house.onboarding_done if house else False,
        "household_allergies":   house.household_allergies if house else None,
        "cuisine_sub_region_id": house.cuisine_sub_region_id if house else None,
        "cuisine_state":         cuisine_state,
        "cuisine_region":        cuisine_region,
        "city_state":            city_state,
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

    pwd_errors = validate_password(req.password)
    if pwd_errors:
        raise HTTPException(status_code=422, detail=" ".join(pwd_errors))

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

    pwd_errors = validate_password(req.new_password)
    if pwd_errors:
        raise HTTPException(status_code=422, detail=" ".join(pwd_errors))

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


# ── Profile update (admin only) ────────────────────────────────────────────────

class ProfileUpdateRequest(BaseModel):
    house_name: str = None
    primary_region: str = None
    current_city: str = None
    dietary_preference: str = None
    cuisine_sub_region_id: int = None
    household_allergies: str = None  # comma-separated list

@router.put("/profile", status_code=200)
async def update_profile(
    req: ProfileUpdateRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """Admin-only — update household profile fields with audit trail."""
    house_id = current_user["house_id"]
    user_id = current_user["user_id"]

    # Fetch current values for audit
    current = db.execute(text("""
        SELECT house_name, dietary_preference, primary_region,
               current_city, cuisine_sub_region_id, household_allergies
        FROM household_master WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()

    if not current:
        raise HTTPException(status_code=404, detail="Household not found.")

    updates = {}
    audit_entries = []

    def track(field, new_val, current_val):
        if new_val is not None and str(new_val) != str(current_val or ""):
            updates[field] = new_val
            audit_entries.append({"field": field, "old": str(current_val or ""), "new": str(new_val)})

    track("house_name",            req.house_name,            current.house_name)
    track("primary_region",        req.primary_region,        current.primary_region)
    track("current_city",          req.current_city,          current.current_city)
    track("dietary_preference",    req.dietary_preference,    current.dietary_preference)
    track("cuisine_sub_region_id", req.cuisine_sub_region_id, current.cuisine_sub_region_id)
    track("household_allergies",   req.household_allergies,   current.household_allergies)

    if not updates:
        return {"message": "No changes detected."}

    # Build dynamic UPDATE — dietary_preference must be cast to the diet_pref enum type
    set_clauses = []
    for k in updates:
        if k == "dietary_preference":
            set_clauses.append(f"{k} = CAST(:{k} AS diet_pref)")
        else:
            set_clauses.append(f"{k} = :{k}")
    params = {**updates, "hid": house_id}
    db.execute(text(f"""
        UPDATE household_master SET {', '.join(set_clauses)}
        WHERE household_id = CAST(:hid AS uuid)
    """), params)

    # Write audit log
    for entry in audit_entries:
        db.execute(text("""
            INSERT INTO profile_audit_log (house_id, changed_by, field_name, old_value, new_value)
            VALUES (CAST(:hid AS uuid), CAST(:uid AS uuid), :field, :old, :new)
        """), {"hid": house_id, "uid": user_id, "field": entry["field"], "old": entry["old"], "new": entry["new"]})

    db.commit()
    return {"message": f"{len(audit_entries)} field(s) updated successfully."}


# ── Member management (admin only) ────────────────────────────────────────────

class RoleUpdateRequest(BaseModel):
    user_id: str
    new_role: str  # 'household_admin' or 'household_member'

@router.get("/members", status_code=200)
async def list_members(
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """List all members in the household."""
    rows = db.execute(text("""
        SELECT user_id, name, email, role, is_active, created_at
        FROM users
        WHERE house_id = CAST(:hid AS uuid)
        ORDER BY created_at
    """), {"hid": current_user["house_id"]}).fetchall()
    return [{"user_id": str(r.user_id), "name": r.name, "email": r.email,
             "role": r.role, "is_active": r.is_active} for r in rows]


@router.put("/members/role", status_code=200)
async def update_member_role(
    req: RoleUpdateRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Admin-only — promote or demote a household member.
    On promotion to household_admin: generates temp password and emails the user.
    """
    allowed_roles = ["household_admin", "household_member"]
    if req.new_role not in allowed_roles:
        raise HTTPException(status_code=422, detail=f"Role must be one of: {allowed_roles}")

    # Fetch target user — must be in same household
    target = db.execute(text("""
        SELECT user_id, name, email, role FROM users
        WHERE user_id = CAST(:uid AS uuid) AND house_id = CAST(:hid AS uuid)
    """), {"uid": req.user_id, "hid": current_user["house_id"]}).fetchone()

    if not target:
        raise HTTPException(status_code=404, detail="Member not found in your household.")

    if str(target.user_id) == current_user["user_id"]:
        raise HTTPException(status_code=400, detail="You cannot change your own role.")

    is_promotion = (target.role == "household_member" and req.new_role == "household_admin")

    if is_promotion:
        # Generate temp password and update
        import secrets as sec
        temp_password = sec.token_urlsafe(10)
        from auth.security import hash_password as hp
        db.execute(text("""
            UPDATE users SET role = :role, password_hash = :pwd
            WHERE user_id = CAST(:uid AS uuid)
        """), {"role": req.new_role, "pwd": hp(temp_password), "uid": req.user_id})
        db.commit()
        # Email the promoted user
        send_otp_email.__module__  # ensure imported
        from services.email_service import send_otp_email as send_email
        # Reuse email service with custom message via a direct send
        import smtplib, os
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart
        gmail_user = os.getenv("GMAIL_USER", "vramanbala@gmail.com")
        gmail_pwd = os.getenv("GMAIL_APP_PASSWORD", "")
        if gmail_pwd:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = "You have been promoted — Momentum"
            msg["From"] = f"Momentum <{gmail_user}>"
            msg["To"] = target.email
            body = f"""
            <div style="font-family:system-ui,sans-serif;max-width:480px;margin:0 auto;">
              <div style="background:#1A3A2E;padding:24px;border-radius:16px 16px 0 0;text-align:center;">
                <div style="font-size:28px;">🌿</div>
                <div style="color:#FDFCF8;font-size:18px;font-weight:500;margin-top:6px;">Momentum</div>
              </div>
              <div style="background:#FFF9F2;padding:28px 24px;border-radius:0 0 16px 16px;">
                <p style="color:#2C2C2A;">Hi {target.name},</p>
                <p style="color:#2C2C2A;">You have been promoted to <strong>Household Admin</strong> by your household administrator.</p>
                <p style="color:#2C2C2A;">Your new temporary password is:</p>
                <div style="background:#E1F5EE;border-radius:12px;padding:16px;text-align:center;margin:16px 0;">
                  <div style="font-size:22px;font-weight:700;letter-spacing:4px;color:#1A3A2E;">{temp_password}</div>
                </div>
                <p style="color:#888780;font-size:12px;">Please log in and change your password immediately.</p>
              </div>
            </div>"""
            msg.attach(MIMEText(body, "html"))
            try:
                with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                    server.login(gmail_user, gmail_pwd)
                    server.sendmail(gmail_user, target.email, msg.as_string())
            except Exception as e:
                print(f"[role_email] Failed: {e}")
        return {"message": f"{target.name} promoted to admin. Temporary password sent to {target.email}."}
    else:
        # Demotion — just update role, no password change
        db.execute(text("""
            UPDATE users SET role = :role WHERE user_id = CAST(:uid AS uuid)
        """), {"role": req.new_role, "uid": req.user_id})
        db.commit()
        return {"message": f"{target.name} role updated to {req.new_role}."}


class DeactivateRequest(BaseModel):
    user_id: str
    is_active: bool  # true = activate, false = deactivate

@router.put("/members/deactivate", status_code=200)
async def deactivate_member(
    req: DeactivateRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """Admin-only — activate or deactivate a member. Admin cannot deactivate themselves."""
    if not req.is_active and req.user_id == current_user["user_id"]:
        raise HTTPException(status_code=403, detail="You cannot deactivate yourself.")

    target = db.execute(text("""
        SELECT user_id, name FROM users
        WHERE user_id = CAST(:uid AS uuid) AND house_id = CAST(:hid AS uuid)
    """), {"uid": req.user_id, "hid": current_user["house_id"]}).fetchone()

    if not target:
        raise HTTPException(status_code=404, detail="Member not found in your household.")

    db.execute(text("""
        UPDATE users SET is_active = :active WHERE user_id = CAST(:uid AS uuid)
    """), {"active": req.is_active, "uid": req.user_id})
    db.commit()

    status_str = "activated" if req.is_active else "deactivated"
    return {"user_id": req.user_id, "is_active": req.is_active, "message": f"{target.name} has been {status_str}."}


# ── My Profile ────────────────────────────────────────────────────────────────

class MyProfileUpdateRequest(BaseModel):
    name:         str = None   # Admin can update any member's name; user can update own
    age_group:    str = None   # Child | Teen | Adult | Senior
    gender:       str = None   # Male | Female | Transgender | Prefer not to say
    phone_number: str = None
    dietary_preference: str = None
    # Restrictions handled separately via /onboarding/members

@router.get("/my-profile")
async def get_my_profile(
    target_user_id: str = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns a user's personal profile.
    If target_user_id is provided and caller is admin — returns that member's profile.
    Otherwise returns the logged-in user's own profile.
    """
    is_admin = current_user["role"] in ("household_admin", "platform_admin")

    # Admin can view any member in their household
    if target_user_id and is_admin:
        # Verify target belongs to same household
        check = db.execute(text("""
            SELECT user_id FROM users
            WHERE user_id = CAST(:uid AS uuid)
              AND house_id = CAST(:hid AS uuid)
        """), {"uid": target_user_id, "hid": current_user["house_id"]}).fetchone()
        if not check:
            raise HTTPException(status_code=404, detail="Member not found in your household.")
        user_id  = target_user_id
        house_id = current_user["house_id"]
    else:
        user_id  = current_user["user_id"]
        house_id = current_user["house_id"]

    # Get user details
    user = db.execute(text("""
        SELECT user_id, name, email, role, phone_number, created_at
        FROM users WHERE user_id = CAST(:uid AS uuid)
    """), {"uid": user_id}).fetchone()

    # Get member preferences
    pref = db.execute(text("""
        SELECT dietary_preference, age_group, gender, display_name
        FROM member_preferences
        WHERE user_id = CAST(:uid AS uuid)
    """), {"uid": user_id}).fetchone()

    # Get restrictions
    restrictions = db.execute(text("""
        SELECT mr.id, mr.restriction_type,
               ic.id as ingredient_id, ic.name_en, ic.name_ta,
               ic.category, ic.thumb_url
        FROM member_restrictions mr
        JOIN ingredient_catalog ic ON ic.id = mr.ingredient_id
        WHERE mr.user_id = CAST(:uid AS uuid)
        ORDER BY mr.restriction_type, ic.name_en
    """), {"uid": user_id}).fetchall()

    return {
        "user_id":            str(user.user_id),
        "name":               user.name,
        "email":              user.email,
        "phone_number":       user.phone_number,
        "role":               str(user.role),
        "dietary_preference": str(pref.dietary_preference) if pref and pref.dietary_preference else None,
        "age_group":          pref.age_group if pref else None,
        "gender":             pref.gender if pref else None,
        "display_name":       pref.display_name if pref else None,
        "restrictions": [{
            "id":               r.id,
            "ingredient_id":    r.ingredient_id,
            "name_en":          r.name_en,
            "name_ta":          r.name_ta,
            "category":         r.category,
            "thumb_url":        r.thumb_url,
            "restriction_type": r.restriction_type,
        } for r in restrictions]
    }

@router.put("/my-profile", status_code=200)
async def update_my_profile(
    req: MyProfileUpdateRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
    target_user_id: str = None
):
    """
    Updates the logged-in user's personal profile.
    Admin can pass ?target_user_id= to update any member's profile (including name).
    """
    is_admin = current_user["role"] in ("household_admin", "platform_admin")
    # Admin can target another member — otherwise always own profile
    user_id  = target_user_id if (target_user_id and is_admin) else current_user["user_id"]
    house_id = current_user["house_id"]

    valid_age    = {"Child", "Teen", "Adult", "Senior", None}
    valid_gender = {"Male", "Female", "Transgender", "Prefer not to say", None}
    valid_diet   = {"Veg", "Non-Veg", "Vegan", "Eggitarian", None}

    if req.age_group not in valid_age:
        raise HTTPException(status_code=422, detail=f"Invalid age_group: {req.age_group}")
    if req.gender not in valid_gender:
        raise HTTPException(status_code=422, detail=f"Invalid gender: {req.gender}")
    if req.dietary_preference not in valid_diet:
        raise HTTPException(status_code=422, detail=f"Invalid dietary_preference: {req.dietary_preference}")

    # Update name on users table (admin can update any member via target_user_id)
    if req.name is not None and req.name.strip():
        db.execute(text("""
            UPDATE users SET name = :name
            WHERE user_id = CAST(:uid AS uuid)
        """), {"name": req.name.strip(), "uid": user_id})

    # Update phone_number on users table
    if req.phone_number is not None:
        db.execute(text("""
            UPDATE users SET phone_number = :phone
            WHERE user_id = CAST(:uid AS uuid)
        """), {"phone": req.phone_number or None, "uid": user_id})

    # Upsert member_preferences — always update all provided fields
    db.execute(text("""
        INSERT INTO member_preferences
            (user_id, house_id, dietary_preference, age_group, gender, updated_by)
        VALUES
            (CAST(:uid AS uuid), CAST(:hid AS uuid),
             CAST(:diet AS diet_pref), :age, :gender, CAST(:uid AS uuid))
        ON CONFLICT (user_id) DO UPDATE
        SET dietary_preference = CAST(:diet AS diet_pref),
            age_group          = :age,
            gender             = :gender,
            updated_at         = NOW(),
            updated_by         = CAST(:uid AS uuid)
    """), {
        "uid":    user_id,
        "hid":    house_id,
        "diet":   req.dietary_preference or "Veg",
        "age":    req.age_group,
        "gender": req.gender,
    })

    db.commit()
    return {"message": "Profile updated successfully."}


# ── Save own restrictions (available to all users) ────────────────────────────

class SelfRestrictionItem(BaseModel):
    ingredient_id:    int
    restriction_type: str  # Allergy | Dislike

class SaveSelfRestrictionsRequest(BaseModel):
    restrictions: list

@router.post("/my-profile/restrictions", status_code=200)
async def save_my_restrictions(
    req: SaveSelfRestrictionsRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Saves the logged-in user's own allergies and dislikes.
    Available to ALL users — not just admins.
    """
    user_id  = current_user["user_id"]
    house_id = current_user["house_id"]

    # Delete existing restrictions for this user
    db.execute(text("""
        DELETE FROM member_restrictions WHERE user_id = CAST(:uid AS uuid)
    """), {"uid": user_id})

    # Insert new restrictions
    for r in req.restrictions:
        ing_id = r.get("ingredient_id") if isinstance(r, dict) else r.ingredient_id
        rtype  = r.get("restriction_type") if isinstance(r, dict) else r.restriction_type
        if rtype not in ("Allergy", "Dislike"):
            continue
        db.execute(text("""
            INSERT INTO member_restrictions
                (user_id, house_id, ingredient_id, restriction_type, updated_by)
            VALUES
                (CAST(:uid AS uuid), CAST(:hid AS uuid), :iid, :rtype, CAST(:uid AS uuid))
            ON CONFLICT (user_id, ingredient_id, restriction_type) DO NOTHING
        """), {"uid": user_id, "hid": house_id, "iid": ing_id, "rtype": rtype})

    db.commit()
    return {"message": "Restrictions saved.", "count": len(req.restrictions)}
