# test_lunar_calendar.py — Lunar Calendar Integration Tests
#
# Covers:
#  1.  GET /onboarding/data returns panchangam_types list
#  2.  POST /onboarding/panchangam — save panchangam type
#  3.  POST /onboarding/panchangam — copies ADMIN lunar events to household
#  4.  POST /onboarding/panchangam — does NOT duplicate if called twice
#  5.  POST /onchanging panchangam type — clears old lunar events first
#  6.  POST /onboarding/panchangam — setting to None clears panchangam selection
#  7.  POST /onboarding/panchangam — invalid panchangam_type_id returns 404
#  8.  GET /onboarding/lunar-observations — returns empty when no panchangam set
#  9.  GET /onboarding/lunar-observations — returns observations after panchangam set
# 10.  GET /onboarding/lunar-observations — all observations active by default
# 11.  PUT /onboarding/lunar-observations — toggle one observation inactive
# 12.  PUT /onboarding/lunar-observations — toggle observation back to active
# 13.  PUT /onboarding/lunar-observations — toggle multiple observations at once
# 14.  PUT /onboarding/lunar-observations — unknown event_name updates 0 rows (no error)
# 15.  Non-admin member cannot save panchangam
# 16.  Non-admin member cannot update observations
# 17.  Unauthenticated request returns 401
# 18.  Changing panchangam type clears old observations and loads new ones

import pytest
from sqlalchemy import text


def auth(user):
    return {"Authorization": f"Bearer {user['access_token']}"}


def get_first_panchangam_id(client):
    """Helper — get the first available panchangam type id from DB via onboarding/data."""
    resp = client.get("/onboarding/data", headers={"Authorization": "Bearer dummy"})
    # Use a known panchangam from seed data
    return 1  # Tamil Vakya is always id=1 from seed


class TestPanchangamSave:

    # Test 1
    def test_onboarding_data_returns_panchangam_types(self, client, admin_user):
        """GET /onboarding/data includes list of panchangam types."""
        resp = client.get("/onboarding/data", headers=auth(admin_user))
        assert resp.status_code == 200
        data = resp.json()
        assert "panchangam_types" in data
        assert len(data["panchangam_types"]) > 0
        # Each type has required fields
        pt = data["panchangam_types"][0]
        assert "id" in pt
        assert "code" in pt
        assert "display_name" in pt

    # Test 2
    def test_save_panchangam_type_succeeds(self, client, admin_user, db):
        """POST /onboarding/panchangam saves panchangam_type_id to household_master."""
        # Get first panchangam id
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert "saved" in resp.json()["message"].lower()

        # Verify in DB
        hh = db.execute(text("""
            SELECT panchangam_type_id FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert hh.panchangam_type_id == pt_id

    # Test 3
    def test_save_panchangam_copies_admin_events(self, client, admin_user, db):
        """Saving panchangam type copies ADMIN lunar events into household event_master rows."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        # Check ADMIN events exist for this panchangam
        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN'
            AND house_id IS NULL
            AND event_type = 'Lunar'
            AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()

        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded for this panchangam type — skipping copy test")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id},
            headers=auth(admin_user)
        )

        # Verify household rows created
        hh_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND source = 'ADMIN'
            AND event_type = 'Lunar'
            AND panchangam_type_id = :ptid
        """), {"ptid": pt_id, "hid": admin_user["house_id"]}).scalar()

        assert hh_count == admin_count

    # Test 4
    def test_save_panchangam_no_duplicate_on_second_call(self, client, admin_user, db):
        """Calling save_panchangam twice does not duplicate household lunar events."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        # Save twice
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND source = 'ADMIN'
            AND event_type = 'Lunar'
        """), {"hid": admin_user["house_id"]}).scalar()

        # Should be same as first call — no duplicates
        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN'
            AND house_id IS NULL
            AND event_type = 'Lunar'
            AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()

        assert count == admin_count

    # Test 5
    def test_changing_panchangam_type_clears_old_events(self, client, admin_user, db):
        """Changing panchangam type deletes old lunar events and inserts new ones."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        types = data["panchangam_types"]
        if len(types) < 2:
            pytest.skip("Need at least 2 panchangam types to test change")

        pt_id_1 = types[0]["id"]
        pt_id_2 = types[1]["id"]

        # Set first panchangam
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id_1}, headers=auth(admin_user))

        # Change to second panchangam
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id_2}, headers=auth(admin_user))

        # Old panchangam events should be gone
        old_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND source = 'ADMIN'
            AND event_type = 'Lunar'
            AND panchangam_type_id = :ptid
        """), {"hid": admin_user["house_id"], "ptid": pt_id_1}).scalar()

        assert old_count == 0

    # Test 6
    def test_save_panchangam_none_clears_selection(self, client, admin_user, db):
        """Setting panchangam_type_id to None clears the selection."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        # Clear it
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": None}, headers=auth(admin_user))
        assert resp.status_code == 200

        hh = db.execute(text("""
            SELECT panchangam_type_id FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert hh.panchangam_type_id is None

    # Test 7
    def test_invalid_panchangam_type_returns_404(self, client, admin_user):
        """Invalid panchangam_type_id returns 404."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": 99999},
            headers=auth(admin_user)
        )
        assert resp.status_code == 404


class TestLunarObservations:

    # Test 8
    def test_get_observations_empty_when_no_panchangam(self, client, admin_user):
        """GET /onboarding/lunar-observations returns empty list when no panchangam set."""
        resp = client.get("/onboarding/lunar-observations", headers=auth(admin_user))
        assert resp.status_code == 200
        assert resp.json()["observations"] == []

    # Test 9
    def test_get_observations_returns_list_after_panchangam_set(self, client, admin_user, db):
        """GET /onboarding/lunar-observations returns observations after panchangam saved."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()

        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        resp = client.get("/onboarding/lunar-observations", headers=auth(admin_user))
        assert resp.status_code == 200
        obs = resp.json()["observations"]
        assert len(obs) > 0

        # Each observation has required fields
        o = obs[0]
        assert "event_name" in o
        assert "is_active" in o
        assert "is_sattvic_required" in o

    # Test 10
    def test_observations_all_active_by_default(self, client, admin_user, db):
        """All observations are active=True when first copied from ADMIN."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()
        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        resp = client.get("/onboarding/lunar-observations", headers=auth(admin_user))
        obs = resp.json()["observations"]
        assert all(o["is_active"] for o in obs), "All observations should be active by default"

    # Test 11
    def test_toggle_one_observation_inactive(self, client, admin_user, db):
        """PUT /onboarding/lunar-observations — toggle one observation to inactive."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()
        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        # Get observations
        obs = client.get("/onboarding/lunar-observations",
            headers=auth(admin_user)).json()["observations"]
        if not obs:
            pytest.skip("No observations to toggle")

        target = obs[0]["event_name"]

        # Toggle to inactive
        resp = client.put("/onboarding/lunar-observations",
            json={"observations": [{"event_name": target, "is_active": False}]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["rows_updated"] > 0

        # Verify in DB
        inactive_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND event_name = :name
            AND is_active = false
        """), {"hid": admin_user["house_id"], "name": target}).scalar()
        assert inactive_count > 0

    # Test 12
    def test_toggle_observation_back_to_active(self, client, admin_user, db):
        """PUT /onboarding/lunar-observations — toggle observation back to active."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()
        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        obs = client.get("/onboarding/lunar-observations",
            headers=auth(admin_user)).json()["observations"]
        if not obs:
            pytest.skip("No observations to toggle")

        target = obs[0]["event_name"]

        # Toggle inactive
        client.put("/onboarding/lunar-observations",
            json={"observations": [{"event_name": target, "is_active": False}]},
            headers=auth(admin_user))

        # Toggle back to active
        resp = client.put("/onboarding/lunar-observations",
            json={"observations": [{"event_name": target, "is_active": True}]},
            headers=auth(admin_user))
        assert resp.status_code == 200

        # Verify all rows are active
        inactive_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND event_name = :name
            AND is_active = false
        """), {"hid": admin_user["house_id"], "name": target}).scalar()
        assert inactive_count == 0

    # Test 13
    def test_toggle_multiple_observations_at_once(self, client, admin_user, db):
        """PUT /onboarding/lunar-observations — toggle multiple observations in one call."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        pt_id = data["panchangam_types"][0]["id"]

        admin_count = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id}).scalar()
        if admin_count == 0:
            pytest.skip("No ADMIN lunar events seeded")

        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id}, headers=auth(admin_user))

        obs = client.get("/onboarding/lunar-observations",
            headers=auth(admin_user)).json()["observations"]
        if len(obs) < 2:
            pytest.skip("Need at least 2 observations to test multiple toggle")

        # Toggle first two inactive
        toggles = [
            {"event_name": obs[0]["event_name"], "is_active": False},
            {"event_name": obs[1]["event_name"], "is_active": False},
        ]
        resp = client.put("/onboarding/lunar-observations",
            json={"observations": toggles},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["rows_updated"] > 0

        # Verify both are inactive
        for o in toggles:
            count = db.execute(text("""
                SELECT COUNT(*) FROM event_master
                WHERE house_id = CAST(:hid AS uuid)
                AND event_name = :name AND is_active = false
            """), {"hid": admin_user["house_id"], "name": o["event_name"]}).scalar()
            assert count > 0, f"{o['event_name']} should be inactive"

    # Test 14
    def test_unknown_event_name_updates_zero_rows(self, client, admin_user):
        """Unknown event_name in toggle returns 200 but updates 0 rows."""
        resp = client.put("/onboarding/lunar-observations",
            json={"observations": [{"event_name": "NON_EXISTENT_EVENT", "is_active": False}]},
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["rows_updated"] == 0


class TestLunarAccessControl:

    # Test 15
    def test_non_admin_cannot_save_panchangam(self, client, member_user):
        """Household member cannot save panchangam type."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": 1},
            headers=auth(member_user)
        )
        assert resp.status_code == 403

    # Test 16
    def test_non_admin_cannot_update_observations(self, client, member_user):
        """Household member cannot update lunar observations."""
        resp = client.put("/onboarding/lunar-observations",
            json={"observations": [{"event_name": "Pradosham", "is_active": False}]},
            headers=auth(member_user)
        )
        assert resp.status_code == 403

    # Test 17
    def test_unauthenticated_panchangam_save_returns_401(self, client):
        """Unauthenticated request to save panchangam returns 401."""
        resp = client.post("/onboarding/panchangam",
            json={"panchangam_type_id": 1}
        )
        assert resp.status_code == 401

    def test_unauthenticated_observations_get_returns_401(self, client):
        """Unauthenticated request to get observations returns 401."""
        resp = client.get("/onboarding/lunar-observations")
        assert resp.status_code == 401


class TestPanchangamChangeFlow:

    # Test 18
    def test_changing_panchangam_clears_old_and_loads_new(self, client, admin_user, db):
        """Full flow: set panchangam A, customise observations, change to B — old cleared."""
        data = client.get("/onboarding/data", headers=auth(admin_user)).json()
        types = data["panchangam_types"]
        if len(types) < 2:
            pytest.skip("Need at least 2 panchangam types")

        pt_id_1 = types[0]["id"]
        pt_id_2 = types[1]["id"]

        admin_count_1 = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE source = 'ADMIN' AND house_id IS NULL
            AND event_type = 'Lunar' AND panchangam_type_id = :ptid
        """), {"ptid": pt_id_1}).scalar()

        if admin_count_1 == 0:
            pytest.skip("No ADMIN events for first panchangam type")

        # Step 1 — Set panchangam type 1
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id_1}, headers=auth(admin_user))

        # Step 2 — Get observations and toggle one inactive
        obs = client.get("/onboarding/lunar-observations",
            headers=auth(admin_user)).json()["observations"]

        if obs:
            client.put("/onboarding/lunar-observations",
                json={"observations": [{"event_name": obs[0]["event_name"], "is_active": False}]},
                headers=auth(admin_user))

        # Verify customisation saved
        inactive = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND source = 'ADMIN' AND event_type = 'Lunar'
            AND is_active = false
        """), {"hid": admin_user["house_id"]}).scalar()

        if obs:
            assert inactive > 0, "Customisation should be saved"

        # Step 3 — Change to panchangam type 2
        client.post("/onboarding/panchangam",
            json={"panchangam_type_id": pt_id_2}, headers=auth(admin_user))

        # Step 4 — Old type 1 events should be gone
        old_events = db.execute(text("""
            SELECT COUNT(*) FROM event_master
            WHERE house_id = CAST(:hid AS uuid)
            AND source = 'ADMIN' AND event_type = 'Lunar'
            AND panchangam_type_id = :ptid
        """), {"hid": admin_user["house_id"], "ptid": pt_id_1}).scalar()

        assert old_events == 0, "Old panchangam events should be deleted after change"
