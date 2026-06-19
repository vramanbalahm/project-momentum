#!/usr/bin/env python3
"""
seed_recipe_pairings.py
Seeds recipe_pairing table with pre-generated main→side pairings.

Logic:
  1. Load all approved main dishes grouped by dish_category
  2. Load all approved side dishes grouped by dish_category
  3. Use dish_pairing_matrix to find compatible main+side category pairs
  4. For each compatible pair, create recipe_pairing rows with confidence
  5. house_id = NULL (global seed applies to all households)

Confidence scoring:
  matrix compatibility = perfect  → 0.90
  matrix compatibility = good     → 0.80
  matrix compatibility = acceptable → 0.65

Usage:
    python seed_recipe_pairings.py --db postgresql://postgres@localhost/food_momentum_db
    python seed_recipe_pairings.py --db ... --preview
"""

import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("--db",       required=True)
parser.add_argument("--preview",  action="store_true")
parser.add_argument("--category", default=None, help="tiffin|rice|bread|millet — run for one category only")
args = parser.parse_args()

CONFIDENCE_MAP = {
    "perfect":    0.90,
    "good":       0.80,
    "acceptable": 0.65,
}

def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)

def main():
    conn = get_conn()
    cur  = conn.cursor()

    print(f"\n{'='*60}")
    print(f"Recipe Pairing Seeder")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    print(f"{'='*60}\n")

    # Load pairing matrix
    cur.execute("""
        SELECT main_category, side_category, compatibility
        FROM dish_pairing_matrix
        WHERE compatibility != 'never'
        ORDER BY main_category, 
            CASE compatibility 
                WHEN 'perfect' THEN 1 
                WHEN 'good' THEN 2 
                WHEN 'acceptable' THEN 3 
            END
    """)
    matrix = cur.fetchall()
    print(f"Loaded {len(matrix)} pairing rules from matrix\n")

    # Load all approved main dishes
    if args.category:
        cur.execute("""
            SELECT recipe_id, dish_name, dish_category
            FROM recipe_dna_master
            WHERE review_status = 'approved'
            AND meal_role @> ARRAY['main']::text[]
            AND dish_category = %s
            ORDER BY dish_name
        """, (args.category,))
    else:
        cur.execute("""
            SELECT recipe_id, dish_name, dish_category
            FROM recipe_dna_master
            WHERE review_status = 'approved'
            AND meal_role @> ARRAY['main']::text[]
            AND dish_category IS NOT NULL
            ORDER BY dish_category, dish_name
        """)
    mains = cur.fetchall()
    print(f"Loaded {len(mains)} main dishes\n")

    # Load all approved side dishes
    cur.execute("""
        SELECT recipe_id, dish_name, dish_category
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        AND meal_role @> ARRAY['side']::text[]
        AND dish_category IS NOT NULL
        ORDER BY dish_category, dish_name
    """)
    sides = cur.fetchall()
    print(f"Loaded {len(sides)} side dishes\n")

    # Note: ingredient overlap check removed from matrix seeder
    # Overlap check applies only when picking 2 sides (in F16 engine)
    # Matrix seeder seeds all valid category-level pairings

    # Group sides by category
    sides_by_cat = {}
    for recipe_id, dish_name, dish_category in sides:
        if dish_category not in sides_by_cat:
            sides_by_cat[dish_category] = []
        sides_by_cat[dish_category].append((recipe_id, dish_name))

    # Group mains by category
    mains_by_cat = {}
    for recipe_id, dish_name, dish_category in mains:
        if dish_category not in mains_by_cat:
            mains_by_cat[dish_category] = []
        mains_by_cat[dish_category].append((recipe_id, dish_name))

    # Print category counts
    print("Main categories:")
    for cat, items in mains_by_cat.items():
        print(f"  {cat}: {len(items)} dishes")
    print("\nSide categories:")
    for cat, items in sides_by_cat.items():
        print(f"  {cat}: {len(items)} dishes")
    print()

    # Generate pairings
    inserted        = 0
    skipped         = 0
    overlap_skipped = 0
    pairs_preview   = []

    for main_cat, side_cat, compatibility in matrix:
        confidence = CONFIDENCE_MAP.get(compatibility, 0.65)
        main_dishes = mains_by_cat.get(main_cat, [])
        side_dishes = sides_by_cat.get(side_cat, [])

        if not main_dishes or not side_dishes:
            continue

        for main_id, main_name in main_dishes:
            for side_id, side_name in side_dishes:

                if args.preview:
                    pairs_preview.append({
                        "main": main_name,
                        "main_cat": main_cat,
                        "side": side_name,
                        "side_cat": side_cat,
                        "compatibility": compatibility,
                        "confidence": confidence,
                    })
                    inserted += 1
                    continue

                try:
                    cur.execute("""
                        INSERT INTO recipe_pairing
                            (main_recipe_id, side_recipe_id, confidence, source, house_id)
                        VALUES
                            (CAST(%s AS uuid), CAST(%s AS uuid), %s, 'seeded', NULL)
                        ON CONFLICT DO NOTHING
                    """, (str(main_id), str(side_id), confidence))
                    inserted += cur.rowcount
                except Exception as e:
                    if skipped < 3:  # Only print first 3 errors
                        print(f"  ERROR sample: {main_name} -> {side_name}: {e}")
                    conn.rollback()
                    skipped += 1
                    continue

    if not args.preview:
        conn.commit()

    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Pairings {'would be' if args.preview else ''} inserted: {inserted}")
    if overlap_skipped:
        print(f"  Skipped (ingredient overlap): {overlap_skipped}")
    if skipped:
        print(f"  Skipped (errors):  {skipped}")
    print(f"{'='*60}\n")

    if args.preview and pairs_preview:
        # Show sample
        print("Sample pairings (first 20):")
        print(f"{'Main':<40} {'Side':<40} {'Compat':<12} {'Conf'}")
        print("-" * 100)
        for p in pairs_preview[:20]:
            print(f"{p['main']:<40} {p['side']:<40} {p['compatibility']:<12} {p['confidence']}")
        print(f"\n... and {len(pairs_preview)-20} more" if len(pairs_preview) > 20 else "")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
