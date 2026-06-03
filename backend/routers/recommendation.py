# routers/recommendation.py — Recommendation Engine endpoints
#
# POST /recommendation/generate   — generate plan for current week
# GET  /recommendation/audit-log  — platform admin audit log viewer
# DELETE /recommendation/audit-log/purge — purge old logs

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from typing import Optional
from datetime import date, timedelta
from database import get_db
from auth.dependencies import get_current_user, require_role
from services.recommendation_service import generate_plan

router = APIRouter(prefix="/recommendation", tags=["recommendation"])


# ── POST /recommendation/generate ────────────────────────────────────────────

class GeneratePlanRequest(BaseModel):
    week_start:      Optional[str]  = None   # YYYY-MM-DD, defaults to current week
    fill_empty_only: bool           = True   # True = only fill empty slots

@router.post("/generate", status_code=200)
async def generate_recommendation(
    req: GeneratePlanRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Run Bucket A recommendation pipeline and fill plan slots.
    Each formula is loaded from feature_registry (active only).
    Every step is logged to plan_audit_log.
    """
    house_id = current_user["house_id"]

    # Default to current week Monday
    if req.week_start:
        ws = date.fromisoformat(req.week_start)
    else:
        today = date.today()
        ws = today - timedelta(days=today.weekday())  # Monday

    result = generate_plan(
        db=db,
        house_id=house_id,
        week_start=ws,
        fill_empty_only=req.fill_empty_only
    )

    # Count filled slots
    filled = sum(1 for day in result.values() for slot in day.values() if slot)
    empty  = 21 - filled

    return {
        "message":    f"Plan generated: {filled} slots filled, {empty} slots empty.",
        "week_start": str(ws),
        "plan":       result,
        "filled":     filled,
        "empty":      empty,
    }


# ── GET /recommendation/audit-log ────────────────────────────────────────────

@router.get("/audit-log", status_code=200)
async def get_audit_log(
    house_id:   Optional[str]  = Query(None),
    week_start: Optional[str]  = Query(None),
    feature_code: Optional[str] = Query(None),
    day_name:   Optional[str]  = Query(None),
    meal_slot:  Optional[str]  = Query(None),
    limit:      int            = Query(100, le=500),
    current_user: dict = Depends(require_role("platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Platform admin — view audit log for any household's plan generation.
    Filter by house_id, week_start, feature_code, day, slot.
    """
    filters = ["1=1"]
    params  = {}

    if house_id:
        filters.append("house_id = CAST(:hid AS uuid)")
        params["hid"] = house_id
    if week_start:
        filters.append("week_start = :ws")
        params["ws"] = date.fromisoformat(week_start)
    if feature_code:
        filters.append("feature_code = :fc")
        params["fc"] = feature_code
    if day_name:
        filters.append("day_name = :day")
        params["day"] = day_name
    if meal_slot:
        filters.append("meal_slot = :slot")
        params["slot"] = meal_slot

    params["limit"] = limit

    rows = db.execute(text(f"""
        SELECT
            log_id, house_id, week_start, day_name, meal_slot,
            feature_code, function_name,
            recipes_in, recipes_out, filtered_count,
            filter_reason, filtered_ids, selected_id,
            execution_ms, created_at
        FROM plan_audit_log
        WHERE {" AND ".join(filters)}
        ORDER BY created_at DESC, day_name, meal_slot, feature_code
        LIMIT :limit
    """), params).fetchall()

    return {
        "total": len(rows),
        "logs": [
            {
                "log_id":         str(r.log_id),
                "house_id":       str(r.house_id),
                "week_start":     str(r.week_start),
                "day_name":       r.day_name,
                "meal_slot":      r.meal_slot,
                "feature_code":   r.feature_code,
                "function_name":  r.function_name,
                "recipes_in":     r.recipes_in,
                "recipes_out":    r.recipes_out,
                "filtered_count": r.filtered_count,
                "filter_reason":  r.filter_reason,
                "filtered_ids":   [str(i) for i in (r.filtered_ids or [])],
                "selected_id":    str(r.selected_id) if r.selected_id else None,
                "execution_ms":   r.execution_ms,
                "created_at":     str(r.created_at),
            }
            for r in rows
        ]
    }


# ── DELETE /recommendation/audit-log/purge ───────────────────────────────────

@router.delete("/audit-log/purge", status_code=200)
async def purge_audit_log(
    older_than_months: int = Query(6, ge=1, le=24),
    current_user: dict = Depends(require_role("platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Purge audit log entries older than N months.
    Default = 6 months. Platform admin only.
    """
    cutoff = date.today() - timedelta(days=older_than_months * 30)

    result = db.execute(text("""
        DELETE FROM plan_audit_log
        WHERE created_at < :cutoff
    """), {"cutoff": cutoff})
    db.commit()

    return {
        "message": f"Purged audit log entries older than {older_than_months} months.",
        "deleted": result.rowcount,
        "cutoff":  str(cutoff),
    }
