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
import requests
from datetime import datetime

parser = argparse.ArgumentParser()
parser.add_argument("--db",       required=True)
parser.add_argument("--preview",  action="store_true")
parser.add_argument("--category", default=None, help="tiffin|rice|bread|millet — run for one category only")
args = parser.parse_args()

ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
MODEL             = "claude-sonnet-4-6"

def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)

def call_claude(main_dish, main_category, available_sides):
    """Ask Claude to evaluate side dish pairings for a main dish."""

    sides_list = "\n".join([f"- {s}" for s in available_sides])

    prompt = f"""You are an expert in Tamil Nadu cuisine with deep knowledge of regional cooking traditions.

Main dish: {main_dish} (category: {main_category})

From the following list of available side dishes, identify which ones pair well with {main_dish}:

{sides_list}

Also identify any important traditional side dishes that are missing from our list.

Respond ONLY with a valid JSON object in this exact format:
{{
  "matched": [
    {{"name": "exact side dish name from list", "confidence": 0.95, "reason": "one line explanation"}},
    {{"name": "exact side dish name from list", "confidence": 0.85, "reason": "one line explanation"}}
  ],
  "missing": ["Side dish name not in list", "Another missing side"],
  "overall_reasoning": "Brief explanation of pairing principles for this main dish"
}}

Rules:
- matched names MUST be exactly as written in the available list above
- confidence: 0.90-1.0 = perfect, 0.75-0.89 = good, 0.60-0.74 = acceptable
- suggest 3-8 matched sides maximum
- missing list: only truly important traditional sides not in our list
- keep reasons concise (under 10 words)"""

    response = requests.post(
        ANTHROPIC_API_URL,
        headers={"Content-Type": "application/json"},
        json={
            "model": MODEL,
            "max_tokens": 1000,
            "messages": [{"role": "user", "content": prompt}]
        }
    )

    if response.status_code != 200:
        print(f"  API error {response.status_code}: {response.text[:200]}")
        return None

    content = response.json()["content"][0]["text"]

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
    side_names = list(side_name_to_id.keys())
    print(f"Available sides for matching: {len(side_names)}\n")

    # Stats
    total_inserted  = 0
    total_skipped   = 0
    all_missing     = {}  # missing_side_name → [main_dishes that need it]
    all_reasoning   = []

    for idx, (main_id, main_name, main_cat) in enumerate(mains):
        print(f"[{idx+1}/{len(mains)}] {main_name} ({main_cat})")

        if args.preview and idx >= 3:
            print(f"\n  [PREVIEW] Stopping after 3 dishes. Remove --preview to process all.\n")
            break

        # Call Claude
        result = call_claude(main_name, main_cat, side_names)

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
                # Try case-insensitive match
                for sn, sid in side_name_to_id.items():
                    if sn.lower() == side_name.lower():
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
                            (CAST(%s AS uuid), CAST(%s AS uuid), %s, 'seeded', NULL, %s)
                        ON CONFLICT (main_recipe_id, side_recipe_id, house_id) DO UPDATE SET
                            confidence = GREATEST(recipe_pairing.confidence, EXCLUDED.confidence),
                            notes = EXCLUDED.notes,
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
