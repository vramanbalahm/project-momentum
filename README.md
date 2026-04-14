# Momentum Food Scheduler
> Your Partner in Kitchen

An AI-powered, culturally-aware weekly meal planning application
for Indian households.

## Tech Stack
- **Frontend:** React + Vite (mobile-first)
- **Backend:** Python / FastAPI
- **Database:** PostgreSQL
- **AI:** Google Gemini

## Project Structure
```
momentum/
├── backend/
│   ├── auth/           # JWT authentication
│   ├── routers/        # API routes — one file per feature group
│   ├── services/       # Business logic — one file per feature group
│   ├── alembic/        # DB migrations
│   ├── scripts/        # Seed and utility scripts
│   ├── main.py         # App entry point
│   ├── schemas.py      # Pydantic schemas
│   └── database.py     # DB connection
├── frontend/
│   ├── src/
│   │   ├── api/        # API client and service calls
│   │   ├── components/ # Reusable UI components
│   │   ├── pages/      # Full page views
│   │   ├── context/    # Auth and entitlement context
│   │   ├── assets/     # Static assets
│   │   └── App.jsx
│   └── public/
│       └── assets/meals/  # Recipe images
├── docs/
│   ├── requirements/   # All specification documents
│   ├── screens/        # UI wireframes and mockups
│   └── intelligence_engine_core.ipynb
└── Infrastructure/     # DB scripts and exports
```

## Feature Registry
44 features across 11 groups — all independently toggleable.
See feature_registry table in DB for full list.

## Coding Rules (Non-negotiable)
1. No overwriting existing code and functionality
2. No deleting — only comment out with #
3. Do not change names of variables, functions or calls
4. Refer column and table names from baseline (16th March 2026)
5. Only update/fix/append — do not change structure
6. When sharing entire files, preserve function order as baseline

## Getting Started
### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```
### Frontend
```bash
cd frontend
npm install
npm run dev
```
