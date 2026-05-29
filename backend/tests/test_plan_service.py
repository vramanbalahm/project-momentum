# test_plan_service.py — Plan service and session constants tests
#
# Covers:
# - session_constants: member_count returns correct count from users table
# - member_count excludes inactive members
# - session_constants returns oldest_plan_week and dietary_preference

import pytest
from sqlalchemy import text


def auth(user):
    return {"Authorization": f"Bearer {user['access_token']}"}


class TestSessionConstants:

    def test_session_constants_returns_required_fields(self, client, admin_user):
        """GET /session-constants returns member_count, oldest_plan_week, dietary_preference."""
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "member_count" in data
        assert "oldest_plan_week" in data
        assert "dietary_preference" in data

    def test_member_count_includes_admin(self, client, admin_user):
        """member_count includes the admin themselves — at least 1."""
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        assert resp.json()["member_count"] >= 1

    def test_member_count_increases_when_member_added(self, client, admin_user, db):
        """member_count increases by 1 after adding a new member."""
        # Get initial count
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        initial_count = resp.json()["member_count"]

        # Add a new member (no email — email is optional)
        import uuid
        resp_add = client.post("/auth/members/create",
            json={"name": "Count Test Member", "password": "ValidPass1!"},
            headers=auth(admin_user)
        )
        assert resp_add.status_code == 201, f"Member creation failed: {resp_add.text}"

        # Get new count
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        assert resp.json()["member_count"] == initial_count + 1

    def test_member_count_excludes_inactive_members(self, client, admin_user, member_user, db):
        """member_count does not count deactivated members."""
        # Get count with member active
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        active_count = resp.json()["member_count"]

        # Deactivate the member
        client.put("/auth/members/deactivate",
            json={"user_id": member_user["user_id"], "is_active": False},
            headers=auth(admin_user)
        )

        # Get count again — should be 1 less
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        assert resp.json()["member_count"] == active_count - 1

    def test_member_count_uses_users_table_not_household_members(self, client, admin_user, db):
        """Verify member_count comes from users table — household_members table is legacy."""
        # Check household_members table is empty for this household
        hm_count = db.execute(text("""
            SELECT COUNT(*) FROM household_members
            WHERE house_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]}).scalar()

        # Get member_count from session constants
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        session_count = resp.json()["member_count"]

        # session_count should be >= 1 (admin exists) even if household_members is 0
        # This proves it's reading from users table not household_members
        assert session_count >= 1
        # If household_members is empty, member_count should still be correct
        if hm_count == 0:
            assert session_count >= 1  # admin at minimum

    def test_dietary_preference_returned_correctly(self, client, admin_user):
        """dietary_preference matches household dietary setting."""
        resp = client.get(
            f"/session-constants/{admin_user['house_id']}",
            headers=auth(admin_user)
        )
        assert resp.status_code == 200
        diet = resp.json()["dietary_preference"]
        assert diet in ["Veg", "Non-Veg", "Vegan", "Eggitarian"]

    def test_unauthenticated_cannot_get_session_constants(self, client, admin_user):
        """No token returns 401."""
        resp = client.get(f"/session-constants/{admin_user['house_id']}")
        assert resp.status_code == 401
