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
