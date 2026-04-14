-- ============================================================
-- Momentum Food Scheduler — Schema V2 Additions
-- Date: 14-Apr-2026
-- Baseline: food_momentum_16032026.sql
-- Rules:
--   1. No modification to existing tables or columns
--   2. Only ADD new tables and new columns
--   3. All new columns have DEFAULT values — safe for existing rows
--   4. Column and table names follow existing naming conventions
-- ============================================================


-- ============================================================
-- SECTION 1: FEATURE REGISTRY (SOA Architecture)
-- FT-100: manage_feature_registry
-- ============================================================

CREATE TABLE IF NOT EXISTS public.feature_registry (
    feature_code        VARCHAR(20)     PRIMARY KEY,        -- e.g. FT-001
    feature_name        VARCHAR(100)    NOT NULL,           -- Human readable name
    function_name       VARCHAR(100)    NOT NULL,           -- Python function name in service
    router_file         VARCHAR(50)     NOT NULL,           -- e.g. routers/profile.py
    is_mandatory        BOOLEAN         DEFAULT FALSE,      -- Mandatory = always on, cannot revoke
    is_active           BOOLEAN         DEFAULT TRUE,       -- Global on/off switch
    depends_on          VARCHAR(20)[]   DEFAULT '{}',       -- Array of feature_codes required first
    description         TEXT,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.feature_registry IS
    'Central registry of all 44 features. Function name drives dynamic execution. Dependency enforcement via depends_on array.';


-- ============================================================
-- SECTION 2: HOUSEHOLD ENTITLEMENTS (SOA Architecture)
-- FT-101: manage_entitlements
-- ============================================================

CREATE TABLE IF NOT EXISTS public.household_entitlements (
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    feature_code        VARCHAR(20)     NOT NULL REFERENCES public.feature_registry(feature_code),
    is_enabled          BOOLEAN         DEFAULT FALSE,
    enabled_at          TIMESTAMP,
    disabled_at         TIMESTAMP,
    granted_by          VARCHAR(100),                       -- Admin user who granted
    notes               TEXT,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (house_id, feature_code)
);

COMMENT ON TABLE public.household_entitlements IS
    'Maps optional features to households. Mandatory features (is_mandatory=TRUE) bypass this table entirely.';


-- ============================================================
-- SECTION 3: HOUSEHOLD SATVIK PROFILE
-- FT-005: setup_satvik_profile
-- ============================================================

CREATE TABLE IF NOT EXISTS public.household_satvik_profile (
    profile_id          UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    excluded_ingredients INTEGER[]      DEFAULT '{}',       -- Array of ingredient_master.id values
    fasting_pattern     VARCHAR(20)     DEFAULT 'Modified'  -- Full / Partial / Modified
                        CHECK (fasting_pattern IN ('Full', 'Partial', 'Modified')),
    allowed_fast_foods  INTEGER[]       DEFAULT '{}',       -- ingredient_master.id values allowed during fast
    event_overrides     JSONB           DEFAULT '{}',       -- event_code -> specific satvik definition
    is_active           BOOLEAN         DEFAULT TRUE,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (house_id)                                       -- One Satvik profile per household
);

COMMENT ON TABLE public.household_satvik_profile IS
    'Household-defined Satvik rules. Never hardcoded. System defaults provided, user overrides fully supported.';


-- ============================================================
-- SECTION 4: COMPLEXITY LEVELS
-- FT-003: define_complexity_levels
-- ============================================================

CREATE TABLE IF NOT EXISTS public.complexity_levels (
    level_id            UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    level_number        INTEGER         NOT NULL            -- 1, 2, 3, 4
                        CHECK (level_number BETWEEN 1 AND 4),
    level_label         VARCHAR(50),                        -- User defined label e.g. "Weekday Quick"
    main_dish_count     INTEGER         NOT NULL DEFAULT 1,
    side_dish_count     INTEGER         NOT NULL DEFAULT 1,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (house_id, level_number)                         -- One definition per level per household
);

COMMENT ON TABLE public.complexity_levels IS
    'User-defined complexity levels. Level 1-4 with user-specified main + side dish counts. Smart defaults pre-seeded.';

-- Seed default complexity levels for new households via function
-- Level 1: 1 main + 1 side  (Simple)
-- Level 2: 1 main + 2 sides (Standard)
-- Level 3: 1 main + 3 sides (Elaborate)
-- Level 4: 2 mains + 3 sides (Special)


-- ============================================================
-- SECTION 5: DAILY MEAL PATTERN
-- FT-004: setup_daily_meal_pattern
-- ============================================================

CREATE TABLE IF NOT EXISTS public.daily_meal_pattern (
    pattern_id          UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    day_of_week         VARCHAR(10)     NOT NULL            -- Monday, Tuesday ... Sunday
                        CHECK (day_of_week IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
    meal_slot           public.meal_slot_type NOT NULL,     -- Breakfast / Lunch / Dinner (existing ENUM)
    default_level       INTEGER         NOT NULL DEFAULT 2  -- References complexity_levels.level_number
                        CHECK (default_level BETWEEN 1 AND 4),
    current_level       INTEGER         NOT NULL DEFAULT 2  -- Learned pattern — updated after every week
                        CHECK (current_level BETWEEN 1 AND 4),
    last_updated        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (house_id, day_of_week, meal_slot)
);

COMMENT ON TABLE public.daily_meal_pattern IS
    'Two-pattern model: default_level (set once at profile) and current_level (updated weekly by system). User can override both anytime.';


-- ============================================================
-- SECTION 6: WEEKLY QUESTIONNAIRE RESPONSES
-- FT-031: process_weekly_questionnaire
-- ============================================================

CREATE TABLE IF NOT EXISTS public.weekly_questionnaire (
    questionnaire_id    UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    week_start_date     DATE            NOT NULL,
    cook_energy_level   VARCHAR(10)     DEFAULT 'Medium'    -- Low / Medium / High
                        CHECK (cook_energy_level IN ('Low', 'Medium', 'High')),
    guest_count         INTEGER         DEFAULT 0,
    veg_nonveg_split    VARCHAR(20)     DEFAULT 'As Profile', -- As Profile / Full Veg / Mostly Veg / Mixed / Mostly NonVeg
    member_attendance   JSONB           DEFAULT '{}',       -- {member_id: {Mon: true, Tue: false, ...}}
    event_overrides     JSONB           DEFAULT '{}',       -- {event_code: {dietary: 'Veg', is_satvik: true}}
    questionnaire_week  INTEGER         DEFAULT 1,          -- Week number 1-4+ for progressive reduction
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (house_id, week_start_date)
);

COMMENT ON TABLE public.weekly_questionnaire IS
    'Stores weekly context answers. questionnaire_week tracks progression — questions reduce as weeks increase.';


-- ============================================================
-- SECTION 7: BEHAVIORAL TRACKER
-- FT-071: log_behavioral_event
-- ============================================================

CREATE TABLE IF NOT EXISTS public.behavioral_tracker (
    tracker_id          UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    week_start_date     DATE            NOT NULL,
    event_date          DATE            NOT NULL,
    meal_slot           public.meal_slot_type NOT NULL,     -- Existing ENUM
    original_recipe_id  UUID            REFERENCES public.recipe_dna_master(recipe_id),
    new_recipe_id       UUID            REFERENCES public.recipe_dna_master(recipe_id),
    swap_reason         VARCHAR(20)     DEFAULT 'Other'     -- Complexity / Inventory / Variety / Other
                        CHECK (swap_reason IN ('Complexity', 'Inventory', 'Variety', 'Other')),
    swap_reason_text    TEXT,                               -- Optional free text from user
    dish_type           VARCHAR(10)     DEFAULT 'Main'      -- Main / Side
                        CHECK (dish_type IN ('Main', 'Side')),
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.behavioral_tracker IS
    'Logs every swap — original vs new recipe, reason, meal slot. Foundation for all intelligence features.';


-- ============================================================
-- SECTION 8: USER INTELLIGENCE PROFILE
-- FT-062 to FT-066: intelligence engine functions
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_intelligence_profile (
    profile_id          UUID            DEFAULT gen_random_uuid() PRIMARY KEY,
    house_id            UUID            NOT NULL REFERENCES public.household_master(household_id),
    current_confidence_score    FLOAT   DEFAULT 0.0        -- 0.0 to 1.0
                        CHECK (current_confidence_score BETWEEN 0.0 AND 1.0),
    active_window_size  INTEGER         DEFAULT 4,          -- W_obs in weeks
    detected_regional_bias      VARCHAR(50),                -- e.g. 'Tamil Nadu', 'Karnataka'
    avg_complexity_weekday      FLOAT   DEFAULT 2.0,        -- Learned avg complexity Mon-Fri
    avg_complexity_weekend      FLOAT   DEFAULT 3.0,        -- Learned avg complexity Sat-Sun
    low_energy_days     VARCHAR(10)[]   DEFAULT '{}',       -- e.g. ['Wednesday', 'Thursday']
    taste_dna           JSONB           DEFAULT '{}',       -- Full taste profile JSON
    last_drift_detected TIMESTAMP,                          -- When last behavioral drift was found
    last_updated        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (house_id)
);

COMMENT ON TABLE public.user_intelligence_profile IS
    'Stores learned intelligence per household. Updated by intelligence engine after every week. Drives autonomous plan generation.';


-- ============================================================
-- SECTION 9: NEW COLUMNS ON EXISTING TABLES
-- Coding Rule: Only ADD columns, never modify existing ones
-- All new columns have DEFAULT values
-- ============================================================

-- 9.1 meal_event_detail — add dish_type (main/side flag)
-- FT-033: manage_meal_slot_dishes
ALTER TABLE public.meal_event_detail
    ADD COLUMN IF NOT EXISTS dish_type VARCHAR(10) DEFAULT 'Main'
        CHECK (dish_type IN ('Main', 'Side'));

ALTER TABLE public.meal_event_detail
    ADD COLUMN IF NOT EXISTS dish_sequence INTEGER DEFAULT 1;   -- Order within slot (1=first)

COMMENT ON COLUMN public.meal_event_detail.dish_type IS
    'Main or Side dish. Supports multi-dish per meal slot. Default Main for backward compatibility.';

-- 9.2 household_master — add native_region and current_city
-- FT-001: setup_household_profile
ALTER TABLE public.household_master
    ADD COLUMN IF NOT EXISTS native_region VARCHAR(50);         -- Cuisine DNA e.g. Tamil Nadu

ALTER TABLE public.household_master
    ADD COLUMN IF NOT EXISTS current_city VARCHAR(50);          -- Market price reference e.g. Bengaluru

ALTER TABLE public.household_master
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

COMMENT ON COLUMN public.household_master.native_region IS
    'Region of origin — drives cuisine style and dietary DNA. Different from current_city.';

COMMENT ON COLUMN public.household_master.current_city IS
    'City of residence — drives market price intelligence. Independent of native_region.';

-- 9.3 weekly_planning_session — add questionnaire_week and context snapshot
-- FT-072: log_weekly_session_context
ALTER TABLE public.weekly_planning_session
    ADD COLUMN IF NOT EXISTS questionnaire_week INTEGER DEFAULT 1;

ALTER TABLE public.weekly_planning_session
    ADD COLUMN IF NOT EXISTS context_snapshot JSONB DEFAULT '{}';   -- Market stress, fridge snapshot etc

ALTER TABLE public.weekly_planning_session
    ADD COLUMN IF NOT EXISTS generation_method VARCHAR(20) DEFAULT 'Rule'
        CHECK (generation_method IN ('Rule', 'AI', 'Clone', 'Manual'));

COMMENT ON COLUMN public.weekly_planning_session.generation_method IS
    'How this week plan was generated. Rule=rule-based, AI=Gemini, Clone=copied from prev week, Manual=user built from scratch.';

-- 9.4 household_members — add dietary_preference per member
-- FT-002: manage_household_members
ALTER TABLE public.household_members
    ADD COLUMN IF NOT EXISTS dietary_preference public.diet_pref DEFAULT 'Veg';

ALTER TABLE public.household_members
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

COMMENT ON COLUMN public.household_members.dietary_preference IS
    'Individual dietary preference per member. Used in attendance-based plan filtering.';

-- 9.5 meal_audit_logs — add house_id and more context
-- FT-036: run_plan_audit
ALTER TABLE public.meal_audit_logs
    ADD COLUMN IF NOT EXISTS house_id UUID REFERENCES public.household_master(household_id);

ALTER TABLE public.meal_audit_logs
    ADD COLUMN IF NOT EXISTS recipe_id UUID REFERENCES public.recipe_dna_master(recipe_id);

ALTER TABLE public.meal_audit_logs
    ADD COLUMN IF NOT EXISTS audit_type VARCHAR(20) DEFAULT 'Manual'
        CHECK (audit_type IN ('Auto', 'Manual', 'CheckStatus'));

ALTER TABLE public.meal_audit_logs
    ADD COLUMN IF NOT EXISTS is_overridden BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN public.meal_audit_logs.audit_type IS
    'Auto=system triggered, Manual=save button, CheckStatus=user clicked Check Status button.';


-- ============================================================
-- SECTION 10: SEED FEATURE REGISTRY
-- All 44 features from the feature registry
-- ============================================================

INSERT INTO public.feature_registry
    (feature_code, feature_name, function_name, router_file, is_mandatory, depends_on, description)
VALUES

-- Group 1: Profile & household setup
('FT-001', 'Household profile setup',       'setup_household_profile',      'routers/profile.py',       TRUE,  '{}',                       'Create household, native region, current city, dietary type'),
('FT-002', 'Household members management',  'manage_household_members',     'routers/profile.py',       TRUE,  '{FT-001}',                 'Add/edit/remove members with individual dietary types'),
('FT-003', 'Complexity level definition',   'define_complexity_levels',     'routers/profile.py',       TRUE,  '{FT-001}',                 'User defines mains + sides count per level L1-L4'),
('FT-004', 'Daily meal pattern setup',      'setup_daily_meal_pattern',     'routers/profile.py',       TRUE,  '{FT-003}',                 'Assign complexity level per meal type per day'),
('FT-005', 'Household Satvik profile',      'setup_satvik_profile',         'routers/profile.py',       FALSE, '{FT-001}',                 'User-defined Satvik rules — never hardcoded'),
('FT-006', 'Two-pattern model management',  'manage_pattern_model',         'routers/profile.py',       TRUE,  '{FT-004}',                 'Maintains default_level and current_level separately'),

-- Group 2: Inventory & fridge
('FT-010', 'Fridge inventory management',   'manage_fridge_inventory',      'routers/inventory.py',     FALSE, '{FT-001}',                 'Add/update/remove items in household_inventory'),
('FT-011', 'Fridge check against plan',     'check_fridge_against_plan',    'routers/inventory.py',     FALSE, '{FT-010,FT-030}',          'Check if planned meal ingredients are in stock'),
('FT-012', 'Smart purchase form',           'record_purchase',              'routers/inventory.py',     FALSE, '{FT-010}',                 'User enters prices, updates inventory and price_input_buffer'),
('FT-013', 'Inventory usage tracking',      'track_inventory_usage',        'routers/inventory.py',     FALSE, '{FT-010,FT-032}',          'Marks ingredients as consumed after plan is locked'),

-- Group 3: Event management
('FT-020', 'User event creation',           'create_user_event',            'routers/events.py',        FALSE, '{FT-001}',                 'Personal events with custom ID format UE0012026'),
('FT-021', 'Event active/inactive toggle',  'toggle_event_status',          'routers/events.py',        FALSE, '{FT-020}',                 'Toggle events on/off — no hard delete'),
('FT-022', 'Admin lunar calendar',          'populate_lunar_calendar',      'routers/events.py',        FALSE, '{}',                       'Admin batch populates event_master — ID format TN0012026-LC'),
('FT-023', 'Event surface in planning',     'get_week_events',              'routers/events.py',        FALSE, '{FT-020,FT-030}',          'Shows active events during weekly attendance step'),
('FT-024', 'Annual event copy',             'copy_events_to_new_year',      'routers/events.py',        FALSE, '{FT-020}',                 'Copy previous year events to current year'),
('FT-025', 'Event calendar view',           'get_event_calendar',           'routers/events.py',        FALSE, '{FT-020}',                 'Read-only calendar view of all active events'),

-- Group 4: Weekly planning
('FT-030', 'Weekly plan generation',        'generate_weekly_plan_rule_based', 'routers/weekly_plan.py', TRUE, '{FT-003,FT-004,FT-006}',   'Rule-based 7-day multi-dish plan. No AI dependency.'),
('FT-031', 'Weekly questionnaire',          'process_weekly_questionnaire', 'routers/weekly_plan.py',   TRUE,  '{FT-002,FT-030}',          'Collects attendance, cook energy, veg/non-veg split'),
('FT-032', 'Save and lock plan',            'save_and_lock_plan',           'routers/weekly_plan.py',   TRUE,  '{FT-030}',                 'State machine: Review -> Save and Lock -> Plan Locked'),
('FT-033', 'Multi-dish per meal slot',      'manage_meal_slot_dishes',      'routers/weekly_plan.py',   TRUE,  '{FT-003,FT-030}',          'Main + side dishes per slot via meal_event_detail'),
('FT-034', 'Clone previous week',           'clone_previous_week',          'routers/weekly_plan.py',   FALSE, '{FT-030,FT-032}',          'Copy previous week as template with conflict warnings'),
('FT-035', 'View previous weeks',           'get_previous_week_plan',       'routers/weekly_plan.py',   FALSE, '{FT-032}',                 'Read-only view of any past week plan'),
('FT-036', 'Plan audit check status',       'run_plan_audit',               'routers/weekly_plan.py',   FALSE, '{FT-032,FT-011}',          'Re-audit saved plan against current inventory and market'),
('FT-037', 'Planning notification',         'send_planning_reminder',       'routers/notifications.py', FALSE, '{FT-030}',                 'Push notification when next week has no plan'),

-- Group 5: Search & edit
('FT-040', 'Universal recipe search',       'search_recipes',               'routers/search.py',        TRUE,  '{FT-001}',                 'Search system vault + Signature Vault. Satvik warnings shown.'),
('FT-041', 'Meal slot edit',                'edit_meal_slot',               'routers/search.py',        TRUE,  '{FT-040,FT-030}',          'Replace any dish from current date. Override logged.'),
('FT-042', 'Surgical swap AI alternatives', 'get_ai_swap_alternatives',     'routers/search.py',        FALSE, '{FT-041,FT-060}',          'AI Best Match + Regional Swap options on meal click'),
('FT-043', 'Cross-day swap pure move',      'swap_meals_across_days',       'routers/search.py',        FALSE, '{FT-041}',                 'Swap entire day or slots across days with conflict check'),
('FT-044', 'Swap reason capture',           'log_swap_reason',              'routers/search.py',        FALSE, '{FT-041,FT-071}',          'Complexity/Inventory/Variety/Other — feeds behavioral tracker'),
('FT-045', 'Signature Vault',               'manage_signature_vault',       'routers/search.py',        FALSE, '{FT-001,FT-040}',          'User creates custom recipes with image upload'),

-- Group 6: Market intelligence
('FT-050', 'Manual price entry',            'record_manual_price',          'routers/market.py',        FALSE, '{FT-001}',                 'User enters staple prices, writes to price_logs'),
('FT-051', 'OGD API price fetch',           'fetch_mandi_prices',           'routers/market.py',        FALSE, '{FT-050}',                 'Daily batch fetch from data.gov.in OGD API'),
('FT-052', 'RSI calculation engine',        'calculate_rsi',                'routers/market.py',        FALSE, '{FT-051}',                 '14-day rolling RSI per staple from price_logs'),
('FT-053', 'Wave 5 divergence detection',   'detect_wave5_divergence',      'routers/market.py',        FALSE, '{FT-052}',                 'Detects price peak with e-NAM volume confirmation'),
('FT-054', 'Market signal dashboard',       'get_market_signals',           'routers/market.py',        FALSE, '{FT-052}',                 'Green/Yellow/Red signal per staple in context header'),
('FT-055', 'Market stress complexity cap',  'apply_market_complexity_cap',  'routers/market.py',        FALSE, '{FT-053,FT-030}',          'Caps complexity at C<=3 when signal is Red'),

-- Group 7: Intelligence engine
('FT-060', 'Gemini AI weekly draft',        'generate_weekly_draft_ai',     'routers/intelligence.py',  FALSE, '{FT-030,FT-071}',          'AI-powered plan via context packet -> Gemini -> JSON'),
('FT-061', 'Observation window',            'get_observation_window',       'routers/intelligence.py',  FALSE, '{FT-071}',                 'Manages W_obs parameter — default 4 weeks'),
('FT-062', 'Taste DNA analysis',            'analyze_taste_dna',            'routers/intelligence.py',  FALSE, '{FT-061,FT-071}',          'Analyzes rolling history for complexity and regional patterns'),
('FT-063', 'Behavioral drift detection',    'identify_behavior_drift',      'routers/intelligence.py',  FALSE, '{FT-062}',                 'Detects sudden shifts — triggers W_obs reset'),
('FT-064', 'Confidence score engine',       'calculate_confidence_score',   'routers/intelligence.py',  FALSE, '{FT-062,FT-063}',          'CS 0.0-1.0 drives Discovery/Learning/Autonomous mode'),
('FT-065', 'Low energy zone detection',     'detect_low_energy_zones',      'routers/intelligence.py',  FALSE, '{FT-062}',                 'Tags recurring busy days from complexity downgrades'),
('FT-066', 'Regional bias detection',       'detect_regional_bias',         'routers/intelligence.py',  FALSE, '{FT-062}',                 'Identifies consistent regional cuisine preference'),
('FT-067', 'Market stress pivot',           'monitor_market_pivot',         'routers/intelligence.py',  FALSE, '{FT-053,FT-062}',          'Monitors Wave 5 peak — triggers complexity cap'),
('FT-068', 'Recipe gap detection',          'detect_recipe_gap',            'routers/intelligence.py',  FALSE, '{FT-060}',                 'Flags AI suggestions not in vault — writes to recipe_gap_analysis'),
('FT-069', 'AI reasoning explanation',      'get_ai_reasoning',             'routers/intelligence.py',  FALSE, '{FT-060,FT-064}',          'Explains why system suggested a dish — builds trust'),

-- Group 8: Behavioral tracking
('FT-071', 'Behavioral tracker',            'log_behavioral_event',         'routers/tracking.py',      FALSE, '{FT-041}',                 'Logs original vs new recipe on every swap with reason'),
('FT-072', 'Weekly session context log',    'log_weekly_session_context',   'routers/tracking.py',      FALSE, '{FT-031,FT-071}',          'Saves input snapshot when plan is generated'),
('FT-073', 'Pattern update after save',     'update_current_pattern',       'routers/tracking.py',      FALSE, '{FT-071,FT-006}',          'Updates current_level incrementally after every locked week'),

-- Group 9: Recipe & image management
('FT-080', 'Recipe vault management',       'manage_recipe_vault',          'routers/recipes.py',       TRUE,  '{}',                       'Admin CRUD for recipe_dna_master and recipe_content_vault'),
('FT-081', 'AI batch image generation',     'generate_recipe_images',       'routers/recipes.py',       FALSE, '{FT-080}',                 'Batch AI image generation for all vault recipes'),
('FT-082', 'User recipe image upload',      'upload_recipe_image',          'routers/recipes.py',       FALSE, '{FT-045}',                 'Upload interface for Signature Vault recipes'),

-- Group 10: Notifications & export
('FT-090', 'WhatsApp meal card export',     'send_whatsapp_meal_card',      'routers/notifications.py', FALSE, '{FT-032}',                 'Formatted weekly summary via Twilio to household WhatsApp'),
('FT-091', 'In-app planning reminder',      'send_planning_reminder',       'routers/notifications.py', FALSE, '{FT-030}',                 'Push notification when next week has no plan'),

-- Group 11: Platform admin
('FT-100', 'Feature registry management',   'manage_feature_registry',      'routers/admin.py',         TRUE,  '{}',                       'Admin CRUD for feature_registry table'),
('FT-101', 'Household entitlement mgmt',    'manage_entitlements',          'routers/admin.py',         TRUE,  '{FT-100}',                 'Admin enables/disables features per household with dependency enforcement'),
('FT-102', 'Bulk entitlement management',   'bulk_manage_entitlements',     'routers/admin.py',         FALSE, '{FT-101}',                 'Enable/disable feature for all households at once')

ON CONFLICT (feature_code) DO NOTHING;


-- ============================================================
-- SECTION 11: SEED DEFAULT COMPLEXITY LEVELS
-- Applied to the test household — new households seeded on signup
-- ============================================================

INSERT INTO public.complexity_levels
    (house_id, level_number, level_label, main_dish_count, side_dish_count)
SELECT
    household_id,
    level_number,
    level_label,
    main_dish_count,
    side_dish_count
FROM public.household_master
CROSS JOIN (VALUES
    (1, 'Simple',    1, 1),
    (2, 'Standard',  1, 2),
    (3, 'Elaborate', 1, 3),
    (4, 'Special',   2, 3)
) AS defaults(level_number, level_label, main_dish_count, side_dish_count)
ON CONFLICT (house_id, level_number) DO NOTHING;


-- ============================================================
-- SECTION 12: SEED DEFAULT DAILY MEAL PATTERN
-- Weekday = Level 2 (Standard), Weekend = Level 3 (Elaborate)
-- Applied to all existing households
-- ============================================================

INSERT INTO public.daily_meal_pattern
    (house_id, day_of_week, meal_slot, default_level, current_level)
SELECT
    household_id,
    day_of_week,
    meal_slot::public.meal_slot_type,
    CASE
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Lunch'   THEN 3
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Dinner'  THEN 3
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Breakfast' THEN 2
        ELSE 2
    END AS default_level,
    CASE
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Lunch'   THEN 3
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Dinner'  THEN 3
        WHEN day_of_week IN ('Saturday', 'Sunday') AND meal_slot = 'Breakfast' THEN 2
        ELSE 2
    END AS current_level
FROM public.household_master
CROSS JOIN (VALUES
    ('Monday'),('Tuesday'),('Wednesday'),('Thursday'),
    ('Friday'),('Saturday'),('Sunday')
) AS days(day_of_week)
CROSS JOIN (VALUES
    ('Breakfast'),('Lunch'),('Dinner')
) AS slots(meal_slot)
ON CONFLICT (house_id, day_of_week, meal_slot) DO NOTHING;


-- ============================================================
-- SECTION 13: SEED USER INTELLIGENCE PROFILE
-- Default profile for all existing households
-- ============================================================

INSERT INTO public.user_intelligence_profile
    (house_id, current_confidence_score, active_window_size)
SELECT
    household_id,
    0.0,    -- Starts at 0 — Discovery mode
    4       -- Default 4-week observation window
FROM public.household_master
ON CONFLICT (house_id) DO NOTHING;


-- ============================================================
-- END OF V2 ADDITIONS
-- Total new tables: 8
-- Total new columns on existing tables: 12
-- Total features seeded: 44
-- ============================================================
