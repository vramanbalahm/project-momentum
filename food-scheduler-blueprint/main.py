from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import audit_engine

app = FastAPI()

# 1. ALLOW React to talk to Python (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2. Updated Data Model (Matches React runReview function)
class ChangeItem(BaseModel):
    day: str
    type: str
    to_meal: str
    from_meal: Optional[str] = None # Made optional to prevent 422 errors

# 3. The Bridge Endpoint
@app.post("/audit")
async def run_audit(changes: List[ChangeItem]):
    # Simulation of Recipe_Content_Vault
    recipe_vault = {
        "Dal Tadka": ["Dal", "Onion", "Ghee"],
        "Paneer Butter Masala": ["Paneer", "Tomato", "Cream"],
        "Tomato Kootu": ["Tomato", "Moong Dal", "Coconut"],
        "Spinach Pasta": ["Spinach", "Pasta", "Garlic"],
        "Vegetable Khichdi": ["Rice", "Moong Dal", "Carrots"]
    }

    # Simulation of Current Pantry Inventory
    pantry_inventory = ["Dal", "Onion", "Ghee", "Tomato", "Moong Dal", "Rice", "Carrots"]

    results = []
    
    for change in changes:
        target_meal = change.to_meal
        
        # Default Logic for "Skipped" meals
        if target_meal == "Skipped" or not target_meal:
            is_available = True
            message = "No ingredients required."
        else:
            required = recipe_vault.get(target_meal, [])
            # Find which specific items are missing
            missing = [item for item in required if item not in pantry_inventory]
            
            is_available = len(missing) == 0
            
            if is_available:
                message = "All ingredients in stock!"
            else:
                message = f"Missing: {', '.join(missing)}"

        # FEATURE: Add Lunar/Event logic overrides here
        if change.day == "Fri" and "Paneer" in target_meal:
            is_available = False
            message = "Lunar Alert: Avoid Paneer on Fasting Days."

        results.append({
            "day": change.day,
            "type": change.type,
            "isAvailable": is_available,
            "message": message # This feeds your React Tooltip
        })
    
    return results

# 4. Save Plan Endpoint (Placeholder for next story)
@app.post("/save-plan")
async def save_plan(plan: dict):
    # Logic to write back to Recipe_Content_Vault table goes here
    print("Saving plan to database...")
    return {"status": "success"}