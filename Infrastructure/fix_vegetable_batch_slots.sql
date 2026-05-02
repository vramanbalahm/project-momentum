-- ============================================================
-- Momentum Data Fix — fix_vegetable_batch_slots.sql
-- Purpose: Fix meal slots for all vegetable batches seeded
--          Covers: Brinjal, Raw Banana, Yam, Ash Gourd batches
-- Date: May 2026
--
-- STEP 1: DRY RUN — review all changes
-- STEP 2: Run FIX
-- STEP 3: Run VERIFY
-- ============================================================


-- ============================================================
-- STEP 1: DRY RUN
-- ============================================================

-- Dishes that should be Side Dish (currently wrongly slotted as Lunch)
SELECT 'TO → Side Dish' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    -- Raw Banana batch
    'Raw Banana Stir-fry',
    'Raw Banana Fritters',
    -- Yam batch
    'Senai Kizhangu Varuval',
    'Senai Kizhangu Masiyal',
    'Senai Kizhangu Podi Curry',
    'Senai Kizhangu Kootu',
    'Senai Kizhangu Thogayal',
    -- Ash Gourd batch
    'Poosanikai Payasam',
    'Poosanikai Sambhar'
)
ORDER BY dish_name;

-- Dishes that should be Lunch+Dinner (currently wrongly slotted as Lunch or Side Dish)
SELECT 'TO → Lunch+Dinner' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    -- Yam batch — gravies wrongly as Lunch
    'Senai Kizhangu Kuzhambu',
    'Senai Kizhangu Puli Kuzhambu',
    'Senai Kizhangu Mor Kuzhambu',
    -- Yam side dish batch — vathal kuzhambu wrongly as Side Dish
    'Senai Kizhangu Vathal Kuzhambu',
    -- Raw Banana batch — gravies wrongly as Lunch
    'Raw Banana Curry',
    'Raw Banana Kofta Curry',
    'Raw Banana and Lentil Stew',
    'Raw Banana and Drumstick Curry',
    'Raw Banana and Peanut Curry',
    'Raw Banana Vada Curry'
)
ORDER BY dish_name;

-- Ash Gourd — Kootu and Aviyal correctly as Lunch+Dinner already
-- Poosanikai Kootu, Poosanikai Aviyal — confirm these are correct
SELECT 'CONFIRM Lunch+Dinner' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Poosanikai Kootu',
    'Poosanikai Aviyal',
    'Ash Gourd and Coconut Curry'
)
ORDER BY dish_name;


-- ============================================================
-- STEP 2: FIX
-- ============================================================

-- Fix 1: Move wrongly slotted dishes to Side Dish
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE dish_name IN (
    'Raw Banana Stir-fry',
    'Raw Banana Fritters',
    'Senai Kizhangu Varuval',
    'Senai Kizhangu Masiyal',
    'Senai Kizhangu Podi Curry',
    'Senai Kizhangu Kootu',
    'Senai Kizhangu Thogayal',
    'Poosanikai Payasam',
    'Poosanikai Sambhar'
);

-- Fix 2: Move gravies to Lunch+Dinner
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE dish_name IN (
    'Senai Kizhangu Kuzhambu',
    'Senai Kizhangu Puli Kuzhambu',
    'Senai Kizhangu Mor Kuzhambu',
    'Senai Kizhangu Vathal Kuzhambu',
    'Raw Banana Curry',
    'Raw Banana Kofta Curry',
    'Raw Banana and Lentil Stew',
    'Raw Banana and Drumstick Curry',
    'Raw Banana and Peanut Curry',
    'Raw Banana Vada Curry'
);

-- Fix 3: Drumstick batch fixes (from fix_drumstick_batch_slots.sql)
-- Already handled in separate script — skip here


-- ============================================================
-- STEP 3: VERIFY
-- ============================================================

SELECT 'FINAL SLOT DISTRIBUTION' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;

SELECT 'TOTAL RECIPES' as check_name, COUNT(*) as count
FROM recipe_dna_master;

SELECT 'BY DIET TYPE' as check_name, diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY diet_type ORDER BY diet_type;
