# FT-020 to FT-025 — Event management
# Functions: create_user_event, toggle_event_status,
#            populate_lunar_calendar, get_week_events,
#            copy_events_to_new_year, get_event_calendar
from fastapi import APIRouter
router = APIRouter(prefix="/events", tags=["events"])
