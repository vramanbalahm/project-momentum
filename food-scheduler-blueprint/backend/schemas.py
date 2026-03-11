from pydantic import BaseModel
from typing import List, Optional

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