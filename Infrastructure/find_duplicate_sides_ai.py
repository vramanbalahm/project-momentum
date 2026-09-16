#!/usr/bin/env python3
"""
find_duplicate_sides_ai.py

Scans side dishes for likely duplicates using a two-stage approach,
validated against a deliberately hard test set before building this:

1. Cast a LOOSE net with trigram similarity (accepting false positives
   at this stage -- this is just candidate generation, nothing here
   gets merged automatically) to group textually-similar dish names
   into candidate clusters.
2. For each candidate cluster, ask the AI (same Groq/GPT-OSS-120B
   pipeline already proven for pairing generation) to actually judge
   which members, if any, are genuinely the same real dish versus
   dishes that merely share wording -- using real food knowledge, not
   string distance. Tested against real cases: correctly caught
   'Avial'/'Aviyal' (a spelling variant pure similarity misses
   entirely) while correctly keeping apart look-alikes like different-
   legume Kadala curries and coconut chutney vs coconut pachadi.

Only AI-CONFIRMED groups (2+ genuinely same dish) get written to
ai_duplicate_suggestions, status='pending' -- this never merges
anything itself. A human reviews and acts on each suggestion via the
Platform Admin screen, which uses the same proven merge-dishes
endpoint underneath.

Usage:
    python find_duplicate_sides_ai.py --db postgresql://postgres@localhost/food_momentum_db --preview
    python find_duplicate_sides_ai.py --db postgresql://postgres@localhost/food_momentum_db
"""

import argparse
import json
import os
import re
import time
import uuid
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
parser.add_argument("--preview", action="store_true", help="Show what would be found/stored, write nothing")
parser.add_argument("--threshold", type=float, default=0.25, help="Loose trigram threshold for CANDIDATE clustering only -- not a merge decision")
parser.add_argument("--max-cluster-size", type=int, default=15, help="Skip candidate clusters larger than this -- likely chaining, not a real duplicate group")
args = parser.parse_args()


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def cluster_candidates(cur, threshold):
    """Loose trigram-similarity clustering -- candidate generation only,
    deliberately permissive (accepts false positives), since the AI
    step afterward does the actual judgment call."""
    cur.execute("""
        SELECT a.recipe_id AS id_a, a.dish_name AS name_a,
               b.recipe_id AS id_b, b.dish_name AS name_b
        FROM recipe_dna_master a
        JOIN recipe_dna_master b
            ON a.recipe_id < b.recipe_id
            AND a.meal_role @> ARRAY['side']::text[]
            AND b.meal_role @> ARRAY['side']::text[]
            AND similarity(LOWER(a.dish_name), LOWER(b.dish_name)) > %s
        WHERE a.review_status != 'rejected' AND b.review_status != 'rejected'
    """, (threshold,))
    rows = cur.fetchall()

    parent = {}
    def find(x):
        parent.setdefault(x, x)
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    dish_info = {}
    for r in rows:
        a_id, b_id = str(r[0]), str(r[2])
        union(a_id, b_id)
        dish_info[a_id] = {"recipe_id": a_id, "dish_name": r[1]}
        dish_info[b_id] = {"recipe_id": b_id, "dish_name": r[3]}

    clusters = {}
    for rid in dish_info:
        clusters.setdefault(find(rid), []).append(dish_info[rid])

    return [members for members in clusters.values() if len(members) >= 2]


def ask_ai_to_judge(cluster):
    """Send one candidate cluster to the AI and get back genuine
    duplicate sub-groups (a cluster found via loose similarity can
    contain BOTH real duplicates and unrelated look-alikes)."""
    dishes = [m["dish_name"] for m in cluster]
    prompt = f"""You are a Tamil Nadu cuisine expert. Below is a numbered list of dish names that were flagged as textually similar to each other by a text-matching algorithm.

Dishes:
{chr(10).join(f"{i+1}. {d}" for i, d in enumerate(dishes))}

For each dish, determine if it is GENUINELY the same real dish as another one in this list (just spelled, worded, or described differently), or if it is a distinct, different dish/preparation that merely shares some wording.

Be strict: two dishes belong in the same group only if they are truly the same food. Sharing an ingredient name or a base word is NOT enough on its own -- a different legume, a different preparation style (chutney vs pachadi, curry vs poriyal), etc. makes them different dishes, even if worded similarly.

Return ONLY valid JSON, no explanation, no markdown:
{{"groups": [{{"members": [1, 2, 3], "canonical_name": "best name to use", "reasoning": "one line"}}], "distinct": [4, 5, ...]}}

Every dish number from 1 to {len(dishes)} must appear exactly once, either inside a group's "members" (only if it has at least one genuine duplicate) or in "distinct"."""

    import requests
    if not GROQ_API_KEY:
        print("  ERROR: GROQ_API_KEY not set in backend/.env")
        return None

    max_retries = 4
    for attempt in range(max_retries + 1):
        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": "openai/gpt-oss-120b",
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.2,
                "max_tokens": 3000,
                "reasoning_effort": "low"
            },
            timeout=45
        )
        if response.status_code == 429:
            if attempt >= max_retries:
                print(f"    still rate-limited after {max_retries} retries, skipping this cluster")
                return None
            wait_s = int(response.headers.get("retry-after", 15)) + 2
            print(f"    rate limited -- waiting {wait_s}s (attempt {attempt+1}/{max_retries})...")
            time.sleep(wait_s)
            continue
        break

    if response.status_code != 200:
        print(f"    ERROR {response.status_code}: {response.text[:200]}")
        return None

    content = response.json()["choices"][0]["message"]["content"]
    try:
        content = content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        parsed = json.loads(content.strip())
    except Exception as e:
        print(f"    Parse error: {e}")
        return None

    # Translate the AI's 1-indexed dish numbers back to real recipe_ids
    real_groups = []
    for g in parsed.get("groups", []):
        members = g.get("members", [])
        if len(members) < 2:
            continue
        real_groups.append({
            "member_ids": [cluster[i-1]["recipe_id"] for i in members if 1 <= i <= len(cluster)],
            "canonical_name": g.get("canonical_name", dishes[members[0]-1]),
            "reasoning": g.get("reasoning", ""),
        })
    return real_groups


def already_suggested(cur, member_ids):
    """Skip re-inserting a suggestion that already exists and is still
    pending -- lets this script be re-run safely without piling up
    duplicate suggestions for the same group."""
    cur.execute("""
        SELECT 1 FROM ai_duplicate_suggestions
        WHERE status = 'pending'
        AND member_ids @> %s::uuid[] AND member_ids <@ %s::uuid[]
    """, (member_ids, member_ids))
    return cur.fetchone() is not None


def main():
    conn = get_conn()
    cur = conn.cursor()

    print(f"\n{'='*60}")
    print(f"AI Duplicate Scanner (openai/gpt-oss-120b)")
    print(f"Mode: {'PREVIEW' if args.preview else 'LIVE'}")
    print(f"Candidate threshold: {args.threshold}")
    print(f"{'='*60}\n")

    clusters = cluster_candidates(cur, args.threshold)
    clusters = [c for c in clusters if len(c) <= args.max_cluster_size]
    print(f"Candidate clusters found: {len(clusters)}\n")

    total_groups = 0
    for idx, cluster in enumerate(clusters):
        names = [m["dish_name"] for m in cluster]
        print(f"[{idx+1}/{len(clusters)}] Checking cluster of {len(cluster)}: {names}")

        try:
            groups = ask_ai_to_judge(cluster)
        except Exception as e:
            print(f"  UNEXPECTED ERROR: {type(e).__name__}: {e} -- skipping this cluster")
            continue

        if not groups:
            print("  No genuine duplicate groups found in this cluster.")
            time.sleep(2)
            continue

        for g in groups:
            if len(g["member_ids"]) < 2:
                continue
            if already_suggested(cur, g["member_ids"]):
                print(f"  (already suggested, skipping) {g['canonical_name']}")
                continue

            print(f"  -> DUPLICATE GROUP: {g['canonical_name']} -- {g['reasoning']}")
            if not args.preview:
                cur.execute("""
                    INSERT INTO ai_duplicate_suggestions (id, member_ids, canonical_name, reasoning)
                    VALUES (%s, %s, %s, %s)
                """, (str(uuid.uuid4()), g["member_ids"], g["canonical_name"], g["reasoning"]))
                conn.commit()
            total_groups += 1

        time.sleep(2)  # stay well clear of the rate limit

    print(f"\n{'='*60}")
    print(f"Summary: {total_groups} duplicate group(s) {'would be' if args.preview else ''} suggested")
    print(f"{'='*60}\n")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
