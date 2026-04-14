-- ============================================================
-- Momentum Food Scheduler — Schema V3 GIF & Event Updates
-- Date: 14-Apr-2026
-- Baseline: food_momentum_schema_v2_additions.sql
-- Rules:
--   1. No modification to existing tables or columns
--   2. Only ADD new tables and new columns
--   3. All new columns have DEFAULT values
-- ============================================================


-- ============================================================
-- SECTION 1: ADD gif_url TO event_master
-- Stores GIF URL — fetched from Tenor API for lunar events
-- or selected by user from repository for personal events
-- ============================================================

ALTER TABLE public.event_master
    ADD COLUMN IF NOT EXISTS gif_url TEXT;

ALTER TABLE public.event_master
    ADD COLUMN IF NOT EXISTS gif_source VARCHAR(20) DEFAULT 'none'
        CHECK (gif_source IN ('tenor', 'repository', 'none'));

COMMENT ON COLUMN public.event_master.gif_url IS
    'GIF URL — from Tenor API for lunar/admin events, from gif_repository for user personal events';

COMMENT ON COLUMN public.event_master.gif_source IS
    'tenor = fetched via Tenor API at batch time, repository = user selected from local GIF repository';


-- ============================================================
-- SECTION 2: EVENT GIF REPOSITORY
-- Curated GIF library for user personal events
-- User picks from this during event creation (FT-027)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.event_gif_repository (
    gif_id          UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    category        VARCHAR(50)     NOT NULL,       -- Birthday, Anniversary, Memorial, Housewarming, Celebration, Religious
    gif_url         TEXT            NOT NULL,       -- Local /assets/gifs/ path or CDN URL
    gif_label       VARCHAR(100)    NOT NULL,       -- Display name shown to user in picker
    gif_thumbnail   TEXT,                           -- Static thumbnail for picker preview (first frame)
    is_active       BOOLEAN         DEFAULT TRUE,
    sort_order      INTEGER         DEFAULT 1,      -- Display order within category
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.event_gif_repository IS
    'Curated GIF library for user personal events. Grouped by category. User browses and selects during event creation.';

-- ── Seed default categories with placeholder URLs ────────────
-- In production these will be replaced with actual GIF assets
INSERT INTO public.event_gif_repository
    (category, gif_url, gif_label, sort_order)
VALUES
-- Birthday
('Birthday', '/assets/gifs/birthday_cake_01.gif',       'Birthday cake',        1),
('Birthday', '/assets/gifs/birthday_confetti_01.gif',   'Confetti burst',       2),
('Birthday', '/assets/gifs/birthday_balloon_01.gif',    'Balloons',             3),
('Birthday', '/assets/gifs/birthday_sparkle_01.gif',    'Sparkle',              4),
('Birthday', '/assets/gifs/birthday_candles_01.gif',    'Candles',              5),

-- Anniversary / Wedding
('Anniversary', '/assets/gifs/anniversary_rings_01.gif',    'Wedding rings',    1),
('Anniversary', '/assets/gifs/anniversary_hearts_01.gif',   'Hearts',           2),
('Anniversary', '/assets/gifs/anniversary_flowers_01.gif',  'Flowers',          3),
('Anniversary', '/assets/gifs/anniversary_candle_01.gif',   'Romantic candle',  4),

-- Memorial / Death anniversary
('Memorial', '/assets/gifs/memorial_diya_01.gif',       'Diya flame',           1),
('Memorial', '/assets/gifs/memorial_lotus_01.gif',      'Lotus',                2),
('Memorial', '/assets/gifs/memorial_candle_01.gif',     'Memorial candle',      3),

-- Housewarming
('Housewarming', '/assets/gifs/house_new_01.gif',       'New home',             1),
('Housewarming', '/assets/gifs/house_key_01.gif',       'Keys',                 2),
('Housewarming', '/assets/gifs/house_puja_01.gif',      'Griha Pravesh',        3),

-- General celebration
('Celebration', '/assets/gifs/celebrate_fireworks_01.gif',  'Fireworks',        1),
('Celebration', '/assets/gifs/celebrate_party_01.gif',      'Party',            2),
('Celebration', '/assets/gifs/celebrate_stars_01.gif',      'Stars',            3),
('Celebration', '/assets/gifs/celebrate_dance_01.gif',      'Dance',            4),

-- Religious / Puja
('Religious', '/assets/gifs/religious_diya_01.gif',     'Diya',                 1),
('Religious', '/assets/gifs/religious_om_01.gif',       'Om',                   2),
('Religious', '/assets/gifs/religious_kolam_01.gif',    'Kolam',                3),
('Religious', '/assets/gifs/religious_bell_01.gif',     'Temple bell',          4),
('Religious', '/assets/gifs/religious_lamp_01.gif',     'Lamp',                 5)

ON CONFLICT DO NOTHING;


-- ============================================================
-- SECTION 3: TENOR API CONFIG
-- Stores API key and search config for lunar event GIF fetch
-- One row — admin managed
-- ============================================================

CREATE TABLE IF NOT EXISTS public.api_config (
    config_id       UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    service_name    VARCHAR(50)     NOT NULL UNIQUE,    -- e.g. tenor, agmarknet, odg
    api_key         TEXT,                               -- Encrypted in production
    base_url        TEXT,
    is_active       BOOLEAN         DEFAULT TRUE,
    rate_limit      INTEGER         DEFAULT 100,        -- Calls per day
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.api_config IS
    'Central API configuration table. All external API keys and endpoints managed here. One row per service.';

-- Seed service rows (keys to be filled by admin)
INSERT INTO public.api_config
    (service_name, base_url, notes)
VALUES
('tenor',       'https://tenor.googleapis.com/v2',         'GIF search for lunar calendar events. Key from Google Cloud Console.'),
('agmarknet',   'https://agmarknet.gov.in',                 'Primary mandi price portal — Modal Price source'),
('odg_api',     'https://api.data.gov.in/resource',         'OGD API — structured JSON for daily automated price fetch + 14-day RSI'),
('enam',        'https://www.enam.gov.in/web/api',          'e-NAM trading volumes — high confidence divergence signals'),
('twilio',      'https://api.twilio.com/2010-04-01',        'WhatsApp meal card export via Twilio')
ON CONFLICT (service_name) DO NOTHING;


-- ============================================================
-- SECTION 4: ADD NEW FEATURES TO FEATURE REGISTRY
-- FT-026: fetch_event_gif — Tenor API GIF fetch at batch time
-- FT-027: get_gif_repository — User GIF picker for personal events
-- ============================================================

INSERT INTO public.feature_registry
    (feature_code, feature_name, function_name, router_file, is_mandatory, depends_on, description)
VALUES
(
    'FT-026',
    'Lunar event GIF fetch',
    'fetch_event_gif',
    'routers/events.py',
    FALSE,
    '{FT-022}',
    'During lunar calendar batch population, calls Tenor API to fetch and store GIF URL per event. One-time per event at population.'
),
(
    'FT-027',
    'User GIF picker',
    'get_gif_repository',
    'routers/events.py',
    FALSE,
    '{FT-020}',
    'Returns curated GIF repository grouped by category for user personal event creation. User browses and selects.'
)
ON CONFLICT (feature_code) DO NOTHING;


-- ============================================================
-- SECTION 5: GIF ASSETS FOLDER NOTE
-- Physical GIF files to be placed in:
-- frontend/public/assets/gifs/
-- Filename convention: {category}_{description}_{seq}.gif
-- e.g. birthday_cake_01.gif, memorial_diya_01.gif
-- ============================================================

-- ============================================================
-- END OF V3 ADDITIONS
-- New tables: 2 (event_gif_repository, api_config)
-- New columns: 2 on event_master (gif_url, gif_source)
-- New features: 2 (FT-026, FT-027)
-- API services seeded: 5 (tenor, agmarknet, odg_api, enam, twilio)
-- ============================================================
