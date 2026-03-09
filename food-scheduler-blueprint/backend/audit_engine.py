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