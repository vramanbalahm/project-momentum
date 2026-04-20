# test_profile.py — Household profile update endpoint tests
#
# Covers:
# - Update individual fields: house_name, dietary_preference, primary_region,
#   current_city, cuisine_sub_region_id, household_allergies
# - Audit log: one row per changed field, correct old/new values
# - No-change detection: same value sent returns "No changes detected"
# - Partial update: only provided fields are updated, others untouched
# - Role restriction: member cannot update profile
# - Unauthenticated request rejected

import pytest
from sqlalchemy import text


class TestProfileUpdate:

    def test_update_house_name(self, client, admin_user, db):
        """house_name is updated and reflected in DB."""
        resp = client.put("/auth/profile",
            json={"house_name": "Updated House Name"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200
        assert "house_name" in resp.json().get("updated_fields", []) or \
               "updated" in resp.json().get("message", "").lower()

        row = db.execute(text("""
            SELECT house_name FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.house_name == "Updated House Name"

    def test_update_dietary_preference(self, client, admin_user, db):
        """dietary_preference enum is updated correctly."""
        resp = client.put("/auth/profile",
            json={"dietary_preference": "Non-Veg"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT dietary_preference FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert str(row.dietary_preference) == "Non-Veg"

    def test_update_primary_region(self, client, admin_user, db):
        """primary_region is updated correctly."""
        resp = client.put("/auth/profile",
            json={"primary_region": "Karnataka"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT primary_region FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.primary_region == "Karnataka"

    def test_update_current_city(self, client, admin_user, db):
        """current_city is updated correctly."""
        resp = client.put("/auth/profile",
            json={"current_city": "Mysuru"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT current_city FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.current_city == "Mysuru"

    def test_update_household_allergies(self, client, admin_user, db):
        """household_allergies is updated correctly."""
        resp = client.put("/auth/profile",
            json={"household_allergies": "Peanuts, Gluten"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT household_allergies FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.household_allergies == "Peanuts, Gluten"

    def test_update_multiple_fields(self, client, admin_user, db):
        """Multiple fields updated in one call."""
        resp = client.put("/auth/profile",
            json={
                "house_name": "Multi Update House",
                "current_city": "Kochi",
                "household_allergies": "Dairy"
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT house_name, current_city, household_allergies
            FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert row.house_name == "Multi Update House"
        assert row.current_city == "Kochi"
        assert row.household_allergies == "Dairy"

    def test_no_change_returns_no_changes_message(self, client, admin_user, db):
        """Sending the same value as current returns no-change response without DB write."""
        # First set a known value
        client.put("/auth/profile",
            json={"house_name": "Stable House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        # Send the exact same value again
        resp = client.put("/auth/profile",
            json={"house_name": "Stable House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200
        assert "no changes" in resp.json().get("message", "").lower()

    def test_partial_update_does_not_touch_other_fields(self, client, admin_user, db):
        """Only provided fields are updated — other fields remain untouched."""
        # Get current state
        before = db.execute(text("""
            SELECT house_name, current_city FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        original_city = before.current_city

        # Update only house_name
        client.put("/auth/profile",
            json={"house_name": "Partial Update House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )

        after = db.execute(text("""
            SELECT house_name, current_city FROM household_master
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).fetchone()
        assert after.house_name == "Partial Update House"
        assert after.current_city == original_city  # untouched


class TestProfileAuditLog:

    def test_audit_log_row_created_on_change(self, client, admin_user, db):
        """Each field change creates one audit log row."""
        resp = client.put("/auth/profile",
            json={"house_name": "Audit Test House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT field_name, new_value, changed_by
            FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
              AND field_name = 'house_name'
            ORDER BY changed_at DESC
            LIMIT 1
        """), {"hid": admin_user["house_id"]}).fetchone()

        assert row is not None
        assert row.new_value == "Audit Test House"
        assert str(row.changed_by) == admin_user["user_id"]

    def test_audit_log_records_old_value(self, client, admin_user, db):
        """Audit log correctly stores the old value before the change."""
        # Set a known value first
        client.put("/auth/profile",
            json={"house_name": "Before Change"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        # Now change it
        client.put("/auth/profile",
            json={"house_name": "After Change"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )

        row = db.execute(text("""
            SELECT old_value, new_value
            FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
              AND field_name = 'house_name'
              AND new_value = 'After Change'
            ORDER BY changed_at DESC
            LIMIT 1
        """), {"hid": admin_user["house_id"]}).fetchone()

        assert row is not None
        assert row.old_value == "Before Change"
        assert row.new_value == "After Change"

    def test_no_audit_log_when_no_change(self, client, admin_user, db):
        """No audit row is created if the value didn't actually change."""
        # Set value
        client.put("/auth/profile",
            json={"house_name": "No Change House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        # Count existing audit rows
        count_before = db.execute(text("""
            SELECT COUNT(*) FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()

        # Send same value
        client.put("/auth/profile",
            json={"house_name": "No Change House"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        count_after = db.execute(text("""
            SELECT COUNT(*) FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()

        assert count_after == count_before

    def test_multiple_fields_create_multiple_audit_rows(self, client, admin_user, db):
        """Updating 3 fields creates 3 audit rows in one call."""
        count_before = db.execute(text("""
            SELECT COUNT(*) FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()

        client.put("/auth/profile",
            json={
                "house_name": "Multi Audit House",
                "current_city": "Kochi",
                "household_allergies": "Sesame"
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )

        count_after = db.execute(text("""
            SELECT COUNT(*) FROM profile_audit_log
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()

        assert count_after == count_before + 3


class TestProfileRestrictions:

    def test_member_cannot_update_profile(self, client, member_user):
        """household_member cannot update profile — returns 403."""
        resp = client.put("/auth/profile",
            json={"house_name": "Hacked House"},
            headers={"Authorization": f"Bearer {member_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_unauthenticated_cannot_update_profile(self, client):
        """No token returns 401."""
        resp = client.put("/auth/profile",
            json={"house_name": "No Auth House"}
        )
        assert resp.status_code == 401
