-- ============================================================
-- plan_funnel_report.sql
-- Full pipeline funnel visibility from audit log
-- Run after generating a plan in the app
-- ============================================================

-- ── Result 1: Pipeline funnel summary ────────────────────────────────────────
WITH latest_run AS (
    SELECT run_id FROM plan_audit_log 
    ORDER BY created_at DESC LIMIT 1
)
SELECT
    al.feature_code,
    al.function_name,
    COUNT(*)                    as slots_ran,
    AVG(al.recipes_in)::int     as avg_pool_in,
    AVG(al.recipes_out)::int    as avg_pool_out,
    AVG(al.recipes_in - al.recipes_out)::int as avg_dropped,
    ROUND(100.0 * AVG(al.recipes_out) / NULLIF(AVG(al.recipes_in), 0), 1) as pass_rate_pct,
    MIN(al.filter_reason)       as sample_reason
FROM plan_audit_log al
JOIN latest_run lr ON al.run_id = lr.run_id
GROUP BY al.feature_code, al.function_name
ORDER BY
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
    END;

-- ── Result 2: F16 side dish results per slot ─────────────────────────────────
WITH latest_run AS (
    SELECT run_id FROM plan_audit_log 
    ORDER BY created_at DESC LIMIT 1
)
SELECT
    al.day_name,
    al.meal_slot,
    al.filter_reason as sides_selected,
    al.execution_ms
FROM plan_audit_log al
JOIN latest_run lr ON al.run_id = lr.run_id
WHERE al.feature_code = 'RA-F16'
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
    END;
