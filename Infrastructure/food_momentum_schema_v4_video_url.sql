-- ============================================================
-- Schema v4 — Add video_url to recipe_content_vault
-- Date: 15-Apr-2026
-- FT-041: Dish detail panel — video reference support
-- ============================================================

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS video_url TEXT;

COMMENT ON COLUMN public.recipe_content_vault.video_url IS
    'YouTube or external video URL for dish preparation reference. Used in dish detail panel.';
