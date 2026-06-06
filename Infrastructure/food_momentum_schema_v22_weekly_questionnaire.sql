-- ============================================================
-- Schema v22 — Weekly Generation Questionnaire
-- Date: 2026-06-06
-- Purpose: Capture household preferences before each plan generation.
--          Stored for 8 weeks → feeds ML auto-learning.
-- ============================================================

-- weekly_generation_config — one row per household per week_start
CREATE TABLE IF NOT EXISTS public.weekly_generation_config (
    config_id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    house_id                UUID        NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    week_start              DATE        NOT NULL,

    -- Q1: Continental breakfast days (0-7)
    continental_days        INTEGER     DEFAULT 0 CHECK (continental_days >= 0 AND continental_days <= 7),

    -- Q2: Allow same dish to repeat within a day (Breakfast+Dinner)
    allow_same_day_repeat   BOOLEAN     DEFAULT false,

    -- Q3: Allow same dish to repeat within the week
    allow_same_week_repeat  BOOLEAN     DEFAULT true,

    -- Q4: Prefer millet-based recipes this week
    prefer_millet           BOOLEAN     DEFAULT false,

    created_at              TIMESTAMP   DEFAULT NOW(),
    updated_at              TIMESTAMP   DEFAULT NOW(),

    UNIQUE (house_id, week_start)
);

COMMENT ON TABLE public.weekly_generation_config IS
    'Weekly questionnaire responses captured before plan generation.
     Stored for 8 weeks to feed ML auto-learning (Bucket B).
     After 8 weeks system auto-learns and stops showing questionnaire.
     One row per household per week.';

CREATE INDEX IF NOT EXISTS idx_weekly_gen_config_house
    ON public.weekly_generation_config(house_id, week_start DESC);

-- Verify
SELECT 'weekly_generation_config created' as status;
