"""
seed_recipes.py — Populate recipe_dna_master and recipe_content_vault
Supports Claude Haiku (default) and Google Gemini as AI backends.

Usage:
    cd C:\\Users\\SATISH.000\\project-momentum\\backend

    # Breakfast mains — Veg + Vegan
    python scripts/seed_recipes.py --meal breakfast --diet Veg --count 15
    python scripts/seed_recipes.py --meal breakfast --diet Vegan --count 10

    # Breakfast mains — Eggitarian
    python scripts/seed_recipes.py --meal breakfast --diet Eggitarian --count 8

    # Side dishes — chutneys, sambar, rasam, kootu
    python scripts/seed_recipes.py --meal side_dish --diet Veg --count 20
    python scripts/seed_recipes.py --meal side_dish --diet Vegan --count 10

    # Lunch mains
    python scripts/seed_recipes.py --meal lunch --diet Veg --count 20
    python scripts/seed_recipes.py --meal lunch --diet Non-Veg --count 15

    # Dinner mains
    python scripts/seed_recipes.py --meal dinner --diet Veg --count 15
    python scripts/seed_recipes.py --meal dinner --diet Non-Veg --count 15

    # Sub-region specific
    python scripts/seed_recipes.py --meal lunch --diet Non-Veg --sub_region Chettinad --count 10
    python scripts/seed_recipes.py --meal lunch --diet Veg --sub_region Brahmin --count 10

    # Use Gemini instead of Claude
    python scripts/seed_recipes.py --meal breakfast --diet Veg --count 10 --ai gemini

    # Dry run (no DB insert)
    python scripts/seed_recipes.py --meal breakfast --diet Veg --count 5 --dry-run

Options:
    --meal        breakfast | lunch | dinner | side_dish
    --diet        Veg | Non-Veg | Vegan | Eggitarian
    --sub_region  Brahmin | Chettinad | Kongu | Tirunelveli | Thanjavur | Coastal | (leave blank for all)
    --region      default: Tamil Nadu
    --count       number of recipes to generate (default 10)
    --ai          claude (default) | gemini
    --dry-run     print JSON only, do not insert into DB

Requirements:
    pip install anthropic google-generativeai psycopg2-binary python-dotenv
"""

import argparse
import json
import os
import re
import sys
import uuid
from pathlib import Path

# ── Load .env ─────────────────────────────────────────────────────────────────
from dotenv import load_dotenv
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

import psycopg2

# ── Config ────────────────────────────────────────────────────────────────────
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
GEMINI_API_KEY    = os.getenv("GEMINI_API_KEY", "")  # set in backend/.env — never hardcode
DATABASE_URL      = os.getenv("DATABASE_URL", "postgresql://postgres:admin123@localhost:5432/food_momentum_db")

if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# ── Valid values — enforced before DB insert ───────────────────────────────────
VALID_MEAL_SLOTS  = {"Breakfast", "Lunch", "Dinner", "Side Dish"}
VALID_DIETS       = {"Veg", "Non-Veg", "Vegan", "Eggitarian"}
VALID_INTENSITIES = {"Light", "Medium", "Heavy"}

# ── Meal slot rules per --meal arg ────────────────────────────────────────────
# These are the ONLY valid meal_slots combinations for each meal type.
# Claude/Gemini must return one of these — anything else is rejected.
ALLOWED_SLOTS_BY_MEAL = {
    "breakfast": [
        ["Breakfast"],
        ["Breakfast", "Dinner"],
        ["Breakfast", "Lunch"],
        ["Breakfast", "Lunch", "Dinner"],
    ],
    "lunch": [
        ["Lunch"],
        ["Lunch", "Dinner"],
        ["Breakfast", "Lunch"],
        ["Breakfast", "Lunch", "Dinner"],
    ],
    "dinner": [
        ["Dinner"],
        ["Lunch", "Dinner"],
        ["Breakfast", "Dinner"],
        ["Breakfast", "Lunch", "Dinner"],
    ],
    "side_dish": [
        ["Side Dish"],
    ],
}

# ── Meal slot descriptions for prompt ─────────────────────────────────────────
MEAL_SLOT_INSTRUCTIONS = {
    "breakfast": (
        "Breakfast MAIN DISH only — one standalone dish (e.g. Idli, Dosa, Pongal, Upma, Idiyappam). "
        "DO NOT combine dishes (e.g. 'Idli with Sambar' is WRONG — 'Idli' is correct). "
        "Chutneys, sambar, and gravies are NOT breakfast mains — skip them. "
        "meal_slots must be one of: [\"Breakfast\"], [\"Breakfast\",\"Dinner\"], "
        "[\"Breakfast\",\"Lunch\"], [\"Breakfast\",\"Lunch\",\"Dinner\"]"
    ),
    "lunch": (
        "Lunch MAIN DISH only — rice varieties, gravies, biryanis, curries, breads. "
        "DO NOT combine dishes. One standalone main dish per recipe. "
        "meal_slots must be one of: [\"Lunch\"], [\"Lunch\",\"Dinner\"], "
        "[\"Breakfast\",\"Lunch\"], [\"Breakfast\",\"Lunch\",\"Dinner\"]"
    ),
    "dinner": (
        "Dinner MAIN DISH only — one standalone dish. "
        "DO NOT combine dishes. "
        "IMPORTANT: Use [\"Lunch\",\"Dinner\"] for gravies, curries, kuzhambu, varuval, "
        "masala, paya, or any dish equally suitable for both lunch and dinner. "
        "Use [\"Dinner\"] ONLY for dishes specifically suited to dinner like heavy dosas, "
        "parottas, or kothu dishes not typically eaten at lunch. "
        "meal_slots must be one of: [\"Dinner\"], [\"Lunch\",\"Dinner\"], "
        "[\"Breakfast\",\"Dinner\"], [\"Breakfast\",\"Lunch\",\"Dinner\"]"
    ),
    "side_dish": (
        "SIDE DISH only — accompaniments served alongside mains: chutneys, poriyal, kootu, "
        "raita, pachadi, thogayal, pickle, papad, aviyal, stir-fry, dry preparations. "
        "IMPORTANT: Kuzhambu (gravy), Curry, Mor Kuzhambu, Vathal Kuzhambu are NOT side dishes — skip them. "
        "Rasam and Sambar are side dishes. Kootu is a side dish. Poriyal is a side dish. "
        "These are NOT standalone mains. One side dish per recipe. "
        "meal_slots must be exactly: [\"Side Dish\"]"
    ),
}

# ── Diet-specific guidance ─────────────────────────────────────────────────────
DIET_INSTRUCTIONS = {
    "Veg": (
        "All recipes must be Vegetarian. May include dairy (ghee, milk, curd, butter, paneer). "
        "No eggs, no meat, no seafood. "
        "If the dish uses only plant-based ingredients with NO dairy, set diet_type to 'Vegan' instead."
    ),
    "Vegan": (
        "All recipes must be strictly Vegan — NO dairy of any kind (no ghee, no milk, no curd, "
        "no butter, no paneer, no cream). Use only plant-based ingredients. "
        "Coconut milk is allowed. Oil instead of ghee. "
        "If a dish traditionally uses dairy, skip it and choose another."
    ),
    "Non-Veg": (
        "All recipes must include meat or seafood (chicken, mutton, fish, prawn, crab, etc.). "
        "Egg-only dishes are NOT Non-Veg for this purpose — they are Eggitarian. "
        "Focus on authentic Tamil Nadu Non-Veg preparations."
    ),
    "Eggitarian": (
        "All recipes must feature eggs as the primary protein. "
        "Dishes like egg curry, egg dosa, omelette, egg kothu parotta, egg biryani. "
        "No meat or seafood. May include dairy."
    ),
}

# ── Prompt template ────────────────────────────────────────────────────────────
PROMPT_TEMPLATE = """You are a culinary expert specialising in authentic Tamil Nadu cuisine.

Generate exactly {count} authentic {meal_label} recipes from {region}{sub_region_clause}.

CRITICAL RULES — read carefully:
1. ONE dish per recipe — never combine dishes. "Idli" is correct. "Idli with Sambar" is WRONG.
2. {meal_slot_instruction}
3. {diet_instruction}
4. dish_name must be unique — no duplicates within this batch or common variations.
5. Ingredient names must be clean base names only — NO preparation notes in the name.
   WRONG: "Onion, finely chopped" / "Rice (soaked overnight)"
   RIGHT: "Onion" / "Rice"
   Preparation goes in prep_steps only.
6. Return ONLY a valid JSON array. No explanation, no markdown, no code fences.

Each recipe must follow this EXACT structure:
{{
  "dish_name": "string — English name, single dish only",
  "regional_name": "string — Tamil or local language name if applicable",
  "sub_region": "string — e.g. Chettinad, Tirunelveli, Kongu Nadu, Thanjavur, Brahmin, Coastal",
  "diet_type": "{diet_type}",
  "is_sattvic": true | false,
  "is_vegan": true | false,
  "intensity_level": "Light | Medium | Heavy",
  "is_scalable": true | false,
  "is_regional_specific": true | false,
  "meal_slots": {allowed_slots_example},
  "prep_time_mins": integer,
  "cook_time_mins": integer,
  "serves": integer,
  "ingredients": [
    {{
      "name": "string — clean ingredient name only",
      "name_ta": "string — Tamil name if known, else empty string",
      "quantity": "string — e.g. 2, 1/2, a pinch, to taste",
      "unit": "string — e.g. cups, tbsp, grams, or empty for countable items",
      "category": "Vegetable | Lentil | Spice | Oil | Dairy | Grain | Meat | Seafood | Fruit | Nut | Other",
      "is_optional": true | false,
      "is_sattvic": true | false,
      "is_vegan": true | false
    }}
  ],
  "prep_steps": [
    "Step 1: ...",
    "Step 2: ...",
    "Step 3: ..."
  ],
  "tags": ["string"]
}}

Focus on variety — cover different sub-regions, different base ingredients, different cooking methods.
Include both everyday dishes and lesser-known authentic dishes.
Do not include fusion dishes or non-Tamil Nadu dishes.

{exclusion_clause}
"""  

# ── AI backends ───────────────────────────────────────────────────────────────

def call_claude(prompt, count):
    """Call Claude Haiku and return raw text response."""
    import anthropic
    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
    message = client.messages.create(
        model="claude-haiku-4-5",
        max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
        system=(
            "You are a culinary database assistant. You always respond with valid JSON arrays only. "
            "Never add explanations, markdown, or code fences. "
            "Never combine multiple dishes into one recipe name."
        )
    )
    return message.content[0].text.strip()


def call_gemini(prompt, count):
    """Call Gemini Flash and return raw text response."""
    from google import genai
    from google.genai import types
    client = genai.Client(api_key=GEMINI_API_KEY)
    GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash-lite")
    response = client.models.generate_content(
        model=GEMINI_MODEL,
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.7,
            max_output_tokens=16000,
        )
    )
    return response.text.strip()


def parse_response(raw):
    """Parse JSON from AI response, stripping markdown fences if present."""
    if raw.startswith("```"):
        lines = raw.split("\n")
        raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])
    raw = raw.strip()
    return json.loads(raw)


# ── Validation ────────────────────────────────────────────────────────────────

def validate_meal_slots(meal_slots, meal_arg):
    """Check meal_slots against allowed combinations for this meal type."""
    if not meal_slots or not isinstance(meal_slots, list):
        return False
    allowed = ALLOWED_SLOTS_BY_MEAL.get(meal_arg, [])
    # Normalise — sort both for comparison
    normalised = sorted([s.strip() for s in meal_slots])
    for allowed_combo in allowed:
        if normalised == sorted(allowed_combo):
            return True
    return False


def fix_meal_slots(meal_slots, meal_arg):
    """
    Attempt to fix invalid meal_slots by mapping to the closest valid combo.
    Returns fixed slots or None if unfixable.
    """
    if not meal_slots:
        # Default to the primary slot for this meal type
        defaults = {
            "breakfast": ["Breakfast"],
            "lunch":     ["Lunch"],
            "dinner":    ["Dinner"],
            "side_dish": ["Side Dish"],
        }
        return defaults.get(meal_arg)

    # Clean individual slot values
    cleaned = []
    slot_map = {
        "snack":        "Side Dish",
        "snacks":       "Side Dish",
        "dessert":      "Side Dish",
        "festival food":"Lunch",
        "side dish":    "Side Dish",
        "breakfast":    "Breakfast",
        "lunch":        "Lunch",
        "dinner":       "Dinner",
    }
    for s in meal_slots:
        mapped = slot_map.get(s.lower().strip(), s.strip())
        if mapped in VALID_MEAL_SLOTS:
            cleaned.append(mapped)

    cleaned = sorted(list(set(cleaned)))
    if not cleaned:
        return None

    # Check if cleaned is now valid
    allowed = ALLOWED_SLOTS_BY_MEAL.get(meal_arg, [])
    for allowed_combo in allowed:
        if cleaned == sorted(allowed_combo):
            return cleaned

    # If still not valid, use the primary slot
    defaults = {
        "breakfast": ["Breakfast"],
        "lunch":     ["Lunch"],
        "dinner":    ["Dinner"],
        "side_dish": ["Side Dish"],
    }
    return defaults.get(meal_arg)


# ── DB helpers ────────────────────────────────────────────────────────────────

def get_existing_dish_names():
    """Fetch all existing dish names from DB for exclusion in prompt."""
    conn = get_connection()
    cur  = conn.cursor()
    cur.execute("SELECT dish_name FROM recipe_dna_master ORDER BY dish_name")
    names = [row[0] for row in cur.fetchall()]
    cur.close()
    conn.close()
    return names

def get_connection():
    return psycopg2.connect(DATABASE_URL)


def clean_ingredient_name(name):
    """Strip preparation notes from ingredient names."""
    name = name.split(",")[0].strip()
    name = re.sub(r"\s*\([^)]*\)", "", name).strip()
    for keyword in [" for ", " soaked", " roasted", " ground", " grated", " beaten", " chopped", " sliced"]:
        if keyword in name.lower():
            name = name[:name.lower().index(keyword)].strip()
    return name


def dish_exists(cur, dish_name):
    """
    Check exact + fuzzy match to prevent near-duplicate dishes.
    Fuzzy threshold raised to 0.85 — stricter to avoid false positives
    like 'Egg Pongal' matching 'Pongal' or 'Ragi Idiyappam' matching 'Idiyappam'.
    Additionally: if dish names share the same base but have a meaningful prefix
    (Egg, Ragi, Kambu, Thinai, Varagu, Kuthiraivali, Samai, Kodo, Bajra, Foxtail)
    they are treated as distinct dishes and never merged.
    """
    # Exact match
    cur.execute("SELECT 1 FROM recipe_dna_master WHERE LOWER(dish_name) = LOWER(%s)", (dish_name,))
    if cur.fetchone():
        return True

    # Prefix guard — if the dish has a meaningful distinguishing prefix, skip fuzzy
    DISTINCT_PREFIXES = [
        "egg ", "muttai", "ragi ", "kambu ", "thinai ", "varagu ", "kuthiraivali ",
        "samai ", "kodo ", "bajra ", "foxtail ", "little millet", "kuzhu ",
        "ven ", "sweet ", "spicy ", "mini ", "set ", "neer "
    ]
    dish_lower = dish_name.lower()
    for prefix in DISTINCT_PREFIXES:
        if dish_lower.startswith(prefix):
            # Only do exact match for prefixed dishes — skip fuzzy entirely
            return False

    # Fuzzy match — threshold 0.85 (was 0.6 — too aggressive)
    cur.execute("""
        SELECT dish_name FROM recipe_dna_master
        WHERE similarity(LOWER(dish_name), LOWER(%s)) > 0.85
        LIMIT 1
    """, (dish_name,))
    row = cur.fetchone()
    if row:
        print(f"    (fuzzy match: '{dish_name}' ~ '{row[0]}')")
        return True
    return False


def get_or_create_ingredient(cur, ingredient):
    """Get existing ingredient from catalog or create new one."""
    name_en = clean_ingredient_name(ingredient.get("name", "").strip())
    if not name_en:
        return None

    cur.execute("SELECT id FROM ingredient_catalog WHERE LOWER(name_en) = LOWER(%s)", (name_en,))
    row = cur.fetchone()
    if row:
        return row[0]

    cur.execute("""
        SELECT id FROM ingredient_catalog
        WHERE similarity(LOWER(name_en), LOWER(%s)) > 0.8
        ORDER BY similarity(LOWER(name_en), LOWER(%s)) DESC
        LIMIT 1
    """, (name_en, name_en))
    row = cur.fetchone()
    if row:
        return row[0]

    name_ta  = ingredient.get("name_ta", "") or None
    category = ingredient.get("category", "Other")
    is_sattvic = ingredient.get("is_sattvic", True)
    is_vegan   = ingredient.get("is_vegan", True)

    valid_categories = {"Vegetable", "Lentil", "Spice", "Oil", "Dairy",
                        "Grain", "Meat", "Seafood", "Fruit", "Nut", "Other"}
    if category not in valid_categories:
        category = "Other"

    cur.execute("""
        INSERT INTO ingredient_catalog (name_en, name_ta, category, is_sattvic, is_vegan, created_by_ai)
        VALUES (%s, %s, %s, %s, %s, true)
        RETURNING id
    """, (name_en, name_ta, category, is_sattvic, is_vegan))
    return cur.fetchone()[0]


def insert_recipes(recipes, args, ai_model, dry_run=False):
    if dry_run:
        print(json.dumps(recipes, indent=2, ensure_ascii=False))
        print(f"\n✓ Dry run — {len(recipes)} recipes generated, not inserted.")
        return

    conn = get_connection()
    cur  = conn.cursor()
    inserted = skipped = errors = slot_fixed = 0

    for r in recipes:
        try:
            dish_name = r.get("dish_name", "").strip()
            if not dish_name:
                print(f"  ⚠ Skipped — empty dish_name")
                skipped += 1
                continue

            if dish_exists(cur, dish_name):
                print(f"  ⟳ Skipped — already exists: {dish_name}")
                skipped += 1
                continue

            # Validate diet_type
            diet_type = r.get("diet_type", args.diet)
            if diet_type not in VALID_DIETS:
                diet_type = args.diet

            # Validate intensity
            intensity = r.get("intensity_level", "Medium")
            if intensity not in VALID_INTENSITIES:
                intensity = "Medium"

            # Validate and fix meal_slots
            meal_slots = r.get("meal_slots", [])
            if not validate_meal_slots(meal_slots, args.meal):
                fixed = fix_meal_slots(meal_slots, args.meal)
                if fixed is None:
                    print(f"  ✗ Skipped '{dish_name}' — invalid meal_slots {meal_slots} and could not fix")
                    skipped += 1
                    continue
                print(f"  ⚠ Fixed meal_slots for '{dish_name}': {meal_slots} → {fixed}")
                meal_slots = fixed
                slot_fixed += 1

            recipe_id            = str(uuid.uuid4())
            is_sattvic           = r.get("is_sattvic", False)
            is_vegan             = r.get("is_vegan", False)
            is_scalable          = r.get("is_scalable", True)
            is_regional_specific = r.get("is_regional_specific", False)
            regional_name        = r.get("regional_name", dish_name)
            sub_region           = r.get("sub_region", args.sub_region or "")
            prep_time_mins       = r.get("prep_time_mins")
            cook_time_mins       = r.get("cook_time_mins")
            serves               = r.get("serves")
            tags                 = r.get("tags", [])

            cur.execute("""
                INSERT INTO recipe_dna_master
                    (recipe_id, dish_name, regional_name, sub_region, diet_type,
                     is_sattvic, intensity_level, is_scalable, is_vegan,
                     is_regional_specific, meal_slots, prep_time_mins, cook_time_mins,
                     serves, tags, source_region, created_by_ai, ai_model)
                VALUES
                    (%s, %s, %s, %s, %s::diet_pref,
                     %s, %s, %s, %s,
                     %s, %s, %s, %s,
                     %s, %s, %s, %s, %s)
            """, (recipe_id, dish_name, regional_name, sub_region, diet_type,
                  is_sattvic, intensity, is_scalable, is_vegan,
                  is_regional_specific, meal_slots, prep_time_mins, cook_time_mins,
                  serves, tags, args.region, True, ai_model))

            steps = r.get("prep_steps", [])
            prep_steps_text = "\n".join(steps) if isinstance(steps, list) else str(steps)
            ingredients = r.get("ingredients", [])
            ingredients_json = json.dumps(ingredients, ensure_ascii=False)

            cur.execute("""
                INSERT INTO recipe_content_vault (recipe_id, prep_steps, ingredients_json)
                VALUES (%s, %s, %s)
            """, (recipe_id, prep_steps_text, ingredients_json))

            ing_inserted = 0
            for idx, ing in enumerate(ingredients):
                ing_id = get_or_create_ingredient(cur, ing)
                if ing_id is None:
                    continue
                cur.execute("""
                    INSERT INTO recipe_ingredients
                        (recipe_id, ingredient_id, quantity, unit, is_optional, sort_order)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (recipe_id, ing_id,
                      ing.get("quantity", ""),
                      ing.get("unit", ""),
                      ing.get("is_optional", False),
                      idx + 1))
                ing_inserted += 1

            conn.commit()
            print(f"  ✓ {dish_name} ({diet_type}, {meal_slots}) — {ing_inserted} ingredients")
            inserted += 1

        except Exception as e:
            conn.rollback()
            print(f"  ✗ Error inserting '{r.get('dish_name', '?')}': {e}")
            errors += 1

    cur.close()
    conn.close()

    print(f"\n{'='*50}")
    print(f"  Inserted    : {inserted}")
    print(f"  Skipped     : {skipped}")
    print(f"  Slot fixed  : {slot_fixed}")
    print(f"  Errors      : {errors}")
    print(f"{'='*50}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Seed recipes using Claude Haiku or Gemini")
    parser.add_argument("--meal",       default="breakfast",
                        help="breakfast | lunch | dinner | side_dish")
    parser.add_argument("--diet",       default="Veg",
                        help="Veg | Non-Veg | Vegan | Eggitarian")
    parser.add_argument("--sub_region", default="",
                        help="Brahmin | Chettinad | Kongu | Tirunelveli | Thanjavur | Coastal")
    parser.add_argument("--region",     default="Tamil Nadu",
                        help="Region name e.g. 'Tamil Nadu'")
    parser.add_argument("--count",      type=int, default=10,
                        help="Number of recipes to generate")
    parser.add_argument("--ai",         default="claude",
                        help="claude (default) | gemini")
    parser.add_argument("--dry-run",    action="store_true",
                        help="Print JSON only, do not insert into DB")
    args = parser.parse_args()

    # Validate args
    if args.meal not in ALLOWED_SLOTS_BY_MEAL:
        print(f"✗ Invalid --meal '{args.meal}'. Choose: breakfast | lunch | dinner | side_dish")
        sys.exit(1)
    if args.diet not in VALID_DIETS:
        print(f"✗ Invalid --diet '{args.diet}'. Choose: Veg | Non-Veg | Vegan | Eggitarian")
        sys.exit(1)

    # Determine AI model label
    if args.ai == "claude":
        if not ANTHROPIC_API_KEY:
            print("✗ ANTHROPIC_API_KEY not set in .env")
            sys.exit(1)
        ai_model = "claude-haiku-4-5"
        call_ai = call_claude
    else:
        if not GEMINI_API_KEY:
            print("✗ GEMINI_API_KEY not set in .env")
            sys.exit(1)
        ai_model = os.getenv("GEMINI_MODEL", "gemini-2.5-flash-lite")
        call_ai = call_gemini

    # Build sub_region clause for prompt
    sub_region_clause = f" — specifically from the {args.sub_region} sub-region" if args.sub_region else ""

    # Build allowed slots example for prompt
    allowed_examples = ALLOWED_SLOTS_BY_MEAL[args.meal]
    allowed_slots_example = json.dumps(allowed_examples[0])

    # Fetch existing dish names and build exclusion clause
    if not args.dry_run:
        existing_names = get_existing_dish_names()
        print(f"   Existing: {len(existing_names)} recipes already in DB — will exclude from prompt")
    else:
        existing_names = []

    if existing_names:
        names_list = "\n".join(f"- {n}" for n in existing_names)
        exclusion_clause = (
            f"IMPORTANT — Do NOT generate any of these {len(existing_names)} dishes that already exist:\n"
            f"{names_list}\n"
            "Generate only dishes that are NOT in the above list."
        )
    else:
        exclusion_clause = ""

    # Build prompt
    prompt = PROMPT_TEMPLATE.format(
        count=args.count,
        meal_label=args.meal.replace("_", " "),
        region=args.region,
        sub_region_clause=sub_region_clause,
        meal_slot_instruction=MEAL_SLOT_INSTRUCTIONS[args.meal],
        diet_instruction=DIET_INSTRUCTIONS[args.diet],
        diet_type=args.diet,
        allowed_slots_example=allowed_slots_example,
        exclusion_clause=exclusion_clause,
    )

    print(f"\n🌿 Momentum Recipe Seeder")
    print(f"   AI      : {ai_model}")
    print(f"   Meal    : {args.meal}")
    print(f"   Diet    : {args.diet}")
    print(f"   Region  : {args.region}")
    if args.sub_region:
        print(f"   Sub     : {args.sub_region}")
    print(f"   Count   : {args.count}")
    print(f"   Dry run : {args.dry_run}\n")

    # Batch into groups of 8 to avoid token limits
    BATCH_SIZE  = 8
    all_recipes = []
    batches = [BATCH_SIZE] * (args.count // BATCH_SIZE)
    if args.count % BATCH_SIZE:
        batches.append(args.count % BATCH_SIZE)

    for batch_num, count in enumerate(batches, 1):
        print(f"⏳ Calling {args.ai} — batch {batch_num}/{len(batches)} ({count} recipes)...")
        batch_prompt = PROMPT_TEMPLATE.format(
            count=count,
            meal_label=args.meal.replace("_", " "),
            region=args.region,
            sub_region_clause=sub_region_clause,
            meal_slot_instruction=MEAL_SLOT_INSTRUCTIONS[args.meal],
            diet_instruction=DIET_INSTRUCTIONS[args.diet],
            diet_type=args.diet,
            allowed_slots_example=allowed_slots_example,
            exclusion_clause=exclusion_clause,
        )
        try:
            raw = call_ai(batch_prompt, count)
        except Exception as e:
            print(f"✗ AI API error on batch {batch_num}: {e}")
            continue

        try:
            recipes = parse_response(raw)
            if not isinstance(recipes, list):
                raise ValueError("Expected a JSON array")
            print(f"  ✓ Parsed {len(recipes)} recipes in batch {batch_num}")
            all_recipes.extend(recipes)
        except json.JSONDecodeError as e:
            print(f"  ✗ JSON parse error on batch {batch_num}: {e}")
            print("  Raw snippet:", raw[:300])
            continue

    if not all_recipes:
        print("✗ No recipes parsed — exiting.")
        sys.exit(1)

    print(f"\n✓ Total parsed: {len(all_recipes)} recipes")
    if not args.dry_run:
        print("\n💾 Inserting into database...")
    insert_recipes(all_recipes, args, ai_model, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
