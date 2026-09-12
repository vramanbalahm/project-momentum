-- Schema v34 — safe re-runnable government holiday template rows
--
-- event_master's original UNIQUE constraint on event_code was deliberately
-- dropped in v19 -- every household that opts in gets its own copy of the
-- same event_code, so a blanket uniqueness rule would have blocked that
-- entirely by design.
--
-- This migration does NOT reverse that. It adds a much narrower,
-- *partial* unique constraint that only applies to the master/template
-- rows themselves (house_id IS NULL, sourced from an official government
-- holiday notification) -- scoped to (event_code, event_year). This lets
-- the annual holiday-population script re-run safely (upsert, not
-- duplicate) without affecting per-household rows in any way, since
-- those all have house_id set and fall outside this index entirely.

CREATE UNIQUE INDEX IF NOT EXISTS idx_event_master_template_unique
    ON event_master(event_code, event_year)
    WHERE house_id IS NULL;

COMMENT ON INDEX idx_event_master_template_unique IS
    'Scoped uniqueness for government-sourced holiday template rows only
     (house_id IS NULL) -- lets the annual population script safely
     upsert by (event_code, event_year) without touching per-household
     copies, which intentionally have no such constraint.';
