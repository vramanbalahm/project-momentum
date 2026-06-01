# routers/pantry.py — My Pantry endpoints
#
# GET  /pantry/ingredients  — returns all ingredients grouped by category
#                             with household's current availability status
# POST /pantry/save         — save household's ingredient availability

from fastapi import APIRouter, Depends, HTTPException
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
