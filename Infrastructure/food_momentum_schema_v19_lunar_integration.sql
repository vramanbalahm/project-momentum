-- ============================================================
-- Schema v19 — Lunar Calendar Integration
-- Date: 2026-05-30
-- Changes:
--   1. Add panchangam_type_id (nullable) to event_master
--      - ADMIN rows: set to matching panchangam type
--      - USER rows: NULL (personal events like birthdays)
--   2. Drop UNIQUE constraint on event_code
--      - Multiple rows exist for same event (Pradosham repeats monthly)
--      - event_id (UUID) is the true primary key
-- ============================================================

-- STEP 1: Add panchangam_type_id to event_master
ALTER TABLE public.event_master
    ADD COLUMN IF NOT EXISTS panchangam_type_id INTEGER REFERENCES public.panchangam_types(id);

COMMENT ON COLUMN public.event_master.panchangam_type_id IS
    'Which Panchangam this event belongs to. Set for ADMIN-seeded lunar events.
     NULL for USER-added personal events (birthdays, anniversaries etc.).
     Used to copy correct set of lunar events when household selects their Panchangam.';

-- STEP 2: Drop UNIQUE constraint on event_code
-- Multiple rows exist for same event_name (Pradosham repeats ~2x/month)
-- event_id (UUID) is the true primary key
ALTER TABLE public.event_master
    DROP CONSTRAINT IF EXISTS event_master_event_code_key;

-- STEP 3: Update existing ADMIN lunar rows to set panchangam_type_id
-- Tamil Nadu events (region_code = 'TN') map to Tamil Vakya by default
-- (Tamil Vakya is the most commonly followed in Tamil Nadu)
UPDATE public.event_master
SET panchangam_type_id = (
    SELECT id FROM public.panchangam_types
    WHERE code = 'TAMIL_VAKYA'
    LIMIT 1
)
WHERE source = 'ADMIN'
AND region_code = 'TN'
AND event_type = 'Lunar'
AND panchangam_type_id IS NULL;

-- STEP 4: Add index for efficient household lookup
CREATE INDEX IF NOT EXISTS idx_event_master_house_date
    ON public.event_master(house_id, event_date)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_event_master_panchangam
    ON public.event_master(panchangam_type_id, event_year)
    WHERE source = 'ADMIN';

CREATE INDEX IF NOT EXISTS idx_event_master_house_satvik
    ON public.event_master(house_id, event_date, is_sattvic_required)
    WHERE is_active = true AND is_sattvic_required = true;

-- STEP 5: Verify
SELECT
    source,
    panchangam_type_id,
    COUNT(*) as row_count
FROM public.event_master
WHERE event_type = 'Lunar'
GROUP BY source, panchangam_type_id
ORDER BY source, panchangam_type_id;
