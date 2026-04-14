# FT-100 to FT-102 — Platform admin
# Functions: manage_feature_registry, manage_entitlements,
#            bulk_manage_entitlements
from fastapi import APIRouter
router = APIRouter(prefix="/admin", tags=["admin"])
