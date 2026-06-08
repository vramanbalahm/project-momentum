-- ============================================================
-- Schema v24 — Dish Category + Pairing Matrix
-- Date: 2026-06-08
-- Purpose: Enable F16 side dish recommendation via pairing matrix
-- Changes:
--   1. Add dish_category to recipe_dna_master
--   2. Create dish_pairing_matrix table
--   3. Seed pairing matrix with compatibility rules
--   4. Auto-tag dish_category based on keywords
-- ============================================================

-- STEP 1: Add dish_category column
ALTER TABLE public.recipe_dna_master
    ADD COLUMN IF NOT EXISTS dish_category VARCHAR(20) DEFAULT NULL;

COMMENT ON COLUMN public.recipe_dna_master.dish_category IS
    'Category used for side dish pairing recommendations.
     Main dish categories: tiffin | rice | bread | millet | other
     Side dish categories: wet | semi_dry | dry | condiment | sweet
     Used with dish_pairing_matrix to recommend compatible sides.';

-- STEP 2: Create pairing matrix
CREATE TABLE IF NOT EXISTS public.dish_pairing_matrix (
    id              SERIAL          PRIMARY KEY,
    main_category   VARCHAR(20)     NOT NULL,
    side_category   VARCHAR(20)     NOT NULL,
    compatibility   VARCHAR(15)     NOT NULL
                    CHECK (compatibility IN ('perfect', 'good', 'acceptable', 'never')),
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT NOW(),
    UNIQUE (main_category, side_category)
);

COMMENT ON TABLE public.dish_pairing_matrix IS
    'Compatibility matrix for main+side dish pairing.
     Used by F16 recommendation engine to suggest appropriate sides.
     Main categories: tiffin | rice | bread | millet | other
     Side categories: wet | semi_dry | dry | condiment | sweet
     Compatibility: perfect > good > acceptable > never';

-- STEP 3: Seed pairing matrix
INSERT INTO public.dish_pairing_matrix (main_category, side_category, compatibility, notes)
VALUES
    -- Tiffin (Idli, Dosa, Pongal, Upma, Appam)
    ('tiffin',  'wet',        'perfect',    'Sambar/Rasam with Idli/Dosa is classic'),
    ('tiffin',  'condiment',  'perfect',    'Chutney is essential with tiffin'),
    ('tiffin',  'semi_dry',   'never',      'Kootu/Aviyal not served with tiffin'),
    ('tiffin',  'dry',        'never',      'Poriyal not served with tiffin'),
    ('tiffin',  'sweet',      'acceptable', 'Occasional sweet alongside tiffin'),

    -- Rice (plain rice, curd rice, lemon rice, tamarind rice)
    ('rice',    'wet',        'perfect',    'Sambar/Rasam/Kuzhambu essential with rice'),
    ('rice',    'dry',        'perfect',    'Poriyal/Thoran alongside rice'),
    ('rice',    'semi_dry',   'perfect',    'Kootu/Aviyal works well with rice'),
    ('rice',    'condiment',  'good',       'Pickle/Papad as accompaniment'),
    ('rice',    'sweet',      'acceptable', 'Payasam as dessert after rice meal'),

    -- Bread (Chapati, Roti, Parotta, Naan)
    ('bread',   'wet',        'perfect',    'Curry/Dal/Gravy essential with bread'),
    ('bread',   'condiment',  'good',       'Raita/Chutney alongside bread'),
    ('bread',   'dry',        'acceptable', 'Dry sabzi can accompany bread'),
    ('bread',   'semi_dry',   'acceptable', 'Thick gravy works with bread'),
    ('bread',   'sweet',      'never',      'Sweet not typically served with bread meal'),

    -- Millet (Ragi koozh, Kambu roti, Thinai dishes)
    ('millet',  'wet',        'perfect',    'Kuzhambu/Curry with millet dishes'),
    ('millet',  'condiment',  'perfect',    'Chutney/Buttermilk essential with millet'),
    ('millet',  'dry',        'good',       'Dry sides work with millet'),
    ('millet',  'semi_dry',   'good',       'Semi-dry sides complement millet'),
    ('millet',  'sweet',      'never',      'Sweet not paired with millet meals'),

    -- Other (catch-all for unclassified mains)
    ('other',   'wet',        'good',       'Default pairing'),
    ('other',   'condiment',  'good',       'Default pairing'),
    ('other',   'dry',        'acceptable', 'Default pairing'),
    ('other',   'semi_dry',   'acceptable', 'Default pairing'),
    ('other',   'sweet',      'acceptable', 'Default pairing')

ON CONFLICT (main_category, side_category) DO UPDATE SET
    compatibility = EXCLUDED.compatibility,
    notes = EXCLUDED.notes;

-- STEP 4: Auto-tag main dish categories
-- Tiffin
UPDATE public.recipe_dna_master
SET dish_category = 'tiffin'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(idli|dosa|pongal|upma|rava|uttapam|adai|appam|idiyappam|puttu|kichadi|paniyaram|sevai|idiappam|pesarattu|akki roti|set dosa|uthappam)%';

-- Rice
UPDATE public.recipe_dna_master
SET dish_category = 'rice'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(rice|sadam|sadham|bath|biryani|pulao|pulav|fried rice|saatham|puliyodarai|lemon rice|curd rice|tomato rice|bisi bele)%';

-- Bread
UPDATE public.recipe_dna_master
SET dish_category = 'bread'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(chapati|roti|parotta|paratha|naan|kulcha|puri|poori|bhatura|porotta)%';

-- Millet
UPDATE public.recipe_dna_master
SET dish_category = 'millet'
WHERE meal_role @> ARRAY['main']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(ragi|kambu|thinai|varagu|millet|koozh|kali|sorghum|bajra|jowar|foxtail)%';

-- Other — catch-all for remaining mains
UPDATE public.recipe_dna_master
SET dish_category = 'other'
WHERE meal_role @> ARRAY['main']::text[]
AND dish_category IS NULL;

-- STEP 5: Auto-tag side dish categories
-- Wet — pourable gravy/liquid sides
UPDATE public.recipe_dna_master
SET dish_category = 'wet'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(sambar|rasam|kuzhambu|kozhambu|kulambu|dal|dhal|curry|gravy|salna|soup|kadhi|mor kuzhambu|sodhi|stew|shorba)%';

-- Semi-dry — thick, spoonable
UPDATE public.recipe_dna_master
SET dish_category = 'semi_dry'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(kootu|aviyal|olan|erissery|mixed veg|korma|kurma|masala|sabzi|bhaji|palya)%'
AND dish_category IS NULL;

-- Condiment — chutney, pickle, papad
UPDATE public.recipe_dna_master
SET dish_category = 'condiment'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(chutney|thogayal|pickle|achar|papad|appalam|vadam|raita|pachadi|thuvaiyal|podimas|podi|salsa)%'
AND dish_category IS NULL;

-- Sweet — desserts
UPDATE public.recipe_dna_master
SET dish_category = 'sweet'
WHERE meal_role @> ARRAY['side']::text[]
AND LOWER(dish_name) SIMILAR TO
    '%(payasam|kheer|halwa|ladoo|barfi|sweet|poli|pongal sweet|sakkarai|dessert|pudding|kesari|jigarthanda)%'
AND dish_category IS NULL;

-- Dry — poriyal, thoran, stir fry
UPDATE public.recipe_dna_master
SET dish_category = 'dry'
WHERE meal_role @> ARRAY['side']::text[]
AND dish_category IS NULL;  -- catch-all for remaining sides

-- STEP 6: Verify
SELECT
    meal_role,
    dish_category,
    COUNT(*) as count
FROM recipe_dna_master
WHERE review_status = 'approved'
GROUP BY meal_role, dish_category
ORDER BY meal_role, count DESC;
