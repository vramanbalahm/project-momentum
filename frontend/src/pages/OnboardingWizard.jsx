import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import IngredientSelector, { restrictionsToValue, valueToRestrictions } from "../components/IngredientSelector";
import SatvikEditor from "../components/SatvikEditor.jsx";
import LunarEditor from "../components/LunarEditor.jsx";
import EventEditor from "../components/EventEditor.jsx";

import { C, DIET_PREFS, AGE_GROUPS, GENDERS, DIET_IMAGES, EVENT_ICONS, Field, HelpTip, Toggle, Chip, Avatar, NavButtons } from "../components/householdShared.jsx";
import { useTranslation } from "react-i18next";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const STEP_LABEL_KEYS = ["welcome", "members", "satvik", "calendar", "events", "done"];

// ── Main Wizard ───────────────────────────────────────────────────────────────
export default function OnboardingWizard({ onComplete }) {
  const { apiFetch, user } = useAuth();
  const { t } = useTranslation();
  const STEP_LABELS = STEP_LABEL_KEYS.map(k => t(`onboarding.steps.${k}`));
  const [step, setStep]         = useState(0);
  const [data, setData]         = useState(null);
  const [loading, setLoading]   = useState(true);
  const [saving, setSaving]     = useState(false);
  const [error, setError]       = useState(null);
  const [help, setHelp]         = useState({});
  const [completedSteps, setCompletedSteps] = useState([]);

  // Step 2 — Members state
  const [members, setMembers]   = useState([]);
  const [editMember, setEditMember] = useState(null);
  const [showAddMember, setShowAddMember] = useState(false);
  const [addMemberForm, setAddMemberForm] = useState({ name: "", email: "", password: "" });
  const [addMemberError, setAddMemberError] = useState(null);
  const [addingMember, setAddingMember] = useState(false);
  const [copyFrom, setCopyFrom] = useState(null);
  const [copyTo, setCopyTo]     = useState({});

  // Step 3 — Satvik state
  // satvikValue moved to SatvikEditor component

  // Step 4 — Panchangam state
  const [panchangamId, setPanchangamId] = useState(null);

  // Step 5 — Events state
  const [events, setEvents]     = useState([]);
  // newEvent/addingEvent/ingSearch/ingResults moved to EventEditor component

  const toggleHelp = (key) => setHelp(h => ({ ...h, [key]: !h[key] }));

  // ── Load onboarding data ───────────────────────────────────────────────────
  useEffect(() => {
    (async () => {
      try {
        const d = await apiFetch("/onboarding/data");
        setData(d);
        // Pre-fill members
        setMembers(d.members.map(m => ({
          ...m,
          dietary_preference: m.dietary_preference || d.household.dietary_preference || "Veg",
          age_group:          m.age_group || null,
          gender:             m.gender || null,
          phone_number:       m.phone_number || null,
          restrictions: m.restrictions || [],
        })));
        // Satvik/Panchangam/Events pre-fill moved into editor components

      } catch (e) {
        setError("Failed to load setup data. Please restart.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // ── Save handlers ──────────────────────────────────────────────────────────
  const searchIngredients = async (q) => {
    setIngSearch(q);
    if (q.length < 2) { setIngResults([]); return; }
    try {
      const res = await apiFetch(`/lookup/ingredients/search?q=${encodeURIComponent(q)}&limit=8`);
      setIngResults(res.results || res || []);
    } catch {
      // fallback — search locally from satvikIngredients
      const all = Object.values(satvikIngredients).flat();
      setIngResults(all.filter(i => i.name_en.toLowerCase().includes(q.toLowerCase())).slice(0, 8));
    }
  };

  const saveMembers = async () => {
    setSaving(true);
    try {
      await apiFetch("/onboarding/members", {
        method: "POST",
        body: JSON.stringify({ members: members.map(m => ({
          user_id:            m.user_id,
          dietary_preference: m.dietary_preference,
          age_group:          m.age_group,
          gender:             m.gender,
          phone_number:       m.phone_number,
          restrictions: m.restrictionValue
            ? valueToRestrictions(m.restrictionValue)
            : (m.restrictions || []).map(r => ({
                ingredient_id:    r.ingredient_id,
                restriction_type: r.restriction_type,
              }))
        }))}),
      });
      setCompletedSteps(s => [...new Set([...s, 1])]);
      setStep(2);
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

  const handleAddMember = async () => {
    setAddMemberError(null);
    if (!addMemberForm.name || !addMemberForm.password) {
      setAddMemberError(t("manageMembers.allFieldsRequired"));
      return;
    }
    if (addMemberForm.password.length < 8) {
      setAddMemberError(t("manageMembers.passwordMin8"));
      return;
    }
    setAddingMember(true);
    try {
      const newMember = await apiFetch("/auth/members/create", {
        method: "POST",
        body: JSON.stringify(addMemberForm),
      });
      setMembers(ms => [...ms, {
        user_id: newMember.user_id,
        name: addMemberForm.name,
        dietary_preference: "Veg",
        restrictions: [],
      }]);
      setAddMemberForm({ name: "", email: "", password: "" });
      setShowAddMember(false);
    } catch (e) {
      setAddMemberError(e.message);
    } finally {
      setAddingMember(false);
    }
  };

  // saveSatvik/savePanchangam/saveEvents moved into editor components

  const confirmOnboarding = async () => {
    setSaving(true);
    try {
      await apiFetch("/onboarding/confirm", { method: "POST" });
      onComplete();
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

  // ── Member edit helpers ────────────────────────────────────────────────────
  const updateMemberPref = (userId, pref) => {
    setMembers(ms => ms.map(m => m.user_id === userId ? { ...m, dietary_preference: pref } : m));
  };

  const applyCopyTo = () => {
    const src = members.find(m => m.user_id === copyFrom);
    if (!src) return;
    setMembers(ms => ms.map(m =>
      copyTo[m.user_id] ? { ...m, dietary_preference: src.dietary_preference } : m
    ));
    setCopyTo({});
    setCopyFrom(null);
  };

  // ── Loading / error states ─────────────────────────────────────────────────
  if (loading) {
    return (
      <div style={{ minHeight: "100vh", background: C.green, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ color: C.mint, fontSize: 14 }}>{t("common.loading")}</div>
      </div>
    );
  }

  // ── Shared styles ──────────────────────────────────────────────────────────
  const inputStyle = { width: "100%", padding: "9px 12px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box" };
  const cardStyle  = { background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 10 };

  return (
    <div style={{ minHeight: "100vh", background: C.green, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif", padding: "24px 0" }}>
      <div style={{ width: "100%", maxWidth: 400, padding: "0 16px" }}>

        {/* Tab bar */}
        <div style={{ display: "flex", gap: 5, justifyContent: "center", flexWrap: "wrap", marginBottom: 10 }}>
          {STEP_LABELS.map((label, i) => (
            <button key={i} onClick={() => i < step + 1 && setStep(i)}
              style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "4px 10px", lineHeight: 1.3, border: `0.5px solid ${i === step ? C.teal : C.border}`, borderRadius: 20, background: i === step ? "#E1F5EE" : "transparent", color: i === step ? C.deepTeal : i < step ? C.teal : C.muted, cursor: i <= step ? "pointer" : "default" }}>
              <span style={{ fontSize: 13, fontWeight: 500 }}>{i + 1}</span>
              <span style={{ fontSize: 10 }}>{label}</span>
            </button>
          ))}
        </div>

        {/* Card */}
        <div style={{ background: C.card, borderRadius: 20, padding: "20px 18px", position: "relative" }}>

          {/* Close — goes to confirm with defaults */}
          <div onClick={confirmOnboarding} style={{ position: "absolute", top: 14, right: 16, fontSize: 16, color: C.muted, cursor: "pointer" }}>✕</div>

          {/* Error */}
          {error && (
            <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.errorText }}>
              {error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span>
            </div>
          )}

          {/* ── STEP 0: Welcome ───────────────────────────────────────────── */}
          {step === 0 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ textAlign: "center", padding: "10px 0 12px" }}>
                <div style={{ fontSize: 32, marginBottom: 6 }}>👋</div>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text, marginBottom: 4 }}>{t("onboarding.welcome.title")}</div>
                <div style={{ fontSize: 12, color: C.muted, lineHeight: 1.5 }}>{t("onboarding.welcome.subtitle")}</div>
              </div>
              <div style={{ background: "#E1F5EE", border: `0.5px solid ${C.teal}`, borderRadius: 12, padding: "12px 14px", marginBottom: 12 }}>
                <div style={{ fontSize: 12, fontWeight: 500, color: C.deepTeal, marginBottom: 8 }}>{t("onboarding.welcome.whyMatters")}</div>
                {[
                  ["🎯", t("onboarding.welcome.point1")],
                  ["🌙", t("onboarding.welcome.point2")],
                  ["🎂", t("onboarding.welcome.point3")],
                  ["✨", t("onboarding.welcome.point4")],
                ].map(([icon, text]) => (
                  <div key={text} style={{ display: "flex", gap: 8, marginBottom: 8 }}>
                    <span style={{ fontSize: 14, flexShrink: 0 }}>{icon}</span>
                    <span style={{ fontSize: 12, color: C.deepTeal, lineHeight: 1.4 }}>{text}</span>
                  </div>
                ))}
              </div>
              <div style={cardStyle}>
                <div style={{ fontSize: 12, fontWeight: 500, color: C.text, marginBottom: 8 }}>{t("onboarding.welcome.whatSetup")}</div>
                {[t("onboarding.members.title"), t("onboarding.satvik.title"), t("onboarding.lunar.title"), t("onboarding.events.title")].map((item, i) => (
                  <div key={item} style={{ display: "flex", alignItems: "center", gap: 10, padding: "8px 0", borderBottom: i < 3 ? `0.5px solid ${C.border}` : "none" }}>
                    <div style={{ width: 20, height: 20, borderRadius: "50%", border: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: C.muted, background: "#F7F4EE", flexShrink: 0 }}>{i + 1}</div>
                    <span style={{ fontSize: 13, color: C.text }}>{item}</span>
                  </div>
                ))}
              </div>
              <div style={{ fontSize: 11, color: C.muted, textAlign: "center", padding: "6px 0", cursor: "pointer", textDecoration: "underline" }} onClick={confirmOnboarding}>
                {t("common.skip")}
              </div>
              <div style={{ marginTop: "auto", paddingTop: 12 }}>
                <button onClick={() => setStep(1)} style={{ width: "100%", padding: 12, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>
                  {t("onboarding.welcome.getStarted")}
                </button>
              </div>
            </div>
          )}

          {/* ── STEP 1: Members ──────────────────────────────────────────── */}
          {step === 1 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>{t("onboarding.members.title")}</div>
                <HelpTip text="Each member can have their own dietary preference and restrictions. When only some members are home, we recommend meals they'll enjoy." visible={help.members} onToggle={() => toggleHelp("members")} />
              </div>
              <div style={{ fontSize: 12, color: C.muted, marginBottom: 14 }}>{t("onboarding.members.subtitle")}</div>

              <div style={cardStyle}>
                {members.map((m, idx) => {
                  const isAdmin = m.user_id === user?.user_id;
                  return (
                    <div key={m.user_id} style={{ display: "flex", alignItems: "center", gap: 8, padding: "9px 0", borderBottom: idx < members.length - 1 ? `0.5px solid ${C.border}` : "none" }}>
                      <Avatar name={m.name} bg={["#E1F5EE", "#FAEEDA", "#EEEDFE"][idx % 3]} color={["#0F6E56", "#633806", "#3C3489"][idx % 3]} />
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{m.name}{isAdmin ? " (You)" : ""}</div>
                        <div style={{ display: "flex", gap: 4, marginTop: 3, flexWrap: "wrap" }}>
                          <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 20, border: `0.5px solid ${C.teal}`, background: "#E1F5EE", color: C.deepTeal }}>{m.dietary_preference}</span>
                          {m.restrictions.slice(0, 2).map(r => (
                            <span key={r.ingredient_id + r.restriction_type} style={{ fontSize: 11, padding: "2px 8px", borderRadius: 20, border: `0.5px solid ${C.border}`, color: C.muted }}>
                              {r.restriction_type === "Allergy" ? "🚫" : "😕"} {r.name_en}
                            </span>
                          ))}
                        </div>
                      </div>
                      <span onClick={() => setEditMember({ ...m, restrictionValue: restrictionsToValue(m.restrictions || []) })} style={{ fontSize: 11, color: C.deepTeal, cursor: "pointer" }}>Edit</span>
                      {!isAdmin && <span style={{ fontSize: 11, color: "#E24B4A", cursor: "pointer" }}>Del</span>}
                    </div>
                  );
                })}
              </div>

              {/* Add Member */}
              {!showAddMember ? (
                <button onClick={() => setShowAddMember(true)}
                  style={{ width: "100%", padding: 10, marginBottom: 10, border: `1px dashed ${C.teal}`, borderRadius: 10, background: "transparent", color: C.deepTeal, fontSize: 13, fontWeight: 500, cursor: "pointer" }}>
                  {t("manageMembers.addMember")}
                </button>
              ) : (
                <div style={{ ...cardStyle, background: "#FFF9F2" }}>
                  <input type="text" placeholder={t("manageMembers.namePlaceholder")} value={addMemberForm.name}
                    onChange={e => setAddMemberForm(f => ({ ...f, name: e.target.value }))}
                    style={{ width: "100%", padding: "9px 12px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, boxSizing: "border-box", marginBottom: 10 }} />
                  <input type="email" placeholder={t("manageMembers.emailPlaceholder")} value={addMemberForm.email}
                    onChange={e => setAddMemberForm(f => ({ ...f, email: e.target.value }))}
                    style={{ width: "100%", padding: "9px 12px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, boxSizing: "border-box", marginBottom: 10 }} />
                  <input type="password" placeholder={t("manageMembers.passwordPlaceholder")} value={addMemberForm.password}
                    onChange={e => setAddMemberForm(f => ({ ...f, password: e.target.value }))}
                    style={{ width: "100%", padding: "9px 12px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, boxSizing: "border-box", marginBottom: 10 }} />
                  {addMemberError && <div style={{ fontSize: 12, color: "#993C1D", marginBottom: 10 }}>{addMemberError}</div>}
                  <div style={{ display: "flex", gap: 8 }}>
                    <button onClick={() => { setShowAddMember(false); setAddMemberError(null); }}
                      style={{ flex: 1, padding: 10, border: `0.5px solid ${C.border}`, borderRadius: 10, background: "transparent", color: C.muted, fontSize: 13, cursor: "pointer" }}>
                      {t("manageMembers.cancel")}
                    </button>
                    <button onClick={handleAddMember} disabled={addingMember}
                      style={{ flex: 1, padding: 10, border: "none", borderRadius: 10, background: C.green, color: C.mint, fontSize: 13, fontWeight: 500, cursor: addingMember ? "not-allowed" : "pointer", opacity: addingMember ? 0.7 : 1 }}>
                      {addingMember ? t("manageMembers.adding") : t("manageMembers.addBtn")}
                    </button>
                  </div>
                </div>
              )}
              {/* Copy preference section */}
              {members.length > 1 && (
                <div style={{ background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 10, padding: "10px 12px", marginBottom: 10 }}>
                  <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>{t("onboarding.members.copyFrom")}</div>
                  <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 8 }}>
                    {members.map(m => (
                      <button key={m.user_id} onClick={() => setCopyFrom(m.user_id)}
                        style={{ padding: "4px 10px", borderRadius: 20, fontSize: 11, border: `0.5px solid ${copyFrom === m.user_id ? C.teal : C.border}`, background: copyFrom === m.user_id ? "#E1F5EE" : "transparent", color: copyFrom === m.user_id ? C.deepTeal : C.muted, cursor: "pointer" }}>
                        {m.name}
                      </button>
                    ))}
                  </div>
                  {copyFrom && (
                    <>
                      <div style={{ fontSize: 12, color: C.muted, marginBottom: 6 }}>Copy to:</div>
                      {members.filter(m => m.user_id !== copyFrom).map(m => (
                        <div key={m.user_id} style={{ display: "flex", alignItems: "center", gap: 8, padding: "4px 0" }}>
                          <div onClick={() => setCopyTo(ct => ({ ...ct, [m.user_id]: !ct[m.user_id] }))}
                            style={{ width: 16, height: 16, borderRadius: 4, border: `0.5px solid ${C.border}`, background: copyTo[m.user_id] ? "#1D9E75" : "white", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white", cursor: "pointer", flexShrink: 0 }}>
                            {copyTo[m.user_id] ? "✓" : ""}
                          </div>
                          <span style={{ fontSize: 12, color: C.text }}>{m.name}</span>
                        </div>
                      ))}
                      <button onClick={applyCopyTo} style={{ marginTop: 8, width: "100%", padding: 8, background: C.mint, border: "none", borderRadius: 8, fontSize: 12, fontWeight: 500, color: C.green, cursor: "pointer" }}>
                        {t("common.save")}
                      </button>
                    </>
                  )}
                </div>
              )}

              <NavButtons onBack={() => setStep(0)} onSkip={() => setStep(2)} onNext={saveMembers} loading={saving} />

              {/* Member Edit Sheet */}
              {editMember && (
                <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", zIndex: 50, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
                  <div style={{ background: C.card, borderRadius: "16px 16px 0 0", padding: 20, width: "100%", maxWidth: 400, maxHeight: "80vh", overflowY: "auto" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
                      <div style={{ fontSize: 15, fontWeight: 500, color: C.text }}>Edit — {editMember.name}</div>
                      <span onClick={() => setEditMember(null)} style={{ fontSize: 16, color: C.muted, cursor: "pointer" }}>✕</span>
                    </div>
                    <Field label="Dietary preference">
                      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 14 }}>
                        {DIET_PREFS.map(d => (
                          <div key={d} onClick={() => setEditMember(em => ({ ...em, dietary_preference: d }))}
                            style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, padding: "8px 6px", borderRadius: 10, border: `0.5px solid ${editMember.dietary_preference === d ? C.teal : C.border}`, background: editMember.dietary_preference === d ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                            <img src={DIET_IMAGES[d]} alt={d} style={{ width: 28, height: 28, objectFit: "contain" }} onError={e => e.target.style.display='none'} />
                            <span style={{ fontSize: 11, fontWeight: 500, color: editMember.dietary_preference === d ? C.deepTeal : C.muted }}>{d}</span>
                          </div>
                        ))}
                      </div>
                    </Field>
                    <Field label="Age group">
                      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 14 }}>
                        {AGE_GROUPS.map(ag => (
                          <div key={ag.value} onClick={() => setEditMember(em => ({ ...em, age_group: ag.value }))}
                            style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 10px", borderRadius: 10, border: `0.5px solid ${editMember.age_group === ag.value ? C.teal : C.border}`, background: editMember.age_group === ag.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                            <span style={{ fontSize: 20 }}>{ag.emoji}</span>
                            <div>
                              <div style={{ fontSize: 12, fontWeight: 500, color: editMember.age_group === ag.value ? C.deepTeal : C.text }}>{ag.label}</div>
                              <div style={{ fontSize: 10, color: C.muted }}>{ag.sub}</div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </Field>
                    <Field label="Gender">
                      <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 14 }}>
                        {GENDERS.map(g => (
                          <div key={g.value} onClick={() => setEditMember(em => ({ ...em, gender: g.value }))}
                            style={{ display: "flex", alignItems: "center", gap: 6, padding: "6px 10px", borderRadius: 20, border: `0.5px solid ${editMember.gender === g.value ? C.teal : C.border}`, background: editMember.gender === g.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                            <span style={{ fontSize: 16 }}>{g.emoji}</span>
                            <span style={{ fontSize: 11, color: editMember.gender === g.value ? C.deepTeal : C.muted }}>{g.value}</span>
                          </div>
                        ))}
                      </div>
                    </Field>
                    <Field label="Phone number (optional)">
                      <input value={editMember.phone_number || ""} onChange={e => setEditMember(em => ({ ...em, phone_number: e.target.value }))} placeholder="e.g. 98765 43210" style={inputStyle} />
                    </Field>
                    <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>
                      Allergies & dislikes
                      <HelpTip text="Allergy = medical restriction. Dislike = preference. Both can be active for the same ingredient." visible={help.restrictions} onToggle={() => toggleHelp("restrictions")} />
                    </div>
                    <IngredientSelector
                      mode="restriction"
                      value={editMember.restrictionValue || {}}
                      onChange={rv => setEditMember(em => ({ ...em, restrictionValue: rv }))}
                      showImages={true}
                      maxHeight="200px"
                    />
                    <button onClick={() => {
                      const restrictions = valueToRestrictions(editMember.restrictionValue || {});
                      setMembers(ms => ms.map(m => m.user_id === editMember.user_id
                        ? { ...m, dietary_preference: editMember.dietary_preference,
                            age_group: editMember.age_group, gender: editMember.gender,
                            phone_number: editMember.phone_number,
                            restrictions, restrictionValue: editMember.restrictionValue }
                        : m));
                      setEditMember(null);
                      setIngSearch(""); setIngResults([]);
                    }} style={{ width: "100%", padding: 11, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>
                      {t("common.save")}
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ── STEP 2: Satvik ──────────────────────────────────────────── */}
          {step === 2 && (
            <SatvikEditor
              onBack={() => setStep(1)}
              onSkip={() => setStep(3)}
              onDone={() => { setCompletedSteps(s => [...new Set([...s, 2])]); setStep(3); }}
            />
          )}

          {/* ── STEP 3: Lunar Calendar ────────────────────────────────────── */}
          {step === 3 && (
            <LunarEditor
              onBack={() => setStep(2)}
              onSkip={() => setStep(4)}
              onDone={() => setStep(4)}
            />
          )}

          {/* ── STEP 4: Events ──────────────────────────────────────────── */}
          {step === 4 && (
            <EventEditor
              onBack={() => setStep(3)}
              onSkip={() => setStep(5)}
              onDone={() => { setCompletedSteps(s => [...new Set([...s, 4])]); setStep(5); }}
            />
          )}

          {/* ── STEP 5: Done ─────────────────────────────────────────────── */}
          {step === 5 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ textAlign: "center", padding: "16px 0 12px" }}>
                <div style={{ fontSize: 36, marginBottom: 8 }}>🎉</div>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text, marginBottom: 4 }}>{t("onboarding.done.title")}</div>
                <div style={{ fontSize: 12, color: C.muted, lineHeight: 1.5 }}>{t("onboarding.done.subtitle")}</div>
              </div>
              <div style={cardStyle}>
                {[
                  [t("onboarding.members.title"), completedSteps.includes(1) || data?.wizard_status?.members_done],
                  [t("onboarding.satvik.title"), completedSteps.includes(2) || data?.wizard_status?.satvik_done],
                  [t("onboarding.lunar.title"), !!panchangamId],
                  [t("onboarding.events.title"), completedSteps.includes(4) || data?.wizard_status?.events_done],
                ].map(([label, done]) => (
                  <div key={label} style={{ display: "flex", alignItems: "center", gap: 10, padding: "9px 0", borderBottom: `0.5px solid ${C.border}` }}>
                    <div style={{ width: 20, height: 20, borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, flexShrink: 0, background: done ? "#1D9E75" : "#F7F4EE", color: done ? "white" : C.muted, border: done ? "none" : `0.5px solid ${C.border}` }}>
                      {done ? "✓" : "–"}
                    </div>
                    <span style={{ fontSize: 13, color: done ? C.text : C.muted }}>{label}</span>
                  </div>
                ))}
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: 8, marginTop: 12 }}>
                <button onClick={confirmOnboarding} disabled={saving} style={{ width: "100%", padding: 13, border: "none", borderRadius: 12, fontSize: 14, fontWeight: 500, color: C.green, background: C.mint, cursor: saving ? "not-allowed" : "pointer", opacity: saving ? 0.7 : 1 }}>
                  {saving ? t("common.saving") : t("onboarding.done.goToDashboard")}
                </button>
                <button onClick={() => setStep(0)} style={{ width: "100%", padding: 10, border: `0.5px solid ${C.border}`, borderRadius: 12, fontSize: 13, color: C.muted, background: "transparent", cursor: "pointer" }}>
                  {t("common.back")}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
