-- ============================================================
-- Schema v5 — Enable fuzzy search on recipe_dna_master
-- Date: 16-Apr-2026
-- FT-041: Trigram similarity search for dish name lookup
-- ============================================================

-- Enable pg_trgm extension (requires superuser — run once)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Trigram index on dish_name for fast similarity search
CREATE INDEX IF NOT EXISTS idx_recipe_dna_dish_name_trgm
    ON public.recipe_dna_master
    USING GIN (dish_name gin_trgm_ops);

COMMENT ON INDEX idx_recipe_dna_dish_name_trgm IS
    'Trigram index for fuzzy/phonetic dish name search. Supports partial and misspelled queries.';
