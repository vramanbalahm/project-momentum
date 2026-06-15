-- ============================================================
-- Schema v25 — Recipe Pairing Table
-- Date: 2026-06-15
-- Purpose: Store main→side dish pairing relationships
--          Used by F16 for side dish recommendation
--          Seeded with pre-generated pairings (cold start)
--          Enhanced by behavioral_tracker over time
-- ============================================================

-- STEP 1: Create recipe_pairing table
CREATE TABLE IF NOT EXISTS public.recipe_pairing (
    id              SERIAL          PRIMARY KEY,
    main_recipe_id  UUID            NOT NULL REFERENCES public.recipe_dna_master(recipe_id) ON DELETE CASCADE,
    side_recipe_id  UUID            NOT NULL REFERENCES public.recipe_dna_master(recipe_id) ON DELETE CASCADE,
    confidence      NUMERIC(4,2)    NOT NULL DEFAULT 0.80
                    CHECK (confidence >= 0.0 AND confidence <= 1.0),
    source          VARCHAR(20)     NOT NULL DEFAULT 'seeded'
                    CHECK (source IN ('seeded','user_accepted','user_rejected','ml_generated')),
    house_id        UUID            REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    -- NULL house_id = global seed (applies to all households)
    -- UUID house_id = household-specific learning
    created_at      TIMESTAMP       DEFAULT NOW(),
    updated_at      TIMESTAMP       DEFAULT NOW(),
    UNIQUE (main_recipe_id, side_recipe_id, house_id)
);

COMMENT ON TABLE public.recipe_pairing IS
    'Main→Side dish pairing relationships.
     source=seeded: pre-generated pairings (cold start, house_id=NULL)
     source=user_accepted: user kept the suggested side
     source=user_rejected: user swapped away from suggested side
     source=ml_generated: ML model generated pairing (Bucket B)
     F16 queries this table ordered by confidence DESC.
     Household-specific rows override global seeds.';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_recipe_pairing_main
    ON public.recipe_pairing(main_recipe_id, confidence DESC);

CREATE INDEX IF NOT EXISTS idx_recipe_pairing_house
    ON public.recipe_pairing(house_id, main_recipe_id);

CREATE INDEX IF NOT EXISTS idx_recipe_pairing_source
    ON public.recipe_pairing(source);

-- STEP 2: Verify
SELECT 'recipe_pairing table created' as status;
