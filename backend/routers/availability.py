# routers/availability.py
# Member availability for weekly meal planning
#
# Endpoints:
#   GET  /availability/week   — returns availability for a given week (all members present by default)
#   POST /availability/save   — upserts absence records into meal_attendance_log

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from typing import List
from datetime import date, timedelta
from database import SessionLocal
from auth.dependencies import get_current_user

router = APIRouter(prefix="/availability", tags=["Availability"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ── Helpers ───────────────────────────────────────────────────────────────────

def get_week_start(d: date) -> date:
    """Return the Monday of the week containing d."""
    return d - timedelta(days=d.weekday())

MEAL_SLOTS = ["Breakfast", "Lunch", "Dinner"]

# ── Schemas ───────────────────────────────────────────────────────────────────

class SlotAvailability(BaseModel):
    meal_date: str          # YYYY-MM-DD
    meal_slot: str          # Breakfast | Lunch | Dinner
    absent_member_ids: List[str]

class SaveAvailabilityRequest(BaseModel):
    week_start_date: str    # YYYY-MM-DD (Monday)
    slots: List[SlotAvailability]

# ── GET /availability/week ────────────────────────────────────────────────────

@router.get("/week")
async def get_week_availability(
    week_start: str = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns availability grid for the requested week.
    week_start: Monday date as YYYY-MM-DD. Defaults to current week.
    Response shape: { week_start, members, slots: [{meal_date, meal_slot, absent_member_ids}] }
    If no rows saved yet — returns all slots with empty absent_member_ids (everyone present).
    """
    house_id = current_user["house_id"]

    # Resolve week start
    if week_start:
        try:
            week_date = date.fromisoformat(week_start)
        except ValueError:
            raise HTTPException(status_code=400, detail="week_start must be YYYY-MM-DD")
    else:
        week_date = get_week_start(date.today())

    week_end = week_date + timedelta(days=6)

    # Fetch all household members
    members = db.execute(text("""
        SELECT user_id, name
        FROM users
        WHERE house_id = CAST(:hid AS uuid)
          AND is_active = true
        ORDER BY created_at
    """), {"hid": house_id}).fetchall()

    # Fetch saved attendance rows for this week (via session or direct date match)
    rows = db.execute(text("""
        SELECT meal_date, meal_slot, absent_member_ids
        FROM meal_attendance_log
        WHERE session_id IN (
            SELECT session_id FROM weekly_planning_session
            WHERE house_id = CAST(:hid AS uuid)
        )
        AND meal_date BETWEEN :start AND :end
        ORDER BY meal_date, meal_slot
    """), {"hid": house_id, "start": week_date, "end": week_end}).fetchall()

    # Build lookup: (date_str, slot) -> absent_ids
    saved = {}
    for r in rows:
        key = (str(r.meal_date), r.meal_slot)
        saved[key] = [str(uid) for uid in (r.absent_member_ids or [])]

    # Build full 7×3 grid — fill from saved or default to all present
    slots = []
    for i in range(7):
        d = week_date + timedelta(days=i)
        d_str = str(d)
        for slot in MEAL_SLOTS:
            key = (d_str, slot)
            slots.append({
                "meal_date": d_str,
                "meal_slot": slot,
                "absent_member_ids": saved.get(key, [])
            })

    return {
        "week_start": str(week_date),
        "week_end": str(week_end),
        "is_current_week": week_date == get_week_start(date.today()),
        "has_saved": len(rows) > 0,   # True if any rows exist in DB for this week
        "members": [{"user_id": str(m.user_id), "name": m.name} for m in members],
        "slots": slots
    }


# ── POST /availability/save ───────────────────────────────────────────────────

@router.post("/save", status_code=200)
async def save_week_availability(
    req: SaveAvailabilityRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Upserts absence records for the week into meal_attendance_log.
    Creates a weekly_planning_session if one doesn't exist for this house+week.
    Only the current week can be modified — past weeks are rejected.
    """
    house_id = current_user["house_id"]

    try:
        week_date = date.fromisoformat(req.week_start_date)
    except ValueError:
        raise HTTPException(status_code=400, detail="week_start_date must be YYYY-MM-DD")

    current_week = get_week_start(date.today())
    if week_date < current_week:
        raise HTTPException(status_code=403, detail="Cannot modify availability for past weeks.")

    # Get or create weekly_planning_session for this house + week
    session = db.execute(text("""
        SELECT session_id FROM weekly_planning_session
        WHERE house_id = CAST(:hid AS uuid)
          AND week_start_date = :wstart
    """), {"hid": house_id, "wstart": week_date}).fetchone()

    if session:
        session_id = str(session.session_id)
    else:
        result = db.execute(text("""
            INSERT INTO weekly_planning_session (house_id, week_start_date, session_status)
            VALUES (CAST(:hid AS uuid), :wstart, 'Draft')
            RETURNING session_id
        """), {"hid": house_id, "wstart": week_date})
        session_id = str(result.fetchone().session_id)

    # Upsert each slot
    for slot in req.slots:
        # Validate slot
        if slot.meal_slot not in MEAL_SLOTS:
            continue

        absent_ids = slot.absent_member_ids or []
        # Convert list to Postgres UUID array literal
        if absent_ids:
            array_literal = "ARRAY[" + ",".join(f"'{uid}'::uuid" for uid in absent_ids) + "]"
        else:
            array_literal = "ARRAY[]::uuid[]"

        # Delete existing row for this session+date+slot then insert fresh
        db.execute(text("""
            DELETE FROM meal_attendance_log
            WHERE session_id = CAST(:sid AS uuid)
              AND meal_date = CAST(:mdate AS date)
              AND meal_slot = :mslot
        """), {"sid": session_id, "mdate": slot.meal_date, "mslot": slot.meal_slot})

        db.execute(text(f"""
            INSERT INTO meal_attendance_log
                (session_id, meal_date, meal_slot, absent_member_ids, last_updated)
            VALUES
                (CAST(:sid AS uuid), CAST(:mdate AS date), :mslot,
                 {array_literal}, NOW())
        """), {"sid": session_id, "mdate": slot.meal_date, "mslot": slot.meal_slot})

    db.commit()
    return {"message": "Availability saved.", "session_id": session_id, "week_start": str(week_date)}
