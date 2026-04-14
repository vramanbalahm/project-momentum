from pydantic import BaseModel
from typing import List, Optional

# --- 1. AUDIT REQUEST SCHEMA ---
# Used when the frontend asks the backend to validate the current grid
class AuditItem(BaseModel):
    day: str
    type: str
    to_meal: str
    date: str

# --- 2. PLAN PERSISTENCE SCHEMA ---
# Used for the "Save Plan" functionality
class SaveItem(BaseModel):
    day: str
    type: str
    meal_name: str
    recipe_id: str  # Matches the DB column name
    date: str
    # Added for Sprint 3: Allows saving the 'Momentum' highlights to history
    status: Optional[str] = "Success"
    message: Optional[str] = ""

class SavePlanRequest(BaseModel):
    household_id: str
    plan: List[SaveItem]

# --- 3. HOUSEHOLD / PREFERENCE SCHEMAS ---
class PreferenceUpdate(BaseModel):
    household_id: str
    dietary_preference: str