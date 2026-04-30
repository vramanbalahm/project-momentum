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
