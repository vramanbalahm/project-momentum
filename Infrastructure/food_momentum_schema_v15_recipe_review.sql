-- ============================================================
-- Momentum Schema v15 — Recipe Review Workflow
-- Purpose: Add review_status to recipe_dna_master,
--          youtube_urls to recipe_content_vault
-- Date: May 2026
--
-- Run on food_momentum_db
-- ============================================================

-- ── 1. Add review_status to recipe_dna_master ─────────────────────────────

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS review_status varchar(20) DEFAULT 'under_review'
        CHECK (review_status IN ('under_review', 'approved', 'rejected'));

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS reviewed_by uuid;

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS reviewed_at timestamp without time zone;

ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS review_notes text;

-- All existing AI-seeded recipes start as under_review
UPDATE public.recipe_dna_master
SET review_status = 'under_review'
WHERE review_status IS NULL;

-- Index for fast filtering by status
CREATE INDEX IF NOT EXISTS idx_recipe_review_status
    ON public.recipe_dna_master(review_status);

-- ── 2. Add youtube_urls to recipe_content_vault ───────────────────────────
-- Replaces single video_url with array of up to 3 URLs

ALTER TABLE public.recipe_content_vault
    ADD COLUMN IF NOT EXISTS youtube_urls text[] DEFAULT '{}';

-- Migrate existing video_url into youtube_urls array if present
UPDATE public.recipe_content_vault
SET youtube_urls = ARRAY[video_url]
WHERE video_url IS NOT NULL
  AND video_url != ''
  AND (youtube_urls IS NULL OR youtube_urls = '{}');

-- ── 3. Verify ─────────────────────────────────────────────────────────────

SELECT 'REVIEW STATUS DISTRIBUTION' as check_name,
       review_status, COUNT(*) as count
FROM recipe_dna_master
GROUP BY review_status;

SELECT 'RECIPE_CONTENT_VAULT COLUMNS' as check_name,
       column_name, data_type
FROM information_schema.columns
WHERE table_name = 'recipe_content_vault'
ORDER BY ordinal_position;
