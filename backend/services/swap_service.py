from sqlalchemy.orm import Session
from sqlalchemy import text

# ─────────────────────────────────────────────────────────────────────────────
# SWAP SERVICE — FT-043
# Generic slot swap with audit validation.
# Called by /meal/swap endpoint.
# Day swap (future) calls execute_swap in a loop per meal type.
# ─────────────────────────────────────────────────────────────────────────────

def audit_slot(db: Session, h_id: str, event_date: str, meal_slot: str) -> dict:
    """
    Standalone audit for a single meal slot.
    Callable anytime — before swap, after edit, before save.
    Checks:
      1. Slot exists in DB
      2. Repetition — same main dish used on another day this week
      3. Pantry stock for primary staple
      4. Market divergence (price peak) for primary staple

    Returns: { status: "Success"|"Warning"|"Conflict", messages: [] }
    """
    messages = []
    status = "Success"

    # 1. Fetch slot details
    slot = db.execute(text("""
        SELECT h.event_id, d.recipe_id, r.dish_name, r.primary_staple_id
        FROM meal_event_header h
        JOIN meal_event_detail d ON h.event_id = d.event_id
        JOIN recipe_dna_master r ON d.recipe_id = r.recipe_id
        WHERE h.house_id = CAST(:h_id AS uuid)
          AND h.event_date = CAST(:dt AS date)
          AND h.meal_slot = CAST(:slot AS meal_slot_type)
          AND d.dish_type = 'Main'
          AND d.dish_sequence = 1
    """), {"h_id": h_id, "dt": event_date, "slot": meal_slot}).fetchone()

    if not slot:
        return {"status": "Success", "messages": ["No meal in this slot"]}

    event_id, recipe_id, dish_name, staple_id = slot

    # 2. Repetition check — same dish used elsewhere this week
    repetition = db.execute(text("""
        SELECT COUNT(*)
        FROM meal_event_header h
        JOIN meal_event_detail d ON h.event_id = d.event_id
        WHERE h.house_id = CAST(:h_id AS uuid)
          AND d.recipe_id = CAST(:r_id AS uuid)
          AND d.dish_type = 'Main'
          AND h.event_id != CAST(:e_id AS uuid)
          AND DATE_TRUNC('week', h.event_date) = DATE_TRUNC('week', CAST(:dt AS date))
    """), {"h_id": h_id, "r_id": str(recipe_id), "e_id": str(event_id), "dt": event_date}).scalar()

    if repetition and repetition > 0:
        status = "Warning"
        messages.append(f"{dish_name} is already used {repetition} time(s) this week — variety risk.")

    # 3. Pantry stock check
    if staple_id:
        stock = db.execute(text("""
            SELECT i.stock_status, s.item_name
            FROM staple_master_registry s
            LEFT JOIN household_inventory i
                ON s.staple_id = i.staple_id
               AND i.house_id = CAST(:h_id AS uuid)
            WHERE s.staple_id = :s_id
        """), {"h_id": h_id, "s_id": staple_id}).fetchone()

        if stock and stock[0] != 'In-Stock':
            status = "Warning"
            messages.append(f"Pantry: {stock[1]} may be out of stock.")

    # 4. Market divergence check
    if staple_id:
        divergence = db.execute(text("""
            SELECT
                CASE
                    WHEN pl.recorded_price >= smr.peak_threshold
                     AND smr.peak_threshold > 0 THEN TRUE
                    ELSE FALSE
                END as is_divergent
            FROM staple_master_registry smr
            LEFT JOIN LATERAL (
                SELECT recorded_price
                FROM price_logs
                WHERE staple_id = smr.staple_id
                ORDER BY recorded_at DESC
                LIMIT 1
            ) pl ON TRUE
            WHERE smr.staple_id = :s_id
        """), {"s_id": staple_id}).fetchone()

        if divergence and divergence[0]:
            if status == "Success":
                status = "Warning"
            messages.append("Market: Primary staple is at price peak — consider alternatives.")

    if not messages:
        messages.append("Ready")

    return {"status": status, "messages": messages}


def execute_swap(db: Session, h_id: str, source: dict, target: dict) -> dict:
    """
    Generic slot swap — swaps meal_event_detail records between two slots.
    Works for within-day and cross-day swaps.
    For day swap: caller loops over meal types and calls this per type.

    source / target shape: { day, type, date }

    Steps:
      1. Validate both slots exist
      2. Swap recipe details between the two event_ids
      3. Run audit on both slots post-swap
      4. Return audit results for both slots

    Returns: { success, source_audit, target_audit, message }
    """

    def get_event_id(date, meal_slot):
        row = db.execute(text("""
            SELECT event_id FROM meal_event_header
            WHERE house_id = CAST(:h_id AS uuid)
              AND event_date = CAST(:dt AS date)
              AND meal_slot = CAST(:slot AS meal_slot_type)
        """), {"h_id": h_id, "dt": date, "slot": meal_slot}).fetchone()
        return str(row[0]) if row else None

    source_event_id = get_event_id(source['date'], source['type'])
    target_event_id = get_event_id(target['date'], target['type'])

    # Both slots must exist
    if not source_event_id or not target_event_id:
        missing = []
        if not source_event_id:
            missing.append(f"{source['day']} {source['type']}")
        if not target_event_id:
            missing.append(f"{target['day']} {target['type']}")
        return {
            "success": False,
            "message": f"Cannot swap — no meal data for: {', '.join(missing)}"
        }

    # Cannot swap a slot with itself
    if source_event_id == target_event_id:
        return {"success": False, "message": "Source and target are the same slot."}

    try:
        # Fetch all detail rows for both events
        source_details = db.execute(text("""
            SELECT recipe_id, action_taken, dish_type, dish_sequence
            FROM meal_event_detail
            WHERE event_id = CAST(:e_id AS uuid)
            ORDER BY dish_sequence
        """), {"e_id": source_event_id}).fetchall()

        target_details = db.execute(text("""
            SELECT recipe_id, action_taken, dish_type, dish_sequence
            FROM meal_event_detail
            WHERE event_id = CAST(:e_id AS uuid)
            ORDER BY dish_sequence
        """), {"e_id": target_event_id}).fetchall()

        # Delete existing details for both
        db.execute(text("DELETE FROM meal_event_detail WHERE event_id = CAST(:e_id AS uuid)"),
                   {"e_id": source_event_id})
        db.execute(text("DELETE FROM meal_event_detail WHERE event_id = CAST(:e_id AS uuid)"),
                   {"e_id": target_event_id})

        # Insert target's dishes into source slot
        for row in target_details:
            db.execute(text("""
                INSERT INTO meal_event_detail
                    (event_id, recipe_id, action_taken, dish_type, dish_sequence)
                VALUES (CAST(:e_id AS uuid), CAST(:r_id AS uuid), :action, :dtype, :seq)
            """), {
                "e_id": source_event_id,
                "r_id": str(row[0]),
                "action": row[1],
                "dtype": row[2],
                "seq": row[3]
            })

        # Insert source's dishes into target slot
        for row in source_details:
            db.execute(text("""
                INSERT INTO meal_event_detail
                    (event_id, recipe_id, action_taken, dish_type, dish_sequence)
                VALUES (CAST(:e_id AS uuid), CAST(:r_id AS uuid), :action, :dtype, :seq)
            """), {
                "e_id": target_event_id,
                "r_id": str(row[0]),
                "action": row[1],
                "dtype": row[2],
                "seq": row[3]
            })

        db.commit()

        # Post-swap audit on both slots
        source_audit = audit_slot(db, h_id, source['date'], source['type'])
        target_audit = audit_slot(db, h_id, target['date'], target['type'])

        return {
            "success": True,
            "message": f"Swapped {source['day']} {source['type']} ↔ {target['day']} {target['type']}",
            "source_audit": source_audit,
            "target_audit": target_audit
        }

    except Exception as e:
        db.rollback()
        return {"success": False, "message": f"Swap failed: {str(e)}"}
