-- ============================================================
-- Momentum Data Fix — fix_brinjal_batch_slots.sql
-- Purpose: Correct meal slots for brinjal batch inserted as Lunch
--          Some are side dishes, some are Lunch+Dinner gravies
-- Date: May 2026
--
-- STEP 1: Run DRY RUN to confirm dishes exist
-- STEP 2: Review
-- STEP 3: Run FIX
-- STEP 4: Run VERIFY
-- ============================================================


-- ============================================================
-- STEP 1: DRY RUN
-- ============================================================

SELECT 'RECLASSIFY TO SIDE DISH' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Kathirikai Thokku',
    'Kathirikai Poriyal (Chettinad Style)',
    'Spicy Brinjal Fry',
    'Kathirikai Kara Curry'
);

SELECT 'RECLASSIFY TO LUNCH+DINNER' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Brinjal Vathal Kuzhambu',
    'Kathirikai Gothsu (Kongu Nadu Style)',
    'Kathirikai Mor Kuzhambu',
    'Kathirikai Perum Kaai Kara Kuzhambu',
    'Kathirikai Puli Kuzhambu (Madurai Style)',
    'Kathirikai Vathal Kuzhambu',
    'Brinjal and Drumstick Kuzhambu',
    'Brinjal and Lentil Stew',
    'Brinjal and Yam Curry',
    'Brinjal and Peanut Curry',
    'Brinjal and Coconut Milk Curry'
);

SELECT 'STAYS AS LUNCH' as action, dish_name, meal_slots
FROM recipe_dna_master
WHERE dish_name IN (
    'Brinjal Mappillai Kathirikai',
    'Kothavarangai Brinjal Curry',
    'Brinjal Podi Curry'
);


-- ============================================================
-- STEP 3: FIX
-- ============================================================

-- Reclassify to Side Dish
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Side Dish']::text[]
WHERE dish_name IN (
    'Kathirikai Thokku',
    'Kathirikai Poriyal (Chettinad Style)',
    'Spicy Brinjal Fry',
    'Kathirikai Kara Curry'
);

-- Reclassify to Lunch + Dinner
UPDATE recipe_dna_master
SET meal_slots = ARRAY['Lunch', 'Dinner']::text[]
WHERE dish_name IN (
    'Brinjal Vathal Kuzhambu',
    'Kathirikai Gothsu (Kongu Nadu Style)',
    'Kathirikai Mor Kuzhambu',
    'Kathirikai Perum Kaai Kara Kuzhambu',
    'Kathirikai Puli Kuzhambu (Madurai Style)',
    'Kathirikai Vathal Kuzhambu',
    'Brinjal and Drumstick Kuzhambu',
    'Brinjal and Lentil Stew',
    'Brinjal and Yam Curry',
    'Brinjal and Peanut Curry',
    'Brinjal and Coconut Milk Curry'
);


-- ============================================================
-- STEP 4: VERIFY
-- ============================================================

SELECT dish_name, meal_slots, diet_type
FROM recipe_dna_master
WHERE dish_name IN (
    'Kathirikai Thokku',
    'Kathirikai Poriyal (Chettinad Style)',
    'Spicy Brinjal Fry',
    'Kathirikai Kara Curry',
    'Brinjal Vathal Kuzhambu',
    'Kathirikai Gothsu (Kongu Nadu Style)',
    'Kathirikai Mor Kuzhambu',
    'Kathirikai Perum Kaai Kara Kuzhambu',
    'Kathirikai Puli Kuzhambu (Madurai Style)',
    'Kathirikai Vathal Kuzhambu',
    'Brinjal and Drumstick Kuzhambu',
    'Brinjal and Lentil Stew',
    'Brinjal and Yam Curry',
    'Brinjal and Peanut Curry',
    'Brinjal and Coconut Milk Curry',
    'Brinjal Mappillai Kathirikai',
    'Kothavarangai Brinjal Curry',
    'Brinjal Podi Curry'
)
ORDER BY meal_slots::text, dish_name;
