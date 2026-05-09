"""
image_utils.py — Reusable image compression utility for Momentum
Used by:
  1. compress_images.py — bulk compress existing recipe images
  2. main.py — compress customer uploaded images before saving

Compression settings:
  - Format: JPEG
  - Quality: 80%
  - Max dimensions: 800x800 pixels
  - Target size: under 200KB per image
"""

from PIL import Image
import io
import os
from pathlib import Path


# ── Compression settings ──────────────────────────────────────────────────────
MAX_DIMENSION = 800   # max width or height in pixels
JPEG_QUALITY  = 80    # 0-100, 80 is good balance of quality and size
TARGET_KB     = 200   # target size in KB


def compress_image_file(input_path: str, output_path: str = None) -> dict:
    """
    Compress an image file on disk.
    If output_path is None, overwrites the input file.

    Returns:
        dict with original_kb, compressed_kb, saved_kb, output_path
    """
    input_path  = Path(input_path)
    output_path = Path(output_path) if output_path else input_path

    if not input_path.exists():
        return {"error": f"File not found: {input_path}"}

    original_kb = input_path.stat().st_size / 1024

    try:
        with Image.open(input_path) as img:
            result = _compress(img)

        output_path.write_bytes(result["bytes"])
        compressed_kb = len(result["bytes"]) / 1024

        return {
            "original_kb":   round(original_kb, 1),
            "compressed_kb": round(compressed_kb, 1),
            "saved_kb":      round(original_kb - compressed_kb, 1),
            "output_path":   str(output_path),
            "dimensions":    result["dimensions"],
        }

    except Exception as e:
        return {"error": str(e)}


def compress_image_bytes(image_bytes: bytes) -> bytes:
    """
    Compress raw image bytes (for customer uploads via API).
    Returns compressed JPEG bytes.
    """
    with Image.open(io.BytesIO(image_bytes)) as img:
        result = _compress(img)
    return result["bytes"]


def _compress(img: Image.Image) -> dict:
    """
    Core compression logic — resize and compress to JPEG.
    Handles RGBA, palette images etc.
    """
    # Convert to RGB (handles PNG with transparency, palette images)
    if img.mode in ("RGBA", "P", "LA"):
        background = Image.new("RGB", img.size, (255, 255, 255))
        if img.mode == "P":
            img = img.convert("RGBA")
        background.paste(img, mask=img.split()[-1] if img.mode == "RGBA" else None)
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")

    # Resize if larger than MAX_DIMENSION
    w, h = img.size
    if w > MAX_DIMENSION or h > MAX_DIMENSION:
        img.thumbnail((MAX_DIMENSION, MAX_DIMENSION), Image.LANCZOS)

    # Compress to JPEG
    output = io.BytesIO()
    quality = JPEG_QUALITY

    img.save(output, format="JPEG", quality=quality, optimize=True)

    # If still over target, reduce quality progressively
    while output.tell() / 1024 > TARGET_KB and quality > 50:
        output = io.BytesIO()
        quality -= 5
        img.save(output, format="JPEG", quality=quality, optimize=True)

    return {
        "bytes":      output.getvalue(),
        "dimensions": img.size,
        "quality":    quality,
    }
