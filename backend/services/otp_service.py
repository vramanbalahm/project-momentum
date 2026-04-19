import random
import string
from datetime import datetime, timedelta

# In-memory OTP store — { email: { otp, expires_at } }
# Good enough for development; replace with Redis for production
_otp_store: dict = {}

OTP_EXPIRY_MINUTES = 5


def generate_otp(email: str) -> str:
    """Generate a 6-digit OTP, store it against the email, return the OTP."""
    otp = "".join(random.choices(string.digits, k=6))
    _otp_store[email.lower()] = {
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_MINUTES)
    }
    return otp


def verify_otp(email: str, otp: str) -> bool:
    """Return True if OTP matches and has not expired. Clears OTP on success."""
    record = _otp_store.get(email.lower())
    if not record:
        return False
    if datetime.utcnow() > record["expires_at"]:
        _otp_store.pop(email.lower(), None)
        return False
    if record["otp"] != otp.strip():
        return False
    # Valid — consume it
    _otp_store.pop(email.lower(), None)
    return True


def clear_otp(email: str):
    """Explicitly clear OTP for an email (e.g. on registration abort)."""
    _otp_store.pop(email.lower(), None)
