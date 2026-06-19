-- Find potential duplicate recipes for manual review
-- Export this to Excel and mark duplicates for deletion

SELECT 
    a.dish_name as name1,
    a.meal_role::text as role1,
    a.dish_category as cat1,
    b.dish_name as name2,
    b.meal_role::text as role2,
    b.dish_category as cat2,
    ROUND(similarity(LOWER(a.dish_name), LOWER(b.dish_name))::numeric, 2) as similarity,
    '' as action  -- Fill: KEEP_BOTH | DELETE_NAME1 | DELETE_NAME2
FROM recipe_dna_master a
JOIN recipe_dna_master b ON a.recipe_id < b.recipe_id
WHERE a.review_status = 'approved'
AND b.review_status = 'approved'
AND similarity(LOWER(a.dish_name), LOWER(b.dish_name)) > 0.70
ORDER BY similarity DESC;
