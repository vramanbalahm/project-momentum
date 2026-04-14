from sqlalchemy.orm import Session
from sqlalchemy import text
import uuid

# --- 1. PLAN RETRIEVAL (Restored & Verified) ---
# --- 1. PLAN RETRIEVAL (Restored & Verified) ---
def fetch_active_plan(db: Session, h_id: str):
    # Standardizing ID based on SQL Baseline
    clean_h_id = "550e8400-e29b-41d4-a716-446655440000" if h_id == "HOUSEHOLD_001" else h_id
    
    query = text("""
        SELECT 
            h.event_date as date, 
            CAST(h.meal_slot AS text) as slot, 
            r.dish_name as name,        -- Alias to 'name' for Frontend
            r.recipe_code as code, 
            v.hero_image_url as hero,   -- Alias to 'hero' for Frontend
            d.recipe_id                 -- Added to ensure UUID is available
        FROM meal_event_header h
        JOIN meal_event_detail d ON h.event_id = d.event_id
        JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
        ORDER BY h.event_date ASC
    """)
    
    rows = db.execute(query, {"h_id": clean_h_id}).fetchall()
    
    # Returning keys that match your App.jsx init logic exactly
    return {
        "plan": [
            {
                "date": str(r.date), 
                "type": r.slot, 
                "meal_name": r.name, 
                "code": r.code, 
                "hero": r.hero,
                "recipe_id": str(r.recipe_id)
            } for r in rows
        ]
    }

# --- 2. SUGGESTIONS & SCORING (Standardized) ---
def get_suggestions(db: Session, pref: str, h_id: str):
    # MAPPING: Standardizing the test ID to the UUID in your DB

    current_pref = str(pref).strip() if pref else "Veg"

    if current_pref == "Veg":
        filter_sql = "AND r.diet_type IN ('Veg', 'Vegan')"
    elif current_pref == "Vegan":
        filter_sql = "AND r.diet_type = 'Vegan'"
    else:
        filter_sql = "" # Non-Veg sees everything

    test_uuid = "550e8400-e29b-41d4-a716-446655440000" 
    clean_h_id = test_uuid if h_id == "HOUSEHOLD_001" else h_id

    filter_sql = "AND r.diet_type IN ('Veg', 'Vegan')" if pref == "Veg" else ""

    query = text(f"""
        SELECT 
            r.dish_name, 
            r.recipe_code, 
            v.hero_image_url, 
            v.carousel_thumb_url,
            (100 + 
                CASE WHEN inv.stock_status = 'In-Stock' THEN 50 ELSE 0 END - 
                CASE WHEN lp.recorded_price >= s.peak_threshold AND s.peak_threshold > 0 THEN 80 ELSE 0 END
            ) as match_score
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
    return [{"name": r[0], "code": r[1], "hero": r[2], "thumb": r[3], "score": r[4]} for r in rows]

#    except Exception as e:
#        print(f"DATABASE ERROR: {e}")
#        return {"error": str(e)}

# --- 3. AUDIT & INVENTORY (Yesterday's Logic) ---
# backend/services.py

def execute_audit(db: Session, h_id: str, changes: list):
    result_map = []
    seen_meals = {} # To track duplicates for Scenario 1

    for change in changes:
        status = "Success"
        message = "Ready"
        score = 90
        
        # Scenario 1: Multiple Challenge (Duplicate Detection)
        if change.to_meal in seen_meals and change.to_meal != "Skipped":
            status = "Conflict"
            message = f"Divergence: {change.to_meal} is repeated. High fatigue risk!"
            score = 40
        
        # Scenario 2: Single Challenge (Low Momentum/Nutritional Check)
        # We'll simulate this by flagging any dish with 'Paneer' as a 'High Protein Balance' check
        elif "Paneer" in change.to_meal:
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

def persist_plan(db: Session, h_id: str, plan: list):
    """
    Maintains the original name to prevent breaking main.py / API layer.
    Implements: Delete -> Insert -> Audit Sync.
    """
    clean_h_id = "550e8400-e29b-41d4-a716-446655440000" if h_id == "HOUSEHOLD_001" else h_id
    try:
        # 1. PURGE (Only for this household)
        # We delete the header; CASCADE handles the rest if your DB is set up that way.
        db.execute(text("DELETE FROM meal_event_header WHERE house_id = CAST(:h_id AS uuid)"), {"h_id": clean_h_id})

        for item in plan:
            new_event_id = str(uuid.uuid4())
            
            # 2. CREATE Header (The Slot)
            db.execute(text("""
                INSERT INTO meal_event_header (event_id, house_id, event_date, meal_slot)
                VALUES (CAST(:e_id AS uuid), CAST(:h_id AS uuid), :date, :slot)
            """), {"e_id": new_event_id, "h_id": clean_h_id, "date": item.date, "slot": item.type})
            
            # 3. CREATE Detail (The Shield: Only save real recipes)
            if item.recipe_id and len(item.recipe_id) > 30: 
                db.execute(text("""
                    INSERT INTO meal_event_detail (event_id, recipe_id)
                    VALUES (CAST(:e_id AS uuid), CAST(:r_id AS uuid))
                """), {"e_id": new_event_id, "r_id": item.recipe_id})
            
            # 4. CREATE Audit Log (Optional persistence of the highlights)
            # This checks if the payload sent from App.jsx includes audit data
            # Note: We use .get() to avoid KeyErrors if the field is missing
            audit_status = getattr(item, 'status', None)
            if audit_status and audit_status != "Success":
                db.execute(text("""
                    INSERT INTO meal_audit_logs (event_id, issue_type, message)
                    VALUES (CAST(:e_id AS uuid), :issue, :msg)
                """), {"e_id": new_event_id, "issue": audit_status, "msg": getattr(item, 'message', '')})
        
        db.commit()
        return {"status": "success"}
    except Exception as e:
        db.rollback()
        raise e
    
# --- 5. HOUSEHOLD PREFERENCES ---
def get_dietary_pref(db: Session, h_id: str):
    res = db.execute(text("SELECT dietary_preference FROM household_master WHERE household_id = CAST(:h_id AS uuid)"), {"h_id": h_id}).fetchone()
    return res[0] if res else "All"