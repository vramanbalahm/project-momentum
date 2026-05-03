-- ============================================================
-- Momentum Schema v15b — Image Generation Tracking
-- Purpose: Track how many times an image has been generated
--          per recipe — enforces 2-attempt limit for QA
-- Date: May 2026
-- Run on: food_momentum_db
-- ============================================================

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_generation_count integer DEFAULT 0;

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_last_generated_at timestamp without time zone;

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS image_generated_by uuid;

COMMENT ON COLUMN public.recipe_content_vault.image_generation_count IS
    'Number of times image was generated. Max 2 for QA role. Platform admin can override.';

-- Verify
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'recipe_content_vault'
ORDER BY ordinal_position;
