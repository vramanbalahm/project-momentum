-- ============================================================
-- Schema v23 — meal_role array on recipe_dna_master
-- Date: 2026-06-07
-- Purpose: Replace binary is_side_dish flag with meal_role array
--          so a dish can be both main AND side (e.g. Sambar)
-- Changes:
--   1. Add meal_role TEXT[] to recipe_dna_master
--   2. Migrate existing 'Side Dish' from meal_slots → meal_role
--   3. Remove 'Side Dish' from meal_slots
--   4. Add GIN index on meal_role
-- ============================================================

-- STEP 1: Add meal_role column
ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS meal_role TEXT[] DEFAULT '{main}';

COMMENT ON COLUMN public.recipe_dna_master.meal_role IS
    'Role of this dish — main, side, or both.
     {main}       = served as primary dish only (Biryani, Idli etc.)
     {side}       = served as accompaniment only (Chutney, Pickle, Papad)
     {main,side}  = can serve as either (Sambar, Rasam, Dal)
     Replaces the incorrect use of meal_slots for this purpose.';

-- STEP 2: Set meal_role based on current meal_slots data
-- Dishes with 'Side Dish' in meal_slots → meal_role = {side}
UPDATE public.recipe_dna_master
SET meal_role = '{side}'
WHERE meal_slots @> ARRAY['Side Dish']::text[]
AND NOT (meal_slots && ARRAY['Breakfast','Lunch','Dinner']::text[]);

-- Dishes with 'Side Dish' AND other slots → meal_role = {main,side}
UPDATE public.recipe_dna_master
SET meal_role = '{main,side}'
WHERE meal_slots @> ARRAY['Side Dish']::text[]
AND meal_slots && ARRAY['Breakfast','Lunch','Dinner']::text[];

-- Known dual-role dishes — can be both main and side
-- Sambar, Rasam, Dal — commonly served as side with rice but also as main
UPDATE public.recipe_dna_master
SET meal_role = '{main,side}'
WHERE LOWER(dish_name) SIMILAR TO '%(sambar|rasam|dal|dhal|kootu|kuzhambu|curry|gravy|chutney|raita|pachadi)%'
AND meal_role = '{main}';

-- Pure side dishes — never served as main
UPDATE public.recipe_dna_master
SET meal_role = '{side}'
WHERE LOWER(dish_name) SIMILAR TO '%(pickle|achar|papad|appalam|vadam|chutney|thogayal|podimas|raita|pachadi|salad|accompaniment)%'
AND meal_role = '{main}';

-- STEP 3: Remove 'Side Dish' from meal_slots array
-- meal_slots should only contain Breakfast, Lunch, Dinner
UPDATE public.recipe_dna_master
SET meal_slots = ARRAY(
    SELECT UNNEST(meal_slots)
    EXCEPT
    SELECT 'Side Dish'
)
WHERE meal_slots @> ARRAY['Side Dish']::text[];

-- For recipes that had ONLY 'Side Dish' in meal_slots (now empty)
-- Set them to all slots since sides can be served at any meal
UPDATE public.recipe_dna_master
SET meal_slots = ARRAY['Breakfast','Lunch','Dinner']::text[]
WHERE (meal_slots IS NULL OR array_length(meal_slots, 1) = 0)
AND meal_role @> ARRAY['side']::text[];

-- STEP 4: Add GIN index for fast meal_role queries
CREATE INDEX IF NOT EXISTS idx_recipe_meal_role
    ON public.recipe_dna_master USING GIN(meal_role);

-- STEP 5: Verify
SELECT
    meal_role,
    COUNT(*) as recipe_count,
    array_agg(DISTINCT unnest_slots) as slots_used
FROM recipe_dna_master,
     LATERAL unnest(COALESCE(meal_slots, ARRAY[]::text[])) as unnest_slots
GROUP BY meal_role
ORDER BY meal_role;
