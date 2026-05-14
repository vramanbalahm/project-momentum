import React, { useState, useEffect, useCallback } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
  amber: "#EF9F27", amberBg: "#FFF3DC",
  errorBg: "#FAECE7", errorText: "#712B13",
  successBg: "#E1F5EE", successText: "#085041",
};

const MEAL_SLOTS   = ["Breakfast", "Lunch", "Dinner", "Side Dish"];
const DIETS        = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];
const INTENSITIES  = ["Light", "Medium", "Heavy"];
const STATUSES     = ["under_review", "saved", "approved", "rejected"];

const STATUS_LABEL = { under_review: "Pending", saved: "Saved", approved: "Approved", rejected: "Rejected" };
const STATUS_STYLE = {
  under_review: { bg: "#FAEEDA", color: "#633806" },
  saved:        { bg: "#EAF0FB", color: "#1A3A6E" },
  approved:     { bg: "#E1F5EE", color: "#085041" },
  rejected:     { bg: "#FAECE7", color: "#712B13" },
};

const DIET_COLORS = {
  Veg:        { bg: "#E1F5EE", color: "#085041" },
  "Non-Veg":  { bg: "#FAECE7", color: "#712B13" },
  Vegan:      { bg: "#EEF6E8", color: "#2A5C1A" },
  Eggitarian: { bg: "#FFF3DC", color: "#633806" },
};

function Badge({ label, style }) {
  return (
    <span style={{
      fontSize: 10, fontWeight: 500, padding: "2px 7px",
      borderRadius: 10, ...style
    }}>{label}</span>
  );
}

export default function RecipeReview({ onBack, onHelp, helpReturnRecipeId, initialTab = "under_review", filterReviewerId = null }) {
  const { user, apiFetch } = useAuth();
  const isPlatformAdmin = user?.role === "platform_admin";

  // ── List state ────────────────────────────────────────────
  const [activeTab,   setActiveTab]   = useState(initialTab);
  const [dietFilter,  setDietFilter]  = useState(null);
  const [slotFilter,  setSlotFilter]  = useState(null);
  const [recipes,     setRecipes]     = useState([]);
  const [total,       setTotal]       = useState(0);
  const [page,        setPage]        = useState(1);
  const [loading,     setLoading]     = useState(true);
  const [error,       setError]       = useState(null);
  const [selected,    setSelected]    = useState(new Set());
  const [bulkSaving,  setBulkSaving]  = useState(false);
  const [success,     setSuccess]     = useState(null);

  // ── Edit sheet state ──────────────────────────────────────
  const [editRecipe,  setEditRecipe]  = useState(null); // full detail
  const [editOpen,    setEditOpen]    = useState(false);
  const [editLoading, setEditLoading] = useState(false);
  const [editSaving,  setEditSaving]  = useState(false);
  const [genLoading,  setGenLoading]  = useState(false);

  // ── Load list ─────────────────────────────────────────────
  const loadRecipes = useCallback(async (pg = 1) => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({
        status: activeTab, page: pg, page_size: 20,
        ...(filterReviewerId ? { filter_reviewer_id: filterReviewerId } : {})
      });
      if (dietFilter) params.append("diet", dietFilter);
      if (slotFilter) params.append("meal_slot", slotFilter);
      const data = await apiFetch(`/recipes/review?${params}`);
      if (pg === 1) setRecipes(data.recipes);
      else setRecipes(prev => [...prev, ...data.recipes]);
      setTotal(data.total);
      setPage(pg);
    } catch (e) {
      setError(e.message || "Failed to load recipes.");
    } finally {
      setLoading(false);
    }
  }, [activeTab, dietFilter, slotFilter, apiFetch]);

  useEffect(() => { loadRecipes(1); }, [loadRecipes]);

  // ── Open edit sheet ───────────────────────────────────────
  const openEdit = async (recipe_id) => {
    setEditLoading(true);
    setEditOpen(true);
    try {
      const detail = await apiFetch(`/recipes/${recipe_id}/detail`);
      // Convert literal \n strings to actual newlines in prep_steps
      if (detail.prep_steps) {
        detail.prep_steps = detail.prep_steps.replace(/\\n/g, "\n");
      }
      setEditRecipe(detail);
    } catch (e) {
      setError(e.message);
      setEditOpen(false);
    } finally {
      setEditLoading(false);
    }
  };

  // ── Save edits ────────────────────────────────────────────
  const saveEdit = async (status = null) => {
    if (!editRecipe) return;
    setEditSaving(true);
    try {
      const payload = { ...editRecipe };
      if (status) payload.review_status = status;
      await apiFetch(`/recipes/${editRecipe.recipe_id}/review`, {
        method: "PUT",
        body: JSON.stringify(payload),
      });
      setSuccess(status === "approved" ? "Recipe approved! ✓" :
                 status === "rejected" ? "Recipe rejected." :
                 status === "saved"    ? "Recipe saved. ✓" :
                 "Changes saved.");
      setTimeout(() => setSuccess(null), 3000);
      setEditOpen(false);
      loadRecipes(1);
    } catch (e) {
      setError(e.message);
    } finally {
      setEditSaving(false);
    }
  };

  // ── Generate image ────────────────────────────────────────
  const generateImage = async () => {
    if (!editRecipe) return;
    const genCount = editRecipe.image_generation_count || 0;
    if (!isPlatformAdmin && genCount >= 2) {
      setError("Maximum 2 image generations reached. Contact platform admin.");
      return;
    }
    setGenLoading(true);
    try {
      const res = await apiFetch(`/recipes/${editRecipe.recipe_id}/generate-image`, {
        method: "POST"
      });
      setEditRecipe(prev => ({
        ...prev,
        hero_image_url: res.hero_image_url,
        image_generation_count: res.generation_count,
        _img_ts: Date.now(), // force image cache bust
      }));
      setSuccess("Image generated! ✓");
      setTimeout(() => setSuccess(null), 3000);
    } catch (e) {
      setError(e.message || "Image generation failed.");
    } finally {
      setGenLoading(false);
    }
  };

  // ── Mark as Pending (platform admin only) ──────────────────────
  const markPending = async (recipeId) => {
    try {
      await apiFetch(`/recipes/${recipeId}/mark-pending`, { method: "POST" });
      setSuccess("Recipe reset to Pending. ✓");
      setTimeout(() => setSuccess(null), 3000);
      setEditOpen(false);
      loadRecipes(1);
    } catch (e) {
      setError(e.message || "Failed to reset recipe.");
    }
  };

  // ── Bulk approve ──────────────────────────────────────────
  const bulkApprove = async () => {
    if (selected.size === 0) return;
    setBulkSaving(true);
    try {
      await apiFetch("/recipes/bulk-approve", {
        method: "POST",
        body: JSON.stringify({ recipe_ids: [...selected] }),
      });
      setSuccess(`${selected.size} recipes approved! ✓`);
      setTimeout(() => setSuccess(null), 3000);
      setSelected(new Set());
      loadRecipes(1);
    } catch (e) {
      setError(e.message);
    } finally {
      setBulkSaving(false);
    }
  };

  // Reopen edit sheet if returning from Help screen
  React.useEffect(() => {
    if (helpReturnRecipeId) {
      openEdit(helpReturnRecipeId);
    }
  }, []);

  const toggleSelect = (id) => {
    setSelected(prev => {
      const n = new Set(prev);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  };

  const tabCounts = { under_review: total };

  // ── Render ────────────────────────────────────────────────
  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: C.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>MOMENTUM · REVIEW</div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500, marginTop: 2 }}>Recipe Review</div>
            <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>{total} recipes · tap any to review</div>
          </div>
        </div>
      </div>

      {/* Status tabs */}
      <div style={{ display: "flex", background: C.card, borderBottom: `0.5px solid ${C.border}` }}>
        {STATUSES.map(s => (
          <div key={s} onClick={() => { setActiveTab(s); setSelected(new Set()); }}
            style={{
              flex: 1, padding: "10px 0", textAlign: "center", cursor: "pointer",
              fontSize: 12, fontWeight: 500,
              color: activeTab === s ? C.green : C.muted,
              borderBottom: activeTab === s ? `2px solid ${C.green}` : "2px solid transparent"
            }}>
            {STATUS_LABEL[s]}
          </div>
        ))}
      </div>

      {/* Diet + Slot filters */}
      <div style={{ display: "flex", gap: 6, padding: "10px 14px", overflowX: "auto", background: C.card, borderBottom: `0.5px solid ${C.border}` }}>
        {["All", ...DIETS].map(d => (
          <div key={d} onClick={() => setDietFilter(d === "All" ? null : d)}
            style={{
              flexShrink: 0, padding: "5px 10px", borderRadius: 16, fontSize: 11, fontWeight: 500,
              cursor: "pointer", border: `0.5px solid ${C.border}`,
              background: dietFilter === d || (d === "All" && !dietFilter) ? C.green : C.card,
              color: dietFilter === d || (d === "All" && !dietFilter) ? C.mint : C.muted,
            }}>{d}</div>
        ))}
        {MEAL_SLOTS.map(s => (
          <div key={s} onClick={() => setSlotFilter(slotFilter === s ? null : s)}
            style={{
              flexShrink: 0, padding: "5px 10px", borderRadius: 16, fontSize: 11, fontWeight: 500,
              cursor: "pointer", border: `0.5px solid ${C.border}`,
              background: slotFilter === s ? C.green : C.card,
              color: slotFilter === s ? C.mint : C.muted,
            }}>{s}</div>
        ))}
      </div>

      {/* Bulk approve bar */}
      {selected.size > 0 && (
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 16px", background: C.successBg, borderBottom: `0.5px solid ${C.mint}` }}>
          <span style={{ fontSize: 12, color: C.successText, fontWeight: 500 }}>{selected.size} selected</span>
          <button onClick={bulkApprove} disabled={bulkSaving}
            style={{ fontSize: 11, fontWeight: 500, padding: "5px 14px", borderRadius: 8, background: C.green, color: C.mint, border: "none", cursor: "pointer" }}>
            {bulkSaving ? "Approving…" : "Approve selected"}
          </button>
        </div>
      )}

      {/* Banners */}
      <div style={{ padding: success || error ? "10px 14px 0" : 0 }}>
        {success && <div style={{ background: C.successBg, border: `0.5px solid ${C.mint}`, borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.successText }}>{success}</div>}
        {error   && <div style={{ background: C.errorBg, border: `0.5px solid #F0997B`, borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.errorText }}>{error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span></div>}
      </div>

      {/* Recipe list */}
      <div style={{ padding: "10px 14px 100px", display: "flex", flexDirection: "column", gap: 8 }}>
        {loading && <div style={{ textAlign: "center", padding: "40px 0", color: C.muted, fontSize: 13 }}>Loading…</div>}

        {!loading && recipes.length === 0 && (
          <div style={{ textAlign: "center", padding: "48px 0", color: C.muted, fontSize: 13 }}>
            No recipes in this category.
          </div>
        )}

        {recipes.map(r => {
          const statusStyle = STATUS_STYLE[r.review_status] || STATUS_STYLE.under_review;
          const dietStyle   = DIET_COLORS[r.diet_type] || {};
          const isSelected  = selected.has(r.recipe_id);

          return (
            <div key={r.recipe_id}
              style={{
                background: C.card, borderRadius: 12,
                border: `0.5px solid ${isSelected ? C.teal : C.border}`,
                overflow: "hidden",
              }}>
              <div style={{ display: "flex", alignItems: "flex-start", padding: "12px 14px", gap: 10 }}>
                {/* Checkbox */}
                {activeTab === "under_review" && (
                  <input type="checkbox" checked={isSelected}
                    onChange={() => toggleSelect(r.recipe_id)}
                    style={{ marginTop: 2, flexShrink: 0, width: 15, height: 15 }} />
                )}

                {/* Image thumbnail */}
                {r.hero_image_url ? (
                  <img src={`${r.hero_image_url.startsWith("http") ? r.hero_image_url : (import.meta.env.VITE_API_BASE || "http://localhost:8000") + r.hero_image_url}?t=${r.image_generation_count || 0}`} alt={r.dish_name}
                    style={{ width: 52, height: 52, borderRadius: 8, objectFit: "cover", flexShrink: 0 }} />
                ) : (
                  <div style={{ width: 52, height: 52, borderRadius: 8, background: "#F0EFEC", flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20 }}>🍽</div>
                )}

                {/* Content */}
                <div style={{ flex: 1, minWidth: 0 }} onClick={() => openEdit(r.recipe_id)}>
                  <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 6 }}>
                    <div style={{ fontSize: 13, fontWeight: 500, color: C.text, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{r.dish_name}</div>
                    <Badge label={STATUS_LABEL[r.review_status]} style={statusStyle} />
                  </div>
                  {r.regional_name && r.regional_name !== r.dish_name && (
                    <div style={{ fontSize: 11, color: C.muted, marginTop: 1 }}>{r.regional_name}</div>
                  )}
                  <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginTop: 5 }}>
                    <Badge label={r.diet_type} style={dietStyle} />
                    {(r.meal_slots || []).map(s => <Badge key={s} label={s} style={{ bg: "#F0EFEC", background: "#F0EFEC", color: C.muted }} />)}
                    {r.is_sattvic && <Badge label="Satvik" style={{ background: "#E6F1FB", color: "#0C447C" }} />}
                  </div>
                  <div style={{ fontSize: 11, color: C.muted, marginTop: 4 }}>
                    {r.sub_region || "General Tamil Nadu"} · {r.intensity_level}
                    {r.image_generation_count > 0 && ` · ${r.image_generation_count}/2 img`}
                    {r.reviewed_by_name && r.review_status !== "under_review" && (
                      <span style={{ color: r.review_status === "approved" ? "#085041" : r.review_status === "saved" ? "#1A3A6E" : "#712B13" }}>
                        {` · ${r.review_status === "approved" ? "✓" : r.review_status === "saved" ? "◌" : "✗"} ${r.reviewed_by_name}`}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          );
        })}

        {/* Load more */}
        {recipes.length < total && !loading && (
          <button onClick={() => loadRecipes(page + 1)}
            style={{ width: "100%", padding: 12, borderRadius: 12, border: `0.5px solid ${C.border}`, background: C.card, color: C.muted, fontSize: 13, cursor: "pointer" }}>
            Load more ({total - recipes.length} remaining)
          </button>
        )}
      </div>

      {/* ── EDIT SHEET ── */}
      {editOpen && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 100, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
          <div style={{ width: "100%", maxWidth: 480, background: C.bg, borderRadius: "20px 20px 0 0", maxHeight: "92vh", overflowY: "auto", position: "relative" }}>

            {/* Sheet header */}
            <div style={{ background: C.green, padding: "14px 16px", borderRadius: "20px 20px 0 0", position: "sticky", top: 0, zIndex: 10 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <div style={{ color: "#FDFCF8", fontSize: 14, fontWeight: 500, flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                  {editRecipe?.dish_name || "Loading…"}
                </div>
                <div onClick={() => onHelp(editRecipe?.recipe_id)} style={{ color: C.mint, fontSize: 11, fontWeight: 500, padding: "4px 8px", borderRadius: 6, border: `0.5px solid ${C.mint}`, cursor: "pointer", flexShrink: 0 }}>
                  ? Help
                </div>
                <div onClick={() => setEditOpen(false)} style={{ color: C.mint, fontSize: 18, cursor: "pointer", flexShrink: 0 }}>✕</div>
              </div>
              {editRecipe && (
                <Badge label={STATUS_LABEL[editRecipe.review_status]}
                  style={{ ...STATUS_STYLE[editRecipe.review_status], marginTop: 6, display: "inline-block" }} />
              )}
            </div>

            {editLoading && <div style={{ textAlign: "center", padding: "40px 0", color: C.muted }}>Loading recipe…</div>}

            {editRecipe && !editLoading && (
              <div style={{ padding: "16px 16px 120px" }}>

                {/* Image section */}
                <div style={{ background: C.card, borderRadius: 12, padding: 14, marginBottom: 12, border: `0.5px solid ${C.border}` }}>
                  <div style={{ fontSize: 11, fontWeight: 600, color: C.muted, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Recipe Image</div>
                  {editRecipe.hero_image_url ? (
                    <img src={`${editRecipe.hero_image_url.startsWith("http") ? editRecipe.hero_image_url : (import.meta.env.VITE_API_BASE || "http://localhost:8000") + editRecipe.hero_image_url}?t=${editRecipe._img_ts || editRecipe.image_generation_count || 0}`} alt={editRecipe.dish_name}
                      style={{ width: "100%", height: 180, objectFit: "cover", borderRadius: 10, marginBottom: 10 }} />
                  ) : (
                    <div style={{ width: "100%", height: 120, borderRadius: 10, background: "#F0EFEC", display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 10, color: C.muted, fontSize: 13 }}>
                      No image yet
                    </div>
                  )}
                  <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                    <span style={{ fontSize: 11, color: C.muted, fontStyle: "italic" }}>
                      Image generation paused during QA
                    </span>
                    <span style={{
                      fontSize: 11, padding: "6px 12px", borderRadius: 10,
                      background: "#F0EFEC", color: C.muted
                    }}>
                      Disabled
                    </span>
                  </div>
                </div>

                {/* Basic details */}
                <EditSection title="Basic Details">
                  <EditField label="Dish name">
                    <input value={editRecipe.dish_name || ""} onChange={e => setEditRecipe(p => ({ ...p, dish_name: e.target.value }))} style={inputStyle} />
                  </EditField>
                  <EditField label="Regional name (Tamil)">
                    <input value={editRecipe.regional_name || ""} onChange={e => setEditRecipe(p => ({ ...p, regional_name: e.target.value }))} style={inputStyle} />
                  </EditField>
                  <EditField label="Sub region">
                    <input value={editRecipe.sub_region || ""} onChange={e => setEditRecipe(p => ({ ...p, sub_region: e.target.value }))} style={inputStyle} />
                  </EditField>
                </EditSection>

                {/* Classification */}
                <EditSection title="Classification">
                  <EditField label="Diet type">
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                      {DIETS.map(d => (
                        <div key={d} onClick={() => setEditRecipe(p => ({ ...p, diet_type: d }))}
                          style={{
                            padding: "6px 12px", borderRadius: 10, fontSize: 12, fontWeight: 500, cursor: "pointer",
                            background: editRecipe.diet_type === d ? C.green : "#F0EFEC",
                            color: editRecipe.diet_type === d ? C.mint : C.muted,
                          }}>{d}</div>
                      ))}
                    </div>
                  </EditField>
                  <EditField label="Meal slots">
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                      {MEAL_SLOTS.map(s => {
                        const active = (editRecipe.meal_slots || []).includes(s);
                        return (
                          <div key={s} onClick={() => {
                            const slots = editRecipe.meal_slots || [];
                            setEditRecipe(p => ({
                              ...p,
                              meal_slots: active ? slots.filter(x => x !== s) : [...slots, s]
                            }));
                          }}
                            style={{
                              padding: "6px 12px", borderRadius: 10, fontSize: 12, fontWeight: 500, cursor: "pointer",
                              background: active ? C.green : "#F0EFEC",
                              color: active ? C.mint : C.muted,
                            }}>{s}</div>
                        );
                      })}
                    </div>
                  </EditField>
                  <EditField label="Intensity">
                    <div style={{ display: "flex", gap: 6 }}>
                      {INTENSITIES.map(i => (
                        <div key={i} onClick={() => setEditRecipe(p => ({ ...p, intensity_level: i }))}
                          style={{
                            flex: 1, padding: "6px 0", borderRadius: 10, fontSize: 12, fontWeight: 500,
                            cursor: "pointer", textAlign: "center",
                            background: editRecipe.intensity_level === i ? C.green : "#F0EFEC",
                            color: editRecipe.intensity_level === i ? C.mint : C.muted,
                          }}>{i}</div>
                      ))}
                    </div>
                  </EditField>
                  <EditField label="Flags">
                    <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                      {[["is_sattvic", "Satvik"], ["is_vegan", "Vegan"], ["is_scalable", "Scalable"], ["is_regional_specific", "Regional specific"]].map(([key, label]) => (
                        <label key={key} style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 12, color: C.text, cursor: "pointer" }}>
                          <input type="checkbox" checked={!!editRecipe[key]}
                            onChange={e => setEditRecipe(p => ({ ...p, [key]: e.target.checked }))} />
                          {label}
                        </label>
                      ))}
                    </div>
                  </EditField>
                </EditSection>

                {/* Ingredients */}
                <EditSection title="Ingredients — tap to toggle optional">
                  {(editRecipe.ingredients || []).map((ing, idx) => (
                    <div key={ing.ingredient_id || idx}
                      onClick={() => {
                        const ings = [...(editRecipe.ingredients || [])];
                        ings[idx] = { ...ings[idx], is_optional: !ings[idx].is_optional };
                        setEditRecipe(p => ({ ...p, ingredients: ings }));
                      }}
                      style={{
                        display: "flex", alignItems: "center", gap: 10,
                        padding: "9px 14px",
                        borderBottom: idx < (editRecipe.ingredients.length - 1) ? `0.5px solid ${C.border}` : "none",
                        cursor: "pointer",
                      }}>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 12, color: C.text }}>{ing.name_en}</div>
                        {ing.name_ta && <div style={{ fontSize: 10, color: C.muted }}>{ing.name_ta}</div>}
                      </div>
                      <div style={{ fontSize: 11, color: C.muted, marginRight: 8 }}>{ing.quantity} {ing.unit}</div>
                      <div style={{
                        fontSize: 10, fontWeight: 500, padding: "2px 8px", borderRadius: 8, flexShrink: 0,
                        background: ing.is_optional ? C.successBg : "#F0EFEC",
                        color: ing.is_optional ? C.successText : C.muted,
                      }}>{ing.is_optional ? "Optional" : "Required"}</div>
                    </div>
                  ))}
                </EditSection>

                {/* Prep steps */}
                <EditSection title="Prep Steps">
                  <div style={{ padding: "10px 14px" }}>
                    <textarea
                      value={editRecipe.prep_steps || ""}
                      onChange={e => {
                        setEditRecipe(p => ({ ...p, prep_steps: e.target.value }));
                        e.target.style.height = "auto";
                        e.target.style.height = e.target.scrollHeight + "px";
                      }}
                      onLoad={e => { e.target.style.height = e.target.scrollHeight + "px"; }}
                      ref={el => { if (el) { el.style.height = "auto"; el.style.height = el.scrollHeight + "px"; } }}
                      style={{ ...inputStyle, resize: "none", fontFamily: "system-ui", lineHeight: 1.8, minHeight: 120, overflow: "hidden" }}
                    />
                  </div>
                </EditSection>

                {/* YouTube URLs */}
                <EditSection title="YouTube Links (up to 3)">
                  {[0, 1, 2].map(i => (
                    <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 14px", borderBottom: i < 2 ? `0.5px solid ${C.border}` : "none" }}>
                      <span style={{ fontSize: 11, color: C.muted, width: 16 }}>{i + 1}</span>
                      <input
                        value={(editRecipe.youtube_urls || [])[i] || ""}
                        onChange={e => {
                          const urls = [...(editRecipe.youtube_urls || ["", "", ""])];
                          urls[i] = e.target.value;
                          setEditRecipe(p => ({ ...p, youtube_urls: urls }));
                        }}
                        placeholder="https://youtube.com/watch?v=..."
                        style={{ ...inputStyle, fontSize: 11, marginBottom: 0 }}
                      />
                    </div>
                  ))}
                </EditSection>

                {/* Review notes */}
                <EditSection title="Review Notes">
                  <div style={{ padding: "10px 14px" }}>
                    <textarea
                      value={editRecipe.review_notes || ""}
                      onChange={e => setEditRecipe(p => ({ ...p, review_notes: e.target.value }))}
                      rows={2}
                      placeholder="Add notes for the team…"
                      style={{ ...inputStyle, resize: "none", fontFamily: "system-ui" }}
                    />
                  </div>
                </EditSection>

              </div>
            )}

            {/* Action buttons */}
            {editRecipe && !editLoading && (
              <div style={{ position: "sticky", bottom: 0, background: C.card, borderTop: `0.5px solid ${C.border}`, padding: "12px 16px" }}>
                <button onClick={() => saveEdit("saved")} disabled={editSaving}
                  style={{ width: "100%", padding: 12, borderRadius: 12, border: "none", background: "#1A3A6E", color: "#FDFCF8", fontSize: 13, fontWeight: 500, cursor: "pointer", marginBottom: 8, opacity: editSaving ? 0.7 : 1 }}>
                  {editSaving ? "Saving…" : "Save ✓"}
                </button>
                <div style={{ display: "flex", gap: 8 }}>
                  <button onClick={() => saveEdit("rejected")} disabled={editSaving}
                    style={{ flex: 1, padding: 11, borderRadius: 12, border: `0.5px solid #F0997B`, background: C.errorBg, color: C.errorText, fontSize: 13, fontWeight: 500, cursor: "pointer" }}>
                    Reject
                  </button>
                  <button onClick={() => saveEdit("approved")} disabled={editSaving}
                    style={{ flex: 2, padding: 11, borderRadius: 12, border: "none", background: C.green, color: C.mint, fontSize: 13, fontWeight: 500, cursor: "pointer" }}>
                    Approve ✓
                  </button>
                </div>
                {isPlatformAdmin && editRecipe && (
                  <button onClick={() => markPending(editRecipe.recipe_id)} disabled={editSaving}
                    style={{ width: "100%", marginTop: 8, padding: 10, borderRadius: 12, border: `0.5px solid #EDE8E0`, background: "transparent", color: "#888780", fontSize: 12, cursor: "pointer" }}>
                    ↩ Mark as Pending
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// ── Helper components ──────────────────────────────────────────────────────────

function Tooltip({ text }) {
  const [show, setShow] = React.useState(false);
  return (
    <span style={{ position: "relative", display: "inline-flex", alignItems: "center", marginLeft: 5 }}>
      <span
        onClick={e => { e.stopPropagation(); setShow(!show); }}
        style={{
          display: "inline-flex", alignItems: "center", justifyContent: "center",
          width: 14, height: 14, borderRadius: "50%", fontSize: 9, fontWeight: 700,
          background: "#E0EDE8", color: "#0F6E56", cursor: "pointer", flexShrink: 0,
          border: "0.5px solid #9FE1CB"
        }}>?</span>
      {show && (
        <span style={{
          position: "absolute", bottom: 20, left: 0, zIndex: 200,
          background: "#1A3A2E", color: "#FDFCF8", fontSize: 11,
          padding: "8px 10px", borderRadius: 8, width: 200, lineHeight: 1.5,
          boxShadow: "0 4px 12px rgba(0,0,0,0.3)"
        }}>
          {text}
          <span onClick={e => { e.stopPropagation(); setShow(false); }}
            style={{ display: "block", marginTop: 6, color: "#9FE1CB", fontSize: 10, cursor: "pointer" }}>
            Tap to close
          </span>
        </span>
      )}
    </span>
  );
}

function EditSection({ title, children, tooltip }) {
  return (
    <div style={{ background: "#FFF9F2", borderRadius: 12, overflow: "hidden", marginBottom: 12, border: "0.5px solid #EDE8E0" }}>
      <div style={{ fontSize: 10, fontWeight: 600, color: "#888780", textTransform: "uppercase", letterSpacing: "0.05em", padding: "10px 14px 6px", borderBottom: "0.5px solid #EDE8E0", display: "flex", alignItems: "center" }}>
        {title}
        {tooltip && <Tooltip text={tooltip} />}
      </div>
      {children}
    </div>
  );
}

function EditField({ label, children, tooltip }) {
  return (
    <div style={{ padding: "10px 14px", borderBottom: "0.5px solid #EDE8E0" }}>
      <div style={{ fontSize: 11, color: "#888780", marginBottom: 6, display: "flex", alignItems: "center" }}>
        {label}
        {tooltip && <Tooltip text={tooltip} />}
      </div>
      {children}
    </div>
  );
}

const inputStyle = {
  width: "100%", padding: "8px 10px", borderRadius: 8,
  border: "0.5px solid #EDE8E0", fontSize: 13,
  color: "#2C2C2A", background: "#F7F4EE",
  outline: "none", boxSizing: "border-box",
  marginBottom: 0,
};
