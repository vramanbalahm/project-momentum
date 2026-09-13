-- Schema v36 — track "genuinely has no sides" separately from "not yet checked"
--
-- Real inefficiency found while running seed_recipe_pairings_groq.py:
-- a dish that genuinely and correctly has no traditional side dishes
-- (e.g. Kothu Parotta -- confirmed by testing to have real pairings
-- once the prompt scope was fixed, but genuinely-side-less dishes like
-- Corn Flakes and Oats Porridge do exist) never gets an ai_seeded
-- pairing row, since there's nothing to insert. That means the
-- script's "already done" check -- which only recognizes a dish as
-- processed once it has a pairing row -- can never mark it done, so
-- it gets re-asked (wasting an API call) in every subsequent batch.
--
-- This flag lets the script record "AI confirmed this dish has no
-- sides" directly on the dish itself, independent of recipe_pairing
-- (which requires a real, non-null side_recipe_id and can't hold a
-- sentinel/empty-result row). Also useful beyond the script itself,
-- per Vijey: the recommendation engine can use this same signal to
-- know upfront a dish genuinely has no side, rather than treating an
-- empty pairing result ambiguously.
--
-- BOOLEAN, not a timestamp or Y/N -- matches the established
-- convention already used consistently across this schema for every
-- other flag column (is_active, onboarding_done, wizard_members_done,
-- is_regional_specific, created_by_ai, etc.), confirmed directly
-- against those column definitions before choosing this.

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS pairing_confirmed_no_sides BOOLEAN DEFAULT NULL;

COMMENT ON COLUMN recipe_dna_master.pairing_confirmed_no_sides IS
    'TRUE when seed_recipe_pairings_groq.py asks the AI for this dish''s
     side pairings and it genuinely confirms none exist (e.g. a dish
     traditionally eaten plain). NULL/FALSE = not yet checked, or
     checked and does have sides (see recipe_pairing for those). Lets
     the already_done logic correctly skip re-asking about a dish
     already confirmed to have no sides, and lets the recommendation
     engine know upfront a dish genuinely has none.';
