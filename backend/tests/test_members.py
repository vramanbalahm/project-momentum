# test_members.py — Member management endpoint tests
#
# Covers:
# - Create member: success, duplicate email, short password
# - List members: admin sees all, member blocked
# - Role change: promote, demote, self-demotion blocked, cross-household blocked
# - Deactivate: deactivate, reactivate, self-deactivation blocked, member blocked
# - Role restrictions: member cannot access admin-only endpoints

import pytest
from sqlalchemy import text
from conftest import unique_email


class TestCreateMember:

    def test_create_member_success(self, client, admin_user, db):
        """Admin creates a member — returns 201 with user_id."""
        email = unique_email("newmember")
        resp = client.post("/auth/members/create",
            json={"email": email, "password": "MemberPass1!", "name": "New Member"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 201
        data = resp.json()
        assert "user_id" in data

        # Verify user exists in DB under correct household
        row = db.execute(text("""
            SELECT house_id, role FROM users WHERE email = :email
        """), {"email": email}).fetchone()
        assert row is not None
        assert str(row.house_id) == admin_user["house_id"]
        assert str(row.role) == "household_member"

    def test_create_member_duplicate_email(self, client, admin_user, member_user):
        """Duplicate email returns 409."""
        resp = client.post("/auth/members/create",
            json={"email": member_user["email"], "password": "MemberPass1!", "name": "Dupe"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 409

    def test_create_member_short_password(self, client, admin_user):
        """Password under 8 chars returns 422."""
        resp = client.post("/auth/members/create",
            json={"email": unique_email("short"), "password": "abc", "name": "Short"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 422

    def test_member_cannot_create_member(self, client, member_user):
        """household_member cannot create members — returns 403."""
        resp = client.post("/auth/members/create",
            json={"email": unique_email("unauth"), "password": "ValidPass1!", "name": "Unauth"},
            headers={"Authorization": f"Bearer {member_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_unauthenticated_cannot_create_member(self, client):
        """No token returns 401."""
        resp = client.post("/auth/members/create",
            json={"email": unique_email("noauth"), "password": "ValidPass1!", "name": "NoAuth"}
        )
        assert resp.status_code == 401


class TestListMembers:

    def test_admin_can_list_members(self, client, admin_user, member_user):
        """Admin sees all household members including themselves."""
        resp = client.get("/auth/members",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        emails = [u["email"] for u in data]
        assert admin_user["email"] in emails
        assert member_user["email"] in emails

    def test_member_cannot_list_members(self, client, member_user):
        """household_member cannot list members — returns 403."""
        resp = client.get("/auth/members",
            headers={"Authorization": f"Bearer {member_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_list_members_returns_correct_fields(self, client, admin_user, member_user):
        """Each member record has required fields."""
        resp = client.get("/auth/members",
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200
        for user in resp.json():
            assert "user_id" in user
            assert "name" in user
            assert "email" in user
            assert "role" in user
            assert "is_active" in user


class TestRoleChange:

    def test_promote_member_to_admin(self, client, admin_user, member_user, db):
        """Admin promotes a member — role changes to household_admin."""
        resp = client.put("/auth/members/role",
            json={"user_id": member_user["user_id"], "new_role": "household_admin"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT role FROM users WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]}).fetchone()
        assert str(row.role) == "household_admin"

    def test_demote_admin_to_member(self, client, admin_user, member_user, db):
        """Admin demotes another admin — role changes to household_member."""
        # First promote
        client.put("/auth/members/role",
            json={"user_id": member_user["user_id"], "new_role": "household_admin"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        # Then demote
        resp = client.put("/auth/members/role",
            json={"user_id": member_user["user_id"], "new_role": "household_member"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT role FROM users WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]}).fetchone()
        assert str(row.role) == "household_member"

    def test_admin_cannot_demote_themselves(self, client, admin_user):
        """Admin cannot demote themselves — returns 400."""
        resp = client.put("/auth/members/role",
            json={"user_id": admin_user["user_id"], "new_role": "household_member"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 400

    def test_invalid_role_rejected(self, client, admin_user, member_user):
        """Invalid role string returns 422."""
        resp = client.put("/auth/members/role",
            json={"user_id": member_user["user_id"], "new_role": "platform_god"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 422

    def test_member_cannot_change_roles(self, client, member_user, admin_user):
        """household_member cannot change roles — returns 403."""
        resp = client.put("/auth/members/role",
            json={"user_id": admin_user["user_id"], "new_role": "household_member"},
            headers={"Authorization": f"Bearer {member_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_cannot_change_role_of_other_household_user(self, client, admin_user, db):
        """Cannot change role of a user outside this household — returns 404."""
        # Use a random UUID that doesn't belong to this household
        import uuid
        fake_uid = str(uuid.uuid4())
        resp = client.put("/auth/members/role",
            json={"user_id": fake_uid, "new_role": "household_member"},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 404


class TestDeactivateMember:

    def test_deactivate_member(self, client, admin_user, member_user, db):
        """Admin deactivates a member — is_active becomes false."""
        resp = client.put("/auth/members/deactivate",
            json={"user_id": member_user["user_id"], "is_active": False},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT is_active FROM users WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]}).fetchone()
        assert row.is_active is False

    def test_reactivate_member(self, client, admin_user, member_user, db):
        """Admin reactivates a member — is_active becomes true."""
        # First deactivate
        client.put("/auth/members/deactivate",
            json={"user_id": member_user["user_id"], "is_active": False},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        # Then reactivate
        resp = client.put("/auth/members/deactivate",
            json={"user_id": member_user["user_id"], "is_active": True},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 200

        row = db.execute(text("""
            SELECT is_active FROM users WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]}).fetchone()
        assert row.is_active is True

    def test_admin_cannot_deactivate_themselves(self, client, admin_user):
        """Admin cannot deactivate themselves — returns 403."""
        resp = client.put("/auth/members/deactivate",
            json={"user_id": admin_user["user_id"], "is_active": False},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_member_cannot_deactivate(self, client, member_user, admin_user):
        """household_member cannot deactivate anyone — returns 403."""
        resp = client.put("/auth/members/deactivate",
            json={"user_id": admin_user["user_id"], "is_active": False},
            headers={"Authorization": f"Bearer {member_user['access_token']}"}
        )
        assert resp.status_code == 403

    def test_deactivate_nonexistent_user_returns_404(self, client, admin_user):
        """Deactivating a user not in this household returns 404."""
        import uuid
        resp = client.put("/auth/members/deactivate",
            json={"user_id": str(uuid.uuid4()), "is_active": False},
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 404
