import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import IngredientSelector, { restrictionsToValue, valueToRestrictions } from "../components/IngredientSelector";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5", deepTeal: "#0F6E56",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0", text: "#2C2C2A",
  muted: "#888780", error: "#FAECE7", errorText: "#712B13",
};

const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];
const DIET_IMAGES = {
  "Veg":        "https://cdn-icons-png.flaticon.com/512/2153/2153788.png",
  "Non-Veg":    "https://cdn-icons-png.flaticon.com/512/857/857681.png",
  "Vegan":      "https://cdn-icons-png.flaticon.com/512/2153/2153786.png",
  "Eggitarian": "https://cdn-icons-png.flaticon.com/512/837/837560.png",
};
const AGE_GROUPS = [
  { value: "Child",  label: "Child",  sub: "0–12 yrs",  emoji: "👶" },
  { value: "Teen",   label: "Teen",   sub: "13–17 yrs", emoji: "🧒" },
  { value: "Adult",  label: "Adult",  sub: "18–59 yrs", emoji: "🧑" },
  { value: "Senior", label: "Senior", sub: "60+ yrs",   emoji: "👴" },
];
const GENDERS = [
  { value: "Male",              emoji: "👨" },
  { value: "Female",            emoji: "👩" },
  { value: "Transgender",       emoji: "🏳️" },
  { value: "Prefer not to say", emoji: "🤐" },
];

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

export default function MyProfile({ onBack }) {
  const { apiFetch } = useAuth();
  const [profile, setProfile]   = useState(null);
  const [loading, setLoading]   = useState(true);
  const [saving, setSaving]     = useState(false);
  const [error, setError]       = useState(null);
  const [success, setSuccess]   = useState(false);
  const [form, setForm]         = useState({
    dietary_preference: null,
    age_group:          null,
    gender:             null,
    phone_number:       "",
  });
  const [restrictionValue, setRestrictionValue] = useState({});

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  useEffect(() => {
    (async () => {
      try {
        const p = await apiFetch("/auth/my-profile");
        setProfile(p);
        setForm({
          dietary_preference: p.dietary_preference,
          age_group:          p.age_group,
          gender:             p.gender,
          phone_number:       p.phone_number || "",
        });
        setRestrictionValue(restrictionsToValue(p.restrictions || []));
      } catch (e) { setError("Failed to load profile."); }
      finally { setLoading(false); }
    })();
  }, []);

  const handleSave = async () => {
    setSaving(true); setError(null); setSuccess(false);
    try {
      // Save profile fields
      await apiFetch("/auth/my-profile", {
        method: "PUT",
        body: JSON.stringify(form),
      });
      // Save restrictions via onboarding endpoint
      await apiFetch("/onboarding/members", {
        method: "POST",
        body: JSON.stringify({
          members: [{
            user_id:            profile.user_id,
            dietary_preference: form.dietary_preference || "Veg",
            age_group:          form.age_group,
            gender:             form.gender,
            phone_number:       form.phone_number,
            restrictions:       valueToRestrictions(restrictionValue)
          }]
        }),
      });
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (e) { setError(e.message); }
    finally { setSaving(false); }
  };

  const inputStyle = { width: "100%", padding: "9px 12px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box" };

  if (loading) return (
    <div style={{ minHeight: "100vh", background: C.bg, display: "flex", alignItems: "center", justifyContent: "center" }}>
      <div style={{ fontSize: 14, color: C.muted }}>Loading your profile...</div>
    </div>
  );

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
          <span onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</span>
          <div style={{ fontSize: 17, fontWeight: 500, color: "#FDFCF8" }}>My Profile</div>
        </div>
        {/* Avatar */}
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{ width: 56, height: 56, borderRadius: "50%", background: C.mint, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, fontWeight: 500, color: C.green }}>
            {(profile?.name || "U")[0].toUpperCase()}
          </div>
          <div>
            <div style={{ fontSize: 17, fontWeight: 500, color: "#FDFCF8" }}>{profile?.name}</div>
            <div style={{ fontSize: 12, color: "#5DCAA5", marginTop: 2 }}>{profile?.email || "No email set"}</div>
            <div style={{ fontSize: 11, color: "#5DCAA5", marginTop: 1, textTransform: "uppercase", letterSpacing: "0.04em" }}>{profile?.role?.replace("_", " ")}</div>
          </div>
        </div>
      </div>

      <div style={{ padding: "16px 16px 100px" }}>

        {error && (
          <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: C.errorText }}>
            {error}
          </div>
        )}
        {success && (
          <div style={{ background: "#E1F5EE", border: `0.5px solid ${C.teal}`, borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: C.deepTeal }}>
            ✓ Profile saved successfully
          </div>
        )}

        {/* ── Personal details ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Personal details</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>Full name</div>
            <div style={{ fontSize: 14, color: C.text, padding: "9px 12px", background: "#F1EFE8", borderRadius: 8, border: `0.5px solid ${C.border}` }}>{profile?.name}</div>
            <div style={{ fontSize: 10, color: C.muted, marginTop: 3 }}>Contact your admin to change your name</div>
          </div>
          <div style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>Email address</div>
            <div style={{ fontSize: 14, color: C.muted, padding: "9px 12px", background: "#F1EFE8", borderRadius: 8, border: `0.5px solid ${C.border}` }}>{profile?.email || "—"}</div>
            <div style={{ fontSize: 10, color: C.muted, marginTop: 3 }}>Email cannot be changed</div>
          </div>
          <div>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>Phone number <span style={{ color: "#B4B2A9" }}>(optional)</span></div>
            <input value={form.phone_number} onChange={e => set("phone_number", e.target.value)} placeholder="e.g. 98765 43210" style={inputStyle} />
          </div>
        </div>

        {/* ── Dietary preference ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Dietary preference</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            {DIET_PREFS.map(d => (
              <div key={d} onClick={() => set("dietary_preference", d)}
                style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6, padding: "10px 8px", borderRadius: 12, border: `0.5px solid ${form.dietary_preference === d ? C.teal : C.border}`, background: form.dietary_preference === d ? "#E1F5EE" : "transparent", cursor: "pointer", transition: "all 0.15s" }}>
                <img src={DIET_IMAGES[d]} alt={d} style={{ width: 32, height: 32, objectFit: "contain" }} onError={e => e.target.style.display = "none"} />
                <span style={{ fontSize: 12, fontWeight: 500, color: form.dietary_preference === d ? C.deepTeal : C.muted }}>{d}</span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Age group ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Age group</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            {AGE_GROUPS.map(ag => (
              <div key={ag.value} onClick={() => set("age_group", ag.value)}
                style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 12px", borderRadius: 12, border: `0.5px solid ${form.age_group === ag.value ? C.teal : C.border}`, background: form.age_group === ag.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                <span style={{ fontSize: 24 }}>{ag.emoji}</span>
                <div>
                  <div style={{ fontSize: 13, fontWeight: 500, color: form.age_group === ag.value ? C.deepTeal : C.text }}>{ag.label}</div>
                  <div style={{ fontSize: 10, color: C.muted }}>{ag.sub}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Gender ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Gender</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {GENDERS.map(g => (
              <div key={g.value} onClick={() => set("gender", g.value)}
                style={{ display: "flex", alignItems: "center", gap: 6, padding: "8px 12px", borderRadius: 20, border: `0.5px solid ${form.gender === g.value ? C.teal : C.border}`, background: form.gender === g.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                <span style={{ fontSize: 18 }}>{g.emoji}</span>
                <span style={{ fontSize: 12, color: form.gender === g.value ? C.deepTeal : C.muted }}>{g.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Allergies & dislikes ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>Allergies & dislikes</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>
            Tap <strong style={{color:"#E24B4A"}}>🚫 Allergy</strong> for medical restrictions · <strong style={{color:"#BA7517"}}>😕 Dislike</strong> for preferences
          </div>
          <IngredientSelector
            mode="restriction"
            value={restrictionValue}
            onChange={setRestrictionValue}
            showImages={true}
            maxHeight="320px"
          />
        </div>
      </div>

      {/* Fixed save button */}
      <div style={{ position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)", width: "100%", maxWidth: 480, background: C.card, padding: "14px 16px 28px", borderTop: `0.5px solid ${C.border}`, boxSizing: "border-box" }}>
        <button onClick={handleSave} disabled={saving} style={{ width: "100%", padding: 13, border: "none", borderRadius: 12, fontSize: 14, fontWeight: 500, color: C.green, background: C.mint, cursor: saving ? "not-allowed" : "pointer", opacity: saving ? 0.7 : 1 }}>
          {saving ? "Saving..." : "Save profile"}
        </button>
      </div>
    </div>
  );
}
