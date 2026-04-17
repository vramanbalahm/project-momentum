import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8000';

/**
 * swapSlots
 * Pure in-memory swap — no API call.
 * Takes current blueprint and two slot keys, returns new blueprint.
 * Works for any combination: same day, cross-day, any meal type.
 *
 * @param {string} sourceKey  e.g. "Monday-Lunch"
 * @param {string} targetKey  e.g. "Wednesday-Dinner"
 * @param {object} blueprint  current blueprint state
 * @returns {object}          new blueprint with slots swapped
 */
export function swapSlots(sourceKey, targetKey, blueprint) {
  if (!sourceKey || !targetKey || sourceKey === targetKey) return blueprint;

  const newBlueprint = { ...blueprint };
  const sourceMeal = newBlueprint[sourceKey];
  const targetMeal = newBlueprint[targetKey];

  newBlueprint[sourceKey] = targetMeal || { main: null, mains: [], sides: [] };
  newBlueprint[targetKey] = sourceMeal || { main: null, mains: [], sides: [] };

  return newBlueprint;
}

/**
 * swapDays
 * Swaps all meal slots between two days in one call.
 * Loops through all meal types and calls swapSlots for each.
 * Used for day-level swap (future feature).
 *
 * @param {string}   sourceDay  e.g. "Monday"
 * @param {string}   targetDay  e.g. "Wednesday"
 * @param {string[]} mealTypes  e.g. ["Breakfast", "Lunch", "Dinner"]
 * @param {object}   blueprint  current blueprint state
 * @returns {object}            new blueprint with all slots swapped
 */
export function swapDays(sourceDay, targetDay, mealTypes, blueprint) {
  if (!sourceDay || !targetDay || sourceDay === targetDay) return blueprint;

  let newBlueprint = { ...blueprint };
  for (const type of mealTypes) {
    const sourceKey = `${sourceDay}-${type}`;
    const targetKey = `${targetDay}-${type}`;
    newBlueprint = swapSlots(sourceKey, targetKey, newBlueprint);
  }
  return newBlueprint;
}

/**
 * auditBlueprint
 * Sends current blueprint to backend /audit endpoint.
 * Returns a map of slotKey -> audit result.
 * Callable anytime — after swap, after edit, before save.
 *
 * @param {object}   blueprint      current blueprint state
 * @param {function} getTargetDate  function to resolve day name -> YYYY-MM-DD
 * @returns {object}                map of { "Monday-Lunch": { status, message, score } }
 */
export async function auditBlueprint(blueprint, getTargetDate) {
  const payload = Object.entries(blueprint).map(([key, val]) => {
    const [day, type] = key.split('-');
    const mainsArr = val?.mains && val.mains.length > 0 ? val.mains : (val?.main ? [val.main] : []);
    return {
      day,
      type,
      to_meal: mainsArr.map(m => m.name).join(', ') || 'Skipped',
      date: getTargetDate(day)
    };
  });

  try {
    const res = await axios.post(`${API_BASE}/audit`, payload);
    const resultMap = {};
    res.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
    return { success: true, results: resultMap };
  } catch (err) {
    console.error('Audit failed:', err);
    return { success: false, results: {} };
  }
}

/**
 * persistSwap
 * Calls backend /meal/swap to persist a slot swap to DB.
 * Backend validates, swaps event_detail records, and returns audit.
 *
 * @param {string} sourceKey   e.g. "Monday-Lunch"
 * @param {string} targetKey   e.g. "Wednesday-Dinner"
 * @param {function} getDate   function(dayName) -> YYYY-MM-DD
 * @param {string} weekStart   YYYY-MM-DD of current week's Monday
 * @returns {object}           { success, auditResults }
 */
export async function persistSwap(sourceKey, targetKey, getDate, weekStart) {
  const [sourceDay, sourceType] = sourceKey.split('-');
  const [targetDay, targetType] = targetKey.split('-');

  try {
    const res = await axios.post(`${API_BASE}/meal/swap`, {
      source: { day: sourceDay, type: sourceType, date: getDate(sourceDay) },
      target: { day: targetDay, type: targetType, date: getDate(targetDay) },
      week_start: weekStart
    });
    return { success: true, auditResults: res.data?.audit || {} };
  } catch (err) {
    console.error('Swap persist failed:', err);
    return { success: false, auditResults: {} };
  }
}
