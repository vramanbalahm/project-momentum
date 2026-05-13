// householdShared.jsx
// Shared constants and micro-components used by:
//   - OnboardingWizard.jsx
//   - SatvikEditor.jsx, LunarEditor.jsx, EventEditor.jsx
//   - HouseholdSettings.jsx

export const C = {
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

export const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];

export const AGE_GROUPS = [
  { value: "Child",  label: "Child",  sub: "0–12 yrs",  emoji: "👶" },
  { value: "Teen",   label: "Teen",   sub: "13–17 yrs", emoji: "🧒" },
  { value: "Adult",  label: "Adult",  sub: "18–59 yrs", emoji: "🧑" },
  { value: "Senior", label: "Senior", sub: "60+ yrs",   emoji: "👴" },
];

export const GENDERS = [
  { value: "Male",               emoji: "👨" },
  { value: "Female",             emoji: "👩" },
  { value: "Transgender",        emoji: "🏳️" },
  { value: "Prefer not to say",  emoji: "🤐" },
];

export const DIET_IMAGES = {
  "Veg":        "https://cdn-icons-png.flaticon.com/512/2153/2153788.png",
  "Non-Veg":    "https://cdn-icons-png.flaticon.com/512/857/857681.png",
  "Vegan":      "https://cdn-icons-png.flaticon.com/512/2153/2153786.png",
  "Eggitarian": "https://cdn-icons-png.flaticon.com/512/837/837560.png",
};

export const EVENT_ICONS = [
  "🎂", "🎉", "🎊", "💍", "🙏", "⭐", "🌸", "🕉️",
  "👶", "🎓", "🏠", "❤️", "🌙", "🔔", "🪔", "🌺"
];

export const Field = ({ label, hint, children }) => (
  <div style={{ marginBottom: 14 }}>
    <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, marginBottom: 3 }}>{label}</div>
    {hint && <div style={{ fontSize: 10, color: "#B4B2A9", marginBottom: 5, lineHeight: 1.4 }}>{hint}</div>}
    {children}
  </div>
);

export const HelpTip = ({ text, visible, onToggle }) => (
  <span style={{ display: "inline-flex", marginLeft: 4 }}>
    <span onClick={onToggle} style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 16, height: 16, borderRadius: "50%", border: `0.5px solid ${C.border}`, fontSize: 10, color: C.muted, cursor: "pointer" }}>?</span>
    {visible && (
      <div style={{ position: "absolute", zIndex: 20, background: C.card, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 10px", fontSize: 11, color: C.muted, lineHeight: 1.5, maxWidth: 240, marginTop: 20, boxShadow: "0 4px 16px rgba(0,0,0,0.08)" }}>
        {text}
      </div>
    )}
  </span>
);

export const Toggle = ({ value, onChange }) => (
  <div onClick={() => onChange(!value)} style={{ width: 30, height: 17, borderRadius: 9, background: value ? C.teal : C.border, position: "relative", cursor: "pointer", flexShrink: 0, transition: "background 0.2s" }}>
    <div style={{ width: 13, height: 13, borderRadius: "50%", background: "white", position: "absolute", top: 2, left: value ? 15 : 2, transition: "left 0.2s" }} />
  </div>
);

export const Chip = ({ label, active, onClick }) => (
  <button onClick={onClick} style={{ padding: "7px 10px", borderRadius: 8, fontSize: 12, fontWeight: 500, cursor: "pointer", background: active ? C.green : "transparent", color: active ? C.mint : C.muted, border: active ? "none" : `0.5px solid ${C.border}`, transition: "all 0.15s" }}>
    {label}
  </button>
);

export const Avatar = ({ name, bg = "#E1F5EE", color = C.deepTeal }) => (
  <div style={{ width: 32, height: 32, borderRadius: "50%", background: bg, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, fontWeight: 500, color, flexShrink: 0 }}>
    {(name || "?")[0].toUpperCase()}
  </div>
);

export const NavButtons = ({ onBack, onNext, onSkip, nextLabel = "Save & continue", loading }) => (
  <div style={{ display: "flex", gap: 8, marginTop: "auto", paddingTop: 12 }}>
    {onBack && <button onClick={onBack} style={{ flex: 1, padding: 10, border: `0.5px solid ${C.border}`, borderRadius: 10, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>Back</button>}
    {onSkip && <button onClick={onSkip} style={{ flex: 1, padding: 10, border: `0.5px dashed ${C.border}`, borderRadius: 10, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>Skip</button>}
    <button onClick={onNext} disabled={loading} style={{ flex: 2, padding: 10, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1 }}>
      {loading ? "Saving..." : nextLabel}
    </button>
  </div>
);
