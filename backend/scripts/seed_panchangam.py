"""
seed_panchangam.py — Annual Panchangam date seeder for Momentum.

Fetches all observation dates for a given Panchangam type and year from Gemini
and inserts them into panchangam_master.

Run once per year per Panchangam type — platform admin only.

Usage:
    cd C:\\Users\\SATISH.000\\project-momentum\\backend
    python scripts/seed_panchangam.py --type TAMIL_VAKYA --year 2026 --dry-run
    python scripts/seed_panchangam.py --type TAMIL_VAKYA --year 2026
    python scripts/seed_panchangam.py --type TAMIL_DRIK  --year 2026
    python scripts/seed_panchangam.py --type TELUGU      --year 2026

Requirements:
    pip install google-genai psycopg2-binary python-dotenv
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

from dotenv import load_dotenv
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

from google import genai
from google.genai import types
import psycopg2

# ── Config ────────────────────────────────────────────────────────────────────
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyCwsXt4Pkga-RmiJGORB56yQBDXvryXEh0")
GEMINI_MODEL   = os.getenv("GEMINI_MODEL",   "gemini-2.5-flash-lite")
DATABASE_URL   = os.getenv("DATABASE_URL",   "postgresql://postgres:admin123@localhost:5432/food_momentum_db")

if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

client = genai.Client(api_key=GEMINI_API_KEY)

# ── Panchangam display names — matches panchangam_types.code ─────────────────
PANCHANGAM_DISPLAY = {
    "TAMIL_VAKYA":   "Tamil Panchangam (Vakya)",
    "TAMIL_DRIK":    "Tamil Panchangam (Drik Ganitha)",
    "TELUGU":        "Telugu Panchangam",
    "KANNADA":       "Kannada Panchangam",
    "MALAYALAM":     "Malayalam Panchangam",
    "MARATHI":       "Marathi Panchangam",
    "GUJARATI":      "Gujarati Panchangam",
    "BENGALI":       "Bengali Panjika",
    "HINDI_VIKRAMI": "Hindi Vikrami Samvat Panchangam",
    "ODIA":          "Odia Panchangam",
}

# ── Prompt ────────────────────────────────────────────────────────────────────
PROMPT_TEMPLATE = """
You are an expert in Hindu calendar systems and Panchangam.

Generate a complete list of ALL religious observation dates for the {panchangam_name}
for the calendar year {year}.

Include ALL of the following observation types where applicable to this Panchangam:
- Ekadasi (both Shukla Paksha and Krishna Paksha — all occurrences)
- Amavasya (all occurrences)
- Pournami (all occurrences)
- Pradosham (all occurrences)
- Maha Shivaratri
- Karthigai Deepam
- Navratri (all 9 days)
- Diwali
- Pongal / Sankranti
- Ugadi / Tamil New Year
- Vinayagar Chaturthi
- Skanda Sashti (all 6 days)
- Thiruvathirai
- Sankatahara Chaturthi (all occurrences)
- Any other major observation specific to this Panchangam

Return ONLY a JSON array. No explanation, no markdown, no code fences.

Each observation must follow this exact structure:
{{
  "observation_code": "string — use these exact codes: EKADASI_SHUKLA, EKADASI_KRISHNA, AMAVASYA, POURNAMI, PRADOSHAM, SHIVARATRI, KARTHIGAI, NAVRATRI, DIWALI, PONGAL, UGADI, VINAYAGAR, SKANDA_SASHTI, THIRUVATHIRAI, SANKATAHARA — or a new code in CAPS_WITH_UNDERSCORES for additional observations",
  "observation_name": "string — full English name",
  "local_name": "string — name in the regional language of this Panchangam",
  "observation_date": "YYYY-MM-DD",
  "paksha": "Shukla | Krishna | null",
  "tithi": "string — lunar day name if applicable, else null",
  "category": "Fasting | Auspicious | Festival | Other",
  "is_sattvic": true | false,
  "notes": "string — any special notes for this occurrence, else null"
}}

Rules:
- Every date must be accurate for {year} as per {panchangam_name}
- Include ALL occurrences of repeating observations (e.g. all 24 Ekadasi dates)
- observation_date must be in YYYY-MM-DD format
- Do not miss any major observation
- For multi-day festivals (Navratri, Skanda Sashti), include one row per day
"""

# ── DB helpers ────────────────────────────────────────────────────────────────
def get_connection():
    return psycopg2.connect(DATABASE_URL)

def get_panchangam_type_id(cur, code):
    cur.execute("SELECT id FROM panchangam_types WHERE code = %s", (code,))
    row = cur.fetchone()
    if not row:
        raise ValueError(f"Panchangam type '{code}' not found in panchangam_types table.")
    return row[0]

def get_or_create_observation_id(cur, code, name, local_name, category, is_sattvic):
    """Get existing observation by code, or create it if new."""
    cur.execute("SELECT id FROM panchangam_observations WHERE code = %s", (code,))
    row = cur.fetchone()
    if row:
        return row[0]
    # New observation — insert it
    cur.execute("""
        INSERT INTO panchangam_observations
            (code, display_name, local_name, category, is_sattvic)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id
    """, (code, name, local_name, category, is_sattvic))
    print(f"    + New observation added to catalog: {code} — {name}")
    return cur.fetchone()[0]

def date_exists(cur, panchangam_type_id, observation_id, observation_date):
    cur.execute("""
        SELECT 1 FROM panchangam_master
        WHERE panchangam_type_id = %s
          AND observation_id = %s
          AND observation_date = %s
    """, (panchangam_type_id, observation_id, observation_date))
    return cur.fetchone() is not None

def insert_dates(dates, panchangam_type_id, year, dry_run=False):
    if dry_run:
        print(json.dumps(dates, indent=2, ensure_ascii=False))
        print(f"\n✓ Dry run — {len(dates)} dates generated, not inserted.")
        return

    conn = get_connection()
    cur  = conn.cursor()

    inserted = 0
    skipped  = 0
    errors   = 0

    for d in dates:
        try:
            obs_code     = d.get("observation_code", "").strip().upper()
            obs_name     = d.get("observation_name", "").strip()
            local_name   = d.get("local_name") or None
            obs_date_str = d.get("observation_date", "").strip()
            paksha       = d.get("paksha") or None
            tithi        = d.get("tithi") or None
            category     = d.get("category", "Other")
            is_sattvic   = d.get("is_sattvic", True)
            notes        = d.get("notes") or None

            if not obs_code or not obs_date_str:
                print(f"  ⚠ Skipped — missing code or date: {d}")
                skipped += 1
                continue

            # Validate date format
            try:
                obs_date = datetime.strptime(obs_date_str, "%Y-%m-%d").date()
            except ValueError:
                print(f"  ⚠ Invalid date format: {obs_date_str} for {obs_code}")
                skipped += 1
                continue

            # Validate year matches
            if obs_date.year != year:
                print(f"  ⚠ Date year mismatch: {obs_date} not in {year} — skipping")
                skipped += 1
                continue

            # Validate category
            if category not in ("Fasting", "Auspicious", "Festival", "Other"):
                category = "Other"

            # Get or create observation
            observation_id = get_or_create_observation_id(
                cur, obs_code, obs_name, local_name, category, is_sattvic
            )

            # Skip if already exists
            if date_exists(cur, panchangam_type_id, observation_id, obs_date):
                print(f"  ⟳ Skipped — already exists: {obs_code} on {obs_date}")
                skipped += 1
                continue

            # Insert
            cur.execute("""
                INSERT INTO panchangam_master
                    (panchangam_type_id, observation_id, observation_date,
                     year, tithi, paksha, notes, created_by_ai)
                VALUES (%s, %s, %s, %s, %s, %s, %s, true)
            """, (panchangam_type_id, observation_id, obs_date,
                  year, tithi, paksha, notes))

            conn.commit()
            print(f"  ✓ {obs_code:25} {obs_date}  {paksha or '':7}  {tithi or ''}")
            inserted += 1

        except Exception as e:
            conn.rollback()
            print(f"  ✗ Error: {d.get('observation_code', '?')} — {e}")
            errors += 1

    cur.close()
    conn.close()

    print(f"\n{'='*50}")
    print(f"  Inserted : {inserted}")
    print(f"  Skipped  : {skipped}")
    print(f"  Errors   : {errors}")
    print(f"{'='*50}")

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Seed Panchangam dates from Gemini")
    parser.add_argument("--type",    required=True, help="Panchangam type code e.g. TAMIL_VAKYA")
    parser.add_argument("--year",    type=int, required=True, help="Calendar year e.g. 2026")
    parser.add_argument("--dry-run", action="store_true", help="Print JSON only, do not insert")
    args = parser.parse_args()

    panchangam_name = PANCHANGAM_DISPLAY.get(args.type)
    if not panchangam_name:
        print(f"✗ Unknown Panchangam type: {args.type}")
        print(f"  Valid types: {', '.join(PANCHANGAM_DISPLAY.keys())}")
        sys.exit(1)

    print(f"\n🌙 Momentum Panchangam Seeder")
    print(f"   Type    : {args.type} — {panchangam_name}")
    print(f"   Year    : {args.year}")
    print(f"   Dry run : {args.dry_run}")
    print(f"   Model   : {GEMINI_MODEL}\n")

    # Get panchangam_type_id from DB
    if not args.dry_run:
        conn = get_connection()
        cur  = conn.cursor()
        try:
            panchangam_type_id = get_panchangam_type_id(cur, args.type)
            print(f"✓ Panchangam type ID: {panchangam_type_id}\n")
        except ValueError as e:
            print(f"✗ {e}")
            sys.exit(1)
        finally:
            cur.close()
            conn.close()
    else:
        panchangam_type_id = None

    prompt = PROMPT_TEMPLATE.format(
        panchangam_name=panchangam_name,
        year=args.year
    )

    print("⏳ Calling Gemini...")
    try:
        response = client.models.generate_content(
            model=GEMINI_MODEL,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.1,       # Low temp — dates must be precise, not creative
                max_output_tokens=16000,
            )
        )
        raw = response.text.strip()
    except Exception as e:
        print(f"✗ Gemini API error: {e}")
        sys.exit(1)

    # Strip markdown fences if present
    if raw.startswith("```"):
        lines = raw.split("\n")
        raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])

    print("✓ Response received — parsing JSON...")
    try:
        dates = json.loads(raw)
        if not isinstance(dates, list):
            raise ValueError("Expected a JSON array")
        print(f"✓ Parsed {len(dates)} observation dates\n")
    except json.JSONDecodeError as e:
        print(f"✗ JSON parse error: {e}")
        print("Raw snippet:", raw[:300])
        sys.exit(1)

    print("💾 Inserting into panchangam_master...")
    insert_dates(dates, panchangam_type_id, args.year, dry_run=args.dry_run)

if __name__ == "__main__":
    main()
