from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
import uuid

# Existing imports from yesterday
import services
import audit_engine
from database import SessionLocal, engine
from schemas import AuditItem, SavePlanRequest # Assuming these are in your schemas.py

from fastapi.middleware.cors import CORSMiddleware

# app = FastAPI()
app = FastAPI(title="Food Scheduling App - Standardized Baseline")

# Allow your frontend origin to talk to your backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Yesterday's established constant - UPDATED VALUE TO MATCH DATABASE CONTENT
# # ACTIVE_H_ID = "550e8400-e29b-41d4-a716-446655440000" 
ACTIVE_H_ID = "733b3f63-0fb4-4170-877c-eb2a70f29ccb"

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 1. CORE SUGGESTIONS & PREFERENCES (Yesterday's Logic) ---

@app.get("/generate-suggestions/{household_id}")
async def generate_suggestions(household_id: str, db: Session = Depends(get_db)):
    # If the frontend sends "HOUSEHOLD_001", we swap it for the real ACTIVE_H_ID
    clean_h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id

    """Standardized today to use price_logs while keeping yesterday's mapping."""
    
    pref = services.get_dietary_pref(db, clean_h_id)
    # Passed h_id to ensure inventory bonus (+50) and price penalty (-80) work
    return services.get_suggestions(db, pref, clean_h_id)

# --- 2. AUDIT & INVENTORY (Yesterday's Logic) ---

@app.post("/audit")
async def run_audit(changes: List[AuditItem], db: Session = Depends(get_db)):
    """Yesterday's logic: Calculates impact of inventory changes."""
    return services.execute_audit(db, ACTIVE_H_ID, changes)

@app.post("/inventory/update")
def set_inventory(h_id: str, s_id: str, status: str, db: Session = Depends(get_db)):
    """Standardized today to use the new staple_id (Varchar)."""
    services.update_inventory_status(db, h_id, s_id, status)
    return {"message": "Inventory updated successfully"}

# --- 3. PLAN PERSISTENCE (Yesterday's Fixes) ---

@app.post("/save-plan")
async def save_plan(request: SavePlanRequest, db: Session = Depends(get_db)):
    try:
        # Pass the validated ACTIVE_H_ID and the plan list
        return services.persist_plan(db, ACTIVE_H_ID, request.plan)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@app.get("/get-plan/{household_id}")
async def get_plan(household_id: str, db: Session = Depends(get_db)):
    """Fetches the modularized plan from yesterday's schema."""
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    plan = services.fetch_active_plan(db, h_id)
    return plan

# --- 4. MARKET SIGNALS & CONTENT VAULT (Today's Standardized Logic) ---

@app.get("/market/signals")
def get_market_signals(db: Session = Depends(get_db)):
    """The new Wave 5 'Divergence' monitor."""
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
    """The content vault link for hero_image and prep_steps."""
    query = text("""
        SELECT hero_image, carousel_thumb, prep_steps 
        FROM recipe_content_vault 
        WHERE recipe_id = :r_id
    """)
    result = db.execute(query, {"r_id": recipe_id}).fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="Recipe content not found")
    return {"hero": result[0], "thumb": result[1], "steps": result[2]}