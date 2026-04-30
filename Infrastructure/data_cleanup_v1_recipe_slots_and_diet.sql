-- ============================================================
-- Momentum Data Cleanup v1
-- Run dry run first: psql ... -f this_file (reads SELECT only)
-- Run fix: psql ... -v apply=true -f this_file
-- ============================================================

-- ── DRY RUN — shows what will change ──────────────────────────────────────

-- 1. Bad meal slots — current distribution
SELECT 'BAD MEAL SLOTS — BEFORE' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
WHERE meal_slots && ARRAY['Snack','Snacks','Dessert','Festival Food','Side Dish','Snack & Tiffin']::text[]
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;

-- 2. Vegan misclassification — recipes tagged Vegan but contain dairy ingredients
SELECT 'VEGAN MISCLASSIFIED — BEFORE' as check_name,
       r.recipe_id, r.dish_name, r.diet_type,
       r.ingredients_json::text
FROM recipe_dna_master r
WHERE r.diet_type = 'Vegan'
  AND (
    LOWER(r.ingredients_json::text) LIKE '%ghee%'
    OR LOWER(r.ingredients_json::text) LIKE '%milk%'
    OR LOWER(r.ingredients_json::text) LIKE '%curd%'
    OR LOWER(r.ingredients_json::text) LIKE '%butter%'
    OR LOWER(r.ingredients_json::text) LIKE '%paneer%'
    OR LOWER(r.ingredients_json::text) LIKE '%cream%'
    OR LOWER(r.ingredients_json::text) LIKE '%yogurt%'
    OR LOWER(r.ingredients_json::text) LIKE '%yoghurt%'
    OR LOWER(r.ingredients_json::text) LIKE '%cheese%'
    OR LOWER(r.ingredients_json::text) LIKE '%khoa%'
    OR LOWER(r.ingredients_json::text) LIKE '%khoya%'
  )
ORDER BY r.dish_name;


-- ============================================================
-- FIX SCRIPT — Run only after reviewing dry run output above
-- Copy everything below into pgAdmin and run manually
-- ============================================================

-- ── FIX 1: Remap bad meal slots ───────────────────────────────────────────

-- Snack → Side Dish
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Snack']::text[];

-- Snacks → Side Dish
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Snacks']::text[];

-- Dessert → Side Dish
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE meal_slots = ARRAY['Dessert']::text[];

-- Festival Food → Lunch
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch']::text[]
WHERE meal_slots = ARRAY['Festival Food']::text[];

-- ── FIX 2: Reclassify Vegan → Veg where dairy ingredients present ─────────

UPDATE recipe_dna_master
SET diet_type = 'Veg',
    is_vegan  = false
WHERE diet_type = 'Vegan'
  AND (
    LOWER(ingredients_json::text) LIKE '%ghee%'
    OR LOWER(ingredients_json::text) LIKE '%milk%'
    OR LOWER(ingredients_json::text) LIKE '%curd%'
    OR LOWER(ingredients_json::text) LIKE '%butter%'
    OR LOWER(ingredients_json::text) LIKE '%paneer%'
    OR LOWER(ingredients_json::text) LIKE '%cream%'
    OR LOWER(ingredients_json::text) LIKE '%yogurt%'
    OR LOWER(ingredients_json::text) LIKE '%yoghurt%'
    OR LOWER(ingredients_json::text) LIKE '%cheese%'
    OR LOWER(ingredients_json::text) LIKE '%khoa%'
    OR LOWER(ingredients_json::text) LIKE '%khoya%'
  );

-- ── VERIFY — run after fix to confirm results ─────────────────────────────

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
