@echo off
REM ============================================================
REM Momentum — Batch Vegetable Seeder
REM Seeds lunch mains + side dishes for all remaining vegetables
REM Run from: C:\Users\SATISH.000\project-momentum\backend
REM Usage: scripts\seed_vegetables.bat
REM ============================================================

echo.
echo ==========================================
echo  Momentum Vegetable Seeder — Tamil Nadu
echo ==========================================
echo.

REM ── Potato (Urulai Kizhangu) ──────────────────────────────
echo [1/15] Potato — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 10 --sub_region "Potato Urulai Kizhangu" --ai gemini
echo [1/15] Potato — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 8 --sub_region "Potato Urulai Kizhangu" --ai gemini

REM ── Banana Stem (Vaazhai Thandu) ──────────────────────────
echo [2/15] Banana Stem — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Banana Stem Vaazhai Thandu" --ai gemini
echo [2/15] Banana Stem — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Banana Stem Vaazhai Thandu" --ai gemini

REM ── Banana Flower (Vaazhai Poo) ───────────────────────────
echo [3/15] Banana Flower — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Banana Flower Vaazhai Poo" --ai gemini
echo [3/15] Banana Flower — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Banana Flower Vaazhai Poo" --ai gemini

REM ── Bangalore Brinjal ─────────────────────────────────────
echo [4/15] Bangalore Brinjal — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Bangalore Brinjal" --ai gemini
echo [4/15] Bangalore Brinjal — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Bangalore Brinjal" --ai gemini

REM ── Cauliflower ───────────────────────────────────────────
echo [5/15] Cauliflower — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Cauliflower" --ai gemini
echo [5/15] Cauliflower — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Cauliflower" --ai gemini

REM ── Capsicum ──────────────────────────────────────────────
echo [6/15] Capsicum — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Capsicum" --ai gemini
echo [6/15] Capsicum — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Capsicum" --ai gemini

REM ── Avarekai (Broad Beans) ────────────────────────────────
echo [7/15] Avarekai — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Avarekai Broad Beans" --ai gemini
echo [7/15] Avarekai — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Avarekai Broad Beans" --ai gemini

REM ── Beans ─────────────────────────────────────────────────
echo [8/15] Beans — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Beans" --ai gemini
echo [8/15] Beans — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Beans" --ai gemini

REM ── Radish (Mullangi) ─────────────────────────────────────
echo [9/15] Radish — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Radish Mullangi" --ai gemini
echo [9/15] Radish — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Radish Mullangi" --ai gemini

REM ── Kovakkai (Ivy Gourd) ──────────────────────────────────
echo [10/15] Kovakkai — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Kovakkai Ivy Gourd" --ai gemini
echo [10/15] Kovakkai — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Kovakkai Ivy Gourd" --ai gemini

REM ── Snake Gourd (Pudalangai) ──────────────────────────────
echo [11/15] Snake Gourd — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Snake Gourd Pudalangai" --ai gemini
echo [11/15] Snake Gourd — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Snake Gourd Pudalangai" --ai gemini

REM ── Colacasia (Seppankizhangu) ────────────────────────────
echo [12/15] Colacasia — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Colacasia Seppankizhangu" --ai gemini
echo [12/15] Colacasia — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Colacasia Seppankizhangu" --ai gemini

REM ── Cluster Beans (Kothavarangai) ────────────────────────
echo [13/15] Cluster Beans — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Cluster Beans Kothavarangai" --ai gemini
echo [13/15] Cluster Beans — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Cluster Beans Kothavarangai" --ai gemini

REM ── Raw Mango (Maanga) ────────────────────────────────────
echo [14/15] Raw Mango — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Raw Mango Maanga" --ai gemini
echo [14/15] Raw Mango — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Raw Mango Maanga" --ai gemini

REM ── Bitter Gourd (Pavakkai) ───────────────────────────────
echo [15/15] Bitter Gourd — lunch mains...
python scripts/seed_recipes.py --meal lunch --diet Veg --count 8 --sub_region "Bitter Gourd Pavakkai" --ai gemini
echo [15/15] Bitter Gourd — side dishes...
python scripts/seed_recipes.py --meal side_dish --diet Veg --count 6 --sub_region "Bitter Gourd Pavakkai" --ai gemini

echo.
echo ==========================================
echo  All vegetable batches complete!
echo ==========================================
echo.
