-- Schema v33 — unique constraint on cuisine_regions natural key
--
-- cuisine_regions had no unique constraint beyond the SERIAL id, which
-- is exactly what allowed the whole table to get silently duplicated at
-- some point (the seed file was run twice, with no guard against it --
-- confirmed via a live production duplicate-row incident, cleaned up
-- manually before this migration). Adding a real natural-key uniqueness
-- constraint so that can't happen again, and so migrate_to_supabase.py
-- can safely upsert this table by content (state, region, sub_region)
-- instead of by id, which isn't guaranteed to line up between
-- environments.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_cuisine_regions_natural_key'
    ) THEN
        ALTER TABLE cuisine_regions
            ADD CONSTRAINT uq_cuisine_regions_natural_key
            UNIQUE (state, region, sub_region);
    END IF;
END $$;
