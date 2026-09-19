-- ============================================================
-- Schema v38 — Track recommendation filter failures explicitly
-- Date: 2026-09-19
--
-- Real gap found: generate_plan()'s pipeline wraps every filter call
-- in a try/except that only prints to console on failure -- nothing
-- gets written to plan_audit_log for that step at all, since each
-- filter function's own _log() call sits at the END of its normal
-- execution path. A crash in, say, filter_by_allergies means: the
-- plan still generates (using whatever candidates existed before the
-- crash, i.e. as if that filter never ran), the only trace is a
-- console print visible solely in Cloud Run's own logging console,
-- and plan_audit_log -- the table platform admin actually queries to
-- troubleshoot -- shows NO row for that step, which reads as "wasn't
-- relevant" rather than "silently failed to run".
--
-- Given plan_audit_log's own stated purpose ("Platform admin uses
-- this to troubleshoot customer issues"), a dedicated, queryable
-- succeeded flag is worth it over relying on text-matching a reason
-- string. Defaults succeeded=TRUE so every existing row (all of which
-- represent a filter that ran normally) stays correct with no backfill
-- needed.
-- ============================================================

ALTER TABLE public.plan_audit_log
    ADD COLUMN IF NOT EXISTS succeeded BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS error_detail TEXT;

COMMENT ON COLUMN public.plan_audit_log.succeeded IS
    'FALSE means this filter function raised an exception and was
     skipped -- the plan generation continued anyway, using whatever
     candidates existed before the failure. Query
     WHERE succeeded = FALSE to find silently-skipped safety checks
     (allergies, diet, Satvik) across any household.';

COMMENT ON COLUMN public.plan_audit_log.error_detail IS
    'The exception message when succeeded = FALSE. NULL otherwise.';

-- Index for the actual troubleshooting query this exists to support
CREATE INDEX IF NOT EXISTS idx_plan_audit_log_failures
    ON public.plan_audit_log(succeeded)
    WHERE succeeded = FALSE;
