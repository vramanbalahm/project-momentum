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
