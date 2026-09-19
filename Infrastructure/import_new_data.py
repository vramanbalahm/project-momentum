"""
import_new_data.py - Imports the CSV files produced by export_new_data.py
into a target database (QA).

Order matters: dishes must be imported before pairings, since pairings
reference dish recipe_ids via foreign key. This script enforces that
order internally.

Column list for each table is read dynamically from the CSV's own
header row, not hardcoded -- avoids drift if the schema changes.
Known array-typed columns (meal_role, meal_slots, member_ids) get an
explicit ::text[] / ::uuid[] cast so the Postgres array literals
written by export_new_data.py (e.g. "{side}") are interpreted
correctly, rather than being inserted as a single plain-text value.

Conflict handling, per table:
  - recipe_dna_master: ON CONFLICT (recipe_id) DO NOTHING -- recipe_id
    is a UUID generated locally and must be preserved exactly, since
    new_pairings.csv references these same IDs.
  - recipe_pairing: the "id" column (SERIAL) is dropped entirely and
    left for QA to auto-generate -- importing a specific local id could
    collide with QA's own sequence. Conflict target matches the
    partial unique index from schema v31: (main_recipe_id,
    side_recipe_id) WHERE house_id IS NULL.
  - ai_duplicate_suggestions: ON CONFLICT (id) DO NOTHING.

Usage:
    python import_new_data.py --db "QA_CONNECTION_STRING" --preview
    python import_new_data.py --db "QA_CONNECTION_STRING"
"""

import argparse
import csv
import os

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
parser.add_argument("--preview", action="store_true", help="Show what would be imported, write nothing")
args = parser.parse_args()

TEXT_ARRAY_COLUMNS = {"meal_role", "meal_slots"}
UUID_ARRAY_COLUMNS = {"member_ids"}


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def read_csv(filename):
    if not os.path.exists(filename):
        print(f"  {filename} not found -- skipping")
        return None, []
    with open(filename, "r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = list(reader)
    return header, rows


def build_insert(table, columns, conflict_clause):
    col_list = ", ".join(columns)
    value_placeholders = []
    for col in columns:
        if col in TEXT_ARRAY_COLUMNS:
            value_placeholders.append("%s::text[]")
        elif col in UUID_ARRAY_COLUMNS:
            value_placeholders.append("%s::uuid[]")
        else:
            value_placeholders.append("%s")
    return f"""
        INSERT INTO {table} ({col_list})
        VALUES ({', '.join(value_placeholders)})
        {conflict_clause}
    """


def import_table(cur, filename, table, conflict_clause, exclude_columns=None):
    exclude_columns = exclude_columns or set()
    header, rows = read_csv(filename)
    if header is None:
        return 0

    columns = [c for c in header if c not in exclude_columns]
    keep_indices = [i for i, c in enumerate(header) if c not in exclude_columns]

    query = build_insert(table, columns, conflict_clause)
    inserted = 0
    failed = 0

    for row in rows:
        values = [row[i] if row[i] != "" else None for i in keep_indices]
        if args.preview:
            inserted += 1
            continue
        try:
            # A savepoint isolates this one row's failure from the rest
            # of the transaction -- without it, one bad row poisons
            # every subsequent row too (confirmed: this was happening,
            # every row after the first failure showed
            # InFailedSqlTransaction, meaning nothing was actually
            # getting inserted from that point on).
            cur.execute("SAVEPOINT row_import")
            cur.execute(query, values)
            inserted += cur.rowcount
            cur.execute("RELEASE SAVEPOINT row_import")
        except Exception as e:
            cur.execute("ROLLBACK TO SAVEPOINT row_import")
            failed += 1
            print(f"  ERROR on a row: {type(e).__name__}: {e}")

    if failed:
        print(f"  ({failed} row(s) failed -- see errors above)")
    return inserted


def main():
    conn = get_conn()
    cur = conn.cursor()

    print(f"\n{'='*60}")
    print(f"Import New Data")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    print(f"{'='*60}\n")

    print("[1/3] Dishes (recipe_dna_master)...")
    n_dishes = import_table(
        cur, "new_dishes.csv", "recipe_dna_master",
        conflict_clause="ON CONFLICT (recipe_id) DO NOTHING",
        exclude_columns={"pairing_ai_checked_at"},  # untracked local-only column, confirmed absent from every migration -- schema drift, not part of the real schema
    )
    print(f"  {n_dishes} row(s) inserted\n")
    if not args.preview:
        conn.commit()

    print("[2/3] Pairings (recipe_pairing)...")
    n_pairings = import_table(
        cur, "new_pairings.csv", "recipe_pairing",
        conflict_clause="ON CONFLICT (main_recipe_id, side_recipe_id) WHERE house_id IS NULL DO NOTHING",
        exclude_columns={"id"},  # SERIAL -- let QA auto-generate, avoids sequence collisions
    )
    print(f"  {n_pairings} row(s) inserted\n")
    if not args.preview:
        conn.commit()

    print("[3/3] Duplicate suggestions (ai_duplicate_suggestions)...")
    n_dupes = import_table(
        cur, "duplicate_suggestions.csv", "ai_duplicate_suggestions",
        conflict_clause="ON CONFLICT (id) DO NOTHING",
    )
    print(f"  {n_dupes} row(s) inserted\n")
    if not args.preview:
        conn.commit()

    print(f"{'='*60}")
    print(f"Done. Dishes: {n_dishes}, Pairings: {n_pairings}, Duplicate suggestions: {n_dupes}")
    print(f"{'='*60}\n")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
