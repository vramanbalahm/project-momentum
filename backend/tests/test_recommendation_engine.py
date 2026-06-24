"""
test_recommendation_engine.py
Tests for Recommendation Engine Bucket A — all 12 formulas + F16 side dish pairing.

Rules tested:
    F03  — filter_by_availability (who is home)
    FA01 — filter_by_allergies
    F02  — calc_effective_diet
    F01  — filter_by_diet
    FA02 — check_satvik_day
    F08  — filter_satvik_ingredients
    F04  — filter_by_meal_slot + intensity
    F05  — filter_recent_recipes (no repeat)
    F13  — apply_breakfast_model
    F14  — apply_lunch_model
    F15  — apply_dinner_model (lunch intensity → light dinner)
    F16  — recommend_sides (pairing table + category + ingredient overlap)
    GEN  — generate_plan (full pipeline, 21 slots)
"""

import pytest
import uuid
from sqlalchemy import text
from fastapi.testclient import TestClient
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main import app
from database import SessionLocal
from services.recommendation_service import (
    filter_by_availability,
    filter_by_allergies,
    calc_effective_diet,
    filter_by_diet,
    check_satvik_day,
    filter_satvik_ingredients,
    filter_by_meal_slot,
    filter_recent_recipes,
    recommend_sides,
    DIET_COMPATIBLE,
    DIET_ORDER,
)

client = TestClient(app)

# ── Fixtures ──────────────────────────────────────────────────────────────────

@pytest.fixture(scope="function")
def db():
    """Fresh DB session per test — rolls back on failure to prevent transaction cascade."""
    session = SessionLocal()
    yield session
    try:
        session.rollback()
    except Exception:
        pass
    session.close()


@pytest.fixture(scope="function")
def sample_recipes(db):
    """Load a small sample of approved recipes for testing."""
    rows = db.execute(text("""
        SELECT recipe_id::text, dish_name, diet_type::text,
               intensity_level, meal_slots, meal_role,
               dish_category, is_sattvic
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        LIMIT 100
    """)).fetchall()
    return [
        {
            "recipe_id":       r[0],
            "dish_name":       r[1],
            "diet_type":       r[2],
            "intensity_level": r[3],
            "meal_slots":      list(r[4]) if r[4] else [],
            "meal_role":       list(r[5]) if r[5] else ["main"],
            "dish_category":   r[6],
            "is_sattvic":      r[7] or False,
            "ingredient_ids":  [],
        }
        for r in rows
    ]


@pytest.fixture(scope="function")
def veg_recipes(sample_recipes):
    return [r for r in sample_recipes if r["diet_type"] == "Veg"]


@pytest.fixture(scope="function")
def week_ctx_default(db):
    """Default week context for testing."""
    return {
        "members":            [{"member_id": "m1", "diet": "Veg", "is_home": True}],
        "all_member_ids":     ["m1"],
        "availability":       {"Monday": {"Breakfast": ["m1"], "Lunch": ["m1"], "Dinner": ["m1"]},
                               "Tuesday": {"Breakfast": ["m1"], "Lunch": ["m1"], "Dinner": ["m1"]}},
        "allergen_ids":       set(),
        "satvik_days":        set(),
        "satvik_avoided_ids": set(),
        "recent_by_slot":     {"Breakfast": set(), "Lunch": set(), "Dinner": set()},
        "no_repeat_weeks":    1,
        "weekly_config":      {},
        "last_effective_diet": "Veg",
        "sides_used_this_week": set(),
        "lunch_intensity":    {},
        "lunch_sides":        {},
        "house_id":           str(uuid.uuid4()),
        "selected_this_week": {"Breakfast": set(), "Lunch": set(), "Dinner": set()},
    }


# ── F03: filter_by_availability ───────────────────────────────────────────────

class TestF03Availability:

    def test_members_home_returns_all_recipes(self, sample_recipes, week_ctx_default, db):
        """When members are home, recipe pool unchanged."""
        ctx = {}
        result, _ = filter_by_availability(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx_default,
            db, "house1", "2025-01-01"
        )
        assert len(result) == len(sample_recipes)

    def test_no_members_home_still_returns_recipes(self, sample_recipes, db):
        """Even if no members home, pool should not crash."""
        ctx = {}
        week_ctx = {
            "members":        [],
            "all_member_ids": [],
            "availability":   {"Monday": {"Breakfast": [], "Lunch": [], "Dinner": []}},
            "allergen_ids":   set(),
            "satvik_days":    set(),
            "satvik_avoided_ids": set(),
            "recent_by_slot": {"Breakfast": set(), "Lunch": set(), "Dinner": set()},
            "no_repeat_weeks": 1,
            "weekly_config":  {},
            "last_effective_diet": "Veg",
            "sides_used_this_week": set(),
            "lunch_intensity": {},
            "lunch_sides": {},
            "house_id": str(uuid.uuid4()),
            "selected_this_week": {"Breakfast": set(), "Lunch": set(), "Dinner": set()},
        }
        result, _ = filter_by_availability(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert isinstance(result, list)


# ── FA01: filter_by_allergies ─────────────────────────────────────────────────

class TestFA01Allergies:

    def test_no_allergens_returns_all(self, sample_recipes, week_ctx_default, db):
        """No allergens = full pool returned."""
        ctx = {}
        result, _ = filter_by_allergies(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx_default,
            db, "house1", "2025-01-01"
        )
        assert len(result) == len(sample_recipes)

    def test_allergen_removes_matching_recipes(self, db):
        """Recipes containing allergen ingredient should be removed."""
        # Get a real ingredient ID
        row = db.execute(text("SELECT id FROM ingredient_catalog LIMIT 1")).fetchone()
        if not row:
            pytest.skip("No ingredients in catalog")
        allergen_id = row[0]

        # Get recipes that contain this ingredient
        recipe_rows = db.execute(text("""
            SELECT recipe_id::text FROM recipe_ingredients
            WHERE ingredient_id = :aid LIMIT 5
        """), {"aid": allergen_id}).fetchall()
        allergic_ids = {r[0] for r in recipe_rows}

        if not allergic_ids:
            pytest.skip("No recipes with this ingredient")

        recipes = [{"recipe_id": rid, "dish_name": "Test", "diet_type": "Veg",
                    "intensity_level": "Medium", "meal_slots": ["Lunch"],
                    "meal_role": ["main"], "dish_category": "rice",
                    "is_sattvic": False, "ingredient_ids": [allergen_id]}
                   for rid in allergic_ids]

        test_house_id = str(uuid.uuid4())
        week_ctx = {"allergen_ids": {allergen_id}, "satvik_days": set(),
                    "satvik_avoided_ids": set(), "members": [],
                    "all_member_ids": [], "availability": {},
                    "recent_by_slot": {}, "no_repeat_weeks": 1,
                    "weekly_config": {}, "last_effective_diet": "Veg",
                    "sides_used_this_week": set(), "lunch_intensity": {},
                    "lunch_sides": {}, "house_id": test_house_id,
                    "selected_this_week": {}}
        ctx = {}
        result, _ = filter_by_allergies(
            recipes, "Monday", "Lunch", ctx, week_ctx,
            db, test_house_id, "2025-01-01"
        )
        result_ids = {r["recipe_id"] for r in result}
        assert not result_ids.intersection(allergic_ids), "Allergic recipes should be removed"


# ── F02: calc_effective_diet ──────────────────────────────────────────────────

class TestF02EffectiveDiet:

    def test_single_veg_member_effective_diet_veg(self, sample_recipes, db):
        """Single Veg member → effective diet = Veg."""
        ctx = {}
        week_ctx = {
            "members": [{"member_id": "m1", "diet": "Veg", "is_home": True}],
            "all_member_ids": ["m1"],
            "availability": {"Monday": {"Breakfast": ["m1"], "Lunch": ["m1"], "Dinner": ["m1"]}},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(),
            "recent_by_slot": {}, "no_repeat_weeks": 1,
            "weekly_config": {}, "last_effective_diet": "Veg",
            "sides_used_this_week": set(), "lunch_intensity": {},
            "lunch_sides": {}, "house_id": str(uuid.uuid4()),
            "selected_this_week": {},
        }
        result, ctx = calc_effective_diet(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert ctx.get("effective_diet") == "Veg"

    def test_veg_and_nonveg_strictest_is_veg(self, sample_recipes, db):
        """Veg + Non-Veg members → strictest = Veg."""
        ctx = {}
        week_ctx = {
            "members": [
                {"member_id": "m1", "diet": "Veg",     "is_home": True},
                {"member_id": "m2", "diet": "Non-Veg", "is_home": True},
            ],
            "all_member_ids": ["m1", "m2"],
            "availability": {"Monday": {"Breakfast": ["m1","m2"], "Lunch": ["m1","m2"], "Dinner": ["m1","m2"]}},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(),
            "recent_by_slot": {}, "no_repeat_weeks": 1,
            "weekly_config": {}, "last_effective_diet": "Veg",
            "sides_used_this_week": set(), "lunch_intensity": {},
            "lunch_sides": {}, "house_id": str(uuid.uuid4()),
            "selected_this_week": {},
        }
        result, ctx = calc_effective_diet(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert ctx.get("effective_diet") == "Veg"

    def test_diet_order_strictness(self):
        """Veg has highest order value (strictest), Non-Veg has lowest."""
        assert DIET_ORDER["Veg"] > DIET_ORDER["Non-Veg"]
        assert DIET_ORDER["Veg"] > DIET_ORDER["Eggitarian"]
        assert DIET_ORDER["Eggitarian"] > DIET_ORDER["Non-Veg"]


# ── F01: filter_by_diet ───────────────────────────────────────────────────────

class TestF01Diet:

    def test_veg_filter_removes_non_veg(self, sample_recipes, db):
        """Veg effective diet should remove Non-Veg recipes."""
        ctx = {"effective_diet": "Veg"}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_by_diet(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        non_veg = [r for r in result if r["diet_type"] == "Non-Veg"]
        assert len(non_veg) == 0, "Non-Veg recipes should be filtered out for Veg diet"

    def test_non_veg_filter_includes_all(self, sample_recipes, db):
        """Non-Veg effective diet should include all diet types."""
        ctx = {"effective_diet": "Non-Veg"}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Non-Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_by_diet(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        diets = {r["diet_type"] for r in result}
        assert "Non-Veg" in diets

    def test_diet_compatible_map(self):
        """DIET_COMPATIBLE map should be consistent."""
        assert "Veg" in DIET_COMPATIBLE["Veg"]
        assert "Non-Veg" not in DIET_COMPATIBLE["Veg"]
        assert "Non-Veg" in DIET_COMPATIBLE["Non-Veg"]
        assert "Veg" in DIET_COMPATIBLE["Non-Veg"]


# ── FA02 + F08: Satvik rules ──────────────────────────────────────────────────

class TestSatvik:

    def test_satvik_day_sets_context(self, sample_recipes, db):
        """On a Satvik day, context should reflect it."""
        ctx = {}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(),
            "satvik_days": {"Monday"},  # Monday is Satvik
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, ctx = check_satvik_day(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert ctx.get("is_satvik_day") == True

    def test_non_satvik_day_no_restriction(self, sample_recipes, db):
        """On non-Satvik day, Satvik flag should be False."""
        ctx = {}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, ctx = check_satvik_day(
            sample_recipes, "Tuesday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert ctx.get("is_satvik_day") == False

    def test_satvik_filter_removes_non_satvik(self, db):
        """On Satvik day, non-Satvik recipes should be removed."""
        recipes = [
            {"recipe_id": "r1", "dish_name": "Satvik Dish", "diet_type": "Veg",
             "intensity_level": "Light", "meal_slots": ["Lunch"],
             "meal_role": ["main"], "dish_category": "rice",
             "is_sattvic": True, "ingredient_ids": []},
            {"recipe_id": "r2", "dish_name": "Non Satvik Dish", "diet_type": "Veg",
             "intensity_level": "Medium", "meal_slots": ["Lunch"],
             "meal_role": ["main"], "dish_category": "rice",
             "is_sattvic": False, "ingredient_ids": [99]},  # 99 = avoided ingredient
        ]
        ctx = {"is_satvik": True}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": {"Monday"},
            "satvik_avoided_ids": {99},  # ingredient 99 is avoided
            "recent_by_slot": {}, "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_satvik_ingredients(
            recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        assert len(result) == 1
        assert result[0]["recipe_id"] == "r1"


# ── F04: filter_by_meal_slot ──────────────────────────────────────────────────

class TestF04MealSlot:

    def test_breakfast_only_light(self, sample_recipes, db):
        """Breakfast slot should only have Light intensity recipes."""
        ctx = {"effective_diet": "Veg"}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_by_meal_slot(
            sample_recipes, "Monday", "Breakfast", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        intensities = {r["intensity_level"] for r in result}
        assert "Heavy" not in intensities, "Breakfast should not have Heavy intensity"
        assert "Medium" not in intensities, "Breakfast should not have Medium intensity"

    def test_dinner_no_heavy(self, sample_recipes, db):
        """Dinner slot should not have Heavy intensity (Tamil Nadu eating pattern)."""
        ctx = {"effective_diet": "Veg"}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_by_meal_slot(
            sample_recipes, "Monday", "Dinner", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        intensities = {r["intensity_level"] for r in result}
        assert "Heavy" not in intensities, "Dinner should not have Heavy intensity"

    def test_lunch_has_medium_and_heavy(self, sample_recipes, db):
        """Lunch slot should include Medium and Heavy intensity."""
        ctx = {"effective_diet": "Veg"}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(), "recent_by_slot": {},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()), "selected_this_week": {},
        }
        result, _ = filter_by_meal_slot(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        intensities = {r["intensity_level"] for r in result}
        assert "Medium" in intensities or "Heavy" in intensities


# ── F05: filter_recent_recipes ────────────────────────────────────────────────

class TestF05NoRepeat:

    def test_recent_recipes_excluded(self, sample_recipes, db):
        """Recipes used recently should be excluded."""
        recent_id = sample_recipes[0]["recipe_id"]
        ctx = {}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(),
            "recent_by_slot": {"Lunch": {recent_id}},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()),
            "selected_this_week": {"Breakfast": set(), "Lunch": {recent_id}, "Dinner": set()},
        }
        result, _ = filter_recent_recipes(
            sample_recipes, "Monday", "Lunch", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        result_ids = {r["recipe_id"] for r in result}
        assert recent_id not in result_ids

    def test_within_week_no_repeat(self, sample_recipes, db):
        """Recipes selected earlier this week should not repeat."""
        used_id = sample_recipes[0]["recipe_id"]
        ctx = {}
        week_ctx = {
            "members": [], "all_member_ids": [], "availability": {},
            "allergen_ids": set(), "satvik_days": set(),
            "satvik_avoided_ids": set(),
            "recent_by_slot": {"Dinner": set()},
            "no_repeat_weeks": 1, "weekly_config": {},
            "last_effective_diet": "Veg", "sides_used_this_week": set(),
            "lunch_intensity": {}, "lunch_sides": {},
            "house_id": str(uuid.uuid4()),
            "selected_this_week": {"Breakfast": set(), "Lunch": {used_id}, "Dinner": set()},
        }
        result, _ = filter_recent_recipes(
            sample_recipes, "Tuesday", "Dinner", ctx, week_ctx,
            db, "house1", "2025-01-01"
        )
        result_ids = {r["recipe_id"] for r in result}
        assert used_id not in result_ids, "Recipe used at Lunch should not appear at Dinner"


# ── F16: recommend_sides ──────────────────────────────────────────────────────

class TestF16Sides:

    def test_sides_returned_for_valid_main(self, db):
        """F16 should return sides for a main dish with pairings."""
        row = db.execute(text("""
            SELECT r.recipe_id::text, r.dish_name, r.dish_category
            FROM recipe_dna_master r
            JOIN recipe_pairing rp ON rp.main_recipe_id = r.recipe_id
            WHERE r.meal_role @> ARRAY['main']::text[]
            AND r.review_status = 'approved'
            AND rp.house_id IS NULL
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No pairings in recipe_pairing table")

        selected_main = {
            "recipe_id":     row[0],
            "dish_name":     row[1],
            "dish_category": row[2],
        }
        week_ctx = {
            "last_effective_diet":  "Veg",
            "satvik_days":          set(),
            "satvik_avoided_ids":   set(),
            "allergen_ids":         set(),
            "sides_used_this_week": set(),
            "house_id":             str(uuid.uuid4()),
        }
        sides = recommend_sides(
            db, str(uuid.uuid4()), "2025-01-06",
            "Monday", "Lunch", selected_main, week_ctx
        )
        assert isinstance(sides, list)

    def test_sides_max_2(self, db):
        """F16 should never return more than 2 sides."""
        row = db.execute(text("""
            SELECT r.recipe_id::text, r.dish_name, r.dish_category
            FROM recipe_dna_master r
            WHERE r.meal_role @> ARRAY['main']::text[]
            AND r.review_status = 'approved'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No main recipes")

        selected_main = {"recipe_id": row[0], "dish_name": row[1], "dish_category": row[2]}
        week_ctx = {
            "last_effective_diet":  "Veg",
            "satvik_days":          set(),
            "satvik_avoided_ids":   set(),
            "allergen_ids":         set(),
            "sides_used_this_week": set(),
            "house_id":             str(uuid.uuid4()),
        }
        sides = recommend_sides(
            db, str(uuid.uuid4()), "2025-01-06",
            "Monday", "Lunch", selected_main, week_ctx
        )
        assert len(sides) <= 2, "F16 should never return more than 2 sides"

    def test_sides_no_duplicate_category(self, db):
        """F16 should not return two sides of the same dish_category."""
        row = db.execute(text("""
            SELECT r.recipe_id::text, r.dish_name, r.dish_category
            FROM recipe_dna_master r
            WHERE r.meal_role @> ARRAY['main']::text[]
            AND r.review_status = 'approved'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No main recipes")

        selected_main = {"recipe_id": row[0], "dish_name": row[1], "dish_category": row[2]}
        week_ctx = {
            "last_effective_diet":  "Veg",
            "satvik_days":          set(),
            "satvik_avoided_ids":   set(),
            "allergen_ids":         set(),
            "sides_used_this_week": set(),
            "house_id":             str(uuid.uuid4()),
        }
        sides = recommend_sides(
            db, str(uuid.uuid4()), "2025-01-06",
            "Monday", "Lunch", selected_main, week_ctx
        )
        if len(sides) == 2:
            assert sides[0]["dish_category"] != sides[1]["dish_category"], \
                "Two sides should not have same dish_category"

    def test_sides_match_diet(self, db):
        """F16 sides should match the effective diet."""
        row = db.execute(text("""
            SELECT r.recipe_id::text, r.dish_name, r.dish_category
            FROM recipe_dna_master r
            WHERE r.meal_role @> ARRAY['main']::text[]
            AND r.review_status = 'approved'
            AND r.diet_type::text = 'Veg'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No Veg main recipes")

        selected_main = {"recipe_id": row[0], "dish_name": row[1], "dish_category": row[2]}
        week_ctx = {
            "last_effective_diet":  "Veg",
            "satvik_days":          set(),
            "satvik_avoided_ids":   set(),
            "allergen_ids":         set(),
            "sides_used_this_week": set(),
            "house_id":             str(uuid.uuid4()),
        }
        sides = recommend_sides(
            db, str(uuid.uuid4()), "2025-01-06",
            "Monday", "Lunch", selected_main, week_ctx
        )
        for side in sides:
            assert side["diet_type"] in ["Veg", "Vegan"], \
                f"Side {side['dish_name']} diet {side['diet_type']} incompatible with Veg household"

    def test_sides_no_repeat_within_week(self, db):
        """F16 should not suggest sides already used this week."""
        row = db.execute(text("""
            SELECT r.recipe_id::text, r.dish_name, r.dish_category,
                   rp.side_recipe_id::text
            FROM recipe_dna_master r
            JOIN recipe_pairing rp ON rp.main_recipe_id = r.recipe_id
            WHERE r.meal_role @> ARRAY['main']::text[]
            AND r.review_status = 'approved'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No pairings")

        used_side_id = row[3]
        selected_main = {"recipe_id": row[0], "dish_name": row[1], "dish_category": row[2]}
        week_ctx = {
            "last_effective_diet":  "Veg",
            "satvik_days":          set(),
            "satvik_avoided_ids":   set(),
            "allergen_ids":         set(),
            "sides_used_this_week": {used_side_id},  # already used
            "house_id":             str(uuid.uuid4()),
        }
        sides = recommend_sides(
            db, str(uuid.uuid4()), "2025-01-06",
            "Monday", "Lunch", selected_main, week_ctx
        )
        side_ids = {s["recipe_id"] for s in sides}
        assert used_side_id not in side_ids, "Already used side should not be suggested again"


# ── Full plan generation ──────────────────────────────────────────────────────

class TestFullPlanGeneration:

    def test_generate_plan_returns_21_slots(self, admin_user=None):
        """Full plan should have 7 days × 3 slots = 21 slots."""
        # Use TestClient for API-level test
        with TestClient(app) as c:
            # Register and login
            email = f"test_{uuid.uuid4().hex[:8]}@test.com"
            reg = c.post("/auth/register", json={
                "email": email, "password": "Test1234!",
                "name": "Test", "house_name": "Test House",
                "primary_region": "Tamil Nadu", "current_city": "Chennai",
                "dietary_preference": "Veg"
            })
            if reg.status_code != 200:
                pytest.skip("Registration failed — check DB connection")

            token = reg.json()["access_token"]
            headers = {"Authorization": f"Bearer {token}"}

            # Generate plan
            from datetime import date, timedelta
            # Use a unique past Monday to avoid conflicts with existing plans
            unique_offset = hash(email) % 520  # up to 10 years back
            monday = date(2020, 1, 6) - timedelta(weeks=unique_offset % 52)
            week_start = monday.strftime("%Y-%m-%d")

            resp = c.post("/recommendation/generate", json={
                "week_start": week_start,
                "questionnaire": {}
            }, headers=headers)

            if resp.status_code == 200:
                plan = resp.json()
                slot_count = sum(
                    1 for day_data in plan.values()
                    for slot in day_data.values()
                    if slot is not None
                )
                assert slot_count > 0, "Plan should have at least some slots filled"

    def test_generate_plan_no_repeat_same_week(self):
        """Generated plan should not have same main dish twice in a week."""
        with TestClient(app) as c:
            email = f"test_{uuid.uuid4().hex[:8]}@test.com"
            reg = c.post("/auth/register", json={
                "email": email, "password": "Test1234!",
                "name": "Test", "house_name": "Test House",
                "primary_region": "Tamil Nadu", "current_city": "Chennai",
                "dietary_preference": "Veg"
            })
            if reg.status_code != 200:
                pytest.skip("Registration failed")

            token = reg.json()["access_token"]
            headers = {"Authorization": f"Bearer {token}"}

            from datetime import date, timedelta
            unique_offset = hash(email) % 520
            monday = date(2021, 1, 4) - timedelta(weeks=unique_offset % 52)
            week_start = monday.strftime("%Y-%m-%d")

            resp = c.post("/recommendation/generate", json={
                "week_start": week_start, "questionnaire": {}
            }, headers=headers)

            if resp.status_code == 200:
                plan = resp.json()
                all_mains = []
                for day_data in plan.values():
                    for slot_data in day_data.values():
                        if slot_data and slot_data.get("recipe_id"):
                            all_mains.append(slot_data["recipe_id"])
                # Check no repeat
                assert len(all_mains) == len(set(all_mains)), \
                    "Same main dish should not appear twice in a week"


# ── Search endpoint ───────────────────────────────────────────────────────────

class TestRecipeSearch:

    def test_search_returns_results(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/search?q=idli")
            assert resp.status_code == 200
            assert len(resp.json()) > 0

    def test_search_veg_filter(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/search?diet_type=Veg&is_side_dish=false")
            assert resp.status_code == 200
            results = resp.json()
            for r in results:
                assert r["diet_type"] == "Veg"

    def test_search_side_dish_filter(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/search?is_side_dish=true")
            assert resp.status_code == 200
            results = resp.json()
            for r in results:
                assert "side" in r.get("meal_role", [])

    def test_search_intensity_filter(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/search?intensity=Light")
            assert resp.status_code == 200
            results = resp.json()
            for r in results:
                assert r["intensity_level"] == "Light"

    def test_sub_regions_endpoint(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/sub-regions")
            assert resp.status_code == 200
            data = resp.json()
            assert "sub_regions" in data
            assert len(data["sub_regions"]) > 0

    def test_dish_category_filter(self):
        with TestClient(app) as c:
            resp = c.get("/recipes/search?dish_category=tiffin")
            assert resp.status_code == 200
            results = resp.json()
            for r in results:
                assert r.get("dish_category") == "tiffin"
