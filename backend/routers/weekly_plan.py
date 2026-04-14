# FT-030 to FT-037 — Weekly planning
# Functions: generate_weekly_plan_rule_based, process_weekly_questionnaire,
#            save_and_lock_plan, manage_meal_slot_dishes,
#            clone_previous_week, get_previous_week_plan,
#            run_plan_audit, send_planning_reminder
from fastapi import APIRouter
router = APIRouter(prefix="/weekly-plan", tags=["weekly_plan"])
