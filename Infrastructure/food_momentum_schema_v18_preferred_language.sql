-- ============================================================
-- Schema v18 — Add preferred_language to household_master
-- Purpose: Store household's preferred regional language
--          so the app loads the correct translation JSON on login.
-- Supported values: 'en' (English), 'ta' (Tamil)
-- Default: 'en' — English
-- Date: 16 May 2026
-- ============================================================

-- STEP 1: Add preferred_language column
ALTER TABLE public.household_master
    ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(5) DEFAULT 'en';

-- STEP 2: Set existing households to English default
UPDATE public.household_master
SET preferred_language = 'en'
WHERE preferred_language IS NULL;

-- STEP 3: Verify
SELECT household_id, preferred_language
FROM public.household_master
LIMIT 5;
