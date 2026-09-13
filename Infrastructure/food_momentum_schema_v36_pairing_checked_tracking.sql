-- Schema v36 — track "genuinely has no sides" separately from "not yet checked"
--
-- Real inefficiency found while running seed_recipe_pairings_groq.py:
-- a dish that genuinely and correctly has no traditional side dishes
-- (e.g. Kothu Parotta -- street food, not paired with sides in Tamil
-- Brahmin home cuisine) never gets an ai_seeded pairing row, since
-- there's nothing to insert. That means the script's "already done"
-- check -- which only recognizes a dish as processed once it has a
-- pairing row -- can never mark it done, so it gets re-asked (wasting
-- an API call) in every single subsequent batch, forever.
--
-- This column lets the script record "AI confirmed this dish has no
-- sides" directly on the dish itself, independent of recipe_pairing
-- (which requires a real, non-null side_recipe_id and can't hold a
-- sentinel/empty-result row).

ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS pairing_ai_checked_at TIMESTAMP DEFAULT NULL;

COMMENT ON COLUMN recipe_dna_master.pairing_ai_checked_at IS
    'Set when seed_recipe_pairings_groq.py asks the AI for this dish''s
     side pairings and it genuinely confirms none exist (e.g. a dish
     traditionally eaten plain). Distinct from having zero ai_seeded
     rows in recipe_pairing, which just means "not yet checked at all".
     Lets the already_done logic correctly skip re-asking about a dish
     that has already been checked and confirmed to have no sides.';
