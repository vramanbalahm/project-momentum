-- Schema v31 — missing partial unique index on recipe_pairing
--
-- recipe_pairing has a plain UNIQUE (main_recipe_id, side_recipe_id, house_id)
-- constraint, but Postgres treats NULL <> NULL in uniqueness checks -- so
-- that constraint never actually prevented duplicate GLOBAL pairings
-- (house_id IS NULL), since every NULL is distinct from every other NULL.
--
-- migrate_to_supabase.py's upsert logic for this table has always assumed
-- a partial unique index existed for exactly this case
-- ("ON CONFLICT (main_recipe_id, side_recipe_id) WHERE house_id IS NULL"),
-- but it was never actually created in any prior migration. Adding it now.

CREATE UNIQUE INDEX IF NOT EXISTS idx_recipe_pairing_global_unique
    ON recipe_pairing(main_recipe_id, side_recipe_id)
    WHERE house_id IS NULL;

COMMENT ON INDEX idx_recipe_pairing_global_unique IS
    'Enforces uniqueness of (main_recipe_id, side_recipe_id) among global/
     seeded pairings (house_id IS NULL) specifically -- the plain 3-column
     UNIQUE constraint on this table cannot do this since NULL <> NULL.
     Required for migrate_to_supabase.py''s ON CONFLICT upsert logic.';
