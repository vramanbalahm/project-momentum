-- ============================================================
-- Momentum Schema v16b — Add reviewer to user_role enum
-- Date: May 2026
-- Run on: food_momentum_db
-- ============================================================

-- Add reviewer to the existing user_role enum
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'reviewer';

-- Verify
SELECT enumlabel FROM pg_enum
WHERE enumtypid = 'public.user_role'::regtype
ORDER BY enumsortorder;
