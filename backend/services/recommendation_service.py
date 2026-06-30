# services/recommendation_service.py
# Recommendation Engine — Bucket A (Rule-based)
#
# All table/column names verified against actual schema files.
#
# Tables used (verified):
#   users                  — user_id, house_id, name, is_active
#   member_preferences     — user_id, dietary_preference
#   member_restrictions    — user_id, ingredient_id, restriction_type ('Allergy','Dislike')
#   satvik_restrictions    — house_id, ingredient_id, is_avoided
#   meal_attendance_log    — meal_date, meal_slot, absent_member_ids (uuid[])
#   event_master           — house_id, event_date, is_sattvic_required, is_active
#   recipe_dna_master      — recipe_id, dish_name, diet_type, intensity_level,
#                            is_sattvic, meal_slots (text[]), review_status
#   recipe_ingredients     — recipe_id, ingredient_id
#   meal_event_header      — event_id, house_id, meal_slot, event_date
#   meal_event_detail      — detail_id, event_id, recipe_id
#   household_plan_config  — house_id, no_repeat_weeks
#   plan_audit_log         — audit log per formula per slot
#   feature_registry       — feature_code, function_name, is_active

import time
import random
import uuid
from datetime import date, timedelta
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import SessionLocal

DAYS_OF_WEEK = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

DIET_ORDER = {"Vegan": 4, "Veg": 3, "Eggitarian": 2, "Non-Veg": 1}
DIET_COMPATIBLE = {
    "Vegan":      ["Vegan"],
    "Veg":        ["Veg", "Vegan"],
    "Eggitarian": ["Veg", "Vegan", "Eggitarian"],
    "Non-Veg":    ["Veg", "Vegan", "Eggitarian", "Non-Veg"],
}
SLOT_INTENSITY = {
    "Breakfast": ["Light"],
    "Lunch":     ["Medium", "Heavy"],
    "Dinner":    ["Light", "Medium"],  # Tamil Nadu dinner is often lighter — idli/dosa/chapati at night
}

# Pipeline sequence — owned here, not in DB
MAIN_PIPELINE = [
    "filter_by_availability",
    "filter_by_allergies",
    "calc_effective_diet",
    "filter_by_diet",
    "check_satvik_day",
    "filter_satvik_ingredients",
    "filter_by_meal_slot",
    "filter_recent_recipes",
]
SLOT_PIPELINE = {
    "Breakfast": ["apply_breakfast_model"],
    "Lunch":     ["apply_lunch_model"],
    "Dinner":    ["apply_dinner_model"],
}


# ── 5 upfront DB queries ──────────────────────────────────────────────────────

def load_week_context(db: Session, house_id: str, week_start: date, no_repeat_weeks: int = 1) -> Dict:
    """Load all data needed for the full week in 5 targeted queries."""

    week_end = week_start + timedelta(days=7)

    # Query 1 — Approved recipe vault
    vault_rows = db.execute(text("""
        SELECT
            r.recipe_id,
            r.dish_name,
            r.diet_type,
            r.intensity_level,
            r.is_sattvic,
            r.meal_slots,
            r.meal_role,
            r.dish_category,
            COALESCE(v.carousel_thumb_url, v.hero_image_url) as thumb,
            COALESCE(
                ARRAY(
                    SELECT ri.ingredient_id
                    FROM recipe_ingredients ri
                    WHERE ri.recipe_id = r.recipe_id
                ), '{}'::integer[]
            ) AS ingredient_ids
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        WHERE r.review_status = 'approved'
        AND r.meal_role @> ARRAY['main']::text[]
    """)).fetchall()

    approved_recipes = [
        {
            "recipe_id":       str(r.recipe_id),
            "dish_name":       r.dish_name,
            "diet_type":       str(r.diet_type) if r.diet_type else "Veg",
            "intensity_level": r.intensity_level or "Medium",
            "is_sattvic":      r.is_sattvic or False,
            "meal_slots":      list(r.meal_slots) if r.meal_slots else [],
            "meal_role":       list(r.meal_role) if r.meal_role else ["main"],
            "dish_category":   r.dish_category or "other",
            "thumb":           r.thumb or None,
            "ingredient_ids":  list(r.ingredient_ids) if r.ingredient_ids else [],
        }
        for r in vault_rows
    ]

    # Query 2 — Members + diet + allergens
    member_rows = db.execute(text("""
        SELECT
            u.user_id,
            u.name,
            COALESCE(mp.dietary_preference, 'Veg') AS dietary_preference,
            COALESCE(
                ARRAY(
                    SELECT mr.ingredient_id
                    FROM member_restrictions mr
                    WHERE mr.user_id = u.user_id
                    AND mr.restriction_type = 'Allergy'
                ), '{}'::integer[]
            ) AS allergen_ids
        FROM users u
        LEFT JOIN member_preferences mp ON mp.user_id = u.user_id
        WHERE u.house_id = CAST(:hid AS uuid)
        AND u.is_active = true
    """), {"hid": house_id}).fetchall()

    members = {
        str(r.user_id): {
            "name":               r.name,
            "dietary_preference": str(r.dietary_preference) if r.dietary_preference else "Veg",
            "allergen_ids":       list(r.allergen_ids) if r.allergen_ids else [],
        }
        for r in member_rows
    }
    all_member_ids = list(members.keys())

    # Query 3 — Attendance: absent_member_ids per day+slot
    # meal_attendance_log stores who is ABSENT, not who is present
    avail_rows = db.execute(text("""
        SELECT meal_date, meal_slot, absent_member_ids
        FROM meal_attendance_log
        WHERE meal_date >= :ws
        AND meal_date < :we
    """), {"ws": week_start, "we": week_end}).fetchall()

    # Build present map: {day_name: {slot: [present_user_ids]}}
    availability = {}
    for r in avail_rows:
        day_idx = (r.meal_date - week_start).days
        if 0 <= day_idx < 7:
            day = DAYS_OF_WEEK[day_idx]
            absent = [str(uid) for uid in (r.absent_member_ids or [])]
            present = [uid for uid in all_member_ids if uid not in absent]
            if day not in availability:
                availability[day] = {}
            availability[day][r.meal_slot] = present

    # Query 4 — Satvik days + household satvik restrictions
    satvik_rows = db.execute(text("""
        SELECT event_date
        FROM event_master
        WHERE house_id = CAST(:hid AS uuid)
        AND event_date >= :ws
        AND event_date < :we
        AND is_sattvic_required = true
        AND is_active = true
    """), {"hid": house_id, "ws": week_start, "we": week_end}).fetchall()

    satvik_days = {
        DAYS_OF_WEEK[(r.event_date - week_start).days]
        for r in satvik_rows
        if 0 <= (r.event_date - week_start).days < 7
    }

    satvik_restr_rows = db.execute(text("""
        SELECT ingredient_id
        FROM satvik_restrictions
        WHERE house_id = CAST(:hid AS uuid)
        AND is_avoided = true
    """), {"hid": house_id}).fetchall()

    satvik_avoided_ids = {r.ingredient_id for r in satvik_restr_rows}

    # Query 5a — Weekly generation config (questionnaire answers)
    wc_row = db.execute(text("""
        SELECT continental_days, allow_same_day_repeat,
               allow_same_week_repeat, prefer_millet
        FROM weekly_generation_config
        WHERE house_id = CAST(:hid AS uuid)
        AND week_start = :ws
    """), {"hid": house_id, "ws": week_start}).fetchone()

    weekly_config = {
        "continental_days":       wc_row.continental_days      if wc_row else 0,
        "allow_same_day_repeat":  wc_row.allow_same_day_repeat  if wc_row else False,
        "allow_same_week_repeat": wc_row.allow_same_week_repeat if wc_row else True,
        "prefer_millet":          wc_row.prefer_millet          if wc_row else False,
    }

    # Query 5 — Recent recipes (past N weeks) to avoid repetition
    cutoff = week_start - timedelta(weeks=no_repeat_weeks)
    recent_rows = db.execute(text("""
        SELECT DISTINCT d.recipe_id, h.meal_slot
        FROM meal_event_header h
        JOIN meal_event_detail d ON d.event_id = h.event_id
        WHERE h.house_id = CAST(:hid AS uuid)
        AND h.event_date >= :cutoff
        AND h.event_date < :ws
    """), {"hid": house_id, "cutoff": cutoff, "ws": week_start}).fetchall()

    recent_by_slot: Dict[str, set] = {}
    for r in recent_rows:
        recent_by_slot.setdefault(r.meal_slot, set()).add(str(r.recipe_id))

    return {
        "approved_recipes":   approved_recipes,
        "members":            members,
        "all_member_ids":     all_member_ids,
        "availability":       availability,
        "satvik_days":        satvik_days,
        "satvik_avoided_ids": satvik_avoided_ids,
        "recent_by_slot":     recent_by_slot,
        "no_repeat_weeks":    no_repeat_weeks,
        "weekly_config":      weekly_config,
        "last_effective_diet": "Veg",   # updated by F02 per slot
        "sides_used_this_week": set(),  # updated by F16 per slot
        "allergen_ids":        set(),   # updated by FA01
        "lunch_intensity":     {},      # updated by apply_lunch_post per day
        "lunch_sides":         {},      # updated by apply_lunch_post per day
        "house_id":            house_id,  # for dinner model leftover boost
    }


def get_active_formulas(db: Session) -> Dict[str, bool]:
    """Load which Bucket A formulas are active from feature_registry."""
    rows = db.execute(text("""
        SELECT function_name, is_active
        FROM feature_registry
        WHERE feature_code LIKE 'RA-%'
    """)).fetchall()
    return {r.function_name: r.is_active for r in rows}


# ── Audit logger ──────────────────────────────────────────────────────────────

def _log(
    db: Session, house_id: str, week_start: date,
    day_name: str, meal_slot: str,
    feature_code: str, function_name: str,
    recipes_in: int, recipes_out: int,
    filtered_ids: List[str], filter_reason: str,
    selected_id: Optional[str] = None,
    execution_ms: int = 0,
    run_id: Optional[str] = None
):
    """
    Writes to plan_audit_log using an ISOLATED session — never shares the
    caller's transaction. This guarantees a logging failure can never
    roll back or poison the main plan-generation transaction.
    """
    log_db = SessionLocal()
    try:
        fids = "{" + ",".join(str(i) for i in filtered_ids) + "}" if filtered_ids else "{}"
        log_db.execute(text("""
            INSERT INTO plan_audit_log
                (run_id, house_id, week_start, day_name, meal_slot,
                 feature_code, function_name,
                 recipes_in, recipes_out, filtered_count,
                 filter_reason, filtered_ids, selected_id, execution_ms)
            VALUES
                (CAST(:rid AS uuid), CAST(:hid AS uuid), :ws, :day, :slot,
                 :fc, :fn, :rin, :rout, :fcnt,
                 :reason,
                 CAST(:fids AS uuid[]),
                 CAST(:sel AS uuid),
                 :ms)
            ON CONFLICT DO NOTHING
        """), {
            "rid":    run_id or str(uuid.uuid4()),
            "hid":    house_id, "ws": week_start, "day": day_name, "slot": meal_slot,
            "fc":     feature_code, "fn": function_name,
            "rin":    recipes_in, "rout": recipes_out, "fcnt": recipes_in - recipes_out,
            "reason": filter_reason, "fids": fids,
            "sel":    str(selected_id) if selected_id else None,
            "ms":     execution_ms,
        })
        log_db.commit()
    except Exception as e:
        print(f"[audit_log] FAILED for {feature_code}/{function_name} house={house_id} day={day_name} slot={meal_slot}: {type(e).__name__}: {e}")
        try:
            log_db.rollback()
        except Exception as rollback_err:
            print(f"[audit_log] rollback also failed: {rollback_err}")
    finally:
        log_db.close()


# ── Formula functions (pure in-memory) ───────────────────────────────────────

def filter_by_availability(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    avail = week_ctx["availability"]
    all_ids = week_ctx["all_member_ids"]

    present_ids = avail.get(day, {}).get(slot, None)
    if present_ids is None:
        present_ids = all_ids
        reason = f"No attendance data — all {len(all_ids)} members assumed present"
    else:
        reason = f"{len(present_ids)} of {len(all_ids)} members present"

    ctx["present_ids"] = present_ids
    _log(db, house_id, week_start, day, slot, "RA-F03", "filter_by_availability",
         len(recipes), len(recipes), [], reason, None, int((time.time()-t0)*1000), run_id=run_id)
    return recipes, ctx


def filter_by_allergies(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    present_ids = ctx.get("present_ids", [])
    members = week_ctx["members"]

    allergen_ids = set()
    desc = []
    for uid in present_ids:
        m = members.get(uid, {})
        ids = m.get("allergen_ids", [])
        if ids:
            allergen_ids.update(ids)
            desc.append(f"{m.get('name','?')}:{len(ids)}")

    if not allergen_ids:
        _log(db, house_id, week_start, day, slot, "RA-FA01", "filter_by_allergies",
             len(recipes), len(recipes), [], "No allergens for present members", None, 0, run_id=run_id)
        return recipes, ctx

    filtered = [r for r in recipes if not (set(r.get("ingredient_ids", [])) & allergen_ids)]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]
    _log(db, house_id, week_start, day, slot, "RA-FA01", "filter_by_allergies",
         len(recipes), len(filtered), removed, f"Allergens: {', '.join(desc)}",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return filtered, ctx


def calc_effective_diet(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    present_ids = ctx.get("present_ids", [])
    members = week_ctx["members"]
    diets = [str(members[uid]["dietary_preference"]) for uid in present_ids if uid in members]
    effective = max(diets, key=lambda d: DIET_ORDER.get(d, 0)) if diets else "Veg"
    ctx["effective_diet"] = effective
    week_ctx["last_effective_diet"] = effective  # store for F16
    # Store allergen IDs for F16
    week_ctx["allergen_ids"] = week_ctx.get("allergen_ids", set()) | ctx.get("allergen_ids", set())
    _log(db, house_id, week_start, day, slot, "RA-F02", "calc_effective_diet",
         len(recipes), len(recipes), [], f"Effective diet: {effective}",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return recipes, ctx


def filter_by_diet(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    effective = ctx.get("effective_diet", "Veg")
    allowed   = DIET_COMPATIBLE.get(effective, ["Veg"])
    filtered  = [r for r in recipes if r.get("diet_type") in allowed]
    removed   = [r["recipe_id"] for r in recipes if r not in filtered]
    _log(db, house_id, week_start, day, slot, "RA-F01", "filter_by_diet",
         len(recipes), len(filtered), removed, f"Diet: {effective} — allowed: {allowed}",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return filtered, ctx


def check_satvik_day(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    is_satvik = day in week_ctx["satvik_days"]
    ctx["is_satvik_day"] = is_satvik
    _log(db, house_id, week_start, day, slot, "RA-FA02", "check_satvik_day",
         len(recipes), len(recipes), [],
         "Satvik day ✓" if is_satvik else "Not a Satvik day",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return recipes, ctx


def filter_satvik_ingredients(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    if not ctx.get("is_satvik_day", False):
        _log(db, house_id, week_start, day, slot, "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Not Satvik day — skipped", None, 0, run_id=run_id)
        return recipes, ctx

    avoided = week_ctx["satvik_avoided_ids"]
    if not avoided:
        _log(db, house_id, week_start, day, slot, "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Satvik day — no restrictions defined", None, 0, run_id=run_id)
        return recipes, ctx

    filtered = [r for r in recipes if not (set(r.get("ingredient_ids", [])) & avoided)]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]
    _log(db, house_id, week_start, day, slot, "RA-F08", "filter_satvik_ingredients",
         len(recipes), len(filtered), removed,
         f"Satvik: {len(removed)} recipes removed", None, int((time.time()-t0)*1000), run_id=run_id)
    return filtered, ctx


def filter_by_meal_slot(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    allowed_intensities = SLOT_INTENSITY.get(slot, ["Medium"])
    filtered = [
        r for r in recipes
        if slot in r.get("meal_slots", [])
        and r.get("intensity_level", "Medium") in allowed_intensities
    ]
    removed = [r["recipe_id"] for r in recipes if r not in filtered]
    _log(db, house_id, week_start, day, slot, "RA-F04", "filter_by_meal_slot",
         len(recipes), len(filtered), removed,
         f"{slot}: intensity={allowed_intensities}, {len(filtered)} pass",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return filtered, ctx


def filter_recent_recipes(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    t0 = time.time()
    recent = week_ctx["recent_by_slot"].get(slot, set())

    # Also exclude dishes already selected THIS week (cross-slot within week)
    this_week_all = set()
    for slot_set in week_ctx.get("selected_this_week", {}).values():
        this_week_all.update(slot_set)
    recent = recent | this_week_all

    if not recent:
        _log(db, house_id, week_start, day, slot, "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [],
             f"No recent recipes in past {week_ctx['no_repeat_weeks']} week(s)", None, 0, run_id=run_id)
        return recipes, ctx

    filtered = [r for r in recipes if r["recipe_id"] not in recent]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]

    if not filtered:
        _log(db, house_id, week_start, day, slot, "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [], "Pool empty — no-repeat constraint relaxed", None, 0, run_id=run_id)
        return recipes, ctx

    _log(db, house_id, week_start, day, slot, "RA-F05", "filter_recent_recipes",
         len(recipes), len(filtered), removed,
         f"No-repeat: {len(removed)} excluded (past {week_ctx['no_repeat_weeks']} wk)",
         None, int((time.time()-t0)*1000), run_id=run_id)
    return filtered, ctx


def apply_breakfast_model(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    if slot != "Breakfast": return recipes, ctx
    _log(db, house_id, week_start, day, slot, "RA-F13", "apply_breakfast_model",
         len(recipes), len(recipes), [], f"Breakfast pool: {len(recipes)}", None, 0, run_id=run_id)
    return recipes, ctx


def apply_lunch_model(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    if slot != "Lunch": return recipes, ctx
    _log(db, house_id, week_start, day, slot, "RA-F14", "apply_lunch_model",
         len(recipes), len(recipes), [], f"Lunch pool: {len(recipes)}", None, 0, run_id=run_id)
    return recipes, ctx


def apply_lunch_post(selected_main: Dict, sides: list, day: str, week_ctx: Dict):
    """Called after lunch is selected — stores intensity and sides for dinner model."""
    if not selected_main:
        return
    intensity = selected_main.get("intensity_level", "Medium")
    # Store lunch intensity per day for dinner model
    if "lunch_intensity" not in week_ctx:
        week_ctx["lunch_intensity"] = {}
    week_ctx["lunch_intensity"][day] = intensity
    # Store lunch side recipe IDs for leftover boost in dinner
    if "lunch_sides" not in week_ctx:
        week_ctx["lunch_sides"] = {}
    week_ctx["lunch_sides"][day] = [s["recipe_id"] for s in sides]


def apply_dinner_model(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    if slot != "Dinner": return recipes, ctx
    t0 = time.time()
    original_count = len(recipes)

    # Rule 1: If lunch was Heavy/Medium → enforce Light dinner
    lunch_intensity = week_ctx.get("lunch_intensity", {}).get(day, "Medium")
    if lunch_intensity in ("Heavy", "Medium"):
        light_recipes = [r for r in recipes if r.get("intensity_level") == "Light"]
        if light_recipes:
            recipes = light_recipes
            reason = f"Lunch was {lunch_intensity} → dinner restricted to Light ({len(recipes)} recipes)"
        else:
            reason = f"Lunch was {lunch_intensity} but no Light dinner recipes found — keeping full pool"
    else:
        reason = f"Lunch was Light — dinner pool unrestricted"

    # Rule 2: Boost mains that pair with today's lunch sides (leftover linking)
    lunch_side_ids = week_ctx.get("lunch_sides", {}).get(day, [])
    boosted = []
    normal  = []
    if lunch_side_ids:
        # Find mains that have high-confidence pairings with today's lunch sides
        boosted_ids = set()
        try:
            from sqlalchemy import text as sqla_text
            rows = db.execute(sqla_text("""
                SELECT DISTINCT main_recipe_id
                FROM recipe_pairing
                WHERE side_recipe_id = ANY(:side_ids)
                AND confidence >= 0.85
                AND (house_id IS NULL OR house_id = CAST(:house_id AS uuid))
            """), {
                "side_ids": [str(s) for s in lunch_side_ids],
                "house_id": str(week_ctx.get("house_id", ""))
            }).fetchall()
            boosted_ids = {str(r.main_recipe_id) for r in rows}
        except Exception:
            pass

        if boosted_ids:
            boosted = [r for r in recipes if r.get("recipe_id") in boosted_ids]
            normal  = [r for r in recipes if r.get("recipe_id") not in boosted_ids]
            # Put boosted mains at front of pool
            recipes = boosted + normal
            reason += f" | Leftover boost: {len(boosted)} mains match lunch sides"

    ms = int((time.time()-t0)*1000)
    _log(db, house_id, week_start, day, slot, "RA-F15", "apply_dinner_model",
         original_count, len(recipes), [], reason, None, ms, run_id=run_id)
    return recipes, ctx


def recommend_sides(
    db: Session, house_id: str, week_start: date,
    day: str, slot: str,
    selected_main: Dict,
    week_ctx: Dict,
    run_id: Optional[str] = None
) -> List[Dict]:
    """
    F16 — Side dish recommendation using recipe_pairing table.
    Pipeline:
    1. Query recipe_pairing for this main — household-specific first, then global seeds
    2. Filter by: diet, Satvik, meal slot, allergens, no-repeat (week)
    3. Reject sides previously rejected by this household (behavioral_tracker)
    4. Pick up to 2 sides — different dish_category, no ingredient overlap
    Falls back to matrix-based selection if no pairings found.
    """
    t0 = time.time()

    main_recipe_id  = selected_main.get("recipe_id")
    main_category   = selected_main.get("dish_category", "other")
    effective_diet  = week_ctx.get("last_effective_diet", "Veg")
    is_satvik       = day in week_ctx.get("satvik_days", set())
    satvik_avoided  = week_ctx.get("satvik_avoided_ids", set())
    allowed_diets   = DIET_COMPATIBLE.get(effective_diet, ["Veg"])
    allergen_ids    = week_ctx.get("allergen_ids", set())
    used_this_week  = week_ctx.get("sides_used_this_week", set())

    # ── Step 1: Query recipe_pairing table ────────────────────────────────────
    # Household-specific rows override global seeds (higher confidence wins)
    pairing_rows = db.execute(text("""
        SELECT
            rp.side_recipe_id,
            rp.confidence,
            rp.source,
            r.dish_name,
            r.diet_type,
            r.intensity_level,
            r.dish_category,
            r.meal_slots,
            r.is_sattvic,
            v.carousel_thumb_url as thumb,
            v.hero_image_url     as hero,
            COALESCE(
                ARRAY(SELECT ri.ingredient_id FROM recipe_ingredients ri
                      WHERE ri.recipe_id = r.recipe_id),
                '{}'::integer[]
            ) AS ingredient_ids
        FROM recipe_pairing rp
        JOIN recipe_dna_master r ON r.recipe_id = rp.side_recipe_id
        LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        WHERE rp.main_recipe_id = CAST(:main_id AS uuid)
        AND rp.source NOT IN ('user_rejected')
        AND (rp.house_id IS NULL OR rp.house_id = CAST(:house_id AS uuid))
        AND r.review_status = 'approved'
        AND r.diet_type::text = ANY(:diets)
        AND (r.meal_slots = '{}'::text[] OR r.meal_slots IS NULL OR r.meal_slots @> ARRAY[:slot]::text[])
        AND (
            -- Continental mains ONLY get continental-appropriate sides
            -- (condiment category with continental sub_region, or dry/wet that are continental)
            CASE WHEN :main_category = 'continental'
                THEN r.sub_region = 'Continental'
                ELSE TRUE
            END
        )
        ORDER BY
            CASE WHEN rp.house_id IS NOT NULL THEN 0 ELSE 1 END,
            CASE WHEN rp.source = 'ai_seeded'      THEN 1
                 WHEN rp.source = 'user_accepted'   THEN 2
                 WHEN rp.source = 'matrix_seeded'
                      AND rp.acceptance_count > 0   THEN 3
                 WHEN rp.source = 'matrix_seeded'   THEN 4
                 ELSE 5
            END,
            rp.confidence DESC,
            rp.acceptance_count DESC
    """), {
        "main_id":       str(main_recipe_id),
        "house_id":      str(house_id),
        "diets":         allowed_diets,
        "slot":          slot,
        "main_category": main_category,
    }).fetchall()

    sides = [
        {
            "recipe_id":       str(r.side_recipe_id),
            "dish_name":       r.dish_name,
            "diet_type":       str(r.diet_type) if r.diet_type else "Veg",
            "intensity_level": r.intensity_level or "Light",
            "dish_category":   r.dish_category,
            "meal_slots":      list(r.meal_slots) if r.meal_slots else [],
            "is_sattvic":      r.is_sattvic or False,
            "thumb":           r.thumb or r.hero,
            "hero":            r.hero or r.thumb,
            "ingredient_ids":  list(r.ingredient_ids) if r.ingredient_ids else [],
            "confidence":      float(r.confidence),
            "source":          r.source,
        }
        for r in pairing_rows
    ]

    # ── Step 2: Apply filters ─────────────────────────────────────────────────

    # Satvik filter
    if is_satvik and satvik_avoided:
        sides = [s for s in sides if not (set(s["ingredient_ids"]) & satvik_avoided)]

    # Allergen filter
    if allergen_ids:
        sides = [s for s in sides if not (set(s["ingredient_ids"]) & allergen_ids)]

    # No-repeat filter — exclude sides used this week
    sides = [s for s in sides if s["recipe_id"] not in used_this_week]

    # ── Step 3: Fall back to matrix if no pairings found ─────────────────────
    if not sides:
        matrix_rows = db.execute(text("""
            SELECT side_category, compatibility
            FROM dish_pairing_matrix
            WHERE main_category = :mc
            AND compatibility != 'never'
            ORDER BY CASE compatibility
                WHEN 'perfect'    THEN 1
                WHEN 'good'       THEN 2
                WHEN 'acceptable' THEN 3
                ELSE 4 END
        """), {"mc": main_category}).fetchall()

        if matrix_rows:
            compatible_cats = [r.side_category for r in matrix_rows]
            fb_rows = db.execute(text("""
                SELECT r.recipe_id, r.dish_name, r.diet_type,
                       r.intensity_level, r.dish_category, r.meal_slots,
                       r.is_sattvic,
                       v.carousel_thumb_url as thumb, v.hero_image_url as hero,
                       COALESCE(
                           ARRAY(SELECT ri.ingredient_id FROM recipe_ingredients ri
                                 WHERE ri.recipe_id = r.recipe_id),
                           '{}'::integer[]
                       ) AS ingredient_ids
                FROM recipe_dna_master r
                LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
                WHERE r.review_status = 'approved'
                AND r.meal_role @> ARRAY['side']::text[]
                AND r.dish_category = ANY(:cats)
                AND r.diet_type::text = ANY(:diets)
                AND r.meal_slots @> ARRAY[:slot]::text[]
            """), {"cats": compatible_cats, "diets": allowed_diets, "slot": slot}).fetchall()

            sides = [
                {
                    "recipe_id":       str(r.recipe_id),
                    "dish_name":       r.dish_name,
                    "diet_type":       str(r.diet_type) if r.diet_type else "Veg",
                    "intensity_level": r.intensity_level or "Light",
                    "dish_category":   r.dish_category,
                    "meal_slots":      list(r.meal_slots) if r.meal_slots else [],
                    "is_sattvic":      r.is_sattvic or False,
                    "thumb":           r.thumb or r.hero,
                    "hero":            r.hero or r.thumb,
                    "ingredient_ids":  list(r.ingredient_ids) if r.ingredient_ids else [],
                    "confidence":      0.65,
                    "source":          "matrix_fallback",
                }
                for r in fb_rows
            ]

            if is_satvik and satvik_avoided:
                sides = [s for s in sides if not (set(s["ingredient_ids"]) & satvik_avoided)]
            if allergen_ids:
                sides = [s for s in sides if not (set(s["ingredient_ids"]) & allergen_ids)]
            sides = [s for s in sides if s["recipe_id"] not in used_this_week]

    if not sides:
        _log(db, house_id, week_start, day, slot, "RA-F16", "pair_side_dishes",
             0, 0, [], f"No sides found for main={selected_main.get('dish_name')}",
             None, int((time.time()-t0)*1000), run_id=run_id)
        return []

    # ── Step 4: Pick up to 2 sides ────────────────────────────────────────────
    # Rule 1: max 1 per dish_category
    # Rule 2: no ingredient overlap between selected sides
    selected_sides  = []
    used_categories = set()
    used_ingredients = set()

    # Sort by confidence descending
    sides.sort(key=lambda x: -x["confidence"])

    for side in sides:
        if len(selected_sides) >= 2:
            break

        # Rule 1: skip if category already used
        if side["dish_category"] in used_categories:
            continue

        # Rule 2: skip if shares primary vegetable ingredient with already selected side
        side_veg_ings = {i for i in side["ingredient_ids"]} & used_ingredients
        if side_veg_ings and used_ingredients:
            continue

        selected_sides.append(side)
        used_categories.add(side["dish_category"])
        used_ingredients.update(side["ingredient_ids"])

        # Track used sides for no-repeat
        used_this_week.add(side["recipe_id"])

    # Update week context
    week_ctx["sides_used_this_week"] = used_this_week

    reason = (f"main={selected_main.get('dish_name')} → "
              f"sides={[s['dish_name'] for s in selected_sides]} "
              f"(pool={len(sides)}, source={selected_sides[0]['source'] if selected_sides else 'none'})")
    ms = int((time.time()-t0)*1000)
    _log(db, house_id, week_start, day, slot, "RA-F16", "pair_side_dishes",
         len(sides), len(selected_sides), [], reason,
         selected_sides[0]["recipe_id"] if selected_sides else None, ms, run_id=run_id)

    return selected_sides


# ── Formula map ───────────────────────────────────────────────────────────────

FORMULA_MAP = {
    "filter_by_availability":    filter_by_availability,
    "filter_by_allergies":       filter_by_allergies,
    "calc_effective_diet":       calc_effective_diet,
    "filter_by_diet":            filter_by_diet,
    "check_satvik_day":          check_satvik_day,
    "filter_satvik_ingredients": filter_satvik_ingredients,
    "filter_by_meal_slot":       filter_by_meal_slot,
    "filter_recent_recipes":     filter_recent_recipes,
    "apply_breakfast_model":     apply_breakfast_model,
    "apply_lunch_model":         apply_lunch_model,
    "apply_dinner_model":        apply_dinner_model,
}


# ── Main entry point ──────────────────────────────────────────────────────────

def generate_plan(db: Session, house_id: str, week_start: date, fill_empty_only: bool = False) -> Dict:
    """
    Generate recommendations for all 21 slots.
    5 DB queries upfront. Formula execution is pure in-memory.
    """
    # Get no_repeat config
    config = db.execute(text("""
        SELECT no_repeat_weeks FROM household_plan_config
        WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()
    no_repeat_weeks = config.no_repeat_weeks if config else 1

    # Load all data in 5 queries
    week_ctx = load_week_context(db, house_id, week_start, no_repeat_weeks)

    # Load active formulas
    active = get_active_formulas(db)

    # Get existing plan if fill_empty_only
    existing: Dict = {}
    if fill_empty_only:
        week_end = week_start + timedelta(days=7)
        rows = db.execute(text("""
            SELECT
                h.event_date,
                h.meal_slot,
                d.recipe_id,
                r.dish_name
            FROM meal_event_header h
            JOIN meal_event_detail d ON d.event_id = h.event_id
            JOIN recipe_dna_master r ON r.recipe_id = d.recipe_id
            WHERE h.house_id = CAST(:hid AS uuid)
            AND h.event_date >= :ws
            AND h.event_date < :we
        """), {"hid": house_id, "ws": week_start, "we": week_end}).fetchall()
        for r in rows:
            day_idx = (r.event_date - week_start).days
            if 0 <= day_idx < 7:
                day = DAYS_OF_WEEK[day_idx]
                existing.setdefault(day, {})[r.meal_slot] = {
                    "recipe_id": str(r.recipe_id),
                    "dish_name": r.dish_name,
                }

    result: Dict = {}
    # Generate a unique run_id for this entire plan generation
    run_id = str(uuid.uuid4())

    # Track selected recipe_ids per slot within this run
    # Controlled by weekly_config.allow_same_week_repeat
    weekly_config = week_ctx.get("weekly_config", {})
    allow_same_week_repeat = weekly_config.get("allow_same_week_repeat", True)
    prefer_millet          = weekly_config.get("prefer_millet", False)

    selected_this_week: Dict[str, set] = {
        "Breakfast": set(),
        "Lunch":     set(),
        "Dinner":    set(),
    }
    week_ctx["selected_this_week"] = selected_this_week  # share with F05

    for day in DAYS_OF_WEEK:
        result[day] = {}
        for slot in ["Breakfast", "Lunch", "Dinner"]:

            # Skip if already filled and fill_empty_only
            if fill_empty_only and existing.get(day, {}).get(slot):
                result[day][slot] = existing[day][slot]
                continue

            # Build pipeline for this slot
            pipeline = (
                [fn for fn in MAIN_PIPELINE if active.get(fn, True)]
                + [fn for fn in SLOT_PIPELINE.get(slot, []) if active.get(fn, True)]
            )

            # Run pipeline — pure in-memory
            candidates = list(week_ctx["approved_recipes"])
            ctx: Dict = {}

            for fn_name in pipeline:
                fn = FORMULA_MAP.get(fn_name)
                if not fn:
                    continue
                try:
                    candidates, ctx = fn(candidates, day, slot, ctx, week_ctx, db, house_id, week_start, run_id)
                except Exception as e:
                    print(f"[recommendation] {fn_name} failed: {e}")

            # Apply millet boost — move millet recipes to front if preferred
            if prefer_millet:
                millet_tags = {"millet", "ragi", "kambu", "thinai", "varagu", "kuthiraivali", "samai"}
                millet_recipes = [r for r in candidates if any(t in millet_tags for t in r.get("tags", []))]
                other_recipes  = [r for r in candidates if r not in millet_recipes]
                candidates = millet_recipes + other_recipes

            # Exclude recipes already selected this week for this slot
            if allow_same_week_repeat:
                fresh_candidates = candidates  # allow repeats
            else:
                fresh_candidates = [r for r in candidates if r["recipe_id"] not in selected_this_week[slot]]
                if not fresh_candidates:
                    fresh_candidates = candidates  # relax if pool is empty

            # Select one recipe randomly
            selected = None
            if fresh_candidates:
                selected = random.choice(fresh_candidates)
                selected_this_week[slot].add(selected["recipe_id"])
            elif candidates:
                selected = random.choice(candidates)

            if selected:
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     len(fresh_candidates or candidates), 1, [],
                     f"Selected: {selected['dish_name']} from {len(fresh_candidates or candidates)} candidates",
                     selected["recipe_id"], 0, run_id=run_id)

                # F16 — Recommend side dishes for this main
                sides = recommend_sides(
                    db, house_id, week_start, day, slot,
                    selected, week_ctx, run_id=run_id
                )

                # Store lunch result for dinner model (intensity + sides)
                if slot == "Lunch":
                    apply_lunch_post(selected, sides, day, week_ctx)

                result[day][slot] = {
                    "recipe_id": selected["recipe_id"],
                    "dish_name": selected["dish_name"],
                    "diet_type": selected["diet_type"],
                    "intensity": selected["intensity_level"],
                    "dish_category": selected.get("dish_category", "other"),
                    "thumb": selected.get("thumb"),
                    "hero":  selected.get("thumb"),
                    "sides": [
                        {
                            "recipe_id":     s["recipe_id"],
                            "dish_name":     s["dish_name"],
                            "name":          s["dish_name"],
                            "dish_category": s["dish_category"],
                            "thumb":         s.get("thumb"),
                            "hero":          s.get("hero"),
                        }
                        for s in sides
                    ],
                }
            else:
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     0, 0, [], "No candidates — slot left empty", None, 0, run_id=run_id)
                result[day][slot] = None

    db.commit()
    return result, run_id
