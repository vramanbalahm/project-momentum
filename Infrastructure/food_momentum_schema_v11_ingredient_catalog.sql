-- ============================================================
-- Schema v11 — ingredient_catalog + recipe_ingredients
-- Run after: food_momentum_schema_v10_recipe_fields.sql
-- ============================================================
-- Design decisions:
--   ingredient_catalog  — master list of all ingredients known to the system
--                         source of truth for recipe, pantry, and future market linkage
--   recipe_ingredients  — links recipe_dna_master → ingredient_catalog
--                         with quantity and unit per ingredient
--
-- Existing tables NOT touched:
--   ingredient_master       — market/price metadata (shelf life, price thresholds)
--   ingredient_translations — multi-language names for market ingredients
--   staple_master_registry  — market staples for price tracking
-- ============================================================

-- ── 1. ingredient_catalog ─────────────────────────────────────────────────────
-- Master list of all ingredients — populated by Gemini during recipe seeding.
-- One row per unique ingredient in English.
-- Tamil and other language names stored in ingredient_catalog_translations.

CREATE TABLE IF NOT EXISTS ingredient_catalog (
    id              SERIAL PRIMARY KEY,
    name_en         VARCHAR(200) NOT NULL UNIQUE,   -- English name — deduplication key
    name_ta         VARCHAR(200),                   -- Tamil name if known
    category        VARCHAR(50),                    -- Vegetable, Lentil, Spice, Oil, Dairy, Grain, Meat, Seafood, Fruit, Nut, Other
    is_sattvic      BOOLEAN DEFAULT true,
    is_vegan        BOOLEAN DEFAULT true,
    shelf_life_days INTEGER,                        -- optional — can link to ingredient_master later
    ingredient_master_id INTEGER REFERENCES ingredient_master(id), -- optional FK to market price table
    created_at      TIMESTAMP DEFAULT NOW(),
    created_by_ai   BOOLEAN DEFAULT true            -- true = added by Gemini seeding
);

CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_name_en ON ingredient_catalog(LOWER(name_en));
CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_category ON ingredient_catalog(category);

-- Enable trigram similarity search for fuzzy ingredient matching
-- (pg_trgm already installed via schema v5)
CREATE INDEX IF NOT EXISTS idx_ingredient_catalog_trgm ON ingredient_catalog
    USING GIN (name_en gin_trgm_ops);

COMMENT ON TABLE ingredient_catalog IS
    'Master ingredient list — single source of truth for all ingredients in recipes.
     Populated by Gemini during seeding. Optional FK to ingredient_master for market price linkage.';

COMMENT ON COLUMN ingredient_catalog.ingredient_master_id IS
    'Optional link to ingredient_master (market/price table) when this ingredient is also a tracked market staple.';


-- ── 2. recipe_ingredients ─────────────────────────────────────────────────────
-- Links recipe_dna_master → ingredient_catalog.
-- One row per ingredient per recipe.
-- Replaces the ingredients_json blob in recipe_content_vault for structured queries.
-- ingredients_json is KEPT in recipe_content_vault as a fallback/display blob.

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id                  SERIAL PRIMARY KEY,
    recipe_id           UUID NOT NULL REFERENCES recipe_dna_master(recipe_id) ON DELETE CASCADE,
    ingredient_id       INTEGER NOT NULL REFERENCES ingredient_catalog(id) ON DELETE RESTRICT,
    quantity            VARCHAR(50),        -- e.g. "2", "1/2", "a pinch", "to taste"
    unit                VARCHAR(50),        -- e.g. "cups", "tbsp", "grams", "" for countable
    is_optional         BOOLEAN DEFAULT false,
    sort_order          INTEGER DEFAULT 0,  -- display order within recipe
    created_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe_id     ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

COMMENT ON TABLE recipe_ingredients IS
    'Normalised recipe-ingredient link table. One row per ingredient per recipe.
     Enables pantry check, ingredient search, and market price linkage.
     ingredients_json in recipe_content_vault is kept as display blob.';

COMMENT ON COLUMN recipe_ingredients.quantity IS
    'Raw quantity string from Gemini — e.g. "2", "1/2", "lemon-sized ball", "to taste".';

COMMENT ON COLUMN recipe_ingredients.is_optional IS
    'true = ingredient is optional or garnish. false = required for the dish.';
