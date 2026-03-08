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

# --- 1. AUDIT ENDPOINT ---
@app.post("/audit")
async def run_audit(changes: List[AuditItem], db: Session = Depends(get_db)):
    results = []
    
    # Fetch all items currently "In-Stock"
    pantry_rows = db.execute(text("SELECT staple_id FROM household_inventory WHERE stock_status = 'In-Stock'")).fetchall()
    pantry_stock = [row[0] for row in pantry_rows]

    for item in changes:
        query = text("""
            SELECT rd.is_sattvic, em.is_sattvic_required, rd.primary_staple_id
            FROM recipe_dna_master rd
            LEFT JOIN event_master em ON em.event_date = :e_date
            WHERE rd.dish_name = :d_name
        """)
        
        row = db.execute(query, {"e_date": item.date, "d_name": item.to_meal}).fetchone()
        is_valid = True
        msg = f"{item.to_meal} verified."

        if row:
            is_sattvic_recipe, is_sattvic_req, primary_staple = row
            
            if is_sattvic_req and not is_sattvic_recipe:
                is_valid, msg = False, "Sattvic Conflict."
            
            mock_vault = [{'name': item.to_meal, 'ingredients': {primary_staple: True}}]
            pantry_ok = check_pantry_availability(item.to_meal, pantry_stock, mock_vault)
            
            if not pantry_ok:
                is_valid, msg = False, f"Missing Staple: {primary_staple}"
        else:
            if item.to_meal == "Skipped":
                msg = "Meal skipped."
            else:
                msg = "Not in DNA Master."

        results.append({
            "day": item.day, 
            "type": item.type, 
            "isAvailable": is_valid, 
            "message": msg
        })
    return results

# --- 2. SAVE & LOCK ENDPOINT ---
@app.post("/save-plan")
async def save_plan(request: SavePlanRequest, db: Session = Depends(get_db)):
    try:
        # Validate UUID format for household_id
        try:
            uuid.UUID(request.household_id)
        except ValueError:
            raise HTTPException(status_code=400, detail=f"'{request.household_id}' is not a valid UUID format.")

        for item in request.plan:
            # 1. Check for existing header
            header = db.execute(text("""
                SELECT event_id FROM meal_event_header 
                WHERE event_date = :e_date 
                AND house_id = CAST(:h_id AS uuid) 
                AND CAST(meal_slot AS text) = :slot
            """), {
                "e_date": item.date, 
                "h_id": request.household_id, 
                "slot": item.type
            }).fetchone()

            if not header:
                # 2. CREATE the header if missing
                e_id = str(uuid.uuid4())
                db.execute(text("""
                    INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date, base_count, guest_count)
                    VALUES (CAST(:e_id AS uuid), CAST(:h_id AS uuid), :slot, :e_date, 1, 0)
                """), {
                    "e_id": e_id,
                    "h_id": request.household_id,
                    "slot": item.type,
                    "e_date": item.date
                })
            else:
                e_id = str(header[0])

            # 3. Get the recipe_id
            recipe = db.execute(text("""
                SELECT recipe_id FROM recipe_dna_master WHERE dish_name = :d_name
            """), {"d_name": item.meal_name}).fetchone()
            
            r_id = str(recipe[0]) if recipe else None

            # 4. Cleanup old details and Insert new one according to DDL
            db.execute(text("""
                DELETE FROM meal_event_detail 
                WHERE event_id = CAST(:e_id AS uuid)
            """), {"e_id": e_id})

            if item.meal_name != "Skipped" and r_id:
                # Generating detail_id UUID as required by your schema
                db.execute(text("""
                    INSERT INTO meal_event_detail (detail_id, event_id, recipe_id)
                    VALUES (CAST(:d_id AS uuid), CAST(:e_id AS uuid), CAST(:r_id AS uuid))
                """), {
                    "d_id": str(uuid.uuid4()),
                    "e_id": e_id,
                    "r_id": r_id
                })
        
        db.commit()
        return {"status": "success", "message": "Records synchronized."}
    except Exception as e:
        db.rollback()
        print(f"Detailed Save Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))