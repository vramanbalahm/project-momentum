# FT-080 to FT-082 — Recipe & image management
# Functions: manage_recipe_vault, generate_recipe_images,
#            upload_recipe_image
from fastapi import APIRouter
router = APIRouter(prefix="/recipes", tags=["recipes"])
