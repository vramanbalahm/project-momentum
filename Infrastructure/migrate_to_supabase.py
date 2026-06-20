#!/usr/bin/env python3
"""
migrate_to_supabase.py
Migrates reference/seed data from local PostgreSQL to Supabase.
Safe to run multiple times — uses UPSERT (ON CONFLICT DO UPDATE).

Usage:
    python migrate_to_supabase.py --local postgresql://postgres:admin123@localhost/food_momentum_db --supabase postgresql://postgres:<password>@<host>/postgres
    python migrate_to_supabase.py --local ... --supabase ... --tables recipe_dna_master,recipe_content_vault
    python migrate_to_supabase.py --local ... --supabase ... --preview   # show counts only, no migration
    python migrate_to_supabase.py --local ... --supabase ... --schema    # run schema files first

Tables migrated (in dependency order):
    1.  cuisine_regions
    2.  ingredient_catalog
    3.  recipe_dna_master
    4.  recipe_content_vault
    5.  recipe_ingredients
    6.  dish_pairing_matrix
    7.  recipe_pairing
    8.  feature_registry
    9.  tamil_panchangam
    10. household_plan_config (defaults only)
"""

import argparse
import os
import sys
from datetime import datetime

parser = argparse.ArgumentParser(description="Migrate local DB to Supabase")
parser.add_argument("--local",    required=True, help="Local PostgreSQL connection string")
parser.add_argument("--supabase", required=True, help="Supabase connection string")
parser.add_argument("--tables",   default="",    help="Comma-separated table names (default: all)")
parser.add_argument("--preview",  action="store_true", help="Show counts only, no migration")
parser.add_argument("--schema",   action="store_true", help="Run schema SQL files before data migration")
parser.add_argument("--batch",    type=int, default=100, help="Batch size for inserts (default: 100)")
args = parser.parse_args()

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    os.system("pip install psycopg2-binary --break-system-packages -q")
    import psycopg2
    import psycopg2.extras

# ── Table migration config ────────────────────────────────────────────────────
# Each entry: (table_name, conflict_column(s), update_columns or None)
# None = skip on conflict (don't overwrite existing)

TABLES = [
    # Reference data — always upsert
    {
        "table":    "cuisine_regions",
        "conflict": "id",
        "update":   ["name", "description"],
        "order_by": "id",
    },
    {
        "table":    "ingredient_catalog",
        "conflict": "id",
        "update":   ["name_en", "name_ta", "category", "is_common_allergen"],
        "order_by": "id",
    },
    # Recipe master — upsert by recipe_id
    {
        "table":    "recipe_dna_master",
        "conflict": "recipe_id",
        "update":   [
            "dish_name", "regional_name", "diet_type", "is_sattvic",
            "is_vegan", "intensity_level", "meal_slots", "meal_role",
            "dish_category", "sub_region", "review_status",
            "is_scalable", "is_regional_specific"
        ],
        "order_by": "dish_name",
        "filter":   "review_status = 'approved'",
    },
    # Content vault — upsert by recipe_id
    {
        "table":    "recipe_content_vault",
        "conflict": "recipe_id",
        "update":   [
            "hero_image_url", "carousel_thumb_url",
            "prep_steps", "ingredients_json", "video_url"
        ],
        "order_by": "recipe_id",
        "filter":   "recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE review_status = 'approved')",
    },
    # Recipe ingredients — upsert by (recipe_id, ingredient_id)
    {
        "table":    "recipe_ingredients",
        "conflict": "recipe_id, ingredient_id",
        "update":   ["quantity", "unit", "is_optional"],
        "order_by": "recipe_id",
        "filter":   "recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE review_status = 'approved')",
    },
    # Pairing matrix — upsert by (main_category, side_category)
    {
        "table":    "dish_pairing_matrix",
        "conflict": "main_category, side_category",
        "update":   ["compatibility", "notes"],
        "order_by": "main_category",
    },
    # Recipe pairing — upsert global seeds only (house_id IS NULL)
    {
        "table":    "recipe_pairing",
        "conflict": "main_recipe_id, side_recipe_id",
        "update":   ["confidence", "source", "notes"],
        "order_by": "main_recipe_id",
        "filter":   "house_id IS NULL AND source = 'seeded'",
        "partial_index": True,  # uses partial unique index
    },
    # Feature registry
    {
        "table":    "feature_registry",
        "conflict": "feature_code",
        "update":   ["feature_name", "function_name", "is_active", "description"],
        "order_by": "feature_code",
    },
    # Panchangam
    {
        "table":    "tamil_panchangam",
        "conflict": "observation_date",
        "update":   ["day_type", "notes"],
        "order_by": "observation_date",
    },
    # Household plan config — defaults only (no household-specific data)
    {
        "table":    "household_plan_config",
        "conflict": "house_id",
        "update":   None,  # skip on conflict — don't overwrite QA household settings
        "order_by": "house_id",
        "skip":     True,  # skip this table — QA has its own config
    },
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def get_conn(dsn, label):
    try:
        conn = psycopg2.connect(dsn)
        print(f"  Connected to {label}")
        return conn
    except Exception as e:
        print(f"  ERROR connecting to {label}: {e}")
        sys.exit(1)

def get_columns(cur, table):
    cur.execute("""
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = %s
        AND table_schema = 'public'
        ORDER BY ordinal_position
    """, (table,))
    return [(r[0], r[1]) for r in cur.fetchall()]

def fetch_rows(cur, cfg):
    where = f"WHERE {cfg['filter']}" if cfg.get("filter") else ""
    cur.execute(f"SELECT * FROM {cfg['table']} {where} ORDER BY {cfg['order_by']}")
    return cur.fetchall(), [d[0] for d in cur.description]

def build_upsert(table, columns, conflict, update_cols):
    col_list    = ", ".join(columns)
    placeholder = ", ".join(["%s"] * len(columns))
    conflict_clause = f"ON CONFLICT ({conflict})"

    if update_cols is None:
        conflict_clause += " DO NOTHING"
    else:
        updates = ", ".join([f"{c} = EXCLUDED.{c}" for c in update_cols if c in columns])
        conflict_clause += f" DO UPDATE SET {updates}, updated_at = NOW()" if "updated_at" in columns else f" DO UPDATE SET {updates}"

    return f"INSERT INTO {table} ({col_list}) VALUES ({placeholder}) {conflict_clause}"

def migrate_table(src_cur, dst_cur, cfg, batch_size):
    if cfg.get("skip"):
        print(f"  ⏭  {cfg['table']} — skipped (QA managed)")
        return 0, 0

    print(f"\n  📦 {cfg['table']}")

    # Fetch source data
    rows, columns = fetch_rows(src_cur, cfg)
    print(f"     Source rows: {len(rows)}")

    if not rows:
        print(f"     No data to migrate")
        return 0, 0

    # Build upsert SQL
    sql = build_upsert(cfg["table"], columns, cfg["conflict"], cfg.get("update"))

    inserted = 0
    errors   = 0

    # Batch insert
    for i in range(0, len(rows), batch_size):
        batch = rows[i:i+batch_size]
        try:
            psycopg2.extras.execute_batch(dst_cur, sql, batch)
            inserted += len(batch)
        except Exception as e:
            print(f"     ERROR batch {i//batch_size + 1}: {e}")
            dst_cur.connection.rollback()
            errors += len(batch)
            # Try row by row
            for row in batch:
                try:
                    dst_cur.execute(sql, row)
                    inserted += 1
                    errors   -= 1
                except Exception as re:
                    dst_cur.connection.rollback()

    print(f"     Migrated: {inserted} | Errors: {errors}")
    return inserted, errors

# ── Schema migration ──────────────────────────────────────────────────────────

def run_schema(dst_conn):
    schema_dir = os.path.dirname(os.path.abspath(__file__))
    schema_files = sorted([
        f for f in os.listdir(schema_dir)
        if f.startswith("food_momentum_schema_v") and f.endswith(".sql")
    ])

    print(f"\nRunning {len(schema_files)} schema files...")
    cur = dst_conn.cursor()
    for sf in schema_files:
        path = os.path.join(schema_dir, sf)
        with open(path, "r", encoding="utf-8") as f:
            sql = f.read()
        try:
            cur.execute(sql)
            dst_conn.commit()
            print(f"  ✅ {sf}")
        except Exception as e:
            dst_conn.rollback()
            print(f"  ⚠️  {sf}: {e}")
    cur.close()

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f"\n{'='*60}")
    print(f"Momentum — Local → Supabase Migration")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    print(f"{'='*60}\n")

    # Connect
    print("Connecting...")
    src_conn = get_conn(args.local,    "Local DB")
    dst_conn = get_conn(args.supabase, "Supabase")
    src_cur  = src_conn.cursor()
    dst_cur  = dst_conn.cursor()

    # Filter tables if --tables specified
    tables = TABLES
    if args.tables:
        requested = [t.strip() for t in args.tables.split(",")]
        tables = [t for t in TABLES if t["table"] in requested]
        print(f"Migrating only: {[t['table'] for t in tables]}\n")

    # Preview mode — show counts only
    if args.preview:
        print("Row counts in local DB:")
        print(f"{'Table':<30} {'Rows':>8}")
        print("-" * 40)
        for cfg in tables:
            if cfg.get("skip"):
                print(f"  {cfg['table']:<28} {'(skipped)':>8}")
                continue
            where = f"WHERE {cfg['filter']}" if cfg.get("filter") else ""
            src_cur.execute(f"SELECT COUNT(*) FROM {cfg['table']} {where}")
            count = src_cur.fetchone()[0]
            print(f"  {cfg['table']:<28} {count:>8}")
        print("\nRun without --preview to migrate.")
        return

    # Run schema if requested
    if args.schema:
        run_schema(dst_conn)

    # Migrate tables
    total_inserted = 0
    total_errors   = 0

    for cfg in tables:
        ins, err = migrate_table(src_cur, dst_cur, cfg, args.batch)
        dst_conn.commit()
        total_inserted += ins
        total_errors   += err

    # Final summary
    print(f"\n{'='*60}")
    print(f"Migration complete!")
    print(f"  Total migrated: {total_inserted}")
    print(f"  Total errors:   {total_errors}")
    print(f"{'='*60}\n")

    src_cur.close(); src_conn.close()
    dst_cur.close(); dst_conn.close()

if __name__ == "__main__":
    main()
