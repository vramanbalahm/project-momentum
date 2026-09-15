import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
  errorBg: "#FAECE7", errorText: "#712B13",
  successBg: "#E1F5EE", successText: "#085041",
};

// Small dish search box used twice by the merge tool below -- searches
// across ALL review statuses (via /recipes/review, the same endpoint the
// reviewer queue uses) since duplicates often involve under_review dishes
// that /recipes/search would never surface (it only shows approved ones).
function DishPicker({ label, selected, onSelect }) {
  const { apiFetch } = useAuth();
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [searching, setSearching] = useState(false);

  const search = async (q) => {
    setQuery(q);
    if (q.trim().length < 2) { setResults([]); return; }
    setSearching(true);
    try {
      const res = await apiFetch(`/recipes/review?q=${encodeURIComponent(q)}&status=all&page_size=8`);
      setResults(res.recipes || []);
    } catch {
      setResults([]);
    } finally {
      setSearching(false);
    }
  };

  if (selected) {
    return (
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", background: C.successBg, border: `0.5px solid ${C.mint}`, borderRadius: 10, padding: "8px 12px" }}>
        <div>
          <div style={{ fontSize: 11, color: C.muted }}>{label}</div>
          <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{selected.dish_name}</div>
        </div>
        <span onClick={() => onSelect(null)} style={{ cursor: "pointer", color: C.muted, fontSize: 14 }}>✕</span>
      </div>
    );
  }

  return (
    <div style={{ position: "relative" }}>
      <input
        placeholder={label}
        value={query}
        onChange={e => search(e.target.value)}
        style={{ width: "100%", padding: "8px 12px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, boxSizing: "border-box" }}
      />
      {(searching || results.length > 0) && query.trim().length >= 2 && (
        <div style={{ position: "absolute", top: "100%", left: 0, right: 0, background: "white", border: `0.5px solid ${C.border}`, borderRadius: 10, marginTop: 4, maxHeight: 180, overflowY: "auto", zIndex: 5, boxShadow: "0 4px 12px rgba(0,0,0,0.08)" }}>
          {searching && <div style={{ padding: 10, fontSize: 12, color: C.muted }}>Searching…</div>}
          {!searching && results.length === 0 && <div style={{ padding: 10, fontSize: 12, color: C.muted }}>No matches</div>}
          {!searching && results.map(r => (
            <div key={r.recipe_id} onClick={() => { onSelect(r); setQuery(""); setResults([]); }}
              style={{ padding: "8px 12px", fontSize: 12, cursor: "pointer", borderBottom: `0.5px solid ${C.border}` }}>
              {r.dish_name} <span style={{ color: C.muted }}>({r.review_status})</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function MergeDishesTool({ apiFetch, onDone }) {
  const [dishA, setDishA] = useState(null);
  const [dishB, setDishB] = useState(null);
  const [keeperId, setKeeperId] = useState(null);
  const [confirming, setConfirming] = useState(false);
  const [merging, setMerging] = useState(false);

  const bothSelected = dishA && dishB;
  const keeper = keeperId === dishA?.recipe_id ? dishA : keeperId === dishB?.recipe_id ? dishB : null;
  const duplicate = keeper === dishA ? dishB : keeper === dishB ? dishA : null;

  const reset = () => { setDishA(null); setDishB(null); setKeeperId(null); setConfirming(false); };

  const doMerge = async () => {
    setMerging(true);
    try {
      const res = await apiFetch("/auth/admin/merge-dishes", {
        method: "POST",
        body: JSON.stringify({ keeper_recipe_id: keeper.recipe_id, duplicate_recipe_id: duplicate.recipe_id })
      });
      onDone(res.message, null);
      reset();
    } catch (e) {
      onDone(null, e.message || "Merge failed.");
    } finally {
      setMerging(false);
    }
  };

  return (
    <div style={{ background: C.card, borderRadius: 12, border: `0.5px solid ${C.border}`, padding: "12px 14px" }}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
        <div style={{ fontSize: 24, flexShrink: 0 }}>🔀</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>Merge duplicate dishes</div>
          <div style={{ fontSize: 11, color: C.muted, marginTop: 2, lineHeight: 1.4, marginBottom: 10 }}>
            Find two dishes that are really the same thing, pick which one to keep — pairings pointing at the other get repointed automatically, then it's deleted.
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <DishPicker label="First dish" selected={dishA} onSelect={setDishA} />
            <DishPicker label="Second dish" selected={dishB} onSelect={setDishB} />
          </div>

          {bothSelected && (
            <div style={{ marginTop: 10 }}>
              <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>Which one do you want to keep?</div>
              {[dishA, dishB].map(d => (
                <div key={d.recipe_id} onClick={() => setKeeperId(d.recipe_id)}
                  style={{
                    display: "flex", alignItems: "center", gap: 8, padding: "8px 10px", borderRadius: 8, marginBottom: 6, cursor: "pointer",
                    background: keeperId === d.recipe_id ? C.successBg : "white",
                    border: `0.5px solid ${keeperId === d.recipe_id ? C.mint : C.border}`,
                  }}>
                  <div style={{ width: 16, height: 16, borderRadius: "50%", border: `1.5px solid ${keeperId === d.recipe_id ? C.teal : C.border}`, background: keeperId === d.recipe_id ? C.teal : "transparent" }} />
                  <div style={{ fontSize: 12, color: C.text }}>Keep <strong>{d.dish_name}</strong></div>
                </div>
              ))}
            </div>
          )}

          {keeper && duplicate && !confirming && (
            <button onClick={() => setConfirming(true)}
              style={{ marginTop: 6, width: "100%", background: C.green, color: C.mint, border: "none", borderRadius: 8, padding: "8px", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
              Merge
            </button>
          )}

          {confirming && (
            <div style={{ marginTop: 10, background: C.errorBg, border: "0.5px solid #F0997B", borderRadius: 10, padding: "10px 12px" }}>
              <div style={{ fontSize: 12, color: C.errorText, marginBottom: 8 }}>
                This will delete <strong>{duplicate.dish_name}</strong> and repoint its pairings to <strong>{keeper.dish_name}</strong>. This can't be undone.
              </div>
              <div style={{ display: "flex", gap: 8 }}>
                <button onClick={doMerge} disabled={merging}
                  style={{ flex: 1, background: "#E24B4A", color: "white", border: "none", borderRadius: 8, padding: "7px", fontSize: 12, fontWeight: 500, cursor: merging ? "not-allowed" : "pointer" }}>
                  {merging ? "Merging…" : "Yes, merge"}
                </button>
                <button onClick={() => setConfirming(false)} disabled={merging}
                  style={{ flex: 1, background: "white", color: C.text, border: `0.5px solid ${C.border}`, borderRadius: 8, padding: "7px", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
                  Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function PlatformAdmin({ onBack }) {
  const { apiFetch } = useAuth();
  const [runningId, setRunningId] = useState(null);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const runTool = async (tool) => {
    setRunningId(tool.id);
    setError(null);
    setResult(null);
    try {
      const res = await apiFetch(tool.endpoint, { method: "POST" });
      setResult(res.message);
    } catch (e) {
      setError(e.message || "Something went wrong.");
    } finally {
      setRunningId(null);
    }
  };

  // Add future simple (single-button) admin tools here — each renders as
  // its own list item below. Tools needing their own richer UI (like
  // MergeDishesTool) render as separate dedicated components instead.
  const tools = [
    {
      id: "backfill_holidays",
      icon: "📅",
      title: "Backfill holiday events",
      desc: "Copies this year's government-published holidays into every existing household's own events. Only affects households that don't already have them — safe to run more than once.",
      endpoint: "/auth/admin/backfill-holidays",
      actionLabel: "Run backfill",
    },
  ];

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: C.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>LADLEFUL · ADMIN</div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500, marginTop: 2 }}>Platform Admin</div>
            <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>{tools.length + 1} tools available</div>
          </div>
        </div>
      </div>

      {/* Banners */}
      <div style={{ padding: result || error ? "10px 14px 0" : 0 }}>
        {result && <div style={{ background: C.successBg, border: `0.5px solid ${C.mint}`, borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.successText }}>✅ {result}</div>}
        {error && <div style={{ background: C.errorBg, border: "0.5px solid #F0997B", borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.errorText }}>{error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span></div>}
      </div>

      {/* Tools list */}
      <div style={{ padding: "14px", display: "flex", flexDirection: "column", gap: 8 }}>
        {tools.map(tool => (
          <div key={tool.id} style={{ background: C.card, borderRadius: 12, border: `0.5px solid ${C.border}`, overflow: "hidden" }}>
            <div style={{ display: "flex", alignItems: "flex-start", padding: "12px 14px", gap: 10 }}>
              <div style={{ fontSize: 24, flexShrink: 0 }}>{tool.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>{tool.title}</div>
                <div style={{ fontSize: 11, color: C.muted, marginTop: 2, lineHeight: 1.4 }}>{tool.desc}</div>
                <button
                  onClick={() => runTool(tool)}
                  disabled={runningId === tool.id}
                  style={{
                    marginTop: 10, background: runningId === tool.id ? "#B4B2A9" : C.green, color: C.mint,
                    border: "none", borderRadius: 8, padding: "7px 14px",
                    fontSize: 12, fontWeight: 500, cursor: runningId === tool.id ? "not-allowed" : "pointer"
                  }}
                >
                  {runningId === tool.id ? "Running…" : tool.actionLabel}
                </button>
              </div>
            </div>
          </div>
        ))}

        <MergeDishesTool
          apiFetch={apiFetch}
          onDone={(msg, err) => { setResult(msg); setError(err); }}
        />

        <div style={{ fontSize: 11, color: C.muted, textAlign: "center", marginTop: 8 }}>
          More admin tools will appear here over time.
        </div>
      </div>
    </div>
  );
}
