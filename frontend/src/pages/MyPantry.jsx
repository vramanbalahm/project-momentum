import { useState, useEffect, useMemo } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";

const C = {
  green:    "#1A3A2E",
  mint:     "#9FE1CB",
  teal:     "#5DCAA5",
  deepTeal: "#0F6E56",
  midTeal:  "#1D9E75",
  text:     "#2C2C2A",
  muted:    "#888780",
  border:   "#EDE8E0",
  card:     "#FFF9F2",
  bg:       "#F7F4EE",
  selected: "#E1F5EE",
  selBorder:"#5DCAA5",
};

export default function MyPantry({ onBack }) {
  const { apiFetch } = useAuth();
  const { t } = useTranslation();

  const [categories, setCategories]     = useState([]);
  const [activeKey, setActiveKey]       = useState(null);
  const [changes, setChanges]           = useState({}); // { ingredient_id: is_available }
  const [loading, setLoading]           = useState(true);
  const [saving, setSaving]             = useState(false);
  const [error, setError]               = useState(null);
  const [success, setSuccess]           = useState(false);
  const [search, setSearch]             = useState("");

  useEffect(() => {
    (async () => {
      try {
        const data = await apiFetch("/pantry/ingredients");
        setCategories(data.categories || []);
        if (data.categories?.length > 0) {
          setActiveKey(data.categories[0].key);
        }
      } catch (e) {
        setError(e.message || "Failed to load pantry.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // Active category with changes applied
  const activeCategory = useMemo(() => {
    const cat = categories.find(c => c.key === activeKey);
    if (!cat) return null;
    return {
      ...cat,
      ingredients: cat.ingredients.map(ing => ({
        ...ing,
        is_available: changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available,
      }))
    };
  }, [categories, activeKey, changes]);

  // Global search across ALL categories
  const isSearching = search.trim().length > 0;
  const globalSearchResults = useMemo(() => {
    const q = search.toLowerCase().trim();
    if (!q) return [];
    const results = [];
    categories.forEach(cat => {
      cat.ingredients.forEach(ing => {
        const avail = changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available;
        if (
          ing.name_en.toLowerCase().includes(q) ||
          (ing.name_ta && ing.name_ta.includes(q))
        ) {
          results.push({ ...ing, is_available: avail, categoryLabel: cat.label, categoryEmoji: cat.emoji });
        }
      });
    });
    return results;
  }, [categories, changes, search]);

  // Filtered ingredients for active category (when not searching)
  const filteredIngredients = useMemo(() => {
    if (!activeCategory) return [];
    return activeCategory.ingredients;
  }, [activeCategory]);

  // Get selected count for a category (including changes)
  const getSelectedCount = (cat) => {
    return cat.ingredients.filter(ing =>
      changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available
    ).length;
  };

  // Toggle ingredient
  const toggle = (ingredientId, current) => {
    setChanges(prev => ({ ...prev, [ingredientId]: !current }));
  };

  // Select all in active category
  const selectAll = () => {
    if (!activeCategory) return;
    const newChanges = {};
    activeCategory.ingredients.forEach(ing => { newChanges[ing.id] = true; });
    setChanges(prev => ({ ...prev, ...newChanges }));
  };

  // Clear all in active category
  const clearAll = () => {
    if (!activeCategory) return;
    const newChanges = {};
    activeCategory.ingredients.forEach(ing => { newChanges[ing.id] = false; });
    setChanges(prev => ({ ...prev, ...newChanges }));
  };

  // Total selected across all categories
  const totalSelected = useMemo(() => {
    let count = 0;
    categories.forEach(cat => {
      cat.ingredients.forEach(ing => {
        const avail = changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available;
        if (avail) count++;
      });
    });
    return count;
  }, [categories, changes]);

  // Save
  const handleSave = async () => {
    if (Object.keys(changes).length === 0) {
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
      return;
    }
    setSaving(true);
    setError(null);
    try {
      const items = Object.entries(changes).map(([id, avail]) => ({
        ingredient_id: parseInt(id),
        is_available: avail,
      }));
      await apiFetch("/pantry/save", {
        method: "POST",
        body: JSON.stringify({ items }),
      });
      // Update local state to reflect saved changes
      setCategories(prev => prev.map(cat => ({
        ...cat,
        ingredients: cat.ingredients.map(ing => ({
          ...ing,
          is_available: changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available,
        }))
      })));
      setChanges({});
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (e) {
      setError(e.message || "Failed to save pantry.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif" }}>
        <div style={{ color: C.mint, fontSize: 14 }}>Loading your pantry...</div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", flexDirection: "column", alignItems: "center", fontFamily: "system-ui, sans-serif" }}>
      <div style={{ width: "100%", maxWidth: 430, flex: 1, display: "flex", flexDirection: "column", background: C.card, position: "relative" }}>

      {/* ── Header ── */}
      <div style={{ background: "#1A3A2E", padding: "48px 16px 12px", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
          <span onClick={onBack} style={{ color: C.mint, fontSize: 12, cursor: "pointer" }}>← Dashboard</span>
          <span style={{ color: "#FDFCF8", fontSize: 15, fontWeight: 500 }}>My Pantry</span>
          <span style={{ color: C.mint, fontSize: 11, background: "rgba(159,225,203,0.15)", padding: "3px 8px", borderRadius: 10 }}>
            {totalSelected} items
          </span>
        </div>

        {/* Search */}
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 10, padding: "8px 12px", display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ color: C.mint, fontSize: 14 }}>🔍</span>
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search — e.g. poosinikai, onion, தக்காளி..."
            style={{ background: "transparent", border: "none", outline: "none", color: "#FDFCF8", fontSize: 13, width: "100%" }}
          />
          {search && <span onClick={() => setSearch("")} style={{ color: C.mint, cursor: "pointer", fontSize: 16 }}>✕</span>}
        </div>
      </div>

      {/* ── Notifications ── */}
      {error && (
        <div style={{ margin: "0 16px 8px", background: "#FAECE7", borderRadius: 8, padding: "8px 12px", fontSize: 12, color: "#712B13" }}>
          {error} <span onClick={() => setError(null)} style={{ float: "right", cursor: "pointer" }}>✕</span>
        </div>
      )}
      {success && (
        <div style={{ margin: "0 16px 8px", background: C.selected, borderRadius: 8, padding: "8px 12px", fontSize: 12, color: C.deepTeal }}>
          Pantry saved ✓
        </div>
      )}

      {/* ── Body: sidebar + grid ── */}
      <div style={{ flex: 1, display: "flex", background: C.card, overflow: "hidden", minHeight: 0 }}>

        {/* Sidebar */}
        <div style={{ width: 72, background: "#F1EFE8", borderRight: `0.5px solid ${C.border}`, overflowY: "auto", flexShrink: 0 }}>
          {categories.map(cat => {
            const selCount = getSelectedCount(cat);
            const isActive = cat.key === activeKey;
            return (
              <div
                key={cat.key}
                onClick={() => { setActiveKey(cat.key); setSearch(""); }}
                style={{
                  padding: "10px 6px", textAlign: "center", cursor: "pointer",
                  borderBottom: `0.5px solid ${C.border}`,
                  background: isActive ? C.green : "transparent",
                  borderRight: isActive ? `2px solid ${C.teal}` : "none",
                }}
              >
                <div style={{ fontSize: 22 }}>{cat.emoji}</div>
                <div style={{ fontSize: 9, color: isActive ? C.mint : C.muted, marginTop: 3, fontWeight: 500, lineHeight: 1.2 }}>
                  {cat.label.split(" ")[0]}
                </div>
                <div style={{ fontSize: 9, color: selCount > 0 ? (isActive ? C.teal : C.deepTeal) : (isActive ? "rgba(159,225,203,0.5)" : C.muted) }}>
                  {selCount > 0 ? `${selCount}✓` : "0"}
                </div>
              </div>
            );
          })}
        </div>

        {/* Ingredient grid */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>

          {activeCategory && (
            <>
              {/* Category header */}
              <div style={{ padding: "10px 12px 8px", borderBottom: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
                <div>
                  <span style={{ fontSize: 12, fontWeight: 500, color: C.text }}>{activeCategory.label}</span>
                  <span style={{ fontSize: 11, color: C.muted, marginLeft: 6 }}>
                    {getSelectedCount(activeCategory)} / {activeCategory.total}
                  </span>
                </div>
                <div style={{ display: "flex", gap: 8 }}>
                  <span onClick={selectAll} style={{ fontSize: 11, color: C.deepTeal, cursor: "pointer" }}>All</span>
                  <span style={{ fontSize: 11, color: C.border }}>|</span>
                  <span onClick={clearAll} style={{ fontSize: 11, color: "#E24B4A", cursor: "pointer" }}>Clear</span>
                </div>
              </div>

              {/* Grid */}
              <div style={{ flex: 1, overflowY: "auto", padding: "10px" }}>
                {isSearching ? (
                  globalSearchResults.length === 0 ? (
                    <div style={{ textAlign: "center", padding: "40px 0", color: C.muted, fontSize: 13 }}>No ingredients found</div>
                  ) : (
                    <>
                      <div style={{ fontSize: 11, color: C.muted, marginBottom: 8 }}>{globalSearchResults.length} result{globalSearchResults.length !== 1 ? "s" : ""} across all categories</div>
                      <div style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0,1fr))", gap: 8 }}>
                        {globalSearchResults.map(ing => {
                          const avail = ing.is_available;
                          return (
                            <div key={ing.id} onClick={() => toggle(ing.id, avail)}
                              style={{ background: avail ? C.selected : C.bg, border: `${avail ? "1.5px" : "0.5px"} solid ${avail ? C.selBorder : C.border}`, borderRadius: 10, overflow: "hidden", cursor: "pointer", position: "relative" }}
                            >
                              <div style={{ height: 64, background: avail ? "#d0ede4" : "#EEEBE4", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 32 }}>{ing.emoji}</div>
                              <div style={{ padding: "6px 8px" }}>
                                <div style={{ fontSize: 11, fontWeight: 500, color: avail ? C.deepTeal : C.text }}>{ing.name_en}</div>
                                {ing.name_ta && <div style={{ fontSize: 9, color: avail ? C.midTeal : C.muted }}>{ing.name_ta}</div>}
                                <div style={{ fontSize: 9, color: C.muted, marginTop: 2 }}>{ing.categoryEmoji} {ing.categoryLabel}</div>
                              </div>
                              {avail && <div style={{ position: "absolute", top: 4, right: 4, background: C.deepTeal, color: "white", borderRadius: "50%", width: 16, height: 16, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9 }}>✓</div>}
                            </div>
                          );
                        })}
                      </div>
                    </>
                  )
                ) : (
                  filteredIngredients.length === 0 ? (
                    <div style={{ textAlign: "center", padding: "40px 0", color: C.muted, fontSize: 13 }}>No ingredients found</div>
                  ) : (
                    <div style={{ display: "grid", gridTemplateColumns: "repeat(2, minmax(0,1fr))", gap: 8 }}>
                      {filteredIngredients.map(ing => {
                        const avail = changes[ing.id] !== undefined ? changes[ing.id] : ing.is_available;
                        return (
                          <div key={ing.id} onClick={() => toggle(ing.id, avail)}
                            style={{ background: avail ? C.selected : C.bg, border: `${avail ? "1.5px" : "0.5px"} solid ${avail ? C.selBorder : C.border}`, borderRadius: 10, overflow: "hidden", cursor: "pointer", position: "relative" }}
                          >
                            <div style={{ height: 64, background: avail ? "#d0ede4" : "#EEEBE4", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 32 }}>{ing.emoji}</div>
                            <div style={{ padding: "6px 8px" }}>
                              <div style={{ fontSize: 11, fontWeight: 500, color: avail ? C.deepTeal : C.text }}>{ing.name_en}</div>
                              {ing.name_ta && <div style={{ fontSize: 9, color: avail ? C.midTeal : C.muted }}>{ing.name_ta}</div>}
                            </div>
                            {avail && <div style={{ position: "absolute", top: 4, right: 4, background: C.deepTeal, color: "white", borderRadius: "50%", width: 16, height: 16, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9 }}>✓</div>}
                          </div>
                        );
                      })}
                    </div>
                  )
                )}
              </div>
            </>
          )}
        </div>
      </div>

      {/* ── Save button ── */}
      <div style={{ padding: "12px 16px", background: C.card, borderTop: `0.5px solid ${C.border}`, flexShrink: 0 }}>
        <button
          onClick={handleSave}
          disabled={saving}
          style={{
            width: "100%", background: C.green, color: C.mint,
            border: "none", borderRadius: 12, padding: 13,
            fontSize: 14, fontWeight: 500,
            cursor: saving ? "not-allowed" : "pointer",
            opacity: saving ? 0.7 : 1
          }}
        >
          {saving ? "Saving..." : `Save pantry${Object.keys(changes).length > 0 ? ` — ${Object.keys(changes).length} change${Object.keys(changes).length > 1 ? "s" : ""}` : ""}`}
        </button>
      </div>
      </div>
    </div>
  );
}
