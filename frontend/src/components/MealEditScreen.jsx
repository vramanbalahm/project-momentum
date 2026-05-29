import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const SWAP_REASONS = ['Complexity', 'Inventory', 'Variety', 'Other'];

const DietBadge = ({ dietType, isSattvic }) => {
  const isSatvik = isSattvic;
  const bg = isSatvik ? "#E1F5EE" : dietType === "Non-Veg" ? "#FAECE7" : "#F1EFE8";
  const color = isSatvik ? "#085041" : dietType === "Non-Veg" ? "#712B13" : "#444441";
  const label = isSatvik ? "Satvik" : dietType || "Veg";
  return (
    <span style={{ fontSize: 9, background: bg, color, borderRadius: 6, padding: "2px 7px", fontWeight: 500, whiteSpace: "nowrap" }}>
      {label}
    </span>
  );
};

// ── DISH DETAIL PANEL ──────────────────────────────────────────────────────
class DishDetailErrorBoundary extends React.Component {
  constructor(props) { super(props); this.state = { hasError: false }; }
  static getDerivedStateFromError() { return { hasError: true }; }
  render() {
    if (this.state.hasError) {
      return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}>
          <div style={{ background: "#1A3A2E", padding: "48px 16px 14px", display: "flex", alignItems: "center", gap: 10 }}>
            <button onClick={this.props.onBack} style={{ background: "none", border: "none", color: "#9FE1CB", fontSize: 20, cursor: "pointer" }}>←</button>
            <span style={{ fontSize: 15, fontWeight: 500, color: "#FDFCF8" }}>Dish details</span>
          </div>
          <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", color: "#888780", fontSize: 13 }}>
            Unable to load dish details.
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

function DishDetailPanel({ recipe, onBack, onSelect, selectLabel }) {
  const [vault, setVault] = useState(null);

  useEffect(() => {
    if (!recipe?.recipe_id) return;
    // Use data already on recipe object if available (steps or prep_steps), else fetch
    if (recipe.prep_steps !== undefined || recipe.steps !== undefined) {
      setVault(recipe);
    } else {
      axios.get(`${API_BASE}/recipe/${recipe.recipe_id}/vault`)
        .then(r => setVault(r.data))
        .catch(() => setVault({}));
    }
  }, [recipe?.recipe_id]);

  if (!recipe) return null;

  const rawSteps = vault?.prep_steps || vault?.steps || "";
  const steps = (typeof rawSteps === "string" && rawSteps)
    ? rawSteps.split("\n").filter(s => s && s.trim()).slice(0, 6)
    : [];

  const ingredients = (() => {
    try {
      const raw = vault?.ingredients_json;
      if (!raw) return [];
      const parsed = typeof raw === "string" ? JSON.parse(raw) : raw;
      if (Array.isArray(parsed)) {
        // Array of objects — extract name field; array of strings — use as-is
        return parsed.map(item => typeof item === "object" ? (item.name || item.name_en || "") : item).filter(Boolean);
      }
      return Object.keys(parsed);
    } catch { return []; }
  })();

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", minHeight: 0 }}>
      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "48px 16px 14px", display: "flex", alignItems: "center", gap: 10, flexShrink: 0 }}>
        <button onClick={onBack} style={{ background: "none", border: "none", color: "#9FE1CB", fontSize: 20, cursor: "pointer", padding: 0, lineHeight: 1 }}>←</button>
        <span style={{ fontSize: 15, fontWeight: 500, color: "#FDFCF8" }}>Dish details</span>
      </div>

      <div style={{ flex: 1, overflowY: "auto", minHeight: 0 }}>
        {/* Hero image */}
        <div style={{ position: "relative", height: 160, background: "#B4B2A9", flexShrink: 0 }}>
          {(recipe?.hero || recipe?.hero_image_url) && (
            <img src={recipe.hero || recipe.hero_image_url} alt={recipe.name} style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }}
              onError={e => { e.target.style.display = "none"; }} />
          )}
          <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, background: "linear-gradient(to top, rgba(26,58,46,0.9), transparent)", padding: "24px 14px 10px" }}>
            <div style={{ fontSize: 14, fontWeight: 500, color: "#FDFCF8" }}>{recipe?.name}</div>
            <div style={{ fontSize: 10, color: "#9FE1CB", marginTop: 2 }}>
              {recipe?.diet_type}{recipe?.is_sattvic ? " · Satvik" : ""}{recipe?.intensity_level ? ` · ${recipe.intensity_level}` : ""}
            </div>
          </div>
        </div>

        {/* Quick stats */}
        <div style={{ display: "flex", borderBottom: "0.5px solid #EDE8E0" }}>
          {[
            { val: recipe?.intensity_level || "—", label: "Intensity" },
            { val: recipe?.diet_type || "—", label: "Diet" },
          ].map((s, i) => (
            <div key={i} style={{ flex: 1, padding: "10px 0", textAlign: "center", borderRight: i === 0 ? "0.5px solid #EDE8E0" : "none" }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: "#2C2C2A" }}>{s.val}</div>
              <div style={{ fontSize: 9, color: "#B4B2A9" }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* Prep steps */}
        {steps.length > 0 && (
          <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0" }}>
            <div style={{ fontSize: 9, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Preparation steps</div>
            {steps.map((step, i) => (
              <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 8 }}>
                <div style={{ width: 18, height: 18, borderRadius: "50%", background: "#1A3A2E", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9, color: "#9FE1CB", flexShrink: 0, marginTop: 1 }}>{i + 1}</div>
                <div style={{ fontSize: 12, color: "#2C2C2A", lineHeight: 1.5 }}>{step}</div>
              </div>
            ))}
          </div>
        )}

        {/* Ingredients */}
        {ingredients.length > 0 && (
          <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0" }}>
            <div style={{ fontSize: 9, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>Key ingredients</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
              {ingredients.map((ing, i) => (
                <span key={i} style={{ fontSize: 11, background: "#F1EFE8", border: "0.5px solid #EDE8E0", borderRadius: 20, padding: "3px 10px", color: "#2C2C2A" }}>{ing}</span>
              ))}
            </div>
          </div>
        )}

        {/* Video placeholder */}
        <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0" }}>
          <div style={{ fontSize: 9, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>Video reference</div>
          <div style={{ background: "#F1EFE8", borderRadius: 10, padding: "10px 12px", display: "flex", alignItems: "center", gap: 10 }}>
            <div style={{ width: 32, height: 32, borderRadius: 6, background: "#D85A30", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <div style={{ width: 0, height: 0, borderTop: "6px solid transparent", borderBottom: "6px solid transparent", borderLeft: "10px solid white", marginLeft: 2 }} />
            </div>
            <div>
              <div style={{ fontSize: 11, fontWeight: 500, color: "#2C2C2A" }}>{recipe?.name} — recipe video</div>
              <div style={{ fontSize: 10, color: "#B4B2A9" }}>Video link coming soon</div>
            </div>
          </div>
        </div>
      </div>

      {/* Select button */}
      {onSelect && (
        <div style={{ padding: "14px 16px", paddingBottom: 28, background: "#FFF9F2", borderTop: "0.5px solid #EDE8E0", flexShrink: 0 }}>
          <button onClick={() => onSelect(recipe)} style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: 14, fontSize: 14, fontWeight: 500, cursor: "pointer" }}>
            {selectLabel || "Select this dish"}
          </button>
        </div>
      )}
    </div>
  );
}

// ── SEARCH PANEL ───────────────────────────────────────────────────────────
function SearchPanel({ context, onBack, onSelect, duplicateWarning, onClearWarning }) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [detailRecipe, setDetailRecipe] = useState(null);
  const inputRef = useRef(null);

  useEffect(() => {
    inputRef.current?.focus();
    fetchResults('');
  }, []);

  const fetchResults = async (q) => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE}/recipes/search`, { params: { q } });
      setResults(res.data);
    } catch { setResults([]); }
    finally { setLoading(false); }
  };

  const handleSearch = (val) => {
    setQuery(val);
    fetchResults(val);
  };

  if (detailRecipe) {
    return (
      <DishDetailPanel
        recipe={detailRecipe}
        onBack={() => setDetailRecipe(null)}
        onSelect={onSelect}
        selectLabel={context === 'add-side' ? "Add as side dish" : "Replace with this dish"}
      />
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%" }}>
      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "48px 16px 14px", display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <button onClick={onBack} style={{ background: "none", border: "none", color: "#9FE1CB", fontSize: 20, cursor: "pointer", padding: 0, lineHeight: 1 }}>←</button>
          <span style={{ fontSize: 15, fontWeight: 500, color: "#FDFCF8" }}>Choose a dish</span>
        </div>
        <span style={{ fontSize: 9, color: "#5DCAA5", background: "rgba(93,202,165,0.15)", borderRadius: 6, padding: "3px 8px" }}>
          {context === 'replace-main' ? 'replacing main' : context === 'add-side' ? 'adding side' : 'replacing side'}
        </span>
      </div>

      {/* Search input */}
      <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0", flexShrink: 0 }}>
        <input
          ref={inputRef}
          value={query}
          onChange={e => { handleSearch(e.target.value); onClearWarning && onClearWarning(); }}
          placeholder="Search dishes..."
          style={{ width: "100%", background: "#F1EFE8", border: "0.5px solid #EDE8E0", borderRadius: 10, padding: "9px 14px", fontSize: 13, color: "#2C2C2A", outline: "none", boxSizing: "border-box" }}
        />
        {duplicateWarning && (
          <div style={{ marginTop: 8, fontSize: 11, color: "#993C1D", background: "#FAECE7", borderRadius: 8, padding: "6px 10px" }}>
            {duplicateWarning} is already in this meal slot.
          </div>
        )}
      </div>

      {/* Results */}
      <div style={{ flex: 1, overflowY: "auto", padding: "8px 16px" }}>
        {loading && <div style={{ fontSize: 12, color: "#B4B2A9", padding: "20px 0", textAlign: "center" }}>Searching...</div>}
        {!loading && results.length === 0 && (
          <div style={{ fontSize: 12, color: "#B4B2A9", padding: "20px 0", textAlign: "center" }}>No dishes found</div>
        )}
        {results.map(recipe => (
          <div key={recipe.recipe_id}
            style={{ display: "flex", alignItems: "center", gap: 10, borderBottom: "0.5px solid #EDE8E0",
              background: (!recipe.is_sattvic && recipe.diet_type === "Non-Veg") ? "#FAECE7" : "transparent",
              borderRadius: (!recipe.is_sattvic && recipe.diet_type === "Non-Veg") ? 8 : 0,
              marginBottom: (!recipe.is_sattvic && recipe.diet_type === "Non-Veg") ? 4 : 0,
              padding: (!recipe.is_sattvic && recipe.diet_type === "Non-Veg") ? "9px 8px" : "9px 0"
            }}>
            {/* Thumbnail */}
            <div style={{ width: 44, height: 44, borderRadius: 8, background: "#EDE8E0", flexShrink: 0, overflow: "hidden" }}>
              {recipe.thumb ? (
                <img src={recipe.thumb} alt={recipe.name} style={{ width: "100%", height: "100%", objectFit: "cover" }}
                  onError={e => { e.target.style.display = "none"; }} />
              ) : null}
            </div>
            {/* Info */}
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: recipe.diet_type === "Non-Veg" ? "#712B13" : "#2C2C2A", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{recipe.name}</div>
              {recipe.diet_type === "Non-Veg" && !recipe.is_sattvic
                ? <div style={{ fontSize: 10, color: "#993C1D" }}>⚠ Not Satvik today</div>
                : <div style={{ fontSize: 10, color: "#888780" }}>{recipe.diet_type}{recipe.is_sattvic ? " · Satvik" : ""}</div>
              }
            </div>
            {/* Badge + info button */}
            <div style={{ display: "flex", gap: 6, alignItems: "center", flexShrink: 0 }}>
              <DietBadge dietType={recipe.diet_type} isSattvic={recipe.is_sattvic} />
              <button onClick={() => setDetailRecipe(recipe)} style={{ width: 20, height: 20, borderRadius: "50%", border: "0.5px solid #B4B2A9", background: "none", fontSize: 10, color: "#888780", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", padding: 0 }}>?</button>
              <button onClick={() => onSelect(recipe)} style={{ fontSize: 10, color: "#0F6E56", border: "0.5px solid #0F6E56", borderRadius: 6, padding: "3px 8px", background: "none", cursor: "pointer", whiteSpace: "nowrap" }}>Select</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── REASON CAPTURE ─────────────────────────────────────────────────────────
function ReasonPanel({ recipe, onConfirm, onBack }) {
  const [reason, setReason] = useState('');
  const [note, setNote] = useState('');
  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%" }}>
      <div style={{ background: "#1A3A2E", padding: "48px 16px 14px", display: "flex", alignItems: "center", gap: 10, flexShrink: 0 }}>
        <button onClick={onBack} style={{ background: "none", border: "none", color: "#9FE1CB", fontSize: 20, cursor: "pointer", padding: 0, lineHeight: 1 }}>←</button>
        <span style={{ fontSize: 15, fontWeight: 500, color: "#FDFCF8" }}>Why this change?</span>
      </div>

      <div style={{ flex: 1, padding: "20px 16px", overflowY: "auto" }}>
        {/* Selected dish preview */}
        <div style={{ display: "flex", alignItems: "center", gap: 10, background: "#F1EFE8", borderRadius: 10, padding: 10, marginBottom: 20 }}>
          <div style={{ width: 40, height: 40, borderRadius: 8, background: "#EDE8E0", overflow: "hidden", flexShrink: 0 }}>
            {recipe?.thumb && <img src={recipe.thumb} alt={recipe.name} style={{ width: "100%", height: "100%", objectFit: "cover" }} onError={e => { e.target.style.display = "none"; }} />}
          </div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 500, color: "#2C2C2A" }}>{recipe?.name}</div>
            <div style={{ fontSize: 10, color: "#888780" }}>Selected dish</div>
          </div>
        </div>

        <div style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A", marginBottom: 12 }}>Select a reason</div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 20 }}>
          {SWAP_REASONS.map(r => (
            <button key={r} onClick={() => setReason(r)}
              style={{ fontSize: 12, borderRadius: 20, padding: "7px 14px", cursor: "pointer", fontWeight: 500,
                border: reason === r ? "1.5px solid #0F6E56" : "0.5px solid #EDE8E0",
                background: reason === r ? "#E1F5EE" : "transparent",
                color: reason === r ? "#0F6E56" : "#888780"
              }}>{r}</button>
          ))}
        </div>

        <textarea
          value={note}
          onChange={e => setNote(e.target.value)}
          placeholder="Add a note (optional)..."
          rows={3}
          style={{ width: "100%", background: "#F1EFE8", border: "0.5px solid #EDE8E0", borderRadius: 10, padding: "10px 12px", fontSize: 12, color: "#2C2C2A", outline: "none", resize: "none", boxSizing: "border-box" }}
        />
      </div>

      <div style={{ padding: "14px 16px", paddingBottom: 28, background: "#FFF9F2", borderTop: "0.5px solid #EDE8E0", flexShrink: 0 }}>
        <button
          onClick={() => onConfirm(reason || 'Other', note)}
          style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: 14, fontSize: 14, fontWeight: 500, cursor: "pointer" }}
        >
          Confirm change
        </button>
      </div>
    </div>
  );
}

// ── MAIN: MEAL EDIT SCREEN ─────────────────────────────────────────────────
export default function MealEditScreen({ selected, onClose, onSave }) {
  // selected = { day, type, meal: { main, sides, event_id }, date }
  const { day, type, meal, date } = selected;

  const [localMeal, setLocalMeal] = useState({
    mains: meal?.mains || (meal?.main ? [meal.main] : []),
    sides: meal?.sides || [],
    event_id: meal?.event_id || null
  });

  const [panel, setPanel] = useState('edit'); // 'edit' | 'search' | 'reason' | 'detail'
  const [searchContext, setSearchContext] = useState(null); // { mode: 'replace-main'|'replace-side'|'add-side', sideSeq? }
  const [pendingRecipe, setPendingRecipe] = useState(null);
  const [detailRecipe, setDetailRecipe] = useState(null);
  const [skipped, setSkipped] = useState(false);
  const [saving, setSaving] = useState(false);
  const [duplicateWarning, setDuplicateWarning] = useState(null);

  const openSearch = (mode, sideSeq = null, mainIdx = null) => {
    setSearchContext({ mode, sideSeq, mainIdx });
    setPanel('search');
  };

  const handleSearchSelect = (recipe) => {
    // Duplicate check — same recipe_id cannot appear twice in mains or sides
    const allIds = [
      ...localMeal.mains.map(m => m.recipe_id),
      ...localMeal.sides.map(s => s.recipe_id)
    ];
    const isReplacing = searchContext.mode === 'replace-main' || searchContext.mode === 'replace-side';
    if (!isReplacing && allIds.includes(recipe.recipe_id)) {
      setDuplicateWarning(recipe.name || 'This dish');
      return;
    }
    setDuplicateWarning(null);

    if (searchContext.mode === 'add-side') {
      setLocalMeal(prev => ({
        ...prev,
        sides: [...prev.sides, { ...recipe, dish_sequence: (prev.sides.length + 2) }]
      }));
      setPanel('edit');
    } else if (searchContext.mode === 'add-main') {
      setLocalMeal(prev => ({
        ...prev,
        mains: [...prev.mains, recipe].slice(0, 3)
      }));
      setPanel('edit');
    } else {
      setPendingRecipe({ ...recipe, _context: searchContext });
      setPanel('reason');
    }
  };

  const handleReasonConfirm = (reason, note) => {
    const ctx = pendingRecipe._context;
    if (ctx.mode === 'replace-main') {
      setLocalMeal(prev => ({
        ...prev,
        mains: prev.mains.map((m, i) => i === ctx.mainIdx ? pendingRecipe : m)
      }));
    } else if (ctx.mode === 'replace-side') {
      setLocalMeal(prev => ({
        ...prev,
        sides: prev.sides.map(s => s.dish_sequence === ctx.sideSeq ? { ...pendingRecipe, dish_sequence: ctx.sideSeq } : s)
      }));
    }
    setPendingRecipe(null);
    setPanel('edit');
  };

  const handleDeleteMain = (idx) => {
    setLocalMeal(prev => ({ ...prev, mains: prev.mains.filter((_, i) => i !== idx) }));
  };

  const handleDeleteSide = (seq) => {
    setLocalMeal(prev => ({
      ...prev,
      sides: prev.sides.filter(s => s.dish_sequence !== seq)
    }));
  };

  const handleSave = () => {
    if (skipped) {
      onSave({ mains: [], main: null, sides: [], event_id: localMeal.event_id });
    } else {
      // Pass both mains array and main (first item) for backward compat
      onSave({ ...localMeal, main: localMeal.mains[0] || null });
    }
  };

  // ── PANEL ROUTING ──
  if (panel === 'search') {
    return (
      <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(0,0,0,0.4)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "flex-start" }}>
        <div style={{ width: "100%", maxWidth: 430, height: "100%", minHeight: 0, background: "#FFF9F2", display: "flex", flexDirection: "column", overflow: "hidden" }}>
        <SearchPanel
          context={searchContext.mode}
          onBack={() => { setPanel('edit'); setDuplicateWarning(null); }}
          onSelect={handleSearchSelect}
          duplicateWarning={duplicateWarning}
          onClearWarning={() => setDuplicateWarning(null)}
        />
        </div>
      </div>
    );
  }

  if (panel === 'reason') {
    return (
      <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(0,0,0,0.4)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "flex-start" }}>
        <div style={{ width: "100%", maxWidth: 430, height: "100%", minHeight: 0, background: "#FFF9F2", display: "flex", flexDirection: "column", overflow: "hidden" }}>
        <ReasonPanel
          recipe={pendingRecipe}
          onBack={() => setPanel('search')}
          onConfirm={handleReasonConfirm}
        />
        </div>
      </div>
    );
  }

  if (panel === 'detail') {
    return (
      <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(0,0,0,0.4)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "flex-start" }}>
        <div style={{ width: "100%", maxWidth: 430, height: "100%", minHeight: 0, background: "#FFF9F2", display: "flex", flexDirection: "column", overflow: "hidden" }}>
        <DishDetailErrorBoundary onBack={() => setPanel('edit')}>
          <DishDetailPanel
            recipe={detailRecipe}
            onBack={() => setPanel('edit')}
            onSelect={null}
          />
        </DishDetailErrorBoundary>
        </div>
      </div>
    );
  }

  // ── EDIT PANEL (default) ──
  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(0,0,0,0.4)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "flex-start" }}>
      <div style={{ width: "100%", maxWidth: 430, height: "100%", minHeight: 0, background: "#FFF9F2", display: "flex", flexDirection: "column", overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "48px 16px 14px", display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
        <div>
          <div style={{ fontSize: 9, color: "#5DCAA5", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.06em" }}>{day} · {type}</div>
          <div style={{ fontSize: 16, fontWeight: 500, color: "#FDFCF8", marginTop: 2 }}>Edit meal slot</div>
        </div>
        <button onClick={onClose} style={{ width: 28, height: 28, borderRadius: "50%", border: "0.5px solid #5DCAA5", background: "none", color: "#9FE1CB", fontSize: 14, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>✕</button>
      </div>

      <div style={{ flex: 1, overflowY: "auto", minHeight: 0 }}>
        {/* Main dishes */}
        <div style={{ padding: "14px 16px", borderBottom: "0.5px solid #EDE8E0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
            <div style={{ fontSize: 9, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em" }}>Main dishes</div>
            {localMeal.mains.length < 3 && (
              <button onClick={() => openSearch('add-main')} style={{ fontSize: 11, color: "#0F6E56", fontWeight: 500, background: "none", border: "none", cursor: "pointer", padding: 0 }}>+ Add main</button>
            )}
          </div>
          {localMeal.mains.length === 0 && (
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", background: "#F1EFE8", borderRadius: 10, padding: "12px 14px" }}>
              <span style={{ fontSize: 12, color: "#B4B2A9" }}>No main dish set</span>
              <button onClick={() => openSearch('add-main')} style={{ fontSize: 11, color: "#0F6E56", border: "0.5px solid #0F6E56", borderRadius: 6, padding: "4px 10px", background: "none", cursor: "pointer" }}>+ Add main</button>
            </div>
          )}
          {localMeal.mains.map((dish, idx) => (
            <div key={idx} style={{ display: "flex", alignItems: "center", gap: 10, background: "#F1EFE8", borderRadius: 10, padding: 10, marginBottom: 6 }}>
              <div style={{ width: 52, height: 52, borderRadius: 8, background: "#EDE8E0", flexShrink: 0, overflow: "hidden" }}>
                {(dish.thumb || dish.hero) && (
                  <img src={dish.thumb || dish.hero} alt={dish.name}
                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                    onError={e => { e.target.style.display = "none"; }} />
                )}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 500, color: "#2C2C2A", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{dish.name}</div>
                <div style={{ marginTop: 3 }}><DietBadge dietType={dish.diet_type} isSattvic={dish.is_sattvic} /></div>
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: 5, alignItems: "flex-end", flexShrink: 0 }}>
                <button onClick={() => openSearch('replace-main', null, idx)} style={{ fontSize: 10, color: "#0F6E56", border: "0.5px solid #0F6E56", borderRadius: 6, padding: "3px 8px", background: "none", cursor: "pointer" }}>Replace</button>
                <div style={{ display: "flex", gap: 4 }}>
                  <button onClick={() => { setDetailRecipe(dish); setPanel('detail'); }} style={{ width: 18, height: 18, borderRadius: "50%", border: "0.5px solid #B4B2A9", background: "none", fontSize: 9, color: "#888780", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", padding: 0 }}>?</button>
                  {localMeal.mains.length > 1 && (
                    <button onClick={() => handleDeleteMain(idx)} style={{ fontSize: 10, color: "#993C1D", border: "0.5px solid #993C1D", borderRadius: 6, padding: "2px 6px", background: "none", cursor: "pointer" }}>✕</button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Side dishes */}
        <div style={{ padding: "14px 16px", borderBottom: "0.5px solid #EDE8E0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
            <div style={{ fontSize: 9, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em" }}>Side dishes</div>
            <button onClick={() => openSearch('add-side')} style={{ fontSize: 11, color: "#0F6E56", fontWeight: 500, background: "none", border: "none", cursor: "pointer", padding: 0 }}>+ Add side</button>
          </div>

          {localMeal.sides.length === 0 && (
            <div style={{ fontSize: 12, color: "#B4B2A9", textAlign: "center", padding: "10px 0" }}>No side dishes — tap + Add side</div>
          )}

          {localMeal.sides.map((side, idx) => (
            <div key={idx} style={{ display: "flex", alignItems: "center", gap: 8, background: "#F1EFE8", borderRadius: 10, padding: 8, marginBottom: 6 }}>
              <div style={{ width: 38, height: 38, borderRadius: 6, background: "#EDE8E0", flexShrink: 0, overflow: "hidden" }}>
                {(side.thumb || side.hero) && (
                  <img src={side.thumb || side.hero} alt={side.name}
                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                    onError={e => { e.target.style.display = "none"; }} />
                )}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{side.name || side.dish_name}</div>
                <div style={{ fontSize: 10, color: "#888780" }}>Side · {idx + 2}</div>
              </div>
              <div style={{ display: "flex", gap: 5, alignItems: "center", flexShrink: 0 }}>
                <button onClick={() => { setDetailRecipe(side); setPanel('detail'); }} style={{ width: 18, height: 18, borderRadius: "50%", border: "0.5px solid #B4B2A9", background: "none", fontSize: 9, color: "#888780", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", padding: 0 }}>?</button>
                <button onClick={() => openSearch('replace-side', side.dish_sequence)} style={{ fontSize: 10, color: "#0F6E56", border: "0.5px solid #0F6E56", borderRadius: 6, padding: "2px 7px", background: "none", cursor: "pointer" }}>Replace</button>
                <button onClick={() => handleDeleteSide(side.dish_sequence)} style={{ fontSize: 10, color: "#993C1D", border: "0.5px solid #993C1D", borderRadius: 6, padding: "2px 7px", background: "none", cursor: "pointer" }}>✕</button>
              </div>
            </div>
          ))}
        </div>

        {/* Skip meal */}
        <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 500, color: "#2C2C2A" }}>Skip this meal</div>
            <div style={{ fontSize: 10, color: "#B4B2A9" }}>Remove all dishes for this slot</div>
          </div>
          <button onClick={() => setSkipped(!skipped)} style={{ background: "none", border: "none", cursor: "pointer", padding: 0 }}>
            <div style={{ width: 36, height: 20, borderRadius: 10, background: skipped ? "#1A3A2E" : "#B4B2A9", position: "relative", transition: "background 0.2s" }}>
              <div style={{ width: 16, height: 16, borderRadius: "50%", background: "white", position: "absolute", top: 2, left: skipped ? 18 : 2, transition: "left 0.2s" }} />
            </div>
          </button>
        </div>
      </div>

      {/* Save button */}
      <div style={{ padding: "14px 16px", paddingBottom: 28, background: "#FFF9F2", borderTop: "0.5px solid #EDE8E0", flexShrink: 0 }}>
        <button onClick={handleSave} disabled={saving}
          style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: 14, fontSize: 14, fontWeight: 500, cursor: "pointer", opacity: saving ? 0.6 : 1 }}>
          {saving ? "Saving..." : "Save changes"}
        </button>
      </div>
      </div>
    </div>
  );
}
