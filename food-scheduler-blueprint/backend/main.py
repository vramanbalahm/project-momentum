from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List

# Internal Imports
from database import get_db
from schemas import AuditItem, SavePlanRequest
import services

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Test ID Mapping (Kept for your local development)
ACTIVE_H_ID = "733b3f63-0fb4-4170-877c-eb2a70f29ccb"

@app.get("/generate-suggestions/{household_id}")
async def generate_suggestions(household_id: str, db: Session = Depends(get_db)):
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    pref = services.get_dietary_pref(db, h_id)
    return services.get_suggestions(db, pref)

@app.post("/audit")
async def run_audit(changes: List[AuditItem], db: Session = Depends(get_db)):
    # Logic moved to services.execute_audit
    return services.execute_audit(db, ACTIVE_H_ID, changes)

@app.post("/save-plan")
async def save_plan(request: SavePlanRequest, db: Session = Depends(get_db)):
    try:
        h_id = ACTIVE_H_ID if request.household_id == "HOUSEHOLD_001" else request.household_id
        services.persist_plan(db, h_id, request.plan)
        return {"status": "success", "message": "Plan locked and modularized."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/get-plan/{household_id}")
async def get_plan(household_id: str, db: Session = Depends(get_db)):
    h_id = ACTIVE_H_ID if household_id == "HOUSEHOLD_001" else household_id
    return services.fetch_plan(db, h_id)