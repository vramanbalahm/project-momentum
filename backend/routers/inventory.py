# FT-010 to FT-013 — Inventory & fridge
# Functions: manage_fridge_inventory, check_fridge_against_plan,
#            record_purchase, track_inventory_usage
from fastapi import APIRouter
router = APIRouter(prefix="/inventory", tags=["inventory"])
