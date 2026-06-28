-- ============================================================
-- fix_continental_pairings.sql
-- Fix continental pairing data — match sides to correct mains
-- ============================================================

-- STEP 1: Fix Chicken Curry sub_region — not continental
UPDATE recipe_dna_master
SET sub_region = 'Tamil Nadu'
WHERE dish_name = 'Chicken Curry';

-- STEP 2: Delete ALL existing continental pairings and rebuild cleanly
DELETE FROM recipe_pairing
WHERE main_recipe_id IN (
    SELECT recipe_id FROM recipe_dna_master
    WHERE dish_category = 'continental'
    AND meal_role @> ARRAY['main']::text[]
)
AND house_id IS NULL;

-- STEP 3: Insert correct pairings by main type

-- Breakfast continental mains → Butter, Jam, Honey, Cheese Spread only
INSERT INTO recipe_pairing (main_recipe_id, side_recipe_id, confidence, source, house_id)
SELECT m.recipe_id, s.recipe_id, 0.90, 'seeded', NULL
FROM recipe_dna_master m
CROSS JOIN recipe_dna_master s
WHERE m.dish_category = 'continental'
AND m.meal_role @> ARRAY['main']::text[]
AND m.meal_slots @> ARRAY['Breakfast']::text[]
AND NOT (m.meal_slots @> ARRAY['Lunch']::text[])  -- breakfast only mains
AND s.dish_name IN ('Butter', 'Strawberry Jam', 'Mixed Fruit Jam', 'Honey', 'Cheese Spread')
AND s.meal_role @> ARRAY['side']::text[]
ON CONFLICT DO NOTHING;

-- Pasta/Macaroni mains → Garden Salad, Garlic Bread, Cheese Spread
INSERT INTO recipe_pairing (main_recipe_id, side_recipe_id, confidence, source, house_id)
SELECT m.recipe_id, s.recipe_id, 0.90, 'seeded', NULL
FROM recipe_dna_master m
CROSS JOIN recipe_dna_master s
WHERE m.dish_name IN (
    'Pasta Arrabiata', 'Pasta Aglio Olio', 'Pasta in White Sauce', 'Pasta Pesto',
    'Baked Macaroni and Cheese', 'Macaroni in Tomato Sauce'
)
AND s.dish_name IN ('Garden Salad', 'Garlic Bread', 'Cheese Spread')
AND s.meal_role @> ARRAY['side']::text[]
ON CONFLICT DO NOTHING;

-- Noodles/Fried Rice mains → Garden Salad only
INSERT INTO recipe_pairing (main_recipe_id, side_recipe_id, confidence, source, house_id)
SELECT m.recipe_id, s.recipe_id, 0.88, 'seeded', NULL
FROM recipe_dna_master m
CROSS JOIN recipe_dna_master s
WHERE m.dish_name IN (
    'Hakka Noodles', 'Schezwan Noodles', 'Stir Fry Noodles',
    'Indo-Chinese Fried Rice', 'Schezwan Fried Rice'
)
AND s.dish_name IN ('Garden Salad')
AND s.meal_role @> ARRAY['side']::text[]
ON CONFLICT DO NOTHING;

-- Sandwich → Butter, Cheese Spread, Garden Salad
INSERT INTO recipe_pairing (main_recipe_id, side_recipe_id, confidence, source, house_id)
SELECT m.recipe_id, s.recipe_id, 0.90, 'seeded', NULL
FROM recipe_dna_master m
CROSS JOIN recipe_dna_master s
WHERE m.dish_name = 'Vegetable Sandwich'
AND s.dish_name IN ('Butter', 'Cheese Spread', 'Garden Salad')
AND s.meal_role @> ARRAY['side']::text[]
ON CONFLICT DO NOTHING;

-- STEP 4: Verify
SELECT r.dish_name as main, s.dish_name as side, s.dish_category
FROM recipe_pairing rp
JOIN recipe_dna_master r ON r.recipe_id = rp.main_recipe_id
JOIN recipe_dna_master s ON s.recipe_id = rp.side_recipe_id
WHERE r.dish_category = 'continental'
AND rp.house_id IS NULL
ORDER BY r.dish_name, s.dish_name;
