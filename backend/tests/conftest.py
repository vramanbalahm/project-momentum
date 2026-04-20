# conftest.py — shared fixtures for all Momentum Pytest tests
#
# Strategy:
# - Uses FastAPI TestClient — no live server needed
# - Every fixture creates real DB rows and cleans them up after the test
# - Teardown uses direct SQL DELETE so no test data ever persists
# - admin_user and member_user fixtures are scoped to "function" — fresh per test

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text

import sys
import os

# Ensure backend root is on the path so imports resolve correctly
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app
from database import SessionLocal

# ── TestClient ────────────────────────────────────────────────────────────────

@pytest.fixture(scope="session")
def client():
    """Single TestClient for the whole test session."""
    with TestClient(app) as c:
        yield c


# ── DB session for direct SQL in tests ───────────────────────────────────────

@pytest.fixture(scope="function")
def db():
    """Raw DB session for assertions and teardown."""
    session = SessionLocal()
    yield session
    session.close()


# ── Unique email helper ───────────────────────────────────────────────────────

import uuid

def unique_email(prefix="test"):
    """Plain function — usable directly in test files without import."""
    return f"{prefix}_{uuid.uuid4().hex[:8]}@momentum-test.com"

@pytest.fixture
def make_email():
    """Fixture version — yields the unique_email function for use in tests."""
    return unique_email


# ── Admin user fixture ────────────────────────────────────────────────────────

@pytest.fixture(scope="function")
def admin_user(client, db):
    """
    Registers a fresh household + admin user.
    Yields: { email, password, access_token, refresh_token, house_id, user_id }
    Cleans up: deletes users and household after test.
    """
    email = unique_email("admin")
    password = "AdminPass1!"
    payload = {
        "email": email,
        "password": password,
        "name": "Test Admin",
        "house_name": "Test Household",
        "primary_region": "Tamil Nadu",
        "current_city": "Bengaluru",
        "dietary_preference": "Veg"
    }
    resp = client.post("/auth/register", json=payload)
    assert resp.status_code == 200, f"Admin register failed: {resp.text}"

    tokens = resp.json()
    access_token = tokens["access_token"]

    # Fetch user details
    me_resp = client.get("/auth/me", headers={"Authorization": f"Bearer {access_token}"})
    assert me_resp.status_code == 200
    me = me_resp.json()

    yield {
        "email":         email,
        "password":      password,
        "access_token":  access_token,
        "refresh_token": tokens["refresh_token"],
        "house_id":      me["house_id"],
        "user_id":       me["user_id"],
    }

    # Teardown — delete users first (FK), then household
    db.execute(text("DELETE FROM refresh_tokens WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM profile_audit_log WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM users WHERE house_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.execute(text("DELETE FROM household_master WHERE household_id = CAST(:hid AS uuid)"), {"hid": me["house_id"]})
    db.commit()


# ── Member user fixture ───────────────────────────────────────────────────────

@pytest.fixture(scope="function")
def member_user(client, admin_user, db):
    """
    Creates a household_member under the admin_user's household.
    Yields: { email, password, access_token, refresh_token, user_id }
    Cleanup is handled by admin_user teardown (cascade delete on household).
    """
    email = unique_email("member")
    password = "MemberPass1!"
    payload = {
        "email": email,
        "password": password,
        "name": "Test Member"
    }
    resp = client.post(
        "/auth/members/create",
        json=payload,
        headers={"Authorization": f"Bearer {admin_user['access_token']}"}
    )
    assert resp.status_code == 201, f"Member create failed: {resp.text}"
    user_id = resp.json()["user_id"]

    # Log in as member to get tokens
    login_resp = client.post("/auth/login", json={"email": email, "password": password})
    assert login_resp.status_code == 200, f"Member login failed: {login_resp.text}"
    tokens = login_resp.json()

    yield {
        "email":         email,
        "password":      password,
        "access_token":  tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
        "user_id":       user_id,
    }
    # No explicit teardown — admin_user fixture deletes all users in the household
