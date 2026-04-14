# FT-001 to FT-006 — Profile & household setup
# Functions: setup_household_profile, manage_household_members,
#            define_complexity_levels, setup_daily_meal_pattern,
#            setup_satvik_profile, manage_pattern_model
from fastapi import APIRouter
router = APIRouter(prefix="/profile", tags=["profile"])
