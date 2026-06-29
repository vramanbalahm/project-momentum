"""
audit_service.py
Audit engine — checks meal plan for issues.
Each check is a separate function, toggleable via feature_registry.
Feature codes: AU-D01 to AU-D06

Principle: Never blocks the user — only highlights issues with friendly messages.
"""

from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Dict

DIET_COMPATIBLE = {
    "Vegan":      ["Vegan"],
    "Veg":        ["Veg", "Vegan"],
    "Eggitarian": ["Veg", "Vegan", "Eggitarian"],
    "Non-Veg":    ["Veg", "Vegan", "Eggitarian", "Non-Veg"],
}

DIET_BY_RANK = {1: "Vegan", 2: "Veg", 3: "Eggitarian", 4: "Non-Veg"}


def load_active_audit_features(db: Session) -> set:
    """Load which audit checks are currently active from feature_registry."""
    rows = db.execute(text("""
        SELECT feature_code FROM feature_registry
        WHERE feature_code LIKE 'AU-%'
        AND is_active = TRUE
    """)).fetchall()
    return {r[0] for r in rows}


def load_household_context(db: Session, h_id: str) -> Dict:
    """Load all household context needed for audit checks in one pass."""

    # Effective diet
    diet_row = db.execute(text("""
        SELECT MIN(CASE dietary_preference::text
            WHEN 'Vegan'      THEN 1
            WHEN 'Veg'        THEN 2
            WHEN 'Eggitarian' THEN 3
            WHEN 'Non-Veg'    THEN 4
            ELSE 2 END) as diet_rank
        FROM member_preferences mp
        JOIN users u ON u.user_id = mp.user_id
        WHERE u.house_id = CAST(:h_id AS uuid)
    """), {"h_id": h_id}).fetchone()
    diet_rank      = diet_row[0] if diet_row and diet_row[0] else 2
    effective_diet = DIET_BY_RANK.get(diet_rank, "Veg")
    allowed_diets  = DIET_COMPATIBLE.get(effective_diet, ["Veg"])

    # Allergen IDs
    allergen_rows = db.execute(text("""
        SELECT DISTINCT ingredient_id FROM household_restrictions
        WHERE house_id = CAST(:h_id AS uuid)
        AND restriction_type = 'allergen'
    """), {"h_id": h_id}).fetchall()
    allergen_ids = {r[0] for r in allergen_rows}

    # Pantry ingredient IDs
    pantry_rows = db.execute(text("""
        SELECT DISTINCT ingredient_id FROM household_pantry
        WHERE house_id = CAST(:h_id AS uuid)
        AND (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)
    """), {"h_id": h_id}).fetchall()
    pantry_ids = {r[0] for r in pantry_rows}

    # Past 2 weeks meal history
    history_rows = db.execute(text("""
        SELECT DISTINCT r.dish_name
        FROM meal_event_detail med
        JOIN meal_event_header meh ON meh.event_id = med.event_id
        JOIN recipe_dna_master r   ON r.recipe_id  = med.recipe_id
        WHERE meh.house_id  = CAST(:h_id AS uuid)
        AND meh.event_date >= CURRENT_DATE - INTERVAL '14 days'
        AND meh.event_date  < CURRENT_DATE
    """), {"h_id": h_id}).fetchall()
    recent_meals = {r[0] for r in history_rows}

    # Satvik dates this week
    satvik_rows = db.execute(text("""
        SELECT observation_date::text FROM panchangam_types
        WHERE observation_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
        AND is_satvik = TRUE
    """)).fetchall()
    satvik_dates = {r[0] for r in satvik_rows}

    return {
        "effective_diet": effective_diet,
        "allowed_diets":  allowed_diets,
        "allergen_ids":   allergen_ids,
        "pantry_ids":     pantry_ids,
        "recent_meals":   recent_meals,
        "satvik_dates":   satvik_dates,
    }


def load_recipe(db: Session, recipe_id: str) -> Dict:
    """Load recipe details needed for audit."""
    if not recipe_id:
        return {}
    row = db.execute(text("""
        SELECT dish_name, diet_type::text, is_sattvic, intensity_level
        FROM recipe_dna_master
        WHERE recipe_id = CAST(:rid AS uuid)
    """), {"rid": recipe_id}).fetchone()
    if not row:
        return {}
    return {"name": row[0], "diet": row[1], "sattvic": row[2], "intensity": row[3]}


# ── Individual audit check functions ─────────────────────────────────────────

def audit_diet(recipe: Dict, ctx: Dict) -> str | None:
    """AU-D01: Check diet compatibility."""
    if not recipe:
        return None
    if recipe.get("diet") not in ctx["allowed_diets"]:
        return "This dish may not suit everyone at the table today."
    return None


def audit_allergens(db: Session, recipe_id: str, ctx: Dict) -> str | None:
    """AU-D02: Check for allergen ingredients."""
    if not recipe_id or not ctx["allergen_ids"]:
        return None
    hit = db.execute(text("""
        SELECT COUNT(*) FROM recipe_ingredients
        WHERE recipe_id     = CAST(:rid AS uuid)
        AND ingredient_id   = ANY(:aids)
        AND is_optional     = FALSE
    """), {"rid": recipe_id, "aids": list(ctx["allergen_ids"])}).scalar()
    if hit:
        return "One of the ingredients may cause a reaction for someone in the family."
    return None


def audit_satvik(recipe: Dict, date: str, ctx: Dict) -> str | None:
    """AU-D03: Check Satvik day compliance."""
    if not recipe or not date:
        return None
    if str(date) in ctx["satvik_dates"] and not recipe.get("sattvic"):
        return "Today is a fasting day — this dish might not be the best fit."
    return None


def audit_repeat_week(meal_name: str, seen_this_week: set) -> str | None:
    """AU-D04: Check repeat within current week."""
    if meal_name and meal_name in seen_this_week:
        return "This dish is already in your plan this week — a little variety would be nice!"
    return None


def audit_repeat_past(meal_name: str, ctx: Dict) -> str | None:
    """AU-D05: Check repeat from past 2 weeks."""
    if meal_name and meal_name in ctx["recent_meals"]:
        return "You had this recently — maybe try something different this week?"
    return None


def audit_pantry(db: Session, recipe_id: str, ctx: Dict) -> str | None:
    """AU-D06: Check if primary ingredients are in pantry."""
    if not recipe_id or not ctx["pantry_ids"]:
        return None
    total = db.execute(text("""
        SELECT COUNT(*) FROM recipe_ingredients
        WHERE recipe_id = CAST(:rid AS uuid) AND is_optional = FALSE
    """), {"rid": recipe_id}).scalar() or 0
    if total == 0:
        return None
    in_pantry = db.execute(text("""
        SELECT COUNT(*) FROM recipe_ingredients
        WHERE recipe_id     = CAST(:rid AS uuid)
        AND is_optional     = FALSE
        AND ingredient_id   = ANY(:pids)
    """), {"rid": recipe_id, "pids": list(ctx["pantry_ids"])}).scalar() or 0
    if (total - in_pantry) > 0:
        return "You may need to pick up some ingredients before cooking this."
    return None


# ── Main audit runner ─────────────────────────────────────────────────────────

AUDIT_FUNCTIONS = {
    "AU-D01": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_diet(recipe, ctx),
    "AU-D02": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_allergens(db, recipe_id, ctx),
    "AU-D03": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_satvik(recipe, date, ctx),
    "AU-D04": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_repeat_week(meal, seen),
    "AU-D05": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_repeat_past(meal, ctx),
    "AU-D06": lambda db, recipe, recipe_id, meal, date, ctx, seen: audit_pantry(db, recipe_id, ctx),
}


def execute_audit(db: Session, h_id: str, changes: list) -> List[Dict]:
    """
    Main audit runner — checks each meal slot against all active AU- features.
    Returns list of results with friendly issue messages.
    """
    active_features = load_active_audit_features(db)
    ctx             = load_household_context(db, h_id)
    seen_this_week  = set()
    result_map      = []

    for change in changes:
        day       = change.day
        slot      = change.type
        meal      = change.to_meal
        date      = change.date if hasattr(change, "date") else None
        recipe_id = change.recipe_id if hasattr(change, "recipe_id") else None

        if not meal or meal == "Skipped":
            result_map.append({"day": day, "type": slot, "status": "ok", "issues": []})
            continue

        recipe = load_recipe(db, recipe_id) if recipe_id else {}
        issues = []

        # Run each active audit check
        for feature_code, fn in AUDIT_FUNCTIONS.items():
            if feature_code not in active_features:
                continue
            try:
                issue = fn(db, recipe, recipe_id, meal, date, ctx, seen_this_week)
                if issue:
                    issues.append(issue)
            except Exception as e:
                print(f"[audit] {feature_code} error: {e}")

        # Track within-week seen meals (after checks so first occurrence is clean)
        if meal:
            seen_this_week.add(meal)

        result_map.append({
            "day":     day,
            "type":    slot,
            "status":  "ok" if not issues else "warning",
            "issues":  issues,
            "message": issues[0] if issues else "Ready",
            "score":   90 if not issues else 65,
        })

    return result_map
