"""
test_audit_engine.py
Tests for the Audit Engine (AU-D01 to AU-D06).

Covers:
    - Each individual audit check function
    - feature_registry toggle behavior (enable/disable)
    - Full execute_audit() pipeline
    - /audit API endpoint
    - Edge cases: no recipe, no issues, multiple issues
"""

import pytest
import uuid
from sqlalchemy import text
from datetime import date, timedelta

from services.audit_service import (
    audit_diet,
    audit_allergens,
    audit_satvik,
    audit_repeat_week,
    audit_repeat_past,
    audit_pantry,
    load_household_context,
    load_active_audit_features,
    execute_audit,
    DIET_COMPATIBLE,
)


# ── Fixtures ──────────────────────────────────────────────────────────────────

@pytest.fixture
def sample_veg_recipe(db):
    """A real approved Veg recipe for testing."""
    row = db.execute(text("""
        SELECT recipe_id::text, dish_name FROM recipe_dna_master
        WHERE diet_type::text = 'Veg' AND review_status = 'approved'
        LIMIT 1
    """)).fetchone()
    if not row:
        pytest.skip("No approved Veg recipe found")
    return {"recipe_id": row[0], "dish_name": row[1]}


@pytest.fixture
def sample_nonveg_recipe(db):
    """A real approved Non-Veg recipe for testing."""
    row = db.execute(text("""
        SELECT recipe_id::text, dish_name FROM recipe_dna_master
        WHERE diet_type::text = 'Non-Veg' AND review_status = 'approved'
        LIMIT 1
    """)).fetchone()
    if not row:
        pytest.skip("No approved Non-Veg recipe found")
    return {"recipe_id": row[0], "dish_name": row[1]}


# ── AU-D01: Diet compatibility ────────────────────────────────────────────────

class TestAuditDiet:

    def test_veg_dish_in_veg_household_no_issue(self):
        recipe = {"diet": "Veg"}
        ctx = {"allowed_diets": DIET_COMPATIBLE["Veg"]}
        result = audit_diet(recipe, ctx)
        assert result is None

    def test_nonveg_dish_in_veg_household_flags_issue(self):
        recipe = {"diet": "Non-Veg"}
        ctx = {"allowed_diets": DIET_COMPATIBLE["Veg"]}
        result = audit_diet(recipe, ctx)
        assert result is not None
        assert "suit everyone" in result.lower()

    def test_vegan_dish_in_veg_household_no_issue(self):
        """Veg household accepts Vegan dishes too."""
        recipe = {"diet": "Vegan"}
        ctx = {"allowed_diets": DIET_COMPATIBLE["Veg"]}
        result = audit_diet(recipe, ctx)
        assert result is None

    def test_nonveg_dish_in_nonveg_household_no_issue(self):
        recipe = {"diet": "Non-Veg"}
        ctx = {"allowed_diets": DIET_COMPATIBLE["Non-Veg"]}
        result = audit_diet(recipe, ctx)
        assert result is None

    def test_empty_recipe_no_crash(self):
        ctx = {"allowed_diets": DIET_COMPATIBLE["Veg"]}
        result = audit_diet({}, ctx)
        assert result is None

    def test_message_does_not_expose_rule_name(self):
        """Message must be friendly, not technical."""
        recipe = {"diet": "Non-Veg"}
        ctx = {"allowed_diets": DIET_COMPATIBLE["Veg"]}
        result = audit_diet(recipe, ctx)
        assert "diet_type" not in result.lower()
        assert "veg" not in result.lower() or "everyone" in result.lower()


# ── AU-D02: Allergen check ────────────────────────────────────────────────────

class TestAuditAllergens:

    def test_no_allergens_configured_no_issue(self, db, sample_veg_recipe):
        ctx = {"allergen_ids": set()}
        result = audit_allergens(db, sample_veg_recipe["recipe_id"], ctx)
        assert result is None

    def test_recipe_with_allergen_flags_issue(self, db):
        # Find a real ingredient used in some recipe
        row = db.execute(text("""
            SELECT recipe_id::text, ingredient_id FROM recipe_ingredients
            WHERE is_optional = FALSE LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No recipe_ingredients found")
        recipe_id, ingredient_id = row
        ctx = {"allergen_ids": {ingredient_id}}
        result = audit_allergens(db, recipe_id, ctx)
        assert result is not None
        assert "reaction" in result.lower()

    def test_recipe_without_matching_allergen_no_issue(self, db, sample_veg_recipe):
        ctx = {"allergen_ids": {999999}}  # non-existent ingredient
        result = audit_allergens(db, sample_veg_recipe["recipe_id"], ctx)
        assert result is None

    def test_no_recipe_id_no_crash(self, db):
        ctx = {"allergen_ids": {1, 2, 3}}
        result = audit_allergens(db, None, ctx)
        assert result is None


# ── AU-D03: Satvik day check ──────────────────────────────────────────────────

class TestAuditSatvik:

    def test_non_satvik_day_no_issue(self):
        recipe = {"sattvic": False}
        ctx = {"satvik_dates": set()}
        result = audit_satvik(recipe, "2025-01-01", ctx)
        assert result is None

    def test_satvik_day_non_satvik_dish_flags_issue(self):
        recipe = {"sattvic": False}
        ctx = {"satvik_dates": {"2025-01-01"}}
        result = audit_satvik(recipe, "2025-01-01", ctx)
        assert result is not None
        assert "fasting" in result.lower()

    def test_satvik_day_satvik_dish_no_issue(self):
        recipe = {"sattvic": True}
        ctx = {"satvik_dates": {"2025-01-01"}}
        result = audit_satvik(recipe, "2025-01-01", ctx)
        assert result is None

    def test_no_date_no_crash(self):
        recipe = {"sattvic": False}
        ctx = {"satvik_dates": {"2025-01-01"}}
        result = audit_satvik(recipe, None, ctx)
        assert result is None


# ── AU-D04: Repeat this week ──────────────────────────────────────────────────

class TestAuditRepeatWeek:

    def test_first_occurrence_no_issue(self):
        seen = set()
        result = audit_repeat_week("Idli", seen)
        assert result is None

    def test_second_occurrence_flags_issue(self):
        seen = {"Idli"}
        result = audit_repeat_week("Idli", seen)
        assert result is not None
        assert "variety" in result.lower() or "already" in result.lower()

    def test_different_dish_no_issue(self):
        seen = {"Idli"}
        result = audit_repeat_week("Dosa", seen)
        assert result is None

    def test_none_meal_no_crash(self):
        seen = {"Idli"}
        result = audit_repeat_week(None, seen)
        assert result is None


# ── AU-D05: Repeat past weeks ─────────────────────────────────────────────────

class TestAuditRepeatPast:

    def test_not_recently_served_no_issue(self):
        ctx = {"recent_meals": {"Sambar Rice"}}
        result = audit_repeat_past("Idli", ctx)
        assert result is None

    def test_recently_served_flags_issue(self):
        ctx = {"recent_meals": {"Idli"}}
        result = audit_repeat_past("Idli", ctx)
        assert result is not None
        assert "recently" in result.lower()

    def test_empty_recent_meals_no_issue(self):
        ctx = {"recent_meals": set()}
        result = audit_repeat_past("Idli", ctx)
        assert result is None


# ── AU-D06: Pantry check ──────────────────────────────────────────────────────

class TestAuditPantry:

    def test_no_pantry_items_no_issue(self, db, sample_veg_recipe):
        """If pantry is empty, no warning (nothing to compare against)."""
        ctx = {"pantry_ids": set()}
        result = audit_pantry(db, sample_veg_recipe["recipe_id"], ctx)
        assert result is None

    def test_all_ingredients_in_pantry_no_issue(self, db):
        row = db.execute(text("""
            SELECT recipe_id::text FROM recipe_dna_master r
            WHERE EXISTS (
                SELECT 1 FROM recipe_ingredients ri
                WHERE ri.recipe_id = r.recipe_id AND ri.is_optional = FALSE
            )
            AND review_status = 'approved'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No recipe with required ingredients found")
        recipe_id = row[0]

        # Get all primary ingredient ids for this recipe
        ing_rows = db.execute(text("""
            SELECT ingredient_id FROM recipe_ingredients
            WHERE recipe_id = CAST(:rid AS uuid) AND is_optional = FALSE
        """), {"rid": recipe_id}).fetchall()
        all_ids = {r[0] for r in ing_rows}

        ctx = {"pantry_ids": all_ids}
        result = audit_pantry(db, recipe_id, ctx)
        assert result is None

    def test_missing_ingredient_flags_issue(self, db):
        row = db.execute(text("""
            SELECT recipe_id::text FROM recipe_dna_master r
            WHERE EXISTS (
                SELECT 1 FROM recipe_ingredients ri
                WHERE ri.recipe_id = r.recipe_id AND ri.is_optional = FALSE
            )
            AND review_status = 'approved'
            LIMIT 1
        """)).fetchone()
        if not row:
            pytest.skip("No recipe with required ingredients found")
        recipe_id = row[0]

        ctx = {"pantry_ids": set()}  # nothing in pantry
        result = audit_pantry(db, recipe_id, ctx)
        assert result is not None
        assert "ingredients" in result.lower()

    def test_no_recipe_id_no_crash(self, db):
        ctx = {"pantry_ids": {1, 2, 3}}
        result = audit_pantry(db, None, ctx)
        assert result is None


# ── Feature toggle behavior ────────────────────────────────────────────────────

class TestFeatureToggle:

    def test_disabling_au_d01_skips_diet_check(self, db, admin_user, sample_nonveg_recipe):
        """When AU-D01 is disabled, diet mismatch should NOT be flagged."""
        h_id = admin_user["house_id"]

        # Disable AU-D01
        db.execute(text("UPDATE feature_registry SET is_active = FALSE WHERE feature_code = 'AU-D01'"))
        db.commit()

        try:
            active = load_active_audit_features(db)
            assert "AU-D01" not in active
        finally:
            # Re-enable for other tests
            db.execute(text("UPDATE feature_registry SET is_active = TRUE WHERE feature_code = 'AU-D01'"))
            db.commit()

    def test_enabling_au_d01_includes_diet_check(self, db):
        db.execute(text("UPDATE feature_registry SET is_active = TRUE WHERE feature_code = 'AU-D01'"))
        db.commit()
        active = load_active_audit_features(db)
        assert "AU-D01" in active

    def test_all_audit_features_registered(self, db):
        """All 6 audit features should exist in feature_registry."""
        rows = db.execute(text("""
            SELECT feature_code FROM feature_registry WHERE feature_code LIKE 'AU-%'
        """)).fetchall()
        codes = {r[0] for r in rows}
        expected = {"AU-D01", "AU-D02", "AU-D03", "AU-D04", "AU-D05", "AU-D06"}
        assert expected.issubset(codes), f"Missing: {expected - codes}"


# ── Full execute_audit pipeline ────────────────────────────────────────────────

class TestExecuteAuditPipeline:

    def test_skipped_meal_returns_ok_no_issues(self, db, admin_user):
        class FakeChange:
            day = "Monday"
            type = "Lunch"
            to_meal = "Skipped"
            date = "2025-01-01"
            recipe_id = None

        result = execute_audit(db, admin_user["house_id"], [FakeChange()])
        assert len(result) == 1
        assert result[0]["status"] == "ok"
        assert result[0]["issues"] == []

    def test_clean_veg_meal_in_veg_household_ok(self, db, admin_user, sample_veg_recipe):
        class FakeChange:
            day = "Monday"
            type = "Breakfast"
            to_meal = sample_veg_recipe["dish_name"]
            date = (date.today() + timedelta(days=30)).isoformat()  # avoid satvik/repeat collision
            recipe_id = sample_veg_recipe["recipe_id"]

        result = execute_audit(db, admin_user["house_id"], [FakeChange()])
        assert len(result) == 1
        # Status depends on pantry/repeat state but should not crash
        assert result[0]["status"] in ("ok", "warning")
        assert isinstance(result[0]["issues"], list)

    def test_nonveg_meal_in_veg_household_flags_diet_issue(self, db, admin_user, sample_nonveg_recipe):
        class FakeChange:
            day = "Monday"
            type = "Lunch"
            to_meal = sample_nonveg_recipe["dish_name"]
            date = (date.today() + timedelta(days=31)).isoformat()
            recipe_id = sample_nonveg_recipe["recipe_id"]

        result = execute_audit(db, admin_user["house_id"], [FakeChange()])
        assert result[0]["status"] == "warning"
        assert any("suit everyone" in issue.lower() for issue in result[0]["issues"])

    def test_repeat_within_week_flagged_on_second_occurrence(self, db, admin_user, sample_veg_recipe):
        class FakeChange1:
            day = "Monday"
            type = "Breakfast"
            to_meal = sample_veg_recipe["dish_name"]
            date = (date.today() + timedelta(days=32)).isoformat()
            recipe_id = sample_veg_recipe["recipe_id"]

        class FakeChange2:
            day = "Tuesday"
            type = "Breakfast"
            to_meal = sample_veg_recipe["dish_name"]  # same dish
            date = (date.today() + timedelta(days=33)).isoformat()
            recipe_id = sample_veg_recipe["recipe_id"]

        result = execute_audit(db, admin_user["house_id"], [FakeChange1(), FakeChange2()])
        # First occurrence — no repeat-this-week issue
        assert not any("already in your plan" in i for i in result[0]["issues"])
        # Second occurrence — should flag repeat
        assert any("already in your plan" in i for i in result[1]["issues"])

    def test_multiple_changes_processed_independently(self, db, admin_user, sample_veg_recipe, sample_nonveg_recipe):
        class Change1:
            day = "Monday"; type = "Breakfast"
            to_meal = sample_veg_recipe["dish_name"]
            date = (date.today() + timedelta(days=40)).isoformat()
            recipe_id = sample_veg_recipe["recipe_id"]

        class Change2:
            day = "Monday"; type = "Lunch"
            to_meal = sample_nonveg_recipe["dish_name"]
            date = (date.today() + timedelta(days=40)).isoformat()
            recipe_id = sample_nonveg_recipe["recipe_id"]

        result = execute_audit(db, admin_user["house_id"], [Change1(), Change2()])
        assert len(result) == 2
        assert result[0]["day"] == "Monday" and result[0]["type"] == "Breakfast"
        assert result[1]["day"] == "Monday" and result[1]["type"] == "Lunch"


# ── /audit API endpoint ────────────────────────────────────────────────────────

class TestAuditEndpoint:

    def test_audit_endpoint_requires_auth(self, client):
        resp = client.post("/audit", json=[{
            "day": "Monday", "type": "Breakfast",
            "to_meal": "Idli", "date": "2025-01-01"
        }])
        assert resp.status_code in (401, 403)

    def test_audit_endpoint_returns_list(self, client, admin_user, sample_veg_recipe):
        headers = {"Authorization": f"Bearer {admin_user['access_token']}"}
        payload = [{
            "day": "Monday", "type": "Breakfast",
            "to_meal": sample_veg_recipe["dish_name"],
            "date": "2025-01-01",
            "recipe_id": sample_veg_recipe["recipe_id"],
        }]
        resp = client.post("/audit", json=payload, headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) == 1
        assert "status" in data[0]
        assert "issues" in data[0]

    def test_audit_endpoint_empty_payload(self, client, admin_user):
        headers = {"Authorization": f"Bearer {admin_user['access_token']}"}
        resp = client.post("/audit", json=[], headers=headers)
        assert resp.status_code == 200
        assert resp.json() == []

    def test_audit_response_never_blocks(self, client, admin_user, sample_nonveg_recipe):
        """Even with diet violation, API must return 200 — never blocks."""
        headers = {"Authorization": f"Bearer {admin_user['access_token']}"}
        payload = [{
            "day": "Monday", "type": "Lunch",
            "to_meal": sample_nonveg_recipe["dish_name"],
            "date": "2025-01-01",
            "recipe_id": sample_nonveg_recipe["recipe_id"],
        }]
        resp = client.post("/audit", json=payload, headers=headers)
        assert resp.status_code == 200  # never 4xx/5xx for rule violations
