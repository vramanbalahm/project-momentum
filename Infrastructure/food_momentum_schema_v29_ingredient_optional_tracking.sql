-- Schema v29 — is_optional classification tracking
--
-- Tracks whether a recipe's ingredients have already been run through the
-- AI is_optional classification pass (classify_is_optional.py), so re-runs
-- (e.g. after adding new recipes) don't reprocess -- and re-bill -- recipes
-- that are already done.
--
-- Not inferred from recipe_ingredients.is_optional values themselves,
-- since a genuinely all-mandatory recipe would be indistinguishable from
-- an unprocessed one (both default to false).

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS is_optional_classified_at TIMESTAMP DEFAULT NULL;

COMMENT ON COLUMN recipe_dna_master.is_optional_classified_at IS
    'Timestamp of the last successful AI is_optional classification pass
     (classify_is_optional.py --apply) for this recipe. NULL = not yet
     classified. Used to skip already-processed recipes on re-runs.';
