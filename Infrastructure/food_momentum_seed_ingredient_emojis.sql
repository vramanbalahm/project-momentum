-- ============================================================
-- Seed: Ingredient-specific emojis for My Pantry
-- Run after schema v20
-- ============================================================

-- Vegetables
UPDATE ingredient_catalog SET emoji = '🍅' WHERE name_en ILIKE '%tomato%';
UPDATE ingredient_catalog SET emoji = '🧅' WHERE name_en ILIKE '%onion%';
UPDATE ingredient_catalog SET emoji = '🍆' WHERE name_en ILIKE '%brinjal%' OR name_en ILIKE '%eggplant%';
UPDATE ingredient_catalog SET emoji = '🥕' WHERE name_en ILIKE '%carrot%';
UPDATE ingredient_catalog SET emoji = '🥔' WHERE name_en ILIKE '%potato%' AND name_en NOT ILIKE '%sweet%';
UPDATE ingredient_catalog SET emoji = '🍠' WHERE name_en ILIKE '%sweet potato%' OR name_en ILIKE '%yam%' OR name_en ILIKE '%colocasia%';
UPDATE ingredient_catalog SET emoji = '🧄' WHERE name_en ILIKE '%garlic%';
UPDATE ingredient_catalog SET emoji = '🫚' WHERE name_en ILIKE '%ginger%';
UPDATE ingredient_catalog SET emoji = '🥬' WHERE name_en ILIKE '%spinach%' OR name_en ILIKE '%cabbage%';
UPDATE ingredient_catalog SET emoji = '🥦' WHERE name_en ILIKE '%cauliflower%' OR name_en ILIKE '%broccoli%';
UPDATE ingredient_catalog SET emoji = '🌽' WHERE name_en ILIKE '%corn%' OR name_en ILIKE '%maize%';
UPDATE ingredient_catalog SET emoji = '🫑' WHERE name_en ILIKE '%capsicum%' OR name_en ILIKE '%bell pepper%';
UPDATE ingredient_catalog SET emoji = '🥒' WHERE name_en ILIKE '%cucumber%' OR name_en ILIKE '%gourd%' OR name_en ILIKE '%courgette%';
UPDATE ingredient_catalog SET emoji = '🎃' WHERE name_en ILIKE '%pumpkin%' OR name_en ILIKE '%ash gourd%';
UPDATE ingredient_catalog SET emoji = '🫛' WHERE name_en ILIKE '%peas%' OR name_en ILIKE '%cluster bean%' OR name_en ILIKE '%french bean%';
UPDATE ingredient_catalog SET emoji = '🌿' WHERE name_en ILIKE '%drumstick%';
UPDATE ingredient_catalog SET emoji = '🍄' WHERE name_en ILIKE '%mushroom%';
UPDATE ingredient_catalog SET emoji = '🍈' WHERE name_en ILIKE '%jackfruit%';
UPDATE ingredient_catalog SET emoji = '🍌' WHERE name_en ILIKE '%plantain%' OR name_en ILIKE '%raw banana%';
UPDATE ingredient_catalog SET emoji = '🌱' WHERE name_en ILIKE '%radish%' OR name_en ILIKE '%turnip%';
UPDATE ingredient_catalog SET emoji = '🫒' WHERE name_en ILIKE '%beetroot%' OR name_en ILIKE '%beet%';

-- Meat
UPDATE ingredient_catalog SET emoji = '🍗' WHERE name_en ILIKE '%chicken%' AND name_en NOT ILIKE '%liver%' AND name_en NOT ILIKE '%gizzard%';
UPDATE ingredient_catalog SET emoji = '🥩' WHERE name_en ILIKE '%mutton%' OR name_en ILIKE '%lamb%' OR name_en ILIKE '%beef%' OR name_en ILIKE '%pork%';
UPDATE ingredient_catalog SET emoji = '🫀' WHERE name_en ILIKE '%liver%' OR name_en ILIKE '%gizzard%';
UPDATE ingredient_catalog SET emoji = '🦆' WHERE name_en ILIKE '%duck%';

-- Seafood
UPDATE ingredient_catalog SET emoji = '🦐' WHERE name_en ILIKE '%prawn%' OR name_en ILIKE '%shrimp%';
UPDATE ingredient_catalog SET emoji = '🦀' WHERE name_en ILIKE '%crab%';
UPDATE ingredient_catalog SET emoji = '🦞' WHERE name_en ILIKE '%lobster%';
UPDATE ingredient_catalog SET emoji = '🦑' WHERE name_en ILIKE '%squid%';

-- Dairy & Eggs
UPDATE ingredient_catalog SET emoji = '🥚' WHERE name_en ILIKE '%egg%';
UPDATE ingredient_catalog SET emoji = '🥛' WHERE name_en ILIKE '%milk%' OR name_en ILIKE '%curd%' OR name_en ILIKE '%yogurt%' OR name_en ILIKE '%yoghurt%';
UPDATE ingredient_catalog SET emoji = '🧈' WHERE name_en ILIKE '%butter%' OR name_en ILIKE '%ghee%';
UPDATE ingredient_catalog SET emoji = '🧀' WHERE name_en ILIKE '%cheese%' OR name_en ILIKE '%paneer%';

-- Grains
UPDATE ingredient_catalog SET emoji = '🍚' WHERE name_en ILIKE '%rice%' OR name_en ILIKE '%poha%';
UPDATE ingredient_catalog SET emoji = '🍞' WHERE name_en ILIKE '%bread%';

-- Lentils
UPDATE ingredient_catalog SET emoji = '🥜' WHERE name_en ILIKE '%peanut%' OR name_en ILIKE '%groundnut%';

-- Spices
UPDATE ingredient_catalog SET emoji = '🌶️' WHERE name_en ILIKE '%chilli%' OR name_en ILIKE '%chili%';
UPDATE ingredient_catalog SET emoji = '🍃' WHERE name_en ILIKE '%curry leaf%' OR name_en ILIKE '%curry leaves%' OR name_en ILIKE '%bay leaf%';
UPDATE ingredient_catalog SET emoji = '🌿' WHERE name_en ILIKE '%coriander%' OR name_en ILIKE '%mint%' OR name_en ILIKE '%fenugreek%';

-- Fruits
UPDATE ingredient_catalog SET emoji = '🥭' WHERE name_en ILIKE '%mango%';
UPDATE ingredient_catalog SET emoji = '🍌' WHERE name_en ILIKE '%banana%' AND name_en NOT ILIKE '%raw%' AND name_en NOT ILIKE '%plantain%';
UPDATE ingredient_catalog SET emoji = '🍋' WHERE name_en ILIKE '%lemon%' OR name_en ILIKE '%lime%';
UPDATE ingredient_catalog SET emoji = '🥥' WHERE name_en ILIKE '%coconut%';
UPDATE ingredient_catalog SET emoji = '🍊' WHERE name_en ILIKE '%orange%';
UPDATE ingredient_catalog SET emoji = '🍇' WHERE name_en ILIKE '%grape%';
UPDATE ingredient_catalog SET emoji = '🍍' WHERE name_en ILIKE '%pineapple%';

-- Oils
UPDATE ingredient_catalog SET emoji = '🥥' WHERE name_en ILIKE '%coconut oil%';
UPDATE ingredient_catalog SET emoji = '🌻' WHERE name_en ILIKE '%sunflower oil%';
UPDATE ingredient_catalog SET emoji = '🫒' WHERE name_en ILIKE '%olive oil%';

-- Verify
SELECT name_en, emoji, category FROM ingredient_catalog ORDER BY category, name_en LIMIT 20;
