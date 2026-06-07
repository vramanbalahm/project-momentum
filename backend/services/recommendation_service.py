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
            COALESCE(
                ARRAY(
                    SELECT ri.ingredient_id
                    FROM recipe_ingredients ri
                    WHERE ri.recipe_id = r.recipe_id
                ), '{}'::integer[]
            ) AS ingredient_ids
        FROM recipe_dna_master r
        WHERE r.review_status = 'approved'
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
    try:
        fids = "{" + ",".join(str(i) for i in filtered_ids) + "}" if filtered_ids else "{}"
        db.execute(text("""
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
    except Exception as e:
        print(f"[audit_log] {e}")


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


def apply_dinner_model(recipes, day, slot, ctx, week_ctx, db, house_id, week_start, run_id=None):
    if slot != "Dinner": return recipes, ctx
    _log(db, house_id, week_start, day, slot, "RA-F15", "apply_dinner_model",
         len(recipes), len(recipes), [], f"Dinner pool: {len(recipes)}", None, 0, run_id=run_id)
    return recipes, ctx


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
                result[day][slot] = {
                    "recipe_id": selected["recipe_id"],
                    "dish_name": selected["dish_name"],
                    "diet_type": selected["diet_type"],
                    "intensity": selected["intensity_level"],
                }
            else:
                _log(db, house_id, week_start, day, slot,
                     "RA-SELECT", "random_select",
                     0, 0, [], "No candidates — slot left empty", None, 0, run_id=run_id)
                result[day][slot] = None

    db.commit()
    return result, run_id
