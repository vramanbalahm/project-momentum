# routers/onboarding.py
# Onboarding wizard endpoints — also used post-onboarding for editing
# All endpoints require authentication — admin only for household-level data
#
# Endpoints:
#   GET  /onboarding/data              — pre-fill data for wizard
#   POST /onboarding/members           — save member preferences + restrictions
#   POST /onboarding/satvik            — save household Satvik restrictions
#   POST /onboarding/events            — save household events (wraps event_master)
#   POST /onboarding/panchangam        — save household Panchangam type
#   POST /onboarding/confirm           — mark onboarding complete
#   GET  /onboarding/satvik-ingredients — ingredient catalog for Satvik selection

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from typing import List, Optional
from database import SessionLocal
from auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/onboarding", tags=["Onboarding"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ── GET /onboarding/data ──────────────────────────────────────────────────────
# Returns everything the wizard needs to pre-fill all steps

@router.get("/data")
async def get_onboarding_data(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns pre-fill data for all wizard steps:
    - members with their existing preferences and restrictions
    - existing Satvik restrictions for the household
    - existing events for the household
    - Panchangam types lookup
    - household current Panchangam type
    - wizard step completion status
    """
    house_id = current_user["house_id"]

    # ── Members with preferences and restrictions ──────────────────────────────
    members_raw = db.execute(text("""
        SELECT
            u.user_id, u.name, u.email, u.role,
            mp.dietary_preference,
            mp.id as pref_id
        FROM users u
        LEFT JOIN member_preferences mp ON mp.user_id = u.user_id
        WHERE u.house_id = CAST(:hid AS uuid)
          AND u.is_active = true
        ORDER BY u.created_at ASC
    """), {"hid": house_id}).fetchall()

    members = []
    for m in members_raw:
        # Get restrictions for this member
        restrictions = db.execute(text("""
            SELECT
                mr.id, mr.restriction_type,
                ic.id as ingredient_id, ic.name_en, ic.name_ta, ic.category
            FROM member_restrictions mr
            JOIN ingredient_catalog ic ON ic.id = mr.ingredient_id
            WHERE mr.user_id = CAST(:uid AS uuid)
            ORDER BY mr.restriction_type, ic.name_en
        """), {"uid": str(m.user_id)}).fetchall()

        members.append({
            "user_id":            str(m.user_id),
            "name":               m.name,
            "email":              m.email,
            "role":               str(m.role),
            "dietary_preference": str(m.dietary_preference) if m.dietary_preference else None,
            "restrictions": [{
                "id":               r.id,
                "ingredient_id":    r.ingredient_id,
                "name_en":          r.name_en,
                "name_ta":          r.name_ta,
                "category":         r.category,
                "restriction_type": r.restriction_type,
            } for r in restrictions]
        })

    # ── Household Satvik restrictions ──────────────────────────────────────────
    satvik_raw = db.execute(text("""
        SELECT
            sr.id, sr.is_avoided,
            ic.id as ingredient_id, ic.name_en, ic.name_ta, ic.category
        FROM satvik_restrictions sr
        JOIN ingredient_catalog ic ON ic.id = sr.ingredient_id
        WHERE sr.house_id = CAST(:hid AS uuid)
        ORDER BY ic.category, ic.name_en
    """), {"hid": house_id}).fetchall()

    satvik = [{
        "id":            r.id,
        "ingredient_id": r.ingredient_id,
        "name_en":       r.name_en,
        "name_ta":       r.name_ta,
        "category":      r.category,
        "is_avoided":    r.is_avoided,
    } for r in satvik_raw]

    # ── Household events ───────────────────────────────────────────────────────
    events_raw = db.execute(text("""
        SELECT
            event_id, event_name, event_date, event_type,
            is_sattvic_required, recurring_annual,
            dietary_context, local_name, icon, source
        FROM event_master
        WHERE house_id = CAST(:hid AS uuid)
          AND is_active = true
        ORDER BY event_date ASC
    """), {"hid": house_id}).fetchall()

    events = [{
        "event_id":           str(e.event_id),
        "event_name":         e.event_name,
        "event_date":         e.event_date.isoformat() if e.event_date else None,
        "event_type":         e.event_type,
        "is_sattvic_required": e.is_sattvic_required,
        "recurring_annual":   e.recurring_annual,
        "dietary_context":    str(e.dietary_context) if e.dietary_context else None,
        "local_name":         e.local_name,
        "icon":               e.icon,
        "source":             e.source,
    } for e in events_raw]

    # ── Panchangam types lookup ────────────────────────────────────────────────
    panchangam_types = db.execute(text("""
        SELECT id, code, display_name, language, region
        FROM panchangam_types
        WHERE is_active = true
        ORDER BY sort_order
    """)).fetchall()

    # ── Household wizard status ────────────────────────────────────────────────
    hh = db.execute(text("""
        SELECT
            onboarding_done,
            wizard_members_done,
            wizard_satvik_done,
            wizard_events_done,
            panchangam_type_id,
            dietary_preference,
            household_allergies
        FROM household_master
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()

    # Resolve panchangam display name if set
    panchangam_selected = None
    if hh and hh.panchangam_type_id:
        pt = db.execute(text("""
            SELECT id, code, display_name FROM panchangam_types WHERE id = :id
        """), {"id": hh.panchangam_type_id}).fetchone()
        if pt:
            panchangam_selected = {
                "id": pt.id, "code": pt.code, "display_name": pt.display_name
            }

    return {
        "members":          members,
        "satvik":           satvik,
        "events":           events,
        "panchangam_types": [{"id": p.id, "code": p.code, "display_name": p.display_name,
                               "language": p.language, "region": p.region}
                              for p in panchangam_types],
        "panchangam_selected": panchangam_selected,
        "wizard_status": {
            "onboarding_done":    hh.onboarding_done if hh else False,
            "members_done":       hh.wizard_members_done if hh else False,
            "satvik_done":        hh.wizard_satvik_done if hh else False,
            "events_done":        hh.wizard_events_done if hh else False,
        },
        "household": {
            "dietary_preference": str(hh.dietary_preference) if hh and hh.dietary_preference else "Veg",
            "household_allergies": hh.household_allergies if hh else None,
        }
    }


# ── GET /onboarding/satvik-ingredients ────────────────────────────────────────
# Returns ingredient catalog grouped by category for Satvik selection screen

@router.get("/satvik-ingredients")
async def get_satvik_ingredients(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns all ingredients from ingredient_catalog grouped by category.
    Used to populate the Satvik selection toggles.
    """
    rows = db.execute(text("""
        SELECT id, name_en, name_ta, category, is_sattvic, is_vegan
        FROM ingredient_catalog
        WHERE name_en IS NOT NULL
        ORDER BY category, name_en
    """)).fetchall()

    # Group by category
    grouped = {}
    for r in rows:
        cat = r.category or "Other"
        if cat not in grouped:
            grouped[cat] = []
        grouped[cat].append({
            "id":         r.id,
            "name_en":    r.name_en,
            "name_ta":    r.name_ta,
            "category":   r.category,
            "is_sattvic": r.is_sattvic,
            "is_vegan":   r.is_vegan,
        })

    return grouped


# ── POST /onboarding/members ──────────────────────────────────────────────────

class RestrictionItem(BaseModel):
    ingredient_id:    int
    restriction_type: str  # Allergy | Dislike

class MemberPrefItem(BaseModel):
    user_id:            str
    dietary_preference: str
    restrictions:       List[RestrictionItem] = []

class SaveMembersRequest(BaseModel):
    members: List[MemberPrefItem]

@router.post("/members", status_code=200)
async def save_member_preferences(
    req: SaveMembersRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Saves dietary preferences and restrictions for each member.
    Upserts member_preferences and replaces member_restrictions for each member.
    Also marks wizard_members_done = true on household_master.
    Used during onboarding wizard AND post-onboarding from Manage Members screen.
    """
    house_id = current_user["house_id"]
    admin_id = current_user["user_id"]

    valid_prefs = {"Veg", "Non-Veg", "Vegan", "Eggitarian"}
    valid_restrictions = {"Allergy", "Dislike"}

    for m in req.members:
        if m.dietary_preference not in valid_prefs:
            raise HTTPException(status_code=422,
                detail=f"Invalid dietary_preference '{m.dietary_preference}' for user {m.user_id}")

        for r in m.restrictions:
            if r.restriction_type not in valid_restrictions:
                raise HTTPException(status_code=422,
                    detail=f"Invalid restriction_type '{r.restriction_type}'")

        # Verify member belongs to this household
        check = db.execute(text("""
            SELECT user_id FROM users
            WHERE user_id = CAST(:uid AS uuid)
              AND house_id = CAST(:hid AS uuid)
        """), {"uid": m.user_id, "hid": house_id}).fetchone()

        if not check:
            raise HTTPException(status_code=404,
                detail=f"User {m.user_id} not found in this household")

        # Upsert member_preferences
        db.execute(text("""
            INSERT INTO member_preferences (user_id, house_id, dietary_preference, updated_by)
            VALUES (CAST(:uid AS uuid), CAST(:hid AS uuid), CAST(:pref AS diet_pref), CAST(:admin AS uuid))
            ON CONFLICT (user_id) DO UPDATE
            SET dietary_preference = CAST(:pref AS diet_pref),
                updated_at = NOW(),
                updated_by = CAST(:admin AS uuid)
        """), {"uid": m.user_id, "hid": house_id,
               "pref": m.dietary_preference, "admin": admin_id})

        # Replace restrictions — delete existing, insert new
        db.execute(text("""
            DELETE FROM member_restrictions
            WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": m.user_id})

        for r in m.restrictions:
            db.execute(text("""
                INSERT INTO member_restrictions
                    (user_id, house_id, ingredient_id, restriction_type, updated_by)
                VALUES (CAST(:uid AS uuid), CAST(:hid AS uuid), :iid, :rtype, CAST(:admin AS uuid))
                ON CONFLICT (user_id, ingredient_id, restriction_type) DO NOTHING
            """), {"uid": m.user_id, "hid": house_id,
                   "iid": r.ingredient_id, "rtype": r.restriction_type,
                   "admin": admin_id})

    # Mark members step done
    db.execute(text("""
        UPDATE household_master
        SET wizard_members_done = true
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id})

    db.commit()
    return {"message": "Member preferences saved.", "members_updated": len(req.members)}


# ── POST /onboarding/satvik ───────────────────────────────────────────────────

class SatvikIngredientItem(BaseModel):
    ingredient_id: int
    is_avoided:    bool = True

class SaveSatvikRequest(BaseModel):
    restrictions: List[SatvikIngredientItem]

@router.post("/satvik", status_code=200)
async def save_satvik_restrictions(
    req: SaveSatvikRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Saves the household Satvik ingredient restrictions.
    Replaces all existing satvik_restrictions for this household.
    Also marks wizard_satvik_done = true.
    Used during onboarding AND post-onboarding from Family Profile screen.
    """
    house_id = current_user["house_id"]
    admin_id = current_user["user_id"]

    # Replace all existing Satvik restrictions for this household
    db.execute(text("""
        DELETE FROM satvik_restrictions WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id})

    for item in req.restrictions:
        db.execute(text("""
            INSERT INTO satvik_restrictions
                (house_id, ingredient_id, is_avoided, updated_by)
            VALUES (CAST(:hid AS uuid), :iid, :avoided, CAST(:admin AS uuid))
            ON CONFLICT (house_id, ingredient_id) DO UPDATE
            SET is_avoided = :avoided, updated_by = CAST(:admin AS uuid)
        """), {"hid": house_id, "iid": item.ingredient_id,
               "avoided": item.is_avoided, "admin": admin_id})

    # Mark Satvik step done
    db.execute(text("""
        UPDATE household_master
        SET wizard_satvik_done = true
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id})

    db.commit()
    return {"message": "Satvik restrictions saved.", "items_saved": len(req.restrictions)}


# ── POST /onboarding/panchangam ───────────────────────────────────────────────

class SavePanchangamRequest(BaseModel):
    panchangam_type_id: Optional[int] = None  # None = clears the selection

@router.post("/panchangam", status_code=200)
async def save_panchangam(
    req: SavePanchangamRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Saves the household's Panchangam type selection.
    Used during onboarding AND post-onboarding from Family Profile screen.
    """
    house_id = current_user["house_id"]

    if req.panchangam_type_id is not None:
        # Validate panchangam_type_id exists
        check = db.execute(text("""
            SELECT id FROM panchangam_types WHERE id = :id AND is_active = true
        """), {"id": req.panchangam_type_id}).fetchone()
        if not check:
            raise HTTPException(status_code=404,
                detail=f"Panchangam type {req.panchangam_type_id} not found")

    db.execute(text("""
        UPDATE household_master
        SET panchangam_type_id = :ptid
        WHERE household_id = CAST(:hid AS uuid)
    """), {"ptid": req.panchangam_type_id, "hid": house_id})

    db.commit()
    return {"message": "Panchangam preference saved."}


# ── POST /onboarding/events ───────────────────────────────────────────────────

class EventItem(BaseModel):
    event_name:          str
    event_date:          str   # MM-DD format (recurring) or YYYY-MM-DD (one-time)
    event_type:          str   # Personal | Social | Ritual
    is_sattvic_required: bool = False
    recurring_annual:    bool = True
    local_name:          Optional[str] = None
    icon:                Optional[str] = None

class SaveEventsRequest(BaseModel):
    events: List[EventItem]

@router.post("/events", status_code=200)
async def save_events(
    req: SaveEventsRequest,
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Saves user-defined household events into event_master.
    source = 'USER', event_type = Personal | Social | Ritual.
    Also marks wizard_events_done = true.
    Used during onboarding AND post-onboarding from Events screen.
    """
    house_id = current_user["house_id"]

    valid_types = {"Personal", "Social", "Ritual"}

    saved = 0
    for e in req.events:
        if e.event_type not in valid_types:
            raise HTTPException(status_code=422,
                detail=f"Invalid event_type '{e.event_type}'. Must be Personal, Social or Ritual.")

        # Parse date — support both MM-DD and YYYY-MM-DD
        try:
            from datetime import date
            if len(e.event_date) == 5:  # MM-DD
                month, day = e.event_date.split("-")
                event_date = date(date.today().year, int(month), int(day))
            else:
                event_date = date.fromisoformat(e.event_date)
        except ValueError:
            raise HTTPException(status_code=422,
                detail=f"Invalid event_date '{e.event_date}'. Use MM-DD or YYYY-MM-DD format.")

        db.execute(text("""
            INSERT INTO event_master
                (house_id, event_name, event_date, event_type,
                 is_sattvic_required, recurring_annual,
                 local_name, icon, source, is_active)
            VALUES
                (CAST(:hid AS uuid), :name, :date, :etype,
                 :sattvic, :recurring,
                 :local_name, :icon, 'USER', true)
        """), {
            "hid":        house_id,
            "name":       e.event_name,
            "date":       event_date,
            "etype":      e.event_type,
            "sattvic":    e.is_sattvic_required,
            "recurring":  e.recurring_annual,
            "local_name": e.local_name,
            "icon":       e.icon,
        })
        saved += 1

    # Mark events step done
    db.execute(text("""
        UPDATE household_master
        SET wizard_events_done = true
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id})

    db.commit()
    return {"message": "Events saved.", "events_saved": saved}


# ── POST /onboarding/confirm ──────────────────────────────────────────────────

@router.post("/confirm", status_code=200)
async def confirm_onboarding(
    current_user: dict = Depends(require_role("household_admin", "platform_admin")),
    db: Session = Depends(get_db)
):
    """
    Marks onboarding as complete — unlocks Weekly Planner.
    Sets onboarding_done = true on household_master.
    Safe to call multiple times — idempotent.
    Also used if user confirms with defaults (skips all steps).
    """
    house_id = current_user["house_id"]

    db.execute(text("""
        UPDATE household_master
        SET onboarding_done = true
        WHERE household_id = CAST(:hid AS uuid)
    """), {"hid": house_id})

    db.commit()
    return {"message": "Onboarding confirmed. Weekly Planner is now unlocked."}
