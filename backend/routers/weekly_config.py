# routers/weekly_config.py — Weekly generation questionnaire endpoints
#
# GET  /weekly-config              — get config for current week + generation count
# POST /weekly-config              — save questionnaire answers for this week
# GET  /weekly-config/should-ask   — should questionnaire be shown? (< 8 weeks data)

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from typing import Optional
from datetime import date, timedelta
from database import get_db
from auth.dependencies import get_current_user

router = APIRouter(prefix="/weekly-config", tags=["weekly-config"])

ML_THRESHOLD = 8  # Stop asking after 8 weeks of data


# ── GET /weekly-config/should-ask ────────────────────────────────────────────

@router.get("/should-ask", status_code=200)
async def should_ask_questionnaire(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns whether to show questionnaire before plan generation.
    True if household has < 8 weeks of data (still learning).
    False if >= 8 weeks — system has auto-learned preferences.
    """
    house_id = current_user["house_id"]

    row = db.execute(text("""
        SELECT COUNT(*) as count
        FROM weekly_generation_config
        WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()

    count = row.count if row else 0
    should_ask = count < ML_THRESHOLD

    return {
        "should_ask":       should_ask,
        "weeks_collected":  count,
        "ml_threshold":     ML_THRESHOLD,
        "message":          f"{count} of {ML_THRESHOLD} weeks collected" if should_ask
                            else "Auto-learned — using your preference profile"
    }


# ── GET /weekly-config ────────────────────────────────────────────────────────

@router.get("", status_code=200)
async def get_weekly_config(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get config for current week — returns defaults if not set yet."""
    house_id = current_user["house_id"]
    today = date.today()
    week_start = today - timedelta(days=today.weekday())

    row = db.execute(text("""
        SELECT continental_days, allow_same_day_repeat,
               allow_same_week_repeat, prefer_millet
        FROM weekly_generation_config
        WHERE house_id = CAST(:hid AS uuid)
        AND week_start = :ws
    """), {"hid": house_id, "ws": week_start}).fetchone()

    if row:
        return {
            "week_start":            str(week_start),
            "continental_days":      row.continental_days,
            "allow_same_day_repeat": row.allow_same_day_repeat,
            "allow_same_week_repeat":row.allow_same_week_repeat,
            "prefer_millet":         row.prefer_millet,
            "is_set":                True,
        }

    return {
        "week_start":            str(week_start),
        "continental_days":      0,
        "allow_same_day_repeat": False,
        "allow_same_week_repeat":True,
        "prefer_millet":         False,
        "is_set":                False,
    }


# ── POST /weekly-config ───────────────────────────────────────────────────────

class WeeklyConfigRequest(BaseModel):
    continental_days:       int     = 0
    allow_same_day_repeat:  bool    = False
    allow_same_week_repeat: bool    = True
    prefer_millet:          bool    = False

@router.post("", status_code=200)
async def save_weekly_config(
    req: WeeklyConfigRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Save questionnaire answers for current week."""
    house_id = current_user["house_id"]
    today = date.today()
    week_start = today - timedelta(days=today.weekday())

    db.execute(text("""
        INSERT INTO weekly_generation_config
            (house_id, week_start, continental_days,
             allow_same_day_repeat, allow_same_week_repeat, prefer_millet)
        VALUES
            (CAST(:hid AS uuid), :ws, :cd, :asd, :asw, :pm)
        ON CONFLICT (house_id, week_start) DO UPDATE SET
            continental_days        = EXCLUDED.continental_days,
            allow_same_day_repeat   = EXCLUDED.allow_same_day_repeat,
            allow_same_week_repeat  = EXCLUDED.allow_same_week_repeat,
            prefer_millet           = EXCLUDED.prefer_millet,
            updated_at              = NOW()
    """), {
        "hid": house_id,
        "ws":  week_start,
        "cd":  req.continental_days,
        "asd": req.allow_same_day_repeat,
        "asw": req.allow_same_week_repeat,
        "pm":  req.prefer_millet,
    })
    db.commit()

    return {"message": "Preferences saved for this week.", "week_start": str(week_start)}
