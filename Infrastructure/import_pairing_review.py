#!/usr/bin/env python3
"""
import_pairing_review.py
Applies pairing review decisions from Excel back to DB.
Deletes rows marked REMOVE, keeps rows marked KEEP.

Usage:
    python import_pairing_review.py --db <dsn> --file pairing_review_rice_xxx.xlsx
    python import_pairing_review.py --db <dsn> --file pairing_review_rice_xxx.xlsx --preview
"""

import argparse, os, sys

parser = argparse.ArgumentParser()
parser.add_argument("--db",      required=True)
parser.add_argument("--file",    required=True)
parser.add_argument("--preview", action="store_true")
args = parser.parse_args()

try:
    import psycopg2
    import openpyxl
except ImportError:
    os.system("pip install psycopg2-binary openpyxl --break-system-packages -q")
    import psycopg2, openpyxl

wb = openpyxl.load_workbook(args.file)
ws = wb.active

to_remove = []
to_keep   = 0

for row in ws.iter_rows(min_row=2, values_only=True):
    if not row[0]:
        continue
    rid    = row[0]
    action = str(row[12]).strip().upper() if row[12] else "KEEP"
    if action == "REMOVE":
        to_remove.append(rid)
    else:
        to_keep += 1

print(f"Review results:")
print(f"  KEEP:   {to_keep}")
print(f"  REMOVE: {len(to_remove)}")

if args.preview:
    print("\nPreview mode — no changes made.")
    print(f"IDs to remove: {to_remove[:10]}{'...' if len(to_remove) > 10 else ''}")
    sys.exit(0)

if not to_remove:
    print("\nNothing to remove — all pairings kept!")
    sys.exit(0)

conn = psycopg2.connect(args.db)
cur  = conn.cursor()

cur.execute("DELETE FROM recipe_pairing WHERE id = ANY(%s)", (to_remove,))
deleted = cur.rowcount
conn.commit()

print(f"\nDeleted {deleted} pairings.")
cur.close()
conn.close()
