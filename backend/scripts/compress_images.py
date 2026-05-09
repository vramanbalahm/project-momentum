"""
compress_images.py — Bulk compress all recipe images in backend/recipe_images/
Uses image_utils.py — same compression pipeline as customer uploads.

Usage:
    cd C:\\Users\\SATISH.000\\project-momentum\\backend
    pip install Pillow --break-system-packages

    # Dry run — see what will happen without changing files
    python scripts/compress_images.py --dry-run

    # Compress all images
    python scripts/compress_images.py

    # Compress specific folder
    python scripts/compress_images.py --folder recipe_images

Requirements:
    pip install Pillow
"""

import argparse
import sys
import io
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from utils.image_utils import compress_image_file

IMAGE_DIR = Path(__file__).resolve().parent.parent / "recipe_images"


def main():
    parser = argparse.ArgumentParser(description="Bulk compress recipe images")
    parser.add_argument("--folder", default=None, help="Custom image folder path")
    parser.add_argument("--dry-run", action="store_true", help="Show what would happen without changing files")
    args = parser.parse_args()

    image_dir = Path(args.folder) if args.folder else IMAGE_DIR

    if not image_dir.exists():
        print(f"[FAIL] Image folder not found: {image_dir}")
        sys.exit(1)

    # Find all images
    images = list(image_dir.glob("*.jpg")) + list(image_dir.glob("*.jpeg")) + list(image_dir.glob("*.png"))
    images.sort()

    if not images:
        print(f"No images found in {image_dir}")
        return

    print(f"\n== Momentum Image Compressor ==")
    print(f"   Folder  : {image_dir}")
    print(f"   Images  : {len(images)}")
    print(f"   Dry run : {args.dry_run}")
    print(f"   Target  : max 800x800px, 80% JPEG quality, under 200KB\n")

    total_original_kb  = 0
    total_compressed_kb = 0
    compressed = 0
    skipped    = 0
    failed     = 0

    for i, img_path in enumerate(images, 1):
        original_kb = img_path.stat().st_size / 1024

        if args.dry_run:
            print(f"[{i}/{len(images)}] {img_path.name} — {original_kb:.0f}KB -> would compress")
            total_original_kb += original_kb
            continue

        result = compress_image_file(str(img_path))

        if "error" in result:
            print(f"[{i}/{len(images)}] [FAIL] {img_path.name} — {result['error']}")
            failed += 1
            continue

        total_original_kb   += result["original_kb"]
        total_compressed_kb += result["compressed_kb"]

        if result["saved_kb"] > 10:
            print(f"[{i}/{len(images)}] [OK] {img_path.name} — {result['original_kb']:.0f}KB -> {result['compressed_kb']:.0f}KB (saved {result['saved_kb']:.0f}KB)")
            compressed += 1
        else:
            print(f"[{i}/{len(images)}] [SKIP] {img_path.name} — already small ({result['original_kb']:.0f}KB)")
            skipped += 1

    print(f"\n{'='*50}")
    if args.dry_run:
        print(f"  Total size  : {total_original_kb/1024:.1f}MB")
        print(f"  Dry run     : no files changed")
    else:
        saved = total_original_kb - total_compressed_kb
        print(f"  Compressed  : {compressed}")
        print(f"  Skipped     : {skipped}")
        print(f"  Failed      : {failed}")
        print(f"  Before      : {total_original_kb/1024:.1f}MB")
        print(f"  After       : {total_compressed_kb/1024:.1f}MB")
        print(f"  Saved       : {saved/1024:.1f}MB ({(saved/total_original_kb*100):.0f}%)")
    print(f"{'='*50}\n")


if __name__ == "__main__":
    main()
