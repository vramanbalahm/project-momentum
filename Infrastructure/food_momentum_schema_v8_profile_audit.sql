-- ============================================================
-- Schema v8 — profile_audit_log
-- Run after: food_momentum_schema_v7_lookup_tables.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS profile_audit_log (
    id              SERIAL PRIMARY KEY,
    house_id        UUID NOT NULL REFERENCES household_master(household_id),
    changed_by      UUID NOT NULL REFERENCES users(user_id),
    field_name      VARCHAR(100) NOT NULL,
    old_value       TEXT,
    new_value       TEXT,
    changed_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profile_audit_house ON profile_audit_log(house_id);
CREATE INDEX IF NOT EXISTS idx_profile_audit_changed_at ON profile_audit_log(changed_at);

-- Add new columns to household_master for profile update support
ALTER TABLE household_master
    ADD COLUMN IF NOT EXISTS cuisine_sub_region_id INTEGER REFERENCES cuisine_regions(id),
    ADD COLUMN IF NOT EXISTS household_allergies TEXT;
