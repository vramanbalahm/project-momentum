-- ============================================================
-- delete_recipes.sql — Safe recipe deletion utility
-- Deletes from all dependent tables in correct order
-- Usage: Replace dish names in the IN clause below
-- ============================================================

-- EDIT THIS LIST with dish names to delete
DO $$
DECLARE
    dish_names TEXT[] := ARRAY[
        'Dish Name 1',
        'Dish Name 2'
    ];
BEGIN
    -- Step 1: behavioral_tracker
    DELETE FROM behavioral_tracker
    WHERE new_recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names))
    OR original_recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 1 done: behavioral_tracker';

    -- Step 2: meal_audit_logs
    DELETE FROM meal_audit_logs
    WHERE recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 2 done: meal_audit_logs';

    -- Step 3: meal_event_detail
    DELETE FROM meal_event_detail
    WHERE recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names))
    OR original_suggested_recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 3 done: meal_event_detail';

    -- Step 4: recipe_content_vault
    DELETE FROM recipe_content_vault
    WHERE recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 4 done: recipe_content_vault';

    -- Step 5: recipe_ingredients
    DELETE FROM recipe_ingredients
    WHERE recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 5 done: recipe_ingredients';

    -- Step 6: recipe_pairing
    DELETE FROM recipe_pairing
    WHERE main_recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names))
    OR side_recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE dish_name = ANY(dish_names));
    RAISE NOTICE 'Step 6 done: recipe_pairing';

    -- Step 7: recipe_dna_master
    DELETE FROM recipe_dna_master WHERE dish_name = ANY(dish_names);
    RAISE NOTICE 'Step 7 done: recipe_dna_master';

    RAISE NOTICE 'All done!';
END $$;

-- Verify
SELECT COUNT(*) as remaining FROM recipe_dna_master WHERE review_status = 'approved';
