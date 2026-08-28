"""
test_household_recipes.py
Tests for the household quick-entry recipe feature.

Covers:
    - POST /recipes/quick-entry (creation, validation, dedup)
    - Candidate-pool scoping: household-private dish visible only to its
      own household, never to another household
    - Reviewer-queue exclusion: household-private dishes never appear in
      /recipes/review or reviewer_progress totals
    - Permission model on GET/PUT /recipes/{recipe_id}/detail|review:
      owner can access their own dish, another household cannot,
      reviewer/admin can access any recipe
    - Defensive guards: mark-pending refuses a household dish,
      bulk-approve never touches one
"""

import pytest
import uuid
from sqlalchemy import text


def unique_email(prefix="test"):
    return f"{prefix}_{uuid.uuid4().hex[:8]}@momentum-test.com"


# ── Fixtures specific to this file ──────────────────────────────────────────

@pytest.fixture
def other_admin(client, db):
    """
    A second, independent household + admin user -- for testing that one
    household's private dish is invisible to another household.
    Mirrors the admin_user fixture in conftest.py exactly.
    """
    email = unique_email("other_admin")
    password = "OtherPass1!"
    payload = {
        "email": email,
        "password": password,
        "name": "Other Household Admin",
        "house_name": "Other Test Household",
        "primary_region": "Tamil Nadu",
        "current_city": "Chennai",
        "dietary_preference": "Veg"
    }
    resp = client.post("/auth/register", json=payload)
    assert resp.status_code == 200, f"Other admin register failed: {resp.text}"

    tokens = resp.json()
    access_token = tokens["access_token"]

    me_resp = client.get("/auth/me", headers={"Authorization": f"Bearer {access_token}"})
    assert me_resp.status_code == 200
    me = me_resp.json()

    yield {
        "email": email,
        "password": password,
        "access_token": access_token,
        "house_id": me["house_id"],
        "user_id": me["user_id"],
    }

    db.execute(text("DELETE FROM refresh_tokens WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM users WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM household_master WHERE household_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.commit()


@pytest.fixture
def reviewer_user(client, db):
    """A platform_admin user, for permission tests against the reviewer path."""
    email = unique_email("reviewer")
    password = "ReviewerPass1!"
    payload = {
        "email": email, "password": password, "name": "Test Reviewer",
        "house_name": "Reviewer Household", "primary_region": "Tamil Nadu",
        "current_city": "Chennai", "dietary_preference": "Veg"
    }
    resp = client.post("/auth/register", json=payload)
    assert resp.status_code == 200
    tokens = resp.json()
    me = client.get("/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"}).json()

    db.execute(text("UPDATE users SET role = 'platform_admin' WHERE user_id = CAST(:uid AS uuid)"), {"uid": me["user_id"]})
    db.commit()

    yield {"access_token": tokens["access_token"], "house_id": me["house_id"], "user_id": me["user_id"]}

    db.execute(text("DELETE FROM refresh_tokens WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM users WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM household_master WHERE household_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.commit()


@pytest.fixture
def sample_ingredient(db):
    """A real ingredient from the catalog, for use as the mandatory main ingredient."""
    row = db.execute(text("SELECT id, name_en FROM ingredient_catalog ORDER BY id LIMIT 1")).fetchone()
    if not row:
        pytest.skip("No ingredients found in ingredient_catalog")
    return {"id": row[0], "name_en": row[1]}


@pytest.fixture
def quick_dish(client, admin_user, sample_ingredient, db):
    """
    Creates one quick-entry dish for admin_user's household via the real
    API, and cleans it up afterward (before admin_user's own household
    teardown runs, so the created_by_house_id FK never dangles).
    """
    resp = client.post("/recipes/quick-entry",
        json={
            "dish_name": f"Test Quick Dish {uuid.uuid4().hex[:6]}",
            "main_ingredient_id": sample_ingredient["id"],
            "diet_type": "Veg",
        },
        headers={"Authorization": f"Bearer {admin_user['access_token']}"}
    )
    assert resp.status_code == 200, f"quick_dish fixture setup failed: {resp.text}"
    data = resp.json()

    yield data

    db.execute(text("DELETE FROM recipe_ingredients WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": data["recipe_id"]})
    db.execute(text("DELETE FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": data["recipe_id"]})
    db.commit()


# ── POST /recipes/quick-entry ────────────────────────────────────────────────

class TestQuickEntryCreation:

    def test_create_success(self, client, admin_user, sample_ingredient):
        resp = client.post("/recipes/quick-entry",
            json={
                "dish_name": f"Amma's Special {uuid.uuid4().hex[:6]}",
                "main_ingredient_id": sample_ingredient["id"],
                "diet_type": "Veg",
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["created"] is True
        assert "recipe_id" in data

    def test_missing_dish_name(self, client, admin_user, sample_ingredient):
        resp = client.post("/recipes/quick-entry",
            json={"dish_name": "", "main_ingredient_id": sample_ingredient["id"], "diet_type": "Veg"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 400

    def test_missing_main_ingredient(self, client, admin_user):
        resp = client.post("/recipes/quick-entry",
            json={"dish_name": "No Ingredient Dish", "diet_type": "Veg"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 400

    def test_invalid_diet_type(self, client, admin_user, sample_ingredient):
        resp = client.post("/recipes/quick-entry",
            json={
                "dish_name": "Bad Diet Dish",
                "main_ingredient_id": sample_ingredient["id"],
                "diet_type": "Carnivore",
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 400

    def test_nonexistent_ingredient_id(self, client, admin_user):
        resp = client.post("/recipes/quick-entry",
            json={"dish_name": "Ghost Ingredient Dish", "main_ingredient_id": 999999999, "diet_type": "Veg"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 400

    def test_duplicate_name_returns_existing(self, client, admin_user, sample_ingredient, db):
        dish_name = f"Duplicate Test {uuid.uuid4().hex[:6]}"
        payload = {"dish_name": dish_name, "main_ingredient_id": sample_ingredient["id"], "diet_type": "Veg"}
        headers = {"Authorization": f"Bearer {admin_user['access_token']}"}

        first = client.post("/recipes/quick-entry", json=payload, headers=headers)
        assert first.status_code == 200
        assert first.json()["created"] is True
        recipe_id = first.json()["recipe_id"]

        second = client.post("/recipes/quick-entry", json=payload, headers=headers)
        assert second.status_code == 200
        assert second.json()["created"] is False
        assert second.json()["recipe_id"] == recipe_id

        db.execute(text("DELETE FROM recipe_ingredients WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": recipe_id})
        db.execute(text("DELETE FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": recipe_id})
        db.commit()

    def test_created_dish_is_approved_and_owned(self, quick_dish, admin_user, db):
        """DB-level check: created_by_house_id set correctly, auto-approved, no reviewer stamp."""
        row = db.execute(text("""
            SELECT created_by_house_id, review_status, reviewed_by
            FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)
        """), {"rid": quick_dish["recipe_id"]}).fetchone()
        assert str(row.created_by_house_id) == admin_user["house_id"]
        assert row.review_status == "approved"
        assert row.reviewed_by is None

    def test_main_ingredient_is_mandatory(self, quick_dish, sample_ingredient, db):
        """The main ingredient must be inserted with is_optional = FALSE."""
        row = db.execute(text("""
            SELECT is_optional FROM recipe_ingredients
            WHERE recipe_id = CAST(:rid AS uuid) AND ingredient_id = :iid
        """), {"rid": quick_dish["recipe_id"], "iid": sample_ingredient["id"]}).fetchone()
        assert row is not None
        assert row.is_optional is False


# ── Candidate-pool scoping ───────────────────────────────────────────────────

class TestSearchScoping:

    def test_own_household_sees_own_quick_dish(self, client, admin_user, quick_dish):
        resp = client.get(f"/recipes/search?q={quick_dish['dish_name']}",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert resp.status_code == 200
        names = [r["name"] for r in resp.json()]
        assert quick_dish["dish_name"] in names

    def test_other_household_cannot_see_quick_dish(self, client, other_admin, quick_dish):
        resp = client.get(f"/recipes/search?q={quick_dish['dish_name']}",
            headers={"Authorization": f"Bearer {other_admin['access_token']}"})
        assert resp.status_code == 200
        names = [r["name"] for r in resp.json()]
        assert quick_dish["dish_name"] not in names

    def test_shared_vault_dish_visible_to_both_households(self, client, admin_user, other_admin):
        """Sanity check the scoping logic is additive, not exclusive --
        a real shared-vault dish should still show for every household."""
        shared = client.get("/recipes/search?q=&is_side_dish=false",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert shared.status_code == 200
        if not shared.json():
            pytest.skip("No shared vault recipes available to check against")
        sample_name = shared.json()[0]["name"]

        other_view = client.get(f"/recipes/search?q={sample_name}",
            headers={"Authorization": f"Bearer {other_admin['access_token']}"})
        assert other_view.status_code == 200
        assert any(r["name"] == sample_name for r in other_view.json())


# ── Reviewer queue exclusion ─────────────────────────────────────────────────

class TestReviewerQueueExclusion:

    def test_quick_dish_not_in_review_pending_list(self, client, reviewer_user, quick_dish):
        resp = client.get("/recipes/review?status=all",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert resp.status_code == 200
        names = [r["dish_name"] for r in resp.json()["recipes"]]
        assert quick_dish["dish_name"] not in names

    def test_quick_dish_not_found_via_review_search(self, client, reviewer_user, quick_dish):
        """The cross-status q= search path also must not leak household dishes."""
        resp = client.get(f"/recipes/review?q={quick_dish['dish_name']}",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert resp.status_code == 200
        names = [r["dish_name"] for r in resp.json()["recipes"]]
        assert quick_dish["dish_name"] not in names

    def test_reviewer_totals_unaffected_by_quick_dish(self, client, reviewer_user, admin_user, sample_ingredient):
        before = client.get("/recipes/reviewer-progress",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        if before.status_code != 200:
            pytest.skip("reviewer-progress endpoint path differs -- check route name")
        total_before = before.json()["totals"]["total"]

        create = client.post("/recipes/quick-entry",
            json={"dish_name": f"Totals Test {uuid.uuid4().hex[:6]}",
                  "main_ingredient_id": sample_ingredient["id"], "diet_type": "Veg"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert create.status_code == 200
        recipe_id = create.json()["recipe_id"]

        after = client.get("/recipes/reviewer-progress",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert after.json()["totals"]["total"] == total_before

        # cleanup
        from database import SessionLocal
        db = SessionLocal()
        db.execute(text("DELETE FROM recipe_ingredients WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": recipe_id})
        db.execute(text("DELETE FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)"), {"rid": recipe_id})
        db.commit()
        db.close()


# ── GET/PUT recipe detail permission model ──────────────────────────────────

class TestRecipeDetailPermission:

    def test_owner_can_view_own_dish(self, client, admin_user, quick_dish):
        resp = client.get(f"/recipes/{quick_dish['recipe_id']}/detail",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert resp.status_code == 200
        assert resp.json()["dish_name"] == quick_dish["dish_name"]

    def test_other_household_cannot_view_dish(self, client, other_admin, quick_dish):
        resp = client.get(f"/recipes/{quick_dish['recipe_id']}/detail",
            headers={"Authorization": f"Bearer {other_admin['access_token']}"})
        assert resp.status_code == 403

    def test_reviewer_can_view_any_household_dish(self, client, reviewer_user, quick_dish):
        resp = client.get(f"/recipes/{quick_dish['recipe_id']}/detail",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert resp.status_code == 200

    def test_nonexistent_recipe_404(self, client, admin_user):
        fake_id = str(uuid.uuid4())
        resp = client.get(f"/recipes/{fake_id}/detail",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert resp.status_code == 404


class TestUpdateRecipeReviewPermission:

    def test_owner_can_update_own_dish_name(self, client, admin_user, quick_dish):
        new_name = f"Renamed {uuid.uuid4().hex[:6]}"
        resp = client.put(f"/recipes/{quick_dish['recipe_id']}/review",
            json={"dish_name": new_name},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert resp.status_code == 200

        check = client.get(f"/recipes/{quick_dish['recipe_id']}/detail",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})
        assert check.json()["dish_name"] == new_name

    def test_owner_cannot_change_review_status(self, client, admin_user, quick_dish, db):
        """review_status is a reviewer-pipeline field -- owner edits must not touch it."""
        client.put(f"/recipes/{quick_dish['recipe_id']}/review",
            json={"dish_name": quick_dish["dish_name"], "review_status": "rejected"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"})

        row = db.execute(text("""
            SELECT review_status, reviewed_by FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)
        """), {"rid": quick_dish["recipe_id"]}).fetchone()
        assert row.review_status == "approved"
        assert row.reviewed_by is None

    def test_other_household_cannot_update_dish(self, client, other_admin, quick_dish):
        resp = client.put(f"/recipes/{quick_dish['recipe_id']}/review",
            json={"dish_name": "Hijacked Name"},
            headers={"Authorization": f"Bearer {other_admin['access_token']}"})
        assert resp.status_code == 403


# ── Defensive guards ─────────────────────────────────────────────────────────

class TestMarkPendingGuard:

    def test_refuses_household_dish(self, client, reviewer_user, quick_dish, db):
        """Platform admin trying to reset a household-private dish to
        under_review should be refused -- it doesn't belong in that pipeline."""
        # reviewer_user fixture is platform_admin role
        resp = client.post(f"/recipes/{quick_dish['recipe_id']}/mark-pending",
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert resp.status_code == 400

        row = db.execute(text("""
            SELECT review_status FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)
        """), {"rid": quick_dish["recipe_id"]}).fetchone()
        assert row.review_status == "approved"


class TestBulkApproveGuard:

    def test_bulk_approve_does_not_touch_household_dish(self, client, reviewer_user, quick_dish, db):
        resp = client.post("/recipes/bulk-approve",
            json={"recipe_ids": [quick_dish["recipe_id"]]},
            headers={"Authorization": f"Bearer {reviewer_user['access_token']}"})
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT reviewed_by FROM recipe_dna_master WHERE recipe_id = CAST(:rid AS uuid)
        """), {"rid": quick_dish["recipe_id"]}).fetchone()
        # Still no reviewer stamp -- the guarded UPDATE should have matched zero rows
        assert row.reviewed_by is None
