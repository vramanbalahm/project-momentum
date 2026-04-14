-- ============================================================
-- Seed side dish relationships for testing multi-dish display
-- Date: 14-Apr-2026
-- Purpose: Populate meal_event_detail with side dishes for
--          existing test meals so the UI can show side chips
-- ============================================================

-- First check what recipe_ids exist in recipe_dna_master
-- We will link existing recipes as sides to existing header slots

-- Add side dishes to existing meal_event_detail records
-- Using existing recipe_ids as sides for the current test plan

-- Step 1: Get existing event_ids from meal_event_header
-- Step 2: Insert side dishes into meal_event_detail

DO $$
DECLARE
    v_event_id UUID;
    v_recipes UUID[];
    v_idx INT;
BEGIN
    -- Get all recipe_ids available
    SELECT ARRAY(SELECT recipe_id FROM recipe_dna_master LIMIT 5)
    INTO v_recipes;

    -- For each meal_event_header that has only a main dish,
    -- add 2 side dishes using available recipes
    v_idx := 1;
    FOR v_event_id IN
        SELECT DISTINCT h.event_id
        FROM meal_event_header h
        WHERE (
            SELECT COUNT(*) FROM meal_event_detail d
            WHERE d.event_id = h.event_id
        ) = 1  -- Only has main dish currently
        LIMIT 10
    LOOP
        -- Add side dish 1
        IF array_length(v_recipes, 1) >= 1 THEN
            INSERT INTO meal_event_detail
                (event_id, recipe_id, action_taken, dish_type, dish_sequence)
            VALUES
                (v_event_id,
                 v_recipes[((v_idx - 1) % array_length(v_recipes, 1)) + 1],
                 'Accepted', 'Side', 2)
            ON CONFLICT DO NOTHING;
        END IF;

        -- Add side dish 2
        IF array_length(v_recipes, 1) >= 2 THEN
            INSERT INTO meal_event_detail
                (event_id, recipe_id, action_taken, dish_type, dish_sequence)
            VALUES
                (v_event_id,
                 v_recipes[((v_idx) % array_length(v_recipes, 1)) + 1],
                 'Accepted', 'Side', 3)
            ON CONFLICT DO NOTHING;
        END IF;

        v_idx := v_idx + 1;
    END LOOP;
END $$;

-- Verify
SELECT
    h.meal_slot,
    h.event_date,
    d.dish_type,
    d.dish_sequence,
    r.dish_name
FROM meal_event_header h
JOIN meal_event_detail d ON h.event_id = d.event_id
JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
ORDER BY h.event_date, h.meal_slot, d.dish_sequence
LIMIT 30;
