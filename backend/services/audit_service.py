from sqlalchemy import text
from sqlalchemy.orm import Session

def check_pantry_availability(db, staple_id, h_id):
    """
    Checks if a specific staple is in stock for a household.
    Returns a dictionary with status and item name.
    """
    if not staple_id:
        return {"available": True, "reason": "No staple required"}

    query = text("""
        SELECT s.item_name, i.stock_status 
        FROM staple_master_registry s
        LEFT JOIN household_inventory i ON s.staple_id = i.staple_id 
             AND i.house_id = CAST(:h_id AS uuid)
        WHERE s.staple_id = :s_id
    """)
    
    result = db.execute(query, {"s_id": staple_id, "h_id": h_id}).fetchone()
    
    if result and result[1] == 'In-Stock':
        return {"available": True, "item": result[0]}
    
    return {
        "available": False, 
        "item": result[0] if result else staple_id,
        "status": "NEEDS_SHOPPING"
    }


def check_momentum_divergence(db: Session, recipe_id: str, location_id: int):
    """
    CRUX: Determines if a recipe's primary staple is hitting a price peak.
    Returns: Boolean (True if Price >= Peak Threshold)
    """
    
    query = text("""
        SELECT 
            CASE 
                WHEN pl.recorded_price >= smr.peak_threshold AND smr.peak_threshold > 0 THEN TRUE 
                ELSE FALSE 
            END as is_divergent
        FROM recipe_dna_master rdm
        JOIN staple_master_registry smr ON rdm.primary_staple_id = smr.staple_id
        -- Subquery to fetch only the single latest price for this specific staple
        LEFT JOIN LATERAL (
            SELECT recorded_price 
            FROM price_logs 
            WHERE staple_id = smr.staple_id 
              AND location_id = :loc_id
            ORDER BY recorded_at DESC 
            LIMIT 1
        ) pl ON TRUE
        WHERE rdm.recipe_id = :r_id
    """)
    
    result = db.execute(query, {"r_id": recipe_id, "loc_id": location_id}).fetchone()
    
    # Logic: If no logs exist, divergence is False by default
    return result[0] if result else False

def get_staple_price_history(db: Session, staple_id: str, limit: int = 5):
    """
    Helper for frontend charts to show the trend that caused the divergence.
    """
    query = text("""
        SELECT recorded_price, recorded_at 
        FROM price_logs 
        WHERE staple_id = :s_id 
        ORDER BY recorded_at DESC 
        LIMIT :limit
    """)
    return db.execute(query, {"s_id": staple_id, "limit": limit}).fetchall()

def run_recipe_audit(db, recipe_name, h_id):
    """
    Comprehensive audit for a single recipe.
    """
    # 1. Fetch Recipe details
    recipe = db.execute(text("""
        SELECT recipe_id, primary_staple_id 
        FROM recipe_dna_master 
        WHERE dish_name = :name
    """), {"name": recipe_name}).fetchone()

    if not recipe:
        return {"is_valid": False, "message": "Dish Not Found"}

    r_id, s_id = recipe
    
    # 2. Check Stock
    stock_check = check_pantry_availability(db, s_id, h_id)
    
    # 3. Check Price Momentum
    is_peaked = check_momentum_divergence(db, r_id)
    
    # 4. Consolidate Result (No Hard Stop)
    return {
        "is_valid": True, # Always True to allow continuation
        "is_peaked": is_peaked,
        "in_stock": stock_check["available"],
        "missing_item": stock_check["item"] if not stock_check["available"] else None,
        "message": "verified" if stock_check["available"] else f"Need: {stock_check['item']}"
    }