-- ============================================================
-- Schema v10 — Store all Gemini-generated recipe fields
-- Run after: food_momentum_schema_v9_regional_flag.sql
-- ============================================================

-- Add missing columns to recipe_dna_master
ALTER TABLE recipe_dna_master
    ADD COLUMN IF NOT EXISTS regional_name      VARCHAR(255),   -- name in local language (Tamil, Telugu etc.)
    ADD COLUMN IF NOT EXISTS sub_region         VARCHAR(150),   -- e.g. Chettinad, Tirunelveli, Kongu Nadu
    ADD COLUMN IF NOT EXISTS meal_slots         TEXT[],         -- e.g. {Breakfast,Lunch} — PostgreSQL array
    ADD COLUMN IF NOT EXISTS prep_time_mins     INTEGER,        -- preparation time in minutes
    ADD COLUMN IF NOT EXISTS cook_time_mins     INTEGER,        -- cooking time in minutes
    ADD COLUMN IF NOT EXISTS serves             INTEGER,        -- number of servings
    ADD COLUMN IF NOT EXISTS tags               TEXT[],         -- e.g. {fermented, street food, spicy}
    ADD COLUMN IF NOT EXISTS source_region      VARCHAR(100),   -- state/region this recipe belongs to e.g. Tamil Nadu
    ADD COLUMN IF NOT EXISTS created_by_ai      BOOLEAN DEFAULT true,  -- true = seeded by Gemini
    ADD COLUMN IF NOT EXISTS ai_model           VARCHAR(100);   -- which model generated this e.g. gemini-2.5-flash-lite

COMMENT ON COLUMN recipe_dna_master.regional_name IS 'Dish name in local language — Tamil, Telugu, Kannada etc.';
COMMENT ON COLUMN recipe_dna_master.sub_region IS 'Specific sub-region this dish is associated with e.g. Chettinad, Tirunelveli';
COMMENT ON COLUMN recipe_dna_master.meal_slots IS 'Which meal slots this dish is suitable for — PostgreSQL text array';
COMMENT ON COLUMN recipe_dna_master.tags IS 'Descriptive tags for filtering and discovery e.g. fermented, street food, spicy';
COMMENT ON COLUMN recipe_dna_master.source_region IS 'State or region this recipe belongs to e.g. Tamil Nadu, Kerala';
COMMENT ON COLUMN recipe_dna_master.created_by_ai IS 'true = seeded by Gemini AI, false = manually added';
COMMENT ON COLUMN recipe_dna_master.ai_model IS 'Gemini model version used to generate this recipe';

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_recipe_sub_region  ON recipe_dna_master(sub_region);
CREATE INDEX IF NOT EXISTS idx_recipe_source_region ON recipe_dna_master(source_region);
CREATE INDEX IF NOT EXISTS idx_recipe_meal_slots  ON recipe_dna_master USING GIN(meal_slots);
CREATE INDEX IF NOT EXISTS idx_recipe_tags        ON recipe_dna_master USING GIN(tags);
