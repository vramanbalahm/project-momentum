-- ============================================================
-- Schema v20 — My Pantry (household ingredient availability)
-- Date: 2026-06-01
-- Purpose: Track which ingredients a household has available.
--          Used by Recommendation Engine (F09) to prefer recipes
--          that use available ingredients.
-- ============================================================

-- household_pantry — one row per ingredient per household
CREATE TABLE IF NOT EXISTS public.household_pantry (
    pantry_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    house_id        UUID NOT NULL REFERENCES public.household_master(household_id) ON DELETE CASCADE,
    ingredient_id   INTEGER NOT NULL REFERENCES public.ingredient_catalog(id) ON DELETE CASCADE,
    is_available    BOOLEAN NOT NULL DEFAULT true,
    updated_at      TIMESTAMP DEFAULT NOW(),
    UNIQUE (house_id, ingredient_id)
);

COMMENT ON TABLE public.household_pantry IS
    'Tracks ingredient availability per household.
     Populated by user from My Pantry screen.
     Used by recommendation engine (F09) to prefer recipes with available ingredients.
     is_available=true means ingredient is currently in stock.';

-- Indexes for fast lookup
CREATE INDEX IF NOT EXISTS idx_household_pantry_house
    ON public.household_pantry(house_id)
    WHERE is_available = true;

CREATE INDEX IF NOT EXISTS idx_household_pantry_ingredient
    ON public.household_pantry(ingredient_id);

-- Add emoji column to ingredient_catalog for My Pantry display
ALTER TABLE public.ingredient_catalog
    ADD COLUMN IF NOT EXISTS emoji VARCHAR(10) DEFAULT NULL;

COMMENT ON COLUMN public.ingredient_catalog.emoji IS
    'Emoji icon for display in My Pantry screen. MVP uses emoji instead of images.';

-- Seed default emojis per category
UPDATE public.ingredient_catalog SET emoji = '🥬' WHERE category = 'Vegetable' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥩' WHERE category = 'Meat' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🐟' WHERE category = 'Seafood' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥛' WHERE category = 'Dairy' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🌾' WHERE category = 'Grain' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🫘' WHERE category = 'Lentil' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🌶️' WHERE category = 'Spice' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🫙' WHERE category = 'Oil' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🍎' WHERE category = 'Fruit' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🥜' WHERE category = 'Nut' AND emoji IS NULL;
UPDATE public.ingredient_catalog SET emoji = '🧂' WHERE category = 'Other' AND emoji IS NULL;

-- Verify
SELECT category, emoji, COUNT(*) as ingredient_count
FROM public.ingredient_catalog
GROUP BY category, emoji
ORDER BY category;
