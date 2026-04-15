from sqlalchemy.orm import Session
from sqlalchemy import text
import uuid

# --- 1. PLAN RETRIEVAL (FT-033: Multi-dish per slot) ---
def fetch_active_plan(db: Session, h_id: str, week_start: str = None):
    clean_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if h_id == "HOUSEHOLD_001" else h_id

    # FT-033: Query now returns ALL dishes per slot (main + sides)
    # week_start (YYYY-MM-DD): if provided, filter to that 7-day window only
    week_filter = ""
    params = {"h_id": clean_h_id}
    if week_start:
        week_filter = "AND h.event_date >= CAST(:week_start AS date) AND h.event_date < CAST(:week_end AS date)"
        from datetime import datetime, timedelta
        start_dt = datetime.strptime(week_start, "%Y-%m-%d").date()
        params["week_start"] = str(start_dt)
        params["week_end"] = str(start_dt + timedelta(days=7))

    query = text(f"""
        SELECT 
            h.event_date as date, 
            CAST(h.meal_slot AS text) as slot,
            h.event_id,
            r.dish_name as name, 
            r.recipe_code as code, 
            v.hero_image_url as hero, 
            v.carousel_thumb_url as thumb,
            v.prep_steps as steps,
            d.recipe_id,
            COALESCE(d.dish_type, 'Main') as dish_type,
            COALESCE(d.dish_sequence, 1) as dish_sequence,
            r.is_sattvic,
            r.diet_type
        FROM meal_event_header h
        LEFT JOIN meal_event_detail d ON h.event_id = d.event_id
        LEFT JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        LEFT JOIN recipe_content_vault v ON r.recipe_id = v.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
        {week_filter}
        ORDER BY h.event_date ASC, h.meal_slot DESC, d.dish_sequence ASC
    """)

    rows = db.execute(query, params).fetchall()

    # FT-033: Group dishes by date+slot into slots with main + sides
    slots = {}
    for r in rows:
        key = f"{str(r.date)}_{r.slot}"
        if key not in slots:
            slots[key] = {
                "date": str(r.date),
                "type": r.slot,
                "event_id": str(r.event_id),
                "main": None,
                "sides": []
            }
        dish = {
            "name": r.name if r.name else "Skipped",
            "recipe_id": str(r.recipe_id) if r.recipe_id else "",
            "hero": r.hero,
            "thumb": r.thumb,
            "steps": r.steps,
            "dish_type": r.dish_type,
            "dish_sequence": r.dish_sequence,
            "is_sattvic": r.is_sattvic,
            "diet_type": str(r.diet_type) if r.diet_type else "Veg"
        }
        if r.dish_type == "Main":
            slots[key]["main"] = dish
        else:
            slots[key]["sides"].append(dish)

    return {"plan": list(slots.values())}


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
            r.recipe_id,
            r.is_sattvic,
            r.diet_type
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
        "recipe_id": str(r[5]),
        "is_sattvic": r[6],
        "diet_type": str(r[7]) if r[7] else "Veg"
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


# --- 4. PERSISTENCE (FT-033: Multi-dish save + bug fix) ---
from uuid import uuid4
from sqlalchemy import text

def persist_plan(db: Session, h_id: str, plan_data: list):
    clean_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if h_id == "HOUSEHOLD_001" else h_id

    try:
        # 1. Purge only the dates being saved — not the entire household
        dates_being_saved = list({
            (entry.get("date") if isinstance(entry, dict) else entry.date)
            for entry in plan_data
        })
        for dt in dates_being_saved:
            db.execute(
                text("DELETE FROM meal_event_header WHERE house_id = CAST(:h_id AS uuid) AND event_date = CAST(:dt AS date)"),
                {"h_id": clean_h_id, "dt": dt}
            )

        for entry in plan_data:
            # FT-033: entry now has main dish + sides list
            # Skip slots where main dish has no recipe_id
            main = entry.get("main") if isinstance(entry, dict) else getattr(entry, "main", None)
            sides = entry.get("sides", []) if isinstance(entry, dict) else getattr(entry, "sides", [])
            slot = entry.get("type") if isinstance(entry, dict) else entry.type
            date = entry.get("date") if isinstance(entry, dict) else entry.date

            # FT-033: main is a DishItem Pydantic object — use attribute access, not dict
            main_recipe_id = main.recipe_id if hasattr(main, "recipe_id") else main.get("recipe_id")
            if not main or not main_recipe_id:
                continue

            new_event_id = uuid4()

            # 2. Insert Header (one per slot)
            db.execute(
                text("""
                    INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date)
                    VALUES (:e_id, CAST(:h_id AS uuid), CAST(:slot AS meal_slot_type), CAST(:dt AS date))
                """),
                {"e_id": new_event_id, "h_id": clean_h_id, "slot": slot, "dt": date}
            )

            # 3. Insert Main dish into Detail
            db.execute(
                text("""
                    INSERT INTO meal_event_detail 
                        (event_id, recipe_id, action_taken, dish_type, dish_sequence)
                    VALUES (:e_id, CAST(:r_id AS uuid), 'Accepted', 'Main', 1)
                """),
                {"e_id": new_event_id, "r_id": main_recipe_id}
            )

            # 4. Insert Side dishes into Detail (FT-033)
            for seq, side in enumerate(sides, start=2):
                side_recipe_id = side.recipe_id if hasattr(side, "recipe_id") else side.get("recipe_id")
                if not side_recipe_id:
                    continue
                db.execute(
                    text("""
                        INSERT INTO meal_event_detail 
                            (event_id, recipe_id, action_taken, dish_type, dish_sequence)
                        VALUES (:e_id, CAST(:r_id AS uuid), 'Accepted', 'Side', :seq)
                    """),
                    {"e_id": new_event_id, "r_id": side_recipe_id, "seq": seq}
                )

            # 5. Log to meal_audit_logs (FIXED: was meal_event_log — table does not exist)
            db.execute(
                text("""
                    INSERT INTO meal_audit_logs 
                        (event_id, house_id, recipe_id, issue_type, message, audit_type)
                    VALUES (:e_id, CAST(:h_id AS uuid), CAST(:r_id AS uuid), 'Save', 'Manual_Save', 'Manual')
                """),
                {
                    "e_id": new_event_id,
                    "h_id": clean_h_id,
                    "r_id": main_recipe_id
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
    res = db.execute(
        text("SELECT dietary_preference FROM household_master WHERE household_id = CAST(:h_id AS uuid)"),
        {"h_id": clean_h_id}
    ).fetchone()
    return res[0] if res else "All"


# --- SESSION CONSTANTS (fetched once on load, cached in frontend) ---
def get_session_constants(db: Session, h_id: str):
    """
    Fetches all session-level constants in a single DB call.
    Called once on app load — stored in frontend memory, not re-fetched per navigation.
    Returns:
      - oldest_plan_week: ISO date string of Monday of the oldest week with any plan record
      - dietary_preference: household dietary pref
      - member_count: number of active household members
    """
    clean_h_id = "733b3f63-0fb4-4170-877c-eb2a70f29ccb" if h_id == "HOUSEHOLD_001" else h_id

    # 1. Oldest week with any meal_event_header record
    oldest_row = db.execute(
        text("""
            SELECT MIN(event_date) as oldest_date
            FROM meal_event_header
            WHERE house_id = CAST(:h_id AS uuid)
        """),
        {"h_id": clean_h_id}
    ).fetchone()

    oldest_plan_week = None
    if oldest_row and oldest_row.oldest_date:
        # Roll back to Monday of that week
        from datetime import timedelta
        d = oldest_row.oldest_date
        days_since_monday = d.weekday()  # 0=Mon
        monday = d - timedelta(days=days_since_monday)
        oldest_plan_week = str(monday)

    # 2. Dietary preference
    pref_row = db.execute(
        text("""
            SELECT dietary_preference
            FROM household_master
            WHERE household_id = CAST(:h_id AS uuid)
        """),
        {"h_id": clean_h_id}
    ).fetchone()
    dietary_preference = str(pref_row[0]) if pref_row else "Veg"

    # 3. Member count
    member_row = db.execute(
        text("""
            SELECT COUNT(*) as cnt
            FROM household_members
            WHERE house_id = CAST(:h_id AS uuid)
        """),
        {"h_id": clean_h_id}
    ).fetchone()
    member_count = member_row.cnt if member_row else 0

    return {
        "oldest_plan_week": oldest_plan_week,
        "dietary_preference": dietary_preference,
        "member_count": member_count
    }
