-- ============================================================
-- Momentum — Complete Seed Data for Railway DB
-- Run this after all schema scripts are applied
-- ============================================================

-- 1. HOUSEHOLD
INSERT INTO household_master (household_id, household_name, dietary_preference, native_region, current_city)
VALUES (
    '733b3f63-0fb4-4170-877c-eb2a70f29ccb',
    'Bala Family',
    'Veg',
    'Tamil Nadu',
    'Bengaluru'
) ON CONFLICT DO NOTHING;

-- 2. RECIPES — recipe_dna_master
INSERT INTO recipe_dna_master (recipe_id, dish_name, diet_type, is_sattvic, intensity_level, is_scalable, is_vegan)
VALUES
    ('f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Classic Paneer Butter Masala', 'Veg',   true,  'Medium', true, false),
    ('eebb7561-afec-41d8-bc3a-6e949a770acb', 'White Gravy Paneer',          'Veg',   true,  'Medium', true, false),
    ('1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Homestyle Dal Tadka',         'Veg',   true,  'Light',  true, true),
    ('7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Aloo Jeera',                  'Veg',   true,  'Light',  true, true),
    ('cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Chicken Curry',               'Non-Veg', false, 'Medium', true, false)
ON CONFLICT DO NOTHING;

-- 3. RECIPE CONTENT VAULT
INSERT INTO recipe_content_vault (recipe_id, hero_image_url, carousel_thumb_url, prep_steps, ingredients_json)
VALUES
    (
        'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35',
        'https://storage.googleapis.com/vault/hero_Classic Paneer Butter Masala.jpg',
        'https://storage.googleapis.com/vault/thumb_Classic Paneer Butter Masala.jpg',
        'Soak cashews in warm water for 20 mins, blend smooth
Saute onion, ginger-garlic paste until golden
Add tomato puree, cook until oil separates
Add spices and cashew paste, simmer 10 mins
Add paneer cubes and cream, cook 5 mins',
        '["Paneer", "Tomato", "Cashew", "Butter", "Cream", "Onion", "Ginger", "Garlic"]'
    ),
    (
        'eebb7561-afec-41d8-bc3a-6e949a770acb',
        'https://storage.googleapis.com/vault/hero_White Gravy Paneer.jpg',
        'https://storage.googleapis.com/vault/thumb_White Gravy Paneer.jpg',
        'Blend onion, cashew and yogurt into smooth paste
Saute whole spices in ghee
Add white paste and cook on low heat 15 mins
Add paneer, simmer 5 mins
Finish with cream and cardamom',
        '["Paneer", "Cashew", "Yogurt", "Cream", "Ghee", "Cardamom", "Onion"]'
    ),
    (
        '1d9ac977-ba52-470a-bbc4-6862beaa8de2',
        'https://storage.googleapis.com/vault/hero_Homestyle Dal Tadka.jpg',
        'https://storage.googleapis.com/vault/thumb_Homestyle Dal Tadka.jpg',
        'Pressure cook toor dal until soft
Prepare tadka with ghee, cumin, garlic, dried chilli
Add onion tomato masala to dal
Pour tadka over cooked dal
Garnish with coriander',
        '["Toor Dal", "Ghee", "Cumin", "Garlic", "Tomato", "Onion", "Coriander"]'
    ),
    (
        '7959862a-1f7f-402d-9f82-0a8e1ee56200',
        'https://storage.googleapis.com/vault/hero_Aloo Jeera.jpg',
        'https://storage.googleapis.com/vault/thumb_Aloo Jeera.jpg',
        'Boil potatoes until just cooked, cube them
Heat oil, add cumin seeds and let splutter
Add potatoes and toss well
Add spices and cook 5 mins
Garnish with coriander and lemon',
        '["Potato", "Cumin", "Oil", "Coriander", "Lemon", "Turmeric", "Chilli"]'
    ),
    (
        'cb5b451f-45e6-480d-9e34-3b04fc6c076f',
        'https://storage.googleapis.com/vault/hero_Chicken Curry.jpg',
        'https://storage.googleapis.com/vault/thumb_Chicken Curry.jpg',
        'Marinate chicken with yogurt and spices 30 mins
Saute onion until deep brown
Add ginger garlic paste and tomatoes
Add chicken and cook on high heat 5 mins
Simmer covered until chicken is cooked through',
        '["Chicken", "Yogurt", "Onion", "Tomato", "Ginger", "Garlic", "Spices"]'
    )
ON CONFLICT DO NOTHING;

-- 4. COMPLEXITY LEVELS (needed for suggestions engine)
INSERT INTO complexity_levels (level_code, level_name, description, min_score, max_score)
VALUES
    ('C1', 'Very Simple',  'One pot, minimal prep',        0,  20),
    ('C2', 'Simple',       'Basic cooking, few steps',     21, 40),
    ('C3', 'Moderate',     'Multiple steps, some skill',   41, 60),
    ('C4', 'Complex',      'Advanced techniques',          61, 80),
    ('C5', 'Expert',       'Professional level cooking',   81, 100)
ON CONFLICT DO NOTHING;

-- 5. SEED PAST 2 WEEKS MEAL DATA (Apr 6 - Apr 12, 2026)
INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date) VALUES
    ('3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-06'),
    ('361ab7ab-b76c-4596-bc10-908d0e5977dc', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-06'),
    ('03005c76-5533-4ee8-b7d5-6f52fb118077', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-06'),
    ('a1e16b13-3878-4224-b711-6379641d3afe', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-07'),
    ('1f99dd5a-6e27-4b5f-9921-69a71174ed05', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-07'),
    ('247ea03f-cc1a-4cb6-ae18-6c97160c093c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-07'),
    ('705874b7-7dd9-4bc7-91b8-bb7c140fbc86', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-08'),
    ('5bf7c543-2d7c-47d3-80af-049eb2dd43ab', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-08'),
    ('5927c122-bc55-4690-a831-d7f4a1fe9d86', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-08'),
    ('5437ef6b-54b1-415c-ac64-b93530c6557e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-09'),
    ('232032e2-b760-4111-a33a-e7bbbfeea64f', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-09'),
    ('4066785a-2e99-44b4-a625-bd7f9ae8469b', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-09'),
    ('6fbc0039-e261-4941-a129-ed9c163b81c8', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-10'),
    ('03a11d42-8d40-4873-8e1b-c64c5c606100', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-10'),
    ('955c5848-4979-4873-a233-01157f2cb5b7', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-10'),
    ('07119274-a390-49ac-bba3-0292814d0ccf', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-11'),
    ('fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-11'),
    ('7475cd18-81c8-425f-a87b-06e4a3cbbfdf', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-11'),
    ('e0850e47-3d4d-4f59-ae5e-5c5216e778ba', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-12'),
    ('25645465-c92f-4b38-8374-45751b7061e2', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch',     '2026-04-12'),
    ('9fae68e6-11ab-45b8-9f49-f63d710d867c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner',    '2026-04-12')
ON CONFLICT DO NOTHING;

INSERT INTO meal_event_detail (event_id, recipe_id, action_taken, dish_type, dish_sequence) VALUES
    ('3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Accepted', 'Main', 1),
    ('361ab7ab-b76c-4596-bc10-908d0e5977dc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Accepted', 'Main', 1),
    ('03005c76-5533-4ee8-b7d5-6f52fb118077', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Accepted', 'Main', 1),
    ('a1e16b13-3878-4224-b711-6379641d3afe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Accepted', 'Main', 1),
    ('1f99dd5a-6e27-4b5f-9921-69a71174ed05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Accepted', 'Main', 1),
    ('247ea03f-cc1a-4cb6-ae18-6c97160c093c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Accepted', 'Main', 1),
    ('705874b7-7dd9-4bc7-91b8-bb7c140fbc86', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Accepted', 'Main', 1),
    ('5bf7c543-2d7c-47d3-80af-049eb2dd43ab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Accepted', 'Main', 1),
    ('5927c122-bc55-4690-a831-d7f4a1fe9d86', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Accepted', 'Main', 1),
    ('5437ef6b-54b1-415c-ac64-b93530c6557e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Accepted', 'Main', 1),
    ('232032e2-b760-4111-a33a-e7bbbfeea64f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Accepted', 'Main', 1),
    ('4066785a-2e99-44b4-a625-bd7f9ae8469b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Accepted', 'Main', 1),
    ('6fbc0039-e261-4941-a129-ed9c163b81c8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Accepted', 'Main', 1),
    ('03a11d42-8d40-4873-8e1b-c64c5c606100', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Accepted', 'Main', 1),
    ('955c5848-4979-4873-a233-01157f2cb5b7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Accepted', 'Main', 1),
    ('07119274-a390-49ac-bba3-0292814d0ccf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Accepted', 'Main', 1),
    ('fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Accepted', 'Main', 1),
    ('7475cd18-81c8-425f-a87b-06e4a3cbbfdf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Accepted', 'Main', 1),
    ('e0850e47-3d4d-4f59-ae5e-5c5216e778ba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Accepted', 'Main', 1),
    ('25645465-c92f-4b38-8374-45751b7061e2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Accepted', 'Main', 1),
    ('9fae68e6-11ab-45b8-9f49-f63d710d867c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Accepted', 'Main', 1)
ON CONFLICT DO NOTHING;

-- Verify
SELECT COUNT(*) as recipes FROM recipe_dna_master;
SELECT COUNT(*) as vault FROM recipe_content_vault;
SELECT COUNT(*) as meal_headers FROM meal_event_header;
SELECT COUNT(*) as household FROM household_master;
