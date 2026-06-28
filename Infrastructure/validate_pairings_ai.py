#!/usr/bin/env python3
"""
validate_pairings_ai.py
Ask AI what sides go with a specific dish.
Mark existing pairings as validated=TRUE if AI confirms them.
Mark others as validated=FALSE (candidates for deletion).
Report missing sides not in DB.

Usage:
    python validate_pairings_ai.py --db <dsn> --dish "Curd Rice" --preview
    python validate_pairings_ai.py --db <dsn> --dish "Curd Rice"
    python validate_pairings_ai.py --db <dsn> --dish "Curd Rice" --apply-to-category rice
"""

import argparse, os, sys, json

parser = argparse.ArgumentParser()
parser.add_argument("--db",               required=True)
parser.add_argument("--dish",             required=True, help="Exact dish name to validate")
parser.add_argument("--preview",          action="store_true")
parser.add_argument("--apply-to-category", default=None, help="Apply same validation to all dishes in category")
args = parser.parse_args()

try:
    import psycopg2, psycopg2.extras, anthropic
except ImportError:
    os.system("pip install psycopg2-binary anthropic --break-system-packages -q")
    import psycopg2, psycopg2.extras, anthropic

# ── Load API key ───────────────────────────────────────────────────────────────
env_path = os.path.join(os.path.dirname(__file__), "..", "backend", ".env")
api_key = None
if os.path.exists(env_path):
    for line in open(env_path):
        if line.startswith("ANTHROPIC_API_KEY"):
            api_key = line.split("=", 1)[1].strip()
if not api_key:
    print("ERROR: ANTHROPIC_API_KEY not found in backend/.env")
    sys.exit(1)

conn = psycopg2.connect(args.db)
cur  = conn.cursor()

# ── Get the main dish ─────────────────────────────────────────────────────────
cur.execute("""
    SELECT recipe_id, dish_name, dish_category, sub_region, diet_type::text
    FROM recipe_dna_master
    WHERE dish_name ILIKE %s
    AND meal_role @> ARRAY['main']::text[]
    AND review_status = 'approved'
    LIMIT 1
""", (args.dish,))
main = cur.fetchone()
if not main:
    print(f"ERROR: Dish '{args.dish}' not found")
    sys.exit(1)

main_id, main_name, main_cat, main_region, main_diet = main
print(f"\nValidating pairings for: {main_name}")
print(f"  Category: {main_cat} | Region: {main_region} | Diet: {main_diet}")

# ── Get all approved side dishes ──────────────────────────────────────────────
cur.execute("""
    SELECT recipe_id::text, dish_name, dish_category, sub_region
    FROM recipe_dna_master
    WHERE meal_role @> ARRAY['side']::text[]
    AND review_status = 'approved'
    ORDER BY dish_name
""")
all_sides = cur.fetchall()
sides_by_name = {r[1]: r for r in all_sides}
sides_list = ", ".join([r[1] for r in all_sides])

print(f"  Total sides in DB: {len(all_sides)}")

# ── Ask AI ────────────────────────────────────────────────────────────────────
print(f"\nAsking AI for authentic sides for {main_name}...")

prompt = f"""You are a Tamil Nadu cuisine expert. 

Main dish: {main_name} (category: {main_cat}, region: {main_region or 'Tamil Nadu'}, diet: {main_diet})

Available side dishes in our database:
{sides_list}

Task: Which sides from the list above authentically pair with {main_name}?

Return ONLY valid JSON:
{{
  "validated_sides": ["exact name 1", "exact name 2"],
  "missing_sides": ["side that should exist but is not in list"],
  "reasoning": "one line explanation"
}}

Rules:
- Use ONLY exact names from the available sides list for validated_sides
- validated_sides: 3-10 sides that genuinely pair with this dish in Tamil Nadu cuisine
- missing_sides: important traditional sides NOT in our list (max 5)
- Be culturally authentic — what would a Tamil Nadu household actually serve together?"""

client = anthropic.Anthropic(api_key=api_key)
message = client.messages.create(
    model="claude-haiku-4-5-20251001",
    max_tokens=1000,
    messages=[{"role": "user", "content": prompt}]
)

# Parse response
raw = message.content[0].text.strip()
if raw.startswith("```"):
    raw = raw.split("```")[1]
    if raw.startswith("json"):
        raw = raw[4:]
raw = raw.strip().rstrip("```").strip()

try:
    result = json.loads(raw)
except:
    print(f"ERROR parsing AI response: {raw}")
    sys.exit(1)

validated_names = result.get("validated_sides", [])
missing_names   = result.get("missing_sides", [])
reasoning       = result.get("reasoning", "")

print(f"\nAI Response:")
print(f"  Reasoning: {reasoning}")
print(f"  Validated sides ({len(validated_names)}): {', '.join(validated_names)}")
print(f"  Missing sides ({len(missing_names)}): {', '.join(missing_names)}")

# ── Get current pairings for this dish ────────────────────────────────────────
cur.execute("""
    SELECT rp.id, s.dish_name, rp.confidence, rp.source, rp.validated
    FROM recipe_pairing rp
    JOIN recipe_dna_master s ON s.recipe_id = rp.side_recipe_id
    WHERE rp.main_recipe_id = %s
    AND rp.house_id IS NULL
""", (str(main_id),))
current_pairings = cur.fetchall()
current_by_name  = {r[1]: r for r in current_pairings}

print(f"\nCurrent pairings in DB: {len(current_pairings)}")

# ── Classify ──────────────────────────────────────────────────────────────────
to_validate   = []  # exists in DB + AI confirms → validated=TRUE
to_invalidate = []  # exists in DB but AI doesn't confirm → validated=FALSE
to_add        = []  # AI confirms but not in pairing table → INSERT
not_in_db     = []  # AI says missing → report only

for name in validated_names:
    if name in current_by_name:
        to_validate.append(current_by_name[name][0])  # pairing ID
    elif name in sides_by_name:
        to_add.append(sides_by_name[name][0])  # side recipe_id
    else:
        print(f"  WARNING: AI validated '{name}' not found in DB")

for pairing_id, side_name, conf, source, validated in current_pairings:
    if side_name not in validated_names:
        to_invalidate.append(pairing_id)

not_in_db = missing_names

# ── Preview ───────────────────────────────────────────────────────────────────
print(f"\n{'='*60}")
print(f"PREVIEW for {main_name}:")
print(f"  ✅ Validate (mark as confirmed): {len(to_validate)}")
print(f"  ❌ Invalidate (mark for review): {len(to_invalidate)}")
print(f"  ➕ Add new pairings:             {len(to_add)}")
print(f"  ⚠️  Missing from DB:              {len(not_in_db)}")
if not_in_db:
    print(f"     → {', '.join(not_in_db)}")

if args.preview:
    print("\nPreview mode — no changes made.")
    sys.exit(0)

# ── Apply ─────────────────────────────────────────────────────────────────────
# Mark validated
if to_validate:
    cur.execute("""
        UPDATE recipe_pairing SET validated = TRUE, source = 'ai_seeded'
        WHERE id = ANY(%s)
    """, (to_validate,))
    print(f"\n✅ Marked {cur.rowcount} pairings as validated")

# Mark invalidated
if to_invalidate:
    cur.execute("""
        UPDATE recipe_pairing SET validated = FALSE
        WHERE id = ANY(%s)
    """, (to_invalidate,))
    print(f"❌ Marked {cur.rowcount} pairings as not validated")

# Add new pairings
inserted = 0
for side_id in to_add:
    try:
        cur.execute("""
            INSERT INTO recipe_pairing 
                (main_recipe_id, side_recipe_id, confidence, source, house_id, validated)
            VALUES (CAST(%s AS uuid), CAST(%s AS uuid), 0.88, 'ai_seeded', NULL, TRUE)
            ON CONFLICT DO NOTHING
        """, (str(main_id), side_id))
        inserted += cur.rowcount
    except Exception as e:
        conn.rollback()
print(f"➕ Added {inserted} new validated pairings")

conn.commit()

# ── Apply to category ─────────────────────────────────────────────────────────
if args.apply_to_category:
    print(f"\nApplying validation pattern to ALL {args.apply_to_category} dishes...")
    
    validated_side_ids = []
    for name in validated_names:
        if name in sides_by_name:
            validated_side_ids.append(sides_by_name[name][0])

    if validated_side_ids:
        # Mark same sides as validated across all dishes in category
        cur.execute("""
            UPDATE recipe_pairing
            SET validated = TRUE
            WHERE house_id IS NULL
            AND side_recipe_id = ANY(%s::uuid[])
            AND main_recipe_id IN (
                SELECT recipe_id FROM recipe_dna_master
                WHERE dish_category = %s
                AND meal_role @> ARRAY['main']::text[]
            )
        """, (validated_side_ids, args.apply_to_category))
        print(f"  ✅ Validated {cur.rowcount} pairings across {args.apply_to_category} category")

        # Mark everything else in category as not validated
        cur.execute("""
            UPDATE recipe_pairing
            SET validated = FALSE
            WHERE house_id IS NULL
            AND validated IS NOT TRUE
            AND main_recipe_id IN (
                SELECT recipe_id FROM recipe_dna_master
                WHERE dish_category = %s
                AND meal_role @> ARRAY['main']::text[]
            )
        """, (args.apply_to_category,))
        print(f"  ❌ Marked {cur.rowcount} pairings as not validated in {args.apply_to_category} category")

    conn.commit()

print(f"\n{'='*60}")
print(f"Done! Run export_pairing_review.py to review invalidated pairings.")

cur.close()
conn.close()
