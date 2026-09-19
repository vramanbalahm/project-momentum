"""
export_new_data.py - Exports the AI-generated dishes, pairings, and
duplicate suggestions from the local database to CSV files, for
importing into QA.

Written as a Python script (rather than psql \\copy) since psql isn't
installed/on PATH on this machine -- reuses the same psycopg2 approach
already working throughout today's other scripts.

Usage:
    python export_new_data.py --db postgresql://postgres:admin123@localhost:5432/food_momentum_db
"""

import argparse
import csv
import os

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
args = parser.parse_args()


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def format_pg_array(value):
    """Postgres array literal format: {elem1,elem2}. Escapes any element
    containing a comma, brace, quote, or backslash by wrapping it in
    double quotes -- without this, a Python list value (which psycopg2
    returns for array columns) would be written to CSV as
    ['side'] instead of {side}, which Postgres can't read back."""
    if not value:
        return "{}"
    escaped = []
    for elem in value:
        s = str(elem)
        if any(c in s for c in (',', '{', '}', '"', '\\')) or s == "" or s.upper() == "NULL":
            s = '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
        escaped.append(s)
    return "{" + ",".join(escaped) + "}"


def export_query(cur, query, filename):
    cur.execute(query)
    columns = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    # Array-typed columns (meal_role, meal_slots, member_ids, etc.) come
    # back from psycopg2 as native Python lists -- format those as
    # proper Postgres array literals so they round-trip correctly.
    formatted_rows = [
        [format_pg_array(val) if isinstance(val, list) else val for val in row]
        for row in rows
    ]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(columns)
        writer.writerows(formatted_rows)
    print(f"  {filename}: {len(rows)} row(s)")


def main():
    conn = get_conn()
    cur = conn.cursor()

    print("Exporting new data to CSV...\n")
    export_query(cur, "SELECT * FROM recipe_dna_master WHERE created_by_ai = true", "new_dishes.csv")
    export_query(cur, "SELECT * FROM recipe_pairing WHERE source = 'ai_seeded'", "new_pairings.csv")
    export_query(cur, "SELECT * FROM ai_duplicate_suggestions", "duplicate_suggestions.csv")
    print("\nDone.")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
