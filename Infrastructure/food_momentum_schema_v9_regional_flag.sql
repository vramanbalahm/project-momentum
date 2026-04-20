-- ============================================================
-- Schema v9 — recipe_dna_master: add is_regional_specific flag
-- Run after: food_momentum_schema_v8_profile_audit.sql
-- ============================================================

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS is_regional_specific BOOLEAN DEFAULT false;

COMMENT ON COLUMN recipe_dna_master.is_regional_specific IS
    'true = dish is distinctly associated with a specific sub-region.
     false = dish is a staple eaten widely across the state regardless of sub-region.
     Set by Gemini during recipe seeding — not manually maintained.';
