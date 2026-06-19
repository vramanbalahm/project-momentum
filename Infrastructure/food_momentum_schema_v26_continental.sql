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
