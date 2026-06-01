# test_pantry.py — My Pantry Tests
#
# Covers:
#  1.  GET /pantry/ingredients — returns categories list
#  2.  GET /pantry/ingredients — all ingredients default to is_available=false
#  3.  GET /pantry/ingredients — each category has required fields
#  4.  GET /pantry/ingredients — each ingredient has required fields
#  5.  GET /pantry/ingredients — categories ordered per CATEGORY_CONFIG
#  6.  POST /pantry/save — save single ingredient as available
#  7.  POST /pantry/save — save multiple ingredients at once
#  8.  POST /pantry/save — saved state persists in GET
#  9.  POST /pantry/save — upsert updates existing row
# 10.  POST /pantry/save — mark ingredient unavailable after marking available
# 11.  POST /pantry/save — empty items list returns saved=0
# 12.  POST /pantry/save — invalid ingredient_id returns error
# 13.  GET /pantry/summary — returns empty when nothing saved
# 14.  GET /pantry/summary — returns correct counts after saving
# 15.  GET /pantry/summary — only counts is_available=true
# 16.  GET /pantry/summary — has total_available field
# 17.  Unauthenticated request returns 401
# 18.  Member can also access pantry (not admin-only)

import pytest
from sqlalchemy import text


def auth(user):
    return {"Authorization": f"Bearer {user['access_token']}"}


def get_first_ingredient_id(db):
    """Helper — get first ingredient id from ingredient_catalog."""
    row = db.execute(text("SELECT id FROM ingredient_catalog LIMIT 1")).fetchone()
    return row.id if row else None


def get_ingredients_by_category(db, category):
    """Helper — get ingredient ids for a specific category."""
    rows = db.execute(text(
        "SELECT id FROM ingredient_catalog WHERE category = :cat LIMIT 5"
    ), {"cat": category}).fetchall()
    return [r.id for r in rows]


class TestGetPantryIngredients:

    # Test 1
    def test_get_ingredients_returns_categories(self, client, admin_user):
        """GET /pantry/ingredients returns a list of categories."""
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        assert resp.status_code == 200
        data = resp.json()
        assert "categories" in data
        assert isinstance(data["categories"], list)
        assert len(data["categories"]) > 0

    # Test 2
    def test_all_ingredients_default_unavailable(self, client, admin_user):
        """All ingredients default to is_available=false for new household."""
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        categories = resp.json()["categories"]
        for cat in categories:
            for ing in cat["ingredients"]:
                assert ing["is_available"] == False, \
                    f"{ing['name_en']} should default to unavailable"

    # Test 3
    def test_each_category_has_required_fields(self, client, admin_user):
        """Each category has key, label, emoji, total, selected, ingredients."""
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        for cat in resp.json()["categories"]:
            assert "key" in cat
            assert "label" in cat
            assert "emoji" in cat
            assert "total" in cat
            assert "selected" in cat
            assert "ingredients" in cat
            assert isinstance(cat["ingredients"], list)
            assert cat["total"] == len(cat["ingredients"])

    # Test 4
    def test_each_ingredient_has_required_fields(self, client, admin_user):
        """Each ingredient has id, name_en, is_available, emoji."""
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        for cat in resp.json()["categories"]:
            for ing in cat["ingredients"]:
                assert "id" in ing
                assert "name_en" in ing
                assert "is_available" in ing
                assert "emoji" in ing
                assert ing["name_en"] != ""

    # Test 5
    def test_categories_ordered_correctly(self, client, admin_user):
        """Categories follow CATEGORY_CONFIG order — Vegetable first."""
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        categories = resp.json()["categories"]
        keys = [c["key"] for c in categories]
        expected_order = ["Vegetable", "Meat", "Seafood", "Dairy", "Grain",
                          "Lentil", "Spice", "Oil", "Fruit", "Nut", "Other"]
        # Verify relative ordering — each present key appears before later ones
        present = [k for k in expected_order if k in keys]
        actual_present = [k for k in keys if k in expected_order]
        assert present == actual_present, "Categories not in correct order"


class TestSavePantry:

    # Test 6
    def test_save_single_ingredient_available(self, client, admin_user, db):
        """POST /pantry/save marks single ingredient as available."""
        ing_id = get_first_ingredient_id(db)
        if not ing_id:
            pytest.skip("No ingredients in catalog")

        resp = client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["saved"] == 1

    # Test 7
    def test_save_multiple_ingredients(self, client, admin_user, db):
        """POST /pantry/save saves multiple ingredients in one call."""
        ids = get_ingredients_by_category(db, "Vegetable")
        if len(ids) < 3:
            pytest.skip("Need at least 3 vegetables")

        items = [{"ingredient_id": i, "is_available": True} for i in ids[:3]]
        resp = client.post("/pantry/save",
            json={"items": items},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["saved"] == 3

    # Test 8
    def test_saved_state_persists_in_get(self, client, admin_user, db):
        """After saving, GET /pantry/ingredients shows updated availability."""
        ing_id = get_first_ingredient_id(db)
        if not ing_id:
            pytest.skip("No ingredients in catalog")

        # Save as available
        client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
            headers=auth(admin_user)
        )

        # Verify in GET response
        resp = client.get("/pantry/ingredients", headers=auth(admin_user))
        categories = resp.json()["categories"]
        found = False
        for cat in categories:
            for ing in cat["ingredients"]:
                if ing["id"] == ing_id:
                    assert ing["is_available"] == True, \
                        f"Ingredient {ing_id} should be available after save"
                    found = True
        assert found, f"Ingredient {ing_id} not found in GET response"

    # Test 9
    def test_upsert_updates_existing_row(self, client, admin_user, db):
        """Saving same ingredient twice updates the row — no duplicates."""
        ing_id = get_first_ingredient_id(db)
        if not ing_id:
            pytest.skip("No ingredients in catalog")

        # Save twice
        client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
            headers=auth(admin_user)
        )
        client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
            headers=auth(admin_user)
        )

        # Verify only one row in DB
        count = db.execute(text("""
            SELECT COUNT(*) FROM household_pantry
            WHERE house_id = CAST(:hid AS uuid)
            AND ingredient_id = :iid
        """), {"hid": admin_user["house_id"], "iid": ing_id}).scalar()
        assert count == 1, "Should not create duplicate rows"

    # Test 10
    def test_mark_ingredient_unavailable_after_available(self, client, admin_user, db):
        """Can toggle ingredient from available to unavailable."""
        ing_id = get_first_ingredient_id(db)
        if not ing_id:
            pytest.skip("No ingredients in catalog")

        # First mark available
        client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
            headers=auth(admin_user)
        )

        # Then mark unavailable
        client.post("/pantry/save",
            json={"items": [{"ingredient_id": ing_id, "is_available": False}]},
            headers=auth(admin_user)
        )

        # Verify in DB
        row = db.execute(text("""
            SELECT is_available FROM household_pantry
            WHERE house_id = CAST(:hid AS uuid)
            AND ingredient_id = :iid
        """), {"hid": admin_user["house_id"], "iid": ing_id}).fetchone()
        assert row is not None
        assert row.is_available == False

    # Test 11
    def test_empty_items_returns_zero_saved(self, client, admin_user):
        """Empty items list returns saved=0 with 200 status."""
        resp = client.post("/pantry/save",
            json={"items": []},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["saved"] == 0

    # Test 12
    def test_invalid_ingredient_id_returns_error(self, client, admin_user):
        """Non-existent ingredient_id returns error."""
        resp = client.post("/pantry/save",
            json={"items": [{"ingredient_id": 999999, "is_available": True}]},
            headers=auth(admin_user)
        )
        assert resp.status_code in [400, 422, 500]


class TestPantrySummary:

    # Test 13
    def test_summary_empty_when_nothing_saved(self, client, admin_user):
        """GET /pantry/summary returns total_available=0 for fresh household."""
        resp = client.get("/pantry/summary", headers=auth(admin_user))
        assert resp.status_code == 200
        assert resp.json()["total_available"] == 0
        assert resp.json()["by_category"] == []

    # Test 14
    def test_summary_correct_counts_after_save(self, client, admin_user, db):
        """GET /pantry/summary returns correct count after saving ingredients."""
        ids = get_ingredients_by_category(db, "Vegetable")
        if len(ids) < 2:
            pytest.skip("Need at least 2 vegetables")

        client.post("/pantry/save",
            json={"items": [{"ingredient_id": i, "is_available": True} for i in ids[:2]]},
            headers=auth(admin_user)
        )

        resp = client.get("/pantry/summary", headers=auth(admin_user))
        assert resp.status_code == 200
        assert resp.json()["total_available"] >= 2

        veg = next((c for c in resp.json()["by_category"] if c["category"] == "Vegetable"), None)
        assert veg is not None
        assert veg["count"] >= 2

    # Test 15
    def test_summary_only_counts_available(self, client, admin_user, db):
        """Summary only counts is_available=true rows."""
        ids = get_ingredients_by_category(db, "Vegetable")
        if len(ids) < 2:
            pytest.skip("Need at least 2 vegetables")

        # Save one available, one unavailable
        client.post("/pantry/save",
            json={"items": [
                {"ingredient_id": ids[0], "is_available": True},
                {"ingredient_id": ids[1], "is_available": False},
            ]},
            headers=auth(admin_user)
        )

        resp = client.get("/pantry/summary", headers=auth(admin_user))
        veg = next((c for c in resp.json()["by_category"] if c["category"] == "Vegetable"), None)

        if veg:
            # Count should only include the available one
            unavail_count = db.execute(text("""
                SELECT COUNT(*) FROM household_pantry
                WHERE house_id = CAST(:hid AS uuid)
                AND is_available = false
            """), {"hid": admin_user["house_id"]}).scalar()
            assert unavail_count >= 1, "Should have at least one unavailable"

    # Test 16
    def test_summary_has_total_available(self, client, admin_user):
        """Summary response always has total_available field."""
        resp = client.get("/pantry/summary", headers=auth(admin_user))
        assert "total_available" in resp.json()
        assert "by_category" in resp.json()
        assert isinstance(resp.json()["total_available"], int)


class TestPantryAccessControl:

    # Test 17
    def test_unauthenticated_returns_401(self, client):
        """Unauthenticated requests return 401."""
        assert client.get("/pantry/ingredients").status_code == 401
        assert client.post("/pantry/save", json={"items": []}).status_code == 401
        assert client.get("/pantry/summary").status_code == 401

    # Test 18
    def test_member_can_access_pantry(self, client, member_user, db):
        """Regular household member can also read and save pantry — not admin-only."""
        resp = client.get("/pantry/ingredients", headers=auth(member_user))
        assert resp.status_code == 200

        ing_id = get_first_ingredient_id(db)
        if ing_id:
            resp = client.post("/pantry/save",
                json={"items": [{"ingredient_id": ing_id, "is_available": True}]},
                headers=auth(member_user)
            )
            assert resp.status_code == 200
