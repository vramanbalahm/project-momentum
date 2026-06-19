#!/usr/bin/env python3
"""
export_duplicate_review.py
Exports potential duplicate recipes to Excel for manual review.

Usage:
    python export_duplicate_review.py --db postgresql://postgres@localhost/food_momentum_db
"""

import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
parser.add_argument("--threshold", type=float, default=0.70)
args = parser.parse_args()

def main():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2

    try:
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment
    except ImportError:
        os.system("pip install openpyxl --break-system-packages -q")
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment

    conn = psycopg2.connect(args.db)
    cur  = conn.cursor()

    cur.execute("""
        SELECT 
            a.dish_name as name1,
            a.meal_role::text as role1,
            a.dish_category as cat1,
            b.dish_name as name2,
            b.meal_role::text as role2,
            b.dish_category as cat2,
            ROUND(similarity(LOWER(a.dish_name), LOWER(b.dish_name))::numeric, 2) as sim
        FROM recipe_dna_master a
        JOIN recipe_dna_master b ON a.recipe_id < b.recipe_id
        WHERE a.review_status = 'approved'
        AND b.review_status = 'approved'
        AND similarity(LOWER(a.dish_name), LOWER(b.dish_name)) > %s
        ORDER BY sim DESC
    """, (args.threshold,))
    rows = cur.fetchall()
    print(f"Found {len(rows)} potential duplicates\n")

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Duplicate Review"

    # Headers
    headers = ["Dish 1", "Role 1", "Category 1", "Dish 2", "Role 2", "Category 2", "Similarity", "Action"]
    hf = PatternFill("solid", fgColor="1A3A2E")
    hfont = Font(color="9FE1CB", bold=True)
    for col, h in enumerate(headers, 1):
        c = ws.cell(row=1, column=col, value=h)
        c.fill = hf; c.font = hfont; c.alignment = Alignment(horizontal="center")

    # Color by similarity
    for ri, row in enumerate(rows, 2):
        sim = float(row[6])
        if sim >= 0.90:
            fill = PatternFill("solid", fgColor="FAECE7")  # Red — likely duplicate
        elif sim >= 0.80:
            fill = PatternFill("solid", fgColor="FFF3CD")  # Yellow — review needed
        else:
            fill = PatternFill("solid", fgColor="E1F5EE")  # Green — probably different

        for ci, val in enumerate(row, 1):
            ws.cell(row=ri, column=ci, value=str(val) if val else "").fill = fill

        # Action column — dropdown hint
        ws.cell(row=ri, column=8, value="KEEP_BOTH").fill = fill

    # Column widths
    for col, w in zip("ABCDEFGH", [40, 12, 15, 40, 12, 15, 12, 15]):
        ws.column_dimensions[col].width = w

    # Instructions sheet
    ws2 = wb.create_sheet("Instructions")
    ws2["A1"] = "How to use:"
    ws2["A2"] = "RED rows (>=0.90): Likely same dish - review carefully"
    ws2["A3"] = "YELLOW rows (0.80-0.89): Possibly same - check if they differ"
    ws2["A4"] = "GREEN rows (0.70-0.79): Probably different - keep both"
    ws2["A5"] = ""
    ws2["A6"] = "Action column values:"
    ws2["A7"] = "KEEP_BOTH - different dishes, keep both"
    ws2["A8"] = "DELETE_NAME1 - delete the dish in column A"
    ws2["A9"] = "DELETE_NAME2 - delete the dish in column D"

    out = "duplicate_recipe_review.xlsx"
    wb.save(out)
    print(f"Exported to: {out}")
    print(f"  RED   (>=0.90): Likely duplicates")
    print(f"  YELLOW (0.80-0.89): Review needed")
    print(f"  GREEN  (0.70-0.79): Probably different")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
