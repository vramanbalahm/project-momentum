#!/usr/bin/env python3
"""
classify_is_optional.py — AI classification pass for recipe_ingredients.is_optional

Definition being applied (per Vijey, pantry-matching leniency concept):
    is_optional = TRUE  -> ingredient's absence from a household's pantry should
                            NOT block this dish from being suggested. Supporting
                            ingredients, spices, aromatics, common condiments,
                            salt/oil/water, garnishes, finishing touches.
    is_optional = FALSE -> a defining, core-identity ingredient. Without it,
                            this isn't really the dish anymore. Usually 1-3
                            ingredients per recipe (e.g. rice + coconut milk
                            for Thengai Paal Biryani).

Uses Vertex AI (NOT direct Gemini API / AI Studio key) so usage draws from
GCP credits, not a card. Requires:
    pip install google-genai psycopg2-binary python-dotenv --break-system-packages
    gcloud auth application-default login   (one-time, on this machine)

Usage:
    # Preview against specific dishes -- NO db writes, just prints proposed output
    python scripts/classify_is_optional.py --preview --dishes "Thengai Paal Kuzhambu,Sambar Rice,Idli,Beans Poriyal,Chicken Chettinad"

    # Preview against N auto-picked diverse recipes -- NO db writes
    python scripts/classify_is_optional.py --preview --sample 10

    # Apply to a specific dish only (after preview looks right)
    python scripts/classify_is_optional.py --apply --dishes "Sambar Rice"

    # Apply to ALL approved recipes -- the real run, only after preview sign-off
    python scripts/classify_is_optional.py --apply --all
"""

import argparse
import json
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

try:
    import psycopg2
    import psycopg2.extras
    from google import genai
except ImportError:
    os.system("pip install google-genai psycopg2-binary python-dotenv --break-system-packages -q")
    import psycopg2
    import psycopg2.extras
    from google import genai

# ── Config ───────────────────────────────────────────────────────────────────
DATABASE_URL   = os.getenv("DATABASE_URL", "postgresql://postgres:admin123@localhost:5432/food_momentum_db")
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

GCP_PROJECT  = os.getenv("GOOGLE_CLOUD_PROJECT", "project-momentum-495709")
GCP_LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
MODEL_NAME   = os.getenv("VERTEX_CLASSIFY_MODEL", "gemini-2.5-flash-lite")

# Vertex AI pricing per 1M tokens (input, output) -- checked against
# cloud.google.com/vertex-ai/generative-ai/pricing. Update if pricing changes.
PRICING_PER_MILLION = {
    "gemini-2.5-flash-lite": (0.10, 0.40),
    "gemini-2.5-flash":      (0.30, 2.50),
    "gemini-2.5-pro":        (1.25, 10.00),
}

class CostTracker:
    """Tracks real token usage + cost across a run, using the actual numbers
    Vertex AI reports back per call -- not an estimate."""
    def __init__(self, model_name):
        self.model_name = model_name
        self.price_in, self.price_out = PRICING_PER_MILLION.get(
            model_name, PRICING_PER_MILLION["gemini-2.5-flash-lite"]
        )
        self.total_input_tokens = 0
        self.total_output_tokens = 0
        self.call_count = 0

    def record(self, input_tokens, output_tokens):
        self.total_input_tokens += input_tokens
        self.total_output_tokens += output_tokens
        self.call_count += 1
        call_cost = (input_tokens / 1_000_000 * self.price_in) + (output_tokens / 1_000_000 * self.price_out)
        running_cost = self.running_total()
        print(f"    tokens: in={input_tokens} out={output_tokens} | this call: ${call_cost:.5f} | running total: ${running_cost:.5f}")
        return call_cost

    def running_total(self):
        return (self.total_input_tokens / 1_000_000 * self.price_in) + \
               (self.total_output_tokens / 1_000_000 * self.price_out)

    def summary(self):
        print(f"\n{'='*70}")
        print(f"COST SUMMARY ({self.model_name})")
        print(f"  Calls made:      {self.call_count}")
        print(f"  Input tokens:    {self.total_input_tokens:,}")
        print(f"  Output tokens:   {self.total_output_tokens:,}")
        print(f"  TOTAL COST:      ${self.running_total():.4f}")
        print(f"{'='*70}")

# Vertex AI mode -- vertexai=True + project/location + ADC. NOT an api_key.
# Billing draws from the GCP project's credits, not a personal card.
client = genai.Client(vertexai=True, project=GCP_PROJECT, location=GCP_LOCATION)
cost_tracker = CostTracker(MODEL_NAME)

# ── Prompt ───────────────────────────────────────────────────────────────────
PROMPT_TEMPLATE = """You are a Tamil Nadu home cooking expert helping classify recipe ingredients.

DEFINITION:
For each ingredient, decide if it is "core" or "optional" using this exact test:
    - CORE (is_optional=false): a defining, identity ingredient. If you removed
      it, this would no longer really be the same dish. Usually only 1-3
      ingredients per recipe fall into this category -- the ones that give the
      dish its name and character.
    - OPTIONAL (is_optional=true): everything else. This includes common
      aromatics (onion, garlic, ginger, tomato), spices and tempering
      ingredients, salt, oil, water, garnishes, and finishing touches -- even
      if a recipe "needs" them for good flavor, a household missing them
      should NOT be blocked from getting this dish suggested.

WORKED EXAMPLE 1 (already confirmed correct by the product owner):
    Dish: Thengai Paal Biryani (a coconut-milk biryani)
    CORE: Basmati rice, Coconut milk
    OPTIONAL: everything else -- Bay Leaf, Cardamom pods, Cinnamon stick,
        Cloves, Coriander leaves, Garlic, Ginger, Green chilies, Mint Leaves,
        Onion, Salt, Tomato, Vegetable Oil
    Reasoning: rice + coconut milk are what make this dish *this* dish and
    distinguish it from a plain biryani. Every other ingredient -- even onion,
    garlic, and salt -- is common enough that its absence shouldn't block the
    suggestion.

NAMED-VARIANT RULE: if the dish name itself calls out a specific protein or
ingredient (e.g. "Egg Kothu Parotta", "Mutton Kothu Parotta", "Chicken
Biryani"), that named ingredient joins the base as CORE alongside it. If the
dish name is plain/generic with no protein called out (e.g. plain "Kothu
Parotta"), only the base itself is CORE -- even if a protein happens to appear
in that recipe's ingredient list. The protein becomes OPTIONAL in that case.

WORKED EXAMPLE 2 (named-variant rule, confirmed by product owner):
    - "Kothu Parotta" (plain, no protein in the name):
        CORE: Parotta only. Any egg/chicken/mutton present in the ingredient
        list is OPTIONAL, not core -- the dish name doesn't call it out.
    - "Egg Kothu Parotta":
        CORE: Parotta, Egg
    - "Mutton Kothu Parotta":
        CORE: Parotta, Mutton

GENERIC-CATEGORY RULE: if the dish name uses a generic category word instead
of one specific vegetable/ingredient (e.g. "Vegetable Sandwich", "Vegetable
Kurma"), do NOT pick any single vegetable as core just because it's in the
list -- no specific vegetable is more defining than another here, so they all
stay OPTIONAL. This keeps the dish qualifying for suggestion even if a
household is missing any one particular vegetable.

WORKED EXAMPLE 3 (generic-category rule, confirmed by product owner):
    Dish: Vegetable Sandwich
    CORE: Bread only
    OPTIONAL: Tomato, Cucumber, Onion, Butter, Green Chilli, Salt -- no single
        vegetable is treated as defining since the dish name says "Vegetable"
        generically, not one specific vegetable.

Now classify the following recipe's ingredients using the same standard.

Dish: {dish_name}
Category: {dish_category}
Diet type: {diet_type}
Ingredients:
{ingredient_list}

Return ONLY a JSON array, no markdown fences, no preamble. One object per
ingredient in the exact order given, each with:
    {{"ingredient_id": <int>, "ingredient_name": "<name>", "is_optional": <true|false>, "reason": "<one short phrase>"}}
"""


def get_conn():
    return psycopg2.connect(DATABASE_URL)


def fetch_recipe_ingredients(cur, dish_name_pattern=None, recipe_id=None):
    """Fetch one recipe (by exact-ish name or id) with its ingredient list.
    Always fetches regardless of prior classification -- used for explicit
    --dishes targeting, where re-checking a specific dish is intentional."""
    if recipe_id:
        cur.execute("""
            SELECT recipe_id, dish_name, dish_category, diet_type::text, is_optional_classified_at
            FROM recipe_dna_master WHERE recipe_id = %s
        """, (recipe_id,))
        recipe = cur.fetchone()
    else:
        # Exact match first (case-insensitive) -- avoids "Kothu Parotta" search
        # accidentally matching "Egg Kothu Parotta" via substring + alphabetical
        # ORDER BY LIMIT 1. Only fall back to substring if no exact match exists.
        cur.execute("""
            SELECT recipe_id, dish_name, dish_category, diet_type::text, is_optional_classified_at
            FROM recipe_dna_master
            WHERE dish_name ILIKE %s AND review_status = 'approved'
            LIMIT 1
        """, (dish_name_pattern,))
        recipe = cur.fetchone()
        if not recipe:
            cur.execute("""
                SELECT recipe_id, dish_name, dish_category, diet_type::text, is_optional_classified_at
                FROM recipe_dna_master
                WHERE dish_name ILIKE %s AND review_status = 'approved'
                ORDER BY dish_name LIMIT 1
            """, (f"%{dish_name_pattern}%",))
            recipe = cur.fetchone()
    if not recipe:
        return None, []

    if recipe[4] is not None:
        print(f"  NOTE: '{recipe[1]}' was already classified on {recipe[4]} -- processing again since it was explicitly requested.")

    cur.execute("""
        SELECT ri.ingredient_id, ic.name_en, ri.quantity, ri.unit
        FROM recipe_ingredients ri
        JOIN ingredient_catalog ic ON ic.id = ri.ingredient_id
        WHERE ri.recipe_id = %s
        ORDER BY ri.sort_order, ic.name_en
    """, (recipe[0],))
    ingredients = cur.fetchall()
    return recipe, ingredients


def pick_diverse_sample(cur, n, force=False):
    """Auto-pick n recipes spread across distinct dish_category/diet_type combos.
    Skips already-classified recipes by default so re-runs don't reprocess
    (and re-bill) recipes that are already done."""
    skip_clause = "" if force else "AND is_optional_classified_at IS NULL"
    cur.execute(f"""
        SELECT DISTINCT ON (dish_category, diet_type) recipe_id, dish_name, dish_category, diet_type::text
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        {skip_clause}
        ORDER BY dish_category, diet_type, RANDOM()
        LIMIT %s
    """, (n,))
    return cur.fetchall()


def classify_recipe(recipe, ingredients):
    dish_name, dish_category, diet_type = recipe[1], recipe[2], recipe[3]
    ingredient_list = "\n".join(
        f"  - id={i[0]}: {i[1]} ({i[2] or ''} {i[3] or ''})".strip()
        for i in ingredients
    )
    prompt = PROMPT_TEMPLATE.format(
        dish_name=dish_name,
        dish_category=dish_category or "unspecified",
        diet_type=diet_type or "unspecified",
        ingredient_list=ingredient_list,
    )
    response = client.models.generate_content(model=MODEL_NAME, contents=prompt)

    # Real token counts from Vertex AI's response -- not an estimate.
    usage = getattr(response, "usage_metadata", None)
    if usage:
        input_tokens = getattr(usage, "prompt_token_count", 0) or 0
        output_tokens = getattr(usage, "candidates_token_count", 0) or 0
        cost_tracker.record(input_tokens, output_tokens)
    else:
        print("    (no usage_metadata returned -- cost tracking unavailable for this call)")

    text = response.text.strip()
    # Strip accidental markdown fences if the model adds them anyway
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    return json.loads(text.strip())


def print_preview(dish_name, classifications):
    print(f"\n{'='*70}\n{dish_name}\n{'='*70}")
    core = [c for c in classifications if not c["is_optional"]]
    optional = [c for c in classifications if c["is_optional"]]
    print(f"  CORE ({len(core)}):")
    for c in core:
        print(f"    - {c['ingredient_name']:30s} | {c['reason']}")
    print(f"  OPTIONAL ({len(optional)}):")
    for c in optional:
        print(f"    - {c['ingredient_name']:30s} | {c['reason']}")


def apply_classifications(cur, recipe_id, classifications, valid_ingredient_ids):
    updated = 0
    skipped = 0
    for c in classifications:
        raw_id = c.get("ingredient_id")
        try:
            ingredient_id = int(raw_id)
        except (TypeError, ValueError):
            print(f"    SKIPPED bad entry (ingredient_id={raw_id!r}, name={c.get('ingredient_name')!r}) -- not a valid integer id")
            skipped += 1
            continue
        if ingredient_id not in valid_ingredient_ids:
            print(f"    SKIPPED entry (ingredient_id={ingredient_id}, name={c.get('ingredient_name')!r}) -- not one of this recipe's actual ingredients")
            skipped += 1
            continue
        cur.execute("""
            UPDATE recipe_ingredients
            SET is_optional = %s
            WHERE recipe_id = %s AND ingredient_id = %s
        """, (c["is_optional"], recipe_id, ingredient_id))
        updated += cur.rowcount
    # Mark this recipe as classified so future --all/--sample runs skip it.
    cur.execute("""
        UPDATE recipe_dna_master SET is_optional_classified_at = NOW()
        WHERE recipe_id = %s
    """, (recipe_id,))
    return updated, skipped


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--preview", action="store_true", help="Print proposed classifications, no DB writes")
    parser.add_argument("--apply", action="store_true", help="Write classifications to DB")
    parser.add_argument("--dishes", default=None, help="Comma-separated dish names (partial match ok)")
    parser.add_argument("--sample", type=int, default=None, help="Auto-pick N diverse recipes")
    parser.add_argument("--all", action="store_true", help="Run against ALL approved recipes (real run)")
    parser.add_argument("--max-cost", type=float, default=None, help="Abort the run if running total exceeds this dollar amount")
    parser.add_argument("--force", action="store_true", help="Include already-classified recipes in --sample/--all (normally skipped)")
    args = parser.parse_args()

    if not args.preview and not args.apply:
        print("ERROR: specify --preview or --apply")
        sys.exit(1)
    if not args.dishes and not args.sample and not args.all:
        print("ERROR: specify --dishes, --sample N, or --all")
        sys.exit(1)

    conn = get_conn()
    cur = conn.cursor()

    targets = []  # list of (recipe_row, ingredients)

    if args.dishes:
        for name in [d.strip() for d in args.dishes.split(",")]:
            try:
                recipe, ingredients = fetch_recipe_ingredients(cur, dish_name_pattern=name)
            except Exception as e:
                conn.rollback()
                print(f"  ERROR fetching '{name}': {e} -- skipped")
                continue
            if not recipe:
                print(f"  WARNING: no approved recipe matching '{name}' -- skipped")
                continue
            targets.append((recipe, ingredients))
    elif args.sample:
        try:
            sample_rows = pick_diverse_sample(cur, args.sample, force=args.force)
        except Exception as e:
            conn.rollback()
            print(f"FATAL: could not build sample set: {e}")
            sys.exit(1)
        for row in sample_rows:
            try:
                recipe, ingredients = fetch_recipe_ingredients(cur, recipe_id=row[0])
                targets.append((recipe, ingredients))
            except Exception as e:
                conn.rollback()
                print(f"  ERROR fetching recipe_id {row[0]}: {e} -- skipped")
    elif args.all:
        skip_clause = "" if args.force else "AND is_optional_classified_at IS NULL"
        cur.execute(f"SELECT recipe_id FROM recipe_dna_master WHERE review_status = 'approved' {skip_clause}")
        all_ids = [r[0] for r in cur.fetchall()]
        already_done = 0
        if not args.force:
            cur.execute("SELECT COUNT(*) FROM recipe_dna_master WHERE review_status = 'approved' AND is_optional_classified_at IS NOT NULL")
            already_done = cur.fetchone()[0]
        print(f"Running against {len(all_ids)} approved recipes not yet classified" +
              (f" ({already_done} already classified, skipped -- use --force to reprocess)." if already_done else "."))
        for rid in all_ids:
            try:
                recipe, ingredients = fetch_recipe_ingredients(cur, recipe_id=rid)
                targets.append((recipe, ingredients))
            except Exception as e:
                conn.rollback()
                print(f"  ERROR fetching recipe_id {rid}: {e} -- skipped")

    print(f"\n{len(targets)} recipe(s) to process.\n")

    total_updated = 0
    total_skipped = 0
    total_errors = 0
    for recipe, ingredients in targets:
        if args.max_cost is not None and cost_tracker.running_total() >= args.max_cost:
            print(f"\nSTOPPED: running cost ${cost_tracker.running_total():.4f} reached --max-cost ${args.max_cost:.4f} cap.")
            print(f"Everything applied above this line is already committed and safe.")
            print(f"Just re-run the same command to continue -- already-classified recipes are")
            print(f"automatically skipped, so you'll only pay for what's left.")
            break

        if not ingredients:
            print(f"  SKIP {recipe[1]} -- no ingredients found")
            continue

        # Single wide net around the entire per-recipe body -- classify, apply,
        # and commit. Nothing here should be able to kill the whole 723-recipe
        # run; a failure on one recipe rolls back just that recipe and moves on.
        try:
            classifications = classify_recipe(recipe, ingredients)

            if args.preview:
                print_preview(recipe[1], classifications)
            else:
                valid_ingredient_ids = {i[0] for i in ingredients}
                n, skipped = apply_classifications(cur, recipe[0], classifications, valid_ingredient_ids)
                conn.commit()  # commit per-recipe -- a later failure can't undo work already done
                total_updated += n
                total_skipped += skipped
                print(f"  Applied {n} updates -> {recipe[1]}" + (f" ({skipped} entries skipped)" if skipped else ""))
        except Exception as e:
            conn.rollback()
            total_errors += 1
            print(f"  ERROR on {recipe[1]}: {e} -- rolled back this recipe, continuing")

    if args.apply:
        print(f"\nTotal ingredient rows updated: {total_updated}" +
              (f" ({total_skipped} entries skipped as invalid)" if total_skipped else "") +
              (f" ({total_errors} recipes errored and were skipped entirely)" if total_errors else ""))
    else:
        print("\n(Preview only -- no DB changes made.)")

    cost_tracker.summary()

    cur.close()
    conn.close()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nInterrupted by user.")
        cost_tracker.summary()
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFATAL (unrecoverable): {e}")
        print("Everything applied before this point was committed per-recipe and is safe --")
        print("nothing is lost. Just re-run the same command; already-classified recipes")
        print("are skipped automatically, so you'll only pay for what's left.")
        cost_tracker.summary()
        raise
