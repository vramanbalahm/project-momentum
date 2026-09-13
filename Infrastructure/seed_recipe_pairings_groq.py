#!/usr/bin/env python3
"""
seed_recipe_pairings_groq.py
Groq/GPT-OSS-120B variant of seed_recipe_pairings_ai.py -- same overall
design (per real main dish, ask which sides from the vault pair well,
track genuinely missing sides for manual review), switched to Groq for
cost (~free within Groq's tier vs metered Anthropic usage) after
validating output quality through a separate breakfast-list test.

Fixes applied vs. the original Anthropic script, found while validating:
1. already_done check was 'WHERE source IN (ai_seeded, matrix_seeded,
   seeded)' -- since ~97.8% of dishes already have crude matrix_seeded
   rows, this made the script skip almost everything on a fresh run.
   Now only 'ai_seeded' counts as done, so this actually re-processes
   every dish that hasn't had real AI review yet, regardless of what
   crude pairings already exist for it. The recommendation engine
   already correctly prioritizes ai_seeded over matrix_seeded when both
   exist (confirmed in recommend_sides()'s ORDER BY), so old rows don't
   need to be deleted -- they'll just stop being selected once real ones
   exist alongside them.
2. Added explicit per-dish deduplication of the model's suggested sides
   by name (case-insensitive) before counting/inserting -- the database's
   ON CONFLICT already prevents true duplicate rows, but a model response
   listing the same side twice within one dish's suggestions silently
   shrinks "4 sides" down to fewer genuinely distinct options.
3. Added --meal-slot filter (e.g. --meal-slot Breakfast) alongside the
   existing --category filter, since "Breakfast" is a meal_slots value,
   not a dish_category value in this schema.
4. Prompt reinforced based on iterative testing against a real breakfast
   list: explicit accuracy checking (don't mischaracterize what a dish
   actually is), and a partial-repeat structure for sides (at most 2 of
   however many suggested may be common staples also used elsewhere; at
   least the rest must be genuinely dish-specific) -- pure "avoid all
   repeats" distorted individual correctness in testing, and pure "no
   constraint" made the model lazy/uniform. This middle ground tested
   best.

Usage:
    python seed_recipe_pairings_groq.py --db postgresql://postgres@localhost/food_momentum_db --preview
    python seed_recipe_pairings_groq.py --db postgresql://postgres@localhost/food_momentum_db --meal-slot Breakfast --limit 10
    python seed_recipe_pairings_groq.py --db ... --meal-slot Breakfast   # full breakfast run
"""

import argparse
import json
import os
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


def call_groq(main_dish, main_category, available_sides, compatible_cats):
    """Ask GPT-OSS-120B (via Groq) to evaluate side dish pairings for a main dish."""

    relevant_sides = [s for s in available_sides if s[2] in compatible_cats]
    relevant_sides = relevant_sides[:60]
    sides_list = ", ".join([s[1] for s in relevant_sides])

    prompt = f"""You are a Tamil Nadu cuisine expert, specifically familiar with Tamil Brahmin (Iyer/Iyengar) household cooking traditions in Tamil Nadu.

Main dish: {main_dish} (category: {main_category})
Available sides in our vault (prefer these, use EXACT names when you do): {sides_list}

Suggest the traditional side dishes/accompaniments that genuinely and authentically pair with this main dish, ordered from most to least traditional/common.

Rules:
- Prefer matching to the available vault sides above when a genuine traditional match exists there.
- If a truly important traditional pairing is missing from that list, name it anyway in a separate "missing" field -- do not force a worse match from the list just to avoid naming something new.
- At most 2 of your suggested sides may be common staples that would also suit other dishes (e.g. sambar, coconut chutney). The rest must be genuinely specific to this exact dish's own texture and flavor -- not defaulted from a generic pool.
- If this dish is traditionally NOT eaten with side dishes at all (e.g. it's normally eaten plain, or mixed with something directly rather than served alongside it), say so honestly rather than forcing matches that don't reflect real practice.
- A side must be an actual dish/preparation -- not a plain condiment or garnish like ghee or salt.
- Be precise about what the main dish actually is -- do not mischaracterize its nature (texture, whether it's a rice preparation vs. a batter-based item vs. a legume dish, etc.) when reasoning about what pairs with it.
- Select 3-6 best matching sides from the vault list (if any genuinely fit).

Return ONLY valid JSON, no explanation, no markdown:
{{"matched":[{{"name":"exact name from list","confidence":0.9,"reason":"one line"}}],"missing":["dish name","dish name"],"overall_reasoning":"one line"}}"""

    import requests
    if not GROQ_API_KEY:
        print("  ERROR: GROQ_API_KEY not set in backend/.env")
        return None

    response = requests.post(
        "https://api.groq.com/openai/v1/chat/completions",
        headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
        json={
            "model": "openai/gpt-oss-120b",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.4,
            "max_tokens": 1500,
            "reasoning_effort": "low"
        },
        timeout=45
    )

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

    total_inserted = 0
    total_skipped  = 0
    all_missing    = {}
    all_reasoning  = []

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
        print(f"Already AI-reviewed: {len(already_done)} main dishes - skipping these\n")

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
            cur.execute("""
                SELECT side_category FROM dish_pairing_matrix
                WHERE main_category = %s AND compatibility != 'never'
            """, (main_cat,))
            compatible_cats = {r[0] for r in cur.fetchall()}
            result = call_groq(main_name, main_cat, sides, compatible_cats)

            if not result:
                print(f"  ✗ Failed to get response")
                total_skipped += 1
                continue

            matched   = dedupe_matched(result.get("matched", []))
            missing   = result.get("missing", [])
            reasoning = result.get("overall_reasoning", "")

            print(f"  ✓ Matched: {len(matched)} sides | Missing: {len(missing)}")

            all_reasoning.append({
                "main": main_name, "category": main_cat, "reasoning": reasoning,
                "matched_count": len(matched), "missing_count": len(missing),
            })

            for m in matched:
                side_name  = m.get("name", "").strip()
                confidence = float(m.get("confidence", 0.80))
                reason     = m.get("reason", "")

                side_id = side_name_to_id.get(side_name)
                if not side_id:
                    for sn, sid in side_name_to_id.items():
                        if sn.lower() == side_name.lower():
                            side_id = sid
                            break
                if not side_id:
                    for sn, sid in side_name_to_id.items():
                        if side_name.lower() in sn.lower() or sn.lower() in side_name.lower():
                            side_id = sid
                            break

                if not side_id:
                    print(f"    ⚠ Side not found in vault: '{side_name}'")
                    all_missing.setdefault(side_name, []).append(main_name)
                    continue

                if not args.preview:
                    try:
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
                        print(f"    ERROR inserting {side_name}: {e}")
                        conn.rollback()
                else:
                    print(f"    → {side_name} ({confidence:.0%}) — {reason}")
                    total_inserted += 1

            for missing_name in missing:
                if isinstance(missing_name, dict):
                    missing_name = missing_name.get("name", "")
                if not isinstance(missing_name, str) or not missing_name.strip():
                    continue
                all_missing.setdefault(missing_name.strip(), []).append(main_name)

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

        time.sleep(0.3)  # Groq is fast, but stay gentle

    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Pairings inserted:     {total_inserted}")
    print(f"  Main dishes processed: {processed}")
    print(f"  Main dishes failed:    {total_skipped}")
    print(f"  Missing sides found:   {len(all_missing)}")
    print(f"{'='*60}\n")

    if all_missing:
        print("Missing sides (review and consider adding to vault):")
        for name, needed_by in all_missing.items():
            print(f"  - {name}  (needed by: {', '.join(needed_by)})")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
