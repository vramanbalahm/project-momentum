#!/usr/bin/env python3
"""
populate_recipe_ingredients.py
Maps ingredients from recipe_content_vault.ingredients_json
to ingredient_catalog IDs and populates recipe_ingredients table.

Primary ingredients = mandatory + category in (Vegetable, Lentil, Grain, Fruit, Meat, Seafood, Dairy)
Spice, Oil, Other, optional ingredients are excluded.

Usage:
    python populate_recipe_ingredients.py --db postgresql://postgres@localhost/food_momentum_db
    python populate_recipe_ingredients.py --db ... --preview   # dry run
    python populate_recipe_ingredients.py --db ... --review    # export flagged items to Excel
"""

import argparse
import json
import os
from datetime import datetime

parser = argparse.ArgumentParser()
parser.add_argument("--db",      required=True)
parser.add_argument("--preview", action="store_true")
parser.add_argument("--review",  action="store_true")
args = parser.parse_args()

PRIMARY_CATEGORIES = {"Vegetable","Lentil","Grain","Fruit","Meat","Seafood","Dairy","Nut"}
SKIP_NAMES = {"salt","water","oil","sugar","jaggery","baking soda","baking powder","food color"}

def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)

def load_catalog(cur):
    cur.execute("SELECT id, name_en, name_ta, category FROM ingredient_catalog ORDER BY name_en")
    return [{"id":r[0],"name_en":(r[1] or "").lower().strip(),"name_ta":(r[2] or "").strip(),"category":r[3] or ""} for r in cur.fetchall()]

def match_ingredient(name_en, name_ta, category, catalog, cur):
    name_lower = name_en.lower().strip()
    # 1. Exact
    for c in catalog:
        if c["name_en"] == name_lower:
            return c["id"], 1.0, c["name_en"]
    # 2. Contains
    for c in catalog:
        if c["name_en"] and c["name_en"] in name_lower:
            return c["id"], 0.92, c["name_en"]
        if c["name_en"] and name_lower in c["name_en"]:
            return c["id"], 0.90, c["name_en"]
    # 3. Tamil
    if name_ta:
        for c in catalog:
            if c["name_ta"] and c["name_ta"] == name_ta.strip():
                return c["id"], 0.95, c["name_en"]
    # 4. Trigram
    try:
        cur.execute("SELECT id, name_en, similarity(LOWER(name_en), LOWER(%s)) as sim FROM ingredient_catalog WHERE similarity(LOWER(name_en), LOWER(%s)) > 0.4 ORDER BY sim DESC LIMIT 1", (name_en, name_en))
        row = cur.fetchone()
        if row and row[2] > 0.4:
            return row[0], float(row[2]), row[1]
    except Exception:
        pass
    return None, 0.0, None

def is_primary(ing):
    if ing.get("is_optional", False): return False
    if ing.get("category","") not in PRIMARY_CATEGORIES: return False
    if any(s in ing.get("name","").lower() for s in SKIP_NAMES): return False
    return True

def main():
    conn = get_conn()
    cur  = conn.cursor()
    print(f"\n{'='*60}\nRecipe Ingredient Populator\nMode: {'PREVIEW' if args.preview else 'LIVE'}\n{'='*60}\n")
    catalog = load_catalog(cur)
    print(f"Loaded {len(catalog)} ingredients from catalog\n")
    cur.execute("""
        SELECT r.recipe_id, r.dish_name, v.ingredients_json
        FROM recipe_dna_master r
        JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        WHERE v.ingredients_json IS NOT NULL AND v.ingredients_json != '[]'
        AND r.review_status = 'approved' ORDER BY r.dish_name
    """)
    recipes = cur.fetchall()
    print(f"Processing {len(recipes)} recipes...\n")
    matched = flagged = skipped = inserted = 0
    review_items = []
    for recipe_id, dish_name, ingredients_json in recipes:
        try:
            ings = json.loads(ingredients_json) if isinstance(ingredients_json, str) else ingredients_json
        except Exception:
            continue
        for ing in [i for i in ings if is_primary(i)]:
            name_en = ing.get("name","").strip()
            name_ta = ing.get("name_ta","").strip()
            category = ing.get("category","")
            if not name_en: continue
            ing_id, confidence, matched_name = match_ingredient(name_en, name_ta, category, catalog, cur)
            if confidence >= 0.85 and ing_id:
                if not args.preview:
                    try:
                        qty  = ing.get("quantity", "")
                        unit = ing.get("unit", "")
                        cur.execute("INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, is_optional) VALUES (CAST(%s AS uuid), %s, %s, %s, false) ON CONFLICT (recipe_id, ingredient_id) DO NOTHING", (str(recipe_id), ing_id, str(qty), str(unit)))
                        inserted += cur.rowcount
                    except Exception as e:
                        print(f"  ERROR: {name_en}: {e}")
                        conn.rollback()
                        continue
                matched += 1
            elif confidence >= 0.6 and ing_id:
                review_items.append({"dish_name":dish_name,"ingredient":name_en,"name_ta":name_ta,"matched_to":matched_name,"confidence":f"{confidence:.0%}","category":category,"action":"Review needed"})
                flagged += 1
            else:
                review_items.append({"dish_name":dish_name,"ingredient":name_en,"name_ta":name_ta,"matched_to":"NO MATCH","confidence":"0%","category":category,"action":"Add to ingredient_catalog"})
                skipped += 1
    if not args.preview:
        conn.commit()
    print(f"\n{'='*60}\nSummary:\n  Auto-matched (>=85%):   {matched}\n  Needs review (60-85%):  {flagged}\n  No match (<60%):        {skipped}\n  Inserted to DB:         {inserted}\n{'='*60}\n")
    if review_items and (args.review or args.preview):
        _export_review(review_items)
    cur.close()
    conn.close()

def _export_review(items):
    try:
        import openpyxl
        from openpyxl.styles import Font, PatternFill
    except ImportError:
        os.system("pip install openpyxl --break-system-packages -q")
        import openpyxl
        from openpyxl.styles import Font, PatternFill
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Review"
    headers = ["Dish Name","Ingredient (EN)","Ingredient (TA)","Matched To","Confidence","Category","Action"]
    hf = PatternFill("solid", fgColor="1A3A2E")
    hfont = Font(color="9FE1CB", bold=True)
    for col, h in enumerate(headers, 1):
        c = ws.cell(row=1, column=col, value=h)
        c.fill = hf; c.font = hfont
    rf = PatternFill("solid", fgColor="FFF3CD")
    mf = PatternFill("solid", fgColor="FAECE7")
    for ri, item in enumerate(items, 2):
        fill = mf if item["matched_to"] == "NO MATCH" else rf
        for ci, key in enumerate(["dish_name","ingredient","name_ta","matched_to","confidence","category","action"], 1):
            ws.cell(row=ri, column=ci, value=item[key]).fill = fill
    for col, w in zip("ABCDEFG", [40,30,25,30,12,15,25]):
        ws.column_dimensions[col].width = w
    out = f"ingredient_review_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
    wb.save(out)
    print(f"Review file: {out}\n  Yellow = needs review | Red = add to catalog")

if __name__ == "__main__":
    main()
