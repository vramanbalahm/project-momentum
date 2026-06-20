import { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { getDishImage } from '../utils/imageUtils';

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const C = {
  bg:     "#F7F4EE",
  card:   "#FDFCF8",
  green:  "#1A3A2E",
  mint:   "#9FE1CB",
  border: "#EDE8E0",
  muted:  "#888780",
  text:   "#2C2C2A",
  accent: "#0F6E56",
};

const INTENSITIES   = ["Light", "Medium", "Heavy"];
const DIETS         = ["Veg", "Vegan", "Eggitarian", "Non-Veg"];
const MEAL_SLOTS    = ["Breakfast", "Lunch", "Dinner"];
const MAIN_CATS     = ["tiffin", "rice", "bread", "millet", "continental"];
const SIDE_CATS     = ["wet", "semi_dry", "dry", "condiment", "sweet"];

export default function DishSearch({ onBack }) {
  const [query,      setQuery]      = useState('');
  const [results,    setResults]    = useState([]);
  const [loading,    setLoading]    = useState(false);
  const [subRegions, setSubRegions] = useState([]);

  // Filters
  const [showSides,   setShowSides]   = useState(false);
  const [intensity,   setIntensity]   = useState('');
  const [dietType,    setDietType]    = useState('');
  const [subRegion,   setSubRegion]   = useState('');
  const [mealSlot,    setMealSlot]    = useState('');
  const [dishCat,     setDishCat]     = useState('');

  const inputRef = useRef(null);
  const [detailDish, setDetailDish] = useState(null);

  useEffect(() => {
    inputRef.current?.focus();
    fetchResults();
    axios.get(`${API_BASE}/recipes/sub-regions`)
      .then(r => setSubRegions(r.data.sub_regions || []))
      .catch(() => {});
  }, []);

  const fetchResults = async (overrides = {}) => {
    setLoading(true);
    try {
      const params = { q: overrides.query ?? query };
      const intens   = overrides.intensity  ?? intensity;
      const diet     = overrides.dietType   ?? dietType;
      const region   = overrides.subRegion  ?? subRegion;
      const slot     = overrides.mealSlot   ?? mealSlot;
      const cat      = overrides.dishCat    ?? dishCat;
      const sides    = overrides.showSides  ?? showSides;

      if (intens)  params.intensity     = intens;
      if (diet)    params.diet_type     = diet;
      if (region)  params.sub_region    = region;
      if (slot)    params.meal_slot     = slot;
      if (cat)     params.dish_category = cat;
      if (sides)   params.is_side_dish  = true;
      else         params.is_side_dish  = false;

      const res = await axios.get(`${API_BASE}/recipes/search`, { params });
      setResults(res.data);
    } catch { setResults([]); }
    finally { setLoading(false); }
  };

  const setFilter = (key, val) => {
    const updates = { [key]: val };
    if (key === 'intensity')  setIntensity(val);
    if (key === 'dietType')   setDietType(val);
    if (key === 'subRegion')  setSubRegion(val);
    if (key === 'mealSlot')   setMealSlot(val);
    if (key === 'dishCat')    setDishCat(val);
    if (key === 'showSides')  setShowSides(val);
    fetchResults(updates);
  };

  const clearFilters = () => {
    setIntensity(''); setDietType(''); setSubRegion('');
    setMealSlot(''); setDishCat(''); setShowSides(false);
    fetchResults({ intensity:'', dietType:'', subRegion:'', mealSlot:'', dishCat:'', showSides: false });
  };

  const hasFilters = intensity || dietType || subRegion || mealSlot || dishCat;

  const chipStyle = (active) => ({
    padding: "3px 10px", borderRadius: 20, fontSize: 11, fontWeight: 500,
    cursor: "pointer", flexShrink: 0, whiteSpace: "nowrap",
    background: active ? C.green : "transparent",
    color:      active ? C.mint  : C.muted,
    border:     `0.5px solid ${active ? "#5DCAA5" : C.border}`,
  });

  const rowStyle = {
    padding: "5px 12px 2px", display: "flex", gap: 5,
    overflowX: "auto", scrollbarWidth: "none",
    WebkitOverflowScrolling: "touch",  // smooth scroll on iOS
    msOverflowStyle: "none",           // hide scrollbar on IE
  };

  const catLabel = (c) => c.replace("_", " ");

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100vh", background: C.bg, maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "12px 16px 10px", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
          <span onClick={onBack} style={{ color: C.mint, fontSize: 13, cursor: "pointer" }}>← Back</span>
          <span style={{ color: "#FDFCF8", fontSize: 15, fontWeight: 500, flex: 1, textAlign: "center" }}>Dish Search</span>
          {hasFilters && (
            <span onClick={clearFilters} style={{ color: C.mint, fontSize: 11, cursor: "pointer" }}>Clear</span>
          )}
        </div>
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 10, padding: "8px 12px", display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ color: C.mint, fontSize: 15 }}>🔍</span>
          <input
            ref={inputRef}
            value={query}
            onChange={e => { setQuery(e.target.value); fetchResults({ query: e.target.value }); }}
            placeholder="Search dishes..."
            style={{ background: "transparent", border: "none", outline: "none", color: "#FDFCF8", fontSize: 13, width: "100%" }}
          />
          {query && <span onClick={() => { setQuery(''); fetchResults({ query: '' }); }} style={{ color: C.mint, cursor: "pointer" }}>✕</span>}
        </div>
      </div>

      {/* Filter chips */}
      <div style={{ background: "#F0EDE6", borderBottom: `0.5px solid ${C.border}`, flexShrink: 0 }}>

        {/* Main / Side toggle */}
        <div style={{ ...rowStyle, paddingTop: 8 }}>
          <div onClick={() => setFilter('showSides', false)} style={chipStyle(!showSides)}>Main dish</div>
          <div onClick={() => setFilter('showSides', true)}  style={chipStyle(showSides)}>Side dish</div>
        </div>

        {/* Meal slot */}
        <div style={rowStyle}>
          <div onClick={() => setFilter('mealSlot', '')} style={chipStyle(!mealSlot)}>All slots</div>
          {MEAL_SLOTS.map(s => (
            <div key={s} onClick={() => setFilter('mealSlot', mealSlot === s ? '' : s)} style={chipStyle(mealSlot === s)}>{s}</div>
          ))}
        </div>

        {/* Dish category */}
        <div style={rowStyle}>
          <div onClick={() => setFilter('dishCat', '')} style={chipStyle(!dishCat)}>All types</div>
          {(showSides ? SIDE_CATS : MAIN_CATS).map(c => (
            <div key={c} onClick={() => setFilter('dishCat', dishCat === c ? '' : c)} style={chipStyle(dishCat === c)}>{catLabel(c)}</div>
          ))}
        </div>

        {/* Intensity */}
        <div style={rowStyle}>
          <div onClick={() => setFilter('intensity', '')} style={chipStyle(!intensity)}>All intensity</div>
          {INTENSITIES.map(i => (
            <div key={i} onClick={() => setFilter('intensity', intensity === i ? '' : i)} style={chipStyle(intensity === i)}>{i}</div>
          ))}
        </div>

        {/* Diet */}
        <div style={rowStyle}>
          <div onClick={() => setFilter('dietType', '')} style={chipStyle(!dietType)}>All diets</div>
          {DIETS.map(d => (
            <div key={d} onClick={() => setFilter('dietType', dietType === d ? '' : d)} style={chipStyle(dietType === d)}>{d}</div>
          ))}
        </div>

        {/* Sub-region */}
        {subRegions.length > 0 && (
          <div style={rowStyle}>
            <div onClick={() => setFilter('subRegion', '')} style={chipStyle(!subRegion)}>All regions</div>
            {subRegions.map(r => (
              <div key={r} onClick={() => setFilter('subRegion', subRegion === r ? '' : r)} style={chipStyle(subRegion === r)}>{r}</div>
            ))}
          </div>
        )}

        {/* Count */}
        <div style={{ display: "flex", justifyContent: "space-between", padding: "3px 14px 6px" }}>
          <span style={{ fontSize: 10, color: C.muted }}>{loading ? "Searching..." : `${results.length} dishes`}</span>
        </div>
      </div>

      {/* Results */}
      <div style={{ flex: 1, overflowY: "auto" }}>
        {results.map((recipe, idx) => {
          const img = getDishImage(recipe);
          return (
            <div key={recipe.recipe_id} style={{
              display: "flex", alignItems: "center", gap: 12,
              padding: "10px 14px",
              borderBottom: `0.5px solid ${C.border}`,
              background: C.card,
            }}>
              {/* Thumbnail */}
              <div style={{ width: 44, height: 44, borderRadius: 10, background: "#E1F5EE", flexShrink: 0, overflow: "hidden", display: "flex", alignItems: "center", justifyContent: "center" }}>
                {img
                  ? <img src={img} alt={recipe.name} style={{ width: "100%", height: "100%", objectFit: "cover" }} onError={e => { e.target.style.display = "none"; }} />
                  : <span style={{ fontSize: 20 }}>🍽️</span>
                }
              </div>
              {/* Info */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 500, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                  {recipe.name}
                </div>
                <div style={{ fontSize: 10, color: C.muted, marginTop: 2 }}>
                  {[recipe.diet_type, recipe.intensity_level, recipe.sub_region].filter(Boolean).join(" · ")}
                </div>
              </div>
              {/* Right side — category + ? button */}
              <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 4, flexShrink: 0 }}>
                {recipe.dish_category && (
                  <div style={{ padding: "2px 8px", borderRadius: 10, background: "#E1F5EE", color: C.accent, fontSize: 10, fontWeight: 500 }}>
                    {catLabel(recipe.dish_category)}
                  </div>
                )}
                <div onClick={() => setDetailDish(recipe)}
                  style={{ width: 22, height: 22, borderRadius: "50%", background: C.green, color: C.mint, fontSize: 11, fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                  ?
                </div>
              </div>
            </div>
          );
        })}
        {!loading && results.length === 0 && (
          <div style={{ textAlign: "center", padding: 40, color: C.muted, fontSize: 13 }}>No dishes found</div>
        )}
      </div>

      {/* Detail modal */}
      {detailDish && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 200, display: "flex", alignItems: "flex-end" }}
          onClick={() => setDetailDish(null)}>
          <div onClick={e => e.stopPropagation()}
            style={{ background: C.card, borderRadius: "16px 16px 0 0", width: "100%", maxWidth: 480, margin: "0 auto", maxHeight: "75vh", display: "flex", flexDirection: "column" }}>

            {/* Modal header */}
            <div style={{ padding: "14px 16px 10px", borderBottom: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", gap: 10 }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: C.text }}>{detailDish.name}</div>
                <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>
                  {[detailDish.diet_type, detailDish.intensity_level, detailDish.sub_region].filter(Boolean).join(" · ")}
                </div>
              </div>
              <span onClick={() => setDetailDish(null)} style={{ color: C.muted, fontSize: 18, cursor: "pointer" }}>✕</span>
            </div>

            {/* Modal content */}
            <div style={{ overflowY: "auto", padding: "14px 16px", flex: 1 }}>

              {/* Ingredients */}
              {detailDish.ingredients_json && (() => {
                try {
                  const ings = typeof detailDish.ingredients_json === 'string'
                    ? JSON.parse(detailDish.ingredients_json)
                    : detailDish.ingredients_json;
                  return ings.length > 0 ? (
                    <div style={{ marginBottom: 16 }}>
                      <div style={{ fontSize: 12, fontWeight: 600, color: C.text, marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.04em" }}>Ingredients</div>
                      {ings.map((ing, i) => (
                        <div key={i} style={{ display: "flex", justifyContent: "space-between", padding: "5px 0", borderBottom: `0.5px solid ${C.border}`, fontSize: 12 }}>
                          <span style={{ color: C.text }}>{ing.name}{ing.name_ta ? ` (${ing.name_ta})` : ""}</span>
                          <span style={{ color: C.muted }}>{ing.quantity} {ing.unit}</span>
                        </div>
                      ))}
                    </div>
                  ) : null;
                } catch { return null; }
              })()}

              {/* Prep steps */}
              {detailDish.prep_steps && (() => {
                try {
                  const steps = typeof detailDish.prep_steps === 'string'
                    ? JSON.parse(detailDish.prep_steps)
                    : detailDish.prep_steps;
                  const stepList = Array.isArray(steps) ? steps : steps?.steps || [];
                  return stepList.length > 0 ? (
                    <div>
                      <div style={{ fontSize: 12, fontWeight: 600, color: C.text, marginBottom: 8, textTransform: "uppercase", letterSpacing: "0.04em" }}>Preparation</div>
                      {stepList.map((step, i) => (
                        <div key={i} style={{ display: "flex", gap: 10, marginBottom: 10 }}>
                          <div style={{ width: 20, height: 20, borderRadius: "50%", background: C.green, color: C.mint, fontSize: 10, fontWeight: 700, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                            {i + 1}
                          </div>
                          <div style={{ fontSize: 12, color: C.text, lineHeight: 1.5 }}>
                            {typeof step === "string" ? step : step.instruction || step.step || JSON.stringify(step)}
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : null;
                } catch { return null; }
              })()}

              {!detailDish.ingredients_json && !detailDish.prep_steps && (
                <div style={{ textAlign: "center", color: C.muted, fontSize: 13, padding: 20 }}>No details available</div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
