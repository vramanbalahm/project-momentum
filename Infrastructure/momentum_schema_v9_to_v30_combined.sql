-- ============================================================
-- BEGIN: food_momentum_schema_v9_regional_flag.sql
-- ============================================================
-- ============================================================
-- Schema v9 — recipe_dna_master: add is_regional_specific flag
-- Run after: food_momentum_schema_v8_profile_audit.sql
-- ============================================================

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS is_regional_specific BOOLEAN DEFAULT false;

COMMENT ON COLUMN recipe_dna_master.is_regional_specific IS
    'true = dish is distinctly associated with a specific sub-region.
     false = dish is a staple eaten widely across the state regardless of sub-region.
     Set by Gemini during recipe seeding — not manually maintained.';

-- END: food_momentum_schema_v9_regional_flag.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v10_recipe_fields.sql
-- ============================================================
-- ============================================================
-- Schema v10 — Store all Gemini-generated recipe fields
-- Run after: food_momentum_schema_v9_regional_flag.sql
-- ============================================================

-- Add missing columns to recipe_dna_master
ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS regional_name      VARCHAR(255),   -- name in local language (Tamil, Telugu etc.)
    ADD COLUMN IF NOT EXISTS sub_region         VARCHAR(150),   -- e.g. Chettinad, Tirunelveli, Kongu Nadu
    ADD COLUMN IF NOT EXISTS meal_slots         TEXT[],         -- e.g. {Breakfast,Lunch} — PostgreSQL array
    ADD COLUMN IF NOT EXISTS prep_time_mins     INTEGER,        -- preparation time in minutes
    ADD COLUMN IF NOT EXISTS cook_time_mins     INTEGER,        -- cooking time in minutes
    ADD COLUMN IF NOT EXISTS serves             INTEGER,        -- number of servings
    ADD COLUMN IF NOT EXISTS tags               TEXT[],         -- e.g. {fermented, street food, spicy}
    ADD COLUMN IF NOT EXISTS source_region      VARCHAR(100),   -- state/region this recipe belongs to e.g. Tamil Nadu
    ADD COLUMN IF NOT EXISTS created_by_ai      BOOLEAN DEFAULT true,  -- true = seeded by Gemini
    ADD COLUMN IF NOT EXISTS ai_model           VARCHAR(100);   -- which model generated this e.g. gemini-2.5-flash-lite

COMMENT ON COLUMN recipe_dna_master.regional_name IS 'Dish name in local language — Tamil, Telugu, Kannada etc.';
COMMENT ON COLUMN recipe_dna_master.sub_region IS 'Specific sub-region this dish is associated with e.g. Chettinad, Tirunelveli';
COMMENT ON COLUMN recipe_dna_master.meal_slots IS 'Which meal slots this dish is suitable for — PostgreSQL text array';
COMMENT ON COLUMN recipe_dna_master.tags IS 'Descriptive tags for filtering and discovery e.g. fermented, street food, spicy';
COMMENT ON COLUMN recipe_dna_master.source_region IS 'State or region this recipe belongs to e.g. Tamil Nadu, Kerala';
COMMENT ON COLUMN recipe_dna_master.created_by_ai IS 'true = seeded by Gemini AI, false = manually added';
COMMENT ON COLUMN recipe_dna_master.ai_model IS 'Gemini model version used to generate this recipe';

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_recipe_sub_region  ON recipe_dna_master(sub_region);
CREATE INDEX IF NOT EXISTS idx_recipe_source_region ON recipe_dna_master(source_region);
CREATE INDEX IF NOT EXISTS idx_recipe_meal_slots  ON recipe_dna_master USING GIN(meal_slots);
CREATE INDEX IF NOT EXISTS idx_recipe_tags        ON recipe_dna_master USING GIN(tags);

-- END: food_momentum_schema_v10_recipe_fields.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v11_ingredient_catalog.sql
-- ============================================================
-- ============================================================
-- Schema v11 — ingredient_catalog + recipe_ingredients
-- Run after: food_momentum_schema_v10_recipe_fields.sql
-- ============================================================
-- Design decisions:
--   ingredient_catalog  — master list of all ingredients known to the system
--                         source of truth for recipe, pantry, and future market linkage
--   recipe_ingredients  — links recipe_dna_master → ingredient_catalog
--                         with quantity and unit per ingredient
--
-- Existing tables NOT touched:
--   ingredient_master       — market/price metadata (shelf life, price thresholds)
--   ingredient_translations — multi-language names for market ingredients
--   staple_master_registry  — market staples for price tracking
-- ============================================================

-- ── 1. ingredient_catalog ─────────────────────────────────────────────────────
-- Master list of all ingredients — populated by Gemini during recipe seeding.
-- One row per unique ingredient in English.
-- Tamil and other language names stored in ingredient_catalog_translations.

CREATE TABLE IF NOT EXISTS ingredient_catalog (
    id              SERIAL PRIMARY KEY,
    name_en         VARCHAR(200) NOT NULL UNIQUE,   -- English name — deduplication key
    name_ta         VARCHAR(200),                   -- Tamil name if known
    category        VARCHAR(50),                    -- Vegetable, Lentil, Spice, Oil, Dairy, Grain, Meat, Seafood, Fruit, Nut, Other
    is_sattvic      BOOLEAN DEFAULT true,
    is_vegan        BOOLEAN DEFAULT true,
    shelf_life_days INTEGER,                        -- optional — can link to ingredient_master later
    ingredient_master_id INTEGER REFERENCES ingredient_master(id), -- optional FK to market price table
    created_at      TIMESTAMP DEFAULT NOW(),
    created_by_ai   BOOLEAN DEFAULT true            -- true = added by Gemini seeding
);

CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_name_en ON ingredient_catalog(LOWER(name_en));
CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_category ON ingredient_catalog(category);

-- Enable trigram similarity search for fuzzy ingredient matching
-- (pg_trgm already installed via schema v5)
CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_trgm ON ingredient_catalog
    USING GIN (name_en gin_trgm_ops);

COMMENT ON TABLE ingredient_catalog IS
    'Master ingredient list — single source of truth for all ingredients in recipes.
     Populated by Gemini during seeding. Optional FK to ingredient_master for market price linkage.';

COMMENT ON COLUMN ingredient_catalog.ingredient_master_id IS
    'Optional link to ingredient_master (market/price table) when this ingredient is also a tracked market staple.';


-- ── 2. recipe_ingredients ─────────────────────────────────────────────────────
-- Links recipe_dna_master → ingredient_catalog.
-- One row per ingredient per recipe.
-- Replaces the ingredients_json blob in recipe_content_vault for structured queries.
-- ingredients_json is KEPT in recipe_content_vault as a fallback/display blob.

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id                  SERIAL PRIMARY KEY,
    recipe_id           UUID NOT NULL REFERENCES recipe_dna_master(recipe_id) ON DELETE CASCADE,
    ingredient_id       INTEGER NOT NULL REFERENCES ingredient_catalog(id) ON DELETE RESTRICT,
    quantity            VARCHAR(50),        -- e.g. "2", "1/2", "a pinch", "to taste"
    unit                VARCHAR(50),        -- e.g. "cups", "tbsp", "grams", "" for countable
    is_optional         BOOLEAN DEFAULT false,
    sort_order          INTEGER DEFAULT 0,  -- display order within recipe
    created_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe_id     ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

COMMENT ON TABLE recipe_ingredients IS
    'Normalised recipe-ingredient link table. One row per ingredient per recipe.
     Enables pantry check, ingredient search, and market price linkage.
     ingredients_json in recipe_content_vault is kept as display blob.';

COMMENT ON COLUMN recipe_ingredients.quantity IS
    'Raw quantity string from Gemini — e.g. "2", "1/2", "lemon-sized ball", "to taste".';

COMMENT ON COLUMN recipe_ingredients.is_optional IS
    'true = ingredient is optional or garnish. false = required for the dish.';

-- END: food_momentum_schema_v11_ingredient_catalog.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v12_onboarding.sql
-- ============================================================
-- ============================================================
-- Schema v12 — Onboarding Wizard Tables
-- Run after: food_momentum_schema_v11_ingredient_catalog.sql
-- ============================================================
-- Tables created:
--   1. panchangam_types        — lookup of all Panchangam types
--   2. panchangam_observations — lookup of all observation types
--   3. panchangam_master       — annual date master seeded by platform admin
--   4. member_preferences      — individual dietary preference per user
--   5. member_restrictions     — allergies + dislikes per user
--   6. satvik_restrictions     — Satvik ingredient exclusions per household
-- Additions to:
--   household_master           — panchangam_type_id + wizard step tracking
-- ============================================================


-- ── 1. panchangam_types ───────────────────────────────────────────────────────
-- Lookup table of all supported Panchangam types.
-- Seeded with known types — open for additions as we expand to new states.
-- Platform admin maintains this table.

CREATE TABLE IF NOT EXISTS panchangam_types (
    id              SERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,   -- e.g. TAMIL_VAKYA
    display_name    VARCHAR(100) NOT NULL,          -- e.g. Tamil - Vakya
    language        VARCHAR(50),                   -- e.g. Tamil, Telugu, Kannada
    region          VARCHAR(100),                  -- e.g. Tamil Nadu, Andhra Pradesh
    is_active       BOOLEAN DEFAULT true,
    sort_order      INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE panchangam_types IS
    'Lookup of all supported Panchangam types. No restriction — add as needed.
     Platform admin maintains. Used by household to declare which calendar they follow.';

-- Seed known Panchangam types
INSERT INTO panchangam_types (code, display_name, language, region, sort_order) VALUES
    ('TAMIL_VAKYA',      'Tamil - Vakya',              'Tamil',     'Tamil Nadu',        1),
    ('TAMIL_DRIK',       'Tamil - Drik Ganitha',       'Tamil',     'Tamil Nadu',        2),
    ('TELUGU',           'Telugu Panchangam',           'Telugu',    'Andhra / Telangana',3),
    ('KANNADA',          'Kannada Panchangam',          'Kannada',   'Karnataka',         4),
    ('MALAYALAM',        'Malayalam Panchangam',        'Malayalam', 'Kerala',            5),
    ('MARATHI',          'Marathi Panchangam',          'Marathi',   'Maharashtra',       6),
    ('GUJARATI',         'Gujarati Panchangam',         'Gujarati',  'Gujarat',           7),
    ('BENGALI',          'Bengali Panjika',             'Bengali',   'West Bengal',       8),
    ('HINDI_VIKRAMI',    'Hindi - Vikrami Samvat',      'Hindi',     'North India',       9),
    ('ODIA',             'Odia Panchangam',             'Odia',      'Odisha',           10)
ON CONFLICT (code) DO NOTHING;


-- ── 2. panchangam_observations ────────────────────────────────────────────────
-- Lookup of all observation types tracked across all Panchangams.
-- Open — Gemini defines what's relevant per Panchangam during annual seeding.
-- Platform admin maintains this table.

CREATE TABLE IF NOT EXISTS panchangam_observations (
    id              SERIAL PRIMARY KEY,
    code            VARCHAR(50) NOT NULL UNIQUE,   -- e.g. EKADASI_SHUKLA
    display_name    VARCHAR(100) NOT NULL,          -- e.g. Ekadasi (Shukla Paksha)
    local_name      VARCHAR(100),                  -- Tamil/regional name if applicable
    category        VARCHAR(50),                   -- Fasting / Auspicious / Festival / Other
    is_sattvic      BOOLEAN DEFAULT true,           -- true = Satvik meals recommended
    is_active       BOOLEAN DEFAULT true,
    sort_order      INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE panchangam_observations IS
    'Lookup of all observation types. Open — all observations tracked, no restriction.
     is_sattvic drives whether Satvik meals are recommended on this day.';

-- Seed common observations — Gemini will add more during annual seeding
INSERT INTO panchangam_observations (code, display_name, local_name, category, is_sattvic, sort_order) VALUES
    ('EKADASI_SHUKLA',   'Ekadasi (Shukla Paksha)',   'வளர்பிறை ஏகாதசி',  'Fasting',    true,  1),
    ('EKADASI_KRISHNA',  'Ekadasi (Krishna Paksha)',  'தேய்பிறை ஏகாதசி',  'Fasting',    true,  2),
    ('AMAVASYA',         'Amavasya',                  'அமாவாசை',           'Fasting',    true,  3),
    ('POURNAMI',         'Pournami',                  'பௌர்ணமி',           'Auspicious', true,  4),
    ('PRADOSHAM',        'Pradosham',                 'பிரதோஷம்',          'Fasting',    true,  5),
    ('SHIVARATRI',       'Maha Shivaratri',           'மகா சிவராத்திரி',   'Festival',   true,  6),
    ('KARTHIGAI',        'Karthigai Deepam',          'கார்த்திகை தீபம்',  'Festival',   false, 7),
    ('NAVRATRI',         'Navratri',                  'நவராத்திரி',        'Festival',   true,  8),
    ('DIWALI',           'Diwali',                    'தீபாவளி',           'Festival',   false, 9),
    ('PONGAL',           'Pongal / Sankranti',        'பொங்கல்',           'Festival',   false, 10),
    ('UGADI',            'Ugadi / Tamil New Year',    'உகாதி / புத்தாண்டு','Festival',   false, 11),
    ('VINAYAGAR',        'Vinayagar Chaturthi',       'விநாயகர் சதுர்த்தி','Festival',   false, 12),
    ('SKANDA_SASHTI',    'Skanda Sashti',             'ஸ்கந்த சஷ்டி',     'Festival',   true,  13),
    ('THIRUVATHIRAI',    'Thiruvathirai',             'திருவாதிரை',        'Festival',   true,  14),
    ('SANKATAHARA',      'Sankatahara Chaturthi',     'சங்கடஹர சதுர்த்தி','Fasting',    true,  15)
ON CONFLICT (code) DO NOTHING;


-- ── 3. panchangam_master ──────────────────────────────────────────────────────
-- Annual date master — seeded once per year by platform admin via Gemini script.
-- One row per observation per Panchangam type per year.
-- Source of truth for all lunar event date generation.

CREATE TABLE IF NOT EXISTS panchangam_master (
    id                      SERIAL PRIMARY KEY,
    panchangam_type_id      INTEGER NOT NULL REFERENCES panchangam_types(id),
    observation_id          INTEGER NOT NULL REFERENCES panchangam_observations(id),
    observation_date        DATE NOT NULL,
    year                    INTEGER NOT NULL,      -- calendar year
    tithi                   VARCHAR(100),          -- lunar day name if applicable
    paksha                  VARCHAR(20),           -- Shukla or Krishna
    notes                   TEXT,                 -- any special notes for this occurrence
    created_at              TIMESTAMP DEFAULT NOW(),
    created_by_ai           BOOLEAN DEFAULT true,  -- true = seeded by Gemini
    UNIQUE (panchangam_type_id, observation_id, observation_date)
);

CREATE INDEX IF NOT EXISTS idx_panchangam_master_type_year
    ON panchangam_master(panchangam_type_id, year);
CREATE INDEX IF NOT EXISTS idx_panchangam_master_date
    ON panchangam_master(observation_date);

COMMENT ON TABLE panchangam_master IS
    'Annual date master for all Panchangam types and observations.
     Seeded once per year by platform admin via Gemini script (seed_panchangam.py).
     Drives auto-population of household event_master rows for lunar events.';

COMMENT ON COLUMN panchangam_master.year IS
    'Calendar year this observation falls in. Used to reseed annually.';


-- ── 4. member_preferences ────────────────────────────────────────────────────
-- Individual dietary preference per user.
-- One row per user — separate from household dietary preference.
-- Drives personalised recommendations when only that member is home.

CREATE TABLE IF NOT EXISTS member_preferences (
    id                  SERIAL PRIMARY KEY,
    user_id             UUID NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    house_id            UUID NOT NULL REFERENCES household_master(household_id) ON DELETE CASCADE,
    dietary_preference  diet_pref DEFAULT 'Veg',
    updated_at          TIMESTAMP DEFAULT NOW(),
    updated_by          UUID REFERENCES users(user_id)  -- admin who last updated
);

CREATE INDEX IF NOT EXISTS idx_member_preferences_house ON member_preferences(house_id);
CREATE INDEX IF NOT EXISTS idx_member_preferences_user  ON member_preferences(user_id);

COMMENT ON TABLE member_preferences IS
    'Individual dietary preference per user. Separate from household dietary_preference.
     Used when only specific members are home — system personalises recommendations.
     One row per user, maintained by admin or the user themselves.';


-- ── 5. member_restrictions ───────────────────────────────────────────────────
-- Allergies and dislikes per member.
-- Linked to ingredient_catalog — no free text.
-- If ingredient not in catalog, it must be added to ingredient_catalog first.

CREATE TABLE IF NOT EXISTS member_restrictions (
    id                  SERIAL PRIMARY KEY,
    user_id             UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    house_id            UUID NOT NULL REFERENCES household_master(household_id) ON DELETE CASCADE,
    ingredient_id       INTEGER NOT NULL REFERENCES ingredient_catalog(id) ON DELETE RESTRICT,
    restriction_type    VARCHAR(10) NOT NULL CHECK (restriction_type IN ('Allergy', 'Dislike')),
    -- Both Allergy and Dislike can exist for same ingredient (different rows)
    notes               TEXT,                     -- optional context e.g. "severe reaction"
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_by          UUID REFERENCES users(user_id),
    UNIQUE (user_id, ingredient_id, restriction_type)
);

CREATE INDEX IF NOT EXISTS idx_member_restrictions_user  ON member_restrictions(user_id);
CREATE INDEX IF NOT EXISTS idx_member_restrictions_house ON member_restrictions(house_id);

COMMENT ON TABLE member_restrictions IS
    'Allergies and dislikes per member. Linked to ingredient_catalog — no free text.
     Both Allergy and Dislike can exist for the same ingredient (separate rows).
     Drives recipe exclusion during recommendation.';

COMMENT ON COLUMN member_restrictions.restriction_type IS
    'Allergy = medical — ingredient must never appear in any recommended dish.
     Dislike = preference — ingredient avoided where possible but not mandatory.';


-- ── 6. satvik_restrictions ───────────────────────────────────────────────────
-- Household-level Satvik definition — which ingredients to avoid on Satvik days.
-- Linked to ingredient_catalog — no free text.
-- Applied automatically on all Satvik-tagged event_master days.

CREATE TABLE IF NOT EXISTS satvik_restrictions (
    id                  SERIAL PRIMARY KEY,
    house_id            UUID NOT NULL REFERENCES household_master(household_id) ON DELETE CASCADE,
    ingredient_id       INTEGER NOT NULL REFERENCES ingredient_catalog(id) ON DELETE RESTRICT,
    is_avoided          BOOLEAN DEFAULT true,      -- true = avoid on Satvik days
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_by          UUID REFERENCES users(user_id),
    UNIQUE (house_id, ingredient_id)
);

CREATE INDEX IF NOT EXISTS idx_satvik_restrictions_house ON satvik_restrictions(house_id);

COMMENT ON TABLE satvik_restrictions IS
    'Household Satvik definition — ingredients to avoid on Satvik days.
     Linked to ingredient_catalog. Applied on all event_master rows where is_sattvic_required = true.
     One row per ingredient per household.';


-- ── 7. Additions to household_master ─────────────────────────────────────────
-- panchangam_type_id  — which Panchangam the household follows
-- Wizard step tracking — drives progress indicator on wizard UI
-- onboarding_done already exists — used as final confirm flag

ALTER TABLE household_master
    ADD COLUMN IF NOT EXISTS panchangam_type_id     INTEGER REFERENCES panchangam_types(id),
    ADD COLUMN IF NOT EXISTS wizard_members_done    BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS wizard_satvik_done     BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS wizard_events_done     BOOLEAN DEFAULT false;

COMMENT ON COLUMN household_master.panchangam_type_id IS
    'Which Panchangam this household follows. FK to panchangam_types.
     Drives auto-population of lunar event dates from panchangam_master.
     NULL = not set yet (wizard not completed).';

COMMENT ON COLUMN household_master.wizard_members_done IS
    'true = member profiles step completed in onboarding wizard.';

COMMENT ON COLUMN household_master.wizard_satvik_done IS
    'true = Satvik definition step completed in onboarding wizard.';

COMMENT ON COLUMN household_master.wizard_events_done IS
    'true = events step completed in onboarding wizard.
     Note: existing onboarding_done column = final confirm button pressed.';

-- END: food_momentum_schema_v12_onboarding.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v13_member_profile.sql
-- ============================================================
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

-- END: food_momentum_schema_v13_member_profile.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v14_household_restrictions.sql
-- ============================================================
-- Schema v14 — household_restrictions table
-- Household-level ingredient restrictions (allergy / dislike) — applies to all members
-- Run this on food_momentum_db

CREATE TABLE IF NOT EXISTS public.household_restrictions (
    id              uuid DEFAULT gen_random_uuid() NOT NULL,
    house_id        uuid NOT NULL,
    ingredient_id   integer NOT NULL,
    restriction_type varchar(20) NOT NULL CHECK (restriction_type IN ('Allergy', 'Dislike')),
    updated_by      uuid,
    updated_at      timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT household_restrictions_pkey PRIMARY KEY (id),
    CONSTRAINT household_restrictions_house_fkey
        FOREIGN KEY (house_id) REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    CONSTRAINT household_restrictions_ingredient_fkey
        FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_catalog(id) ON DELETE CASCADE,
    CONSTRAINT household_restrictions_unique
        UNIQUE (house_id, ingredient_id, restriction_type)
);

CREATE INDEX IF NOT EXISTS idx_household_restrictions_house
    ON public.household_restrictions(house_id);

COMMENT ON TABLE public.household_restrictions IS
    'Household-level ingredient restrictions — ingredients no one in the family eats. '
    'Applied globally to all meal suggestions regardless of individual member restrictions.';

-- END: food_momentum_schema_v14_household_restrictions.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v15_recipe_review.sql
-- ============================================================
-- ============================================================
-- Momentum Schema v15 — Recipe Review Workflow
-- Purpose: Add review_status to recipe_dna_master,
--          youtube_urls to recipe_content_vault
-- Date: May 2026
--
-- Run on food_momentum_db
-- ============================================================

-- ── 1. Add review_status to recipe_dna_master ─────────────────────────────

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS review_status varchar(20) DEFAULT 'under_review'
        CHECK (review_status IN ('under_review', 'approved', 'rejected'));

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS reviewed_by uuid;

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS reviewed_at timestamp without time zone;

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS review_notes text;

-- All existing AI-seeded recipes start as under_review
UPDATE public.recipe_dna_master
SET review_status = 'under_review'
WHERE review_status IS NULL;

-- Index for fast filtering by status
CREATE INDEX IF NOT EXISTS idx_recipe_review_status
    ON public.recipe_dna_master(review_status);

-- ── 2. Add youtube_urls to recipe_content_vault ───────────────────────────
-- Replaces single video_url with array of up to 3 URLs

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS youtube_urls text[] DEFAULT '{}';

-- Migrate existing video_url into youtube_urls array if present
UPDATE public.recipe_content_vault
SET youtube_urls = ARRAY[video_url]
WHERE video_url IS NOT NULL
  AND video_url != ''
  AND (youtube_urls IS NULL OR youtube_urls = '{}');

-- ── 3. Verify ─────────────────────────────────────────────────────────────

SELECT 'REVIEW STATUS DISTRIBUTION' as check_name,
       review_status, COUNT(*) as count
FROM recipe_dna_master
GROUP BY review_status;

SELECT 'RECIPE_CONTENT_VAULT COLUMNS' as check_name,
       column_name, data_type
FROM information_schema.columns
WHERE table_name = 'recipe_content_vault'
ORDER BY ordinal_position;

-- END: food_momentum_schema_v15_recipe_review.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v15b_image_tracking.sql
-- ============================================================
-- ============================================================
-- Momentum Schema v15b — Image Generation Tracking
-- Purpose: Track how many times an image has been generated
--          per recipe — enforces 2-attempt limit for QA
-- Date: May 2026
-- Run on: food_momentum_db
-- ============================================================

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_generation_count integer DEFAULT 0;

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_last_generated_at timestamp without time zone;

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_generated_by uuid;

COMMENT ON COLUMN public.recipe_content_vault.image_generation_count IS
    'Number of times image was generated. Max 2 for QA role. Platform admin can override.';

-- Verify
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'recipe_content_vault'
ORDER BY ordinal_position;

-- END: food_momentum_schema_v15b_image_tracking.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v16_reviewer_role.sql
-- ============================================================
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

-- END: food_momentum_schema_v16_reviewer_role.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v16b_reviewer_role.sql
-- ============================================================
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

-- END: food_momentum_schema_v16b_reviewer_role.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v17_saved_status.sql
-- ============================================================
-- ============================================================
-- Schema v17 — Add 'saved' to review_status CHECK constraint
-- Purpose: Allow reviewers to save work-in-progress recipes
--          and return to them later via a dedicated Saved tab.
-- Date: 13 May 2026
-- ============================================================

-- STEP 1: Drop the existing CHECK constraint on review_status
ALTER TABLE public.recipe_dna_master
    DROP CONSTRAINT IF EXISTS recipe_dna_master_review_status_check;

-- STEP 2: Re-add the constraint with 'saved' included
ALTER TABLE public.recipe_dna_master
    ADD CONSTRAINT recipe_dna_master_review_status_check
    CHECK (review_status IN ('under_review', 'approved', 'rejected', 'saved'));

-- STEP 3: Verify
SELECT
    review_status,
    COUNT(*) AS count
FROM public.recipe_dna_master
GROUP BY review_status
ORDER BY review_status;

-- END: food_momentum_schema_v17_saved_status.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v18_preferred_language.sql
-- ============================================================
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

-- END: food_momentum_schema_v18_preferred_language.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v19_lunar_integration.sql
-- ============================================================
-- ============================================================
-- Schema v19 — Lunar Calendar Integration
-- Date: 2026-05-30
-- Changes:
--   1. Add panchangam_type_id (nullable) to event_master
--      - source='ADMIN' lunar rows: set to household's panchangam type
--      - source='USER' personal rows: NULL (birthdays etc.)
--   2. Drop UNIQUE constraint on event_master.event_code
--      - event_master uses event_id (UUID) as primary key
--      - Multiple lunar events per year have same event_name
--      - UNIQUE constraint remains on panchangam_master (correct)
--
-- Architecture:
--   panchangam_master  → platform calendar (admin seeded, read-only)
--   event_master       → household events (lunar + personal)
--     source='ADMIN'   → copied from panchangam_master by system
--     source='USER'    → added by household (birthdays etc.)
--   is_active flag     → controls which lunar observations household follows
-- ============================================================

-- STEP 1: Add panchangam_type_id to event_master
ALTER TABLE public.event_master
    ADD COLUMN IF NOT EXISTS panchangam_type_id INTEGER REFERENCES public.panchangam_types(id);

COMMENT ON COLUMN public.event_master.panchangam_type_id IS
    'Which Panchangam this event belongs to.
     Set for source=ADMIN lunar events (copied from panchangam_master).
     NULL for source=USER personal events (birthdays, anniversaries etc.).
     Used to identify and replace all lunar rows when household changes Panchangam type.';

-- STEP 2: Drop UNIQUE constraint on event_master.event_code
-- event_master uses event_id (UUID) as primary key.
-- Multiple lunar events can have same event_name (Pradosham repeats monthly).
-- UNIQUE constraint on panchangam_master is correct and stays.
ALTER TABLE public.event_master
    DROP CONSTRAINT IF EXISTS event_master_event_code_key;

-- STEP 3: Add indexes for efficient lookups
-- For recommendation engine — check if today is a Satvik day for a household
CREATE INDEX IF NOT EXISTS idx_event_master_house_date_satvik
    ON public.event_master(house_id, event_date)
    WHERE is_active = true AND is_sattvic_required = true;

-- For lunar setup — find all household lunar events by panchangam type
CREATE INDEX IF NOT EXISTS idx_event_master_house_panchangam
    ON public.event_master(house_id, panchangam_type_id)
    WHERE source = 'ADMIN';

-- STEP 4: Fix existing ADMIN data — all ADMIN rows must be event_type = 'Lunar'
UPDATE public.event_master
SET event_type = 'Lunar'
WHERE source = 'ADMIN'
AND event_type != 'Lunar';

-- STEP 5: Add CHECK constraint to enforce ADMIN = Lunar only
-- Drop existing check first then recreate
ALTER TABLE public.event_master
    DROP CONSTRAINT IF EXISTS event_master_event_type_check;

ALTER TABLE public.event_master
    ADD CONSTRAINT event_master_event_type_check CHECK (
        (source = 'ADMIN' AND event_type = 'Lunar')
        OR
        (source = 'USER' AND event_type IN ('Lunar', 'Social', 'Ritual', 'Personal'))
    );

-- STEP 6: Verify
SELECT
    source,
    event_type,
    panchangam_type_id,
    COUNT(*) as row_count
FROM public.event_master
GROUP BY source, event_type, panchangam_type_id
ORDER BY source, event_type;

-- END: food_momentum_schema_v19_lunar_integration.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v20_pantry.sql
-- ============================================================
-- ============================================================
-- Schema v20 — My Pantry (household ingredient availability)
-- Date: 2026-06-01
-- Purpose: Track which ingredients a household has available.
--          Used by Recommendation Engine (F09) to prefer recipes
--          that use available ingredients.
-- ============================================================

-- household_pantry — one row per ingredient per household
CREATE TABLE IF NOT EXISTS public.household_pantry (
    pantry_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    house_id        UUID NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    ingredient_id   INTEGER NOT NULL REFERENCES public.ingredient_catalog(id) ON DELETE CASCADE,
    is_available    BOOLEAN NOT NULL DEFAULT true,
    updated_at      TIMESTAMP DEFAULT NOW(),
    UNIQUE (house_id, ingredient_id)
);

COMMENT ON TABLE public.household_pantry IS
    'Tracks ingredient availability per household.
     Populated by user from My Pantry screen.
     Used by recommendation engine (F09) to prefer recipes with available ingredients.
     is_available=true means ingredient is currently in stock.';

-- Indexes for fast lookup
CREATE INDEX IF NOT EXISTS idx_household_pantry_house
    ON public.household_pantry(house_id)
    WHERE is_available = true;

CREATE INDEX IF NOT EXISTS idx_household_pantry_ingredient
    ON public.household_pantry(ingredient_id);

-- Add emoji column to ingredient_catalog for My Pantry display
ALTER TABLE public.ingredient_catalog
    ADD COLUMN IF NOT EXISTS emoji VARCHAR(10) DEFAULT NULL;

COMMENT ON COLUMN public.ingredient_catalog.emoji IS
    'Emoji icon for display in My Pantry screen. MVP uses emoji instead of images.';

-- Seed default emojis per category
UPDATE public.ingredient_catalog SET emoji = '🥬' WHERE category = 'Vegetable' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥩' WHERE category = 'Meat' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🐟' WHERE category = 'Seafood' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥛' WHERE category = 'Dairy' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🌾' WHERE category = 'Grain' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🫘' WHERE category = 'Lentil' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🌶️' WHERE category = 'Spice' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🫙' WHERE category = 'Oil' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🍎' WHERE category = 'Fruit' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥜' WHERE category = 'Nut' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🧂' WHERE category = 'Other' AND emoji IS NULL;

-- Verify
SELECT category, emoji, COUNT(*) as ingredient_count
FROM public.ingredient_catalog
GROUP BY category, emoji
ORDER BY category;

-- END: food_momentum_schema_v20_pantry.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v21_recommendation_engine.sql
-- ============================================================
-- ============================================================
-- Schema v21 — Recommendation Engine Bucket A
-- Date: 2026-06-02
-- Changes:
--   1. Add execution_order to feature_registry
--   2. Seed Bucket A recommendation formula entries
--   3. Create plan_audit_log table (Bucket C)
-- ============================================================

-- STEP 1: No schema change to feature_registry needed
-- Pipeline sequence is defined in recommendation_service.py (not DB)
-- feature_registry only stores: function_name, is_active, description

-- STEP 2: Seed Bucket A recommendation formula entries
INSERT INTO public.feature_registry
    (feature_code, feature_name, function_name, router_file,
     is_mandatory, is_active, depends_on, description)
VALUES
    ('RA-F03',  'Member availability filter',     'filter_by_availability',     'services/recommendation_service.py', true,  true,  '{FT-030}',  'F03: Get present members per day+slot. Assumes all home if no data.'),
    ('RA-FA01', 'Allergy hard block',             'filter_by_allergies',        'services/recommendation_service.py', true,  true,  '{RA-F03}',  'FA01: Hard block allergens for present members. No exceptions.'),
    ('RA-F02',  'Effective diet calculation',     'calc_effective_diet',        'services/recommendation_service.py', true,  true,  '{RA-F03}',  'F02: Strictest diet among present members. Vegan>Veg>Eggitarian>Non-Veg.'),
    ('RA-F01',  'Diet filter on vault',           'filter_by_diet',             'services/recommendation_service.py', true,  true,  '{RA-F02}',  'F01: Filter approved recipes by effective diet.'),
    ('RA-FA02', 'Satvik day check',               'check_satvik_day',           'services/recommendation_service.py', false, true,  '{RA-F01}',  'FA02: Check event_master for Satvik days this week.'),
    ('RA-F08',  'Satvik ingredient filter',       'filter_satvik_ingredients',  'services/recommendation_service.py', false, true,  '{RA-FA02}', 'F08: On Satvik days exclude recipes with avoided ingredients.'),
    ('RA-F04',  'Meal slot and intensity filter', 'filter_by_meal_slot',        'services/recommendation_service.py', true,  true,  '{RA-F01}',  'F04: Breakfast=Light, Lunch/Dinner=Medium/Heavy.'),
    ('RA-F13',  'Breakfast model',                'apply_breakfast_model',      'services/recommendation_service.py', true,  true,  '{RA-F04}',  'F13: Breakfast-specific rules.'),
    ('RA-F14',  'Lunch model',                    'apply_lunch_model',          'services/recommendation_service.py', true,  true,  '{RA-F04}',  'F14: Lunch-specific rules.'),
    ('RA-F15',  'Dinner model',                   'apply_dinner_model',         'services/recommendation_service.py', true,  true,  '{RA-F04}',  'F15: Dinner-specific rules.'),
    ('RA-F16',  'Side dish auto-pairing',         'pair_side_dishes',           'services/recommendation_service.py', false, true,  '{RA-F13,RA-F14,RA-F15}', 'F16: Auto-pair sides with mains.'),
    ('RA-F05',  'No repeat within 1 week',        'filter_recent_recipes',      'services/recommendation_service.py', false, true,  '{RA-F01}',  'F05: Exclude recipes from past N weeks. Default=1 week.')
ON CONFLICT (feature_code) DO UPDATE SET
    is_active   = EXCLUDED.is_active,
    description = EXCLUDED.description,
    updated_at  = NOW();

-- STEP 3: Create plan_audit_log table (Bucket C)
CREATE TABLE IF NOT EXISTS public.plan_audit_log (
    log_id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id          UUID            NOT NULL DEFAULT gen_random_uuid(),  -- groups all logs from one generate_plan() call
    house_id        UUID            NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    week_start      DATE            NOT NULL,
    day_name        VARCHAR(10)     NOT NULL,  -- Monday, Tuesday etc.
    meal_slot       VARCHAR(10)     NOT NULL,  -- Breakfast, Lunch, Dinner
    feature_code    VARCHAR(20)     NOT NULL,  -- e.g. RA-F03, RA-SELECT (no FK)
    function_name   VARCHAR(100)    NOT NULL,
    recipes_in      INTEGER         NOT NULL DEFAULT 0,
    recipes_out     INTEGER         NOT NULL DEFAULT 0,
    filtered_count  INTEGER         NOT NULL DEFAULT 0,
    filter_reason   TEXT,
    filtered_ids    UUID[]          DEFAULT '{}',
    selected_id     UUID,
    execution_ms    INTEGER,
    created_at      TIMESTAMP       DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_run_id
    ON public.plan_audit_log(run_id);

COMMENT ON TABLE public.plan_audit_log IS
    'Bucket C — Audit log for recommendation engine formula execution.
     One row per formula per day+slot per plan generation.
     Platform admin uses this to troubleshoot customer issues.
     Feeds ML training data in Bucket B (post-MVP).
     Purge after 6 months.';

-- Indexes for fast admin lookup
CREATE INDEX IF NOT EXISTS idx_audit_log_house_week
    ON public.plan_audit_log(house_id, week_start);

CREATE INDEX IF NOT EXISTS idx_audit_log_feature
    ON public.plan_audit_log(feature_code);

CREATE INDEX IF NOT EXISTS idx_audit_log_created
    ON public.plan_audit_log(created_at);

-- STEP 4: Household entitlement for no-repeat window (configurable per household)
CREATE TABLE IF NOT EXISTS public.household_plan_config (
    house_id                UUID    PRIMARY KEY REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    no_repeat_weeks         INTEGER DEFAULT 1,   -- RA-F05: no repeat within N weeks
    updated_at              TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE public.household_plan_config IS
    'Per-household configuration for recommendation engine parameters.
     no_repeat_weeks: how many weeks back to check for recipe repetition (default=1).';

-- STEP 5: Verify
SELECT feature_code, feature_name, function_name, is_active
FROM public.feature_registry
WHERE feature_code LIKE 'RA-%'
ORDER BY feature_code;

-- END: food_momentum_schema_v21_recommendation_engine.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v22_weekly_questionnaire.sql
-- ============================================================
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

-- END: food_momentum_schema_v22_weekly_questionnaire.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v23_meal_role.sql
-- ============================================================
-- ============================================================
-- Schema v23 — meal_role array on recipe_dna_master
-- Date: 2026-06-07
-- Purpose: Replace binary is_side_dish flag with meal_role array
--          so a dish can be both main AND side (e.g. Sambar)
-- Changes:
--   1. Add meal_role TEXT[] to recipe_dna_master
--   2. Migrate existing 'Side Dish' from meal_slots → meal_role
--   3. Remove 'Side Dish' from meal_slots
--   4. Add GIN index on meal_role
-- ============================================================

-- STEP 1: Add meal_role column
ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS meal_role TEXT[] DEFAULT '{main}';

COMMENT ON COLUMN public.recipe_dna_master.meal_role IS
    'Role of this dish — main, side, or both.
     {main}       = served as primary dish only (Biryani, Idli etc.)
     {side}       = served as accompaniment only (Chutney, Pickle, Papad)
     {main,side}  = can serve as either (Sambar, Rasam, Dal)
     Replaces the incorrect use of meal_slots for this purpose.';

-- STEP 2: Set meal_role based on current meal_slots data
-- Dishes with 'Side Dish' in meal_slots → meal_role = {side}
UPDATE public.recipe_dna_master
SET meal_role = '{side}'
WHERE meal_slots @> ARRAY['Side Dish']::text[]
AND NOT (meal_slots && ARRAY['Breakfast','Lunch','Dinner']::text[]);

-- Dishes with 'Side Dish' AND other slots → meal_role = {main,side}
UPDATE public.recipe_dna_master
SET meal_role = '{main,side}'
WHERE meal_slots @> ARRAY['Side Dish']::text[]
AND meal_slots && ARRAY['Breakfast','Lunch','Dinner']::text[];

-- Known dual-role dishes — can be both main and side
-- Sambar, Rasam, Dal — commonly served as side with rice but also as main
UPDATE public.recipe_dna_master
SET meal_role = '{main,side}'
WHERE LOWER(dish_name) SIMILAR TO '%(sambar|rasam|dal|dhal|kootu|kuzhambu|curry|gravy|chutney|raita|pachadi)%'
AND meal_role = '{main}';

-- Pure side dishes — never served as main
UPDATE public.recipe_dna_master
SET meal_role = '{side}'
WHERE LOWER(dish_name) SIMILAR TO '%(pickle|achar|papad|appalam|vadam|chutney|thogayal|podimas|raita|pachadi|salad|accompaniment)%'
AND meal_role = '{main}';

-- STEP 3: Remove 'Side Dish' from meal_slots array
-- meal_slots should only contain Breakfast, Lunch, Dinner
UPDATE public.recipe_dna_master
SET meal_slots = ARRAY(
    SELECT UNNEST(meal_slots)
    EXCEPT
    SELECT 'Side Dish'
)
WHERE meal_slots @> ARRAY['Side Dish']::text[];

-- For recipes that had ONLY 'Side Dish' in meal_slots (now empty)
-- Set them to all slots since sides can be served at any meal
UPDATE public.recipe_dna_master
SET meal_slots = ARRAY['Breakfast','Lunch','Dinner']::text[]
WHERE (meal_slots IS NULL OR array_length(meal_slots, 1) = 0)
AND meal_role @> ARRAY['side']::text[];

-- STEP 4: Add GIN index for fast meal_role queries
CREATE INDEX IF NOT EXISTS idx_recipe_meal_role
    ON public.recipe_dna_master USING GIN(meal_role);

-- STEP 5: Verify
SELECT
    meal_role,
    COUNT(*) as recipe_count,
    array_agg(DISTINCT unnest_slots) as slots_used
FROM recipe_dna_master,
     LATERAL unnest(COALESCE(meal_slots, ARRAY[]::text[])) as unnest_slots
GROUP BY meal_role
ORDER BY meal_role;

-- END: food_momentum_schema_v23_meal_role.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v24_dish_pairing.sql
-- ============================================================
-- ============================================================
-- Schema v24 — Dish Category + Pairing Matrix
-- Date: 2026-06-08
-- Purpose: Enable F16 side dish recommendation via pairing matrix
-- Changes:
--   1. Add dish_category to recipe_dna_master
--   2. Create dish_pairing_matrix table
--   3. Seed pairing matrix with compatibility rules
--   4. Auto-tag dish_category based on keywords
-- ============================================================

-- STEP 1: Add dish_category column
ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS dish_category VARCHAR(20) DEFAULT NULL;

COMMENT ON COLUMN public.recipe_dna_master.dish_category IS
    'Category used for side dish pairing recommendations.
     Main dish categories: tiffin | rice | bread | millet | other
     Side dish categories: wet | semi_dry | dry | condiment | sweet
     Used with dish_pairing_matrix to recommend compatible sides.';

-- STEP 2: Create pairing matrix
CREATE TABLE IF NOT EXISTS public.dish_pairing_matrix (
    id              SERIAL          PRIMARY KEY,
    main_category   VARCHAR(20)     NOT NULL,
    side_category   VARCHAR(20)     NOT NULL,
    compatibility   VARCHAR(15)     NOT NULL
                    CHECK (compatibility IN ('perfect', 'good', 'acceptable', 'never')),
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT NOW(),
    UNIQUE (main_category, side_category)
);

COMMENT ON TABLE public.dish_pairing_matrix IS
    'Compatibility matrix for main+side dish pairing.
     Used by F16 recommendation engine to suggest appropriate sides.
     Main categories: tiffin | rice | bread | millet | other
     Side categories: wet | semi_dry | dry | condiment | sweet
     Compatibility: perfect > good > acceptable > never';

-- STEP 3: Seed pairing matrix
INSERT INTO public.dish_pairing_matrix (main_category, side_category, compatibility, notes)
VALUES
    -- Tiffin (Idli, Dosa, Pongal, Upma, Appam)
    ('tiffin',  'wet',        'perfect',    'Sambar/Rasam with Idli/Dosa is classic'),
    ('tiffin',  'condiment',  'perfect',    'Chutney is essential with tiffin'),
    ('tiffin',  'semi_dry',   'never',      'Kootu/Aviyal not served with tiffin'),
    ('tiffin',  'dry',        'never',      'Poriyal not served with tiffin'),
    ('tiffin',  'sweet',      'acceptable', 'Occasional sweet alongside tiffin'),

    -- Rice (plain rice, curd rice, lemon rice, tamarind rice)
    ('rice',    'wet',        'perfect',    'Sambar/Rasam/Kuzhambu essential with rice'),
    ('rice',    'dry',        'perfect',    'Poriyal/Thoran alongside rice'),
    ('rice',    'semi_dry',   'perfect',    'Kootu/Aviyal works well with rice'),
    ('rice',    'condiment',  'good',       'Pickle/Papad as accompaniment'),
    ('rice',    'sweet',      'acceptable', 'Payasam as dessert after rice meal'),

    -- Bread (Chapati, Roti, Parotta, Naan)
    ('bread',   'wet',        'perfect',    'Curry/Dal/Gravy essential with bread'),
    ('bread',   'condiment',  'good',       'Raita/Chutney alongside bread'),
    ('bread',   'dry',        'acceptable', 'Dry sabzi can accompany bread'),
    ('bread',   'semi_dry',   'acceptable', 'Thick gravy works with bread'),
    ('bread',   'sweet',      'never',      'Sweet not typically served with bread meal'),

    -- Millet (Ragi koozh, Kambu roti, Thinai dishes)
    ('millet',  'wet',        'perfect',    'Kuzhambu/Curry with millet dishes'),
    ('millet',  'condiment',  'perfect',    'Chutney/Buttermilk essential with millet'),
    ('millet',  'dry',        'good',       'Dry sides work with millet'),
    ('millet',  'semi_dry',   'good',       'Semi-dry sides complement millet'),
    ('millet',  'sweet',      'never',      'Sweet not paired with millet meals'),

    -- Other (catch-all for unclassified mains)
    ('other',   'wet',        'good',       'Default pairing'),
    ('other',   'condiment',  'good',       'Default pairing'),
    ('other',   'dry',        'acceptable', 'Default pairing'),
    ('other',   'semi_dry',   'acceptable', 'Default pairing'),
    ('other',   'sweet',      'acceptable', 'Default pairing')

ON CONFLICT (main_category, side_category) DO UPDATE SET
    compatibility = EXCLUDED.compatibility,
    notes = EXCLUDED.notes;

-- STEP 4: Auto-tag main dish categories
-- Tiffin
UPDATE public.recipe_dna_master
SET dish_category = 'tiffin'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(idli|dosa|pongal|upma|rava|uttapam|adai|appam|idiyappam|puttu|kichadi|paniyaram|sevai|idiappam|pesarattu|akki roti|set dosa|uthappam)%';

-- Rice
UPDATE public.recipe_dna_master
SET dish_category = 'rice'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(rice|sadam|sadham|bath|biryani|pulao|pulav|fried rice|saatham|puliyodarai|lemon rice|curd rice|tomato rice|bisi bele)%';

-- Bread
UPDATE public.recipe_dna_master
SET dish_category = 'bread'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(chapati|roti|parotta|paratha|naan|kulcha|puri|poori|bhatura|porotta)%';

-- Millet
UPDATE public.recipe_dna_master
SET dish_category = 'millet'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(ragi|kambu|thinai|varagu|millet|koozh|kali|sorghum|bajra|jowar|foxtail)%';

-- Other — catch-all for remaining mains
UPDATE public.recipe_dna_master
SET dish_category = 'other'
WHERE meal_role @> ARRAY['main']::text[]
AND dish_category IS NULL;

-- STEP 5: Auto-tag side dish categories
-- Wet — pourable gravy/liquid sides
UPDATE public.recipe_dna_master
SET dish_category = 'wet'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(sambar|rasam|kuzhambu|kozhambu|kulambu|dal|dhal|curry|gravy|salna|soup|kadhi|mor kuzhambu|sodhi|stew|shorba)%';

-- Semi-dry — thick, spoonable
UPDATE public.recipe_dna_master
SET dish_category = 'semi_dry'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(kootu|aviyal|olan|erissery|mixed veg|korma|kurma|masala|sabzi|bhaji|palya)%'
AND dish_category IS NULL;

-- Condiment — chutney, pickle, papad
UPDATE public.recipe_dna_master
SET dish_category = 'condiment'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(chutney|thogayal|pickle|achar|papad|appalam|vadam|raita|pachadi|thuvaiyal|podimas|podi|salsa)%'
AND dish_category IS NULL;

-- Sweet — desserts
UPDATE public.recipe_dna_master
SET dish_category = 'sweet'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(payasam|kheer|halwa|ladoo|barfi|sweet|poli|pongal sweet|sakkarai|dessert|pudding|kesari|jigarthanda)%'
AND dish_category IS NULL;

-- Dry — poriyal, thoran, stir fry
UPDATE public.recipe_dna_master
SET dish_category = 'dry'
WHERE meal_role @> ARRAY['side']::text[]
AND dish_category IS NULL;  -- catch-all for remaining sides

-- STEP 6: Verify
SELECT
    meal_role,
    dish_category,
    COUNT(*) as count
FROM recipe_dna_master
WHERE review_status = 'approved'
GROUP BY meal_role, dish_category
ORDER BY meal_role, count DESC;

-- END: food_momentum_schema_v24_dish_pairing.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v25_recipe_pairing.sql
-- ============================================================
-- ============================================================
-- Schema v25 — Recipe Pairing Table
-- Date: 2026-06-15
-- Purpose: Store main→side dish pairing relationships
--          Used by F16 for side dish recommendation
--          Seeded with pre-generated pairings (cold start)
--          Enhanced by behavioral_tracker over time
-- ============================================================

-- STEP 1: Create recipe_pairing table
CREATE TABLE IF NOT EXISTS public.recipe_pairing (
    id              SERIAL          PRIMARY KEY,
    main_recipe_id  UUID            NOT NULL REFERENCES public.recipe_dna_master(recipe_id) ON DELETE CASCADE,
    side_recipe_id  UUID            NOT NULL REFERENCES public.recipe_dna_master(recipe_id) ON DELETE CASCADE,
    confidence      NUMERIC(4,2)    NOT NULL DEFAULT 0.80
                    CHECK (confidence >= 0.0 AND confidence <= 1.0),
    source          VARCHAR(20)     NOT NULL DEFAULT 'seeded'
                    CHECK (source IN ('seeded','ai_seeded','matrix_seeded','user_accepted','user_rejected','ml_generated')),
    house_id        UUID            REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    -- NULL house_id = global seed (applies to all households)
    -- UUID house_id = household-specific learning
    notes           TEXT,           -- AI reasoning for this pairing
    created_at      TIMESTAMP       DEFAULT NOW(),
    updated_at      TIMESTAMP       DEFAULT NOW(),
    UNIQUE (main_recipe_id, side_recipe_id, house_id)
);

COMMENT ON TABLE public.recipe_pairing IS
    'Main→Side dish pairing relationships.
     source=seeded: pre-generated pairings (cold start, house_id=NULL)
     source=user_accepted: user kept the suggested side
     source=user_rejected: user swapped away from suggested side
     source=ml_generated: ML model generated pairing (Bucket B)
     F16 queries this table ordered by confidence DESC.
     Household-specific rows override global seeds.';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_recipe_pairing_main
    ON public.recipe_pairing(main_recipe_id, confidence DESC);

CREATE INDEX IF NOT EXISTS idx_recipe_pairing_house
    ON public.recipe_pairing(house_id, main_recipe_id);

CREATE INDEX IF NOT EXISTS idx_recipe_pairing_source
    ON public.recipe_pairing(source);

-- STEP 2: Verify
SELECT 'recipe_pairing table created' as status;

-- END: food_momentum_schema_v25_recipe_pairing.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v26_continental.sql
-- ============================================================
-- ============================================================
-- Schema v26 — Continental Category
-- Date: 2026-06-19
-- Purpose: Add continental as main dish category
-- Changes:
--   1. Add continental pairing rules to dish_pairing_matrix
--   2. Tag existing dishes as continental where applicable
-- ============================================================

-- STEP 1: Add continental pairing rules to matrix
INSERT INTO public.dish_pairing_matrix (main_category, side_category, compatibility, notes)
VALUES
    ('continental', 'condiment', 'perfect',    'Butter/jam/cheese/honey essential with continental'),
    ('continental', 'wet',       'good',        'Soup pairs well with continental mains'),
    ('continental', 'dry',       'good',        'Salad/garlic bread alongside continental'),
    ('continental', 'semi_dry',  'acceptable',  'Some semi-dry sides work with continental'),
    ('continental', 'sweet',     'never',       'Sweet not paired with continental meals')
ON CONFLICT (main_category, side_category) DO UPDATE SET
    compatibility = EXCLUDED.compatibility,
    notes = EXCLUDED.notes;

-- STEP 2: Tag any existing continental dishes
UPDATE public.recipe_dna_master
SET dish_category = 'continental'
WHERE meal_role @> ARRAY['main']::text[]
AND review_status = 'approved'
AND LOWER(dish_name) SIMILAR TO
    '%(pasta|macaroni|noodle|sandwich|toast|pancake|french toast|oats|corn flake|muesli|cereal|pizza|burger|hakka|schezwan|indo.chinese|fried rice indo)%'
AND dish_category != 'continental';

-- STEP 3: Verify
SELECT dish_category, COUNT(*) 
FROM recipe_dna_master 
WHERE review_status = 'approved'
AND meal_role @> ARRAY['main']::text[]
GROUP BY dish_category 
ORDER BY dish_category;

SELECT * FROM dish_pairing_matrix ORDER BY main_category, side_category;

-- END: food_momentum_schema_v26_continental.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v27_pairing_feedback.sql
-- ============================================================
-- ============================================================
-- Schema v27 — Pairing Feedback Tracking
-- Date: 2026-06-28
-- Purpose: Track acceptance/rejection signals on recipe_pairing
--          to improve confidence over time across households
-- ============================================================

ALTER TABLE recipe_pairing
ADD COLUMN IF NOT EXISTS validated        BOOLEAN DEFAULT NULL,
ADD COLUMN IF NOT EXISTS acceptance_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS rejection_count  INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_accepted_at TIMESTAMP;

-- Index for querying most accepted pairings
CREATE INDEX IF NOT EXISTS idx_recipe_pairing_acceptance
ON recipe_pairing (acceptance_count DESC)
WHERE house_id IS NULL;

COMMENT ON COLUMN recipe_pairing.acceptance_count IS 
'How many times this pairing was kept/accepted across all households';
COMMENT ON COLUMN recipe_pairing.rejection_count IS 
'How many times this pairing was swapped out across all households';
COMMENT ON COLUMN recipe_pairing.last_accepted_at IS 
'Last time any household accepted this pairing';
COMMENT ON COLUMN recipe_pairing.validated IS 
'TRUE=AI/human confirmed, FALSE=flagged for review, NULL=not yet validated';

-- END: food_momentum_schema_v27_pairing_feedback.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v28_audit_features.sql
-- ============================================================
-- ============================================================
-- Schema v28 — Audit Engine Feature Registry
-- Date: 2026-06-29
-- Purpose: Register all audit checks as toggleable features
-- ============================================================

INSERT INTO public.feature_registry
    (feature_code, feature_name, function_name, router_file,
     is_mandatory, is_active, depends_on, description)
VALUES
    ('AU-D01', 'Diet compatibility check',    'audit_diet',         'services/audit_service.py', false, true, '{}',       'AU-D01: Warn if selected dish diet does not match household effective diet.'),
    ('AU-D02', 'Allergen check',              'audit_allergens',    'services/audit_service.py', false, true, '{AU-D01}', 'AU-D02: Warn if dish contains household member allergen ingredients.'),
    ('AU-D03', 'Satvik day check',            'audit_satvik',       'services/audit_service.py', false, true, '{}',       'AU-D03: Warn if dish not Satvik on a Satvik day.'),
    ('AU-D04', 'Repeat this week check',      'audit_repeat_week',  'services/audit_service.py', false, true, '{}',       'AU-D04: Warn if same dish already in plan this week.'),
    ('AU-D05', 'Repeat past weeks check',     'audit_repeat_past',  'services/audit_service.py', false, true, '{}',       'AU-D05: Warn if dish served in past N weeks.'),
    ('AU-D06', 'Pantry availability check',   'audit_pantry',       'services/audit_service.py', false, true, '{}',       'AU-D06: Warn if primary ingredients not found in household pantry.')
ON CONFLICT (feature_code) DO UPDATE SET
    is_active   = EXCLUDED.is_active,
    description = EXCLUDED.description,
    updated_at  = NOW();

-- Add pantry_only to household_plan_config / weekly generation config
ALTER TABLE household_plan_config ADD COLUMN IF NOT EXISTS pantry_only BOOLEAN DEFAULT FALSE;
ALTER TABLE weekly_generation_config ADD COLUMN IF NOT EXISTS pantry_only BOOLEAN DEFAULT FALSE;

-- END: food_momentum_schema_v28_audit_features.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v29_ingredient_optional_tracking.sql
-- ============================================================
-- Schema v29 — is_optional classification tracking
--
-- Tracks whether a recipe's ingredients have already been run through the
-- AI is_optional classification pass (classify_is_optional.py), so re-runs
-- (e.g. after adding new recipes) don't reprocess -- and re-bill -- recipes
-- that are already done.
--
-- Not inferred from recipe_ingredients.is_optional values themselves,
-- since a genuinely all-mandatory recipe would be indistinguishable from
-- an unprocessed one (both default to false).

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS is_optional_classified_at TIMESTAMP DEFAULT NULL;

COMMENT ON COLUMN recipe_dna_master.is_optional_classified_at IS
    'Timestamp of the last successful AI is_optional classification pass
     (classify_is_optional.py --apply) for this recipe. NULL = not yet
     classified. Used to skip already-processed recipes on re-runs.';

-- END: food_momentum_schema_v29_ingredient_optional_tracking.sql

-- ============================================================
-- BEGIN: food_momentum_schema_v30_household_recipes.sql
-- ============================================================
-- Schema v30 — household-private recipes (quick entry)
--
-- CORRECTED: recipe_dna_master already has a created_by_house_id UUID
-- column from early schema design (present since the March 2026 dumps),
-- but it was never wired into any application code or later migration.
-- Reusing it for this feature instead of adding a new, confusingly
-- redundant column with a different name for the same purpose.
--
-- Semantics being applied to this existing column:
-- NULL     = shared, admin-curated vault (all existing behavior,
--            unchanged -- every current recipe has this).
-- Non-null = private to that household. Auto-approved, visible only
--            to them, never enters the shared reviewer queue.
--
-- Precedent: recipe_pairing.house_id already uses this exact
-- NULL = global / non-null = household-specific pattern in production
-- (see recommendation_service.py recommend_sides()).

-- Add the FK constraint if it isn't already there (defensive -- the
-- column predates this migration and its constraint history is unknown).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'recipe_dna_master_created_by_house_id_fkey'
    ) THEN
        ALTER TABLE recipe_dna_master
            ADD CONSTRAINT recipe_dna_master_created_by_house_id_fkey
            FOREIGN KEY (created_by_house_id) REFERENCES household_master(household_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_recipe_dna_master_created_by_house_id
    ON recipe_dna_master(created_by_house_id) WHERE created_by_house_id IS NOT NULL;

COMMENT ON COLUMN recipe_dna_master.created_by_house_id IS
    'NULL = shared vault recipe (admin-curated, goes through the review
     pipeline). Non-null = household-private quick-entry dish:
     auto-approved, visible only to that household, never enters the
     shared reviewer queue. (Column predates this comment -- repurposed
     here for the quick-entry feature; previously unused by any code.)';

-- END: food_momentum_schema_v30_household_recipes.sql

