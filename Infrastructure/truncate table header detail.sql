BEGIN;

-- This will wipe all three tables and reset their relationships
TRUNCATE 
    public.meal_event_header, 
    public.meal_event_detail, 
    public.meal_audit_logs 
RESTART IDENTITY CASCADE;

COMMIT;