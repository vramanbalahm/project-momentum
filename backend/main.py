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
import os
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "http://localhost:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
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
        SELECT hero_image_url, carousel_thumb_url, prep_steps, ingredients_json, video_url
        FROM recipe_content_vault 
        WHERE recipe_id = :r_id
    """)
    result = db.execute(query, {"r_id": recipe_id}).fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="Recipe content not found")
    return {"hero": result[0], "thumb": result[1], "steps": result[2], "ingredients_json": result[3], "video_url": result[4]}

# --- 5. SESSION CONSTANTS (fetched once on load) ---
@app.get("/session-constants/{household_id}")
async def session_constants(household_id: str, db: Session = Depends(get_db)):
    """
    Single call on app load — returns oldest_plan_week, dietary_preference, member_count.
    Frontend caches these for the session — no repeated DB hits per navigation.
    """
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    return get_session_constants(db, h_id)

# --- 5b. AUTH ROUTER ---
from routers.auth import router as auth_router
app.include_router(auth_router)

# --- 6. WEEKLY PLAN ROUTER (FT-030) ---
from routers.weekly_plan import router as weekly_plan_router
app.include_router(weekly_plan_router)

# --- 6b. FT-043: MEAL SWAP & STANDALONE AUDIT ---
from services.swap_service import execute_swap, audit_slot

@app.post("/meal/swap")
def swap_meals(payload: dict, db: Session = Depends(get_db)):
    """
    Generic meal slot swap. Works for within-day and cross-day.
    Day swap: caller loops over meal types, sends one request per type.
    payload: { source: {day, type, date}, target: {day, type, date} }
    """
    return execute_swap(
        db=db,
        h_id=ACTIVE_H_ID,
        source=payload["source"],
        target=payload["target"]
    )

@app.post("/meal/audit-slot")
def audit_meal_slot(payload: dict, db: Session = Depends(get_db)):
    """
    Standalone slot audit — callable anytime, anywhere.
    payload: { date: YYYY-MM-DD, meal_slot: Breakfast|Lunch|Dinner }
    """
    return audit_slot(
        db=db,
        h_id=ACTIVE_H_ID,
        event_date=payload["date"],
        meal_slot=payload["meal_slot"]
    )

# --- 7. FT-040: RECIPE SEARCH ---
@app.get("/recipes/search")
def search_recipes(q: str = "", db: Session = Depends(get_db)):
    """
    Fuzzy search on recipe_dna_master using pg_trgm trigram similarity.
    Handles misspellings, partial words, and phonetically close inputs.
    Empty query returns all recipes ordered by name.
    """
    if not q:
        query = text("""
            SELECT
                r.recipe_id, r.dish_name, r.diet_type, r.is_sattvic,
                r.intensity_level, v.carousel_thumb_url, v.hero_image_url,
                v.prep_steps, v.ingredients_json
            FROM recipe_dna_master r
            LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
            ORDER BY r.dish_name
            LIMIT 30
        """)
        rows = db.execute(query).fetchall()
    else:
        query = text("""
            SELECT
                r.recipe_id, r.dish_name, r.diet_type, r.is_sattvic,
                r.intensity_level, v.carousel_thumb_url, v.hero_image_url,
                v.prep_steps, v.ingredients_json,
                similarity(LOWER(r.dish_name), LOWER(:q)) AS sim_score
            FROM recipe_dna_master r
            LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
            WHERE
                similarity(LOWER(r.dish_name), LOWER(:q)) > 0.1
                OR LOWER(r.dish_name) LIKE LOWER(:pattern)
            ORDER BY sim_score DESC, r.dish_name
            LIMIT 30
        """)
        rows = db.execute(query, {"q": q, "pattern": f"%{q}%"}).fetchall()
    return [
        {
            "recipe_id": str(row[0]),
            "name": row[1],
            "diet_type": row[2],
            "is_sattvic": row[3],
            "intensity_level": row[4],
            "thumb": row[5],
            "hero": row[6],
            "prep_steps": row[7],
            "ingredients_json": row[8]
        }
        for row in rows
    ]

# --- 8. FT-041: MEAL SLOT EDIT ---
@app.post("/meal-slot/edit")
def edit_meal_slot(payload: dict, db: Session = Depends(get_db)):
    """
    Replace a dish in a meal slot and log to behavioral_tracker.
    payload: {
        event_id, house_id, event_date, meal_slot,
        dish_type (Main/Side), dish_sequence,
        original_recipe_id, new_recipe_id,
        swap_reason, swap_reason_text,
        week_start_date
    }
    """
    h_id = ACTIVE_H_ID if payload.get("house_id") == "HOUSEHOLD_001" else payload.get("house_id", ACTIVE_H_ID)

    # 1. Update meal_event_detail — replace the recipe for this dish
    db.execute(text("""
        UPDATE meal_event_detail
        SET recipe_id = CAST(:new_recipe_id AS uuid),
            action_taken = 'Changed'
        WHERE event_id = CAST(:event_id AS uuid)
          AND dish_sequence = :dish_sequence
    """), {
        "new_recipe_id": payload["new_recipe_id"],
        "event_id": payload["event_id"],
        "dish_sequence": payload["dish_sequence"]
    })

    # 2. Log to behavioral_tracker
    db.execute(text("""
        INSERT INTO behavioral_tracker
            (house_id, week_start_date, event_date, meal_slot,
             original_recipe_id, new_recipe_id,
             swap_reason, swap_reason_text, dish_type)
        VALUES
            (CAST(:h_id AS uuid), CAST(:week_start AS date), CAST(:event_date AS date),
             CAST(:meal_slot AS meal_slot_type),
             CAST(:orig AS uuid), CAST(:new AS uuid),
             :reason, :reason_text, :dish_type)
    """), {
        "h_id": h_id,
        "week_start": payload["week_start_date"],
        "event_date": payload["event_date"],
        "meal_slot": payload["meal_slot"],
        "orig": payload.get("original_recipe_id"),
        "new": payload["new_recipe_id"],
        "reason": payload.get("swap_reason", "Other"),
        "reason_text": payload.get("swap_reason_text", ""),
        "dish_type": payload.get("dish_type", "Main")
    })

    db.commit()
    return {"status": "success"}

# --- 9. FT-033: ADD SIDE DISH TO SLOT ---
@app.post("/meal-slot/add-side")
def add_side_dish(payload: dict, db: Session = Depends(get_db)):
    """
    Add a new side dish to an existing meal slot.
    payload: { event_id, recipe_id }
    """
    # Get current max dish_sequence for this event
    result = db.execute(text("""
        SELECT COALESCE(MAX(dish_sequence), 1)
        FROM meal_event_detail
        WHERE event_id = CAST(:event_id AS uuid)
    """), {"event_id": payload["event_id"]}).scalar()

    next_seq = result + 1

    db.execute(text("""
        INSERT INTO meal_event_detail
            (event_id, recipe_id, action_taken, dish_type, dish_sequence)
        VALUES
            (CAST(:event_id AS uuid), CAST(:recipe_id AS uuid), 'Accepted', 'Side', :seq)
    """), {
        "event_id": payload["event_id"],
        "recipe_id": payload["recipe_id"],
        "seq": next_seq
    })

    db.commit()
    return {"status": "success", "dish_sequence": next_seq}

# --- 10. FT-033: DELETE SIDE DISH FROM SLOT ---
@app.delete("/meal-slot/remove-side")
def remove_side_dish(event_id: str, dish_sequence: int, db: Session = Depends(get_db)):
    """Remove a side dish by event_id + dish_sequence."""
    db.execute(text("""
        DELETE FROM meal_event_detail
        WHERE event_id = CAST(:event_id AS uuid)
          AND dish_sequence = :seq
          AND dish_type = 'Side'
    """), {"event_id": event_id, "seq": dish_sequence})
    db.commit()
    return {"status": "success"}
