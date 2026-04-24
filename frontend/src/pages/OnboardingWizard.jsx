import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import IngredientSelector, { satvikToValue, valueToSatvik, restrictionsToValue, valueToRestrictions } from "../components/IngredientSelector";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

// ── Colours ──────────────────────────────────────────────────────────────────
const C = {
  green:    "#1A3A2E",
  mint:     "#9FE1CB",
  teal:     "#5DCAA5",
  deepTeal: "#0F6E56",
  card:     "#FFF9F2",
  bg:       "#F7F4EE",
  border:   "#EDE8E0",
  text:     "#2C2C2A",
  muted:    "#888780",
  error:    "#FAECE7",
  errorText:"#712B13",
  feast:    { bg: "#FAEEDA", text: "#633806" },
  satvik:   { bg: "#E1F5EE", text: "#0F6E56" },
};

const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];
const AGE_GROUPS = [
  { value: "Child",  label: "Child",  sub: "0–12 yrs",  emoji: "👶" },
  { value: "Teen",   label: "Teen",   sub: "13–17 yrs", emoji: "🧒" },
  { value: "Adult",  label: "Adult",  sub: "18–59 yrs", emoji: "🧑" },
  { value: "Senior", label: "Senior", sub: "60+ yrs",   emoji: "👴" },
];

const GENDERS = [
  { value: "Male",               emoji: "👨" },
  { value: "Female",             emoji: "👩" },
  { value: "Transgender",        emoji: "🏳️" },
  { value: "Prefer not to say",  emoji: "🤐" },
];

const DIET_IMAGES = {
  "Veg":        "https://cdn-icons-png.flaticon.com/512/2153/2153788.png",
  "Non-Veg":    "https://cdn-icons-png.flaticon.com/512/857/857681.png",
  "Vegan":      "https://cdn-icons-png.flaticon.com/512/2153/2153786.png",
  "Eggitarian": "https://cdn-icons-png.flaticon.com/512/837/837560.png",
};

const EVENT_ICONS = [
  "🎂", "🎉", "🎊", "💍", "🙏", "⭐", "🌸", "🕉️",
  "👶", "🎓", "🏠", "❤️", "🌙", "🔔", "🪔", "🌺"
];

const STEP_LABELS = ["Welcome", "Members", "Satvik", "Calendar", "Events", "Done"];

// ── Small reusable components ─────────────────────────────────────────────────
const Field = ({ label, hint, children }) => (
  <div style={{ marginBottom: 14 }}>
    <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, marginBottom: 3 }}>{label}</div>
    {hint && <div style={{ fontSize: 10, color: "#B4B2A9", marginBottom: 5, lineHeight: 1.4 }}>{hint}</div>}
    {children}
  </div>
);

const HelpTip = ({ text, visible, onToggle }) => (
  <span style={{ display: "inline-flex", marginLeft: 4 }}>
    <span onClick={onToggle} style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 16, height: 16, borderRadius: "50%", border: `0.5px solid ${C.border}`, fontSize: 10, color: C.muted, cursor: "pointer" }}>?</span>
    {visible && (
      <div style={{ position: "absolute", zIndex: 20, background: C.card, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 10px", fontSize: 11, color: C.muted, lineHeight: 1.5, maxWidth: 240, marginTop: 20, boxShadow: "0 4px 16px rgba(0,0,0,0.08)" }}>
        {text}
      </div>
    )}
  </span>
);

const Toggle = ({ value, onChange }) => (
  <div onClick={() => onChange(!value)} style={{ width: 30, height: 17, borderRadius: 9, background: value ? C.teal : C.border, position: "relative", cursor: "pointer", flexShrink: 0, transition: "background 0.2s" }}>
    <div style={{ width: 13, height: 13, borderRadius: "50%", background: "white", position: "absolute", top: 2, left: value ? 15 : 2, transition: "left 0.2s" }} />
  </div>
);

const Chip = ({ label, active, onClick }) => (
  <button onClick={onClick} style={{ padding: "7px 10px", borderRadius: 8, fontSize: 12, fontWeight: 500, cursor: "pointer", background: active ? C.green : "transparent", color: active ? C.mint : C.muted, border: active ? "none" : `0.5px solid ${C.border}`, transition: "all 0.15s" }}>
    {label}
  </button>
);

const Avatar = ({ name, bg = "#E1F5EE", color = C.deepTeal }) => (
  <div style={{ width: 32, height: 32, borderRadius: "50%", background: bg, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, fontWeight: 500, color, flexShrink: 0 }}>
    {(name || "?")[0].toUpperCase()}
  </div>
);

const NavButtons = ({ onBack, onNext, onSkip, nextLabel = "Save & continue", loading }) => (
  <div style={{ display: "flex", gap: 8, marginTop: "auto", paddingTop: 12 }}>
    {onBack && <button onClick={onBack} style={{ flex: 1, padding: 10, border: `0.5px solid ${C.border}`, borderRadius: 10, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>Back</button>}
    {onSkip && <button onClick={onSkip} style={{ flex: 1, padding: 10, border: `0.5px dashed ${C.border}`, borderRadius: 10, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>Skip</button>}
    <button onClick={onNext} disabled={loading} style={{ flex: 2, padding: 10, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1 }}>
      {loading ? "Saving..." : nextLabel}
    </button>
  </div>
);

// ── Main Wizard ───────────────────────────────────────────────────────────────
export default function OnboardingWizard({ onComplete }) {
  const { apiFetch, user } = useAuth();
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
  const [copyFrom, setCopyFrom] = useState(null);
  const [copyTo, setCopyTo]     = useState({});

  // Step 3 — Satvik state
  const [satvikValue, setSatvikValue] = useState({});

  // Step 4 — Panchangam state
  const [panchangamId, setPanchangamId] = useState(null);

  // Step 5 — Events state
  const [events, setEvents]     = useState([]);
  const [newEvent, setNewEvent] = useState({ event_name: "", event_date: "", event_type: "Personal", is_sattvic_required: false, recurring_annual: true, icon: "🎂" });
  const [addingEvent, setAddingEvent] = useState(false);
  const [ingSearch, setIngSearch] = useState("");
  const [ingResults, setIngResults] = useState([]);

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
        // Pre-fill Satvik
        setSatvikValue(satvikToValue(d.satvik));
        // Pre-fill Panchangam
        if (d.panchangam_selected) setPanchangamId(d.panchangam_selected.id);
        // Pre-fill events
        setEvents(d.events.filter(e => e.source === "USER"));

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
          restrictions:       m.restrictions.map(r => ({
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

  const saveSatvik = async () => {
    setSaving(true);
    try {
      await apiFetch("/onboarding/satvik", {
        method: "POST",
        body: JSON.stringify({ restrictions: valueToSatvik(satvikValue) }),
      });
      setCompletedSteps(s => [...new Set([...s, 2])]);
      setStep(3);
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

  const savePanchangam = async () => {
    setSaving(true);
    try {
      await apiFetch("/onboarding/panchangam", {
        method: "POST",
        body: JSON.stringify({ panchangam_type_id: panchangamId }),
      });
      setStep(4);
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

  const saveEvents = async () => {
    setSaving(true);
    try {
      if (events.length > 0) {
        await apiFetch("/onboarding/events", {
          method: "POST",
          body: JSON.stringify({ events: events.map(e => ({
            event_name:          e.event_name,
            event_date:          e.event_date,
            event_type:          e.event_type,
            is_sattvic_required: e.is_sattvic_required,
            recurring_annual:    e.recurring_annual,
          }))})
        });
      }
      setCompletedSteps(s => [...new Set([...s, 4])]);
      setStep(5);
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

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
        <div style={{ color: C.mint, fontSize: 14 }}>Setting up your household...</div>
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
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text, marginBottom: 4 }}>Welcome, {user?.name?.split(" ")[0]}!</div>
                <div style={{ fontSize: 12, color: C.muted, lineHeight: 1.5 }}>A few minutes now means smarter meal plans every week.</div>
              </div>
              <div style={{ background: "#E1F5EE", border: `0.5px solid ${C.teal}`, borderRadius: 12, padding: "12px 14px", marginBottom: 12 }}>
                <div style={{ fontSize: 12, fontWeight: 500, color: C.deepTeal, marginBottom: 8 }}>Why this setup matters</div>
                {[
                  ["🎯", "Recipes recommended based on who's home and what they enjoy"],
                  ["🌙", "Satvik and lunar calendar ensure right meals on right days"],
                  ["🎂", "Special events automatically get the right meal suggestions"],
                  ["✨", "The more you share, the smarter your planner gets each week"],
                ].map(([icon, text]) => (
                  <div key={text} style={{ display: "flex", gap: 8, marginBottom: 8 }}>
                    <span style={{ fontSize: 14, flexShrink: 0 }}>{icon}</span>
                    <span style={{ fontSize: 12, color: C.deepTeal, lineHeight: 1.4 }}>{text}</span>
                  </div>
                ))}
              </div>
              <div style={cardStyle}>
                <div style={{ fontSize: 12, fontWeight: 500, color: C.text, marginBottom: 8 }}>What we'll set up</div>
                {["Member profiles & preferences", "Satvik definition", "Lunar calendar", "Events & special days"].map((item, i) => (
                  <div key={item} style={{ display: "flex", alignItems: "center", gap: 10, padding: "8px 0", borderBottom: i < 3 ? `0.5px solid ${C.border}` : "none" }}>
                    <div style={{ width: 20, height: 20, borderRadius: "50%", border: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: C.muted, background: "#F7F4EE", flexShrink: 0 }}>{i + 1}</div>
                    <span style={{ fontSize: 13, color: C.text }}>{item}</span>
                  </div>
                ))}
              </div>
              <div style={{ fontSize: 11, color: C.muted, textAlign: "center", padding: "6px 0", cursor: "pointer", textDecoration: "underline" }} onClick={confirmOnboarding}>
                Skip — confirm with defaults now
              </div>
              <div style={{ marginTop: "auto", paddingTop: 12 }}>
                <button onClick={() => setStep(1)} style={{ width: "100%", padding: 12, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>
                  Let's begin
                </button>
              </div>
            </div>
          )}

          {/* ── STEP 1: Members ──────────────────────────────────────────── */}
          {step === 1 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Member profiles</div>
                <HelpTip text="Each member can have their own dietary preference and restrictions. When only some members are home, we recommend meals they'll enjoy." visible={help.members} onToggle={() => toggleHelp("members")} />
              </div>
              <div style={{ fontSize: 12, color: C.muted, marginBottom: 14 }}>Set individual preferences for each member.</div>

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
                      <span onClick={() => setEditMember(m)} style={{ fontSize: 11, color: C.deepTeal, cursor: "pointer" }}>Edit</span>
                      {!isAdmin && <span style={{ fontSize: 11, color: "#E24B4A", cursor: "pointer" }}>Del</span>}
                    </div>
                  );
                })}
              </div>

              {/* Copy preference section */}
              {members.length > 1 && (
                <div style={{ background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 10, padding: "10px 12px", marginBottom: 10 }}>
                  <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>Copy preference from:</div>
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
                        Apply to selected
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
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
                      <div style={{ fontSize: 12, color: C.muted }}>Allergies & dislikes <HelpTip text="Allergy = medical — ingredient must never appear. Dislike = preference — avoided where possible. Both can coexist." visible={help.restrictions} onToggle={() => toggleHelp("restrictions")} /></div>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 8, background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 8, padding: "7px 10px", marginBottom: 6 }}>
                      <span style={{ fontSize: 13, color: C.muted }}>⌕</span>
                      <input value={ingSearch} onChange={e => searchIngredients(e.target.value)} placeholder="Search ingredient to add..." style={{ border: "none", background: "transparent", fontSize: 13, color: C.text, outline: "none", flex: 1, width: "100%" }} />
                    </div>
                    {ingResults.length > 0 && (
                      <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 8, marginBottom: 8, maxHeight: 140, overflowY: "auto" }}>
                        {ingResults.map(ing => (
                          <div key={ing.id} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "7px 10px", borderBottom: `0.5px solid ${C.border}`, cursor: "pointer" }}
                            onClick={() => {
                              const exists = (editMember.restrictions || []).find(r => r.ingredient_id === ing.id && r.restriction_type === "Allergy");
                              if (!exists) {
                                setEditMember(em => ({ ...em, restrictions: [...(em.restrictions || []), { ingredient_id: ing.id, name_en: ing.name_en, name_ta: ing.name_ta, restriction_type: "Allergy" }] }));
                              }
                              setIngSearch(""); setIngResults([]);
                            }}>
                            <span style={{ fontSize: 13, color: C.text }}>{ing.name_en}</span>
                            <span style={{ fontSize: 11, color: C.deepTeal }}>+ Add</span>
                          </div>
                        ))}
                      </div>
                    )}
                    <div style={{ background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 10, padding: "8px 12px", marginBottom: 12 }}>
                      {(editMember.restrictions || []).length === 0 && (
                        <div style={{ fontSize: 12, color: C.muted, textAlign: "center", padding: "8px 0" }}>No restrictions added yet</div>
                      )}
                      {(editMember.restrictions || []).map((r, i) => (
                        <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "7px 0", borderBottom: i < editMember.restrictions.length - 1 ? `0.5px solid ${C.border}` : "none" }}>
                          <div style={{ flex: 1, fontSize: 13, color: C.text }}>{r.name_en}</div>
                          <div style={{ display: "flex", border: `0.5px solid ${C.border}`, borderRadius: 6, overflow: "hidden", flexShrink: 0 }}>
                            <button onClick={() => setEditMember(em => ({ ...em, restrictions: em.restrictions.map((x, j) => j === i ? { ...x, restriction_type: "Allergy" } : x) }))}
                              style={{ padding: "3px 7px", fontSize: 10, cursor: "pointer", border: "none", background: r.restriction_type === "Allergy" ? "#FAECE7" : "transparent", color: r.restriction_type === "Allergy" ? "#712B13" : C.muted }}>Allergy</button>
                            <button onClick={() => setEditMember(em => ({ ...em, restrictions: em.restrictions.map((x, j) => j === i ? { ...x, restriction_type: "Dislike" } : x) }))}
                              style={{ padding: "3px 7px", fontSize: 10, cursor: "pointer", border: "none", background: r.restriction_type === "Dislike" ? "#FAEEDA" : "transparent", color: r.restriction_type === "Dislike" ? "#633806" : C.muted }}>Dislike</button>
                          </div>
                          <span onClick={() => setEditMember(em => ({ ...em, restrictions: em.restrictions.filter((_, j) => j !== i) }))} style={{ fontSize: 13, color: "#E24B4A", cursor: "pointer", marginLeft: 4 }}>✕</span>
                        </div>
                      ))}
                    </div>
                    <button onClick={() => {
                      setMembers(ms => ms.map(m => m.user_id === editMember.user_id ? { ...m, dietary_preference: editMember.dietary_preference, restrictions: editMember.restrictions } : m));
                      setEditMember(null);
                    }} style={{ width: "100%", padding: 11, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>
                      Save
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ── STEP 2: Satvik ───────────────────────────────────────────── */}
          {step === 2 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Satvik definition</div>
                <HelpTip text="Select ingredients your household AVOIDS on Satvik days. e.g. most Tamil Brahmin households avoid onion and garlic. These rules apply on all Satvik-tagged days." visible={help.satvik} onToggle={() => toggleHelp("satvik")} />
              </div>
              <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>Toggle ingredients your household <strong>AVOIDS</strong> on Satvik days.</div>
              <IngredientSelector
                mode="satvik"
                value={satvikValue}
                onChange={setSatvikValue}
                showImages={true}
                maxHeight="320px"
              />
              <NavButtons onBack={() => setStep(1)} onSkip={() => setStep(3)} onNext={saveSatvik} loading={saving} />
            </div>
          )}

          {/* ── STEP 3: Lunar Calendar ───────────────────────────────────── */}
          {step === 3 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Lunar calendar</div>
                <HelpTip text="Select which Panchangam your household follows. We'll use this to suggest Satvik meals on the correct days automatically." visible={help.lunar} onToggle={() => toggleHelp("lunar")} />
              </div>
              <div style={{ fontSize: 12, color: C.muted, marginBottom: 14 }}>Which Panchangam does your household follow?</div>
              <div style={{ flex: 1, overflowY: "auto", maxHeight: 360 }}>
                {(data?.panchangam_types || []).map(pt => (
                  <div key={pt.id} onClick={() => setPanchangamId(pt.id === panchangamId ? null : pt.id)}
                    style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px", marginBottom: 8, background: panchangamId === pt.id ? "#E1F5EE" : "#F7F4EE", border: `0.5px solid ${panchangamId === pt.id ? C.teal : C.border}`, borderRadius: 12, cursor: "pointer", transition: "all 0.15s" }}>
                    <div style={{ fontSize: 22, width: 32, textAlign: "center", flexShrink: 0 }}>
                      {["🌙", "🌑", "⭐", "🌿", "🌊", "🎋", "☀️", "🌸", "🕉️", "🌺"][data.panchangam_types.indexOf(pt) % 10]}
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 13, fontWeight: 500, color: panchangamId === pt.id ? C.deepTeal : C.text }}>{pt.display_name}</div>
                      <div style={{ fontSize: 11, color: C.muted }}>{pt.language} · {pt.region}</div>
                    </div>
                    {panchangamId === pt.id && <div style={{ width: 18, height: 18, borderRadius: "50%", background: C.teal, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white" }}>✓</div>}
                  </div>
                ))}
                <div onClick={() => setPanchangamId(null)}
                  style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px", background: panchangamId === null ? "#E1F5EE" : "#F7F4EE", border: `0.5px solid ${panchangamId === null ? C.teal : C.border}`, borderRadius: 12, cursor: "pointer" }}>
                  <div style={{ fontSize: 22, width: 32, textAlign: "center" }}>🚫</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 500, color: panchangamId === null ? C.deepTeal : C.text }}>We don't follow a Panchangam</div>
                    <div style={{ fontSize: 11, color: C.muted }}>Skip lunar calendar — plan freely</div>
                  </div>
                  {panchangamId === null && <div style={{ width: 18, height: 18, borderRadius: "50%", background: C.teal, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white" }}>✓</div>}
                </div>
              </div>
              <NavButtons onBack={() => setStep(2)} onSkip={() => setStep(4)} onNext={savePanchangam} loading={saving} />
            </div>
          )}

          {/* ── STEP 4: Events ───────────────────────────────────────────── */}
          {step === 4 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Events & special days</div>
                <HelpTip text="Add birthdays, anniversaries or any special day. Feast = we suggest celebratory dishes. Satvik = Satvik rules apply. Our system learns from these every year." visible={help.events} onToggle={() => toggleHelp("events")} />
              </div>
              <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>We'll suggest the right meals automatically on these days.</div>
              <div style={{ flex: 1, overflowY: "auto", maxHeight: 300 }}>
                {events.length === 0 && !addingEvent && (
                  <div style={{ textAlign: "center", padding: "20px 0", fontSize: 13, color: C.muted }}>No events added yet</div>
                )}
                {events.map((e, i) => (
                  <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "9px 0", borderBottom: `0.5px solid ${C.border}` }}>
                    <div style={{ fontSize: 18, width: 24, textAlign: "center", flexShrink: 0 }}>{e.icon || (e.is_sattvic_required ? "🙏" : "🎉")}</div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 13, color: C.text }}>{e.event_name}</div>
                      <div style={{ fontSize: 11, color: C.muted }}>{e.event_date}{e.recurring_annual ? " — every year" : ""}</div>
                    </div>
                    <span style={{ fontSize: 10, padding: "2px 6px", borderRadius: 10, ...(e.is_sattvic_required ? C.satvik : C.feast) }}>
                      {e.is_sattvic_required ? "Satvik" : "Feast"}
                    </span>
                    <span onClick={() => setEvents(ev => ev.filter((_, j) => j !== i))} style={{ fontSize: 13, color: "#E24B4A", cursor: "pointer" }}>✕</span>
                  </div>
                ))}

                {/* Add event form */}
                {addingEvent && (
                  <div style={{ ...cardStyle, marginTop: 8 }}>
                    <Field label="Event name">
                      <input value={newEvent.event_name} onChange={e => setNewEvent(n => ({ ...n, event_name: e.target.value }))} placeholder="e.g. Bala's Birthday" style={inputStyle} />
                    </Field>
                    <Field label="Date (DD-MM)" hint="Day and month only — e.g. 15-03 for 15th March">
                      <input value={newEvent.event_date} onChange={e => setNewEvent(n => ({ ...n, event_date: e.target.value }))} placeholder="e.g. 15-03" style={inputStyle} />
                    </Field>
                    <Field label="Type">
                      <div style={{ display: "flex", gap: 6 }}>
                        {["Personal", "Social", "Ritual"].map(t => (
                          <Chip key={t} label={t} active={newEvent.event_type === t} onClick={() => setNewEvent(n => ({ ...n, event_type: t }))} />
                        ))}
                      </div>
                    </Field>
                    <Field label="Icon">
                      <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
                        {EVENT_ICONS.map(icon => (
                          <button key={icon} onClick={() => setNewEvent(n => ({ ...n, icon }))}
                            style={{ width: 34, height: 34, borderRadius: 8, fontSize: 18, border: `0.5px solid ${newEvent.icon === icon ? C.teal : C.border}`, background: newEvent.icon === icon ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                            {icon}
                          </button>
                        ))}
                      </div>
                    </Field>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0" }}>
                      <span style={{ fontSize: 13, color: C.text }}>Satvik day</span>
                      <Toggle value={newEvent.is_sattvic_required} onChange={v => setNewEvent(n => ({ ...n, is_sattvic_required: v }))} />
                    </div>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0" }}>
                      <span style={{ fontSize: 13, color: C.text }}>Repeats annually</span>
                      <Toggle value={newEvent.recurring_annual} onChange={v => setNewEvent(n => ({ ...n, recurring_annual: v }))} />
                    </div>
                    <div style={{ display: "flex", gap: 8, marginTop: 10 }}>
                      <button onClick={() => setAddingEvent(false)} style={{ flex: 1, padding: 9, border: `0.5px solid ${C.border}`, borderRadius: 8, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>Cancel</button>
                      <button onClick={() => {
                        if (!newEvent.event_name || !newEvent.event_date) return;
                        setEvents(ev => [...ev, { ...newEvent }]);
                        setNewEvent({ event_name: "", event_date: "", event_type: "Personal", is_sattvic_required: false, recurring_annual: true, icon: "🎂" });
                        setAddingEvent(false);
                      }} style={{ flex: 2, padding: 9, border: "none", borderRadius: 8, fontSize: 12, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>Add event</button>
                    </div>
                  </div>
                )}
              </div>
              {!addingEvent && (
                <div onClick={() => setAddingEvent(true)} style={{ fontSize: 12, color: C.deepTeal, border: `0.5px dashed ${C.teal}`, borderRadius: 8, padding: 8, textAlign: "center", marginTop: 8, cursor: "pointer" }}>
                  + Add an event
                </div>
              )}
              <NavButtons onBack={() => setStep(3)} onSkip={() => setStep(5)} onNext={saveEvents} loading={saving} />
            </div>
          )}

          {/* ── STEP 5: Done ─────────────────────────────────────────────── */}
          {step === 5 && (
            <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
              <div style={{ textAlign: "center", padding: "16px 0 12px" }}>
                <div style={{ fontSize: 36, marginBottom: 8 }}>🎉</div>
                <div style={{ fontSize: 17, fontWeight: 500, color: C.text, marginBottom: 4 }}>You're all set!</div>
                <div style={{ fontSize: 12, color: C.muted, lineHeight: 1.5 }}>Your household is ready. Change any setting anytime from your profile.</div>
              </div>
              <div style={cardStyle}>
                {[
                  ["Member profiles", completedSteps.includes(1) || data?.wizard_status?.members_done],
                  ["Satvik definition", completedSteps.includes(2) || data?.wizard_status?.satvik_done],
                  ["Lunar calendar", !!panchangamId],
                  ["Events & special days", completedSteps.includes(4) || data?.wizard_status?.events_done],
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
                  {saving ? "Setting up..." : "Confirm & go to Dashboard"}
                </button>
                <button onClick={() => setStep(0)} style={{ width: "100%", padding: 10, border: `0.5px solid ${C.border}`, borderRadius: 12, fontSize: 13, color: C.muted, background: "transparent", cursor: "pointer" }}>
                  Review from beginning
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
