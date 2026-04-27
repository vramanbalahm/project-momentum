import { useState, useEffect, useCallback } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5", deepTeal: "#0F6E56",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0", text: "#2C2C2A",
  muted: "#888780",
  allergy: { bg: "#FAECE7", text: "#712B13", active: "#E24B4A" },
  dislike: { bg: "#FAEEDA", text: "#633806", active: "#BA7517" },
  satvik:  { bg: "#E1F5EE", text: "#0F6E56", active: "#1D9E75" },
};

// ── Fallback ingredient image ─────────────────────────────────────────────────
const FALLBACK_IMG = "https://cdn-icons-png.flaticon.com/512/2553/2553651.png";

const IngredientThumb = ({ src, name }) => {
  const [error, setError] = useState(false);
  return (
    <img
      src={error || !src ? FALLBACK_IMG : src}
      alt={name}
      onError={() => setError(true)}
      style={{ width: 32, height: 32, borderRadius: 6, objectFit: "cover", flexShrink: 0, background: C.bg }}
    />
  );
};

// ── Main Component ────────────────────────────────────────────────────────────
/**
 * IngredientSelector — reusable ingredient selection component.
 *
 * Props:
 *   mode        "restriction" | "satvik"
 *               restriction = Allergy + Dislike toggles per ingredient
 *               satvik      = single Avoid toggle per ingredient
 *
 *   value       For restriction mode: { [ingredient_id]: { allergy: bool, dislike: bool } }
 *               For satvik mode:      { [ingredient_id]: bool }
 *
 *   onChange    Called with updated value object on any change
 *
 *   showImages  true | false (default true)
 *
 *   maxHeight   CSS value for scroll container height (default "360px")
 */
export default function IngredientSelector({
  mode = "restriction",
  value = {},
  onChange,
  showImages = true,
  maxHeight = "360px",
}) {
  const { apiFetch } = useAuth();
  const [grouped, setGrouped]   = useState({});
  const [search, setSearch]     = useState("");
  const [loading, setLoading]   = useState(true);

  // Load all ingredients grouped by category
  useEffect(() => {
    (async () => {
      try {
        const data = await apiFetch("/onboarding/satvik-ingredients");
        setGrouped(data);
      } catch (e) {
        console.error("IngredientSelector load error:", e);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // Filter by search
  const filtered = useCallback(() => {
    if (!search.trim()) return grouped;
    const q = search.toLowerCase();
    const result = {};
    Object.entries(grouped).forEach(([cat, items]) => {
      const matches = items.filter(i =>
        i.name_en.toLowerCase().includes(q) ||
        (i.name_ta || "").includes(q)
      );
      if (matches.length) result[cat] = matches;
    });
    return result;
  }, [grouped, search]);

  // ── Restriction mode helpers ───────────────────────────────────────────────
  const toggleRestriction = (id, type) => {
    const current = value[id] || { allergy: false, dislike: false };
    const updated = { ...current, [type]: !current[type] };
    // If both false, remove the key
    if (!updated.allergy && !updated.dislike) {
      const next = { ...value };
      delete next[id];
      onChange(next);
    } else {
      onChange({ ...value, [id]: updated });
    }
  };

  const enableAllRestriction = (cat, type = "allergy") => {
    const items = grouped[cat] || [];
    const next = { ...value };
    items.forEach(i => {
      const current = next[i.id] || { allergy: false, dislike: false };
      next[i.id] = { ...current, [type]: true };
    });
    onChange(next);
  };

  const disableAllRestriction = (cat) => {
    const items = grouped[cat] || [];
    const next = { ...value };
    items.forEach(i => { delete next[i.id]; });
    onChange(next);
  };

  // ── Satvik mode helpers ────────────────────────────────────────────────────
  const toggleSatvik = (id) => {
    onChange({ ...value, [id]: !value[id] });
  };

  const enableAllSatvik = (cat) => {
    const items = grouped[cat] || [];
    const next = { ...value };
    items.forEach(i => { next[i.id] = true; });
    onChange(next);
  };

  const disableAllSatvik = (cat) => {
    const items = grouped[cat] || [];
    const next = { ...value };
    items.forEach(i => { delete next[i.id]; });
    onChange(next);
  };

  if (loading) return (
    <div style={{ padding: "20px 0", textAlign: "center", fontSize: 13, color: C.muted }}>
      Loading ingredients...
    </div>
  );

  const display = filtered();

  return (
    <div>
      {/* Search bar */}
      <div style={{ display: "flex", alignItems: "center", gap: 8, background: C.bg, border: `0.5px solid ${C.border}`, borderRadius: 8, padding: "8px 10px", marginBottom: 10 }}>
        <span style={{ fontSize: 15, color: C.muted, flexShrink: 0 }}>⌕</span>
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder={mode === "satvik" ? "Search ingredients to avoid..." : "Search — e.g. peanuts, onion, wheat..."}
          style={{ border: "none", background: "transparent", fontSize: 13, color: C.text, outline: "none", flex: 1, width: "100%" }}
        />
        {search && (
          <span onClick={() => setSearch("")} style={{ fontSize: 14, color: C.muted, cursor: "pointer", flexShrink: 0 }}>✕</span>
        )}
      </div>

      {/* Selected items summary — shown at top */}
      {Object.keys(value).length > 0 && (
        <div style={{ marginBottom: 10 }}>
          <div style={{ fontSize: 11, color: "#888780", marginBottom: 6, fontWeight: 500 }}>
            {mode === "restriction" ? "Currently selected:" : "Marked to avoid:"}
          </div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
            {Object.entries(value).map(([id, flags]) => {
              // Find ingredient name
              const allItems = Object.values(grouped || {}).flat();
              const ing = allItems.find(i => String(i.id) === String(id));
              if (!ing) return null;
              if (mode === "satvik" && !flags) return null;
              if (mode === "restriction" && !flags.allergy && !flags.dislike) return null;
              return (
                <span key={id} style={{ display: "inline-flex", alignItems: "center", gap: 4, fontSize: 11, padding: "3px 8px", borderRadius: 20,
                  background: mode === "satvik" ? "#E1F5EE" :
                    (flags.allergy && flags.dislike) ? "#F5E6FA" :
                    flags.allergy ? "#FAECE7" : "#FAEEDA",
                  color: mode === "satvik" ? "#0F6E56" :
                    (flags.allergy && flags.dislike) ? "#6B2D8B" :
                    flags.allergy ? "#712B13" : "#633806"
                }}>
                  {mode === "satvik" ? "🚫" : flags.allergy && flags.dislike ? "🚫😕" : flags.allergy ? "🚫" : "😕"}
                  {" "}{ing.name_en}
                </span>
              );
            })}
          </div>
        </div>
      )}

      {/* Scrollable list */}
      <div style={{ maxHeight, overflowY: "auto" }}>
        {Object.keys(display).length === 0 && (
          <div style={{ textAlign: "center", padding: "20px 0", fontSize: 13, color: C.muted }}>
            No ingredients found for "{search}"
          </div>
        )}

        {Object.entries(display).map(([cat, items]) => (
          <div key={cat}>
            {/* Category header */}
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0 4px", position: "sticky", top: 0, background: "white", zIndex: 2 }}>
              <span style={{ fontSize: 11, fontWeight: 500, color: C.muted, textTransform: "uppercase", letterSpacing: "0.05em" }}>{cat}</span>
              <div style={{ display: "flex", gap: 8 }}>
                {mode === "restriction" && (
                  <>
                    <span onClick={() => enableAllRestriction(cat, "allergy")}
                      style={{ fontSize: 11, color: "#E24B4A", cursor: "pointer" }}>All Allergy</span>
                    <span onClick={() => enableAllRestriction(cat, "dislike")}
                      style={{ fontSize: 11, color: "#BA7517", cursor: "pointer" }}>All Dislike</span>
                    <span onClick={() => disableAllRestriction(cat)}
                      style={{ fontSize: 11, color: C.muted, cursor: "pointer" }}>Clear</span>
                  </>
                )}
                {mode === "satvik" && (
                  <>
                    <span onClick={() => enableAllSatvik(cat)}
                      style={{ fontSize: 11, color: C.deepTeal, cursor: "pointer" }}>Enable all</span>
                    <span onClick={() => disableAllSatvik(cat)}
                      style={{ fontSize: 11, color: "#E24B4A", cursor: "pointer" }}>Disable all</span>
                  </>
                )}
              </div>
            </div>

            {/* Ingredient rows */}
            <div style={{ background: C.bg, border: `0.5px solid ${C.border}`, borderRadius: 12, padding: "8px 12px", marginBottom: 8 }}>
              {items.map((item, i) => (
                <div key={item.id} style={{ display: "flex", alignItems: "center", gap: 10, padding: "9px 0", borderBottom: i < items.length - 1 ? `0.5px solid ${C.border}` : "none" }}>

                  {/* Thumbnail */}
                  {showImages && <IngredientThumb src={item.thumb_url} name={item.name_en} />}

                  {/* Name */}
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 13, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{item.name_en}</div>
                    {item.name_ta && <div style={{ fontSize: 10, color: C.muted }}>{item.name_ta}</div>}
                  </div>

                  {/* ── Restriction mode — Allergy + Dislike toggles ── */}
                  {mode === "restriction" && (
                    <div style={{ display: "flex", gap: 5, flexShrink: 0 }}>
                      <button
                        onClick={() => toggleRestriction(item.id, "allergy")}
                        style={{
                          padding: "4px 8px", borderRadius: 6, fontSize: 11, fontWeight: 500, cursor: "pointer", border: "none",
                          background: value[item.id]?.allergy ? C.allergy.active : C.bg,
                          color: value[item.id]?.allergy ? "white" : C.muted,
                          transition: "all 0.15s"
                        }}>
                        🚫 Allergy
                      </button>
                      <button
                        onClick={() => toggleRestriction(item.id, "dislike")}
                        style={{
                          padding: "4px 8px", borderRadius: 6, fontSize: 11, fontWeight: 500, cursor: "pointer", border: "none",
                          background: value[item.id]?.dislike ? C.dislike.active : C.bg,
                          color: value[item.id]?.dislike ? "white" : C.muted,
                          transition: "all 0.15s"
                        }}>
                        😕 Dislike
                      </button>
                    </div>
                  )}

                  {/* ── Satvik mode — single Avoid toggle ── */}
                  {mode === "satvik" && (
                    <div
                      onClick={() => toggleSatvik(item.id)}
                      style={{
                        width: 32, height: 18, borderRadius: 9, flexShrink: 0, cursor: "pointer", transition: "background 0.2s",
                        background: value[item.id] ? C.teal : C.border, position: "relative"
                      }}>
                      <div style={{
                        width: 14, height: 14, borderRadius: "50%", background: "white",
                        position: "absolute", top: 2, transition: "left 0.2s",
                        left: value[item.id] ? 16 : 2
                      }} />
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>


    </div>
  );
}

// ── Helper: convert DB restrictions array → component value format ────────────
export function restrictionsToValue(restrictions = []) {
  const val = {};
  restrictions.forEach(r => {
    if (!val[r.ingredient_id]) val[r.ingredient_id] = { allergy: false, dislike: false };
    if (r.restriction_type === "Allergy") val[r.ingredient_id].allergy = true;
    if (r.restriction_type === "Dislike") val[r.ingredient_id].dislike = true;
  });
  return val;
}

// ── Helper: convert component value → DB restrictions array format ─────────────
export function valueToRestrictions(value = {}) {
  const result = [];
  Object.entries(value).forEach(([id, flags]) => {
    if (flags.allergy) result.push({ ingredient_id: parseInt(id), restriction_type: "Allergy" });
    if (flags.dislike) result.push({ ingredient_id: parseInt(id), restriction_type: "Dislike" });
  });
  return result;
}

// ── Helper: convert satvik DB array → component value format ──────────────────
export function satvikToValue(satvikArray = []) {
  const val = {};
  satvikArray.forEach(s => { if (s.is_avoided) val[s.ingredient_id] = true; });
  return val;
}

// ── Helper: convert component value → satvik DB array format ──────────────────
export function valueToSatvik(value = {}) {
  return Object.entries(value)
    .filter(([, v]) => v)
    .map(([id]) => ({ ingredient_id: parseInt(id), is_avoided: true }));
}
