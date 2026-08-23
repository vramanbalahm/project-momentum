-- Schema v30 — household-private recipes (quick entry)
--
-- Adds house_id to recipe_dna_master so a household can create their own
-- "quick dish" -- a minimal recipe entry they can use in their own plan
-- immediately, with no review/approval step, visible only to them.
--
-- NULL house_id  = shared, admin-curated vault (all existing behavior,
--                  unchanged -- every recipe today implicitly has this).
-- Non-null house_id = private to that household. Never shown to other
--                  households, never enters the shared reviewer queue.
--
-- Precedent: recipe_pairing.house_id already uses this exact
-- NULL = global / non-null = household-specific pattern in production
-- (see recommendation_service.py recommend_sides()).

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS house_id UUID DEFAULT NULL
        REFERENCES household_master(household_id);

CREATE INDEX IF NOT EXISTS idx_recipe_dna_master_house_id
    ON recipe_dna_master(house_id) WHERE house_id IS NOT NULL;

COMMENT ON COLUMN recipe_dna_master.house_id IS
    'NULL = shared vault recipe (admin-curated, goes through review pipeline).
     Non-null = household-private quick-entry dish: auto-approved, visible
     only to that household, never enters the shared reviewer queue.';
