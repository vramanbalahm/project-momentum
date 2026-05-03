from fastapi import FastAPI, Depends, HTTPException, Security
from auth.dependencies import get_current_user
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
import uuid
from dotenv import load_dotenv
load_dotenv()  # Load backend/.env on startup

# FT-033: Updated imports — plan_service now lives in services/
from services.plan_service import (
    fetch_active_plan,
    get_suggestions,
    execute_audit,
    persist_plan,
    get_dietary_pref,
    get_session_constants
)
from services.audit_service import check_pantry_availability, check_momentum_divergence
from database import SessionLocal, engine
from schemas import AuditItem, SavePlanRequest

from fastapi.middleware.cors import CORSMiddleware

# app = FastAPI()
app = FastAPI(title="Momentum Food Scheduler — MVP")

# Serve recipe images as static files — http://localhost:8000/recipe_images/{recipe_id}.jpg
RECIPE_IMAGES_DIR = Path(__file__).resolve().parent / "recipe_images"
RECIPE_IMAGES_DIR.mkdir(exist_ok=True)
app.mount("/recipe_images", StaticFiles(directory=str(RECIPE_IMAGES_DIR)), name="recipe_images")

# Allow frontend origin to talk to backend
import os
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "http://localhost:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ACTIVE_H_ID removed — all endpoints now use get_current_user from JWT token (auth wired FT-001)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 1. CORE SUGGESTIONS & PREFERENCES ---

@app.get("/generate-suggestions/{household_id}")
async def generate_suggestions(
    household_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Standardized to use price_logs. house_id from authenticated user."""
    h_id = current_user["house_id"]
    pref = get_dietary_pref(db, h_id)
    return get_suggestions(db, pref, h_id)

# --- 2. AUDIT & INVENTORY ---

@app.post("/audit")
async def run_audit(
    changes: List[AuditItem],
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Calculates impact of inventory changes. house_id from authenticated user."""
    return execute_audit(db, current_user["house_id"], changes)

@app.post("/inventory/update")
def set_inventory(h_id: str, s_id: str, status: str, db: Session = Depends(get_db)):
    """Standardized to use the new staple_id (Varchar)."""
    # update_inventory_status kept as stub — FT-010 will implement fully
    return {"message": "Inventory updated successfully"}

# --- 3. PLAN PERSISTENCE (FT-033: Multi-dish) ---

@app.post("/save-plan")
async def save_plan(
    request: SavePlanRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    try:
        # FT-033: persist_plan handles main + sides per slot. house_id from authenticated user.
        return persist_plan(db, current_user["house_id"], request.plan)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/get-plan/{household_id}")
async def get_plan(
    household_id: str,
    week_start: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """FT-033: Returns grouped plan — main + sides per slot.
    week_start (YYYY-MM-DD): if provided, returns plan for that specific week only.
    If omitted, returns current week records. house_id from authenticated user.
    """
    plan = fetch_active_plan(db, current_user["house_id"], week_start=week_start)
    return plan

# --- 4. MARKET SIGNALS & CONTENT VAULT ---

@app.get("/market/signals")
def get_market_signals(db: Session = Depends(get_db)):
    """Wave 5 Divergence monitor — FT-054."""
    query = text("""
        SELECT item_name, recorded_price, momentum_status 
        FROM market_signal_dashboard
        WHERE recorded_at >= CURRENT_DATE - INTERVAL '1 day'
    """)
    results = db.execute(query).fetchall()
    return [
        {
            "item": r[0],
            "price": float(r[1]),
            "status": r[2],
            "alert": (r[2] == 'DIVERGENCE')
        } for r in results
    ]

@app.get("/recipe/{recipe_id}/vault")
def get_recipe_details(recipe_id: str, db: Session = Depends(get_db)):
    """Content vault — hero_image and prep_steps."""
    query = text("""
        SELECT hero_image_url, carousel_thumb_url, prep_steps, ingredients_json, video_url
        FROM recipe_content_vault 
        WHERE recipe_id = :r_id
    """)
    result = db.execute(query, {"r_id": recipe_id}).fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="Recipe content not found")
    return {"hero": result[0], "thumb": result[1], "steps": result[2], "ingredients_json": result[3], "video_url": result[4]}

# --- 5. SESSION CONSTANTS (fetched once on load) ---
@app.get("/session-constants/{household_id}")
async def session_constants(
    household_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Single call on app load — returns oldest_plan_week, dietary_preference, member_count.
    Frontend caches these for the session. house_id from authenticated user.
    """
    return get_session_constants(db, current_user["house_id"])

# --- 5b. AUTH ROUTER ---
from routers.auth import router as auth_router
app.include_router(auth_router)

# --- Lookup router — cuisine_regions and cities for registration dropdowns ---
from routers.lookup import router as lookup_router
app.include_router(lookup_router)

# --- 5d. ONBOARDING ROUTER (schema v12) ---
from routers.onboarding import router as onboarding_router
app.include_router(onboarding_router)

# --- 6. WEEKLY PLAN ROUTER (FT-030) ---
from routers.weekly_plan import router as weekly_plan_router
app.include_router(weekly_plan_router)

# --- 6c. MEMBER AVAILABILITY ROUTER ---
from routers.availability import router as availability_router
app.include_router(availability_router)

# --- RECIPE REVIEW ENDPOINTS ---

@app.get("/recipes/review")
async def get_recipes_for_review(
    status: str = "under_review",
    diet: str = None,
    meal_slot: str = None,
    sub_region: str = None,
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Returns paginated recipe list for review screen.
    Accessible to platform_admin and reviewer roles only.
    """
    role = current_user["role"]
    if role not in ("platform_admin", "reviewer"):
        raise HTTPException(status_code=403, detail="Recipe review access denied.")

    conditions = []
    params = {"status": status, "offset": (page - 1) * page_size, "limit": page_size}

    if status != "all":
        conditions.append("r.review_status = :status")
    if diet:
        conditions.append("r.diet_type::text = :diet")
        params["diet"] = diet
    if meal_slot:
        conditions.append(":meal_slot = ANY(r.meal_slots)")
        params["meal_slot"] = meal_slot
    if sub_region:
        conditions.append("r.sub_region ILIKE :sub_region")
        params["sub_region"] = f"%{sub_region}%"

    where = "WHERE " + " AND ".join(conditions) if conditions else ""

    rows = db.execute(text(f"""
        SELECT
            r.recipe_id, r.dish_name, r.regional_name, r.sub_region,
            r.diet_type::text as diet_type, r.is_sattvic, r.is_vegan,
            r.intensity_level, r.meal_slots, r.review_status,
            r.reviewed_at, r.review_notes,
            v.hero_image_url, v.image_generation_count,
            COUNT(*) OVER() as total_count
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        {where}
        ORDER BY r.sub_region, r.dish_name
        LIMIT :limit OFFSET :offset
    """), params).fetchall()

    total = rows[0].total_count if rows else 0

    return {
        "total": total,
        "page": page,
        "page_size": page_size,
        "recipes": [{
            "recipe_id":        str(r.recipe_id),
            "dish_name":        r.dish_name,
            "regional_name":    r.regional_name,
            "sub_region":       r.sub_region,
            "diet_type":        r.diet_type,
            "is_sattvic":       r.is_sattvic,
            "is_vegan":         r.is_vegan,
            "intensity_level":  r.intensity_level,
            "meal_slots":       r.meal_slots,
            "review_status":    r.review_status,
            "reviewed_at":      str(r.reviewed_at) if r.reviewed_at else None,
            "review_notes":     r.review_notes,
            "hero_image_url":   r.hero_image_url,
            "image_generation_count": r.image_generation_count or 0,
        } for r in rows]
    }


@app.get("/recipes/{recipe_id}/detail")
async def get_recipe_detail(
    recipe_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Full recipe detail for review edit sheet."""
    role = current_user["role"]
    if role not in ("platform_admin", "reviewer"):
        raise HTTPException(status_code=403, detail="Access denied.")

    r = db.execute(text("""
        SELECT
            r.recipe_id, r.dish_name, r.regional_name, r.sub_region,
            r.diet_type::text, r.is_sattvic, r.is_vegan, r.intensity_level,
            r.meal_slots, r.is_scalable, r.is_regional_specific,
            r.prep_time_mins, r.cook_time_mins, r.serves, r.tags,
            r.review_status, r.review_notes,
            v.hero_image_url, v.prep_steps, v.youtube_urls,
            v.image_generation_count
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON v.recipe_id = r.recipe_id
        WHERE r.recipe_id = CAST(:rid AS uuid)
    """), {"rid": recipe_id}).fetchone()

    if not r:
        raise HTTPException(status_code=404, detail="Recipe not found.")

    # Fetch ingredients
    ingredients = db.execute(text("""
        SELECT ri.ingredient_id, ic.name_en, ic.name_ta, ic.category,
               ri.quantity, ri.unit, ri.is_optional, ri.sort_order
        FROM recipe_ingredients ri
        JOIN ingredient_catalog ic ON ic.id = ri.ingredient_id
        WHERE ri.recipe_id = CAST(:rid AS uuid)
        ORDER BY ri.sort_order
    """), {"rid": recipe_id}).fetchall()

    return {
        "recipe_id":            str(r.recipe_id),
        "dish_name":            r.dish_name,
        "regional_name":        r.regional_name,
        "sub_region":           r.sub_region,
        "diet_type":            r.diet_type,
        "is_sattvic":           r.is_sattvic,
        "is_vegan":             r.is_vegan,
        "intensity_level":      r.intensity_level,
        "meal_slots":           r.meal_slots,
        "is_scalable":          r.is_scalable,
        "is_regional_specific": r.is_regional_specific,
        "prep_time_mins":       r.prep_time_mins,
        "cook_time_mins":       r.cook_time_mins,
        "serves":               r.serves,
        "tags":                 r.tags,
        "review_status":        r.review_status,
        "review_notes":         r.review_notes,
        "hero_image_url":       r.hero_image_url,
        "prep_steps":           r.prep_steps,
        "youtube_urls":         r.youtube_urls or [],
        "image_generation_count": r.image_generation_count or 0,
        "ingredients": [{
            "ingredient_id": ing.ingredient_id,
            "name_en":       ing.name_en,
            "name_ta":       ing.name_ta,
            "category":      ing.category,
            "quantity":      ing.quantity,
            "unit":          ing.unit,
            "is_optional":   ing.is_optional,
            "sort_order":    ing.sort_order,
        } for ing in ingredients]
    }


@app.put("/recipes/{recipe_id}/review")
async def update_recipe_review(
    recipe_id: str,
    payload: dict,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Update recipe details + review status.
    Accessible to platform_admin and reviewer.
    """
    role = current_user["role"]
    if role not in ("platform_admin", "reviewer"):
        raise HTTPException(status_code=403, detail="Access denied.")

    user_id = current_user["user_id"]

    # Update recipe_dna_master fields
    db.execute(text("""
        UPDATE recipe_dna_master SET
            dish_name            = COALESCE(:dish_name, dish_name),
            regional_name        = COALESCE(:regional_name, regional_name),
            sub_region           = COALESCE(:sub_region, sub_region),
            diet_type            = COALESCE(:diet_type::diet_pref, diet_type),
            is_sattvic           = COALESCE(:is_sattvic, is_sattvic),
            is_vegan             = COALESCE(:is_vegan, is_vegan),
            intensity_level      = COALESCE(:intensity_level, intensity_level),
            meal_slots           = COALESCE(:meal_slots, meal_slots),
            is_scalable          = COALESCE(:is_scalable, is_scalable),
            is_regional_specific = COALESCE(:is_regional_specific, is_regional_specific),
            review_status        = COALESCE(:review_status, review_status),
            review_notes         = COALESCE(:review_notes, review_notes),
            reviewed_by          = CAST(:reviewed_by AS uuid),
            reviewed_at          = NOW()
        WHERE recipe_id = CAST(:recipe_id AS uuid)
    """), {
        "dish_name":            payload.get("dish_name"),
        "regional_name":        payload.get("regional_name"),
        "sub_region":           payload.get("sub_region"),
        "diet_type":            payload.get("diet_type"),
        "is_sattvic":           payload.get("is_sattvic"),
        "is_vegan":             payload.get("is_vegan"),
        "intensity_level":      payload.get("intensity_level"),
        "meal_slots":           payload.get("meal_slots"),
        "is_scalable":          payload.get("is_scalable"),
        "is_regional_specific": payload.get("is_regional_specific"),
        "review_status":        payload.get("review_status"),
        "review_notes":         payload.get("review_notes"),
        "reviewed_by":          user_id,
        "recipe_id":            recipe_id,
    })

    # Update recipe_content_vault fields
    db.execute(text("""
        UPDATE recipe_content_vault SET
            prep_steps    = COALESCE(:prep_steps, prep_steps),
            youtube_urls  = COALESCE(:youtube_urls, youtube_urls),
            hero_image_url = COALESCE(:hero_image_url, hero_image_url)
        WHERE recipe_id = CAST(:recipe_id AS uuid)
    """), {
        "prep_steps":   payload.get("prep_steps"),
        "youtube_urls": payload.get("youtube_urls"),
        "hero_image_url": payload.get("hero_image_url"),
        "recipe_id":    recipe_id,
    })

    # Update ingredient optional flags if provided
    if payload.get("ingredients"):
        for ing in payload["ingredients"]:
            db.execute(text("""
                UPDATE recipe_ingredients
                SET is_optional = :is_optional
                WHERE recipe_id = CAST(:recipe_id AS uuid)
                  AND ingredient_id = :ingredient_id
            """), {
                "is_optional":    ing.get("is_optional", False),
                "recipe_id":      recipe_id,
                "ingredient_id":  ing.get("ingredient_id"),
            })

    db.commit()
    return {"message": "Recipe updated successfully.", "recipe_id": recipe_id}


@app.post("/recipes/bulk-approve")
async def bulk_approve_recipes(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Bulk approve multiple recipes at once."""
    role = current_user["role"]
    if role not in ("platform_admin", "reviewer"):
        raise HTTPException(status_code=403, detail="Access denied.")

    recipe_ids = payload.get("recipe_ids", [])
    if not recipe_ids:
        raise HTTPException(status_code=400, detail="No recipe IDs provided.")

    user_id = current_user["user_id"]
    count = 0
    for rid in recipe_ids:
        db.execute(text("""
            UPDATE recipe_dna_master
            SET review_status = 'approved',
                reviewed_by   = CAST(:uid AS uuid),
                reviewed_at   = NOW()
            WHERE recipe_id = CAST(:rid AS uuid)
        """), {"uid": user_id, "rid": rid})
        count += 1

    db.commit()
    return {"message": f"{count} recipes approved.", "count": count}


# --- RECIPE IMAGE GENERATION ENDPOINT ---
@app.post("/recipes/{recipe_id}/generate-image")
async def generate_recipe_image(
    recipe_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Generate image for a recipe using Gemini Imagen.
    QA role: max 2 generations per recipe.
    Platform admin: unlimited.
    """
    import subprocess, sys, os
    from pathlib import Path

    role = current_user["role"]
    user_id = current_user["user_id"]
    is_platform_admin = role == "platform_admin"

    # Fetch current generation count
    row = db.execute(text("""
        SELECT image_generation_count, hero_image_url
        FROM recipe_content_vault
        WHERE recipe_id = CAST(:rid AS uuid)
    """), {"rid": recipe_id}).fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="Recipe not found.")

    gen_count = row.image_generation_count or 0

    # Enforce 2-attempt limit for non-platform-admin
    if not is_platform_admin and gen_count >= 2:
        raise HTTPException(
            status_code=403,
            detail="Maximum 2 image generations allowed per recipe. Contact platform admin for further changes."
        )

    # Fetch recipe details for prompt
    recipe = db.execute(text("""
        SELECT
            r.dish_name,
            r.regional_name,
            r.sub_region,
            r.diet_type::text as diet_type,
            r.meal_slots,
            COALESCE(
                array_agg(ic.name_en ORDER BY ri.sort_order)
                FILTER (WHERE ic.name_en IS NOT NULL AND ri.is_optional = false),
                ARRAY[]::text[]
            ) as main_ingredients
        FROM recipe_dna_master r
        LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.recipe_id
        LEFT JOIN ingredient_catalog ic ON ic.id = ri.ingredient_id
        WHERE r.recipe_id = CAST(:rid AS uuid)
        GROUP BY r.recipe_id, r.dish_name, r.regional_name,
                 r.sub_region, r.diet_type, r.meal_slots
    """), {"rid": recipe_id}).fetchone()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe details not found.")

    # Run image generation script as subprocess
    script_path = Path(__file__).resolve().parent / "scripts" / "generate_recipe_images.py"
    result = subprocess.run(
        [sys.executable, str(script_path), "--recipe_id", recipe_id, "--force", "--model", "gemini-2.5-flash-image"],
        capture_output=True, text=True,
        cwd=str(Path(__file__).resolve().parent)
    )

    if result.returncode != 0:
        raise HTTPException(status_code=500, detail=f"Image generation failed: {result.stderr}")

    # Update generation count and metadata
    db.execute(text("""
        UPDATE recipe_content_vault
        SET image_generation_count = COALESCE(image_generation_count, 0) + 1,
            image_last_generated_at = NOW(),
            image_generated_by = CAST(:uid AS uuid)
        WHERE recipe_id = CAST(:rid AS uuid)
    """), {"uid": user_id, "rid": recipe_id})
    db.commit()

    # Return updated image URL
    updated = db.execute(text("""
        SELECT hero_image_url, image_generation_count
        FROM recipe_content_vault
        WHERE recipe_id = CAST(:rid AS uuid)
    """), {"rid": recipe_id}).fetchone()

    return {
        "message": "Image generated successfully.",
        "recipe_id": recipe_id,
        "hero_image_url": updated.hero_image_url,
        "generation_count": updated.image_generation_count,
        "attempts_remaining": max(0, 2 - updated.image_generation_count) if not is_platform_admin else "unlimited"
    }

# --- DEV ONLY: Reset current week plan ---
@app.delete("/dev/reset-week")
async def dev_reset_week(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Platform admin only — Deletes all plan data for the current week for this household.
    Removes meal_event_header (cascades to detail + audit), meal_attendance_log,
    and weekly_planning_session. Takes user back to a clean slate.
    Future: expose to household_admin as "Start over this week" feature.
    """
    # TODO: restrict to platform_admin before release
    # Currently open to household_admin for testing
    if current_user["role"] not in ("platform_admin", "household_admin"):
        from fastapi import HTTPException
        raise HTTPException(status_code=403, detail="Admin access only.")
    from datetime import date, timedelta
    house_id = current_user["house_id"]
    today = date.today()
    week_start = today - timedelta(days=today.weekday())  # Monday
    week_end   = week_start + timedelta(days=6)

    # Delete meal events for this week
    db.execute(text("""
        DELETE FROM meal_event_header
        WHERE house_id = CAST(:hid AS uuid)
          AND event_date BETWEEN :start AND :end
    """), {"hid": house_id, "start": week_start, "end": week_end})

    # Delete weekly planning session (cascades to meal_attendance_log)
    db.execute(text("""
        DELETE FROM weekly_planning_session
        WHERE house_id = CAST(:hid AS uuid)
          AND week_start_date = :start
    """), {"hid": house_id, "start": week_start})

    db.commit()
    return {"message": f"Week of {week_start} cleared for household.", "week_start": str(week_start)}

# --- 6b. FT-043: MEAL SWAP & STANDALONE AUDIT ---
from services.swap_service import execute_swap, audit_slot

@app.post("/meal/swap")
def swap_meals(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Generic meal slot swap. Works for within-day and cross-day.
    Day swap: caller loops over meal types, sends one request per type.
    payload: { source: {day, type, date}, target: {day, type, date} }
    house_id from authenticated user.
    """
    return execute_swap(
        db=db,
        h_id=current_user["house_id"],
        source=payload["source"],
        target=payload["target"]
    )

@app.post("/meal/audit-slot")
def audit_meal_slot(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Standalone slot audit — callable anytime, anywhere.
    payload: { date: YYYY-MM-DD, meal_slot: Breakfast|Lunch|Dinner }
    house_id from authenticated user.
    """
    return audit_slot(
        db=db,
        h_id=current_user["house_id"],
        event_date=payload["date"],
        meal_slot=payload["meal_slot"]
    )

# --- 7. FT-040: RECIPE SEARCH ---
@app.get("/recipes/search")
def search_recipes(q: str = "", db: Session = Depends(get_db)):
    """
    Fuzzy search on recipe_dna_master using pg_trgm trigram similarity.
    Handles misspellings, partial words, and phonetically close inputs.
    Empty query returns all recipes ordered by name.
    """
    if not q:
        query = text("""
            SELECT
                r.recipe_id, r.dish_name, r.diet_type, r.is_sattvic,
                r.intensity_level, v.carousel_thumb_url, v.hero_image_url,
                v.prep_steps, v.ingredients_json
            FROM recipe_dna_master r
            LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
            ORDER BY r.dish_name
            LIMIT 30
        """)
        rows = db.execute(query).fetchall()
    else:
        query = text("""
            SELECT
                r.recipe_id, r.dish_name, r.diet_type, r.is_sattvic,
                r.intensity_level, v.carousel_thumb_url, v.hero_image_url,
                v.prep_steps, v.ingredients_json,
                similarity(LOWER(r.dish_name), LOWER(:q)) AS sim_score
            FROM recipe_dna_master r
            LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
            WHERE
                similarity(LOWER(r.dish_name), LOWER(:q)) > 0.1
                OR LOWER(r.dish_name) LIKE LOWER(:pattern)
            ORDER BY sim_score DESC, r.dish_name
            LIMIT 30
        """)
        rows = db.execute(query, {"q": q, "pattern": f"%{q}%"}).fetchall()
    return [
        {
            "recipe_id": str(row[0]),
            "name": row[1],
            "diet_type": row[2],
            "is_sattvic": row[3],
            "intensity_level": row[4],
            "thumb": row[5],
            "hero": row[6],
            "prep_steps": row[7],
            "ingredients_json": row[8]
        }
        for row in rows
    ]

# --- 8. FT-041: MEAL SLOT EDIT ---
@app.post("/meal-slot/edit")
def edit_meal_slot(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Replace a dish in a meal slot and log to behavioral_tracker.
    payload: {
        event_id, house_id, event_date, meal_slot,
        dish_type (Main/Side), dish_sequence,
        original_recipe_id, new_recipe_id,
        swap_reason, swap_reason_text,
        week_start_date
    }
    """
    h_id = current_user["house_id"]

    # 1. Update meal_event_detail — replace the recipe for this dish
    db.execute(text("""
        UPDATE meal_event_detail
        SET recipe_id = CAST(:new_recipe_id AS uuid),
            action_taken = 'Changed'
        WHERE event_id = CAST(:event_id AS uuid)
          AND dish_sequence = :dish_sequence
    """), {
        "new_recipe_id": payload["new_recipe_id"],
        "event_id": payload["event_id"],
        "dish_sequence": payload["dish_sequence"]
    })

    # 2. Log to behavioral_tracker
    db.execute(text("""
        INSERT INTO behavioral_tracker
            (house_id, week_start_date, event_date, meal_slot,
             original_recipe_id, new_recipe_id,
             swap_reason, swap_reason_text, dish_type)
        VALUES
            (CAST(:h_id AS uuid), CAST(:week_start AS date), CAST(:event_date AS date),
             CAST(:meal_slot AS meal_slot_type),
             CAST(:orig AS uuid), CAST(:new AS uuid),
             :reason, :reason_text, :dish_type)
    """), {
        "h_id": h_id,
        "week_start": payload["week_start_date"],
        "event_date": payload["event_date"],
        "meal_slot": payload["meal_slot"],
        "orig": payload.get("original_recipe_id"),
        "new": payload["new_recipe_id"],
        "reason": payload.get("swap_reason", "Other"),
        "reason_text": payload.get("swap_reason_text", ""),
        "dish_type": payload.get("dish_type", "Main")
    })

    db.commit()
    return {"status": "success"}

# --- 9. FT-033: ADD SIDE DISH TO SLOT ---
@app.post("/meal-slot/add-side")
def add_side_dish(payload: dict, db: Session = Depends(get_db)):
    """
    Add a new side dish to an existing meal slot.
    payload: { event_id, recipe_id }
    """
    # Get current max dish_sequence for this event
    result = db.execute(text("""
        SELECT COALESCE(MAX(dish_sequence), 1)
        FROM meal_event_detail
        WHERE event_id = CAST(:event_id AS uuid)
    """), {"event_id": payload["event_id"]}).scalar()

    next_seq = result + 1

    db.execute(text("""
        INSERT INTO meal_event_detail
            (event_id, recipe_id, action_taken, dish_type, dish_sequence)
        VALUES
            (CAST(:event_id AS uuid), CAST(:recipe_id AS uuid), 'Accepted', 'Side', :seq)
    """), {
        "event_id": payload["event_id"],
        "recipe_id": payload["recipe_id"],
        "seq": next_seq
    })

    db.commit()
    return {"status": "success", "dish_sequence": next_seq}

# --- 10. FT-033: DELETE SIDE DISH FROM SLOT ---
@app.delete("/meal-slot/remove-side")
def remove_side_dish(event_id: str, dish_sequence: int, db: Session = Depends(get_db)):
    """Remove a side dish by event_id + dish_sequence."""
    db.execute(text("""
        DELETE FROM meal_event_detail
        WHERE event_id = CAST(:event_id AS uuid)
          AND dish_sequence = :seq
          AND dish_type = 'Side'
    """), {"event_id": event_id, "seq": dish_sequence})
    db.commit()
    return {"status": "success"}
