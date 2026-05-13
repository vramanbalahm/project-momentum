-- ============================================================
-- Schema v17 — Add 'saved' to review_status CHECK constraint
-- Purpose: Allow reviewers to save work-in-progress recipes
--          and return to them later via a dedicated Saved tab.
-- Date: 13 May 2026
-- ============================================================

-- STEP 1: Drop the existing CHECK constraint on review_status
ALTER TABLE public.recipe_dna_master
    DROP CONSTRAINT IF EXISTS recipe_dna_master_review_status_check;

-- STEP 2: Re-add the constraint with 'saved' included
ALTER TABLE public.recipe_dna_master
    ADD CONSTRAINT recipe_dna_master_review_status_check
    CHECK (review_status IN ('under_review', 'approved', 'rejected', 'saved'));

-- STEP 3: Verify
SELECT
    review_status,
    COUNT(*) AS count
FROM public.recipe_dna_master
GROUP BY review_status
ORDER BY review_status;
