-- Schema v37 — AI-verified duplicate group suggestions
--
-- Real problem: with ~200 side dishes sitting under review after three
-- batch runs (Breakfast/Lunch/Dinner), manually searching for
-- duplicates one pair at a time doesn't scale. Pure text similarity
-- (trigram) can't reliably tell "same dish, different spelling" apart
-- from "different dish, similar wording" -- confirmed by testing
-- earlier: it either misses real duplicates (Avial/Aviyal score almost
-- 0 similarity) or wrongly merges genuinely different dishes (two
-- different-legume Kadala curries scored HIGHER than some real
-- duplicates).
--
-- Fix: cast a loose net with trigram similarity to find CANDIDATE
-- clusters (accepting false positives at this stage), then have the AI
-- itself judge each candidate cluster using real food knowledge --
-- validated against a deliberately hard test set (Avial/Aviyal spelling
-- variant, look-alike-but-different dishes like coconut chutney vs
-- coconut pachadi) before building this. Only AI-CONFIRMED groups get
-- stored here, for a human to make the final call on -- this is a
-- suggestion queue, not an auto-merge.

CREATE TABLE IF NOT EXISTS ai_duplicate_suggestions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_ids      UUID[] NOT NULL,       -- the recipe_ids the AI believes are the same dish
    canonical_name  TEXT NOT NULL,         -- AI's suggested name for the merged result
    reasoning       TEXT,                  -- AI's one-line explanation
    status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'merged', 'dismissed')),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMP
);

COMMENT ON TABLE ai_duplicate_suggestions IS
    'AI-verified candidate duplicate groups for admin review -- never
     auto-merges anything. status=pending shown for review; merged/
     dismissed once the admin has acted on it, so re-scans dont
     re-surface the same suggestion repeatedly.';
