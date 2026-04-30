-- ============================================================
-- Momentum Data Cleanup v1
-- Fixes: bad meal slots, Vegan→Veg misclassification
-- Run DRY RUN section first, then FIX section after review
-- ============================================================

-- ── DRY RUN — shows what will change ─────────────────────────────────────

-- 1. Bad meal slots — current distribution
SELECT 'BAD MEAL SLOTS — BEFORE' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
WHERE meal_slots && ARRAY['Snack','Snacks','Dessert','Festival Food']::text[]
   OR meal_slots = ARRAY['Side Dish']::text[]
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;

-- 2. Vegan misclassification — recipes tagged Vegan but contain dairy
-- ingredients_json lives in recipe_content_vault, joined here
SELECT 'VEGAN MISCLASSIFIED — BEFORE' as check_name,
       r.recipe_id, r.dish_name, r.diet_type
FROM recipe_dna_master r
JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
WHERE r.diet_type = 'Vegan'
  AND (
    v.ingredients_json::text ILIKE '%ghee%'
    OR v.ingredients_json::text ILIKE '%milk%'
    OR v.ingredients_json::text ILIKE '%curd%'
    OR v.ingredients_json::text ILIKE '%butter%'
    OR v.ingredients_json::text ILIKE '%paneer%'
    OR v.ingredients_json::text ILIKE '%cream%'
    OR v.ingredients_json::text ILIKE '%yogurt%'
    OR v.ingredients_json::text ILIKE '%yoghurt%'
    OR v.ingredients_json::text ILIKE '%cheese%'
    OR v.ingredients_json::text ILIKE '%khoa%'
    OR v.ingredients_json::text ILIKE '%khoya%'
  )
ORDER BY r.dish_name;

-- ============================================================
-- FIX SCRIPT — Run after reviewing dry run output
-- Copy the UPDATE statements below into pgAdmin and run
-- ============================================================

-- ── FIX 1: Remap bad meal slots ───────────────────────────────────────────

-- {Breakfast, Festival Food} → {Breakfast, Lunch}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Breakfast', 'Lunch']::text[]
WHERE meal_slots = ARRAY['Breakfast', 'Festival Food']::text[];

-- {Festival Food} → {Lunch}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch']::text[]
WHERE meal_slots = ARRAY['Festival Food']::text[];

-- {Breakfast, Snack} → {Breakfast, Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Breakfast', 'Side Dish']::text[]
WHERE meal_slots = ARRAY['Breakfast', 'Snack']::text[];

-- {Lunch, Snack} → {Lunch, Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Side Dish']::text[]
WHERE meal_slots = ARRAY['Lunch', 'Snack']::text[];

-- {Lunch, Snacks} → {Lunch, Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Snacks']::text[]
WHERE meal_slots = ARRAY['Lunch', 'Snacks']::text[];

-- {Snack, Dinner} → {Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Snack', 'Dinner']::text[];

-- {Snack} → {Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Snack']::text[];

-- {Snacks} → {Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Snacks']::text[];

-- {Dessert} → {Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Dessert']::text[];

-- {Breakfast, Side Dish} → {Side Dish} (side dish only — cleaner)
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Breakfast', 'Side Dish']::text[];

-- ── FIX 2: Reclassify Vegan → Veg where non-substitutable dairy present ─────
-- Rule: ghee excluded (substitutable with oil)
--       coconut milk excluded (vegan)
--       curd, butter, paneer, cream, yogurt, cheese, khoya → always Veg

UPDATE recipe_dna_master r
SET diet_type = 'Veg',
    is_vegan  = false
FROM recipe_content_vault v
WHERE v.recipe_id = r.recipe_id
  AND r.diet_type = 'Vegan'
  AND (
    v.ingredients_json::text ILIKE '%curd%'
    OR v.ingredients_json::text ILIKE '%butter%'
    OR v.ingredients_json::text ILIKE '%paneer%'
    OR v.ingredients_json::text ILIKE '%cream%'
    OR v.ingredients_json::text ILIKE '%yogurt%'
    OR v.ingredients_json::text ILIKE '%yoghurt%'
    OR v.ingredients_json::text ILIKE '%cheese%'
    OR v.ingredients_json::text ILIKE '%khoa%'
    OR v.ingredients_json::text ILIKE '%khoya%'
    OR (v.ingredients_json::text ILIKE '% milk%'
        AND v.ingredients_json::text NOT ILIKE '%coconut milk%')
  );

-- ── VERIFY — run after fix ─────────────────────────────────────────────────

SELECT 'MEAL SLOTS — AFTER' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;

SELECT 'DIET TYPE SUMMARY — AFTER' as check_name,
       diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY diet_type
ORDER BY diet_type;

-- ── DIAGNOSTIC — check what dairy keyword triggered each misclassified dish ──
SELECT
    r.dish_name,
    CASE WHEN v.ingredients_json::text ILIKE '%ghee%' THEN 'ghee ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '% milk%'
          AND v.ingredients_json::text NOT ILIKE '%coconut milk%' THEN 'cow-milk ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%curd%' THEN 'curd ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%butter%' THEN 'butter ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%paneer%' THEN 'paneer ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%cream%' THEN 'cream ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%yogurt%'
          OR v.ingredients_json::text ILIKE '%yoghurt%' THEN 'yogurt ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%cheese%' THEN 'cheese ' ELSE '' END ||
    CASE WHEN v.ingredients_json::text ILIKE '%khoa%'
          OR v.ingredients_json::text ILIKE '%khoya%' THEN 'khoya ' ELSE '' END
    as triggers
FROM recipe_dna_master r
JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
WHERE r.diet_type = 'Vegan'
  AND (
    v.ingredients_json::text ILIKE '%ghee%'
    OR (v.ingredients_json::text ILIKE '% milk%' AND v.ingredients_json::text NOT ILIKE '%coconut milk%')
    OR v.ingredients_json::text ILIKE '%curd%'
    OR v.ingredients_json::text ILIKE '%butter%'
    OR v.ingredients_json::text ILIKE '%paneer%'
    OR v.ingredients_json::text ILIKE '%cream%'
    OR v.ingredients_json::text ILIKE '%yogurt%'
    OR v.ingredients_json::text ILIKE '%yoghurt%'
    OR v.ingredients_json::text ILIKE '%cheese%'
    OR v.ingredients_json::text ILIKE '%khoa%'
    OR v.ingredients_json::text ILIKE '%khoya%'
  )
ORDER BY r.dish_name;

-- ── CLEANUP ROUND 2 ────────────────────────────────────────────────────────

-- Check 1: {Lunch, Snacks} missed by previous update
SELECT 'STILL BAD — Lunch,Snacks' as check_name, dish_name, diet_type, meal_slots
FROM recipe_dna_master
WHERE meal_slots = ARRAY['Lunch', 'Snacks']::text[];

-- Check 2: Recipes with NULL or empty meal_slots
SELECT 'NULL MEAL SLOTS' as check_name, dish_name, diet_type, meal_slots
FROM recipe_dna_master
WHERE meal_slots IS NULL OR meal_slots = '{}'::text[]
ORDER BY diet_type, dish_name;

-- FIX: {Lunch, Snacks} → {Lunch, Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Side Dish']::text[]
WHERE meal_slots = ARRAY['Lunch', 'Snacks']::text[];

-- ── DIAGNOSTIC: Show exact meal_slot values as stored in DB ───────────────
SELECT dish_name, diet_type,
       meal_slots,
       array_to_string(meal_slots, '|') as slots_piped
FROM recipe_dna_master
WHERE 'Snack' = ANY(meal_slots)
   OR 'Snacks' = ANY(meal_slots)
   OR 'Dessert' = ANY(meal_slots)
   OR 'Festival Food' = ANY(meal_slots)
ORDER BY slots_piped, diet_type;

-- Also show null slots
SELECT dish_name, diet_type, meal_slots
FROM recipe_dna_master
WHERE meal_slots IS NULL OR meal_slots = '{}'::text[]
ORDER BY diet_type, dish_name;

-- ── FINAL FIXES — using ANY operator (array equality was failing) ──────────

-- Fix meal slots using ANY instead of array equality
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE 'Snack' = ANY(meal_slots) AND array_length(meal_slots, 1) = 1;

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE 'Snacks' = ANY(meal_slots) AND array_length(meal_slots, 1) = 1;

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE 'Dessert' = ANY(meal_slots) AND array_length(meal_slots, 1) = 1;

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch']::text[]
WHERE 'Festival Food' = ANY(meal_slots) AND array_length(meal_slots, 1) = 1;

-- Multi-slot combinations
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Breakfast', 'Lunch']::text[]
WHERE 'Breakfast' = ANY(meal_slots) AND 'Festival Food' = ANY(meal_slots);

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Breakfast', 'Side Dish']::text[]
WHERE 'Breakfast' = ANY(meal_slots) AND 'Snack' = ANY(meal_slots);

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Side Dish']::text[]
WHERE 'Lunch' = ANY(meal_slots) AND 'Snack' = ANY(meal_slots);

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Side Dish']::text[]
WHERE 'Lunch' = ANY(meal_slots) AND 'Snacks' = ANY(meal_slots);

UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE 'Snack' = ANY(meal_slots) AND 'Dinner' = ANY(meal_slots);

-- Tirunelveli Macaroon — {Lunch, Snacks} → {Side Dish}
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE dish_name = 'Tirunelveli Macaroon';

-- Fix null meal slots
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE dish_name IN (
    'Classic Paneer Butter Masala',
    'White Gravy Paneer',
    'Chicken Curry',
    'Aloo Jeera',
    'Homestyle Dal Tadka'
);

-- Fix Vegan → Veg reclassification using JOIN
UPDATE recipe_dna_master r
SET diet_type = 'Veg',
    is_vegan  = false
FROM recipe_content_vault v
WHERE v.recipe_id = r.recipe_id
  AND r.diet_type = 'Vegan'
  AND (
    v.ingredients_json::text ILIKE '%curd%'
    OR v.ingredients_json::text ILIKE '%butter%'
    OR v.ingredients_json::text ILIKE '%paneer%'
    OR v.ingredients_json::text ILIKE '%cream%'
    OR v.ingredients_json::text ILIKE '%yogurt%'
    OR v.ingredients_json::text ILIKE '%yoghurt%'
    OR v.ingredients_json::text ILIKE '%cheese%'
    OR v.ingredients_json::text ILIKE '%khoa%'
    OR v.ingredients_json::text ILIKE '%khoya%'
    OR (v.ingredients_json::text ILIKE '% milk%'
        AND v.ingredients_json::text NOT ILIKE '%coconut milk%')
  );

-- ── FINAL VERIFY ───────────────────────────────────────────────────────────
SELECT 'FINAL — MEAL SLOTS' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;

SELECT 'FINAL — DIET SUMMARY' as check_name,
       diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY diet_type ORDER BY diet_type;

-- Confirm no bad slots remain
SELECT 'REMAINING BAD SLOTS' as check_name, dish_name, meal_slots
FROM recipe_dna_master
WHERE 'Snack' = ANY(meal_slots)
   OR 'Snacks' = ANY(meal_slots)
   OR 'Dessert' = ANY(meal_slots)
   OR 'Festival Food' = ANY(meal_slots)
   OR meal_slots IS NULL
   OR meal_slots = '{}'::text[];

-- ── ROUND 3: Fix the 5 null-slot dishes by name ───────────────────────────

-- Check exact dish names first
SELECT dish_name, meal_slots, diet_type
FROM recipe_dna_master
WHERE meal_slots IS NULL OR meal_slots = '{}'::text[]
   OR dish_name ILIKE '%Paneer Butter%'
   OR dish_name ILIKE '%White Gravy%'
   OR dish_name ILIKE '%Chicken Curry%'
   OR dish_name ILIKE '%Aloo Jeera%'
   OR dish_name ILIKE '%Dal Tadka%';

-- ── ROUND 3 FIX: Chettinad Chicken Curry — Lunch only → Lunch + Dinner ────
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE dish_name = 'Chettinad Chicken Curry'
  AND meal_slots = ARRAY['Lunch']::text[];

-- Final clean verify
SELECT meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;
