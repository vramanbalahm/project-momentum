#!/usr/bin/env python3
"""
seed_recipe_pairings_ai.py
Uses Claude AI to evaluate main→side dish pairings for Tamil Nadu cuisine.

For each main dish:
1. Ask Claude which sides pair well from our existing vault
2. Ask Claude what important sides are missing
3. Store matched pairings in recipe_pairing table with reasoning
4. Export missing sides to Excel for recipe vault addition

Usage:
    python seed_recipe_pairings_ai.py --db postgresql://postgres@localhost/food_momentum_db --preview
    python seed_recipe_pairings_ai.py --db postgresql://postgres@localhost/food_momentum_db
    python seed_recipe_pairings_ai.py --db ... --category tiffin  # run for one category only
"""

import argparse
import json
import os
import time
from datetime import datetime
from dotenv import load_dotenv

# Load .env from backend folder
load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")

parser = argparse.ArgumentParser()
parser.add_argument("--db",       required=True)
parser.add_argument("--preview",  action="store_true")
parser.add_argument("--limit",    type=int, default=0, help="Process only N dishes (0=all). Free check before full run.")
parser.add_argument("--category",  default=None, help="tiffin|rice|bread|millet — run for one category only")
parser.add_argument("--new-sides", default=None, help="Comma-separated new side dish names — only process mains missing these sides")
args = parser.parse_args()

MODEL = "claude-haiku-4-5-20251001"  # Haiku — ~20x cheaper than Sonnet, sufficient for pairing

def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)

def call_claude(main_dish, main_category, available_sides, compatible_cats):
    """Ask Claude to evaluate side dish pairings for a main dish."""

    # Only send sides from compatible categories — reduces tokens significantly
    relevant_sides = [s for s in available_sides if s[2] in compatible_cats]
    # Limit to 60 sides max to reduce token usage
    relevant_sides = relevant_sides[:60]
    sides_list = ", ".join([s[1] for s in relevant_sides])
    prompt = f"""You are a Tamil Nadu cuisine expert. Given a main dish, identify which sides from the provided list pair well with it.

Main dish: {main_dish} (category: {main_category})
Available sides (use EXACT names only): {sides_list}

Return ONLY valid JSON, no explanation, no markdown:
{{"matched":[{{"name":"exact name from list","confidence":0.9,"reason":"one line"}}],"missing":[],"overall_reasoning":"one line"}}

Rules:
- Use ONLY exact names from the Available sides list above
- Select 3-8 best matching sides
- confidence: 0.85-0.95 for traditional pairings, 0.70-0.84 for acceptable
- missing: leave empty [] — do not invent names
- Focus on authentic Tamil Nadu traditional pairings"""

    try:
        import anthropic
    except ImportError:
        os.system("pip install anthropic --break-system-packages -q")
        import anthropic

    if not ANTHROPIC_API_KEY:
        print("  ERROR: ANTHROPIC_API_KEY not set in backend/.env")
        return None

    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
    message = client.messages.create(
        model=MODEL,
        max_tokens=500,
        messages=[{"role": "user", "content": prompt}]
    )
    content = message.content[0].text

    # Parse JSON response
    try:
        # Strip any markdown
        content = content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        return json.loads(content.strip())
    except Exception as e:
        print(f"  Parse error: {e}\n  Response: {content[:200]}")
        return None


def main():
    conn = get_conn()
    cur  = conn.cursor()

    print(f"\n{'='*60}")
    print(f"AI-Powered Recipe Pairing Seeder")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    if args.category:
        print(f"Category: {args.category}")
    print(f"{'='*60}\n")

    # Load all approved main dishes
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
    query += " ORDER BY dish_category, dish_name"

    cur.execute(query, params)
    mains = cur.fetchall()
    print(f"Main dishes to process: {len(mains)}\n")

    # Load all approved side dishes (names for Claude prompt)
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

    # Stats
    total_inserted  = 0
    total_skipped   = 0
    all_missing     = {}  # missing_side_name → [main_dishes that need it]
    all_reasoning   = []

    # Load already processed main dishes
    if args.new_sides:
        # --new-sides mode: only skip mains already paired with these specific sides
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
            print(f"  New sides to pair: {side_names}")
            cur.execute("""
                SELECT DISTINCT main_recipe_id::text FROM recipe_pairing
                WHERE house_id IS NULL
                AND side_recipe_id = ANY(%s)
            """, (new_side_ids,))
            already_done = {r[0] for r in cur.fetchall()}
            print(f"  Mains already paired with these sides: {len(already_done)} - skipping")
    else:
        cur.execute("""
            SELECT DISTINCT main_recipe_id FROM recipe_pairing
            WHERE source IN ('ai_seeded', 'matrix_seeded', 'seeded')
        """)
        already_done = {str(r[0]) for r in cur.fetchall()}
        print(f"Already processed: {len(already_done)} main dishes - skipping these")

    for idx, (main_id, main_name, main_cat) in enumerate(mains):
        # Skip if already processed
        if str(main_id) in already_done:
            if not args.new_sides:
                print(f"[{idx+1}/{len(mains)}] SKIP {main_name} (already seeded)")
            continue

        print(f"[{idx+1}/{len(mains)}] {main_name} ({main_cat})")

        if args.limit and idx >= args.limit:
            print(f"\n  [LIMIT] Stopped after {args.limit} dishes.")
            break
        if args.preview and idx >= 3:
            print(f"\n  [PREVIEW] Stopping after 3 dishes. Remove --preview to process all.\n")
            break

        # Call Claude
        # Get compatible side categories from matrix
        cur.execute("""
            SELECT side_category FROM dish_pairing_matrix
            WHERE main_category = %s AND compatibility != 'never'
        """, (main_cat,))
        compatible_cats = {r[0] for r in cur.fetchall()}
        result = call_claude(main_name, main_cat, sides, compatible_cats)

        if not result:
            print(f"  ✗ Failed to get AI response")
            total_skipped += 1
            continue

        matched  = result.get("matched", [])
        missing  = result.get("missing", [])
        reasoning = result.get("overall_reasoning", "")

        print(f"  ✓ Matched: {len(matched)} sides | Missing: {len(missing)}")

        # Store overall reasoning
        all_reasoning.append({
            "main": main_name,
            "category": main_cat,
            "reasoning": reasoning,
            "matched_count": len(matched),
            "missing_count": len(missing),
        })

        # Insert matched pairings
        for m in matched:
            side_name   = m.get("name", "").strip()
            confidence  = float(m.get("confidence", 0.80))
            reason      = m.get("reason", "")

            side_id = side_name_to_id.get(side_name)
            if not side_id:
                for sn, sid in side_name_to_id.items():
                    if sn.lower() == side_name.lower():
                        side_id = sid
                        break
            if not side_id:
                # Partial match
                for sn, sid in side_name_to_id.items():
                    if side_name.lower() in sn.lower() or sn.lower() in side_name.lower():
                        side_id = sid
                        break

            if not side_id:
                print(f"    ⚠ Side not found in vault: '{side_name}'")
                if side_name not in all_missing:
                    all_missing[side_name] = []
                all_missing[side_name].append(main_name)
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

        # Track missing sides
        for missing_name in missing:
            if missing_name not in all_missing:
                all_missing[missing_name] = []
            all_missing[missing_name].append(main_name)

        if not args.preview:
            conn.commit()

        # Rate limit — be gentle with API
        time.sleep(0.5)

    # Final summary
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Pairings inserted:     {total_inserted}")
    print(f"  Main dishes skipped:   {total_skipped}")
    print(f"  Missing sides found:   {len(all_missing)}")
    print(f"{'='*60}\n")

    # Export missing sides and reasoning to Excel
    if all_missing or all_reasoning:
        _export_results(all_missing, all_reasoning)

    cur.close()
    conn.close()


def _export_results(missing, reasoning):
    """Export missing sides and AI reasoning to Excel."""
    try:
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment
    except ImportError:
        os.system("pip install openpyxl --break-system-packages -q")
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment

    wb = openpyxl.Workbook()

    # Sheet 1: Missing sides
    ws1 = wb.active
    ws1.title = "Missing Sides"
    hf = PatternFill("solid", fgColor="1A3A2E")
    hfont = Font(color="9FE1CB", bold=True)

    headers = ["Missing Side Dish", "Needed For (Main Dishes)", "Count"]
    for col, h in enumerate(headers, 1):
        c = ws1.cell(row=1, column=col, value=h)
        c.fill = hf; c.font = hfont

    fill = PatternFill("solid", fgColor="FAECE7")
    for ri, (side, mains) in enumerate(sorted(missing.items(), key=lambda x: -len(x[1])), 2):
        ws1.cell(row=ri, column=1, value=side).fill = fill
        ws1.cell(row=ri, column=2, value=", ".join(mains[:5])).fill = fill
        ws1.cell(row=ri, column=3, value=len(mains)).fill = fill

    ws1.column_dimensions["A"].width = 35
    ws1.column_dimensions["B"].width = 60
    ws1.column_dimensions["C"].width = 10

    # Sheet 2: AI Reasoning
    ws2 = wb.create_sheet("AI Reasoning")
    headers2 = ["Main Dish", "Category", "AI Reasoning", "Matched", "Missing"]
    for col, h in enumerate(headers2, 1):
        c = ws2.cell(row=1, column=col, value=h)
        c.fill = hf; c.font = hfont

    rfill = PatternFill("solid", fgColor="E1F5EE")
    for ri, r in enumerate(reasoning, 2):
        ws2.cell(row=ri, column=1, value=r["main"]).fill = rfill
        ws2.cell(row=ri, column=2, value=r["category"]).fill = rfill
        ws2.cell(row=ri, column=3, value=r["reasoning"]).fill = rfill
        ws2.cell(row=ri, column=4, value=r["matched_count"]).fill = rfill
        ws2.cell(row=ri, column=5, value=r["missing_count"]).fill = rfill

    ws2.column_dimensions["A"].width = 40
    ws2.column_dimensions["B"].width = 12
    ws2.column_dimensions["C"].width = 70
    ws2.column_dimensions["D"].width = 10
    ws2.column_dimensions["E"].width = 10

    out = f"pairing_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
    wb.save(out)
    print(f"Analysis exported to: {out}")
    print(f"  Sheet 1: Missing sides to add to recipe vault")
    print(f"  Sheet 2: AI reasoning for each main dish pairing")

if __name__ == "__main__":
    main()
