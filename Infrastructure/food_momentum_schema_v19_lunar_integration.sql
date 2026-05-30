-- ============================================================
-- Schema v19 — Lunar Calendar Integration
-- Date: 2026-05-30
-- Changes:
--   1. Add panchangam_type_id (nullable) to event_master
--      - source='ADMIN' lunar rows: set to household's panchangam type
--      - source='USER' personal rows: NULL (birthdays etc.)
--   2. Drop UNIQUE constraint on event_master.event_code
--      - event_master uses event_id (UUID) as primary key
--      - Multiple lunar events per year have same event_name
--      - UNIQUE constraint remains on panchangam_master (correct)
--
-- Architecture:
--   panchangam_master  → platform calendar (admin seeded, read-only)
--   event_master       → household events (lunar + personal)
--     source='ADMIN'   → copied from panchangam_master by system
--     source='USER'    → added by household (birthdays etc.)
--   is_active flag     → controls which lunar observations household follows
-- ============================================================

-- STEP 1: Add panchangam_type_id to event_master
ALTER TABLE public.event_master
    ADD COLUMN IF NOT EXISTS panchangam_type_id INTEGER REFERENCES public.panchangam_types(id);

COMMENT ON COLUMN public.event_master.panchangam_type_id IS
    'Which Panchangam this event belongs to.
     Set for source=ADMIN lunar events (copied from panchangam_master).
     NULL for source=USER personal events (birthdays, anniversaries etc.).
     Used to identify and replace all lunar rows when household changes Panchangam type.';

-- STEP 2: Drop UNIQUE constraint on event_master.event_code
-- event_master uses event_id (UUID) as primary key.
-- Multiple lunar events can have same event_name (Pradosham repeats monthly).
-- UNIQUE constraint on panchangam_master is correct and stays.
ALTER TABLE public.event_master
    DROP CONSTRAINT IF EXISTS event_master_event_code_key;

-- STEP 3: Add indexes for efficient lookups
-- For recommendation engine — check if today is a Satvik day for a household
CREATE INDEX IF NOT EXISTS idx_event_master_house_date_satvik
    ON public.event_master(house_id, event_date)
    WHERE is_active = true AND is_sattvic_required = true;

-- For lunar setup — find all household lunar events by panchangam type
CREATE INDEX IF NOT EXISTS idx_event_master_house_panchangam
    ON public.event_master(house_id, panchangam_type_id)
    WHERE source = 'ADMIN';

-- STEP 4: Fix existing ADMIN data — all ADMIN rows must be event_type = 'Lunar'
UPDATE public.event_master
SET event_type = 'Lunar'
WHERE source = 'ADMIN'
AND event_type != 'Lunar';

-- STEP 5: Add CHECK constraint to enforce ADMIN = Lunar only
-- Drop existing check first then recreate
ALTER TABLE public.event_master
    DROP CONSTRAINT IF EXISTS event_master_event_type_check;

ALTER TABLE public.event_master
    ADD CONSTRAINT event_master_event_type_check CHECK (
        (source = 'ADMIN' AND event_type = 'Lunar')
        OR
        (source = 'USER' AND event_type IN ('Lunar', 'Social', 'Ritual', 'Personal'))
    );

-- STEP 6: Verify
SELECT
    source,
    event_type,
    panchangam_type_id,
    COUNT(*) as row_count
FROM public.event_master
GROUP BY source, event_type, panchangam_type_id
ORDER BY source, event_type;
