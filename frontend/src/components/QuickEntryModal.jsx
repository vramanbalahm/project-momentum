import { useState, useEffect, useRef } from 'react';
import { useAuth } from '../context/AuthContext';

const C = {
  bg:     "#F7F4EE",
  card:   "#FDFCF8",
  green:  "#1A3A2E",
  mint:   "#9FE1CB",
  teal:   "#5DCAA5",
  border: "#EDE8E0",
  muted:  "#888780",
  text:   "#2C2C2A",
  accent: "#0F6E56",
};

const DIETS = ["Veg", "Vegan", "Eggitarian", "Non-Veg"];
const MEAL_SLOTS = ["Breakfast", "Lunch", "Dinner"];

/**
 * QuickEntryModal — create a household-private "quick dish" for immediate
 * use in the plan, no review/approval step needed.
 *
 * Props:
 *   initialDishName   Prefills the dish name from whatever the person searched
 *   initialMealSlot   Prefills the meal slot hint if the search was already scoped to one
 *   isSideDish        Inherited from the search context (Main dish / Side dish toggle) --
 *                      not re-asked here, since the person already told us via that toggle
 *   onClose           Called to dismiss without creating anything
 *   onCreated(recipe) Called with a recipe object shaped like a normal search
 *                      result, ready to pass straight into onSelect / display in results
 */
export default function QuickEntryModal({ initialDishName = '', initialMealSlot = '', isSideDish = false, onClose, onCreated }) {
  const { apiFetch } = useAuth();
  const [dishName, setDishName] = useState(initialDishName);
  const [dietType, setDietType] = useState('');
  const [mealSlot, setMealSlot] = useState(initialMealSlot);

  const [ingredientQuery, setIngredientQuery] = useState('');
  const [allIngredients, setAllIngredients] = useState([]);
  const [ingredientResults, setIngredientResults] = useState([]);
  const [selectedIngredient, setSelectedIngredient] = useState(null);
  const [loadingIngredients, setLoadingIngredients] = useState(true);

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const inputRef = useRef(null);

  useEffect(() => {
    inputRef.current?.focus();
    // Reuse the pantry ingredient list -- same catalog, already fetches
    // everything in one call. Filtered client-side as the person types.
    (async () => {
      try {
        const data = await apiFetch('/pantry/ingredients');
        const flat = (data.categories || []).flatMap(cat => cat.ingredients || []);
        setAllIngredients(flat);
      } catch {
        setAllIngredients([]);
      } finally {
        setLoadingIngredients(false);
      }
    })();
  }, []);

  const handleIngredientSearch = (val) => {
    setIngredientQuery(val);
    setSelectedIngredient(null);
    if (!val.trim()) { setIngredientResults([]); return; }
    const q = val.toLowerCase();
    setIngredientResults(
      allIngredients.filter(i => (i.name_en || '').toLowerCase().includes(q)).slice(0, 8)
    );
  };

  const pickIngredient = (ing) => {
    setSelectedIngredient(ing);
    setIngredientQuery(ing.name_en);
    setIngredientResults([]);
  };

  const canSubmit = dishName.trim() && dietType && selectedIngredient && !submitting;

  const handleSubmit = async () => {
    if (!canSubmit) return;
    setSubmitting(true);
    setError(null);
    try {
      const res = await apiFetch('/recipes/quick-entry', {
        method: 'POST',
        body: JSON.stringify({
          dish_name: dishName.trim(),
          main_ingredient_id: selectedIngredient.id,
          diet_type: dietType,
          meal_slot: mealSlot || undefined,
          is_side_dish: isSideDish,
        }),
      });
      onCreated({
        recipe_id: res.recipe_id,
        name: res.dish_name,
        diet_type: dietType,
        is_sattvic: false,
        intensity_level: "Medium",
        sub_region: null,
        thumb: null,
        hero: null,
        prep_steps: null,
        ingredients_json: null,
        meal_role: isSideDish ? ["side"] : ["main"],
        dish_category: null,
      });
    } catch (e) {
      setError(e.message || "Couldn't add this dish -- try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{
      position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", zIndex: 1000,
      display: "flex", alignItems: "flex-end", justifyContent: "center"
    }} onClick={onClose}>
      <div
        onClick={e => e.stopPropagation()}
        style={{
          background: C.card, borderRadius: "20px 20px 0 0", width: "100%", maxWidth: 480,
          maxHeight: "85vh", overflowY: "auto", padding: 20, boxSizing: "border-box"
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
          <span style={{ fontSize: 15, fontWeight: 600, color: C.green }}>Add your own dish</span>
          <button onClick={onClose} style={{ background: "none", border: "none", fontSize: 18, color: C.muted, cursor: "pointer" }}>×</button>
        </div>
        <div style={{ fontSize: 12, color: C.muted, marginBottom: 16 }}>
          This stays private to your household -- ready to use right away, no review needed.
        </div>

        {/* Dish name */}
        <label style={{ fontSize: 11, fontWeight: 500, color: C.text }}>Dish name</label>
        <input
          ref={inputRef}
          value={dishName}
          onChange={e => setDishName(e.target.value)}
          placeholder="e.g. Amma's Special Kootu"
          style={{ width: "100%", padding: "9px 12px", borderRadius: 10, border: `0.5px solid ${C.border}`,
            fontSize: 13, margin: "6px 0 14px", boxSizing: "border-box" }}
        />

        {/* Diet type */}
        <label style={{ fontSize: 11, fontWeight: 500, color: C.text }}>Diet type</label>
        <div style={{ display: "flex", gap: 6, margin: "6px 0 14px", flexWrap: "wrap" }}>
          {DIETS.map(d => (
            <div key={d} onClick={() => setDietType(d)}
              style={{ padding: "5px 12px", borderRadius: 20, fontSize: 12, fontWeight: 500, cursor: "pointer",
                background: dietType === d ? C.green : "transparent",
                color: dietType === d ? C.mint : C.muted,
                border: `0.5px solid ${dietType === d ? C.teal : C.border}` }}>
              {d}
            </div>
          ))}
        </div>

        {/* Mandatory main ingredient */}
        <label style={{ fontSize: 11, fontWeight: 500, color: C.text }}>Main ingredient (required)</label>
        <div style={{ fontSize: 10, color: C.muted, marginTop: 2 }}>
          The one defining ingredient -- used to match this dish against your pantry.
        </div>
        <div style={{ position: "relative", margin: "6px 0 14px" }}>
          <input
            value={ingredientQuery}
            onChange={e => handleIngredientSearch(e.target.value)}
            placeholder={loadingIngredients ? "Loading ingredients..." : "Search ingredient..."}
            disabled={loadingIngredients}
            style={{ width: "100%", padding: "9px 12px", borderRadius: 10, border: `0.5px solid ${selectedIngredient ? C.teal : C.border}`,
              fontSize: 13, boxSizing: "border-box" }}
          />
          {ingredientResults.length > 0 && (
            <div style={{ position: "absolute", top: "100%", left: 0, right: 0, background: C.card,
              border: `0.5px solid ${C.border}`, borderRadius: 10, marginTop: 4, zIndex: 10,
              maxHeight: 180, overflowY: "auto", boxShadow: "0 4px 12px rgba(0,0,0,0.08)" }}>
              {ingredientResults.map(ing => (
                <div key={ing.id} onClick={() => pickIngredient(ing)}
                  style={{ padding: "8px 12px", fontSize: 13, cursor: "pointer", borderBottom: `0.5px solid ${C.border}` }}>
                  {ing.name_en}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Meal slot hint (optional) */}
        <label style={{ fontSize: 11, fontWeight: 500, color: C.text }}>Meal slot (optional)</label>
        <div style={{ display: "flex", gap: 6, margin: "6px 0 20px", flexWrap: "wrap" }}>
          {["", ...MEAL_SLOTS].map(s => (
            <div key={s} onClick={() => setMealSlot(s)}
              style={{ padding: "5px 12px", borderRadius: 20, fontSize: 12, fontWeight: 500, cursor: "pointer",
                background: mealSlot === s ? C.green : "transparent",
                color: mealSlot === s ? C.mint : C.muted,
                border: `0.5px solid ${mealSlot === s ? C.teal : C.border}` }}>
              {s || "Any"}
            </div>
          ))}
        </div>

        {error && (
          <div style={{ fontSize: 12, color: "#993C1D", background: "#FAECE7", borderRadius: 8, padding: "8px 10px", marginBottom: 12 }}>
            {error}
          </div>
        )}

        <button
          onClick={handleSubmit}
          disabled={!canSubmit}
          style={{
            width: "100%", padding: 13, borderRadius: 12, border: "none", fontSize: 14, fontWeight: 500,
            background: canSubmit ? C.green : C.border,
            color: canSubmit ? C.mint : C.muted,
            cursor: canSubmit ? "pointer" : "not-allowed"
          }}>
          {submitting ? "Adding..." : "Add dish"}
        </button>
      </div>
    </div>
  );
}
