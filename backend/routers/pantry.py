# routers/pantry.py — My Pantry endpoints
#
# GET  /pantry/ingredients        — returns all ingredients grouped by category
#                                   with household's current availability status
# GET  /pantry/ingredients/search — smart multi-language ingredient search
# POST /pantry/save               — save household's ingredient availability

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from typing import List
from database import get_db
from auth.dependencies import get_current_user

router = APIRouter(prefix="/pantry", tags=["pantry"])

# Category display config — order, emoji, display name
CATEGORY_CONFIG = [
    {"key": "Vegetable",  "emoji": "🥬", "label": "Vegetables"},
    {"key": "Meat",       "emoji": "🥩", "label": "Meat"},
    {"key": "Seafood",    "emoji": "🐟", "label": "Seafood"},
    {"key": "Dairy",      "emoji": "🥛", "label": "Eggs & Dairy"},
    {"key": "Grain",      "emoji": "🌾", "label": "Grains"},
    {"key": "Lentil",     "emoji": "🫘", "label": "Lentils & Pulses"},
    {"key": "Spice",      "emoji": "🌶️", "label": "Spices & Herbs"},
    {"key": "Oil",        "emoji": "🫙", "label": "Oils & Fats"},
    {"key": "Fruit",      "emoji": "🍎", "label": "Fruits"},
    {"key": "Nut",        "emoji": "🥜", "label": "Nuts & Seeds"},
    {"key": "Other",      "emoji": "🧂", "label": "Other"},
]


# ── GET /pantry/ingredients ───────────────────────────────────────────────────

@router.get("/ingredients", status_code=200)
async def get_pantry_ingredients(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns all ingredients from ingredient_catalog grouped by category,
    with each ingredient's current availability status for this household.
    Used by My Pantry screen to render the sidebar + ingredient grid.
    """
    house_id = current_user["house_id"]

    rows = db.execute(text("""
        SELECT
            ic.id,
            ic.name_en,
            ic.name_ta,
            ic.category,
            ic.emoji,
            ic.image_url,
            COALESCE(hp.is_available, false) AS is_available
        FROM ingredient_catalog ic
        LEFT JOIN household_pantry hp
            ON hp.ingredient_id = ic.id
            AND hp.house_id = CAST(:hid AS uuid)
        ORDER BY ic.category, ic.name_en
    """), {"hid": house_id}).fetchall()

    # Group by category
    category_map = {}
    for r in rows:
        cat = r.category or "Other"
        if cat not in category_map:
            category_map[cat] = []
        category_map[cat].append({
            "id":           r.id,
            "name_en":      r.name_en,
            "name_ta":      r.name_ta,
            "emoji":        r.emoji or "🥬",
            "image_url":    r.image_url,
            "is_available": r.is_available,
        })

    # Build ordered category list
    categories = []
    for cfg in CATEGORY_CONFIG:
        key = cfg["key"]
        ingredients = category_map.get(key, [])
        if not ingredients:
            continue
        categories.append({
            "key":              key,
            "label":            cfg["label"],
            "emoji":            cfg["emoji"],
            "total":            len(ingredients),
            "selected":         sum(1 for i in ingredients if i["is_available"]),
            "ingredients":      ingredients,
        })

    return {"categories": categories}


# ── GET /pantry/ingredients/search ──────────────────────────────────────────────

@router.get("/ingredients/search", status_code=200)
async def search_pantry_ingredients(
    q: str = Query(..., min_length=1),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Smart multi-language ingredient search. Matches on English name,
    Tamil names, Tamil transliterations, and English synonyms -- so
    "ulundhu", "ulutham paruppu" and "urad dal" all find the same
    ingredient, whatever language the person types in.

    Same two-stage soundex-then-trigram approach as /recipes/search:
      1. soundex() -- coarse match, catches vowel-heavy transliteration
         drift (thayir / thair / thyar / thayair)
      2. similarity() (trigram) -- confirms the match is real, filters
         out unrelated words that happen to share a soundex code
    A name counts as a match if trigram alone clears 0.1, OR soundex
    matches AND trigram clears a lower sanity floor of 0.08.

    Replaces the old client-side substring filter in IngredientSelector.jsx.
    """
    house_id = current_user["house_id"]

    rows = db.execute(text("""
        WITH name_candidates AS (
            SELECT id, name_en AS candidate_name FROM ingredient_catalog
            UNION ALL
            SELECT id, unnest(ta_names) FROM ingredient_catalog WHERE ta_names IS NOT NULL
            UNION ALL
            SELECT id, unnest(ta_names_translit) FROM ingredient_catalog WHERE ta_names_translit IS NOT NULL
            UNION ALL
            SELECT id, unnest(en_synonyms) FROM ingredient_catalog WHERE en_synonyms IS NOT NULL
        ),
        scored AS (
            SELECT id,
                   similarity(LOWER(candidate_name), LOWER(:q)) AS sim_score,
                   soundex(candidate_name) = soundex(:q) AS soundex_hit
            FROM name_candidates
            WHERE candidate_name IS NOT NULL AND candidate_name != ''
        ),
        best AS (
            SELECT id, MAX(sim_score) AS best_score
            FROM scored
            WHERE sim_score > 0.1 OR (soundex_hit AND sim_score >= 0.08)
            GROUP BY id
        )
        SELECT
            ic.id, ic.name_en, ic.name_ta, ic.ta_names, ic.ta_names_translit,
            ic.category, ic.emoji, ic.image_url,
            COALESCE(hp.is_available, false) AS is_available,
            b.best_score
        FROM best b
        JOIN ingredient_catalog ic ON ic.id = b.id
        LEFT JOIN household_pantry hp
            ON hp.ingredient_id = ic.id
            AND hp.house_id = CAST(:hid AS uuid)
        ORDER BY b.best_score DESC, ic.name_en
        LIMIT 30
    """), {"q": q, "hid": house_id}).fetchall()

    return {
        "results": [
            {
                "id":                r.id,
                "name_en":           r.name_en,
                "name_ta":           r.name_ta,
                "ta_names":          list(r.ta_names) if r.ta_names else [],
                "ta_names_translit": list(r.ta_names_translit) if r.ta_names_translit else [],
                "category":          r.category,
                "emoji":             r.emoji or "🥬",
                "image_url":         r.image_url,
                "is_available":      r.is_available,
            }
            for r in rows
        ]
    }


# ── POST /pantry/save ─────────────────────────────────────────────────────────

class PantryItem(BaseModel):
    ingredient_id: int
    is_available:  bool

class SavePantryRequest(BaseModel):
    items: List[PantryItem]

@router.post("/save", status_code=200)
async def save_pantry(
    req: SavePantryRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Upsert household's ingredient availability.
    Sends full list of changes — only modified items need to be sent.
    """
    house_id = current_user["house_id"]

    if not req.items:
        return {"message": "No items to save.", "saved": 0}

    saved = 0
    try:
        for item in req.items:
            db.execute(text("""
                INSERT INTO household_pantry (house_id, ingredient_id, is_available, updated_at)
                VALUES (CAST(:hid AS uuid), :iid, :avail, NOW())
                ON CONFLICT (house_id, ingredient_id)
                DO UPDATE SET
                    is_available = EXCLUDED.is_available,
                    updated_at   = NOW()
            """), {
                "hid":   house_id,
                "iid":   item.ingredient_id,
                "avail": item.is_available,
            })
            saved += 1
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Invalid ingredient: {str(e)}")
    return {"message": "Pantry saved.", "saved": saved}


# ── GET /pantry/summary ───────────────────────────────────────────────────────

@router.get("/summary", status_code=200)
async def get_pantry_summary(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Returns a lightweight summary — total available ingredients per category.
    Used by Dashboard tile and recommendation engine.
    """
    house_id = current_user["house_id"]

    rows = db.execute(text("""
        SELECT
            ic.category,
            COUNT(*) as available_count
        FROM household_pantry hp
        JOIN ingredient_catalog ic ON ic.id = hp.ingredient_id
        WHERE hp.house_id = CAST(:hid AS uuid)
        AND hp.is_available = true
        GROUP BY ic.category
        ORDER BY ic.category
    """), {"hid": house_id}).fetchall()

    total = sum(r.available_count for r in rows)

    return {
        "total_available": total,
        "by_category": [
            {"category": r.category, "count": r.available_count}
            for r in rows
        ]
    }
