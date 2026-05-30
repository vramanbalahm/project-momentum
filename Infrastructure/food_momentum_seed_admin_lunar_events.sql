-- ============================================================
-- Seed: ADMIN Lunar Events for event_master
-- Date: 2026-05-30
-- Purpose: Seed platform-level ADMIN lunar events for Tamil Nadu
--          panchangam (Tamil Vakya = panchangam_types id 1)
-- Run: after schema v19 migration
-- ============================================================

-- First update existing ADMIN rows to set panchangam_type_id and fix event_type
UPDATE public.event_master
SET
    event_type = 'Lunar',
    panchangam_type_id = (SELECT id FROM panchangam_types WHERE code = 'TAMIL_VAKYA' LIMIT 1)
WHERE source = 'ADMIN'
AND house_id IS NULL
AND region_code = 'TN';

-- Remove any remaining non-Lunar ADMIN rows (Social, Ritual etc.)
-- These should not exist per our design decision
DELETE FROM public.event_master
WHERE source = 'ADMIN'
AND house_id IS NULL
AND event_type != 'Lunar';

-- Verify
SELECT
    event_type,
    panchangam_type_id,
    COUNT(*) as count
FROM public.event_master
WHERE source = 'ADMIN'
AND house_id IS NULL
GROUP BY event_type, panchangam_type_id;
