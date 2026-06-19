-- ============================================================
-- plan_funnel_report.sql
-- Shows the full recommendation pipeline funnel for the latest run
-- Usage: Run in psql or pgAdmin after generating a plan
-- ============================================================

WITH latest_run AS (
    SELECT run_id FROM plan_audit_log 
    ORDER BY created_at DESC LIMIT 1
),
funnel AS (
    SELECT
        al.day_name,
        al.meal_slot,
        al.feature_code,
        al.function_name,
        al.recipes_in,
        al.recipes_out,
        al.recipes_in - al.recipes_out as dropped,
        al.filter_reason,
        al.selected_recipe_id,
        al.execution_ms
    FROM plan_audit_log al
    JOIN latest_run lr ON al.run_id = lr.run_id
    ORDER BY
        CASE al.day_name
            WHEN 'Monday'    THEN 1
            WHEN 'Tuesday'   THEN 2
            WHEN 'Wednesday' THEN 3
            WHEN 'Thursday'  THEN 4
            WHEN 'Friday'    THEN 5
            WHEN 'Saturday'  THEN 6
            WHEN 'Sunday'    THEN 7
        END,
        CASE al.meal_slot
            WHEN 'Breakfast' THEN 1
            WHEN 'Lunch'     THEN 2
            WHEN 'Dinner'    THEN 3
        END,
        CASE al.feature_code
            WHEN 'RA-F03'    THEN 1
            WHEN 'RA-FA01'   THEN 2
            WHEN 'RA-F02'    THEN 3
            WHEN 'RA-F01'    THEN 4
            WHEN 'RA-FA02'   THEN 5
            WHEN 'RA-F08'    THEN 6
            WHEN 'RA-F04'    THEN 7
            WHEN 'RA-F05'    THEN 8
            WHEN 'RA-F13'    THEN 9
            WHEN 'RA-F14'    THEN 10
            WHEN 'RA-F15'    THEN 11
            WHEN 'RA-SELECT' THEN 12
            WHEN 'RA-F16'    THEN 13
        END
)
-- Summary view: recipes in vs out per formula
SELECT
    feature_code,
    function_name,
    COUNT(*)                    as slots_ran,
    AVG(recipes_in)::int        as avg_pool_in,
    AVG(recipes_out)::int       as avg_pool_out,
    AVG(dropped)::int           as avg_dropped,
    ROUND(
        100.0 * AVG(recipes_out) / NULLIF(AVG(recipes_in), 0), 1
    )                           as pass_rate_pct,
    MIN(filter_reason)          as sample_reason
FROM funnel
GROUP BY feature_code, function_name
ORDER BY
    CASE feature_code
        WHEN 'RA-F03'    THEN 1
        WHEN 'RA-FA01'   THEN 2
        WHEN 'RA-F02'    THEN 3
        WHEN 'RA-F01'    THEN 4
        WHEN 'RA-FA02'   THEN 5
        WHEN 'RA-F08'    THEN 6
        WHEN 'RA-F04'    THEN 7
        WHEN 'RA-F05'    THEN 8
        WHEN 'RA-F13'    THEN 9
        WHEN 'RA-F14'    THEN 10
        WHEN 'RA-F15'    THEN 11
        WHEN 'RA-SELECT' THEN 12
        WHEN 'RA-F16'    THEN 13
    END;

-- ── Detailed slot-by-slot view ────────────────────────────────────────────────
-- Uncomment below for full detail per slot

/*
SELECT
    day_name,
    meal_slot,
    feature_code,
    recipes_in,
    recipes_out,
    dropped,
    filter_reason
FROM funnel
ORDER BY day_name, meal_slot, feature_code;
*/

-- ── F16 side dish results ─────────────────────────────────────────────────────
SELECT
    f.day_name,
    f.meal_slot,
    f.filter_reason as sides_selected,
    f.execution_ms
FROM funnel f
WHERE f.feature_code = 'RA-F16'
ORDER BY
    CASE f.day_name
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END,
    CASE f.meal_slot
        WHEN 'Breakfast' THEN 1
        WHEN 'Lunch'     THEN 2
        WHEN 'Dinner'    THEN 3
    END;
