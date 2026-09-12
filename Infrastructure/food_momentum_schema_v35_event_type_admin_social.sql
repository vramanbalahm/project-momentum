-- Schema v35 — allow ADMIN-sourced Social events (government holidays)
--
-- v19 added a CHECK constraint enforcing "ADMIN = Lunar only" -- at the
-- time, the only ADMIN-sourced event_master rows were Panchangam-derived
-- lunar observances, so this was a reasonable rule.
--
-- New legitimate case: government-published public holidays (Republic
-- Day, Independence Day, Christmas, etc. -- see seed_tn_holidays.py)
-- are genuinely ADMIN/system-sourced reference data, not something a
-- household typed in themselves, but they're civil holidays, not
-- Panchangam-derived lunar observances -- event_type = 'Social' is the
-- correct classification for them.
--
-- Confirmed before this change: no existing query assumes ADMIN rows
-- are exclusively Lunar. The only queries filtering on
-- (source='ADMIN' AND event_type='Lunar') are the existing Panchangam-
-- type-specific observance-copying logic in onboarding.py, which is
-- unaffected -- it explicitly filters to event_type='Lunar' already,
-- so it will keep ignoring the new Social rows exactly as it does any
-- other non-Lunar row today.

ALTER TABLE event_master
    DROP CONSTRAINT IF EXISTS event_master_event_type_check;

ALTER TABLE event_master
    ADD CONSTRAINT event_master_event_type_check CHECK (
        (source = 'ADMIN' AND event_type IN ('Lunar', 'Social'))
        OR
        (source = 'USER' AND event_type IN ('Lunar', 'Social', 'Ritual', 'Personal'))
    );
