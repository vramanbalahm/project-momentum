# FT-071 to FT-073 — Behavioral tracking
# Functions: log_behavioral_event, log_weekly_session_context,
#            update_current_pattern
from fastapi import APIRouter
router = APIRouter(prefix="/tracking", tags=["tracking"])
