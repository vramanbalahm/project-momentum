-- Schema v30 — household-private recipes (quick entry)
--
-- CORRECTED: recipe_dna_master already has a created_by_house_id UUID
-- column from early schema design (present since the March 2026 dumps),
-- but it was never wired into any application code or later migration.
-- Reusing it for this feature instead of adding a new, confusingly
-- redundant column with a different name for the same purpose.
--
-- Semantics being applied to this existing column:
-- NULL     = shared, admin-curated vault (all existing behavior,
--            unchanged -- every current recipe has this).
-- Non-null = private to that household. Auto-approved, visible only
--            to them, never enters the shared reviewer queue.
--
-- Precedent: recipe_pairing.house_id already uses this exact
-- NULL = global / non-null = household-specific pattern in production
-- (see recommendation_service.py recommend_sides()).

-- Add the FK constraint if it isn't already there (defensive -- the
-- column predates this migration and its constraint history is unknown).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'recipe_dna_master_created_by_house_id_fkey'
    ) THEN
        ALTER TABLE recipe_dna_master
            ADD CONSTRAINT recipe_dna_master_created_by_house_id_fkey
            FOREIGN KEY (created_by_house_id) REFERENCES household_master(household_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_recipe_dna_master_created_by_house_id
    ON recipe_dna_master(created_by_house_id) WHERE created_by_house_id IS NOT NULL;

COMMENT ON COLUMN recipe_dna_master.created_by_house_id IS
    'NULL = shared vault recipe (admin-curated, goes through the review
     pipeline). Non-null = household-private quick-entry dish:
     auto-approved, visible only to that household, never enters the
     shared reviewer queue. (Column predates this comment -- repurposed
     here for the quick-entry feature; previously unused by any code.)';
