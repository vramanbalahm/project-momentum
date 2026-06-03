# services/recommendation_service.py
# Recommendation Engine — Bucket A (Rule-based)
#
# Execution order driven by feature_registry.execution_order
# Every formula logs to plan_audit_log (Bucket C)
#
# Formula pipeline:
#   RA-F03  → filter_by_availability     (who's home)
#   RA-FA01 → filter_by_allergies        (hard block)
#   RA-F02  → calc_effective_diet        (strictest diet)
#   RA-F01  → filter_by_diet             (filter vault)
#   RA-FA02 → check_satvik_day           (is today Satvik)
#   RA-F08  → filter_satvik_ingredients  (Satvik filter)
#   RA-F04  → filter_by_meal_slot        (slot + intensity)
#   RA-F13  → apply_breakfast_model
#   RA-F14  → apply_lunch_model
#   RA-F15  → apply_dinner_model
#   RA-F16  → pair_side_dishes
#   RA-F05  → filter_recent_recipes      (no repeat)

import time
import random
from datetime import date, timedelta
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import text
from uuid import UUID


# ── Diet strictness order ─────────────────────────────────────────────────────

DIET_ORDER = {"Vegan": 4, "Veg": 3, "Eggitarian": 2, "Non-Veg": 1}
DIET_COMPATIBLE = {
    "Vegan":      ["Vegan"],
    "Veg":        ["Veg", "Vegan"],
    "Eggitarian": ["Veg", "Vegan", "Eggitarian"],
    "Non-Veg":    ["Veg", "Vegan", "Eggitarian", "Non-Veg"],
}

# Meal slot intensity rules
SLOT_INTENSITY = {
    "Breakfast": ["Light"],
    "Lunch":     ["Medium", "Heavy"],
    "Dinner":    ["Medium", "Heavy"],
}

DAYS_OF_WEEK = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]


# ── Audit logger ─────────────────────────────────────────────────────────────

def _log(
    db: Session,
    house_id: str,
    week_start: date,
    day_name: str,
    meal_slot: str,
    feature_code: str,
    function_name: str,
    recipes_in: int,
    recipes_out: int,
    filtered_ids: List[str],
    filter_reason: str,
    selected_id: Optional[str] = None,
    execution_ms: int = 0
):
    """Write one audit log entry."""
    try:
        db.execute(text("""
            INSERT INTO plan_audit_log
                (house_id, week_start, day_name, meal_slot,
                 feature_code, function_name,
                 recipes_in, recipes_out, filtered_count,
                 filter_reason, filtered_ids, selected_id, execution_ms)
            VALUES
                (CAST(:hid AS uuid), :ws, :day, :slot,
                 :fc, :fn,
                 :rin, :rout, :fcnt,
                 :reason, CAST(:fids AS uuid[]), CAST(:sel AS uuid), :ms)
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
        print(f"[audit_log] Failed to write log: {e}")


# ── Formula functions ─────────────────────────────────────────────────────────

def filter_by_availability(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F03: Get list of present members for this day.
    If no availability data → assume all members home.
    Sets context['present_members'] for downstream formulas.
    """
    t0 = time.time()

    day_index = DAYS_OF_WEEK.index(day_name) if day_name in DAYS_OF_WEEK else 0
    slot_date = week_start + timedelta(days=day_index)

    rows = db.execute(text("""
        SELECT DISTINCT ma.user_id, u.dietary_preference
        FROM member_availability ma
        JOIN users u ON u.user_id = ma.user_id
        WHERE ma.house_id = CAST(:hid AS uuid)
        AND ma.availability_date = :dt
        AND ma.meal_slot = :slot
        AND ma.is_present = true
    """), {"hid": house_id, "dt": slot_date, "slot": meal_slot}).fetchall()

    if not rows:
        # No availability data — fetch all active household members
        rows = db.execute(text("""
            SELECT user_id, dietary_preference
            FROM users
            WHERE house_id = CAST(:hid AS uuid)
            AND is_active = true
        """), {"hid": house_id}).fetchall()
        reason = f"No availability data — assuming all {len(rows)} members home"
    else:
        reason = f"{len(rows)} member(s) home for {day_name} {meal_slot}"

    context["present_members"] = [
        {"user_id": str(r.user_id), "dietary_preference": r.dietary_preference}
        for r in rows
    ]

    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F03", "filter_by_availability",
         len(recipes), len(recipes), [], reason, None, ms)

    return recipes, context


def filter_by_allergies(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-FA01: Hard block — exclude recipes containing allergens
    of any present member. No exceptions.
    """
    t0 = time.time()

    present = context.get("present_members", [])
    if not present:
        return recipes, context

    member_ids = [m["user_id"] for m in present]

    # Get all allergen ingredient IDs for present members
    rows = db.execute(text("""
        SELECT DISTINCT mr.ingredient_id, ic.name_en, u.name as member_name
        FROM member_restrictions mr
        JOIN users u ON u.user_id = mr.user_id
        JOIN ingredient_catalog ic ON ic.id = mr.ingredient_id
        WHERE mr.user_id = ANY(CAST(:mids AS uuid[]))
        AND mr.restriction_type = 'Allergy'
    """), {"mids": "{" + ",".join(member_ids) + "}"}).fetchall()

    if not rows:
        ms = int((time.time() - t0) * 1000)
        _log(db, house_id, week_start, day_name, meal_slot,
             "RA-FA01", "filter_by_allergies",
             len(recipes), len(recipes), [], "No allergens for present members", None, ms)
        return recipes, context

    allergen_ids = {r.ingredient_id for r in rows}
    allergen_names = [f"{r.name_en} ({r.member_name})" for r in rows]
    context["allergen_ids"] = allergen_ids

    # Filter recipes that contain any allergen
    filtered = []
    removed_ids = []
    for recipe in recipes:
        recipe_ingredient_ids = set(recipe.get("ingredient_ids", []))
        if recipe_ingredient_ids & allergen_ids:
            removed_ids.append(recipe["recipe_id"])
        else:
            filtered.append(recipe)

    reason = f"Allergy block: {', '.join(allergen_names[:5])}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-FA01", "filter_by_allergies",
         len(recipes), len(filtered), removed_ids, reason, None, ms)

    return filtered, context


def calc_effective_diet(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F02: Calculate strictest diet among present members.
    Vegan > Veg > Eggitarian > Non-Veg
    """
    t0 = time.time()

    present = context.get("present_members", [])
    if not present:
        # Fallback to household diet
        hh = db.execute(text("""
            SELECT dietary_preference FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": house_id}).fetchone()
        effective = hh.dietary_preference if hh else "Veg"
    else:
        diets = [m.get("dietary_preference", "Veg") or "Veg" for m in present]
        effective = max(diets, key=lambda d: DIET_ORDER.get(d, 0))

    context["effective_diet"] = effective

    reason = f"Effective diet: {effective} (from {len(present)} present member(s))"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F02", "calc_effective_diet",
         len(recipes), len(recipes), [], reason, None, ms)

    return recipes, context


def filter_by_diet(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F01: Filter vault by effective diet + approved only.
    """
    t0 = time.time()

    effective_diet = context.get("effective_diet", "Veg")
    allowed_diets = DIET_COMPATIBLE.get(effective_diet, ["Veg"])

    filtered = [r for r in recipes if r.get("diet_type") in allowed_diets]
    removed_ids = [r["recipe_id"] for r in recipes if r not in filtered]

    reason = f"Diet filter: {effective_diet} — allowed: {allowed_diets}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F01", "filter_by_diet",
         len(recipes), len(filtered), removed_ids, reason, None, ms)

    return filtered, context


def check_satvik_day(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-FA02: Check if today is a Satvik day for this household.
    Sets context['is_satvik_day'] for downstream formulas.
    """
    t0 = time.time()

    day_index = DAYS_OF_WEEK.index(day_name) if day_name in DAYS_OF_WEEK else 0
    slot_date = week_start + timedelta(days=day_index)

    row = db.execute(text("""
        SELECT COUNT(*) as cnt FROM event_master
        WHERE house_id = CAST(:hid AS uuid)
        AND event_date = :dt
        AND is_sattvic_required = true
        AND is_active = true
    """), {"hid": house_id, "dt": slot_date}).fetchone()

    is_satvik = row.cnt > 0 if row else False
    context["is_satvik_day"] = is_satvik

    reason = f"{'Satvik day — applying Satvik rules' if is_satvik else 'Not a Satvik day'}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-FA02", "check_satvik_day",
         len(recipes), len(recipes), [], reason, None, ms)

    return recipes, context


def filter_satvik_ingredients(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F08: On Satvik days exclude recipes containing
    household's Satvik-avoided ingredients.
    """
    t0 = time.time()

    if not context.get("is_satvik_day", False):
        ms = int((time.time() - t0) * 1000)
        _log(db, house_id, week_start, day_name, meal_slot,
             "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Not a Satvik day — skipped", None, ms)
        return recipes, context

    # Get household's Satvik-avoided ingredients
    rows = db.execute(text("""
        SELECT sr.ingredient_id, ic.name_en
        FROM satvik_restrictions sr
        JOIN ingredient_catalog ic ON ic.id = sr.ingredient_id
        WHERE sr.house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchall()

    if not rows:
        ms = int((time.time() - t0) * 1000)
        _log(db, house_id, week_start, day_name, meal_slot,
             "RA-F08", "filter_satvik_ingredients",
             len(recipes), len(recipes), [], "Satvik day but no restrictions defined", None, ms)
        return recipes, context

    satvik_avoided_ids = {r.ingredient_id for r in rows}
    satvik_names = [r.name_en for r in rows[:5]]

    filtered = []
    removed_ids = []
    for recipe in recipes:
        recipe_ingredient_ids = set(recipe.get("ingredient_ids", []))
        if recipe_ingredient_ids & satvik_avoided_ids:
            removed_ids.append(recipe["recipe_id"])
        else:
            filtered.append(recipe)

    reason = f"Satvik filter: avoiding {', '.join(satvik_names)}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F08", "filter_satvik_ingredients",
         len(recipes), len(filtered), removed_ids, reason, None, ms)

    return filtered, context


def filter_by_meal_slot(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F04: Filter by meal_slots array and intensity_level.
    Breakfast=Light only, Lunch/Dinner=Medium/Heavy.
    """
    t0 = time.time()

    allowed_intensities = SLOT_INTENSITY.get(meal_slot, ["Medium"])

    filtered = []
    removed_ids = []
    for recipe in recipes:
        meal_slots = recipe.get("meal_slots", [])
        intensity = recipe.get("intensity_level", "Medium")
        if meal_slot in meal_slots and intensity in allowed_intensities:
            filtered.append(recipe)
        else:
            removed_ids.append(recipe["recipe_id"])

    reason = f"Slot filter: {meal_slot} requires {allowed_intensities}"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F04", "filter_by_meal_slot",
         len(recipes), len(filtered), removed_ids, reason, None, ms)

    return filtered, context


def filter_recent_recipes(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F05: Exclude recipes used in the past N weeks.
    Default = 1 week. Configurable via household_plan_config.
    """
    t0 = time.time()

    # Get household config
    config = db.execute(text("""
        SELECT no_repeat_weeks FROM household_plan_config
        WHERE house_id = CAST(:hid AS uuid)
    """), {"hid": house_id}).fetchone()

    no_repeat_weeks = config.no_repeat_weeks if config else 1
    cutoff_date = week_start - timedelta(weeks=no_repeat_weeks)

    # Get recipes used in the past N weeks for this slot
    rows = db.execute(text("""
        SELECT DISTINCT recipe_id FROM weekly_plan_slots
        WHERE house_id = CAST(:hid AS uuid)
        AND meal_slot = :slot
        AND week_start >= :cutoff
        AND week_start < :ws
    """), {
        "hid":    house_id,
        "slot":   meal_slot,
        "cutoff": cutoff_date,
        "ws":     week_start,
    }).fetchall()

    recent_ids = {str(r.recipe_id) for r in rows}

    if not recent_ids:
        ms = int((time.time() - t0) * 1000)
        _log(db, house_id, week_start, day_name, meal_slot,
             "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [],
             f"No recent recipes in past {no_repeat_weeks} week(s)", None, ms)
        return recipes, context

    filtered = [r for r in recipes if str(r["recipe_id"]) not in recent_ids]
    removed_ids = [r["recipe_id"] for r in recipes if str(r["recipe_id"]) in recent_ids]

    reason = f"No-repeat filter: {len(recent_ids)} recipes excluded from past {no_repeat_weeks} week(s)"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F05", "filter_recent_recipes",
         len(recipes), len(filtered), removed_ids, reason, None, ms)

    # If pool is empty after filter — relax and return all (log it)
    if not filtered:
        _log(db, house_id, week_start, day_name, meal_slot,
             "RA-F05", "filter_recent_recipes",
             len(recipes), len(recipes), [],
             f"Pool empty after no-repeat filter — relaxing constraint", None, 0)
        return recipes, context

    return filtered, context


def apply_breakfast_model(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """RA-F13: Breakfast model — Light only, already filtered by F04."""
    t0 = time.time()
    if meal_slot != "Breakfast":
        return recipes, context
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F13", "apply_breakfast_model",
         len(recipes), len(recipes), [],
         f"Breakfast model: {len(recipes)} candidates", None, ms)
    return recipes, context


def apply_lunch_model(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """RA-F14: Lunch model — Medium/Heavy, already filtered by F04."""
    t0 = time.time()
    if meal_slot != "Lunch":
        return recipes, context
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F14", "apply_lunch_model",
         len(recipes), len(recipes), [],
         f"Lunch model: {len(recipes)} candidates", None, ms)
    return recipes, context


def apply_dinner_model(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """RA-F15: Dinner model — Medium/Heavy, already filtered by F04."""
    t0 = time.time()
    if meal_slot != "Dinner":
        return recipes, context
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F15", "apply_dinner_model",
         len(recipes), len(recipes), [],
         f"Dinner model: {len(recipes)} candidates", None, ms)
    return recipes, context


def pair_side_dishes(
    db: Session, house_id: str, week_start: date, day_name: str, meal_slot: str,
    recipes: List[Dict], context: Dict
) -> Tuple[List[Dict], Dict]:
    """
    RA-F16: Auto-pair side dishes with the selected main.
    Filters sides compatible with effective diet and meal slot.
    """
    t0 = time.time()

    selected_main = context.get("selected_main")
    if not selected_main:
        return recipes, context

    effective_diet = context.get("effective_diet", "Veg")
    allowed_diets = DIET_COMPATIBLE.get(effective_diet, ["Veg"])

    # Get side dishes compatible with this slot and diet
    sides = db.execute(text("""
        SELECT r.recipe_id, r.dish_name, r.diet_type, r.intensity_level,
               rv.meal_slots
        FROM recipe_dna_master r
        JOIN recipe_review_master rv ON rv.recipe_id = r.recipe_id
        WHERE rv.review_status = 'approved'
        AND r.diet_type = ANY(CAST(:diets AS diet_pref[]))
        AND rv.meal_slots @> CAST(:slot AS text[])
        AND rv.is_side_dish = true
        LIMIT 20
    """), {
        "diets": "{" + ",".join(f'"{d}"' for d in allowed_diets) + "}",
        "slot":  "{" + meal_slot + "}"
    }).fetchall()

    side_list = [
        {"recipe_id": str(s.recipe_id), "dish_name": s.dish_name,
         "diet_type": s.diet_type, "meal_slots": s.meal_slots}
        for s in sides
    ]

    context["available_sides"] = side_list

    reason = f"Side dish pairing: {len(side_list)} compatible sides found"
    ms = int((time.time() - t0) * 1000)
    _log(db, house_id, week_start, day_name, meal_slot,
         "RA-F16", "pair_side_dishes",
         len(side_list), len(side_list), [], reason, None, ms)

    return side_list, context


# ── Main pipeline ─────────────────────────────────────────────────────────────

# Formula map — function_name → function
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
    "pair_side_dishes":          pair_side_dishes,
}


def get_active_formulas(db: Session) -> List[Dict]:
    """Load active Bucket A formulas from feature_registry ordered by execution_order."""
    rows = db.execute(text("""
        SELECT feature_code, function_name, execution_order
        FROM feature_registry
        WHERE feature_code LIKE 'RA-%'
        AND is_active = true
        ORDER BY execution_order
    """)).fetchall()
    return [{"code": r.feature_code, "fn": r.function_name} for r in rows]


def load_approved_recipes(db: Session) -> List[Dict]:
    """
    Load all approved recipes from vault with ingredients.
    This is the full candidate pool before any filtering.
    """
    rows = db.execute(text("""
        SELECT
            r.recipe_id,
            r.dish_name,
            r.diet_type,
            r.intensity_level,
            r.is_sattvic,
            rv.meal_slots,
            rv.is_side_dish,
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

    return [
        {
            "recipe_id":      str(r.recipe_id),
            "dish_name":      r.dish_name,
            "diet_type":      str(r.diet_type) if r.diet_type else "Veg",
            "intensity_level": r.intensity_level or "Medium",
            "is_sattvic":     r.is_sattvic or False,
            "meal_slots":     list(r.meal_slots) if r.meal_slots else [],
            "ingredient_ids": list(r.ingredient_ids) if r.ingredient_ids else [],
        }
        for r in rows
    ]


def generate_plan(
    db: Session,
    house_id: str,
    week_start: date,
    fill_empty_only: bool = True
) -> Dict:
    """
    Main entry point — generate recommendations for all 21 slots.
    Runs Bucket A pipeline for each day+slot combination.

    Args:
        fill_empty_only: True = only fill empty slots, False = replace all
    Returns:
        Dict of {day: {slot: {recipe_id, dish_name, ...}}}
    """
    # Load active formulas from feature_registry
    formulas = get_active_formulas(db)

    # Load full approved recipe vault once (shared across all slots)
    all_recipes = load_approved_recipes(db)

    # Get existing plan if fill_empty_only
    existing_plan = {}
    if fill_empty_only:
        rows = db.execute(text("""
            SELECT day_name, meal_slot, recipe_id, dish_name
            FROM weekly_plan_slots
            WHERE house_id = CAST(:hid AS uuid)
            AND week_start = :ws
        """), {"hid": house_id, "ws": week_start}).fetchall()
        for r in rows:
            if r.day_name not in existing_plan:
                existing_plan[r.day_name] = {}
            existing_plan[r.day_name][r.meal_slot] = {
                "recipe_id": str(r.recipe_id),
                "dish_name": r.dish_name
            }

    result = {}
    db_dirty = False

    for day in DAYS_OF_WEEK:
        result[day] = {}
        for slot in ["Breakfast", "Lunch", "Dinner"]:

            # Skip if slot already filled and fill_empty_only
            if fill_empty_only and existing_plan.get(day, {}).get(slot):
                result[day][slot] = existing_plan[day][slot]
                continue

            # Run pipeline
            context = {}
            candidates = list(all_recipes)  # fresh copy per slot

            for formula in formulas:
                fn_name = formula["fn"]
                fn = FORMULA_MAP.get(fn_name)
                if not fn:
                    continue
                try:
                    candidates, context = fn(
                        db, house_id, week_start, day, slot, candidates, context
                    )
                except Exception as e:
                    print(f"[recommendation] Formula {fn_name} failed: {e}")
                    continue

            # Select one recipe from candidates
            selected = None
            if candidates:
                selected = random.choice(candidates)
                # Log selection
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
                # Empty pool — log and leave slot empty
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     0, 0, [], "No candidates after all filters — slot left empty", None)
                result[day][slot] = None

            db_dirty = True

    if db_dirty:
        db.commit()

    return result
