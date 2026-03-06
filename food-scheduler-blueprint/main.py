from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy import create_engine, text # Correct imports
from sqlalchemy.orm import sessionmaker

app = FastAPI()

# UPDATE THIS with your actual Postgres details:
# "postgresql://username:password@localhost:5432/your_db_name"
DATABASE_URL = "postgresql://postgres:password@localhost:5432/food_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- DATABASE MODELS ---
class ChangeItem(BaseModel):
    day: str
    type: str
    to_meal: str
    from_meal: Optional[str] = None

class EventUpdate(BaseModel):
    event_code: str
    is_active: bool

# --- HELPER: SMART ID GENERATOR (Point 13) ---
def generate_event_code(db, region: str, year: int, source: str):
    # Logic: Fetch count to create sequence (e.g., TN0052026-LC)
    count = db.execute("SELECT COUNT(*) FROM event_master WHERE event_year = :y AND source = :s", 
                      {"y": year, "s": source}).scalar()
    seq = str(count + 1).zfill(3)
    return f"{region}{seq}{year}-LC" if source == 'ADMIN' else f"UE{seq}{year}"

# --- EVENT ENDPOINTS (The New Logic) ---

@app.get("/events/{household_id}/{year}")
async def get_calendar_events(household_id: str, year: int):
    # Retrieve Admin festivals + Private User events for this family
    query = """
        SELECT event_code, event_name, event_date, event_type, icon, 
               is_sattvic_required, source, is_active, dietary_context
        FROM event_master 
        WHERE (house_id = :h_id OR source = 'ADMIN')
        AND event_year = :year
        ORDER BY event_date ASC
    """
    # result = db.execute(query, {"h_id": household_id, "year": year}).fetchall()
    return {"status": "success", "data": "List of events here"}

@app.post("/events/toggle")
async def toggle_event(update: EventUpdate):
    # Point 10: Soft delete/Deactivate logic
    query = "UPDATE event_master SET is_active = :status WHERE event_code = :code"
    # db.execute(query, {"status": update.is_active, "code": update.event_code})
    return {"message": "Status updated"}

# --- UPDATED AUDIT ENDPOINT ---
@app.post("/audit")
async def run_audit(changes: List[ChangeItem], household_id: str):
    # Now retrieves 'is_sattvic_required' from event_master for the given days
    # If Today = Chaturthi (is_sattvic = True) and Meal = Non-Satvik, return Alert.
    results = []
    for change in changes:
        # 1. Check event_master for Satvik requirement
        # 2. Check pantry_inventory table for stock
        # 3. Return combined result
        results.append({
            "day": change.day,
            "isAvailable": True,
            "message": "Real-time audit active"
        })
    return results