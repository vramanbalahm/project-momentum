"""
export_pairing_review_pdf.py - Generates a PDF listing every main dish
and its side-dish pairings, for sharing with relatives to manually
validate in parallel with the Platform Admin review tool.

Usage:
    pip install reportlab psycopg2-binary
    python export_pairing_review_pdf.py --db postgresql://postgres:admin123@localhost:5432/food_momentum_db
"""

import argparse
import os
from xml.sax.saxutils import escape

parser = argparse.ArgumentParser()
parser.add_argument("--db", required=True)
parser.add_argument("--out", default="pairing_review.pdf", help="Output PDF filename")
args = parser.parse_args()


def get_conn():
    try:
        import psycopg2
    except ImportError:
        os.system("pip install psycopg2-binary --break-system-packages -q")
        import psycopg2
    return psycopg2.connect(args.db)


def main():
    try:
        from reportlab.lib.pagesizes import letter
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, KeepTogether
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib import colors
        from reportlab.lib.units import inch
    except ImportError:
        os.system("pip install reportlab --break-system-packages -q")
        from reportlab.lib.pagesizes import letter
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, KeepTogether
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib import colors
        from reportlab.lib.units import inch

    conn = get_conn()
    cur = conn.cursor()

    cur.execute("""
        SELECT r.recipe_id, r.dish_name, r.dish_category
        FROM recipe_dna_master r
        WHERE r.meal_role @> ARRAY['main']::text[]
        AND EXISTS (SELECT 1 FROM recipe_pairing rp WHERE rp.main_recipe_id = r.recipe_id)
        ORDER BY r.dish_name ASC
    """)
    mains = cur.fetchall()
    print(f"Main dishes found: {len(mains)}")

    main_ids = [str(m[0]) for m in mains]
    cur.execute("""
        SELECT rp.main_recipe_id, s.dish_name, rp.source
        FROM recipe_pairing rp
        JOIN recipe_dna_master s ON s.recipe_id = rp.side_recipe_id
        WHERE rp.main_recipe_id = ANY(%s::uuid[])
        ORDER BY rp.confidence DESC
    """, (main_ids,))
    sides_by_main = {}
    for main_id, side_name, source in cur.fetchall():
        sides_by_main.setdefault(str(main_id), []).append((side_name, source))

    cur.close()
    conn.close()

    styles = getSampleStyleSheet()
    main_style = ParagraphStyle("MainDish", parent=styles["Heading2"], spaceAfter=4, textColor=colors.HexColor("#1A3A2E"))
    category_style = ParagraphStyle("Category", parent=styles["Normal"], fontSize=9, textColor=colors.grey, spaceAfter=6)
    side_style = ParagraphStyle("Side", parent=styles["Normal"], leftIndent=16, spaceAfter=2)
    intro_style = ParagraphStyle("Intro", parent=styles["Normal"], spaceAfter=16)

    doc = SimpleDocTemplate(args.out, pagesize=letter,
                             topMargin=0.75*inch, bottomMargin=0.75*inch,
                             leftMargin=0.75*inch, rightMargin=0.75*inch)
    story = []

    story.append(Paragraph("Ladleful — Main Dish &amp; Side Dish Pairing Review", styles["Title"]))
    story.append(Paragraph(
        "Please review each main dish below and its listed side dishes. "
        "Mark anything that looks wrong, unlikely, or unrelated to how it's "
        "actually eaten — a side that doesn't genuinely go with the main "
        "dish, or anything missing that clearly should be there.",
        intro_style
    ))

    for recipe_id, dish_name, dish_category in mains:
        sides = sides_by_main.get(str(recipe_id), [])
        block = [Paragraph(escape(dish_name), main_style)]
        if dish_category:
            block.append(Paragraph(f"Category: {escape(dish_category)}", category_style))
        if sides:
            for side_name, source in sides:
                block.append(Paragraph(f"- {escape(side_name)}", side_style))
        else:
            block.append(Paragraph("(no sides listed)", side_style))
        block.append(Spacer(1, 10))
        story.append(KeepTogether(block))

    doc.build(story)
    print(f"\nDone -- saved to {args.out}")


if __name__ == "__main__":
    main()
