-- ============================================================
-- Schema v13 — Member profiles, ingredient images, optional email
-- Run after: food_momentum_schema_v12_onboarding.sql
-- ============================================================
-- Changes:
--   1. member_preferences — add age_group, gender, display_name
--   2. ingredient_catalog — add image_url, thumb_url
--   3. users — email becomes optional (nullable)
--   4. users — phone_number added (optional)
-- ============================================================

-- ── 1. member_preferences additions ──────────────────────────────────────────
ALTER TABLE member_preferences
    ADD COLUMN IF NOT EXISTS age_group    VARCHAR(20)
        CHECK (age_group IN ('Child', 'Teen', 'Adult', 'Senior')),
    ADD COLUMN IF NOT EXISTS gender       VARCHAR(30)
        CHECK (gender IN ('Male', 'Female', 'Transgender', 'Prefer not to say')),
    ADD COLUMN IF NOT EXISTS display_name VARCHAR(50);  -- nickname — post-MVP but column ready now

COMMENT ON COLUMN member_preferences.age_group IS
    'Child = 0-12, Teen = 13-17, Adult = 18-59, Senior = 60+.
     Set by admin or member themselves from My Profile screen.';

COMMENT ON COLUMN member_preferences.gender IS
    'Male, Female, Transgender, Prefer not to say.
     Optional — used for dietary analysis and ML training.';

COMMENT ON COLUMN member_preferences.display_name IS
    'Nickname shown in UI instead of full name. Post-MVP feature — column ready.';


-- ── 2. ingredient_catalog image columns ──────────────────────────────────────
ALTER TABLE ingredient_catalog
    ADD COLUMN IF NOT EXISTS image_url  VARCHAR(255),   -- full size image
    ADD COLUMN IF NOT EXISTS thumb_url  VARCHAR(255);   -- thumbnail for list views

COMMENT ON COLUMN ingredient_catalog.image_url IS
    'Full size ingredient image URL — AI generated or curated.';

COMMENT ON COLUMN ingredient_catalog.thumb_url IS
    'Thumbnail image URL — used in Satvik selection, recipe ingredient lists.';


-- ── 3. users — email becomes optional ────────────────────────────────────────
-- Members created by admin may not have email or login credentials.
-- Email only required when member wants their own login.
ALTER TABLE users
    ALTER COLUMN email DROP NOT NULL;

-- Add unique constraint that allows multiple NULLs (NULL != NULL in SQL)
-- Drop existing unique constraint first if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'users_email_key'
    ) THEN
        ALTER TABLE users DROP CONSTRAINT users_email_key;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_unique
    ON users(email)
    WHERE email IS NOT NULL;

COMMENT ON COLUMN users.email IS
    'Optional — only required for login. Members without email cannot log in.
     Admin manages their data entirely. NULL allowed — multiple NULLs permitted.';


-- ── 4. users — phone number (optional) ───────────────────────────────────────
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);

COMMENT ON COLUMN users.phone_number IS
    'Optional phone number. Future use for WhatsApp notifications, OTP via SMS.';


-- ── 5. Enums for age_group and gender as reference ───────────────────────────
-- Not creating DB enums — VARCHAR with CHECK is more flexible for future additions
-- Reference values:
--   age_group: Child (0-12), Teen (13-17), Adult (18-59), Senior (60+)
--   gender:    Male, Female, Transgender, Prefer not to say
