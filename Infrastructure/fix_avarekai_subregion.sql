-- ============================================================
-- Momentum Data Fix — fix_avarekai_subregion.sql
-- Purpose: Reclassify Avarekai dishes as Karnataka sub_region
--          Avarekai is a Karnataka ingredient, not Tamil Nadu
-- Date: May 2026
--
-- STEP 1: DRY RUN
-- STEP 2: FIX
-- STEP 3: VERIFY
-- ============================================================

-- STEP 1: DRY RUN
SELECT dish_name, sub_region FROM recipe_dna_master
WHERE sub_region ILIKE '%Avarekai%'
ORDER BY dish_name;

-- STEP 2: FIX
UPDATE recipe_dna_master
SET sub_region           = 'Karnataka',
    source_region        = 'Karnataka',
    is_regional_specific = true
WHERE sub_region ILIKE '%Avarekai%';

-- STEP 3: VERIFY
SELECT dish_name, sub_region, source_region FROM recipe_dna_master
WHERE dish_name ILIKE '%Avarekai%'
ORDER BY dish_name;
