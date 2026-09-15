#!/usr/bin/env python3
"""
seed_recipe_pairings_groq.py
Asks GPT-OSS-120B (via Groq) for traditional Tamil Nadu side dishes for
each main dish, purely from its own culinary knowledge -- the model is
NOT shown our existing vault or any compatibility matrix, so it can't be
constrained or biased by gaps or narrowness already present in our data.

Reconciliation against our existing data happens entirely on our side,
with no AI involved in this part (see find_or_create_side()):
  - If the model's suggested side matches something we already have
    (exact, case-insensitive, or fuzzy match), the pairing links to that
    existing dish.
  - If it doesn't match anything we have, it's inserted as a genuinely
    new recipe_dna_master row (review_status='under_review', so it lands
    in the existing Recipe Review queue for curation rather than going
    live immediately) and the pairing links to that new row.
  - diet_type for a new dish is guessed from keywords in its name
    (chicken/mutton/fish/etc. -> Non-Veg, egg -> Eggitarian, else Veg) --
    not defaulted to Veg unconditionally, since a real non-veg dish
    mislabeled Veg could get served to a vegetarian household before
    anyone reviews it.

Earlier design iteration (kept for reference, not what's implemented
now): pre-filtering which sides the model could choose from, either via
a dish_pairing_matrix compatibility lookup or by showing it our full
vault list to match against. Both were dropped -- pre-filtering by a
possibly-flawed compatibility matrix produced a narrow, repetitive pool
(confirmed: multiple unrelated main dishes all defaulting to the same
handful of "avarekai" sides), and showing the model our vault list still
let its answers be shaped by whatever's already there rather than
genuine independent judgment.

Robustness fixes found while validating against real batch runs:
1. already_done check was 'WHERE source IN (ai_seeded, matrix_seeded,
   seeded)' -- since ~97.8% of dishes already have crude matrix_seeded
   rows, this made the script skip almost everything on a fresh run.
   Now only 'ai_seeded' counts as done. The recommendation engine
   already correctly prioritizes ai_seeded over matrix_seeded when both
   exist (confirmed in recommend_sides()'s ORDER BY), so old crude rows
   don't need deleting -- they just stop being selected once real ones
   exist alongside them.
2. Per-dish deduplication of the model's suggested sides by name
   (case-insensitive) before counting/inserting -- a model response
   listing the same side twice within one dish's suggestions silently
   shrinks the intended count down to fewer genuinely distinct options.
3. The model doesn't always follow the requested JSON shape for every
   item (a plain string instead of {"name":...,"confidence":...} showed
   up mid-run) -- normalized defensively rather than assumed.
4. Entire per-dish processing wrapped in try/except so one unexpected
   failure doesn't halt the whole batch and lose progress already made.
5. --meal-slot filter (e.g. --meal-slot Breakfast) added alongside the
   existing --category filter, since "Breakfast" is a meal_slots value,
   not a dish_category value in this schema.

Usage:
    python seed_recipe_pairings_groq.py --db postgresql://postgres@localhost/food_momentum_db --preview
    python seed_recipe_pairings_groq.py --db postgresql://postgres@localhost/food_momentum_db --meal-slot Breakfast --limit 10
    python seed_recipe_pairings_groq.py --db ... --meal-slot Breakfast   # full breakfast run
"""

import argparse
import json
import os
import re
import time
from datetime import datetime
from dotenv import load_dotenv

# Load .env from backend folder
load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")

parser = argparse.ArgumentParser()
parser.add_argument("--db",        required=True)
parser.add_argument("--preview",   action="store_true")
parser.add_argument("--limit",     type=int, default=0, help="Process only N dishes (0=all). Free check before full run.")
parser.add_argument("--category",  default=None, help="tiffin|rice|bread|millet|continental — dish_category filter")
parser.add_argument("--meal-slot", default=None, help="Breakfast|Lunch|Dinner — meal_slots filter (separate column from dish_category)")
parser.add_argument("--new_sides", default=None, help="Comma-separated new side dish names — only process mains missing these sides")
args = parser.parse_args()


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def call_groq(main_dish, main_category, num_sides=5):
    """Ask GPT-OSS-120B (via Groq) for traditional side dishes for a main
    dish -- purely from the model's own knowledge, with NO list of our
    existing vault sides shown to it at all. Reconciling the model's
    answer against what we already have (and adding genuinely new sides)
    happens entirely on our side afterward, in find_or_create_side()."""

    prompt = f"""You are a Tamil Nadu cuisine expert, with deep knowledge across the full breadth of Tamil Nadu food culture -- home cooking (Brahmin and non-Brahmin households alike), regional specialties, and popular Tamil Nadu street food.

Main dish: {main_dish} (category: {main_category})

Give exactly {num_sides} traditional side dishes/accompaniments that genuinely and authentically pair with this main dish in Tamil Nadu, ordered from most to least traditional/common.

Rules:
- Judge this dish within its own genuine context -- if it's a home-cooked dish, use home-cooking pairing tradition; if it's a well-established Tamil Nadu street food (e.g. Kothu Parotta), use its own genuine, real-world traditional pairings (e.g. what it's actually served with at a real Tamil Nadu roadside stall or restaurant) rather than judging it by a different tradition it was never part of. Do not restrict yourself to any particular list -- name whatever is truly the best traditional pairing, even if it's a less common dish.
- At most 2 of your {num_sides} sides may be common staples that would also suit many other dishes (e.g. sambar, coconut chutney). The rest must be genuinely specific to this exact dish's own texture and flavor -- not defaulted from a generic pool.
- If this dish is genuinely, universally eaten plain in Tamil Nadu (e.g. a Western cereal item like corn flakes, which has no traditional Indian side at all), say so honestly in the reasoning rather than forcing pairings that don't reflect real practice. This should be rare -- most Tamil Nadu dishes, including street food, DO have real traditional pairings; do not use "not eaten with sides" as a way to avoid answering for a dish just because it's outside home-cooking tradition specifically.
- A side must be an actual dish/preparation -- not a plain condiment or garnish like ghee or salt.
- Be precise about what the main dish actually is -- do not mischaracterize its nature (texture, whether it's a rice preparation vs. a batter-based item vs. a legume dish, etc.) when reasoning about what pairs with it.

Return ONLY valid JSON, no explanation, no markdown:
{{"sides":[{{"name":"dish name","confidence":0.9,"reason":"one line"}}],"overall_reasoning":"one line"}}"""

    import requests
    if not GROQ_API_KEY:
        print("  ERROR: GROQ_API_KEY not set in backend/.env")
        return None

    # Groq's free tier for this model caps at 8000 tokens/minute -- a
    # single call with max_tokens=6000 can consume most of that budget
    # on its own, so hitting a 429 is expected under real batch use, not
    # exceptional. Groq returns a 'retry-after' header (seconds) on 429
    # responses specifically -- wait exactly that long (plus a small
    # safety buffer) and retry, rather than giving up on the dish.
    max_retries = 4
    for attempt in range(max_retries + 1):
        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": "openai/gpt-oss-120b",
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.4,
                "max_tokens": 6000,  # reasoning model -- lower values risk it spending the whole budget on hidden reasoning and returning empty visible output (confirmed: "Kothu Parotta" got 0 sides at max_tokens=1500)
                "reasoning_effort": "low"
            },
            timeout=45
        )

        if response.status_code == 429:
            if attempt >= max_retries:
                print(f"  ERROR: still rate-limited after {max_retries} retries, giving up on this dish")
                return None
            wait_s = int(response.headers.get("retry-after", 15)) + 2
            print(f"  Rate limited -- waiting {wait_s}s (attempt {attempt+1}/{max_retries})...")
            time.sleep(wait_s)
            continue

        break

    if response.status_code != 200:
        print(f"  ERROR {response.status_code}: {response.text[:200]}")
        return None

    content = response.json()["choices"][0]["message"]["content"]
    try:
        content = content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        return json.loads(content.strip())
    except Exception as e:
        print(f"  Parse error: {e}\n  Response: {content[:200]}")
        return None


# Keyword-based diet_type inference for newly-created side dishes. Not
# perfect -- it's a starting guess for the reviewer to correct, not a
# final answer -- but defaulting everything to 'Veg' would be actively
# wrong for a name like "Chicken Kurma" and could get a real non-veg
# dish incorrectly served to a vegetarian household before anyone
# reviews it. Checked in order: non-veg keywords first (most specific/
# highest-stakes to get right), then egg, else Veg.
NON_VEG_KEYWORDS = [
    "chicken", "mutton", "lamb", "goat", "beef", "pork", "fish", "prawn",
    "shrimp", "crab", "meat", "keema", "kola urundai"
]
EGG_KEYWORDS = ["egg"]

def infer_diet_type(dish_name):
    """Word-boundary matching, not raw substring -- a naive 'kw in name'
    check incorrectly matched 'lamb' inside 'Kulambu' (the extremely
    common Tamil word for gravy/stew, appearing in dozens of genuinely
    vegetarian dish names like Vatha Kulambu, Puli Kulambu, Kara
    Kulambu), which would have systematically mislabeled every one of
    them as Non-Veg. Confirmed and fixed after finding this in a real
    batch run's output."""
    name_lower = dish_name.lower()
    if any(re.search(r'\b' + re.escape(kw) + r'\b', name_lower) for kw in NON_VEG_KEYWORDS):
        return "Non-Veg"
    if any(re.search(r'\b' + re.escape(kw) + r'\b', name_lower) for kw in EGG_KEYWORDS):
        return "Eggitarian"
    return "Veg"


def find_or_create_side(cur, side_name, side_name_to_id, created_this_run):
    """Reconcile one AI-suggested side name against what we already have.

    Checks, in order: sides already in the vault at the start of this run
    (exact, then case-insensitive, then fuzzy substring match) -- then
    sides created earlier in THIS SAME run (so if the same new side is
    suggested for multiple different mains in one execution, it's reused
    rather than inserted again as a duplicate row).

    If truly not found anywhere, inserts it as a new recipe_dna_master
    row with review_status='under_review' -- lands in the existing
    Recipe Review queue for curation, not treated as production-ready
    immediately. Returns (recipe_id, was_newly_created).
    """
    side_name = side_name.strip()
    if not side_name:
        return None, False

    # 1. Exact match against pre-existing vault sides
    side_id = side_name_to_id.get(side_name)
    if side_id:
        return side_id, False

    # 2. Case-insensitive match against pre-existing vault sides
    for sn, sid in side_name_to_id.items():
        if sn.lower() == side_name.lower():
            return sid, False

    # 3. Already created earlier in this same run
    for sn, sid in created_this_run.items():
        if sn.lower() == side_name.lower():
            return sid, False

    # 4. Fuzzy substring match against pre-existing vault sides
    for sn, sid in side_name_to_id.items():
        if side_name.lower() in sn.lower() or sn.lower() in side_name.lower():
            return sid, False

    # 5. Genuinely new -- create it
    import uuid
    new_id = str(uuid.uuid4())
    diet_type = infer_diet_type(side_name)
    cur.execute("""
        INSERT INTO recipe_dna_master
            (recipe_id, dish_name, diet_type, meal_role, review_status, created_by_ai)
        VALUES
            (CAST(%s AS uuid), %s, CAST(%s AS diet_pref), ARRAY['side']::text[], 'under_review', true)
    """, (new_id, side_name, diet_type))
    created_this_run[side_name] = new_id
    return new_id, True


def dedupe_matched(matched):
    """Collapse case-insensitive duplicate side names within one dish's
    suggestions, keeping the highest-confidence occurrence of each.

    Defensive: the model doesn't always return the requested
    {"name":..., "confidence":..., "reason":...} shape for every item --
    sometimes it returns a plain string instead. Normalize both shapes
    before dedup so downstream code can always assume a dict."""
    normalized = []
    for m in matched:
        if isinstance(m, str):
            normalized.append({"name": m, "confidence": 0.80, "reason": ""})
        elif isinstance(m, dict):
            normalized.append(m)
        # silently skip anything else unparseable (e.g. null, a number)

    seen = {}
    for m in normalized:
        key = m.get("name", "").strip().lower()
        if not key:
            continue
        if key not in seen or m.get("confidence", 0) > seen[key].get("confidence", 0):
            seen[key] = m
    return list(seen.values())


def main():
    conn = get_conn()
    cur = conn.cursor()

    print(f"\n{'='*60}")
    print(f"Groq-Powered Recipe Pairing Seeder (openai/gpt-oss-120b)")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    if args.category:
        print(f"Category: {args.category}")
    if args.meal_slot:
        print(f"Meal slot: {args.meal_slot}")
    print(f"{'='*60}\n")

    query = """
        SELECT recipe_id, dish_name, dish_category
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        AND meal_role @> ARRAY['main']::text[]
        AND dish_category IS NOT NULL
    """
    params = []
    if args.category:
        query += " AND dish_category = %s"
        params.append(args.category)
    if args.meal_slot:
        query += " AND meal_slots @> ARRAY[%s]::text[]"
        params.append(args.meal_slot)
    query += " ORDER BY dish_category, dish_name"

    cur.execute(query, params)
    mains = cur.fetchall()
    print(f"Main dishes to process: {len(mains)}\n")

    cur.execute("""
        SELECT recipe_id, dish_name, dish_category
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        AND meal_role @> ARRAY['side']::text[]
        ORDER BY dish_name
    """)
    sides = cur.fetchall()
    side_name_to_id = {row[1]: row[0] for row in sides}
    print(f"Available sides for matching: {len(sides)}\n")

    total_inserted     = 0
    total_skipped      = 0
    new_dishes_created = 0
    created_this_run   = {}  # name -> recipe_id, for sides created earlier in this run
    all_reasoning      = []

    if args.new_sides:
        side_names = [s.strip() for s in args.new_sides.split(",")]
        cur.execute("""
            SELECT recipe_id FROM recipe_dna_master
            WHERE dish_name = ANY(%s)
            AND meal_role @> ARRAY['side']::text[]
        """, (side_names,))
        new_side_ids = [str(r[0]) for r in cur.fetchall()]
        if not new_side_ids:
            print(f"  WARNING: No sides found matching: {side_names}")
            already_done = set()
        else:
            cur.execute("""
                SELECT DISTINCT main_recipe_id::text FROM recipe_pairing
                WHERE house_id IS NULL
                AND side_recipe_id = ANY(%s::uuid[])
            """, (new_side_ids,))
            already_done = {r[0] for r in cur.fetchall()}
            print(f"  Mains already paired with these sides: {len(already_done)} - skipping")
    else:
        # Fixed: only genuine AI-reviewed pairings count as "done" --
        # previously included matrix_seeded/seeded, which meant ~97.8%
        # of dishes were incorrectly skipped on every run since they
        # already had crude pairings.
        cur.execute("""
            SELECT DISTINCT main_recipe_id FROM recipe_pairing
            WHERE source = 'ai_seeded'
        """)
        already_done = {str(r[0]) for r in cur.fetchall()}

        # Also skip dishes already confirmed to genuinely have no sides
        # (e.g. Kothu Parotta, Corn Flakes) -- these never get an
        # ai_seeded pairing row since there's nothing to insert, so
        # without this they'd be re-asked about in every single batch.
        cur.execute("""
            SELECT recipe_id FROM recipe_dna_master
            WHERE pairing_confirmed_no_sides = TRUE
        """)
        already_done |= {str(r[0]) for r in cur.fetchall()}
        print(f"Already AI-reviewed or confirmed no-sides: {len(already_done)} main dishes - skipping these\n")

    processed = 0
    for idx, (main_id, main_name, main_cat) in enumerate(mains):
        if str(main_id) in already_done:
            continue

        if args.limit and processed >= args.limit:
            print(f"\n  [LIMIT] Stopped after {args.limit} dishes.")
            break
        if args.preview and processed >= 3:
            print(f"\n  [PREVIEW] Stopping after 3 dishes. Remove --preview to process all.\n")
            break

        print(f"[{processed+1}] {main_name} ({main_cat})")
        processed += 1

        try:
            result = call_groq(main_name, main_cat, num_sides=5)

            if not result:
                print(f"  ✗ Failed to get response")
                total_skipped += 1
                continue

            matched   = dedupe_matched(result.get("sides", []))
            reasoning = result.get("overall_reasoning", "")

            print(f"  ✓ Got {len(matched)} sides")
            if len(matched) == 0:
                # Could be genuine (model correctly saying "this dish has
                # no traditional Tamil side" -- plausible for Western
                # items like cereal/porridge) or a real failure. Show the
                # model's own reasoning so we can tell which, instead of
                # guessing.
                print(f"    (0 sides -- model's reasoning: {reasoning or '[none given]'})")
                if not args.preview:
                    # Persist the confirmation -- lets future runs skip
                    # re-asking about this dish, and lets the
                    # recommendation engine know upfront this dish
                    # genuinely has no side dish (per Vijey).
                    cur.execute("""
                        UPDATE recipe_dna_master
                        SET pairing_confirmed_no_sides = TRUE
                        WHERE recipe_id = CAST(%s AS uuid)
                    """, (str(main_id),))

            all_reasoning.append({
                "main": main_name, "category": main_cat, "reasoning": reasoning,
                "matched_count": len(matched),
            })

            for m in matched:
                side_name  = m.get("name", "").strip()
                confidence = float(m.get("confidence", 0.80))
                reason     = m.get("reason", "")

                if args.preview:
                    # Preview mode: report what WOULD happen, write nothing
                    existing_id = side_name_to_id.get(side_name)
                    if not existing_id:
                        for sn, sid in side_name_to_id.items():
                            if sn.lower() == side_name.lower() or side_name.lower() in sn.lower() or sn.lower() in side_name.lower():
                                existing_id = sid
                                break
                    if existing_id:
                        print(f"    → {side_name} ({confidence:.0%}) — matches existing side")
                    else:
                        guessed_diet = infer_diet_type(side_name)
                        print(f"    → {side_name} ({confidence:.0%}) — NEW side, would create as diet_type={guessed_diet}")
                    total_inserted += 1
                    continue

                try:
                    side_id, was_created = find_or_create_side(cur, side_name, side_name_to_id, created_this_run)
                    if was_created:
                        print(f"    + Created new side: '{side_name}' (diet_type={infer_diet_type(side_name)})")
                        new_dishes_created += 1

                    cur.execute("""
                        INSERT INTO recipe_pairing
                            (main_recipe_id, side_recipe_id, confidence, source, house_id, notes)
                        VALUES
                            (CAST(%s AS uuid), CAST(%s AS uuid), %s, 'ai_seeded', NULL, %s)
                        ON CONFLICT (main_recipe_id, side_recipe_id) WHERE house_id IS NULL
                        DO UPDATE SET
                            confidence = GREATEST(recipe_pairing.confidence, EXCLUDED.confidence),
                            source     = 'ai_seeded',
                            notes      = EXCLUDED.notes,
                            updated_at = NOW()
                    """, (str(main_id), str(side_id), confidence, reason))
                    total_inserted += cur.rowcount
                except Exception as e:
                    print(f"    ERROR processing {side_name}: {e}")
                    conn.rollback()

            if not args.preview:
                conn.commit()

        except Exception as e:
            print(f"  ✗ UNEXPECTED ERROR processing {main_name}: {type(e).__name__}: {e}")
            print(f"    Skipping this dish, continuing with the rest.")
            total_skipped += 1
            try:
                conn.rollback()
            except Exception:
                pass

        time.sleep(12)  # paced to roughly stay under the model's 8000 TPM free-tier limit -- the retry-after handling above is the real safety net, this just reduces how often it's needed

    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Pairings inserted:      {total_inserted}")
    print(f"  Main dishes processed:  {processed}")
    print(f"  Main dishes failed:     {total_skipped}")
    print(f"  New side dishes created: {new_dishes_created}")
    print(f"{'='*60}\n")

    if created_this_run:
        print("New side dishes created (review_status='under_review' -- visible in the Recipe Review queue):")
        for name in created_this_run:
            print(f"  - {name}  (guessed diet_type: {infer_diet_type(name)})")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
