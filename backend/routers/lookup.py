from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import SessionLocal

router = APIRouter(prefix="/lookup", tags=["Lookup"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/cuisine-region-states")
def get_cuisine_region_states(db: Session = Depends(get_db)):
    """Return distinct states from cuisine_regions — for State dropdown."""
    rows = db.execute(text(
        "SELECT DISTINCT state FROM cuisine_regions WHERE is_active = true ORDER BY state"
    )).fetchall()
    return [r.state for r in rows]


@router.get("/cuisine-regions/{state}")
def get_regions_by_state(state: str, db: Session = Depends(get_db)):
    """Return distinct regions for a given state."""
    rows = db.execute(text(
        "SELECT DISTINCT region FROM cuisine_regions WHERE state = :state AND is_active = true ORDER BY region"
    ), {"state": state}).fetchall()
    return [r.region for r in rows]


@router.get("/cuisine-sub-regions/{state}/{region}")
def get_sub_regions(state: str, region: str, db: Session = Depends(get_db)):
    """Return sub-regions for a given state + region."""
    rows = db.execute(text(
        """SELECT id, sub_region FROM cuisine_regions
           WHERE state = :state AND region = :region AND is_active = true
           ORDER BY sort_order"""
    ), {"state": state, "region": region}).fetchall()
    return [{"id": r.id, "sub_region": r.sub_region} for r in rows]


@router.get("/city-states")
def get_city_states(db: Session = Depends(get_db)):
    """Return distinct states from cities table — for State dropdown in current city."""
    rows = db.execute(text(
        "SELECT DISTINCT state FROM cities WHERE is_active = true ORDER BY state"
    )).fetchall()
    return [r.state for r in rows]


@router.get("/cities/{state}")
def get_cities_by_state(state: str, db: Session = Depends(get_db)):
    """Return cities for a given state, ordered by sort_order."""
    rows = db.execute(text(
        """SELECT id, display_name, agmarknet_name FROM cities
           WHERE state = :state AND is_active = true
           ORDER BY sort_order, display_name"""
    ), {"state": state}).fetchall()
    return [{"id": r.id, "display_name": r.display_name, "agmarknet_name": r.agmarknet_name} for r in rows]
