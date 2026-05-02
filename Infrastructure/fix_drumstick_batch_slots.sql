-- ============================================================
-- Momentum Data Fix — fix_drumstick_batch_slots.sql
-- Purpose: Kuzhambu/Curry dishes wrongly inserted as Side Dish
--          → reclassify to Lunch + Dinner
-- Date: May 2026
--
-- STEP 1: DRY RUN
-- STEP 2: Review
-- STEP 3: FIX
-- STEP 4: VERIFY
-- ============================================================


-- ============================================================
-- STEP 1: DRY RUN
-- ============================================================

SELECT 'TO RECLASSIFY → Lunch+Dinner' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Drumstick Puli Kuzhambu',
    'Drumstick Mor Kuzhambu',
    'Drumstick Vathal Kuzhambu',
    'Drumstick Curry'
);

SELECT 'STAYS AS Side Dish' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Drumstick Podi Poriyal',
    'Drumstick Thogayal',
    'Drumstick Kootu',
    'Drumstick Rasam',
    'Drumstick Pachadi',
    'Drumstick Aviyal',
    'Drumstick Leaves Stir-fry'
);


-- ============================================================
-- STEP 3: FIX
-- ============================================================

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE dish_name IN (
    'Drumstick Puli Kuzhambu',
    'Drumstick Mor Kuzhambu',
    'Drumstick Vathal Kuzhambu',
    'Drumstick Curry'
);


-- ============================================================
-- STEP 4: VERIFY
-- ============================================================

SELECT dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Drumstick Puli Kuzhambu',
    'Drumstick Mor Kuzhambu',
    'Drumstick Vathal Kuzhambu',
    'Drumstick Curry',
    'Drumstick Podi Poriyal',
    'Drumstick Thogayal',
    'Drumstick Kootu',
    'Drumstick Rasam',
    'Drumstick Pachadi',
    'Drumstick Aviyal',
    'Drumstick Leaves Stir-fry'
)
ORDER BY meal_slots::text, dish_name;
