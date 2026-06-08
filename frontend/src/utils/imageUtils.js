// utils/imageUtils.js
// Central image URL resolver — handles local dev and production GCS

const IMAGE_BASE = import.meta.env.VITE_IMAGE_BASE || "/assets/meals";

/**
 * Resolve a recipe image URL.
 * 
 * In DB, images are stored as:
 *   - Full GCS URL: https://storage.googleapis.com/...
 *   - Relative path: /assets/meals/dish_name.png  (legacy)
 *   - Filename only: chicken_curry.png  (future)
 *   - null
 * 
 * Returns a fully qualified URL using IMAGE_BASE for relative/filename paths.
 */
export function getImageUrl(url, dishName = null) {
  if (!url && !dishName) return null;

  // Already a full URL — return as is
  if (url && (url.startsWith("http://") || url.startsWith("https://"))) {
    return url;
  }

  // Relative path /assets/meals/xxx — replace base
  if (url && url.startsWith("/assets/meals/")) {
    const filename = url.replace("/assets/meals/", "");
    return `${IMAGE_BASE}/${filename}`;
  }

  // Filename only — append to base
  if (url && !url.startsWith("/")) {
    return `${IMAGE_BASE}/${url}`;
  }

  // Fallback — generate filename from dish name
  if (dishName) {
    const filename = dishName.toLowerCase().replace(/\s+/g, "_").replace(/[^a-z0-9_]/g, "") + ".jpg";
    return `${IMAGE_BASE}/${filename}`;
  }

  return null;
}

/**
 * Get best available image for a dish object.
 * Tries thumb first, falls back to hero, then generates from dish name.
 */
export function getDishImage(dish) {
  if (!dish) return null;
  return (
    getImageUrl(dish.thumb || dish.carousel_thumb_url, dish.name || dish.dish_name) ||
    getImageUrl(dish.hero || dish.hero_image_url, dish.name || dish.dish_name)
  );
}
