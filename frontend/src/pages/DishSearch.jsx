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
              {/* Category badge */}
              {recipe.dish_category && (
                <div style={{ padding: "2px 8px", borderRadius: 10, background: "#E1F5EE", color: C.accent, fontSize: 10, fontWeight: 500, flexShrink: 0 }}>
                  {catLabel(recipe.dish_category)}
                </div>
              )}
            </div>
          );
        })}
        {!loading && results.length === 0 && (
          <div style={{ textAlign: "center", padding: 40, color: C.muted, fontSize: 13 }}>No dishes found</div>
        )}
      </div>
    </div>
  );
}
