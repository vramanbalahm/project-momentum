import React, { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
  errorBg: "#FAECE7", errorText: "#712B13",
  successBg: "#E1F5EE", successText: "#085041",
};

// Small dish search box used by the manual merge tool -- searches across
// ALL review statuses (via /recipes/review, the same endpoint the
// reviewer queue uses) since duplicates often involve under_review
// dishes that /recipes/search would never surface (it only shows
// approved ones).
// Merge duplicate dishes -- two independent trigram-powered search boxes
// (same /recipes/review search already proven working in the reviewer
// queue), not automatic detection. Automatic clustering (union-find over
// trigram similarity) was tried and removed after testing confirmed no
// threshold reliably separates real duplicates from genuinely different
// Tamil dishes sharing common "template" wording (curry, kootu, kuzhambu,
// poriyal, etc.) -- e.g. two different-legume Kadala curries scored
// HIGHER similarity than a real Sambar duplicate worded differently. Per
// Vijey: search-and-select on both sides, judgment stays with the admin.
function MergeDishesTool({ apiFetch, onDone }) {
  const [leftQuery, setLeftQuery] = useState("");
  const [leftResults, setLeftResults] = useState([]);
  const [leftSearching, setLeftSearching] = useState(false);
  const [leftStatus, setLeftStatus] = useState("under_review"); // 'under_review' | 'approved' | 'all' -- defaults here since the left side auto-loads all under-review dishes on open
  const [selectedDuplicates, setSelectedDuplicates] = useState([]); // accumulates across searches

  const [rightQuery, setRightQuery] = useState("");
  const [rightResults, setRightResults] = useState([]);
  const [rightSearching, setRightSearching] = useState(false);
  const [rightStatus, setRightStatus] = useState("all");
  const [targetDish, setTargetDish] = useState(null);

  const [confirming, setConfirming] = useState(false);
  const [merging, setMerging] = useState(false);
  const [progress, setProgress] = useState(null);

  const runSearch = async (q, status, setResults, setSearching) => {
    if (q.trim().length < 2) { setResults([]); return; }
    setSearching(true);
    try {
      const res = await apiFetch(`/recipes/review?q=${encodeURIComponent(q)}&status=${status}&page_size=15`);
      let recipes = res.recipes || [];
      // When showing both statuses together, surface under_review first --
      // that's the newer, unvetted content most likely to need attention.
      if (status === "all") {
        recipes = [...recipes].sort((a, b) => {
          const aFirst = a.review_status === "under_review" ? 0 : 1;
          const bFirst = b.review_status === "under_review" ? 0 : 1;
          return aFirst - bFirst;
        });
      }
      setResults(recipes);
    } catch {
      setResults([]);
    } finally {
      setSearching(false);
    }
  };

  // No search text -- just list everything for a given status. Used to
  // auto-load the left side on open (per Vijey: browsing the full
  // under-review list beats having to search the review screen
  // separately just to see what's pending).
  const browse = async (status, setResults, setSearching) => {
    setSearching(true);
    try {
      const res = await apiFetch(`/recipes/review?status=${status}&page_size=200`);
      setResults(res.recipes || []);
    } catch {
      setResults([]);
    } finally {
      setSearching(false);
    }
  };

  const searchLeft = (q) => {
    setLeftQuery(q);
    if (q.trim().length === 0) browse(leftStatus, setLeftResults, setLeftSearching);
    else runSearch(q, leftStatus, setLeftResults, setLeftSearching);
  };
  const searchRight = (q) => { setRightQuery(q); runSearch(q, rightStatus, setRightResults, setRightSearching); };

  // Left side auto-loads under_review on open. Right side stays empty
  // until the admin actually searches, per Vijey.
  useEffect(() => { browse(leftStatus, setLeftResults, setLeftSearching); }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Re-run when the status filter changes: browse (left, no query typed)
  // or search (either side, with query text) -- right side does nothing
  // if nothing's been typed yet.
  const changeLeftStatus = (status) => {
    setLeftStatus(status);
    if (leftQuery.trim().length === 0) browse(status, setLeftResults, setLeftSearching);
    else runSearch(leftQuery, status, setLeftResults, setLeftSearching);
  };
  const changeRightStatus = (status) => {
    setRightStatus(status);
    if (rightQuery.trim().length >= 2) runSearch(rightQuery, status, setRightResults, setRightSearching);
  };

  const STATUS_OPTIONS = [
    { value: "under_review", label: "Under review" },
    { value: "approved", label: "Approved" },
    { value: "all", label: "All" },
  ];

  const StatusFilter = ({ value, onChange }) => (
    <div style={{ display: "flex", gap: 10, marginBottom: 6 }}>
      {STATUS_OPTIONS.map(opt => (
        <div key={opt.value} onClick={() => onChange(opt.value)} style={{ display: "flex", alignItems: "center", gap: 4, cursor: "pointer" }}>
          <div style={{
            width: 11, height: 11, borderRadius: "50%", flexShrink: 0,
            border: `1.5px solid ${value === opt.value ? C.teal : C.border}`,
            background: value === opt.value ? C.teal : "transparent",
          }} />
          <div style={{ fontSize: 10, color: C.muted }}>{opt.label}</div>
        </div>
      ))}
    </div>
  );

  const isSelected = (id) => selectedDuplicates.some(d => d.recipe_id === id);
  const toggleDuplicate = (dish) => {
    setSelectedDuplicates(prev =>
      prev.some(d => d.recipe_id === dish.recipe_id)
        ? prev.filter(d => d.recipe_id !== dish.recipe_id)
        : [...prev, dish]
    );
  };
  const removeDuplicate = (id) => setSelectedDuplicates(prev => prev.filter(d => d.recipe_id !== id));

  const canMerge = selectedDuplicates.length > 0 && targetDish
    && !selectedDuplicates.some(d => d.recipe_id === targetDish.recipe_id);

  const doMerge = async () => {
    setMerging(true);
    let done = 0, failed = 0;
    for (const dup of selectedDuplicates) {
      setProgress(`Merging ${done + failed + 1} / ${selectedDuplicates.length}…`);
      try {
        await apiFetch("/auth/admin/merge-dishes", {
          method: "POST",
          body: JSON.stringify({ keeper_recipe_id: targetDish.recipe_id, duplicate_recipe_id: dup.recipe_id })
        });
        done++;
      } catch {
        failed++;
      }
    }
    setProgress(null);
    setMerging(false);
    setConfirming(false);
    onDone(`Merged ${done} dish(es) into "${targetDish.dish_name}"${failed ? `, ${failed} failed` : ""}.`, null);
    setSelectedDuplicates([]);
    setTargetDish(null);

    // Refresh the left side -- it was never re-fetched after merging,
    // so it kept showing the just-deleted duplicates as if they were
    // still there (confirmed real bug: Vijey merged 'Banana Chips'
    // duplicates and still saw them listed afterward).
    if (leftQuery.trim().length === 0) browse(leftStatus, setLeftResults, setLeftSearching);
    else runSearch(leftQuery, leftStatus, setLeftResults, setLeftSearching);
  };

  return (
    <div style={{ background: C.card, borderRadius: 12, border: `0.5px solid ${C.border}`, padding: "12px 14px" }}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
        <div style={{ fontSize: 24, flexShrink: 0 }}>🔀</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>Merge duplicate dishes</div>
          <div style={{ fontSize: 11, color: C.muted, marginTop: 2, lineHeight: 1.4, marginBottom: 10 }}>
            Search and check off any dishes on the left that are duplicates. Search and pick the one dish on the right to merge them into.
          </div>

          <div style={{ display: "flex", gap: 10 }}>
            {/* LEFT: duplicates, multi-select, accumulates across searches */}
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, fontWeight: 600, color: C.muted, marginBottom: 6 }}>Duplicates to merge</div>
              <StatusFilter value={leftStatus} onChange={changeLeftStatus} />
              <input
                placeholder="Search…"
                value={leftQuery}
                onChange={e => searchLeft(e.target.value)}
                style={{ width: "100%", padding: "7px 10px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 12, boxSizing: "border-box", marginBottom: 6 }}
              />
              {leftSearching && <div style={{ fontSize: 11, color: C.muted }}>Searching…</div>}
              {!leftSearching && (leftQuery.trim().length >= 2 || leftResults.length > 0) && (
                <>
                  {leftQuery.trim().length === 0 && (
                    <div style={{ fontSize: 10, color: C.muted, marginBottom: 4 }}>Showing all {leftResults.length} {STATUS_OPTIONS.find(o => o.value === leftStatus)?.label.toLowerCase()}:</div>
                  )}
                  <div style={{ border: `0.5px solid ${C.border}`, borderRadius: 8, maxHeight: 130, overflowY: "auto", marginBottom: 8 }}>
                    {leftResults.length === 0 && <div style={{ padding: 8, fontSize: 11, color: C.muted }}>Nothing here</div>}
                    {leftResults.map(r => (
                      <div key={r.recipe_id} onClick={() => toggleDuplicate(r)}
                        style={{ display: "flex", alignItems: "center", gap: 6, padding: "6px 8px", cursor: "pointer", borderBottom: `0.5px solid ${C.border}` }}>
                        <div style={{
                          width: 14, height: 14, borderRadius: 3, flexShrink: 0,
                          border: `1.5px solid ${isSelected(r.recipe_id) ? C.teal : C.border}`,
                          background: isSelected(r.recipe_id) ? C.teal : "transparent",
                          display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9, color: "white"
                        }}>{isSelected(r.recipe_id) ? "✓" : ""}</div>
                        <div style={{ fontSize: 11, color: C.text }}>{r.dish_name} <span style={{ color: C.muted, fontSize: 9 }}>({r.review_status})</span></div>
                      </div>
                    ))}
                  </div>
                </>
              )}

              {selectedDuplicates.length > 0 && (
                <div>
                  <div style={{ fontSize: 10, color: C.muted, marginBottom: 4 }}>{selectedDuplicates.length} selected:</div>
                  {selectedDuplicates.map(d => (
                    <div key={d.recipe_id} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", background: C.successBg, borderRadius: 6, padding: "4px 8px", marginBottom: 3 }}>
                      <div style={{ fontSize: 11, color: C.text }}>{d.dish_name}</div>
                      <span onClick={() => removeDuplicate(d.recipe_id)} style={{ cursor: "pointer", color: C.muted, fontSize: 12 }}>✕</span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* RIGHT: target, single-select */}
            <div style={{ flex: 1, borderLeft: `0.5px solid ${C.border}`, paddingLeft: 10 }}>
              <div style={{ fontSize: 11, fontWeight: 600, color: C.muted, marginBottom: 6 }}>Merge into</div>
              {targetDish ? (
                <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", background: C.successBg, border: `0.5px solid ${C.mint}`, borderRadius: 8, padding: "8px 10px" }}>
                  <div style={{ fontSize: 12, color: C.text }}>{targetDish.dish_name} <span style={{ color: C.muted, fontSize: 10 }}>({targetDish.review_status})</span></div>
                  <span onClick={() => setTargetDish(null)} style={{ cursor: "pointer", color: C.muted, fontSize: 13 }}>✕</span>
                </div>
              ) : (
                <>
                  <StatusFilter value={rightStatus} onChange={changeRightStatus} />
                  <input
                    placeholder="Search…"
                    value={rightQuery}
                    onChange={e => searchRight(e.target.value)}
                    style={{ width: "100%", padding: "7px 10px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 12, boxSizing: "border-box", marginBottom: 6 }}
                  />
                  {rightSearching && <div style={{ fontSize: 11, color: C.muted }}>Searching…</div>}
                  {!rightSearching && rightQuery.trim().length >= 2 && (
                    <div style={{ border: `0.5px solid ${C.border}`, borderRadius: 8, maxHeight: 130, overflowY: "auto" }}>
                      {rightResults.length === 0 && <div style={{ padding: 8, fontSize: 11, color: C.muted }}>No matches</div>}
                      {rightResults.map(r => (
                        <div key={r.recipe_id} onClick={() => { setTargetDish(r); setRightQuery(""); setRightResults([]); }}
                          style={{ padding: "6px 8px", cursor: "pointer", borderBottom: `0.5px solid ${C.border}`, fontSize: 11, color: C.text }}>
                          {r.dish_name} <span style={{ color: C.muted, fontSize: 9 }}>({r.review_status})</span>
                        </div>
                      ))}
                    </div>
                  )}
                </>
              )}
            </div>
          </div>

          {canMerge && !confirming && (
            <button onClick={() => setConfirming(true)}
              style={{ marginTop: 10, width: "100%", background: C.green, color: C.mint, border: "none", borderRadius: 8, padding: "9px", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
              Merge {selectedDuplicates.length} into "{targetDish.dish_name}"
            </button>
          )}

          {targetDish && selectedDuplicates.some(d => d.recipe_id === targetDish.recipe_id) && (
            <div style={{ marginTop: 10, fontSize: 11, color: C.errorText, background: C.errorBg, borderRadius: 8, padding: "8px 10px" }}>
              "{targetDish.dish_name}" is both the target and checked as a duplicate on the left — uncheck it there first.
            </div>
          )}

          {confirming && (
            <div style={{ marginTop: 10, background: C.errorBg, border: "0.5px solid #F0997B", borderRadius: 10, padding: "10px 12px" }}>
              <div style={{ fontSize: 12, color: C.errorText, marginBottom: 8 }}>
                This will delete {selectedDuplicates.length} dish(es) and repoint their pairings into <strong>{targetDish.dish_name}</strong>. This can't be undone.
              </div>
              <div style={{ display: "flex", gap: 8 }}>
                <button onClick={doMerge} disabled={merging}
                  style={{ flex: 1, background: "#E24B4A", color: "white", border: "none", borderRadius: 8, padding: "7px", fontSize: 12, fontWeight: 500, cursor: merging ? "not-allowed" : "pointer" }}>
                  {merging ? (progress || "Merging…") : "Yes, merge"}
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

// AI-verified duplicate suggestions -- a separate, proactive tile from
// the manual search-based MergeDishesTool above. find_duplicate_sides_ai.py
// (run separately, not from this UI) does the actual AI-judgment work in
// the background and stores confirmed groups here; this component just
// displays and acts on what's already been found -- no live AI calls at
// review time, keeping the screen fast and responsive.
function AiDuplicateSuggestions({ apiFetch, onDone }) {
  const [suggestions, setSuggestions] = useState(null); // null = not loaded yet
  const [loading, setLoading] = useState(false);
  // One entry per suggestion: { keeperId, merging }
  const [states, setStates] = useState([]);

  const load = async () => {
    setLoading(true);
    try {
      const res = await apiFetch("/auth/admin/duplicate-suggestions");
      const sugs = res.suggestions || [];
      setSuggestions(sugs);
      setStates(sugs.map(s => {
        const approved = s.members.find(m => m.review_status === "approved");
        return { keeperId: (approved || s.members[0]).recipe_id, merging: false };
      }));
    } catch {
      setSuggestions([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const setKeeper = (i, recipeId) => setStates(s => s.map((st, idx) => idx === i ? { ...st, keeperId: recipeId } : st));
  const setMerging = (i, val) => setStates(s => s.map((st, idx) => idx === i ? { ...st, merging: val } : st));

  const mergeSuggestion = async (i) => {
    const sug = suggestions[i];
    const state = states[i];
    setMerging(i, true);
    let done = 0, failed = 0;
    for (const m of sug.members) {
      if (m.recipe_id === state.keeperId) continue;
      try {
        await apiFetch("/auth/admin/merge-dishes", {
          method: "POST",
          body: JSON.stringify({ keeper_recipe_id: state.keeperId, duplicate_recipe_id: m.recipe_id })
        });
        done++;
      } catch { failed++; }
    }
    try {
      await apiFetch(`/auth/admin/duplicate-suggestions/${sug.suggestion_id}/mark-merged`, { method: "POST" });
    } catch { /* non-fatal -- the merges themselves already succeeded */ }
    onDone(`Merged ${done} dish(es)${failed ? `, ${failed} failed` : ""}.`, null);
    setMerging(i, false);
    load(); // refresh -- this suggestion is now resolved, may reveal others
  };

  const dismissSuggestion = async (i) => {
    const sug = suggestions[i];
    try {
      await apiFetch(`/auth/admin/duplicate-suggestions/${sug.suggestion_id}/dismiss`, { method: "POST" });
      onDone(`Dismissed "${sug.canonical_name}".`, null);
      load();
    } catch (e) {
      onDone(null, e.message || "Failed to dismiss.");
    }
  };

  return (
    <div style={{ background: C.card, borderRadius: 12, border: `0.5px solid ${C.border}`, padding: "12px 14px" }}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
        <div style={{ fontSize: 24, flexShrink: 0 }}>🤖</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>AI-suggested duplicates</div>
            <span onClick={load} style={{ fontSize: 11, color: C.teal, cursor: "pointer" }}>↻ Refresh</span>
          </div>
          <div style={{ fontSize: 11, color: C.muted, marginTop: 2, lineHeight: 1.4, marginBottom: 10 }}>
            Run find_duplicate_sides_ai.py to scan for new suggestions -- shown here for you to confirm or dismiss, nothing merges automatically.
          </div>

          {loading && <div style={{ fontSize: 12, color: C.muted }}>Loading…</div>}
          {!loading && suggestions && suggestions.length === 0 && (
            <div style={{ fontSize: 12, color: C.muted }}>No pending suggestions. Run the scan script to find more.</div>
          )}

          {!loading && suggestions && suggestions.length > 0 && (
            <div style={{ display: "flex", flexDirection: "column", gap: 10, maxHeight: 420, overflowY: "auto" }}>
              {suggestions.map((sug, i) => {
                const state = states[i];
                if (!state) return null;
                return (
                  <div key={sug.suggestion_id} style={{ border: `0.5px solid ${C.border}`, borderRadius: 10, padding: "10px", background: "white" }}>
                    <div style={{ fontSize: 12, fontWeight: 600, color: C.text, marginBottom: 2 }}>{sug.canonical_name}</div>
                    {sug.reasoning && <div style={{ fontSize: 10, color: C.muted, marginBottom: 6, fontStyle: "italic" }}>{sug.reasoning}</div>}

                    <div style={{ fontSize: 10, color: C.muted, marginBottom: 4 }}>Keep:</div>
                    {sug.members.map(m => (
                      <div key={m.recipe_id} onClick={() => setKeeper(i, m.recipe_id)}
                        style={{ display: "flex", alignItems: "center", gap: 6, padding: "3px 0", cursor: "pointer" }}>
                        <div style={{
                          width: 12, height: 12, borderRadius: "50%", flexShrink: 0,
                          border: `1.5px solid ${state.keeperId === m.recipe_id ? C.teal : C.border}`,
                          background: state.keeperId === m.recipe_id ? C.teal : "transparent",
                        }} />
                        <div style={{ fontSize: 12, color: C.text }}>{m.dish_name} <span style={{ color: C.muted, fontSize: 10 }}>({m.review_status})</span></div>
                      </div>
                    ))}

                    <div style={{ display: "flex", gap: 8, marginTop: 8 }}>
                      <button onClick={() => mergeSuggestion(i)} disabled={state.merging}
                        style={{ flex: 1, background: state.merging ? "#B4B2A9" : C.green, color: C.mint, border: "none", borderRadius: 6, padding: "6px", fontSize: 11, fontWeight: 500, cursor: state.merging ? "not-allowed" : "pointer" }}>
                        {state.merging ? "Merging…" : "Merge"}
                      </button>
                      <button onClick={() => dismissSuggestion(i)} disabled={state.merging}
                        style={{ flex: 1, background: "white", color: C.text, border: `0.5px solid ${C.border}`, borderRadius: 6, padding: "6px", fontSize: 11, fontWeight: 500, cursor: "pointer" }}>
                        Dismiss
                      </button>
                    </div>
                  </div>
                );
              })}
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
  // DuplicateReview, MergeDishesTool) render as separate dedicated
  // components instead.
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
            <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>{tools.length + 2} tools available</div>
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

        <AiDuplicateSuggestions
          apiFetch={apiFetch}
          onDone={(msg, err) => { setResult(msg); setError(err); }}
        />

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
