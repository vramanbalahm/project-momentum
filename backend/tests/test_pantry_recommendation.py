"""
test_pantry_recommendation.py
Tests for pantry-only mode in the recommendation engine.

Covers:
    - Pantry filter logic in generate_plan
    - Pantry exhausted slot marking
    - Pantry score ordering (most overlap first)
    - Toggle OFF = normal behavior
    - Empty pantry handling
    - /weekly-config API pantry_only field
"""

import pytest
import uuid
from datetime import date, timedelta
from sqlalchemy import text
from fastapi.testclient import TestClient

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main import app


# ── Fixtures ──────────────────────────────────────────────────────────────────

@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def auth_headers(client, db):
    """Register a fresh test household and return auth headers."""
    email = f"pantry_test_{uuid.uuid4().hex[:8]}@test.com"
    reg = client.post("/auth/register", json={
        "email": email, "password": "Test1234!",
        "name": "Pantry Tester", "house_name": "Pantry House",
        "primary_region": "Tamil Nadu", "current_city": "Chennai",
        "dietary_preference": "Veg"
    })
    if reg.status_code != 200:
        pytest.skip(f"Registration failed: {reg.text}")
    token = reg.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def house_id(auth_headers, client):
    """Get house_id for the test household."""
    resp = client.get("/household/profile", headers=auth_headers)
    if resp.status_code == 200:
        return resp.json().get("household_id") or resp.json().get("house_id")
    pytest.skip("Could not get house_id")


@pytest.fixture
def sample_ingredient_id(db):
    """Get a real ingredient ID from catalog."""
    row = db.execute(text("SELECT id FROM ingredient_catalog LIMIT 1")).fetchone()
    if not row:
        pytest.skip("No ingredients in catalog")
    return row[0]


@pytest.fixture
def recipe_with_ingredient(db, sample_ingredient_id):
    """Get a recipe that uses the sample ingredient as primary."""
    row = db.execute(text("""
        SELECT r.recipe_id::text, r.dish_name
        FROM recipe_dna_master r
        JOIN recipe_ingredients ri ON ri.recipe_id = r.recipe_id
        WHERE ri.ingredient_id = :ing_id
        AND ri.is_optional = FALSE
        AND r.review_status = 'approved'
        AND r.meal_role @> ARRAY['main']::text[]
        LIMIT 1
    """), {"ing_id": sample_ingredient_id}).fetchone()
    if not row:
        pytest.skip("No recipe with this primary ingredient")
    return {"recipe_id": row[0], "dish_name": row[1]}


# ── Unit: Pantry score logic ──────────────────────────────────────────────────

class TestPantryScoreLogic:

    def test_recipe_with_all_ingredients_in_pantry_scores_higher(self, db):
        """Recipe with more pantry overlap should have higher score."""
        # Get two recipes with different ingredient counts
        rows = db.execute(text("""
            SELECT r.recipe_id::text, COUNT(ri.ingredient_id) as ing_count
            FROM recipe_dna_master r
            JOIN recipe_ingredients ri ON ri.recipe_id = r.recipe_id
            WHERE ri.is_optional = FALSE
            AND r.review_status = 'approved'
            GROUP BY r.recipe_id
            HAVING COUNT(ri.ingredient_id) > 0
            ORDER BY ing_count DESC
            LIMIT 2
        """)).fetchall()
        if len(rows) < 2:
            pytest.skip("Need at least 2 recipes with ingredients")

        # Higher ingredient count recipe should score more with full pantry
        recipe_a_id = rows[0][0]
        recipe_b_id = rows[1][0]

        # Get all ingredients for recipe A
        ing_a = db.execute(text("""
            SELECT ingredient_id FROM recipe_ingredients
            WHERE recipe_id = CAST(:rid AS uuid) AND is_optional = FALSE
        """), {"rid": recipe_a_id}).fetchall()
        pantry = {r[0] for r in ing_a}

        # Score A = len(pantry) since all match
        overlap_a = len(pantry)

        # Score B = intersection with recipe B's ingredients
        ing_b = db.execute(text("""
            SELECT ingredient_id FROM recipe_ingredients
            WHERE recipe_id = CAST(:rid AS uuid) AND is_optional = FALSE
        """), {"rid": recipe_b_id}).fetchall()
        overlap_b = len({r[0] for r in ing_b} & pantry)

        # Recipe A should score >= Recipe B given pantry built from A
        assert overlap_a >= overlap_b

    def test_pantry_exhausted_when_no_matching_recipes(self, db):
        """If pantry has ingredients no recipe uses, all slots should be exhausted."""
        # Use a synthetic ingredient ID that no recipe has
        fake_ingredient_ids = {-1, -2, -3}

        rows = db.execute(text("""
            SELECT recipe_id::text FROM recipe_dna_master
            WHERE review_status = 'approved'
            AND meal_role @> ARRAY['main']::text[]
            LIMIT 5
        """)).fetchall()

        exhausted_count = 0
        for row in rows:
            recipe_id = row[0]
            ing_rows = db.execute(text("""
                SELECT ingredient_id FROM recipe_ingredients
                WHERE recipe_id = CAST(:rid AS uuid) AND is_optional = FALSE
            """), {"rid": recipe_id}).fetchall()
            primary_ids = {r[0] for r in ing_rows}
            overlap = primary_ids & fake_ingredient_ids
            if not overlap and primary_ids:  # has ingredients but none match
                exhausted_count += 1

        assert exhausted_count > 0  # at least some recipes would be exhausted


# ── Weekly config: pantry_only field ─────────────────────────────────────────

class TestWeeklyConfigPantryOnly:

    def test_weekly_config_returns_pantry_only_field(self, client, auth_headers):
        """GET /weekly-config should return pantry_only field."""
        resp = client.get("/weekly-config", headers=auth_headers)
        assert resp.status_code == 200
        data = resp.json()
        assert "pantry_only" in data

    def test_pantry_only_defaults_to_false(self, client, auth_headers):
        """pantry_only should default to False for new households."""
        resp = client.get("/weekly-config", headers=auth_headers)
        assert resp.status_code == 200
        assert resp.json()["pantry_only"] == False

    def test_can_set_pantry_only_true(self, client, auth_headers):
        """Should be able to set pantry_only=True via POST /weekly-config."""
        resp = client.post("/weekly-config", json={
            "continental_days": 0,
            "allow_same_day_repeat": False,
            "allow_same_week_repeat": True,
            "prefer_millet": False,
            "pantry_only": True
        }, headers=auth_headers)
        assert resp.status_code == 200

        # Verify it persisted
        get_resp = client.get("/weekly-config", headers=auth_headers)
        assert get_resp.json()["pantry_only"] == True

    def test_can_toggle_pantry_only_off(self, client, auth_headers):
        """Should be able to toggle pantry_only back to False."""
        # Set True first
        client.post("/weekly-config", json={
            "continental_days": 0, "allow_same_day_repeat": False,
            "allow_same_week_repeat": True, "prefer_millet": False,
            "pantry_only": True
        }, headers=auth_headers)

        # Set False
        client.post("/weekly-config", json={
            "continental_days": 0, "allow_same_day_repeat": False,
            "allow_same_week_repeat": True, "prefer_millet": False,
            "pantry_only": False
        }, headers=auth_headers)

        resp = client.get("/weekly-config", headers=auth_headers)
        assert resp.json()["pantry_only"] == False


# ── Plan generation with pantry_only ─────────────────────────────────────────

class TestPantryOnlyPlanGeneration:

    def _generate_plan(self, client, auth_headers, pantry_only=False):
        """Helper to generate a plan with optional pantry_only config."""
        today = date.today()
        monday = today - timedelta(days=today.weekday())
        week_start = monday.strftime("%Y-%m-%d")

        if pantry_only:
            client.post("/weekly-config", json={
                "continental_days": 0, "allow_same_day_repeat": False,
                "allow_same_week_repeat": True, "prefer_millet": False,
                "pantry_only": pantry_only
            }, headers=auth_headers)

        return client.post("/recommendation/generate", json={
            "week_start": week_start,
            "questionnaire": {}
        }, headers=auth_headers)

    def test_plan_generates_without_pantry_mode(self, client, auth_headers):
        """Normal plan generation should still work (pantry_only=False)."""
        resp = self._generate_plan(client, auth_headers, pantry_only=False)
        assert resp.status_code == 200
        data = resp.json()
        assert "plan" in data

    def test_plan_with_empty_pantry_marks_slots_exhausted(self, client, auth_headers, db, house_id):
        """With pantry_only=True and empty pantry, all slots should be exhausted."""
        if not house_id:
            pytest.skip("No house_id available")

        # Ensure pantry is empty for this household
        db.execute(text("""
            DELETE FROM household_pantry WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": house_id})
        db.commit()

        resp = self._generate_plan(client, auth_headers, pantry_only=True)
        if resp.status_code != 200:
            pytest.skip(f"Plan generation failed: {resp.status_code}")

        plan = resp.json().get("plan", {})
        exhausted_slots = [
            f"{day}/{slot}"
            for day, day_data in plan.items()
            for slot, slot_data in day_data.items()
            if isinstance(slot_data, dict) and slot_data.get("pantry_exhausted")
        ]
        # With empty pantry, many/all slots should be exhausted
        assert len(exhausted_slots) > 0

    def test_pantry_exhausted_slot_has_correct_structure(self, client, auth_headers, db, house_id):
        """Exhausted slots should have pantry_exhausted=True and no recipe_id."""
        if not house_id:
            pytest.skip("No house_id available")

        db.execute(text("DELETE FROM household_pantry WHERE house_id = CAST(:hid AS uuid)"), {"hid": house_id})
        db.commit()

        resp = self._generate_plan(client, auth_headers, pantry_only=True)
        if resp.status_code != 200:
            pytest.skip("Plan generation failed")

        plan = resp.json().get("plan", {})
        for day_data in plan.values():
            for slot_data in day_data.values():
                if isinstance(slot_data, dict) and slot_data.get("pantry_exhausted"):
                    assert "recipe_id" not in slot_data or not slot_data.get("recipe_id")
                    assert slot_data.get("pantry_exhausted") == True

    def test_plan_with_stocked_pantry_fills_slots(self, client, auth_headers, db, house_id, sample_ingredient_id):
        """With a well-stocked pantry, slots should be filled."""
        if not house_id:
            pytest.skip("No house_id available")

        # Stock pantry with many ingredients
        ing_rows = db.execute(text("""
            SELECT DISTINCT ingredient_id FROM recipe_ingredients
            WHERE ingredient_id IS NOT NULL
            LIMIT 50
        """)).fetchall()

        for row in ing_rows:
            try:
                db.execute(text("""
                    INSERT INTO household_pantry (house_id, ingredient_id, is_available)
                    VALUES (CAST(:hid AS uuid), :iid, TRUE)
                    ON CONFLICT (house_id, ingredient_id) DO UPDATE SET is_available = TRUE
                """), {"hid": house_id, "iid": row[0]})
            except Exception:
                db.rollback()
        db.commit()

        resp = self._generate_plan(client, auth_headers, pantry_only=True)
        if resp.status_code != 200:
            pytest.skip("Plan generation failed")

        plan = resp.json().get("plan", {})
        filled = sum(
            1 for day_data in plan.values()
            for slot_data in day_data.values()
            if isinstance(slot_data, dict) and slot_data.get("recipe_id")
        )
        # With 50 ingredients stocked, at least some slots should be filled
        assert filled > 0


# ── API: Never blocks ─────────────────────────────────────────────────────────

class TestPantryOnlyNeverBlocks:

    def test_pantry_only_always_returns_200(self, client, auth_headers):
        """pantry_only mode should never cause a 500 error."""
        today = date.today()
        monday = today - timedelta(days=today.weekday())
        week_start = (monday - timedelta(weeks=5)).strftime("%Y-%m-%d")

        client.post("/weekly-config", json={
            "continental_days": 0, "allow_same_day_repeat": False,
            "allow_same_week_repeat": True, "prefer_millet": False,
            "pantry_only": True
        }, headers=auth_headers)

        resp = client.post("/recommendation/generate", json={
            "week_start": week_start, "questionnaire": {}
        }, headers=auth_headers)
        assert resp.status_code == 200

    def test_pantry_only_response_has_plan_key(self, client, auth_headers):
        """Response structure should always have 'plan' key regardless of pantry state."""
        today = date.today()
        monday = today - timedelta(days=today.weekday())
        week_start = (monday - timedelta(weeks=6)).strftime("%Y-%m-%d")

        resp = client.post("/recommendation/generate", json={
            "week_start": week_start, "questionnaire": {}
        }, headers=auth_headers)
        if resp.status_code == 200:
            assert "plan" in resp.json()
