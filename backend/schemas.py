from pydantic import BaseModel
from typing import List, Optional

# --- 1. AUDIT REQUEST SCHEMA ---
# Used when the frontend asks the backend to validate the current grid
class AuditItem(BaseModel):
    day: str
    type: str
    to_meal: str
    date: str

# --- 2. DISH SCHEMA (FT-033: Multi-dish per slot) ---
# Represents a single dish — main or side
class DishItem(BaseModel):
    recipe_id: str
    dish_type: str = "Main"     # Main or Side
    dish_sequence: int = 1      # Order within slot

# --- 3. PLAN PERSISTENCE SCHEMA (FT-033: Updated for multi-dish) ---
# One SaveSlotItem per meal slot — contains main dish + list of sides
class SaveSlotItem(BaseModel):
    date: str
    type: str                               # Breakfast / Lunch / Dinner
    main: Optional[DishItem] = None         # First main dish (backward compat)
    mains: Optional[List[DishItem]] = []    # All main dishes (multi-main support)
    sides: Optional[List[DishItem]] = []    # Side dishes
    status: Optional[str] = "Success"
    message: Optional[str] = ""

class SavePlanRequest(BaseModel):
    household_id: str
    plan: List[SaveSlotItem]

# --- 4. LEGACY SCHEMA (kept for backward compatibility — do not remove) ---
# Used by existing /save-plan calls that send flat meal list
class SaveItem(BaseModel):
    day: str
    type: str
    meal_name: str
    recipe_id: str
    date: str
    status: Optional[str] = "Success"
    message: Optional[str] = ""

# --- 5. HOUSEHOLD / PREFERENCE SCHEMAS ---
class PreferenceUpdate(BaseModel):
    household_id: str
    dietary_preference: str
