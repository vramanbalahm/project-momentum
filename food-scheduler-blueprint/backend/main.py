import uuid
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from audit_engine import check_pantry_availability

# --- DATABASE SETUP ---
DATABASE_URL = "postgresql://postgres:admin123@localhost:5432/food_momentum_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MODELS ---
class AuditItem(BaseModel):
    day: str
    type: str
    to_meal: str
    date: str

class SaveItem(BaseModel):
    day: str
    type: str
    meal_name: str
    date: str

class SavePlanRequest(BaseModel):
    household_id: str
    plan: List[SaveItem]

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 1. STRATEGY-BASED SUGGESTIONS (Refined Point #2) ---
@app.get("/generate-suggestions/{household_id}")
async def generate_suggestions(household_id: str, db: Session = Depends(get_db)):
    """
    Logic: 
    1. Fetches exact ENUM label from household_master.
    2. Uses 'diet_type' column with exact casing ("Veg", "Vegan", etc.).
    3. Allows 'is_sattvic' to act as a universal filter if needed.
    """
    active_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if household_id == "HOUSEHOLD_001" else household_id
    
    # Fetch dietary preference
    profile_query = text("SELECT dietary_preference FROM household_master WHERE house_id = CAST(:h_id AS uuid)")
    profile_row = db.execute(profile_query, {"h_id": active_h_id}).fetchone()
    
    # Preference now matches your ENUM labels exactly
    preference = profile_row[0] if profile_row else "Veg"

    base_sql = "SELECT dish_name, is_sattvic, primary_staple_id, recipe_code FROM recipe_dna_master "
    
    # Strategy Mapping based on your ENUM labels
    if preference == "Vegan":
        filter_sql = "WHERE diet_type = 'Vegan'"
    elif preference == "Veg":
        # Includes Veg and Vegan entries
        filter_sql = "WHERE diet_type IN ('Veg', 'Vegan')"
    elif preference == "Eggitarian":
        # Includes Veg, Vegan, and Eggitarian
        filter_sql = "WHERE diet_type IN ('Veg', 'Vegan', 'Eggitarian')"
    else:
        # Non-Veg sees everything
        filter_sql = "WHERE 1=1"

    # Lead Dev Note: Since is_sattvic is a flag, we can add a toggle check here later
    # if global_sattvic_toggle: filter_sql += " AND is_sattvic = True"

    final_query = text(f"{base_sql} {filter_sql} ORDER BY RANDOM() LIMIT 20")
    rows = db.execute(final_query).fetchall()
    
    return [{"name": r[0], "is_sattvic": r[1], "staple": r[2], "code": r[3]} for r in rows]

# --- 2. AUDIT ENDPOINT (Refined Point #4 Tooltips) ---
@app.post("/audit")
async def run_audit(changes: List[AuditItem], db: Session = Depends(get_db)):
    results = []
    pantry_rows = db.execute(text("SELECT staple_id FROM household_inventory WHERE stock_status = 'In-Stock'")).fetchall()
    pantry_stock = [row[0] for row in pantry_rows]

    for item in changes:
        query = text("SELECT primary_staple_id, recipe_code FROM recipe_dna_master WHERE dish_name = :d_name")
        row = db.execute(query, {"d_name": item.to_meal}).fetchone()
        
        is_valid, msg = True, f"{item.to_meal} verified."
        if row and row[0]:
            if row[0] not in pantry_stock:
                # This message will appear on hover in the React UI
                is_valid, msg = False, f"Missing Staple: {row[0]}"
        elif item.to_meal == "Skipped":
            msg = "Meal skipped."
        else:
            msg = "Dish not found in DNA Master."

        results.append({"day": item.day, "type": item.type, "isAvailable": is_valid, "message": msg})
    return results

# --- 3. SAVE & LOCK ENDPOINT (Refined Point #1 Persistence) ---
@app.post("/save-plan")
async def save_plan(request: SavePlanRequest, db: Session = Depends(get_db)):
    try:
        active_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if request.household_id == "HOUSEHOLD_001" else request.household_id

        for item in request.plan:
            # A. Header Logic
            header = db.execute(text("""
                SELECT event_id FROM meal_event_header 
                WHERE event_date = :e_date AND house_id = CAST(:h_id AS uuid) 
                AND CAST(meal_slot AS text) = :slot
            """), {"e_date": item.date, "h_id": active_h_id, "slot": item.type}).fetchone()

            if not header:
                e_id = str(uuid.uuid4())
                db.execute(text("""
                    INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date)
                    VALUES (CAST(:e_id AS uuid), CAST(:h_id AS uuid), :slot, :e_date)
                """), {"e_id": e_id, "h_id": active_h_id, "slot": item.type, "e_date": item.date})
            else:
                e_id = str(header[0])

            # B. ID Lookup (Improved robustness with ILIKE)
            recipe = db.execute(text("""
                SELECT recipe_id FROM recipe_dna_master 
                WHERE TRIM(dish_name) ILIKE TRIM(:d_name)
            """), {"d_name": item.meal_name}).fetchone()
            
            # C. Clean & Insert Detail
            db.execute(text("DELETE FROM meal_event_detail WHERE event_id = CAST(:e_id AS uuid)"), {"e_id": e_id})

            if recipe:
                db.execute(text("""
                    INSERT INTO meal_event_detail (detail_id, event_id, recipe_id)
                    VALUES (CAST(:d_id AS uuid), CAST(:e_id AS uuid), CAST(:r_id AS uuid))
                """), {"d_id": str(uuid.uuid4()), "e_id": e_id, "r_id": str(recipe[0])})
        
        db.commit()
        return {"status": "success", "message": "Blueprint synchronized with DB."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# --- 4. FETCH PLAN ENDPOINT (Refined Point #3 Readable Codes) ---
@app.get("/get-plan/{household_id}")
async def get_plan(household_id: str, db: Session = Depends(get_db)):
    active_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if household_id == "HOUSEHOLD_001" else household_id
    query = text("""
        SELECT h.event_date, CAST(h.meal_slot AS text), r.dish_name, r.recipe_code
        FROM meal_event_header h
        JOIN meal_event_detail d ON h.event_id = d.event_id
        JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
        ORDER BY h.event_date ASC
    """)
    rows = db.execute(query, {"h_id": active_h_id}).fetchall()
    return {"plan": [{"date": str(r[0]), "type": r[1], "meal_name": r[2], "code": r[3]} for r in rows]}