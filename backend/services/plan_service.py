from sqlalchemy.orm import Session
from sqlalchemy import text
import uuid

# --- 1. PLAN RETRIEVAL (FT-033: Multi-dish per slot) ---
def fetch_active_plan(db: Session, h_id: str, week_start: str = None):
    clean_h_id = h_id  # h_id always from authenticated user — no fallback needed

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

    # FT-041: Group dishes by date+slot — mains array supports multi-main
    slots = {}
    for r in rows:
        key = f"{str(r.date)}_{r.slot}"
        if key not in slots:
            slots[key] = {
                "date": str(r.date),
                "type": r.slot,
                "event_id": str(r.event_id),
                "main": None,   # first main — backward compat for frontend
                "mains": [],    # all mains — used by MealCard split hero
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
            slots[key]["mains"].append(dish)
            # Keep main as first dish for backward compat
            if slots[key]["main"] is None:
                slots[key]["main"] = dish
        else:
            slots[key]["sides"].append(dish)

    return {"plan": list(slots.values())}


# --- 2. SUGGESTIONS & SCORING (Fixed: UUID Capture) ---
def get_suggestions(db: Session, pref: str, h_id: str):
    current_pref = str(pref).strip() if pref else "Veg"
    clean_h_id = h_id  # h_id always from authenticated user

    # Diet compatibility — include all compatible diet types
    _diet_map = {
        "Vegan":      ("'Vegan'",),
        "Veg":        ("'Veg'", "'Vegan'"),
        "Eggitarian": ("'Veg'", "'Vegan'", "'Eggitarian'"),
        "Non-Veg":    ("'Veg'", "'Vegan'", "'Eggitarian'", "'Non-Veg'"),
    }
    _allowed = ", ".join(_diet_map.get(current_pref, ("'Veg'", "'Vegan'")))
    filter_sql = f"AND r.diet_type IN ({_allowed})"

    query = text(f"""
        SELECT 
            r.dish_name, 
            r.recipe_code, 
            v.hero_image_url, 
            COALESCE(v.carousel_thumb_url, v.hero_image_url) as carousel_thumb_url,
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
    """
    Audit engine — checks each meal slot for issues.
    Returns friendly plain-language warnings — no technical rule names exposed.
    Checks: diet compatibility, allergens, satvik day, repeat (week + history), pantry.
    """
    from sqlalchemy import text
    result_map = []
    seen_meals  = {}  # within-week repeat tracking

    # ── Load household context ────────────────────────────────────────────────
    # Effective diet
    diet_row = db.execute(text("""
        SELECT MIN(CASE dietary_preference::text
            WHEN 'Vegan'      THEN 1
            WHEN 'Veg'        THEN 2
            WHEN 'Eggitarian' THEN 3
            WHEN 'Non-Veg'    THEN 4
            ELSE 2 END) as diet_rank
        FROM member_preferences mp
        JOIN users u ON u.user_id = mp.user_id
        WHERE u.house_id = CAST(:h_id AS uuid)
    """), {"h_id": h_id}).fetchone()
    diet_rank = diet_row[0] if diet_row and diet_row[0] else 2
    DIET_BY_RANK = {1: "Vegan", 2: "Veg", 3: "Eggitarian", 4: "Non-Veg"}
    DIET_COMPATIBLE = {
        "Vegan":      ["Vegan"],
        "Veg":        ["Veg", "Vegan"],
        "Eggitarian": ["Veg", "Vegan", "Eggitarian"],
        "Non-Veg":    ["Veg", "Vegan", "Eggitarian", "Non-Veg"],
    }
    effective_diet = DIET_BY_RANK.get(diet_rank, "Veg")
    allowed_diets  = DIET_COMPATIBLE.get(effective_diet, ["Veg"])

    # Allergen ingredient IDs for household
    allergen_rows = db.execute(text("""
        SELECT DISTINCT hr.ingredient_id
        FROM household_restrictions hr
        WHERE hr.house_id = CAST(:h_id AS uuid)
        AND hr.restriction_type = 'allergen'
    """), {"h_id": h_id}).fetchall()
    allergen_ids = {r[0] for r in allergen_rows}

    # Pantry ingredient IDs
    pantry_rows = db.execute(text("""
        SELECT DISTINCT ingredient_id
        FROM household_pantry
        WHERE house_id = CAST(:h_id AS uuid)
        AND (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)
    """), {"h_id": h_id}).fetchall()
    pantry_ids = {r[0] for r in pantry_rows}

    # Past meal history (last 2 weeks) for repeat check
    history_rows = db.execute(text("""
        SELECT DISTINCT r.dish_name
        FROM meal_event_detail med
        JOIN meal_event_header meh ON meh.event_id = med.event_id
        JOIN recipe_dna_master r ON r.recipe_id = med.recipe_id
        WHERE meh.house_id = CAST(:h_id AS uuid)
        AND meh.event_date >= CURRENT_DATE - INTERVAL '14 days'
        AND meh.event_date < CURRENT_DATE
    """), {"h_id": h_id}).fetchall()
    recent_meals = {r[0] for r in history_rows}

    # Satvik dates this week
    satvik_rows = db.execute(text("""
        SELECT observation_date::text
        FROM panchangam_types
        WHERE observation_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
        AND is_satvik = TRUE
    """)).fetchall()
    satvik_dates = {r[0] for r in satvik_rows}

    # Lunch intensity tracker for dinner check
    lunch_intensity = {}

    # ── Audit each slot ───────────────────────────────────────────────────────
    for change in changes:
        issues  = []
        day     = change.day
        slot    = change.type
        meal    = change.to_meal
        date    = change.date if hasattr(change, "date") else None
        recipe_id = change.recipe_id if hasattr(change, "recipe_id") else None

        if not meal or meal == "Skipped":
            result_map.append({"day": day, "type": slot, "status": "ok", "issues": []})
            continue

        # Load recipe details
        recipe = None
        if recipe_id:
            row = db.execute(text("""
                SELECT r.dish_name, r.diet_type::text, r.is_sattvic,
                       r.intensity_level, r.meal_slots
                FROM recipe_dna_master r
                WHERE r.recipe_id = CAST(:rid AS uuid)
            """), {"rid": recipe_id}).fetchone()
            if row:
                recipe = {"name": row[0], "diet": row[1], "sattvic": row[2],
                          "intensity": row[3], "slots": list(row[4]) if row[4] else []}

        # 1. DIET CHECK
        if recipe and recipe["diet"] not in allowed_diets:
            issues.append("This dish may not suit everyone at the table today.")

        # 2. ALLERGEN CHECK
        if recipe_id and allergen_ids:
            allergen_hit = db.execute(text("""
                SELECT COUNT(*) FROM recipe_ingredients
                WHERE recipe_id = CAST(:rid AS uuid)
                AND ingredient_id = ANY(:aids)
                AND is_optional = FALSE
            """), {"rid": recipe_id, "aids": list(allergen_ids)}).scalar()
            if allergen_hit:
                issues.append("One of the ingredients in this dish may cause a reaction for someone in the family.")

        # 3. SATVIK CHECK
        if date and str(date) in satvik_dates:
            if recipe and not recipe.get("sattvic"):
                issues.append("Today is a fasting day — this dish might not be the best fit.")

        # 4. REPEAT THIS WEEK
        if meal in seen_meals:
            issues.append("This dish is already in your plan this week — a little variety would be nice!")
        seen_meals[meal] = True

        # 5. REPEAT PAST 2 WEEKS
        if meal in recent_meals:
            issues.append("You had this recently — maybe try something different this week?")

        # 6. HEAVY LUNCH → LIGHT DINNER
        if slot == "Dinner" and lunch_intensity.get(day) in ("Heavy", "Medium"):
            if recipe and recipe.get("intensity") not in ("Light",):
                issues.append("You had a hearty lunch today — a lighter dinner would feel better tonight.")

        # Track lunch intensity for dinner check
        if slot == "Lunch" and recipe:
            lunch_intensity[day] = recipe.get("intensity", "Medium")

        # 7. PANTRY CHECK — primary ingredients
        if recipe_id and pantry_ids:
            primary_rows = db.execute(text("""
                SELECT COUNT(*) FROM recipe_ingredients ri
                WHERE ri.recipe_id = CAST(:rid AS uuid)
                AND ri.is_optional = FALSE
            """), {"rid": recipe_id}).scalar()
            if primary_rows and primary_rows > 0:
                in_pantry = db.execute(text("""
                    SELECT COUNT(*) FROM recipe_ingredients ri
                    WHERE ri.recipe_id = CAST(:rid AS uuid)
                    AND ri.is_optional = FALSE
                    AND ri.ingredient_id = ANY(:pids)
                """), {"rid": recipe_id, "pids": list(pantry_ids)}).scalar()
                missing = primary_rows - (in_pantry or 0)
                if missing > 0:
                    issues.append("You may need to pick up some ingredients before cooking this.")

        status = "ok" if not issues else "warning"
        result_map.append({
            "day":    day,
            "type":   slot,
            "status": status,
            "issues": issues,
            # Keep backward compat
            "message": issues[0] if issues else "Ready",
            "score":   90 if not issues else 65,
        })

    return result_map


# --- 4. PERSISTENCE (FT-033: Multi-dish save + bug fix) ---
from uuid import uuid4
from sqlalchemy import text

def persist_plan(db: Session, h_id: str, plan_data: list):
    clean_h_id = h_id  # h_id always from authenticated user — no fallback needed

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
            # FT-041: entry supports mains array (multi-main) + sides list
            mains = entry.get("mains", []) if isinstance(entry, dict) else getattr(entry, "mains", [])
            main  = entry.get("main") if isinstance(entry, dict) else getattr(entry, "main", None)
            sides = entry.get("sides", []) if isinstance(entry, dict) else getattr(entry, "sides", [])
            slot  = entry.get("type") if isinstance(entry, dict) else entry.type
            date  = entry.get("date") if isinstance(entry, dict) else entry.date

            # Normalise: use mains array if present, else fall back to single main
            if not mains and main:
                first_recipe_id = main.recipe_id if hasattr(main, "recipe_id") else main.get("recipe_id")
                mains = [{"recipe_id": first_recipe_id, "dish_type": "Main", "dish_sequence": 1}]

            if not mains:
                continue

            # First main recipe_id — used for audit log
            first_main = mains[0]
            main_recipe_id = first_main.get("recipe_id") if isinstance(first_main, dict) else getattr(first_main, "recipe_id", None)

            new_event_id = uuid4()

            # 2. Insert Header (one per slot)
            db.execute(
                text("""
                    INSERT INTO meal_event_header (event_id, house_id, meal_slot, event_date)
                    VALUES (:e_id, CAST(:h_id AS uuid), CAST(:slot AS meal_slot_type), CAST(:dt AS date))
                """),
                {"e_id": new_event_id, "h_id": clean_h_id, "slot": slot, "dt": date}
            )

            # 3. Insert all main dishes into Detail
            for seq, m in enumerate(mains, start=1):
                m_recipe_id = m.get("recipe_id") if isinstance(m, dict) else getattr(m, "recipe_id", None)
                if not m_recipe_id:
                    continue
                db.execute(
                    text("""
                        INSERT INTO meal_event_detail
                            (event_id, recipe_id, action_taken, dish_type, dish_sequence)
                        VALUES (:e_id, CAST(:r_id AS uuid), 'Accepted', 'Main', :seq)
                    """),
                    {"e_id": new_event_id, "r_id": m_recipe_id, "seq": seq}
                )

            # 4. Insert Side dishes — sequence continues after mains
            side_start = len(mains) + 1
            for seq, side in enumerate(sides, start=side_start):
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
    clean_h_id = h_id  # h_id always from authenticated user — no fallback needed
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
    clean_h_id = h_id  # h_id always from authenticated user — no fallback needed

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
            FROM users
            WHERE house_id = CAST(:h_id AS uuid)
            AND is_active = true
        """),
        {"h_id": clean_h_id}
    ).fetchone()
    member_count = member_row.cnt if member_row else 0

    return {
        "oldest_plan_week": oldest_plan_week,
        "dietary_preference": dietary_preference,
        "member_count": member_count
    }
