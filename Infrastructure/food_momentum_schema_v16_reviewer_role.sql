-- ============================================================
-- Momentum Schema v16 — Reviewer Role
-- Purpose: Add 'reviewer' to the role CHECK constraint on users
--          Reviewers can edit and approve/reject recipes
--          but cannot access other platform admin features
-- Date: May 2026
-- Run on: food_momentum_db
-- ============================================================

-- Step 1: Drop existing role constraint
ALTER TABLE public.users
    DROP CONSTRAINT IF EXISTS users_role_check;

-- Step 2: Add updated constraint with reviewer role
ALTER TABLE public.users
    ADD CONSTRAINT users_role_check
    CHECK (role IN (
        'household_admin',
        'household_member',
        'platform_admin',
        'reviewer'
    ));

-- Step 3: Verify
SELECT conname, pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'public.users'::regclass
  AND conname = 'users_role_check';
