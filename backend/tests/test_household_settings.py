# test_household_settings.py — Household Settings endpoint tests
#
# Covers:
# GET  /onboarding/data          — returns satvik, panchangam, events data
# GET  /onboarding/satvik-ingredients — returns ingredient catalog
# POST /onboarding/satvik        — save satvik restrictions
# POST /onboarding/panchangam    — save panchangam selection
# POST /onboarding/events        — save events
# POST /onboarding/confirm       — mark onboarding complete
#
# Access control:
#   - household_admin can read and write all
#   - household_member can read but cannot write
#   - unauthenticated requests are rejected
#
# Data integrity:
#   - Saved values persist and are returned by GET /onboarding/data
#   - Satvik save replaces all existing restrictions (not append)
#   - Events are appended (not replaced) each POST
#   - Panchangam null clears the selection
#   - Invalid event_type and event_date formats are rejected
#   - Invalid panchangam_type_id returns 404

import pytest
from sqlalchemy import text


# ── Helpers ───────────────────────────────────────────────────────────────────

def auth(user):
    return {"Authorization": f"Bearer {user['access_token']}"}

SAMPLE_EVENT = {
    "event_name":          "Amma's Birthday",
    "event_date":          "03-15",
    "event_type":          "Personal",
    "is_sattvic_required": False,
    "recurring_annual":    True,
    "icon":                "🎂"
}

SATVIK_EVENT = {
    "event_name":          "Karthigai Deepam",
    "event_date":          "11-28",
    "event_type":          "Ritual",
    "is_sattvic_required": True,
    "recurring_annual":    True,
    "icon":                "🪔"
}


# ── GET /onboarding/data ──────────────────────────────────────────────────────

class TestGetOnboardingData:

    def test_admin_can_get_onboarding_data(self, client, admin_user):
        """Admin fetches onboarding data — returns 200 with expected keys."""
        resp = client.get("/onboarding/data", headers=auth(admin_user))
        assert resp.status_code == 200
        data = resp.json()
        assert "satvik" in data
        assert "panchangam_types" in data
        assert "events" in data
        assert "members" in data

    def test_member_can_get_onboarding_data(self, client, member_user):
        """Household member can also read onboarding data — returns 200."""
        resp = client.get("/onboarding/data", headers=auth(member_user))
        assert resp.status_code == 200

    def test_unauthenticated_cannot_get_onboarding_data(self, client):
        """No token returns 401."""
        resp = client.get("/onboarding/data")
        assert resp.status_code == 401

    def test_panchangam_types_list_is_not_empty(self, client, admin_user):
        """panchangam_types list contains at least one entry from seed data."""
        resp = client.get("/onboarding/data", headers=auth(admin_user))
        assert resp.status_code == 200
        assert len(resp.json()["panchangam_types"]) > 0


# ── GET /onboarding/satvik-ingredients ───────────────────────────────────────

class TestGetSatvikIngredients:

    def test_returns_grouped_ingredients(self, client, admin_user):
        """Returns dict grouped by category with ingredient fields."""
        resp = client.get("/onboarding/satvik-ingredients", headers=auth(admin_user))
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, dict)
        # At least one category with at least one ingredient
        assert len(data) > 0
        first_category = next(iter(data.values()))
        assert len(first_category) > 0
        first_item = first_category[0]
        assert "id" in first_item
        assert "name_en" in first_item

    def test_unauthenticated_rejected(self, client):
        """No token returns 401."""
        resp = client.get("/onboarding/satvik-ingredients")
        assert resp.status_code == 401


# ── POST /onboarding/satvik ───────────────────────────────────────────────────

class TestSatvikSettings:

    def _get_first_ingredient_id(self, client, admin_user):
        """Helper — fetch first available ingredient id from catalog."""
        resp = client.get("/onboarding/satvik-ingredients", headers=auth(admin_user))
        data = resp.json()
        first_cat = next(iter(data.values()))
        return first_cat[0]["id"]

    def test_admin_saves_satvik_restrictions(self, client, admin_user):
        """Admin saves satvik restrictions — returns 200 with items_saved count."""
        ing_id = self._get_first_ingredient_id(client, admin_user)
        resp = client.post("/onboarding/satvik",
            json={"restrictions": [{"ingredient_id": ing_id, "is_avoided": True}]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["items_saved"] == 1

    def test_satvik_restrictions_persist(self, client, admin_user, db):
        """Saved satvik restriction is stored in DB."""
        ing_id = self._get_first_ingredient_id(client, admin_user)
        client.post("/onboarding/satvik",
            json={"restrictions": [{"ingredient_id": ing_id, "is_avoided": True}]},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT is_avoided FROM satvik_restrictions
            WHERE house_id = CAST(:hid AS uuid) AND ingredient_id = :iid
        """), {"hid": admin_user["house_id"], "iid": ing_id}).fetchone()
        assert row is not None
        assert row.is_avoided is True

    def test_satvik_save_replaces_existing(self, client, admin_user, db):
        """Saving satvik replaces all previous restrictions — not append."""
        ing_id = self._get_first_ingredient_id(client, admin_user)

        # Save one restriction
        client.post("/onboarding/satvik",
            json={"restrictions": [{"ingredient_id": ing_id, "is_avoided": True}]},
            headers=auth(admin_user)
        )
        # Save empty — should clear all
        client.post("/onboarding/satvik",
            json={"restrictions": []},
            headers=auth(admin_user)
        )
        count = db.execute(text("""
            SELECT COUNT(*) FROM satvik_restrictions
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()
        assert count == 0

    def test_empty_satvik_restrictions_saves_cleanly(self, client, admin_user):
        """Saving empty restrictions returns 200 with items_saved = 0."""
        resp = client.post("/onboarding/satvik",
            json={"restrictions": []},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["items_saved"] == 0

    def test_satvik_marks_wizard_step_done(self, client, admin_user, db):
        """Saving satvik sets wizard_satvik_done = true on household."""
        client.post("/onboarding/satvik",
            json={"restrictions": []},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT wizard_satvik_done FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.wizard_satvik_done is True

    def test_member_cannot_save_satvik(self, client, member_user):
        """Household member cannot save satvik restrictions — returns 403."""
        resp = client.post("/onboarding/satvik",
            json={"restrictions": []},
            headers=auth(member_user)
        )
        assert resp.status_code == 403

    def test_unauthenticated_cannot_save_satvik(self, client):
        """No token returns 401."""
        resp = client.post("/onboarding/satvik",
            json={"restrictions": []}
        )
        assert resp.status_code == 401


# ── POST /onboarding/panchangam ───────────────────────────────────────────────

class TestPanchangamSettings:

    def _get_valid_panchangam_id(self, client, admin_user):
        """Helper — fetch first valid panchangam_type_id from seed data."""
        resp = client.get("/onboarding/data", headers=auth(admin_user))
        types = resp.json()["panchangam_types"]
        return types[0]["id"] if types else None

    def test_admin_saves_panchangam(self, client, admin_user):
        """Admin saves a panchangam selection — returns 200."""
        pid = self._get_valid_panchangam_id(client, admin_user)
        if not pid:
            pytest.skip("No panchangam types in DB")
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pid},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert "saved" in resp.json()["message"].lower()

    def test_panchangam_persists_in_db(self, client, admin_user, db):
        """Saved panchangam is stored in household_master."""
        pid = self._get_valid_panchangam_id(client, admin_user)
        if not pid:
            pytest.skip("No panchangam types in DB")
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pid},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT panchangam_type_id FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.panchangam_type_id == pid

    def test_admin_clears_panchangam(self, client, admin_user, db):
        """Saving null clears the panchangam selection."""
        # First set one
        pid = self._get_valid_panchangam_id(client, admin_user)
        if pid:
            client.post("/onboarding/panchangam",
                json={"panchangam_type_id": pid},
                headers=auth(admin_user)
            )
        # Now clear it
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": None},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        row = db.execute(text("""
            SELECT panchangam_type_id FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.panchangam_type_id is None

    def test_invalid_panchangam_id_returns_404(self, client, admin_user):
        """Non-existent panchangam_type_id returns 404."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": 99999},
            headers=auth(admin_user)
        )
        assert resp.status_code == 404

    def test_member_cannot_save_panchangam(self, client, member_user):
        """Household member cannot save panchangam — returns 403."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": None},
            headers=auth(member_user)
        )
        assert resp.status_code == 403

    def test_unauthenticated_cannot_save_panchangam(self, client):
        """No token returns 401."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": None}
        )
        assert resp.status_code == 401


# ── POST /onboarding/events ───────────────────────────────────────────────────

class TestEventSettings:

    def test_admin_saves_events(self, client, admin_user):
        """Admin saves a list of events — returns 200 with events_saved count."""
        resp = client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["events_saved"] == 1

    def test_multiple_events_saved(self, client, admin_user):
        """Multiple events saved in one call — events_saved matches count."""
        resp = client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT, SATVIK_EVENT]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["events_saved"] == 2

    def test_events_persist_in_db(self, client, admin_user, db):
        """Saved event is stored in event_master with correct fields."""
        client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT]},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT event_name, event_type, is_sattvic_required, recurring_annual, source
            FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
              AND event_name = :name
            ORDER BY created_at DESC
            LIMIT 1
        """), {"hid": admin_user["house_id"], "name": SAMPLE_EVENT["event_name"]}).fetchone()
        assert row is not None
        assert row.event_name == SAMPLE_EVENT["event_name"]
        assert row.event_type == SAMPLE_EVENT["event_type"]
        assert row.is_sattvic_required == SAMPLE_EVENT["is_sattvic_required"]
        assert row.recurring_annual == SAMPLE_EVENT["recurring_annual"]
        assert row.source == "USER"

    def test_satvik_event_stored_correctly(self, client, admin_user, db):
        """Satvik event has is_sattvic_required = true in DB."""
        client.post("/onboarding/events",
            json={"events": [SATVIK_EVENT]},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT is_sattvic_required FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
              AND event_name = :name
            ORDER BY created_at DESC LIMIT 1
        """), {"hid": admin_user["house_id"], "name": SATVIK_EVENT["event_name"]}).fetchone()
        assert row is not None
        assert row.is_sattvic_required is True

    def test_empty_events_list_saves_cleanly(self, client, admin_user):
        """Empty events list returns 200 with events_saved = 0."""
        resp = client.post("/onboarding/events",
            json={"events": []},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["events_saved"] == 0

    def test_invalid_event_type_rejected(self, client, admin_user):
        """Invalid event_type returns 422."""
        bad_event = {**SAMPLE_EVENT, "event_type": "InvalidType"}
        resp = client.post("/onboarding/events",
            json={"events": [bad_event]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 422

    def test_invalid_event_date_format_rejected(self, client, admin_user):
        """Malformed event_date returns 422."""
        bad_event = {**SAMPLE_EVENT, "event_date": "not-a-date"}
        resp = client.post("/onboarding/events",
            json={"events": [bad_event]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 422

    def test_events_marks_wizard_step_done(self, client, admin_user, db):
        """Saving events sets wizard_events_done = true on household."""
        client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT]},
            headers=auth(admin_user)
        )
        row = db.execute(text("""
            SELECT wizard_events_done FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.wizard_events_done is True

    def test_member_cannot_save_events(self, client, member_user):
        """Household member cannot save events — returns 403."""
        resp = client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT]},
            headers=auth(member_user)
        )
        assert resp.status_code == 403

    def test_unauthenticated_cannot_save_events(self, client):
        """No token returns 401."""
        resp = client.post("/onboarding/events",
            json={"events": [SAMPLE_EVENT]}
        )
        assert resp.status_code == 401


# ── POST /onboarding/confirm ──────────────────────────────────────────────────

class TestConfirmOnboarding:

    def test_admin_can_confirm_onboarding(self, client, admin_user):
        """Admin confirms onboarding — returns 200."""
        resp = client.post("/onboarding/confirm", headers=auth(admin_user))
        assert resp.status_code == 200

    def test_confirm_sets_onboarding_done(self, client, admin_user, db):
        """After confirm, household_master.onboarding_done = true."""
        client.post("/onboarding/confirm", headers=auth(admin_user))
        row = db.execute(text("""
            SELECT onboarding_done FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.onboarding_done is True

    def test_member_cannot_confirm_onboarding(self, client, member_user):
        """Household member cannot confirm onboarding — returns 403."""
        resp = client.post("/onboarding/confirm", headers=auth(member_user))
        assert resp.status_code == 403

    def test_unauthenticated_cannot_confirm_onboarding(self, client):
        """No token returns 401."""
        resp = client.post("/onboarding/confirm")
        assert resp.status_code == 401
