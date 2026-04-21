"""
seed_recipes_gemini.py — Populate recipe_dna_master and recipe_content_vault
using Google Gemini AI.

Usage:
    cd C:\\Users\\SATISH.000\\project-momentum\\backend
    python scripts/seed_recipes_gemini.py --meal breakfast --region "Tamil Nadu" --count 50
    python scripts/seed_recipes_gemini.py --meal lunch    --region "Tamil Nadu" --count 50
    python scripts/seed_recipes_gemini.py --meal dinner   --region "Tamil Nadu" --count 50
    python scripts/seed_recipes_gemini.py --meal snack    --region "Tamil Nadu" --count 30

Options:
    --meal      breakfast | lunch | dinner | snack | all
    --region    e.g. "Tamil Nadu", "Kerala", "Karnataka"
    --count     number of recipes to generate (default 50)
    --dry-run   print JSON only, do not insert into DB

Requirements:
    pip install google-generativeai psycopg2-binary python-dotenv
"""

import argparse
import json
import os
import sys
import uuid
from pathlib import Path

# ── Load .env ─────────────────────────────────────────────────────────────────
from dotenv import load_dotenv
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

import google.generativeai as genai
import psycopg2
from psycopg2.extras import execute_batch

# ── Config ────────────────────────────────────────────────────────────────────
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyCwsXt4Pkga-RmiJGORB56yQBDXvryXEh0")
GEMINI_MODEL   = os.getenv("GEMINI_MODEL",   "gemini-2.5-flash-lite")
DATABASE_URL   = os.getenv("DATABASE_URL",   "postgresql://postgres:admin123@localhost:5432/food_momentum_db")

if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# ── Gemini setup ──────────────────────────────────────────────────────────────
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(GEMINI_MODEL)

# ── Prompt ────────────────────────────────────────────────────────────────────
PROMPT_TEMPLATE = """
You are a culinary expert specialising in South Indian cuisine.

Generate exactly {count} authentic {meal} recipes from {region} — covering all sub-regions
(this is the source_region: {region})
(e.g. Chettinad, Kongu Nadu, Tirunelveli, Thanjavur, Brahmin, coastal areas etc.).

Return ONLY a JSON array. No explanation, no markdown, no code fences.

Each recipe must follow this exact structure:
{{
  "dish_name": "string — English name of the dish",
  "regional_name": "string — name in Tamil or local language if applicable, else same as dish_name",
  "sub_region": "string — which sub-region this dish belongs to, e.g. Chettinad, Tirunelveli, Kongu Nadu",
  "diet_type": "Veg | Non-Veg | Vegan | Eggitarian",
  "is_sattvic": true | false,
  "is_vegan": true | false,
  "intensity_level": "Light | Medium | Heavy",
  "is_scalable": true | false,
  "is_regional_specific": true | false — true if this dish is distinctly associated with a specific sub-region and not commonly eaten across all of {region}. false if it is a staple eaten widely across the state regardless of sub-region. Example: Idli Sambar = false, Chettinad Kuzhambu = true, Tirunelveli Seepu Seedai = true,
  "meal_slots": ["Breakfast"] or ["Lunch"] or ["Dinner"] or ["Breakfast","Lunch"] etc,
  "prep_time_mins": integer,
  "cook_time_mins": integer,
  "serves": integer,
  "ingredients": [
    {{
      "name": "string — ingredient name in English",
      "name_ta": "string — ingredient name in Tamil if known, else empty string",
      "quantity": "string — e.g. 2, 1/2, a pinch, to taste",
      "unit": "string — e.g. cups, tbsp, grams, teaspoon, or empty for countable items",
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

Rules:
- dish_name must be unique — no duplicates
- Ingredient name must be the clean base ingredient only — no preparation notes.
  WRONG: "Onion, finely chopped" / "Banana blossom (Vazhaipoo), cleaned"
  RIGHT: "Onion" / "Banana blossom"
  Preparation method belongs in prep_steps, not in ingredient name.
- Ingredients must be specific and realistic — actual quantities
- prep_steps must be clear and actionable — minimum 4 steps
- Cover a variety of diet types reflecting the region
- Include both common and lesser-known authentic dishes
- Do not include fusion or non-regional dishes
"""

# ── DB helpers ────────────────────────────────────────────────────────────────
def get_connection():
    return psycopg2.connect(DATABASE_URL)

def clean_ingredient_name(name):
    """
    Strip preparation notes from ingredient names before storing in ingredient_catalog.
    Examples:
      "Onion, finely chopped"           → "Onion"
      "Banana blossom (Vazhaipoo), ..."  → "Banana blossom"
      "Chana dal (Kadalai Paruppu), ..." → "Chana dal"
      "Oil for deep frying"             → "Oil"
      "Mutton or Chicken keema"         → keep as-is (it is a valid combined ingredient)
    """
    import re
    # Remove anything after a comma
    name = name.split(",")[0].strip()
    # Remove parenthetical local names — e.g. (Vazhaipoo), (Kadalai Paruppu)
    name = re.sub(r"\s*\([^)]*\)", "", name).strip()
    # Remove trailing prep notes after common keywords
    for keyword in [" for ", " soaked", " roasted", " ground", " grated", " beaten"]:
        if keyword in name.lower():
            name = name[:name.lower().index(keyword)].strip()
    return name

def dish_exists(cur, dish_name):
    """Check exact + fuzzy match — prevents near-duplicate dishes."""
    # Exact match
    cur.execute("SELECT 1 FROM recipe_dna_master WHERE LOWER(dish_name) = LOWER(%s)", (dish_name,))
    if cur.fetchone():
        return True
    # Fuzzy match — similarity > 0.6 catches spelling variations like
    # Tirunelveli vs Thirunelveli, Seepu Seedai vs Thirunelveli Seepu Seedai
    cur.execute("""
        SELECT dish_name FROM recipe_dna_master
        WHERE similarity(LOWER(dish_name), LOWER(%s)) > 0.6
        LIMIT 1
    """, (dish_name,))
    row = cur.fetchone()
    if row:
        print(f"    (fuzzy match: '{dish_name}' ~ '{row[0]}')")
        return True
    return False

def get_or_create_ingredient(cur, ingredient):
    """
    Get existing ingredient from catalog by name (fuzzy match),
    or create a new one. Returns ingredient_catalog.id.
    """
    name_en = clean_ingredient_name(ingredient.get("name", "").strip())
    if not name_en:
        return None

    # Try exact match first
    cur.execute("""
        SELECT id FROM ingredient_catalog WHERE LOWER(name_en) = LOWER(%s)
    """, (name_en,))
    row = cur.fetchone()
    if row:
        return row[0]

    # Try fuzzy match — similarity > 0.8 to avoid false positives
    cur.execute("""
        SELECT id, name_en FROM ingredient_catalog
        WHERE similarity(LOWER(name_en), LOWER(%s)) > 0.8
        ORDER BY similarity(LOWER(name_en), LOWER(%s)) DESC
        LIMIT 1
    """, (name_en, name_en))
    row = cur.fetchone()
    if row:
        return row[0]

    # Not found — create new
    name_ta  = ingredient.get("name_ta", "") or None
    category = ingredient.get("category", "Other")
    is_sattvic = ingredient.get("is_sattvic", True)
    is_vegan   = ingredient.get("is_vegan", True)

    valid_categories = {
        "Vegetable", "Lentil", "Spice", "Oil", "Dairy",
        "Grain", "Meat", "Seafood", "Fruit", "Nut", "Other"
    }
    if category not in valid_categories:
        category = "Other"

    cur.execute("""
        INSERT INTO ingredient_catalog (name_en, name_ta, category, is_sattvic, is_vegan, created_by_ai)
        VALUES (%s, %s, %s, %s, %s, true)
        RETURNING id
    """, (name_en, name_ta, category, is_sattvic, is_vegan))
    return cur.fetchone()[0]

def insert_recipes(recipes, args, dry_run=False):
    if dry_run:
        print(json.dumps(recipes, indent=2, ensure_ascii=False))
        print(f"\n✓ Dry run — {len(recipes)} recipes generated, not inserted.")
        return

    # args used inside loop for source_region and ai_model

    conn = get_connection()
    cur  = conn.cursor()

    inserted   = 0
    skipped    = 0
    errors     = 0

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

            recipe_id  = str(uuid.uuid4())
            diet_type  = r.get("diet_type", "Veg")
            is_sattvic = r.get("is_sattvic", False)
            is_vegan   = r.get("is_vegan", False)
            intensity  = r.get("intensity_level", "Medium")
            is_scalable = r.get("is_scalable", True)

            # Validate diet_type against DB enum
            valid_diets = {"Veg", "Non-Veg", "Vegan", "Eggitarian"}
            if diet_type not in valid_diets:
                diet_type = "Veg"

            # Validate intensity
            valid_intensity = {"Light", "Medium", "Heavy"}
            if intensity not in valid_intensity:
                intensity = "Medium"

            is_regional_specific = r.get("is_regional_specific", False)
            regional_name  = r.get("regional_name", dish_name)
            sub_region     = r.get("sub_region", "")
            meal_slots     = r.get("meal_slots", [])
            prep_time_mins = r.get("prep_time_mins")
            cook_time_mins = r.get("cook_time_mins")
            serves         = r.get("serves")
            tags           = r.get("tags", [])

            # Insert into recipe_dna_master — store everything Gemini returns
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
                  serves, tags, args.region, True, GEMINI_MODEL))

            # Build prep_steps string
            steps = r.get("prep_steps", [])
            prep_steps_text = "\n".join(steps) if isinstance(steps, list) else str(steps)

            # Build ingredients JSON
            ingredients = r.get("ingredients", [])
            ingredients_json = json.dumps(ingredients, ensure_ascii=False)

            # Insert into recipe_content_vault — keep JSON blob for display
            cur.execute("""
                INSERT INTO recipe_content_vault
                    (recipe_id, prep_steps, ingredients_json)
                VALUES
                    (%s, %s, %s)
            """, (recipe_id, prep_steps_text, ingredients_json))

            # Insert into ingredient_catalog + recipe_ingredients
            ing_inserted = 0
            for idx, ing in enumerate(ingredients):
                ing_id = get_or_create_ingredient(cur, ing)
                if ing_id is None:
                    continue
                quantity   = ing.get("quantity", "")
                unit       = ing.get("unit", "")
                is_optional = ing.get("is_optional", False)
                cur.execute("""
                    INSERT INTO recipe_ingredients
                        (recipe_id, ingredient_id, quantity, unit, is_optional, sort_order)
                    VALUES
                        (%s, %s, %s, %s, %s, %s)
                """, (recipe_id, ing_id, quantity, unit, is_optional, idx + 1))
                ing_inserted += 1

            conn.commit()
            print(f"  ✓ Inserted: {dish_name} ({diet_type}, {intensity}) — {ing_inserted} ingredients")
            inserted += 1

        except Exception as e:
            conn.rollback()
            print(f"  ✗ Error inserting '{r.get('dish_name', '?')}': {e}")
            errors += 1

    cur.close()
    conn.close()

    print(f"\n{'='*50}")
    print(f"  Inserted : {inserted}")
    print(f"  Skipped  : {skipped}")
    print(f"  Errors   : {errors}")
    print(f"{'='*50}")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Seed recipes using Gemini AI")
    parser.add_argument("--meal",    default="breakfast", help="breakfast | lunch | dinner | snack")
    parser.add_argument("--region",  default="Tamil Nadu", help="Region name e.g. 'Tamil Nadu'")
    parser.add_argument("--count",   type=int, default=50, help="Number of recipes to generate")
    parser.add_argument("--dry-run", action="store_true", help="Print JSON only, do not insert")
    args = parser.parse_args()

    print(f"\n🌿 Momentum Recipe Seeder")
    print(f"   Meal    : {args.meal}")
    print(f"   Region  : {args.region}")
    print(f"   Count   : {args.count}")
    print(f"   Dry run : {args.dry_run}")
    print(f"   Model   : {GEMINI_MODEL}\n")

    # Split into batches of 20 to avoid token limit truncation
    # Each recipe with full ingredients is ~500 tokens — 20 recipes ≈ 10k tokens safely
    BATCH_SIZE  = 10
    total       = args.count
    all_recipes = []

    batches = [BATCH_SIZE] * (total // BATCH_SIZE)
    if total % BATCH_SIZE:
        batches.append(total % BATCH_SIZE)

    for batch_num, count in enumerate(batches, 1):
        print(f"⏳ Calling Gemini — batch {batch_num}/{len(batches)} ({count} recipes)...")
        batch_prompt = PROMPT_TEMPLATE.format(
            count=count, meal=args.meal, region=args.region
        )
        try:
            response = model.generate_content(
                batch_prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature       = 0.7,
                    max_output_tokens = 16000,
                )
            )
            raw = response.text.strip()
        except Exception as e:
            print(f"✗ Gemini API error on batch {batch_num}: {e}")
            continue

        # Strip markdown fences if Gemini adds them despite instructions
        if raw.startswith("```"):
            lines = raw.split("\n")
            raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])

        try:
            recipes = json.loads(raw)
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
    print("\n💾 Inserting into database...")
    insert_recipes(all_recipes, args, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
