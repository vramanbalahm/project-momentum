from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
import uuid

# FT-033: Updated imports — plan_service now lives in services/
from services.plan_service import (
    fetch_active_plan,
    get_suggestions,
    execute_audit,
    persist_plan,
    get_dietary_pref,
    get_session_constants
)
from services.audit_service import check_pantry_availability, check_momentum_divergence
from database import SessionLocal, engine
from schemas import AuditItem, SavePlanRequest

from fastapi.middleware.cors import CORSMiddleware

# app = FastAPI()
app = FastAPI(title="Momentum Food Scheduler — MVP")

# Allow frontend origin to talk to backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Testing constant — ACTIVE_H_ID used until auth is built (FT-001)
# # ACTIVE_H_ID = "550e8400-e29b-41d4-a716-446655440000"
ACTIVE_H_ID = "733b3f63-0fb4-4170-877c-eb2a70f29ccb"

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 1. CORE SUGGESTIONS & PREFERENCES ---

@app.get("/generate-suggestions/{household_id}")
async def generate_suggestions(household_id: str, db: Session = Depends(get_db)):
    # If the frontend sends "HOUSEHOLD_001", we swap it for the real ACTIVE_H_ID
    clean_h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    """Standardized to use price_logs while keeping yesterday's mapping."""
    pref = get_dietary_pref(db, clean_h_id)
    # Passed h_id to ensure inventory bonus (+50) and price penalty (-80) work
    return get_suggestions(db, pref, clean_h_id)

# --- 2. AUDIT & INVENTORY ---

@app.post("/audit")
async def run_audit(changes: List[AuditItem], db: Session = Depends(get_db)):
    """Yesterday's logic: Calculates impact of inventory changes."""
    return execute_audit(db, ACTIVE_H_ID, changes)

@app.post("/inventory/update")
def set_inventory(h_id: str, s_id: str, status: str, db: Session = Depends(get_db)):
    """Standardized to use the new staple_id (Varchar)."""
    # update_inventory_status kept as stub — FT-010 will implement fully
    return {"message": "Inventory updated successfully"}

# --- 3. PLAN PERSISTENCE (FT-033: Multi-dish) ---

@app.post("/save-plan")
async def save_plan(request: SavePlanRequest, db: Session = Depends(get_db)):
    try:
        # FT-033: persist_plan now handles main + sides per slot
        return persist_plan(db, ACTIVE_H_ID, request.plan)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/get-plan/{household_id}")
async def get_plan(household_id: str, week_start: Optional[str] = None, db: Session = Depends(get_db)):
    """FT-033: Returns grouped plan — main + sides per slot.
    week_start (YYYY-MM-DD): if provided, returns plan for that specific week only.
    If omitted, returns current week records.
    """
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    plan = fetch_active_plan(db, h_id, week_start=week_start)
    return plan

# --- 4. MARKET SIGNALS & CONTENT VAULT ---

@app.get("/market/signals")
def get_market_signals(db: Session = Depends(get_db)):
    """Wave 5 Divergence monitor — FT-054."""
    query = text("""
        SELECT item_name, recorded_price, momentum_status 
        FROM market_signal_dashboard
        WHERE recorded_at >= CURRENT_DATE - INTERVAL '1 day'
    """)
    results = db.execute(query).fetchall()
    return [
        {
            "item": r[0],
            "price": float(r[1]),
            "status": r[2],
            "alert": (r[2] == 'DIVERGENCE')
        } for r in results
    ]

@app.get("/recipe/{recipe_id}/vault")
def get_recipe_details(recipe_id: str, db: Session = Depends(get_db)):
    """Content vault — hero_image and prep_steps."""
    query = text("""
        SELECT hero_image_url, carousel_thumb_url, prep_steps 
        FROM recipe_content_vault 
        WHERE recipe_id = :r_id
    """)
    result = db.execute(query, {"r_id": recipe_id}).fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="Recipe content not found")
    return {"hero": result[0], "thumb": result[1], "steps": result[2]}

# --- 5. SESSION CONSTANTS (fetched once on load) ---
@app.get("/session-constants/{household_id}")
async def session_constants(household_id: str, db: Session = Depends(get_db)):
    """
    Single call on app load — returns oldest_plan_week, dietary_preference, member_count.
    Frontend caches these for the session — no repeated DB hits per navigation.
    """
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    return get_session_constants(db, h_id)

# --- 6. WEEKLY PLAN ROUTER (FT-030) ---
from routers.weekly_plan import router as weekly_plan_router
app.include_router(weekly_plan_router)
