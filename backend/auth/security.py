import os
import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
from pathlib import Path
from dotenv import load_dotenv
import bcrypt

# Load .env from root folder explicitly
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

SECRET_KEY = os.getenv("SECRET_KEY", "changeme")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 15))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

# Using bcrypt directly — passlib is incompatible with bcrypt on Python 3.14
def hash_password(plain: str) -> str:
    # bcrypt has a 72-byte hard limit — encode and truncate safely
    return bcrypt.hashpw(plain.encode("utf-8")[:72], bcrypt.gensalt()).decode("utf-8")

def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode("utf-8")[:72], hashed.encode("utf-8"))

def validate_password(password: str) -> list:
    """
    Returns a list of error messages for any rules the password violates.
    Empty list means the password is valid.
    Rules (matches frontend PasswordStrength component):
      - At least 8 characters
      - At least 1 uppercase letter
      - At least 1 number
      - At least 1 special character (@$!%*?&)
      - No spaces
    """
    import re
    errors = []
    if len(password) < 8:
        errors.append("Password must be at least 8 characters.")
    if not re.search(r"[A-Z]", password):
        errors.append("Password must contain at least 1 uppercase letter.")
    if not re.search(r"[0-9]", password):
        errors.append("Password must contain at least 1 number.")
    if not re.search(r"[@$!%*?&]", password):
        errors.append("Password must contain at least 1 special character (@$!%*?&).")
    if " " in password:
        errors.append("Password must not contain spaces.")
    return errors

def create_access_token(sub: str, org_id: str, role: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {
        "sub": sub,
        "org_id": org_id,
        "role": role,
        "exp": expire
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token() -> tuple[str, str]:
    """Returns (plaintext_token, sha256_hash)"""
    plaintext = secrets.token_hex(64)
    hashed = hashlib.sha256(plaintext.encode()).hexdigest()
    return plaintext, hashed

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None
