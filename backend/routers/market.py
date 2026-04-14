# FT-050 to FT-055 — Market intelligence
# Functions: record_manual_price, fetch_mandi_prices, calculate_rsi,
#            detect_wave5_divergence, get_market_signals,
#            apply_market_complexity_cap
from fastapi import APIRouter
router = APIRouter(prefix="/market", tags=["market"])
