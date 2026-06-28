#!/usr/bin/env python3
"""
migrate_to_supabase.py
Migrates reference/seed data from local PostgreSQL to Supabase.
Safe to run multiple times — uses UPSERT.

Usage:
    python migrate_to_supabase.py --local <dsn> --supabase <dsn> --preview
    python migrate_to_supabase.py --local <dsn> --supabase <dsn> --schema
    python migrate_to_supabase.py --local <dsn> --supabase <dsn>
    python migrate_to_supabase.py --local <dsn> --supabase <dsn> --tables recipe_dna_master,recipe_pairing
"""

import argparse, os, sys, json
from datetime import datetime

parser = argparse.ArgumentParser(description="Migrate local DB to Supabase")
parser.add_argument("--local",    required=True)
parser.add_argument("--supabase", required=True)
parser.add_argument("--tables",   default="")
parser.add_argument("--preview",  action="store_true")
parser.add_argument("--schema",   action="store_true")
parser.add_argument("--batch",    type=int, default=50)
args = parser.parse_args()

try:
    import psycopg2, psycopg2.extras
except ImportError:
    os.system("pip install psycopg2-binary -q")
    import psycopg2, psycopg2.extras

# ── Table configs ─────────────────────────────────────────────────────────────

TABLES = [
    {
        "table":    "ingredient_catalog",
        "conflict": "id",
        "update":   ["name_en", "name_ta", "category", "is_common_allergen"],
        "order_by": "id",
    },
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
    {
        "table":    "recipe_content_vault",
        "conflict": "recipe_id",
        "update":   ["hero_image_url", "carousel_thumb_url", "prep_steps", "ingredients_json", "video_url"],
        "order_by": "recipe_id",
        "filter":   "recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE review_status = 'approved')",
        "json_cols": ["prep_steps", "ingredients_json"],  # columns needing JSON serialization
    },
    {
        "table":    "recipe_ingredients",
        "conflict": "recipe_id, ingredient_id",
        "update":   ["quantity", "unit", "is_optional"],
        "order_by": "recipe_id",
        "filter":   "recipe_id IN (SELECT recipe_id FROM recipe_dna_master WHERE review_status = 'approved')",
        "constraint": "uq_recipe_ingredient",
    },
    {
        "table":    "dish_pairing_matrix",
        "conflict": "main_category, side_category",
        "update":   ["compatibility", "notes"],
        "order_by": "main_category",
    },
    {
        "table":    "recipe_pairing",
        "conflict": "main_recipe_id, side_recipe_id",
        "update":   ["confidence", "source", "notes"],
        "order_by": "main_recipe_id",
        "filter":   "house_id IS NULL AND source IN ('seeded','ai_seeded','matrix_seeded')",
        "do_nothing": False,
        "no_conflict": False,
        "partial_where": "WHERE house_id IS NULL",  # for partial index
    },
    {
        "table":    "feature_registry",
        "conflict": "feature_code",
        "update":   ["feature_name", "function_name", "is_active", "description"],
        "order_by": "feature_code",
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

def serialize_row(row, columns, json_cols):
    """Convert row tuple to list, serializing JSON columns."""
    result = []
    for col, val in zip(columns, row):
        if col in json_cols and val is not None:
            if isinstance(val, (dict, list)):
                val = json.dumps(val, ensure_ascii=False)
        result.append(val)
    return result

def fetch_rows(cur, cfg):
    where = f"WHERE {cfg['filter']}" if cfg.get("filter") else ""
    cur.execute(f"SELECT * FROM {cfg['table']} {where} ORDER BY {cfg['order_by']}")
    rows = cur.fetchall()
    columns = [d[0] for d in cur.description]
    return rows, columns

def get_dst_columns(cur, table):
    """Get columns that exist on destination table."""
    cur.execute("""
        SELECT column_name FROM information_schema.columns
        WHERE table_name = %s AND table_schema = 'public'
        ORDER BY ordinal_position
    """, (table,))
    return {r[0] for r in cur.fetchall()}

def build_upsert(table, columns, conflict, update_cols, do_nothing=False, constraint=None, no_conflict=False):
    col_list    = ", ".join(columns)
    placeholder = ", ".join(["%s"] * len(columns))

    # No conflict clause — plain INSERT, handle duplicates row by row
    if no_conflict:
        return f"INSERT INTO {table} ({col_list}) VALUES ({placeholder})"

    if constraint:
        conflict_clause = f"ON CONFLICT ON CONSTRAINT {constraint}"
    else:
        conflict_clause = f"ON CONFLICT ({conflict})"

    if do_nothing or update_cols is None:
        conflict_clause += " DO NOTHING"
    else:
        updates = ", ".join([f"{c} = EXCLUDED.{c}" for c in update_cols if c in columns])
        if updates:
            conflict_clause += f" DO UPDATE SET {updates}"
        else:
            conflict_clause += " DO NOTHING"

    return f"INSERT INTO {table} ({col_list}) VALUES ({placeholder}) {conflict_clause}"

def migrate_table(src_cur, dst_cur, cfg, batch_size):
    print(f"\n  📦 {cfg['table']}")

    # Fetch source rows
    try:
        rows, src_columns = fetch_rows(src_cur, cfg)
    except Exception as e:
        src_cur.connection.rollback()
        print(f"     Skipped — source error: {e}")
        return 0, 0

    print(f"     Source rows  : {len(rows)}")
    if not rows:
        print(f"     No data to migrate")
        return 0, 0

    # Get destination columns — only migrate columns that exist on dest
    dst_cols = get_dst_columns(dst_cur, cfg["table"])
    if not dst_cols:
        print(f"     Skipped — table not found on Supabase (run --schema first)")
        return 0, 0

    # Filter to columns that exist on both sides
    common_cols = [c for c in src_columns if c in dst_cols]
    col_indices = [src_columns.index(c) for c in common_cols]
    skipped_cols = [c for c in src_columns if c not in dst_cols]
    if skipped_cols:
        print(f"     Skipping cols: {skipped_cols} (not on Supabase yet)")

    json_cols = cfg.get("json_cols", [])

    # Filter update cols to those that exist
    update_cols = cfg.get("update")
    if update_cols:
        update_cols = [c for c in update_cols if c in common_cols]

    # Build upsert SQL
    # Build conflict clause — use partial index WHERE clause if specified
    conflict_str = cfg["conflict"]
    if cfg.get("partial_where"):
        conflict_str = f"{cfg['conflict']} {cfg['partial_where']}"

    sql = build_upsert(
        cfg["table"], common_cols, conflict_str,
        update_cols,
        do_nothing=cfg.get("do_nothing", False),
        constraint=cfg.get("constraint"),
        no_conflict=cfg.get("no_conflict", False),
    )

    inserted = errors = 0

    for i in range(0, len(rows), batch_size):
        batch_raw = rows[i:i+batch_size]
        # Extract only common columns and serialize JSON
        batch = [
            serialize_row([r[j] for j in col_indices], common_cols, json_cols)
            for r in batch_raw
        ]
        try:
            psycopg2.extras.execute_batch(dst_cur, sql, batch)
            dst_cur.connection.commit()
            inserted += len(batch)
        except Exception as e:
            dst_cur.connection.rollback()
            print(f"     ERROR batch {i//batch_size + 1}: {e}")
            # Row by row fallback
            for row in batch:
                try:
                    dst_cur.execute(sql, row)
                    dst_cur.connection.commit()
                    inserted += 1
                except Exception:
                    dst_cur.connection.rollback()
                    errors += 1

    print(f"     Migrated     : {inserted} | Errors: {errors}")
    return inserted, errors

# ── Schema migration ──────────────────────────────────────────────────────────

def run_schema(dst_conn):
    schema_dir = os.path.dirname(os.path.abspath(__file__))
    schema_files = sorted([
        f for f in os.listdir(schema_dir)
        if f.startswith("food_momentum_schema_v") and f.endswith(".sql")
    ])
    print(f"\nRunning {len(schema_files)} schema files on Supabase...")
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
            print(f"  ⚠️  {sf}: {str(e)[:100]}")
    cur.close()

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f"\n{'='*60}")
    print(f"Momentum — Local → Supabase Migration")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Mode: {'PREVIEW' if args.preview else 'SCHEMA' if args.schema else 'LIVE'}")
    print(f"{'='*60}\n")

    print("Connecting...")
    src_conn = get_conn(args.local,    "Local DB")
    dst_conn = get_conn(args.supabase, "Supabase")
    src_cur  = src_conn.cursor()
    dst_cur  = dst_conn.cursor()

    tables = TABLES
    if args.tables:
        requested = [t.strip() for t in args.tables.split(",")]
        tables = [t for t in TABLES if t["table"] in requested]
        print(f"Migrating only: {[t['table'] for t in tables]}\n")

    # Preview mode
    if args.preview:
        print(f"{'Table':<30} {'Local':>8}  {'Supabase':>8}")
        print("-" * 52)
        for cfg in tables:
            where = f"WHERE {cfg['filter']}" if cfg.get("filter") else ""
            try:
                src_cur.execute(f"SELECT COUNT(*) FROM {cfg['table']} {where}")
                local_count = src_cur.fetchone()[0]
            except Exception:
                src_conn.rollback()
                local_count = "N/A"
            try:
                dst_cur.execute(f"SELECT COUNT(*) FROM {cfg['table']} {where}")
                dst_count = dst_cur.fetchone()[0]
            except Exception:
                dst_conn.rollback()
                dst_count = "N/A"
            print(f"  {cfg['table']:<28} {str(local_count):>8}  {str(dst_count):>8}")
        print("\nRun without --preview to migrate.")
        return

    # Schema only
    if args.schema:
        run_schema(dst_conn)
        print("\nSchema done. Run without --schema to migrate data.")
        return

    # Migrate data
    total_inserted = total_errors = 0
    for cfg in tables:
        ins, err = migrate_table(src_cur, dst_cur, cfg, args.batch)
        total_inserted += ins
        total_errors   += err

    print(f"\n{'='*60}")
    print(f"Migration complete!")
    print(f"  Total migrated : {total_inserted}")
    print(f"  Total errors   : {total_errors}")
    print(f"{'='*60}\n")

    src_cur.close(); src_conn.close()
    dst_cur.close(); dst_conn.close()

if __name__ == "__main__":
    main()
