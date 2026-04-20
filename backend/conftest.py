# backend/conftest.py
# Root-level conftest for the backend test suite.
# Anything defined here is available to all test files without import.

import uuid

def unique_email(prefix="test"):
    """Generate a unique test email address — safe to use in parallel test runs."""
    return f"{prefix}_{uuid.uuid4().hex[:8]}@momentum-test.com"
