import uuid
from sqlalchemy import text
from sqlalchemy.orm import Session

def get_dietary_pref(db: Session, h_id: str):
    query = text("SELECT dietary_preference FROM household_master WHERE household_id = CAST(:h_id AS uuid)")
    result = db.execute(query, {"h_id": h_id}).fetchone()
    return result[0] if result else "Veg"

def get_suggestions(db: Session, pref: str):
    filter_sql = "WHERE r.diet_type IN ('Veg', 'Vegan')" if pref == "Veg" else "WHERE 1=1"
    # CRUX: Added JOIN to fetch image URLs
    query = text(f"""
        SELECT r.dish_name, r.recipe_code, v.hero_image_url, v.carousel_thumb_url 
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        {filter_sql} 
        ORDER BY RANDOM() LIMIT 20
    """)
    rows = db.execute(query).fetchall()
    return [{"name": r[0], "code": r[1], "hero": r[2], "thumb": r[3]} for r in rows]

def check_momentum_divergence(db: Session, r_id: str, h_id: str):
    query = text("""
        SELECT COUNT(*) 
        FROM recipe_dna_master r
        JOIN ingredient_master im ON r.primary_staple_id = CAST(im.id AS text)
        JOIN household_master hm ON hm.household_id = CAST(:h_id AS uuid)
        JOIN price_logs pl ON pl.ingredient_id = im.id 
             AND pl.location_id = (SELECT id FROM market_locations WHERE location_name = hm.primary_region LIMIT 1)
        WHERE r.recipe_id = CAST(:r_id AS uuid)
          AND pl.recorded_price >= im.peak_threshold
          AND pl.recorded_at = (SELECT MAX(recorded_at) FROM price_logs WHERE ingredient_id = im.id)
    """)
    result = db.execute(query, {"r_id": r_id, "h_id": h_id}).scalar()
    return result > 0

def execute_audit(db: Session, h_id: str, changes: list):
    pantry_rows = db.execute(text("""
        SELECT staple_id FROM household_inventory 
        WHERE house_id = CAST(:h_id AS uuid) AND stock_status = 'In-Stock'
    """), {"h_id": h_id}).fetchall()
    pantry_stock = [row[0] for row in pantry_rows]

    results = []
    for item in changes:
        recipe_row = db.execute(text("""
            SELECT r.recipe_id, r.primary_staple_id, s.item_name 
            FROM recipe_dna_master r
            LEFT JOIN staple_master_registry s ON r.primary_staple_id = s.staple_id
            WHERE r.dish_name = :d_name
        """), {"d_name": item.to_meal}).fetchone()
        
        is_valid, msg = True, f"{item.to_meal} verified."
        is_peaked = False
        
        if recipe_row:
            r_id = str(recipe_row[0])
            if recipe_row[1] and recipe_row[1] not in pantry_stock:
                is_valid, msg = False, f"Missing: {recipe_row[2] or recipe_row[1]}"
            is_peaked = check_momentum_divergence(db, r_id, h_id)
        elif item.to_meal == "Skipped":
            msg = "Meal skipped."
        else:
            is_valid, msg = False, "Dish Not Found"
            
        results.append({
            "day": item.day, 
            "type": item.type, 
            "isAvailable": is_valid, 
            "isPeaked": is_peaked,
            "message": msg
        })
    return results

def persist_plan(db: Session, h_id: str, plan: list):
    db.execute(text("""
        UPDATE weekly_planning_session 
        SET session_status = 'Plan Locked' 
        WHERE house_id = CAST(:h_id AS uuid) AND session_status = 'Draft'
    """), {"h_id": h_id})

    for item in plan:
        header = db.execute(text("""
            SELECT event_id FROM meal_event_header 
            WHERE event_date = :e_date AND house_id = CAST(:h_id AS uuid) 
            AND CAST(meal_slot AS text) = :slot
        """), {"e_date": item.date, "h_id": h_id, "slot": item.type}).fetchone()

        e_id = str(header[0]) if header else str(uuid.uuid4())
        
        if not header:
            db.execute(text("""
                INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date)
                VALUES (CAST(:e_id AS uuid), CAST(:h_id AS uuid), :slot, :e_date)
            """), {"e_id": e_id, "h_id": h_id, "slot": item.type, "e_date": item.date})

        recipe = db.execute(text("SELECT recipe_id FROM recipe_dna_master WHERE dish_name ILIKE :d_name"), 
                            {"d_name": item.meal_name}).fetchone()
        
        db.execute(text("DELETE FROM meal_event_detail WHERE event_id = CAST(:e_id AS uuid)"), {"e_id": e_id})
        
        if recipe:
            action = 'Accepted' 
            db.execute(text("""
                INSERT INTO meal_event_detail (detail_id, event_id, recipe_id, action_taken)
                VALUES (CAST(:d_id AS uuid), CAST(:e_id AS uuid), CAST(:r_id AS uuid), CAST(:action AS user_action))
            """), {
                "d_id": str(uuid.uuid4()), 
                "e_id": e_id, 
                "r_id": str(recipe[0]),
                "action": action
            })
    db.commit()

def fetch_plan(db: Session, h_id: str):
    # CRUX: Added JOIN to fetch images for the existing plan
    query = text("""
        SELECT h.event_date, CAST(h.meal_slot AS text), r.dish_name, r.recipe_code, v.hero_image_url, v.carousel_thumb_url
        FROM meal_event_header h
        JOIN meal_event_detail d ON h.event_id = d.event_id
        JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
    """)
    rows = db.execute(query, {"h_id": h_id}).fetchall()
    return {"plan": [{"date": str(r[0]), "type": r[1], "meal_name": r[2], "code": r[3], "hero": r[4], "thumb": r[5]} for r in rows]}