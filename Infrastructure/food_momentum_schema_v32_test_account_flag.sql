-- Schema v32 — flag test/QA households vs real users
--
-- Lets us tell apart real families using the app from accumulated test/QA
-- data (Playwright runs, pytest fixtures, manual dev testing) as real users
-- start onboarding.
--
-- BOOLEAN, not Y/N -- every existing flag on this table (is_active,
-- onboarding_done, wizard_members_done, wizard_satvik_done,
-- wizard_events_done) and across the schema generally (is_regional_specific,
-- created_by_ai, etc.) is a genuine boolean, never a Y/N character code.
-- This keeps the new column consistent with that established convention.
--
-- Not mandatory: nullable, defaults to FALSE so every new real registration
-- is correctly flagged as a real household without the app needing to know
-- this column exists.

ALTER TABLE household_master
    ADD COLUMN IF NOT EXISTS is_test_account BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN household_master.is_test_account IS
    'TRUE = known test/QA data (Playwright runs, pytest fixtures, manual
     dev testing). FALSE/NULL = real household. Used to filter test data
     out of any real-user-facing views, reports, or analytics once real
     families start using the app.';


-- ============================================================
-- Flagging: mark everything as test EXCEPT the two confirmed real
-- households (Bala's Family, Hiru Fly). Simpler and less error-prone
-- than pattern-matching dozens of inconsistently-named test households
-- (Test House, Test Household, Pantry House, PW Test House, Rate House,
-- etc.) -- given only two households are confirmed real right now, an
-- exclusion list is the safer approach.
-- ============================================================

-- Preview first -- run this SELECT alone and check the row count/list
-- before running the UPDATE below.
SELECT household_id, house_name
FROM household_master
WHERE household_id NOT IN (
    '64c0e124-d9d1-4ddf-8945-b6fb8bd2c7b8',  -- Bala's Family
    'e8ccd01a-3f8b-4961-aeb8-4b4a19c079e3'   -- Hiru Fly
);

-- The actual update. Run only after checking the preview above looks right.
UPDATE household_master
SET is_test_account = TRUE
WHERE household_id NOT IN (
    '64c0e124-d9d1-4ddf-8945-b6fb8bd2c7b8',  -- Bala's Family
    'e8ccd01a-3f8b-4961-aeb8-4b4a19c079e3'   -- Hiru Fly
);

-- Explicitly confirm the two real households stay FALSE (they already
-- default to FALSE, but setting it explicitly documents intent clearly).
UPDATE household_master
SET is_test_account = FALSE
WHERE household_id IN (
    '64c0e124-d9d1-4ddf-8945-b6fb8bd2c7b8',  -- Bala's Family
    'e8ccd01a-3f8b-4961-aeb8-4b4a19c079e3'   -- Hiru Fly
);

-- Verify
SELECT is_test_account, COUNT(*) FROM household_master GROUP BY is_test_account;
