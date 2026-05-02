-- ============================================================
-- Momentum Data Fix — meal_slots_dinner_to_lunch_dinner.sql
-- Purpose: Reclassify dinner-only gravies/curries to Lunch+Dinner
-- Date: May 2026
--
-- STEP 1: Run the DRY RUN section to see what will change
-- STEP 2: Review the output
-- STEP 3: Run the FIX section
-- STEP 4: Run the VERIFY section to confirm
-- ============================================================


-- ============================================================
-- STEP 1: DRY RUN — see what will change (SELECT only, safe to run)
-- ============================================================

SELECT 'NON-VEG TO FIX' as check_name, dish_name, meal_slots
FROM recipe_dna_master
WHERE meal_slots = ARRAY['Dinner']::text[]
  AND diet_type = 'Non-Veg'
  AND dish_name != 'Thanjavur Mutton Kari Dosai'
  AND (
    LOWER(dish_name) LIKE '%kuzhambu%'
    OR LOWER(dish_name) LIKE '%kari%'
    OR LOWER(dish_name) LIKE '%curry%'
    OR LOWER(dish_name) LIKE '%varuval%'
    OR LOWER(dish_name) LIKE '%masala%'
    OR LOWER(dish_name) LIKE '%paya%'
    OR LOWER(dish_name) LIKE '%kurma%'
    OR LOWER(dish_name) LIKE '%gravy%'
    OR LOWER(dish_name) LIKE '%pirattal%'
    OR LOWER(dish_name) LIKE '%chukka%'
  )
ORDER BY dish_name;

SELECT 'VEG/VEGAN TO FIX' as check_name, dish_name, meal_slots, diet_type
FROM recipe_dna_master
WHERE meal_slots = ARRAY['Dinner']::text[]
  AND diet_type IN ('Veg', 'Vegan')
  AND (
    LOWER(dish_name) LIKE '%kuzhambu%'
    OR LOWER(dish_name) LIKE '%kari%'
    OR LOWER(dish_name) LIKE '%kootu%'
    OR LOWER(dish_name) LIKE '%varuval%'
    OR LOWER(dish_name) LIKE '%masala%'
    OR LOWER(dish_name) LIKE '%kurma%'
    OR LOWER(dish_name) LIKE '%poriyal%'
    OR LOWER(dish_name) LIKE '%pirattal%'
  )
ORDER BY dish_name;


-- ============================================================
-- STEP 2: Review output above before proceeding
-- ============================================================


-- ============================================================
-- STEP 3: FIX — run only after reviewing Step 1 output
-- ============================================================

-- Fix Non-Veg (excludes Thanjavur Mutton Kari Dosai — dinner-specific)
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE meal_slots = ARRAY['Dinner']::text[]
  AND diet_type = 'Non-Veg'
  AND dish_name != 'Thanjavur Mutton Kari Dosai'
  AND (
    LOWER(dish_name) LIKE '%kuzhambu%'
    OR LOWER(dish_name) LIKE '%kari%'
    OR LOWER(dish_name) LIKE '%curry%'
    OR LOWER(dish_name) LIKE '%varuval%'
    OR LOWER(dish_name) LIKE '%masala%'
    OR LOWER(dish_name) LIKE '%paya%'
    OR LOWER(dish_name) LIKE '%kurma%'
    OR LOWER(dish_name) LIKE '%gravy%'
    OR LOWER(dish_name) LIKE '%pirattal%'
    OR LOWER(dish_name) LIKE '%chukka%'
  );

-- Fix Veg and Vegan
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE meal_slots = ARRAY['Dinner']::text[]
  AND diet_type IN ('Veg', 'Vegan')
  AND (
    LOWER(dish_name) LIKE '%kuzhambu%'
    OR LOWER(dish_name) LIKE '%kari%'
    OR LOWER(dish_name) LIKE '%kootu%'
    OR LOWER(dish_name) LIKE '%varuval%'
    OR LOWER(dish_name) LIKE '%masala%'
    OR LOWER(dish_name) LIKE '%kurma%'
    OR LOWER(dish_name) LIKE '%poriyal%'
    OR LOWER(dish_name) LIKE '%pirattal%'
  );


-- ============================================================
-- STEP 4: VERIFY — run after Step 3 to confirm results
-- ============================================================

SELECT 'DINNER SLOTS AFTER FIX' as check_name,
       meal_slots, diet_type, COUNT(*) as count
FROM recipe_dna_master
WHERE 'Dinner' = ANY(meal_slots)
GROUP BY meal_slots, diet_type
ORDER BY meal_slots::text, diet_type;
