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
    execution_order = EXCLUDED.execution_order,
    is_active       = EXCLUDED.is_active,
    description     = EXCLUDED.description,
    updated_at      = NOW();

-- STEP 3: Create plan_audit_log table (Bucket C)
CREATE TABLE IF NOT EXISTS public.plan_audit_log (
    log_id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    house_id        UUID            NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    week_start      DATE            NOT NULL,
    day_name        VARCHAR(10)     NOT NULL,  -- Monday, Tuesday etc.
    meal_slot       VARCHAR(10)     NOT NULL,  -- Breakfast, Lunch, Dinner
    feature_code    VARCHAR(20)     NOT NULL REFERENCES public.feature_registry(feature_code),
    function_name   VARCHAR(100)    NOT NULL,
    recipes_in      INTEGER         NOT NULL DEFAULT 0,  -- count before this filter
    recipes_out     INTEGER         NOT NULL DEFAULT 0,  -- count after this filter
    filtered_count  INTEGER         NOT NULL DEFAULT 0,  -- how many removed
    filter_reason   TEXT,                                -- human readable reason
    filtered_ids    UUID[]          DEFAULT '{}',        -- recipe_ids that were removed
    selected_id     UUID,                                -- final selected recipe (last step only)
    execution_ms    INTEGER,                             -- time taken in ms
    created_at      TIMESTAMP       DEFAULT NOW()
);

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
