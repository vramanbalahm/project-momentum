# scripts/seed_momentum_data.py
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Update this with your actual DB credentials from your baseline
DATABASE_URL = "postgresql://postgres:admin123@localhost:5432/food_momentum_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

def inject_test_momentum_data():
    db = SessionLocal()
    try:
        # 1. Ensure a Location exists (Fixes the ForeignKeyViolation)
        db.execute(text("""
            INSERT INTO public.market_locations (id, location_name) 
            VALUES (1, 'Main City Market') 
            ON CONFLICT (id) DO NOTHING
        """))

        # 2. Get a valid staple_id
        staple = db.execute(text("SELECT staple_id FROM staple_master_registry LIMIT 1")).fetchone()
        
        if not staple:
            print("❌ Registry empty. Please add a staple to staple_master_registry first.")
            return

        s_id = staple[0]

        # 3. Inject the Wave 5 Peak price
        db.execute(text("""
            INSERT INTO public.price_logs (staple_id, recorded_price, recorded_at, location_id)
            VALUES (:s_id, 1277.00, :timestamp, 1)
        """), {"s_id": s_id, "timestamp": datetime.now()})
        
        db.commit()
        print(f"✅ Success! Injected price 1277.00 for Staple: {s_id} at Location: 1")
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    inject_test_momentum_data()