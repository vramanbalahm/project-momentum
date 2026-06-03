# services/recommendation_service.py
# Recommendation Engine — Bucket A (Rule-based)
#
# Design principles:
#   1. Pipeline sequence defined here in code (not DB)
#   2. All data loaded upfront in 5 targeted queries
#   3. Formula execution is pure in-memory — no DB hits during filtering
#   4. Each formula independently toggleable via feature_registry.is_active
#   5. Every formula logs to plan_audit_log (Bucket C)
#
# Pipeline:
#   F03  → filter_by_availability
#   FA01 → filter_by_allergies
#   F02  → calc_effective_diet
#   F01  → filter_by_diet
#   FA02 → check_satvik_day
#   F08  → filter_satvik_ingredients
#   F04  → filter_by_meal_slot
#   F05  → filter_recent_recipes
#   F13/F14/F15 → meal model (slot-specific)
#   F16  → pair_side_dishes

import time
import random
from datetime import date, timedelta
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import text

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
    "Dinner":    ["Medium", "Heavy"],
}

# Pipeline sequence — owned by this service, not DB
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


# ── Step 1: Load all data upfront in 5 queries ────────────────────────────────

def load_week_context(db: Session, house_id: str, week_start: date, no_repeat_weeks: int = 1) -> Dict:
    """
    Load ALL data needed for the full week in 5 targeted queries.
    Formula execution reads from this context — zero DB hits during filtering.
    """

    # Query 1 — Approved recipe vault (all approved mains)
    vault_rows = db.execute(text("""
        SELECT
            r.recipe_id, r.dish_name, r.diet_type,
            r.intensity_level, r.is_sattvic,
            rv.meal_slots,
            COALESCE(
                ARRAY(
                    SELECT ri.ingredient_id
                    FROM recipe_ingredients ri
                    WHERE ri.recipe_id = r.recipe_id
                ), '{}'::integer[]
            ) as ingredient_ids
        FROM recipe_dna_master r
        JOIN recipe_review_master rv ON rv.recipe_id = r.recipe_id
        WHERE rv.review_status = 'approved'
        AND (rv.is_side_dish = false OR rv.is_side_dish IS NULL)
    """)).fetchall()

    approved_recipes = [
        {
            "recipe_id":       str(r.recipe_id),
            "dish_name":       r.dish_name,
            "diet_type":       str(r.diet_type) if r.diet_type else "Veg",
            "intensity_level": r.intensity_level or "Medium",
            "is_sattvic":      r.is_sattvic or False,
            "meal_slots":      list(r.meal_slots) if r.meal_slots else [],
            "ingredient_ids":  list(r.ingredient_ids) if r.ingredient_ids else [],
        }
        for r in vault_rows
    ]

    # Query 2 — Members: diets + allergens per member
    member_rows = db.execute(text("""
        SELECT
            u.user_id,
            u.name,
            u.dietary_preference,
            COALESCE(
                ARRAY(
                    SELECT mr.ingredient_id
                    FROM member_restrictions mr
                    WHERE mr.user_id = u.user_id
                    AND mr.restriction_type = 'Allergy'
                ), '{}'::integer[]
            ) as allergen_ids
        FROM users u
        WHERE u.house_id = CAST(:hid AS uuid)
        AND u.is_active = true
    """), {"hid": house_id}).fetchall()

    members = {
        str(r.user_id): {
            "name":              r.name,
            "dietary_preference": r.dietary_preference or "Veg",
            "allergen_ids":      list(r.allergen_ids) if r.allergen_ids else [],
        }
        for r in member_rows
    }

    # Query 3 — Weekly availability: who's home per day per slot
    avail_rows = db.execute(text("""
        SELECT user_id, availability_date, meal_slot
        FROM member_availability
        WHERE house_id = CAST(:hid AS uuid)
        AND availability_date >= :ws
        AND availability_date < :we
        AND is_present = true
    """), {
        "hid": house_id,
        "ws":  week_start,
        "we":  week_start + timedelta(days=7),
    }).fetchall()

    # Build availability map: {day_name: {slot: [user_id, ...]}}
    availability = {}
    for r in avail_rows:
        day_idx = (r.availability_date - week_start).days
        if 0 <= day_idx < 7:
            day = DAYS_OF_WEEK[day_idx]
            if day not in availability:
                availability[day] = {}
            slot = r.meal_slot
            if slot not in availability[day]:
                availability[day][slot] = []
            availability[day][slot].append(str(r.user_id))

    # Query 4 — Satvik: event days this week + household satvik restrictions
    satvik_rows = db.execute(text("""
        SELECT event_date FROM event_master
        WHERE house_id = CAST(:hid AS uuid)
        AND event_date >= :ws
        AND event_date < :we
        AND is_sattvic_required = true
        AND is_active = true
    """), {
        "hid": house_id,
        "ws":  week_start,
        "we":  week_start + timedelta(days=7),
    }).fetchall()

    satvik_days = {
        DAYS_OF_WEEK[(r.event_date - week_start).days]
        for r in satvik_rows
        if 0 <= (r.event_date - week_start).days < 7
    }

    satvik_restriction_rows = db.execute(text("""
        SELECT ingredient_id FROM satvik_restrictions
        WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchall()

    satvik_avoided_ids = {r.ingredient_id for r in satvik_restriction_rows}

    # Query 5 — Recent recipes: what was served in past N weeks per slot
    cutoff = week_start - timedelta(weeks=no_repeat_weeks)
    recent_rows = db.execute(text("""
        SELECT DISTINCT recipe_id, meal_slot
        FROM weekly_plan_slots
        WHERE house_id = CAST(:hid AS uuid)
        AND week_start >= :cutoff
        AND week_start < :ws
    """), {"hid": house_id, "cutoff": cutoff, "ws": week_start}).fetchall()

    recent_by_slot = {}
    for r in recent_rows:
        slot = r.meal_slot
        if slot not in recent_by_slot:
            recent_by_slot[slot] = set()
        recent_by_slot[slot].add(str(r.recipe_id))

    return {
        "approved_recipes":  approved_recipes,
        "members":           members,
        "availability":      availability,
        "satvik_days":       satvik_days,
        "satvik_avoided_ids": satvik_avoided_ids,
        "recent_by_slot":    recent_by_slot,
        "no_repeat_weeks":   no_repeat_weeks,
    }


def get_active_formulas(db: Session) -> Dict[str, bool]:
    """Load which formulas are active from feature_registry."""
    rows = db.execute(text("""
        SELECT function_name, is_active
        FROM feature_registry
        WHERE feature_code LIKE 'RA-%'
    """)).fetchall()
    return {r.function_name: r.is_active for r in rows}


# ── Step 2: Audit logger ──────────────────────────────────────────────────────

def _log(
    db: Session, house_id: str, week_start: date,
    day_name: str, meal_slot: str,
    feature_code: str, function_name: str,
    recipes_in: int, recipes_out: int,
    filtered_ids: List[str], filter_reason: str,
    selected_id: Optional[str] = None,
    execution_ms: int = 0
):
    try:
        db.execute(text("""
            INSERT INTO plan_audit_log
                (house_id, week_start, day_name, meal_slot,
                 feature_code, function_name,
                 recipes_in, recipes_out, filtered_count,
                 filter_reason, filtered_ids, selected_id, execution_ms)
            VALUES
                (CAST(:hid AS uuid), :ws, :day, :slot,
                 :fc, :fn, :rin, :rout, :fcnt,
                 :reason,
                 CAST(:fids AS uuid[]),
                 CAST(:sel AS uuid),
                 :ms)
        """), {
            "hid":    house_id,
            "ws":     week_start,
            "day":    day_name,
            "slot":   meal_slot,
            "fc":     feature_code,
            "fn":     function_name,
            "rin":    recipes_in,
            "rout":   recipes_out,
            "fcnt":   recipes_in - recipes_out,
            "reason": filter_reason,
            "fids":   "{" + ",".join(str(i) for i in filtered_ids) + "}" if filtered_ids else "{}",
            "sel":    str(selected_id) if selected_id else None,
            "ms":     execution_ms,
        })
    except Exception as e:
        print(f"[audit_log] {e}")


# ── Step 3: Formula functions — pure in-memory ────────────────────────────────

def filter_by_availability(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    avail = week_ctx["availability"]
    members = week_ctx["members"]
    all_member_ids = list(members.keys())

    # Get present members for this day+slot
    present_ids = avail.get(day, {}).get(slot, None)
    if present_ids is None:
        # No availability data — assume all home
        present_ids = all_member_ids
        reason = f"No availability data — all {len(all_member_ids)} members assumed home"
    else:
        reason = f"{len(present_ids)} member(s) home"

    ctx["present_ids"] = present_ids

    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F03", "filter_by_availability",
         len(recipes), len(recipes), [], reason, None, ms)
    return recipes, ctx


def filter_by_allergies(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    present_ids = ctx.get("present_ids", [])
    members = week_ctx["members"]

    # Collect all allergen ingredient IDs for present members
    allergen_ids = set()
    allergen_desc = []
    for uid in present_ids:
        m = members.get(uid, {})
        ids = m.get("allergen_ids", [])
        if ids:
            allergen_ids.update(ids)
            allergen_desc.append(f"{m.get('name','?')}:{len(ids)} allergens")

    if not allergen_ids:
        ms = int((time.time() - t0) * 1000)
        _log(db, house_id, week_start, day, slot,
             "RA-FA01", "filter_by_allergies",
             len(recipes), len(recipes), [], "No allergens", None, ms)
        return recipes, ctx

    filtered, removed = [], []
    for r in recipes:
        if set(r.get("ingredient_ids", [])) & allergen_ids:
            removed.append(r["recipe_id"])
        else:
            filtered.append(r)

    reason = f"Allergy block: {', '.join(allergen_desc)}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-FA01", "filter_by_allergies",
         len(recipes), len(filtered), removed, reason, None, ms)
    return filtered, ctx


def calc_effective_diet(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    present_ids = ctx.get("present_ids", [])
    members = week_ctx["members"]

    diets = [members[uid]["dietary_preference"] for uid in present_ids if uid in members]
    effective = max(diets, key=lambda d: DIET_ORDER.get(d, 0)) if diets else "Veg"
    ctx["effective_diet"] = effective

    reason = f"Effective diet: {effective} from {len(diets)} member(s)"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F02", "calc_effective_diet",
         len(recipes), len(recipes), [], reason, None, ms)
    return recipes, ctx


def filter_by_diet(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    effective = ctx.get("effective_diet", "Veg")
    allowed = DIET_COMPATIBLE.get(effective, ["Veg"])

    filtered = [r for r in recipes if r.get("diet_type") in allowed]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]

    reason = f"Diet: {effective} — allowed types: {allowed}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F01", "filter_by_diet",
         len(recipes), len(filtered), removed, reason, None, ms)
    return filtered, ctx


def check_satvik_day(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    is_satvik = day in week_ctx["satvik_days"]
    ctx["is_satvik_day"] = is_satvik

    reason = "Satvik day ✓" if is_satvik else "Not a Satvik day"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-FA02", "check_satvik_day",
         len(recipes), len(recipes), [], reason, None, ms)
    return recipes, ctx


def filter_satvik_ingredients(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    if not ctx.get("is_satvik_day", False):
        _log(db, house_id, week_start, day, slot,
             "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Not Satvik day — skipped", None, 0)
        return recipes, ctx

    avoided = week_ctx["satvik_avoided_ids"]
    if not avoided:
        _log(db, house_id, week_start, day, slot,
             "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Satvik day — no restrictions defined", None, 0)
        return recipes, ctx

    filtered = [r for r in recipes if not (set(r.get("ingredient_ids", [])) & avoided)]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]

    reason = f"Satvik: excluded {len(removed)} recipes with avoided ingredients"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F08", "filter_satvik_ingredients",
         len(recipes), len(filtered), removed, reason, None, ms)
    return filtered, ctx


def filter_by_meal_slot(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    allowed_intensities = SLOT_INTENSITY.get(slot, ["Medium"])
    filtered = [
        r for r in recipes
        if slot in r.get("meal_slots", [])
        and r.get("intensity_level", "Medium") in allowed_intensities
    ]
    removed = [r["recipe_id"] for r in recipes if r not in filtered]

    reason = f"{slot}: intensity={allowed_intensities}, {len(filtered)} pass"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F04", "filter_by_meal_slot",
         len(recipes), len(filtered), removed, reason, None, ms)
    return filtered, ctx


def filter_recent_recipes(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()

    recent = week_ctx["recent_by_slot"].get(slot, set())
    if not recent:
        _log(db, house_id, week_start, day, slot,
             "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [],
             f"No recent recipes in past {week_ctx['no_repeat_weeks']} week(s)", None, 0)
        return recipes, ctx

    filtered = [r for r in recipes if r["recipe_id"] not in recent]
    removed  = [r["recipe_id"] for r in recipes if r not in filtered]

    # Pool empty after filter — relax and use full pool
    if not filtered:
        _log(db, house_id, week_start, day, slot,
             "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [],
             "Pool empty after no-repeat — constraint relaxed", None, 0)
        return recipes, ctx

    reason = f"No-repeat: {len(removed)} excluded from past {week_ctx['no_repeat_weeks']} week(s)"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day, slot,
         "RA-F05", "filter_recent_recipes",
         len(recipes), len(filtered), removed, reason, None, ms)
    return filtered, ctx


def apply_breakfast_model(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()
    _log(db, house_id, week_start, day, slot,
         "RA-F13", "apply_breakfast_model",
         len(recipes), len(recipes), [],
         f"Breakfast pool: {len(recipes)} candidates", None,
         int((time.time() - t0) * 1000))
    return recipes, ctx


def apply_lunch_model(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()
    _log(db, house_id, week_start, day, slot,
         "RA-F14", "apply_lunch_model",
         len(recipes), len(recipes), [],
         f"Lunch pool: {len(recipes)} candidates", None,
         int((time.time() - t0) * 1000))
    return recipes, ctx


def apply_dinner_model(
    recipes: List[Dict], day: str, slot: str,
    ctx: Dict, week_ctx: Dict,
    db: Session, house_id: str, week_start: date
) -> Tuple[List[Dict], Dict]:
    t0 = time.time()
    _log(db, house_id, week_start, day, slot,
         "RA-F15", "apply_dinner_model",
         len(recipes), len(recipes), [],
         f"Dinner pool: {len(recipes)} candidates", None,
         int((time.time() - t0) * 1000))
    return recipes, ctx


# ── Formula map ───────────────────────────────────────────────────────────────

FORMULA_MAP = {
    "filter_by_availability":    ("RA-F03",  filter_by_availability),
    "filter_by_allergies":       ("RA-FA01", filter_by_allergies),
    "calc_effective_diet":       ("RA-F02",  calc_effective_diet),
    "filter_by_diet":            ("RA-F01",  filter_by_diet),
    "check_satvik_day":          ("RA-FA02", check_satvik_day),
    "filter_satvik_ingredients": ("RA-F08",  filter_satvik_ingredients),
    "filter_by_meal_slot":       ("RA-F04",  filter_by_meal_slot),
    "filter_recent_recipes":     ("RA-F05",  filter_recent_recipes),
    "apply_breakfast_model":     ("RA-F13",  apply_breakfast_model),
    "apply_lunch_model":         ("RA-F14",  apply_lunch_model),
    "apply_dinner_model":        ("RA-F15",  apply_dinner_model),
}


# ── Main entry point ──────────────────────────────────────────────────────────

def generate_plan(
    db: Session,
    house_id: str,
    week_start: date,
    fill_empty_only: bool = True
) -> Dict:
    """
    Generate recommendations for all 21 slots.
    5 DB queries upfront. Formula execution is pure in-memory.
    """

    # Get household no_repeat config
    config = db.execute(text("""
        SELECT no_repeat_weeks FROM household_plan_config
        WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()
    no_repeat_weeks = config.no_repeat_weeks if config else 1

    # Load all data in 5 queries
    week_ctx = load_week_context(db, house_id, week_start, no_repeat_weeks)

    # Load which formulas are active from feature_registry
    active_formulas = get_active_formulas(db)

    # Get existing plan if fill_empty_only
    existing = {}
    if fill_empty_only:
        rows = db.execute(text("""
            SELECT day_name, meal_slot, recipe_id, dish_name
            FROM weekly_plan_slots
            WHERE house_id = CAST(:hid AS uuid)
            AND week_start = :ws
        """), {"hid": house_id, "ws": week_start}).fetchall()
        for r in rows:
            existing.setdefault(r.day_name, {})[r.meal_slot] = {
                "recipe_id": str(r.recipe_id),
                "dish_name": r.dish_name,
            }

    result = {}

    for day in DAYS_OF_WEEK:
        result[day] = {}
        for slot in ["Breakfast", "Lunch", "Dinner"]:

            # Skip if already filled
            if fill_empty_only and existing.get(day, {}).get(slot):
                result[day][slot] = existing[day][slot]
                continue

            # Build pipeline for this slot
            pipeline = (
                [fn for fn in MAIN_PIPELINE if active_formulas.get(fn, True)]
                + [fn for fn in SLOT_PIPELINE.get(slot, []) if active_formulas.get(fn, True)]
            )

            # Run pipeline — pure in-memory
            candidates = list(week_ctx["approved_recipes"])
            ctx = {}

            for fn_name in pipeline:
                entry = FORMULA_MAP.get(fn_name)
                if not entry:
                    continue
                _, fn = entry
                try:
                    candidates, ctx = fn(
                        candidates, day, slot, ctx, week_ctx,
                        db, house_id, week_start
                    )
                except Exception as e:
                    print(f"[recommendation] {fn_name} failed: {e}")

            # Select one recipe randomly from final pool
            if candidates:
                selected = random.choice(candidates)
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     len(candidates), 1, [],
                     f"Selected: {selected['dish_name']} from {len(candidates)} candidates",
                     selected["recipe_id"])
                result[day][slot] = {
                    "recipe_id": selected["recipe_id"],
                    "dish_name": selected["dish_name"],
                    "diet_type": selected["diet_type"],
                    "intensity": selected["intensity_level"],
                }
            else:
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     0, 0, [], "No candidates — slot left empty", None)
                result[day][slot] = None

    db.commit()
    return result
