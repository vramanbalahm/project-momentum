# FT-030 to FT-037 — Weekly planning
# Functions: generate_weekly_plan_rule_based, process_weekly_questionnaire,
#            save_and_lock_plan, manage_meal_slot_dishes,
#            clone_previous_week, get_previous_week_plan,
#            run_plan_audit, send_planning_reminder

from fastapi import APIRouter, Depends, HTTPException
from auth.dependencies import get_current_user
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, datetime
from typing import Optional
from database import SessionLocal
from services.weekly_plan_service import generate_weekly_plan

router = APIRouter(prefix="/weekly-plan", tags=["weekly_plan"])

# ACTIVE_H_ID removed — endpoints now use get_current_user

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# --- FT-030: generate_weekly_plan_rule_based ---
@router.post("/generate")
def generate_weekly_plan_rule_based(
    week_start_date: str,
    cook_energy_level: Optional[str] = "Medium",
    guest_count: Optional[int] = 0,
    veg_nonveg_split: Optional[str] = "As Profile",
    questionnaire_week: Optional[int] = 1,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    FT-030: Generate a 7-day rule-based meal plan.
    Pure generation — does not persist. Call /save-plan to persist.

    week_start_date: Monday of the target week (YYYY-MM-DD)
    cook_energy_level: Low / Medium / High
    guest_count: number of guests this week
    veg_nonveg_split: As Profile / Full Veg / Mixed / Mostly NonVeg
    questionnaire_week: 1-4+ drives how many questions shown to user
    """
    try:
        week_date = datetime.strptime(week_start_date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="week_start_date must be in YYYY-MM-DD format"
        )

    # Build context from request parameters
    # Satvik days and event overrides will come from FT-023 once events are built
    context = {
        "cook_energy_level": cook_energy_level,
        "guest_count": guest_count,
        "veg_nonveg_split": veg_nonveg_split,
        "questionnaire_week": questionnaire_week,
        "event_overrides": {},      # FT-023 will populate this
        "satvik_days": [],          # FT-005 will populate this
        "market_stress": False,     # FT-054 will populate this
        "market_cap_level": 2,
        "daily_pattern": {},        # Fetched from DB by generate_weekly_plan
        "complexity_levels": {},    # Fetched from DB by generate_weekly_plan
        "mode": "Rule"
    }

    plan = generate_weekly_plan(
        db=db,
        h_id=current_user["house_id"],
        week_start_date=week_date,
        context=context
    )

    return plan


# --- FT-035: get_previous_week_plan ---
@router.get("/history/{week_start_date}")
def get_previous_week_plan(
    week_start_date: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    FT-035: Read-only view of any past week plan.
    Returns saved plan from meal_event_header + meal_event_detail.
    house_id from authenticated user.
    """
    from services.plan_service import fetch_active_plan
    return fetch_active_plan(db, current_user["house_id"])
