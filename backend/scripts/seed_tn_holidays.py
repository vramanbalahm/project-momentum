"""
Populate event_master with government-published Tamil Nadu holiday
templates for a given year.

These are master/template rows (house_id IS NULL, source='ADMIN') --
not tied to any household. A separate, later step copies the relevant
rows into a household's own events when they select a Tamil Panchangam
type, which they can then edit, pause, or delete freely without
touching this master data.

Safe to re-run: upserts by (event_code, event_year) via the partial
unique index added in schema v34 -- running this again for the same
year updates existing rows rather than duplicating them.

Usage:
    python seed_tn_holidays.py --json-file tn_holidays_2026.json
    python seed_tn_holidays.py --json-file tn_holidays_2026.json --database "postgresql://...supabase..."
"""

import argparse
import json
import os
import sys

import psycopg2

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:admin123@localhost:5432/food_momentum_db")
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)


def load_holidays(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    year = data.get("year")
    if not year:
        # Year is mandatory, per the actual requirement -- refuse to
        # proceed rather than guess or default it.
        sys.exit(f"ERROR: '{json_path}' has no top-level 'year' field. Year is mandatory -- aborting.")

    holidays = data.get("holidays", [])
    if not holidays:
        sys.exit(f"ERROR: '{json_path}' has no holidays listed. Nothing to do.")

    for h in holidays:
        missing = [k for k in ("event_code", "event_name", "event_date", "event_type") if not h.get(k)]
        if missing:
            sys.exit(f"ERROR: holiday {h} is missing required field(s): {missing}")

    return year, data.get("source_document", ""), holidays


def upsert_holidays(conn, year, source_document, holidays):
    inserted = updated = 0
    with conn.cursor() as cur:
        for h in holidays:
            cur.execute("""
                INSERT INTO event_master
                    (house_id, event_name, local_name, event_date, event_type,
                     is_sattvic_required, recurring_annual, event_code,
                     source, event_year, is_active)
                VALUES
                    (NULL, %(event_name)s, %(event_name)s, %(event_date)s, %(event_type)s,
                     %(is_sattvic_required)s, true, %(event_code)s,
                     'ADMIN', %(event_year)s, true)
                ON CONFLICT (event_code, event_year) WHERE house_id IS NULL
                DO UPDATE SET
                    event_name = EXCLUDED.event_name,
                    event_date = EXCLUDED.event_date,
                    event_type = EXCLUDED.event_type,
                    is_sattvic_required = EXCLUDED.is_sattvic_required,
                    is_active = true
                RETURNING (xmax = 0) AS was_insert
            """, {**h, "event_year": year})
            was_insert = cur.fetchone()[0]
            if was_insert:
                inserted += 1
            else:
                updated += 1
    conn.commit()
    return inserted, updated


def main():
    parser = argparse.ArgumentParser(description="Populate event_master with government TN holiday templates")
    parser.add_argument("--json-file", required=True, help="Path to the holidays JSON file")
    parser.add_argument("--database", default=DATABASE_URL, help="Target database connection string")
    args = parser.parse_args()

    year, source_document, holidays = load_holidays(args.json_file)

    print(f"Source: {source_document}")
    print(f"Year: {year}")
    print(f"Holidays to process: {len(holidays)}")
    print(f"Target database: {args.database.split('@')[-1] if '@' in args.database else args.database}")
    print()

    conn = psycopg2.connect(args.database)
    try:
        inserted, updated = upsert_holidays(conn, year, source_document, holidays)
        print(f"Done. Inserted: {inserted}, Updated: {updated}, Total: {inserted + updated}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
