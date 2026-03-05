def check_pantry_availability(new_meal_name, pantry_stock, recipe_vault):
    """
    Checks if all ingredients for a meal exist in the pantry.
    No quantities, just presence.
    """
    # 1. Fetch ingredients for the recipe
    recipe = next((r for r in recipe_vault if r['name'] == new_meal_name), None)
    if not recipe: return True # "Skipped" or unknown
    
    # 2. Check if every ingredient is in the pantry list
    required_ingredients = recipe['ingredients'].keys()
    missing_items = [ing for ing in required_ingredients if ing not in pantry_stock]
    
    return len(missing_items) == 0 # Returns True if all are available