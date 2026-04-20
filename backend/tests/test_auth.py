# test_auth.py — Authentication endpoint tests
#
# Covers:
# - Register: success, duplicate email, short password
# - Login: success, wrong password, inactive user, inactive household
# - Logout: revokes refresh token
# - Refresh: valid token rotates, revoked token rejected
# - Me: returns correct user and household data
# - Change password: success, wrong current password, too short
# - Rate limiting: 429 after 5 failed login attempts

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text
from conftest import unique_email


# ── Register ──────────────────────────────────────────────────────────────────

class TestRegister:

    def test_register_success(self, client, db):
        """New household + admin created, tokens returned."""
        email = unique_email("reg")
        resp = client.post("/auth/register", json={
            "email": email,
            "password": "ValidPass1!",
            "name": "New Admin",
            "house_name": "New House",
            "primary_region": "Tamil Nadu",
            "current_city": "Chennai",
            "dietary_preference": "Veg"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"

        # Teardown
        db.execute(text("""
            DELETE FROM refresh_tokens rt
            USING users u
            WHERE rt.user_id = u.user_id AND u.email = :email
        """), {"email": email})
        db.execute(text("""
            DELETE FROM household_master hm
            USING users u
            WHERE hm.household_id = u.house_id AND u.email = :email
        """), {"email": email})
        db.execute(text("DELETE FROM users WHERE email = :email"), {"email": email})
        db.commit()

    def test_register_duplicate_email(self, client, admin_user):
        """Duplicate email returns 409."""
        resp = client.post("/auth/register", json={
            "email": admin_user["email"],
            "password": "AnotherPass1!",
            "name": "Duplicate",
            "house_name": "Dupe House",
            "primary_region": "Tamil Nadu",
            "current_city": "Chennai",
            "dietary_preference": "Veg"
        })
        assert resp.status_code == 409
        assert "already registered" in resp.json()["detail"].lower()

    def test_register_short_password(self, client):
        """Password under 8 chars returns 422."""
        resp = client.post("/auth/register", json={
            "email": unique_email("short"),
            "password": "abc",
            "name": "Short",
            "house_name": "Short House",
            "primary_region": "Tamil Nadu",
            "current_city": "Chennai",
            "dietary_preference": "Veg"
        })
        assert resp.status_code == 422


# ── Login ─────────────────────────────────────────────────────────────────────

class TestLogin:

    def test_login_success(self, client, admin_user):
        """Valid credentials return tokens."""
        resp = client.post("/auth/login", json={
            "email": admin_user["email"],
            "password": admin_user["password"]
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert "refresh_token" in data

    def test_login_wrong_password(self, client, admin_user):
        """Wrong password returns 401."""
        resp = client.post("/auth/login", json={
            "email": admin_user["email"],
            "password": "WrongPassword!"
        })
        assert resp.status_code == 401

    def test_login_nonexistent_email(self, client):
        """Unknown email returns 401."""
        resp = client.post("/auth/login", json={
            "email": "nobody@nowhere.com",
            "password": "DoesNotMatter1!"
        })
        assert resp.status_code == 401

    def test_login_inactive_user(self, client, admin_user, member_user, db):
        """Deactivated user cannot log in — returns 403."""
        # Deactivate member directly in DB
        db.execute(text("""
            UPDATE users SET is_active = false
            WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]})
        db.commit()

        resp = client.post("/auth/login", json={
            "email": member_user["email"],
            "password": member_user["password"]
        })
        assert resp.status_code == 403
        assert "deactivated" in resp.json()["detail"].lower()

        # Restore
        db.execute(text("""
            UPDATE users SET is_active = true
            WHERE user_id = CAST(:uid AS uuid)
        """), {"uid": member_user["user_id"]})
        db.commit()

    def test_login_inactive_household(self, client, admin_user, db):
        """Inactive household blocks all logins for that household — returns 403."""
        db.execute(text("""
            UPDATE household_master SET is_active = false
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]})
        db.commit()

        resp = client.post("/auth/login", json={
            "email": admin_user["email"],
            "password": admin_user["password"]
        })
        assert resp.status_code == 403
        assert "inactive" in resp.json()["detail"].lower()

        # Restore
        db.execute(text("""
            UPDATE household_master SET is_active = true
            WHERE household_id = CAST(:hid AS uuid)
        """), {"hid": admin_user["house_id"]})
        db.commit()


# ── Logout ────────────────────────────────────────────────────────────────────

class TestLogout:

    def test_logout_revokes_refresh_token(self, client, admin_user, db):
        """After logout, the refresh token is revoked in DB."""
        resp = client.post("/auth/logout", json={
            "refresh_token": admin_user["refresh_token"]
        })
        assert resp.status_code == 204

        # Verify token is revoked in DB
        import hashlib
        token_hash = hashlib.sha256(admin_user["refresh_token"].encode()).hexdigest()
        row = db.execute(text("""
            SELECT revoked FROM refresh_tokens WHERE token_hash = :hash
        """), {"hash": token_hash}).fetchone()
        assert row is not None
        assert row.revoked is True


# ── Refresh ───────────────────────────────────────────────────────────────────

class TestRefresh:

    def test_refresh_returns_new_tokens(self, client, admin_user):
        """Valid refresh token returns new access + refresh tokens."""
        resp = client.post("/auth/refresh", json={
            "refresh_token": admin_user["refresh_token"]
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert "refresh_token" in data
        # New tokens must differ from originals
        assert data["access_token"] != admin_user["access_token"]
        assert data["refresh_token"] != admin_user["refresh_token"]

    def test_refresh_revoked_token_rejected(self, client, admin_user):
        """Using the same refresh token twice is rejected — token rotates on first use."""
        # First use — succeeds and revokes the token
        client.post("/auth/refresh", json={"refresh_token": admin_user["refresh_token"]})
        # Second use — must fail
        resp = client.post("/auth/refresh", json={"refresh_token": admin_user["refresh_token"]})
        assert resp.status_code == 401

    def test_refresh_invalid_token_rejected(self, client):
        """Garbage token returns 401."""
        resp = client.post("/auth/refresh", json={"refresh_token": "notavalidtoken"})
        assert resp.status_code == 401


# ── Me ────────────────────────────────────────────────────────────────────────

class TestMe:

    def test_me_returns_correct_data(self, client, admin_user):
        """Authenticated /me returns user and household info."""
        resp = client.get("/auth/me", headers={
            "Authorization": f"Bearer {admin_user['access_token']}"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["email"] == admin_user["email"]
        assert data["role"] == "household_admin"
        assert data["house_id"] == admin_user["house_id"]
        assert "house_name" in data
        assert "dietary_preference" in data

    def test_me_unauthenticated_rejected(self, client):
        """No token returns 401."""
        resp = client.get("/auth/me")
        assert resp.status_code == 401

    def test_me_invalid_token_rejected(self, client):
        """Invalid token returns 401."""
        resp = client.get("/auth/me", headers={"Authorization": "Bearer invalidtoken"})
        assert resp.status_code == 401


# ── Change Password ───────────────────────────────────────────────────────────

class TestChangePassword:

    def test_change_password_success(self, client, admin_user):
        """Valid current password allows change — new password works for login."""
        resp = client.post("/auth/change-password",
            json={
                "current_password": admin_user["password"],
                "new_password": "NewValidPass1!"
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 204

        # Verify new password works
        login = client.post("/auth/login", json={
            "email": admin_user["email"],
            "password": "NewValidPass1!"
        })
        assert login.status_code == 200

    def test_change_password_wrong_current(self, client, admin_user):
        """Wrong current password returns 401."""
        resp = client.post("/auth/change-password",
            json={
                "current_password": "WrongOldPass!",
                "new_password": "NewValidPass1!"
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 401

    def test_change_password_too_short(self, client, admin_user):
        """New password under 8 chars returns 422."""
        resp = client.post("/auth/change-password",
            json={
                "current_password": admin_user["password"],
                "new_password": "abc"
            },
            headers={"Authorization": f"Bearer {admin_user['access_token']}"}
        )
        assert resp.status_code == 422

    def test_change_password_unauthenticated(self, client):
        """No token returns 401."""
        resp = client.post("/auth/change-password", json={
            "current_password": "something",
            "new_password": "NewValidPass1!"
        })
        assert resp.status_code == 401


# ── Rate Limiting ─────────────────────────────────────────────────────────────

class TestRateLimiting:

    def test_login_rate_limit(self, client):
        """6th failed login attempt from same IP returns 429."""
        email = unique_email("ratelimit")
        for i in range(5):
            client.post("/auth/login", json={
                "email": email,
                "password": "WrongPass!"
            })
        # 6th attempt must be rate limited
        resp = client.post("/auth/login", json={
            "email": email,
            "password": "WrongPass!"
        })
        assert resp.status_code == 429

    def test_register_rate_limit(self, client, db):
        """6th register attempt from same IP returns 429."""
        for i in range(5):
            email = unique_email(f"ratelimitreg{i}")
            resp = client.post("/auth/register", json={
                "email": email,
                "password": "ValidPass1!",
                "name": "Rate Test",
                "house_name": "Rate House",
                "primary_region": "Tamil Nadu",
                "current_city": "Chennai",
                "dietary_preference": "Veg"
            })
            # Clean up each registration that succeeds
            if resp.status_code == 200:
                db.execute(text("""
                    DELETE FROM refresh_tokens rt
                    USING users u
                    WHERE rt.user_id = u.user_id AND u.email = :email
                """), {"email": email})
                db.execute(text("""
                    DELETE FROM household_master hm
                    USING users u
                    WHERE hm.household_id = u.house_id AND u.email = :email
                """), {"email": email})
                db.execute(text("DELETE FROM users WHERE email = :email"), {"email": email})
                db.commit()

        # 6th attempt
        resp = client.post("/auth/register", json={
            "email": unique_email("ratelimitreg6"),
            "password": "ValidPass1!",
            "name": "Rate Test",
            "house_name": "Rate House",
            "primary_region": "Tamil Nadu",
            "current_city": "Chennai",
            "dietary_preference": "Veg"
        })
        assert resp.status_code == 429
