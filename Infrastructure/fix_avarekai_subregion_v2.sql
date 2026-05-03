-- ============================================================
-- Momentum Data Fix — fix_avarekai_subregion_v2.sql
-- Purpose: Reclassify specific Avarekai dishes as Karnataka
--          Rest stay as Tamil Nadu — QA will validate
-- Date: May 2026
--
-- STEP 1: DRY RUN
-- STEP 2: FIX
-- STEP 3: VERIFY
-- ============================================================

-- STEP 1: DRY RUN
SELECT dish_name, sub_region FROM recipe_dna_master
WHERE dish_name IN (
    'Avarekai Majjige Huli',
    'Avarekai Huli',
    'Avarekai Bisibelebath',
    'Avarekai Akki Roti',
    'Avarekai Gojju'
);

-- STEP 2: FIX — Karnataka dishes
UPDATE recipe_dna_master
SET sub_region           = 'Karnataka',
    source_region        = 'Karnataka',
    is_regional_specific = true
WHERE dish_name IN (
    'Avarekai Majjige Huli',
    'Avarekai Huli',
    'Avarekai Bisibelebath',
    'Avarekai Akki Roti',
    'Avarekai Gojju'
);

-- Fix remaining Avarekai to Tamil Nadu
UPDATE recipe_dna_master
SET sub_region    = 'General Tamil Nadu',
    source_region = 'Tamil Nadu'
WHERE sub_region ILIKE '%Avarekai%';

-- STEP 3: VERIFY
SELECT dish_name, sub_region, source_region
FROM recipe_dna_master
WHERE dish_name ILIKE '%Avarekai%'
ORDER BY sub_region, dish_name;
