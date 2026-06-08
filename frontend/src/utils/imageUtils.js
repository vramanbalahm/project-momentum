// utils/imageUtils.js
// Central image URL resolver — filename only in DB, base URL from environment

const IMAGE_BASE = (import.meta.env.VITE_IMAGE_BASE || "http://localhost:8000/recipe_images").replace(/\/$/, "");

/**
 * Build full image URL from filename stored in DB.
 * DB stores filename only e.g. "chicken_curry.jpg"
 * Base URL comes from environment config.
 */
export function getImageUrl(filename) {
  if (!filename) return null;
  // Already a full URL — return as is (legacy)
  if (filename.startsWith("http://") || filename.startsWith("https://")) {
    return filename;
  }
  // Strip any legacy path prefix, keep filename only
  const name = filename.split("/").pop();
  if (!name) return null;
  return `${IMAGE_BASE}/${name}`;
}

/**
 * Get best available image for a dish object.
 * Uses hero_image_url as primary (thumb has only 5 records).
 */
export function getDishImage(dish) {
  if (!dish) return null;
  const filename = 
    dish.thumb || dish.carousel_thumb_url ||
    dish.hero  || dish.hero_image_url;
  return getImageUrl(filename);
}
