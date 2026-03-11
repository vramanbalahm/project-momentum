def check_pantry_availability(required_ingredients: list, pantry_stock: list):
    """
    Core Validation Engine:
    Compares required ingredients against current pantry stock.
    
    :param required_ingredients: List of staple_ids (strings) required for the dish.
    :param pantry_stock: List of staple_ids (strings) currently 'In-Stock' in the DB.
    :return: Boolean (True if all ingredients are available, False otherwise).
    """
    
    # If no ingredients are defined for a recipe (or it's a 'Skipped' meal),
    # we treat it as available by default.
    if not required_ingredients:
        return True

    # Check for any item in the required list that is NOT present in the stock list.
    missing_items = [ing for ing in required_ingredients if ing not in pantry_stock]

    # The check passes only if the list of missing items is empty.
    return len(missing_items) == 0

def check_momentum_divergence(db, recipe_id, h_id):
    """
    Dynamic Momentum Check: 
    Compares current market prices in the user's region against 
    the peak_threshold defined in the Ingredient Master.
    """
    query = text("""
        SELECT COUNT(*) 
        FROM recipe_ingredients ri
        JOIN ingredient_master im ON ri.ingredient_id = im.id
        JOIN household_master hm ON hm.household_id = CAST(:h_id AS uuid)
        JOIN ingredient_price_logs ipl ON ipl.ingredient_id = im.id 
             AND ipl.state_id = hm.state_id
        WHERE ri.recipe_id = :r_id 
          AND ipl.current_price >= im.peak_threshold
          AND ipl.is_latest = true
    """)
    
    # If count > 0, at least one ingredient is in 'Divergence' (Price Peak)
    result = db.execute(query, {"r_id": recipe_id, "h_id": h_id}).scalar()
    return result > 0