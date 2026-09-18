"""
generate_ingredient_images.py - Generate clear, recognizable ingredient
photos using Segmind's free-tier Stable Diffusion API (SDXL).

Stores images locally in backend/ingredient_images/ and updates
image_url in ingredient_catalog -- same pattern already established by
generate_recipe_images.py, just a different table/folder and a
different (free) image provider.

Why Segmind instead of the existing Gemini pipeline: confirmed all 307
ingredients have zero images. Gemini Imagen (used for recipe images)
costs ~$0.039/image -- affordable in absolute terms, but Vijey wants a
genuinely free option given the volume. Checked Groq (no image
generation at all) and local Stable Diffusion (ruled out -- his primary
machine's 8GB RAM / GeForce 840M can't realistically run it). Segmind's
free tier -- 100 calls/day per account, confirmed from their own docs
-- covers this with zero cost and zero hardware dependency.

Uses TWO API keys (Vijey has two free accounts) to roughly double daily
throughput and finish faster. Each key's own 100/day limit is tracked
independently; the script stops a key once it's near that limit and
switches to the other, stopping entirely once both are exhausted for
the day. Safe to re-run on subsequent days -- already-imaged
ingredients are skipped automatically.

Usage:
    pip install requests psycopg2-binary python-dotenv

    # Preview what would happen, generate nothing
    python generate_ingredient_images.py --db postgresql://postgres@localhost/food_momentum_db --key1 gsk_... --key2 gsk_... --preview

    # Real run -- pick up wherever the daily quota left off last time
    python generate_ingredient_images.py --db postgresql://postgres@localhost/food_momentum_db --key1 gsk_... --key2 gsk_...
"""

import argparse
import os
import time
from pathlib import Path

import requests

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
parser.add_argument("--key1", required=True, help="First Segmind API key")
parser.add_argument("--key2", required=True, help="Second Segmind API key")
parser.add_argument("--preview", action="store_true", help="Show what would be generated, write nothing")
parser.add_argument("--limit", type=int, default=0, help="Process only N ingredients (0=all remaining today)")
args = parser.parse_args()

# Conservative -- stop each key a little before the real 100/day limit,
# in case some of today's quota was already used outside this script.
DAILY_SAFETY_CAP = 90
# Segmind's free tier allows 5 requests/minute -- pace comfortably under that.
SECONDS_BETWEEN_CALLS = 13

IMAGE_DIR = Path(__file__).resolve().parent.parent / "ingredient_images"
IMAGE_DIR.mkdir(exist_ok=True)

SEGMIND_URL = "https://api.segmind.com/v1/sdxl1.0-txt2img"


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def build_prompt(name_en, category):
    """A single, clearly-recognizable ingredient on a plain background --
    no scene, no other objects, no text -- since the whole point is
    something anyone can identify by sight alone, regardless of
    language (per Vijey's explicit requirement)."""
    prompt = (
        f"A single {name_en}, whole and fresh, isolated on a plain white background, "
        f"professional product photography, studio lighting, sharp focus, high detail, "
        f"centered composition, no other objects"
    )
    negative_prompt = (
        "blurry, multiple items, cluttered background, text, watermark, logo, "
        "low quality, cartoon, illustration, plate, bowl, hands, people"
    )
    return prompt, negative_prompt


def generate_image(api_key, name_en, category):
    prompt, negative_prompt = build_prompt(name_en, category)
    response = requests.post(
        SEGMIND_URL,
        json={
            "prompt": prompt,
            "negative_prompt": negative_prompt,
            "samples": 1,
            "scheduler": "UniPC",
            "num_inference_steps": 25,
            "guidance_scale": 7.5,
            "seed": 42,
            "img_width": 512,
            "img_height": 512,
            "base64": False,
        },
        headers={"x-api-key": api_key},
        timeout=60,
    )
    return response


def safe_filename(name_en, ingredient_id):
    safe_name = "".join(c if c.isalnum() else "_" for c in name_en.lower())[:40]
    return f"{safe_name}__{ingredient_id}.jpg"


def main():
    conn = get_conn()
    cur = conn.cursor()

    print(f"\n{'='*60}")
    print(f"Ingredient Image Generator (Segmind SDXL, free tier)")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    print(f"{'='*60}\n")

    cur.execute("""
        SELECT id, name_en, category
        FROM ingredient_catalog
        WHERE image_url IS NULL OR image_url = ''
        ORDER BY category, name_en
    """)
    ingredients = cur.fetchall()
    print(f"Ingredients still needing images: {len(ingredients)}\n")

    keys = [args.key1, args.key2]
    key_counts = {0: 0, 1: 0}
    current_key = 0
    generated = 0
    failed = 0

    for ing_id, name_en, category in ingredients:
        if args.limit and generated >= args.limit:
            print(f"\n[LIMIT] Stopped after {args.limit}.")
            break

        # Switch keys once the current one hits today's safety cap
        if key_counts[current_key] >= DAILY_SAFETY_CAP:
            current_key = 1 - current_key
            if key_counts[current_key] >= DAILY_SAFETY_CAP:
                print(f"\nBoth keys have reached today's safe limit ({DAILY_SAFETY_CAP} each). "
                      f"Stopping here -- re-run tomorrow to continue.")
                break

        api_key = keys[current_key]
        print(f"[{generated+failed+1}/{len(ingredients)}] {name_en} ({category}) -- key {current_key+1}")

        if args.preview:
            print(f"  Would generate and save to ingredient_images/{safe_filename(name_en, ing_id)}")
            generated += 1
            key_counts[current_key] += 1
            continue

        try:
            response = generate_image(api_key, name_en, category)
        except Exception as e:
            print(f"  UNEXPECTED ERROR: {type(e).__name__}: {e} -- skipping")
            failed += 1
            time.sleep(SECONDS_BETWEEN_CALLS)
            continue

        if response.status_code == 429:
            print(f"  Rate limited on key {current_key+1} -- switching keys")
            current_key = 1 - current_key
            time.sleep(2)
            continue

        if response.status_code != 200:
            print(f"  ERROR {response.status_code}: {response.text[:200]}")
            failed += 1
            key_counts[current_key] += 1  # still counts against today's quota
            time.sleep(SECONDS_BETWEEN_CALLS)
            continue

        filename = safe_filename(name_en, ing_id)
        filepath = IMAGE_DIR / filename
        with open(filepath, "wb") as f:
            f.write(response.content)

        image_url = f"/ingredient_images/{filename}"
        cur.execute("""
            UPDATE ingredient_catalog
            SET image_url = %s, thumb_url = %s
            WHERE id = %s
        """, (image_url, image_url, ing_id))
        conn.commit()

        print(f"  Saved -> {image_url}")
        generated += 1
        key_counts[current_key] += 1
        time.sleep(SECONDS_BETWEEN_CALLS)

    print(f"\n{'='*60}")
    print(f"Summary: {generated} generated, {failed} failed")
    print(f"Key 1 used: {key_counts[0]} / ~{DAILY_SAFETY_CAP}")
    print(f"Key 2 used: {key_counts[1]} / ~{DAILY_SAFETY_CAP}")
    remaining = len(ingredients) - generated - failed
    if remaining > 0:
        print(f"Remaining: {remaining} -- re-run tomorrow (or once quota resets) to continue")
    print(f"{'='*60}\n")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
