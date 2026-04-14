from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, timedelta
from typing import Optional
import random

# ================================================================
# FT-030: generate_weekly_plan — Rule-based weekly plan generation
#
# Design principle: This function is intentionally simple for MVP.
# Intelligence improves incrementally via feature registry.
# The function signature stays stable — only internals get smarter.
#
# Called from:
#   - /weekly-plan/generate (no existing plan for the week)
#   - /weekly-plan/clone (previous week as starting template)
#   - FT-060 generate_weekly_draft_ai (AI overrides rule output)
#
# Parameters:
#   db              — DB session
#   h_id            — household UUID string
#   week_start_date — Monday of the target week (date object)
#   context         — dict with questionnaire + profile + market data
#
# Returns:
#   {
#     "week_start_date": "2026-04-14",
#     "generation_method": "Rule",
#     "days": [
#       {
#         "date": "2026-04-14",
#         "day_name": "Monday",
#         "slots": [
#           {
#             "type": "Breakfast",
#             "main": { recipe dict },
#             "sides": [ { recipe dict }, ... ]
#           },
#           ...
#         ]
#       },
#       ...
#     ]
#   }
# ================================================================

DAYS_OF_WEEK = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
MEAL_SLOTS = ["Breakfast", "Lunch", "Dinner"]


def generate_weekly_plan(
    db: Session,
    h_id: str,
    week_start_date: date,
    context: dict
) -> dict:
    """
    FT-030: Rule-based weekly plan generation.
    Pure function — no side effects. Does not write to DB.
    Caller is responsible for persisting the returned plan.
    """

    # ── 1. Extract context parameters ────────────────────────
    cook_energy    = context.get("cook_energy_level", "Medium")   # Low / Medium / High
    guest_count    = context.get("guest_count", 0)
    veg_split      = context.get("veg_nonveg_split", "As Profile")
    event_overrides = context.get("event_overrides", {})          # date_str -> {is_satvik, dietary}
    satvik_days    = context.get("satvik_days", [])               # [date_str, ...]
    market_stress  = context.get("market_stress", False)
    market_cap_level = context.get("market_cap_level", 2)
    daily_pattern  = context.get("daily_pattern", {})             # "Monday-Breakfast" -> level_number
    complexity_levels = context.get("complexity_levels", {})      # level_number -> {main, sides}
    questionnaire_week = context.get("questionnaire_week", 1)

    # ── 2. Fetch household dietary preference as base ─────────
    pref_row = db.execute(
        text("""
            SELECT dietary_preference, native_region
            FROM household_master
            WHERE household_id = CAST(:h_id AS uuid)
        """),
        {"h_id": h_id}
    ).fetchone()

    base_diet = str(pref_row[0]) if pref_row else "Veg"
    native_region = pref_row[1] if pref_row else None

    # ── 3. Fetch all candidate recipes from vault ─────────────
    # One DB call — we filter in Python to avoid multiple round trips
    recipes = _fetch_candidate_recipes(db, h_id, base_diet)

    if not recipes:
        return _empty_plan(week_start_date)

    # ── 4. Fetch default complexity levels if not in context ──
    if not complexity_levels:
        complexity_levels = _fetch_complexity_levels(db, h_id)

    # ── 5. Fetch daily meal pattern if not in context ─────────
    if not daily_pattern:
        daily_pattern = _fetch_daily_pattern(db, h_id)

    # ── 6. Build 7-day plan ───────────────────────────────────
    used_recipe_ids = set()   # Prevent repetition within the week
    days = []

    for day_offset in range(7):
        day_date = week_start_date + timedelta(days=day_offset)
        day_name = DAYS_OF_WEEK[day_offset]
        date_str = str(day_date)

        # Check event override for this day
        day_event = event_overrides.get(date_str, {})
        day_is_satvik = date_str in satvik_days or day_event.get("is_satvik", False)
        day_dietary = day_event.get("dietary", veg_split)

        slots = []
        for slot in MEAL_SLOTS:
            # ── Get complexity level for this day/slot ────────
            pattern_key = f"{day_name}-{slot}"
            level_number = daily_pattern.get(pattern_key, 2)

            # ── Apply cook energy adjustment ──────────────────
            # Low energy → drop one level (minimum level 1)
            # High energy → raise one level (maximum level 4)
            if cook_energy == "Low" and level_number > 1:
                level_number -= 1
            elif cook_energy == "High" and level_number < 4:
                level_number += 1

            # ── Apply market stress cap ───────────────────────
            if market_stress and level_number > market_cap_level:
                level_number = market_cap_level

            # ── Get dish counts for this level ────────────────
            level_def = complexity_levels.get(
                level_number,
                {"main_dish_count": 1, "side_dish_count": 1}
            )
            main_count = level_def.get("main_dish_count", 1)
            side_count = level_def.get("side_dish_count", 1)

            # ── Filter recipes for this slot ──────────────────
            filtered = _filter_recipes(
                recipes=recipes,
                is_satvik=day_is_satvik,
                dietary=day_dietary,
                base_diet=base_diet,
                exclude_ids=used_recipe_ids
            )

            if not filtered:
                # Relax exclusion if nothing available
                filtered = _filter_recipes(
                    recipes=recipes,
                    is_satvik=day_is_satvik,
                    dietary=day_dietary,
                    base_diet=base_diet,
                    exclude_ids=set()
                )

            # ── Pick main dish ────────────────────────────────
            main_dish = None
            if filtered:
                # Prefer in-stock — already scored in _fetch_candidate_recipes
                main_candidates = sorted(filtered, key=lambda r: r["score"], reverse=True)
                main_dish = main_candidates[0]
                used_recipe_ids.add(main_dish["recipe_id"])

            # ── Pick side dishes ──────────────────────────────
            side_dishes = []
            side_candidates = [r for r in filtered if r["recipe_id"] != (main_dish["recipe_id"] if main_dish else "")]
            random.shuffle(side_candidates)
            for i in range(min(side_count, len(side_candidates))):
                side = side_candidates[i]
                side_dishes.append(side)
                used_recipe_ids.add(side["recipe_id"])

            slots.append({
                "type": slot,
                "level": level_number,
                "is_satvik": day_is_satvik,
                "main": main_dish,
                "sides": side_dishes
            })

        days.append({
            "date": date_str,
            "day_name": day_name,
            "has_event": bool(day_event),
            "slots": slots
        })

    return {
        "week_start_date": str(week_start_date),
        "generation_method": "Rule",
        "questionnaire_week": questionnaire_week,
        "days": days
    }


# ================================================================
# Helper functions — private to this module
# ================================================================

def _fetch_candidate_recipes(db: Session, h_id: str, base_diet: str) -> list:
    """
    Fetch all candidate recipes from vault.
    Score includes inventory bonus — in-stock recipes preferred.
    Single DB call — filtering done in Python.
    """
    rows = db.execute(
        text("""
            SELECT
                r.recipe_id,
                r.dish_name,
                r.recipe_code,
                r.diet_type,
                r.is_sattvic,
                r.is_vegan,
                v.hero_image_url,
                v.carousel_thumb_url,
                v.prep_steps,
                COALESCE(
                    CASE WHEN inv.stock_status = 'In-Stock' THEN 50 ELSE 0 END,
                    0
                ) as inventory_score
            FROM recipe_dna_master r
            LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
            LEFT JOIN staple_master_registry s ON r.primary_staple_id = s.staple_id
            LEFT JOIN household_inventory inv
                ON s.staple_id = inv.staple_id
                AND inv.house_id = CAST(:h_id AS uuid)
            ORDER BY inventory_score DESC, r.dish_name ASC
        """),
        {"h_id": h_id}
    ).fetchall()

    return [{
        "recipe_id": str(r[0]),
        "name": r[1],
        "code": r[2],
        "diet_type": str(r[3]) if r[3] else "Veg",
        "is_sattvic": bool(r[4]),
        "is_vegan": bool(r[5]),
        "hero": r[6],
        "thumb": r[7],
        "steps": r[8],
        "score": int(r[9])
    } for r in rows]


def _filter_recipes(
    recipes: list,
    is_satvik: bool,
    dietary: str,
    base_diet: str,
    exclude_ids: set
) -> list:
    """
    Filter recipe candidates based on Satvik, dietary, and exclusion rules.
    No force — warnings handled at display layer.
    """
    result = []
    for r in recipes:
        # Skip already used this week
        if r["recipe_id"] in exclude_ids:
            continue

        # Satvik filter — hard filter on generation
        # (user can override at display layer — FT-041)
        if is_satvik and not r["is_satvik"]:
            continue

        # Dietary filter
        effective_diet = dietary if dietary != "As Profile" else base_diet
        if effective_diet in ("Veg", "Full Veg") and r["diet_type"] not in ("Veg", "Vegan"):
            continue
        if effective_diet == "Vegan" and not r["is_vegan"]:
            continue

        result.append(r)

    return result


def _fetch_complexity_levels(db: Session, h_id: str) -> dict:
    """
    Fetch user-defined complexity levels from DB.
    Returns {level_number: {main_dish_count, side_dish_count}}
    Falls back to system defaults if not configured.
    """
    rows = db.execute(
        text("""
            SELECT level_number, main_dish_count, side_dish_count
            FROM complexity_levels
            WHERE house_id = CAST(:h_id AS uuid)
            ORDER BY level_number ASC
        """),
        {"h_id": h_id}
    ).fetchall()

    if rows:
        return {
            r[0]: {"main_dish_count": r[1], "side_dish_count": r[2]}
            for r in rows
        }

    # System defaults — used when household has not configured levels yet
    return {
        1: {"main_dish_count": 1, "side_dish_count": 1},
        2: {"main_dish_count": 1, "side_dish_count": 2},
        3: {"main_dish_count": 1, "side_dish_count": 3},
        4: {"main_dish_count": 2, "side_dish_count": 3}
    }


def _fetch_daily_pattern(db: Session, h_id: str) -> dict:
    """
    Fetch current_level per day/slot from daily_meal_pattern.
    Returns {"Monday-Breakfast": 2, "Monday-Lunch": 2, ...}
    Falls back to level 2 for all slots if not configured.
    """
    rows = db.execute(
        text("""
            SELECT day_of_week, CAST(meal_slot AS text) as meal_slot, current_level
            FROM daily_meal_pattern
            WHERE house_id = CAST(:h_id AS uuid)
        """),
        {"h_id": h_id}
    ).fetchall()

    if rows:
        return {f"{r[0]}-{r[1]}": r[2] for r in rows}

    # System default — level 2 for all slots
    pattern = {}
    for day in DAYS_OF_WEEK:
        for slot in MEAL_SLOTS:
            pattern[f"{day}-{slot}"] = 2
    return pattern


def _empty_plan(week_start_date: date) -> dict:
    """Returns an empty plan structure when no recipes are available."""
    days = []
    for day_offset in range(7):
        day_date = week_start_date + timedelta(days=day_offset)
        days.append({
            "date": str(day_date),
            "day_name": DAYS_OF_WEEK[day_offset],
            "has_event": False,
            "slots": [
                {"type": slot, "level": 2, "is_satvik": False, "main": None, "sides": []}
                for slot in MEAL_SLOTS
            ]
        })
    return {
        "week_start_date": str(week_start_date),
        "generation_method": "Rule",
        "questionnaire_week": 1,
        "days": days
    }
