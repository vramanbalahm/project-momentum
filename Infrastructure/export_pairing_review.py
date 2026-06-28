#!/usr/bin/env python3
"""
export_pairing_review.py
Exports recipe pairings to Excel for human review.
Vijey can mark pairings as KEEP or REMOVE.
After review, run import_pairing_review.py to apply changes.

Usage:
    python export_pairing_review.py --db <dsn> --category rice
    python export_pairing_review.py --db <dsn> --category tiffin
    python export_pairing_review.py --db <dsn> --category millet
"""

import argparse, os, sys
from datetime import datetime

parser = argparse.ArgumentParser()
parser.add_argument("--db",       required=True)
parser.add_argument("--category", required=True, help="rice|tiffin|millet|bread|continental")
args = parser.parse_args()

try:
    import psycopg2
    import openpyxl
    from openpyxl.styles import PatternFill, Font, Alignment, Border, Side
    from openpyxl.utils import get_column_letter
except ImportError:
    os.system("pip install psycopg2-binary openpyxl --break-system-packages -q")
    import psycopg2, openpyxl
    from openpyxl.styles import PatternFill, Font, Alignment, Border, Side
    from openpyxl.utils import get_column_letter

conn = psycopg2.connect(args.db)
cur  = conn.cursor()

# Fetch pairings for the category
cur.execute("""
    SELECT 
        rp.id,
        r.dish_name       as main_dish,
        r.sub_region      as main_region,
        r.diet_type::text as main_diet,
        s.dish_name       as side_dish,
        s.dish_category   as side_category,
        s.sub_region      as side_region,
        rp.confidence,
        rp.source,
        rp.notes,
        rp.acceptance_count,
        rp.rejection_count
    FROM recipe_pairing rp
    JOIN recipe_dna_master r ON r.recipe_id = rp.main_recipe_id
    JOIN recipe_dna_master s ON s.recipe_id = rp.side_recipe_id
    WHERE r.dish_category = %s
    AND r.meal_role @> ARRAY['main']::text[]
    AND rp.house_id IS NULL
    ORDER BY r.dish_name, rp.source DESC, rp.confidence DESC
""", (args.category,))

rows = cur.fetchall()
print(f"Fetched {len(rows)} pairings for {args.category}")

# Create workbook
wb = openpyxl.Workbook()
ws = wb.active
ws.title = f"{args.category.title()} Pairings"

# Styles
header_fill   = PatternFill("solid", fgColor="1A3A2E")
header_font   = Font(color="9FE1CB", bold=True, size=10)
ai_fill       = PatternFill("solid", fgColor="E1F5EE")
matrix_fill   = PatternFill("solid", fgColor="FFF9E6")
keep_fill     = PatternFill("solid", fgColor="C8E6C9")
remove_fill   = PatternFill("solid", fgColor="FFCDD2")
center        = Alignment(horizontal="center", vertical="center")
thin          = Side(style="thin", color="DDDDDD")
border        = Border(left=thin, right=thin, top=thin, bottom=thin)

# Headers
headers = [
    "ID", "Main Dish", "Region", "Diet", 
    "Side Dish", "Side Category", "Side Region",
    "Confidence", "Source", "Notes", 
    "Accepts", "Rejects", "ACTION"
]
ws.append(headers)

for col, header in enumerate(headers, 1):
    cell = ws.cell(1, col)
    cell.fill   = header_fill
    cell.font   = header_font
    cell.alignment = center
    cell.border = border

# Column widths
widths = [8, 35, 15, 10, 30, 14, 14, 10, 14, 30, 8, 8, 12]
for i, w in enumerate(widths, 1):
    ws.column_dimensions[get_column_letter(i)].width = w

# Data rows
prev_main = None
row_num = 2

for row in rows:
    (rid, main, main_region, main_diet, side, side_cat,
     side_region, confidence, source, notes, accepts, rejects) = row

    # Shade alternating main dish groups
    if main != prev_main:
        prev_main = main

    ws_row = [
        rid, main, main_region, main_diet,
        side, side_cat, side_region,
        round(float(confidence), 2), source, notes or "",
        accepts or 0, rejects or 0, "KEEP"
    ]
    ws.append(ws_row)

    # Style row based on source
    fill = ai_fill if source == 'ai_seeded' else matrix_fill
    for col in range(1, len(headers) + 1):
        cell = ws.cell(row_num, col)
        cell.fill   = fill
        cell.border = border
        cell.alignment = Alignment(vertical="center", wrap_text=(col == 10))

    # ACTION column — default KEEP, dropdown hint
    action_cell = ws.cell(row_num, 13)
    action_cell.value = "KEEP"
    action_cell.font  = Font(bold=True, color="2E7D32")
    action_cell.alignment = center

    row_num += 1

# Add legend sheet
ls = wb.create_sheet("Legend")
ls.append(["Color", "Meaning"])
ls.append(["Green rows", "AI seeded — higher quality, culturally aware"])
ls.append(["Yellow rows", "Matrix seeded — category-level, may need review"])
ls.append(["", ""])
ls.append(["ACTION column:", ""])
ls.append(["KEEP", "Retain this pairing (default)"])
ls.append(["REMOVE", "Delete this pairing"])
ls.append(["", ""])
ls.append(["Instructions:", "Change ACTION to REMOVE for wrong pairings"])
ls.append(["Then run:", "python import_pairing_review.py --db <dsn> --file <this_file>"])

# Add data validation hint for ACTION column
from openpyxl.worksheet.datavalidation import DataValidation
dv = DataValidation(type="list", formula1='"KEEP,REMOVE"', allow_blank=False)
ws.add_data_validation(dv)
dv.add(f"M2:M{row_num}")

# Freeze top row
ws.freeze_panes = "A2"

# Save
fname = f"pairing_review_{args.category}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
wb.save(fname)
print(f"Saved: {fname}")
print(f"  {len(rows)} pairings | {sum(1 for r in rows if r[8]=='ai_seeded')} AI | {sum(1 for r in rows if r[8]=='matrix_seeded')} matrix")

cur.close()
conn.close()
