from sqlalchemy.orm import Session
from sqlalchemy import text
import uuid

# --- 1. PLAN RETRIEVAL (Sprint 3: DB-First Logic) ---
def fetch_active_plan(db: Session, h_id: str):
    clean_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if h_id == "HOUSEHOLD_001" else h_id
    
    query = text("""
        SELECT 
            h.event_date as date, 
            CAST(h.meal_slot AS text) as slot, 
            r.dish_name as name, 
            r.recipe_code as code, 
            v.hero_image_url as hero, 
            v.carousel_thumb_url as thumb,
            v.prep_steps as steps,
            d.recipe_id
        FROM meal_event_header h
        LEFT JOIN meal_event_detail d ON h.event_id = d.event_id
        LEFT JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
        ORDER BY h.event_date ASC, h.meal_slot DESC
    """)
    
    rows = db.execute(query, {"h_id": clean_h_id}).fetchall()
    
    return {
        "plan": [
            {
                "date": str(r.date), 
                "type": r.slot, 
                "name": r.name if r.name else "Skipped", 
                "recipe_id": str(r.recipe_id) if r.recipe_id else "",
                "hero": r.hero,   # Maps to hero_image_url from script
                "thumb": r.thumb, # Maps to carousel_thumb_url from script
                "steps": r.steps  # Maps to prep_steps from script
            } for r in rows
        ]
    }
# --- 2. SUGGESTIONS & SCORING (Fixed: UUID Capture) ---
def get_suggestions(db: Session, pref: str, h_id: str):
    current_pref = str(pref).strip() if pref else "Veg"
    test_uuid = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" 
    clean_h_id = test_uuid if h_id == "HOUSEHOLD_001" else h_id



    filter_sql = "AND r.diet_type IN ('Veg', 'Vegan')" if current_pref == "Veg" else ""

    query = text(f"""
        SELECT 
            r.dish_name, 
            r.recipe_code, 
            v.hero_image_url, 
            v.carousel_thumb_url,
            (100 + 
                CASE WHEN inv.stock_status = 'In-Stock' THEN 50 ELSE 0 END - 
                CASE WHEN lp.recorded_price >= s.peak_threshold AND s.peak_threshold > 0 THEN 80 ELSE 0 END
            ) as match_score,
            r.recipe_id  -- Crucial: Added for UUID persistence
        FROM recipe_dna_master r
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        LEFT JOIN staple_master_registry s ON r.primary_staple_id = s.staple_id
        LEFT JOIN household_inventory inv ON s.staple_id = inv.staple_id 
            AND inv.house_id = CAST(:h_id AS uuid)
        LEFT JOIN LATERAL (
            SELECT recorded_price FROM price_logs 
            WHERE staple_id = s.staple_id 
            ORDER BY recorded_at DESC LIMIT 1
        ) lp ON TRUE
        WHERE 1=1 {filter_sql}
        ORDER BY match_score DESC
        LIMIT 20
    """)

    rows = db.execute(query, {"h_id": clean_h_id}).fetchall()
    return [{
        "name": r[0], 
        "code": r[1], 
        "hero": r[2], 
        "thumb": r[3], 
        "score": r[4],
        "recipe_id": str(r[5]) 
    } for r in rows]

# --- 3. AUDIT LOGIC (Highlights) ---
def execute_audit(db: Session, h_id: str, changes: list):
    result_map = []
    seen_meals = {} 

    for change in changes:
        status = "Success"
        message = "Ready"
        score = 90
        
        if change.to_meal in seen_meals and change.to_meal != "Skipped":
            status = "Conflict"
            message = f"Divergence: {change.to_meal} is repeated. High fatigue risk!"
            score = 40
        elif "Paneer" in (change.to_meal or ""):
            status = "Warning"
            message = "Single Challenge: Heavy protein load for this slot."
            score = 65
            
        seen_meals[change.to_meal] = True
        
        result_map.append({
            "day": change.day,
            "type": change.type,
            "status": status,
            "message": message,
            "score": score
        })
    
    return result_map

# --- 4. PERSISTENCE (Continuous Save Shield) ---
from uuid import uuid4
from sqlalchemy import text

def persist_plan(db: Session, h_id: str, plan_data: list):
    clean_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if h_id == "HOUSEHOLD_001" else h_id
    
    try:
        # 1. Purge existing operational records
        db.execute(
            text("DELETE FROM meal_event_header WHERE house_id = CAST(:h_id AS uuid)"),
            {"h_id": clean_h_id}
        )

        for entry in plan_data:
            if not entry.recipe_id:
                continue

            new_event_id = uuid4()

            # 2. Update Operational Tables (Header)
            db.execute(
                text("""
                    INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date)
                    VALUES (:e_id, CAST(:h_id AS uuid), CAST(:slot AS meal_slot_type), CAST(:dt AS date))
                """),
                {"e_id": new_event_id, "h_id": clean_h_id, "slot": entry.type, "dt": entry.date}
            )

            # 3. Update Operational Tables (Detail)
            db.execute(
                text("""
                    INSERT INTO meal_event_detail (event_id, recipe_id, action_taken)
                    VALUES (:e_id, CAST(:r_id AS uuid), 'Accepted')
                """),
                {"e_id": new_event_id, "r_id": entry.recipe_id}
            )

            # 4. COMMIT TO LOG TABLE (The Snapshot)
            # This records exactly what was saved for historical tracking
            db.execute(
                text("""
                    INSERT INTO meal_event_log (house_id, event_date, meal_slot, recipe_id, log_type)
                    VALUES (CAST(:h_id AS uuid), CAST(:dt AS date), CAST(:slot AS meal_slot_type), CAST(:r_id AS uuid), 'Manual_Save')
                """),
                {
                    "h_id": clean_h_id, 
                    "dt": entry.date, 
                    "slot": entry.type, 
                    "r_id": entry.recipe_id
                }
            )

        db.commit()
        return {"status": "success"}

    except Exception as e:
        db.rollback()
        raise e
    
# --- 5. HOUSEHOLD PREFERENCES ---
def get_dietary_pref(db: Session, h_id: str):
    clean_h_id = "550e8400-e29b-41d4-a716-446655440000" if h_id == "HOUSEHOLD_001" else h_id
    res = db.execute(text("SELECT dietary_preference FROM household_master WHERE household_id = CAST(:h_id AS uuid)"), {"h_id": clean_h_id}).fetchone()
    return res[0] if res else "All"