-- ============================================================
-- Schema v27 — Pairing Feedback Tracking
-- Date: 2026-06-28
-- Purpose: Track acceptance/rejection signals on recipe_pairing
--          to improve confidence over time across households
-- ============================================================

ALTER TABLE recipe_pairing
ADD COLUMN IF NOT EXISTS validated        BOOLEAN DEFAULT NULL,
ADD COLUMN IF NOT EXISTS acceptance_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS rejection_count  INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_accepted_at TIMESTAMP;

-- Index for querying most accepted pairings
CREATE INDEX IF NOT EXISTS idx_recipe_pairing_acceptance
ON recipe_pairing (acceptance_count DESC)
WHERE house_id IS NULL;

COMMENT ON COLUMN recipe_pairing.acceptance_count IS 
'How many times this pairing was kept/accepted across all households';
COMMENT ON COLUMN recipe_pairing.rejection_count IS 
'How many times this pairing was swapped out across all households';
COMMENT ON COLUMN recipe_pairing.last_accepted_at IS 
'Last time any household accepted this pairing';
COMMENT ON COLUMN recipe_pairing.validated IS 
'TRUE=AI/human confirmed, FALSE=flagged for review, NULL=not yet validated';
