select * from meal_audit_logs

select * from meal_event_header

select * from meal_event_detail

SELECT 
    (SELECT COUNT(*) FROM meal_event_header) as headers,
    (SELECT COUNT(*) FROM meal_event_detail) as details,
    (SELECT COUNT(*) FROM meal_audit_logs) as logs;