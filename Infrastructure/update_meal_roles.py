#!/usr/bin/env python3
"""
update_meal_roles.py — Bulk update meal_role on recipe_dna_master
from an Excel or JSON input file.

Usage:
    python3 update_meal_roles.py --file recipes.xlsx --db postgresql://postgres:password@localhost/food_momentum_db
    python3 update_meal_roles.py --file recipes.json  --db postgresql://postgres:password@localhost/food_momentum_db
    python3 update_meal_roles.py --file recipes.xlsx --preview   # dry run, no DB changes

Input format (Excel or JSON):
    Excel: columns → dish_name | meal_role
    JSON:  [{"dish_name": "Sambar", "meal_role": "side"}, ...]

Valid meal_role values:
    main       → main dish only
    side       → side dish only
    main,side  → can be both

Output:
    - Preview of changes before applying
    - Summary of rows updated
    - SQL statements saved to update_meal_roles.sql
"""

import argparse
import json
import sys
import os
from datetime import datetime

# ── Parse arguments ───────────────────────────────────────────────────────────

parser = argparse.ArgumentParser(description="Bulk update meal_role from Excel/JSON")
parser.add_argument("--file",    required=True, help="Input file path (.xlsx or .json)")
parser.add_argument("--db",      default=os.getenv("DATABASE_URL", "postgresql://postgres@localhost/food_momentum_db"),
                    help="PostgreSQL connection string")
parser.add_argument("--preview", action="store_true", help="Dry run — show changes without applying")
args = parser.parse_args()


# ── Load input file ───────────────────────────────────────────────────────────

def load_file(path):
    ext = path.lower().split(".")[-1]
    records = []

    if ext in ("xlsx", "xls"):
        try:
            import openpyxl
        except ImportError:
            print("Installing openpyxl...")
            os.system("pip install openpyxl --break-system-packages -q")
            import openpyxl

        wb = openpyxl.load_workbook(path)
        ws = wb.active
        headers = [str(c.value).strip().lower() for c in next(ws.iter_rows(min_row=1, max_row=1))]

        if "dish_name" not in headers or "meal_role" not in headers:
            print(f"ERROR: Excel must have columns 'dish_name' and 'meal_role'. Found: {headers}")
            sys.exit(1)

        name_idx = headers.index("dish_name")
        role_idx = headers.index("meal_role")

        for row in ws.iter_rows(min_row=2, values_only=True):
            name = row[name_idx]
            role = row[role_idx]
            if name and role:
                records.append({"dish_name": str(name).strip(), "meal_role": str(role).strip()})

    elif ext == "json":
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        for item in data:
            if "dish_name" in item and "meal_role" in item:
                records.append({
                    "dish_name": str(item["dish_name"]).strip(),
                    "meal_role": str(item["meal_role"]).strip()
                })
    else:
        print(f"ERROR: Unsupported file type .{ext}. Use .xlsx or .json")
        sys.exit(1)

    return records


# ── Validate meal_role values ─────────────────────────────────────────────────

VALID_ROLES = {"main", "side", "main,side"}

def validate(records):
    errors = []
    for r in records:
        role = r["meal_role"].replace(" ", "").lower()
        if role not in VALID_ROLES:
            errors.append(f"  Invalid meal_role '{r['meal_role']}' for dish '{r['dish_name']}'")
        # Normalise
        r["meal_role_pg"] = "{" + role + "}"
        r["meal_role_norm"] = role
    if errors:
        print("VALIDATION ERRORS:")
        print("\n".join(errors))
        print(f"\nValid values: main | side | main,side")
        sys.exit(1)
    return records


# ── Generate SQL ──────────────────────────────────────────────────────────────

def generate_sql(records):
    lines = [
        f"-- meal_role bulk update — generated {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- {len(records)} recipes",
        "",
        "BEGIN;",
        ""
    ]
    for r in records:
        name = r["dish_name"].replace("'", "''")  # escape single quotes
        pg_array = r["meal_role_pg"]
        lines.append(f"UPDATE recipe_dna_master SET meal_role = '{pg_array}' WHERE dish_name = '{name}';")

    lines += [
        "",
        "-- Verify",
        "SELECT meal_role, COUNT(*) FROM recipe_dna_master GROUP BY meal_role ORDER BY meal_role;",
        "",
        "COMMIT;"
    ]
    return "\n".join(lines)


# ── Apply to DB ───────────────────────────────────────────────────────────────

def apply(records, db_url):
    try:
        import psycopg2
    except ImportError:
        print("Installing psycopg2...")
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2

    conn = psycopg2.connect(db_url)
    cur  = conn.cursor()

    updated  = 0
    not_found = []

    for r in records:
        cur.execute(
            "UPDATE recipe_dna_master SET meal_role = %s WHERE dish_name = %s",
            ([r["meal_role_norm"]], r["dish_name"])
        )
        if cur.rowcount == 0:
            not_found.append(r["dish_name"])
        else:
            updated += cur.rowcount

    conn.commit()

    # Final counts
    cur.execute("SELECT meal_role, COUNT(*) FROM recipe_dna_master GROUP BY meal_role ORDER BY meal_role")
    counts = cur.fetchall()

    cur.close()
    conn.close()

    return updated, not_found, counts


# ── Export current recipes to Excel for review ────────────────────────────────

def export_for_review(db_url, output="meal_role_review.xlsx"):
    """Export all recipes with current meal_role for manual review in Excel."""
    try:
        import psycopg2
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment
    except ImportError:
        os.system("pip install psycopg2-binary openpyxl --break-system-packages -q")
        import psycopg2
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment

    conn = psycopg2.connect(db_url)
    cur  = conn.cursor()
    cur.execute("""
        SELECT dish_name,
               array_to_string(meal_role, ',') as meal_role,
               array_to_string(meal_slots, ',') as meal_slots,
               diet_type::text,
               intensity_level,
               sub_region
        FROM recipe_dna_master
        WHERE review_status = 'approved'
        ORDER BY meal_role, dish_name
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Recipes"

    # Header
    headers = ["dish_name", "meal_role", "meal_slots", "diet_type", "intensity_level", "sub_region"]
    header_fill = PatternFill("solid", fgColor="1A3A2E")
    header_font = Font(color="9FE1CB", bold=True)
    for col, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=col, value=h)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center")

    # Color coding per meal_role
    fills = {
        "main":      PatternFill("solid", fgColor="E1F5EE"),
        "side":      PatternFill("solid", fgColor="FAECE7"),
        "main,side": PatternFill("solid", fgColor="FFF3CD"),
    }

    for row_idx, row in enumerate(rows, 2):
        role = row[1] if row[1] else "main"
        fill = fills.get(role, PatternFill())
        for col_idx, val in enumerate(row, 1):
            cell = ws.cell(row=row_idx, column=col_idx, value=val)
            cell.fill = fill

    # Column widths
    ws.column_dimensions["A"].width = 45
    ws.column_dimensions["B"].width = 15
    ws.column_dimensions["C"].width = 25
    ws.column_dimensions["D"].width = 12
    ws.column_dimensions["E"].width = 12
    ws.column_dimensions["F"].width = 20

    # Instructions sheet
    ws2 = wb.create_sheet("Instructions")
    ws2["A1"] = "How to use this file:"
    ws2["A2"] = "1. Review the 'meal_role' column for each recipe"
    ws2["A3"] = "2. Valid values: main | side | main,side"
    ws2["A4"] = "3. Green = main, Red = side, Yellow = both"
    ws2["A5"] = "4. Change meal_role as needed"
    ws2["A6"] = "5. Save as .xlsx"
    ws2["A7"] = "6. Run: python3 update_meal_roles.py --file meal_role_review.xlsx --db <connection_string>"

    wb.save(output)
    print(f"\nExported {len(rows)} recipes to {output}")
    print("Edit the meal_role column, then run this script with --file to apply changes.")


# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Special mode: export for review
    if args.file == "export":
        export_for_review(args.db)
        sys.exit(0)

    print(f"\n{'='*60}")
    print(f"Meal Role Updater")
    print(f"{'='*60}")
    print(f"Input file: {args.file}")
    print(f"Mode: {'PREVIEW (dry run)' if args.preview else 'LIVE UPDATE'}")
    print()

    # Load and validate
    records = load_file(args.file)
    records = validate(records)
    print(f"Loaded {len(records)} recipes from {args.file}")

    # Show preview
    print("\nChanges to apply:")
    print(f"{'Dish name':<50} {'New meal_role'}")
    print("-" * 65)
    for r in records:
        print(f"{r['dish_name']:<50} {r['meal_role_norm']}")

    # Generate SQL file
    sql = generate_sql(records)
    sql_file = args.file.rsplit(".", 1)[0] + "_updates.sql"
    with open(sql_file, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"\nSQL saved to: {sql_file}")

    if args.preview:
        print("\nPREVIEW MODE — no changes applied.")
        print(f"To apply: python3 update_meal_roles.py --file {args.file} --db <connection_string>")
        sys.exit(0)

    # Apply
    confirm = input(f"\nApply {len(records)} updates to DB? (yes/no): ").strip().lower()
    if confirm != "yes":
        print("Aborted.")
        sys.exit(0)

    updated, not_found, counts = apply(records, args.db)

    print(f"\n{'='*60}")
    print(f"Done! {updated} recipes updated.")
    if not_found:
        print(f"\nNot found ({len(not_found)}):")
        for name in not_found:
            print(f"  - {name}")

    print("\nFinal meal_role counts:")
    for role, count in counts:
        print(f"  {role}: {count}")
