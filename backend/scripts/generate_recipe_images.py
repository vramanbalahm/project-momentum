"""
generate_recipe_images.py - Generate food images for recipes using Gemini Imagen
Stores images locally in backend/recipe_images/ and updates hero_image_url in DB.

Usage:
    cd C:\\Users\\SATISH.000\\project-momentum\\backend

    # Generate images for all recipes without images
    python scripts/generate_recipe_images.py

    # Generate for a specific diet type
    python scripts/generate_recipe_images.py --diet Veg

    # Generate for a specific sub_region
    python scripts/generate_recipe_images.py --sub_region "Chettinad"

    # Generate for a specific meal slot
    python scripts/generate_recipe_images.py --meal Side Dish

    # Limit how many to generate in one run
    python scripts/generate_recipe_images.py --limit 50

    # Regenerate images even if they already exist
    python scripts/generate_recipe_images.py --force

    # Dry run - show which recipes would get images
    python scripts/generate_recipe_images.py --dry-run

Requirements:
    pip install google-genai psycopg2-binary python-dotenv pillow
"""

import argparse
import base64
import os
import sys
import time
import uuid
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent.parent / ".env")

import psycopg2
from psycopg2.extras import RealDictCursor

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
DATABASE_URL   = os.getenv("DATABASE_URL", "postgresql://postgres:admin123@localhost:5432/food_momentum_db")

if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# -- Image storage -------------------------------------------------------------

def sanitise_filename(dish_name):
    """Convert dish name to a safe filename - lowercase, spaces to underscores."""
    import re
    name = dish_name.lower().strip()
    name = re.sub(r'[^a-z0-9\s]', '', name)   # remove special chars
    name = re.sub(r'\s+', '_', name)            # spaces to underscores
    name = name[:80]                             # max 80 chars
    return name
# Images stored at: backend/recipe_images/{recipe_id}.jpg
# URL stored in DB: /recipe_images/{recipe_id}.jpg (served as static files)

IMAGE_DIR = Path(__file__).resolve().parent.parent / "recipe_images"
IMAGE_DIR.mkdir(exist_ok=True)

# -- Standard prompt template --------------------------------------------------
# Consistent style across all recipes

def build_prompt(dish_name, regional_name, sub_region, diet_type, meal_slots, ingredients=None):
    """Build a consistent food photography prompt for the recipe.
    Uses actual ingredients from DB for visual accuracy."""

    # Serving vessel by meal type
    if "Side Dish" in (meal_slots or []):
        vessel = "small traditional brass katori bowl"
    elif "Breakfast" in (meal_slots or []) and "Lunch" not in (meal_slots or []):
        vessel = "traditional South Indian breakfast plate with banana leaf"
    else:
        vessel = "traditional brass plate or banana leaf thali"

    # Regional context
    region_context = f"{sub_region} style, " if sub_region and sub_region not in ("General Tamil Nadu", "") else ""

    # Diet-specific styling
    if diet_type == "Non-Veg":
        garnish = "garnished with fresh curry leaves and red chilli"
    elif diet_type == "Eggitarian":
        garnish = "garnished with fresh coriander leaves"
    else:
        garnish = "garnished traditionally with curry leaves and a drizzle of ghee or oil"

    # Build ingredient description from top 5 non-optional ingredients
    ing_desc = ""
    if ingredients:
        top_ings = [i for i in ingredients if i][:5]
        if top_ings:
            ing_desc = f"Key ingredients: {', '.join(top_ings)}. "

    # Include Tamil name if available - helps Imagen identify the dish more accurately
    name_part = f"{dish_name} ({regional_name})" if regional_name and regional_name != dish_name else dish_name

    prompt = (
        f"{name_part}. "
        f"Authentic Tamil Nadu dish. "
        f"{ing_desc}"
        f"Professional food photography. "
        f"Served in a {vessel}. "
        f"Bright, well-lit, daylight studio lighting, high key. "
        f"Vibrant colours, crisp and clear. "
        f"Appetising presentation, garnished traditionally with curry leaves. "
        f"Clean light wooden background. "
        f"No text, no people, no hands, no watermarks."
    )
    return prompt


# -- Gemini Imagen call --------------------------------------------------------

def generate_image(prompt, recipe_id, dish_name):
    """
    Call gemini-2.5-flash-image using generateContent (free tier: 500/day).
    This model uses generateContent, not generate_images/predict.
    """
    from google import genai
    from google.genai import types

    client = genai.Client(api_key=GEMINI_API_KEY)

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash-image",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
            )
        )

        # Extract image bytes from response parts
        image_data = None
        for part in response.candidates[0].content.parts:
            if hasattr(part, "inline_data") and part.inline_data is not None:
                image_data = part.inline_data.data
                break

        if not image_data:
            print(f"    [FAIL] No image in response")
            return None

        # Save image to disk
        safe_name = sanitise_filename(dish_name)
        file_path = IMAGE_DIR / f"{safe_name}__{recipe_id[:8]}.jpg"
        with open(file_path, "wb") as f:
            f.write(image_data)

        return file_path

    except Exception as e:
        print(f"    [FAIL] Imagen API error: {e}")
        return None


def get_connection():
    return psycopg2.connect(DATABASE_URL)


def get_recipes(args):
    """Fetch recipes that need images based on filter args."""
    conn = get_connection()
    cur  = conn.cursor(cursor_factory=RealDictCursor)

    conditions = []
    params     = {}

    if args.recipe_id:
        conditions.append("r.recipe_id = %(recipe_id)s::uuid")
        params["recipe_id"] = args.recipe_id

    if not args.force:
        conditions.append("(v.hero_image_url IS NULL OR v.hero_image_url = '')")

    if args.diet:
        conditions.append("r.diet_type = %(diet)s::diet_pref")
        params["diet"] = args.diet

    if args.sub_region:
        conditions.append("r.sub_region ILIKE %(sub_region)s")
        params["sub_region"] = f"%{args.sub_region}%"

    if args.meal:
        conditions.append("%(meal)s = ANY(r.meal_slots)")
        params["meal"] = args.meal

    where = "WHERE " + " AND ".join(conditions) if conditions else ""

    limit_clause = f"LIMIT {args.limit}" if args.limit else ""

    cur.execute(f"""
        SELECT
            r.recipe_id,
            r.dish_name,
            r.regional_name,
            r.sub_region,
            r.diet_type::text as diet_type,
            r.meal_slots,
            v.hero_image_url,
            COALESCE(
                array_agg(ic.name_en ORDER BY ri.sort_order)
                FILTER (WHERE ic.name_en IS NOT NULL AND ri.is_optional = false),
                ARRAY[]::text[]
            ) as main_ingredients
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.recipe_id
        LEFT JOIN ingredient_catalog ic ON ic.id = ri.ingredient_id
        {where}
        GROUP BY r.recipe_id, r.dish_name, r.regional_name, r.sub_region,
                 r.diet_type, r.meal_slots, v.hero_image_url
        ORDER BY r.diet_type, r.sub_region, r.dish_name
        {limit_clause}
    """, params)

    recipes = cur.fetchall()
    cur.close()
    conn.close()
    return recipes


def update_image_url(recipe_id, image_url):
    """Update hero_image_url in recipe_content_vault."""
    conn = get_connection()
    cur  = conn.cursor()
    cur.execute("""
        UPDATE recipe_content_vault
        SET hero_image_url = %s
        WHERE recipe_id = CAST(%s AS uuid)
    """, (image_url, recipe_id))
    conn.commit()
    cur.close()
    conn.close()


# -- Main ----------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate food images for Momentum recipes")
    parser.add_argument("--diet",       default=None, help="Filter by diet type: Veg | Non-Veg | Vegan | Eggitarian")
    parser.add_argument("--sub_region", default=None, help="Filter by sub_region (partial match)")
    parser.add_argument("--meal",       default=None, help="Filter by meal slot: Breakfast | Lunch | Dinner | Side Dish")
    parser.add_argument("--limit",      type=int, default=None, help="Max number of images to generate in this run")
    parser.add_argument("--force",      action="store_true", help="Regenerate even if image already exists")
    parser.add_argument("--dry-run",    action="store_true", help="Show which recipes would get images, don't generate")
    parser.add_argument("--delay",      type=float, default=1.5, help="Seconds between API calls (default 1.5)")
    parser.add_argument("--recipe_id",  default=None, help="Generate image for a specific recipe_id only")
    args = parser.parse_args()

    if not GEMINI_API_KEY:
        print("[FAIL] GEMINI_API_KEY not set in .env")
        sys.exit(1)

    print(f"\n== Momentum Recipe Image Generator ==")
    print(f"   Storage  : {IMAGE_DIR}")
    if args.diet:       print(f"   Diet     : {args.diet}")
    if args.sub_region: print(f"   Region   : {args.sub_region}")
    if args.meal:       print(f"   Meal     : {args.meal}")
    if args.limit:      print(f"   Limit    : {args.limit}")
    print(f"   Force    : {args.force}")
    print(f"   Dry run  : {args.dry_run}\n")

    recipes = get_recipes(args)
    print(f"[OK] Found {len(recipes)} recipes to process\n")

    if not recipes:
        print("Nothing to do - all matching recipes already have images.")
        return

    if args.dry_run:
        for r in recipes:
            print(f"  - {r['dish_name']} ({r['diet_type']}, {r['sub_region']})")
        print(f"\n[OK] Dry run - {len(recipes)} recipes would get images.")
        return

    generated = failed = skipped = 0

    for i, recipe in enumerate(recipes, 1):
        recipe_id   = str(recipe["recipe_id"])
        dish_name   = recipe["dish_name"]
        diet_type   = recipe["diet_type"]
        sub_region  = recipe["sub_region"] or ""
        regional    = recipe["regional_name"] or dish_name
        meal_slots  = recipe["meal_slots"] or []

        print(f"[{i}/{len(recipes)}] {dish_name} ({diet_type}, {sub_region or 'General'})")

        # Check if image already exists on disk
        file_path = IMAGE_DIR / f"{sanitise_filename(dish_name)}__{recipe_id[:8]}.jpg"
        if file_path.exists() and not args.force:
            print(f"    [SKIP] Skipped - image already exists on disk")
            skipped += 1
            continue

        # Build prompt with ingredients for visual accuracy
        ingredients = list(recipe.get('main_ingredients') or [])
        prompt = build_prompt(dish_name, regional, sub_region, diet_type, meal_slots, ingredients)

        # Generate image
        saved_path = generate_image(prompt, recipe_id, dish_name)

        if saved_path:
            # Store relative URL in DB (served as static file by FastAPI)
            safe_name = sanitise_filename(dish_name)
            image_url = f"/recipe_images/{safe_name}__{recipe_id[:8]}.jpg"
            update_image_url(recipe_id, image_url)
            print(f"    [OK] Saved → {image_url}")
            generated += 1
        else:
            failed += 1

        # Rate limiting - avoid hitting API limits
        if i < len(recipes):
            time.sleep(args.delay)

    print(f"\n{'='*50}")
    print(f"  Generated : {generated}")
    print(f"  Skipped   : {skipped}")
    print(f"  Failed    : {failed}")
    print(f"  Images at : {IMAGE_DIR}")
    print(f"{'='*50}\n")


if __name__ == "__main__":
    main()
