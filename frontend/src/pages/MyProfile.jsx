import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";
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
  { value: "Child",  label: t("ageGroup.child"),  sub: t("ageGroup.childSub"),  emoji: "👶" },
  { value: "Teen",   label: t("ageGroup.teen"),   sub: t("ageGroup.teenSub"),   emoji: "🧒" },
  { value: "Adult",  label: t("ageGroup.adult"),  sub: t("ageGroup.adultSub"),  emoji: "🧑" },
  { value: "Senior", label: t("ageGroup.senior"), sub: t("ageGroup.seniorSub"), emoji: "👴" },
];
const GENDERS = [
  { value: "Male",              label: t("gender.male"),            emoji: "👨" },
  { value: "Female",            label: t("gender.female"),          emoji: "👩" },
  { value: "Transgender",       label: t("gender.transgender"),     emoji: "🏳️" },
  { value: "Prefer not to say", label: t("gender.preferNotToSay"), emoji: "🤐" },
];

export default function MyProfile({ onBack }) {
  const { user, apiFetch } = useAuth();
  const { t } = useTranslation();
  const isAdmin = user?.role === "household_admin" || user?.role === "platform_admin";
  const [profile, setProfile]           = useState(null);
  const [loading, setLoading]           = useState(true);
  const [saving, setSaving]             = useState(false);
  const [error, setError]               = useState(null);
  const [successMsg, setSuccessMsg]     = useState(null);
  const [dietPref, setDietPref]         = useState("Veg");
  const [ageGroup, setAgeGroup]         = useState(null);
  const [gender, setGender]             = useState(null);
  const [phone, setPhone]               = useState("");
  const [restrictionValue, setRestrictionValue] = useState({});
  const [editName, setEditName]         = useState("");
  // Add member sheet — admin only
  const [showAddMember, setShowAddMember] = useState(false);
  const [addForm, setAddForm]           = useState({ name: "", email: "", password: "" });
  const [addSaving, setAddSaving]       = useState(false);

  // Load profile on mount
  useEffect(() => {
    (async () => {
      try {
        const p = await apiFetch("/auth/my-profile");
        setProfile(p);
        setEditName(p.name || "");
        setDietPref(p.dietary_preference || "Veg");
        setAgeGroup(p.age_group || null);
        setGender(p.gender || null);
        setPhone(p.phone_number || "");
        setRestrictionValue(restrictionsToValue(p.restrictions || []));
      } catch (e) {
        setError(t("myProfile.loadingError"));
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const handleAddMember = async () => {
    if (!addForm.name.trim() || !addForm.password) { setError(t("myProfile.addMemberSheet.namePasswordRequired")); return; }
    setAddSaving(true);
    setError(null);
    try {
      await apiFetch("/auth/members/create", {
        method: "POST",
        body: JSON.stringify({
          name:     addForm.name.trim(),
          email:    addForm.email.trim() || null,
          password: addForm.password,
        }),
      });
      setShowAddMember(false);
      setAddForm({ name: "", email: "", password: "" });
      showSuccess(`✓ ${addForm.name.trim()} added successfully!`);
    } catch (e) {
      setError(e.message || "Failed to add member.");
    } finally {
      setAddSaving(false);
    }
  };

  const showSuccess = (msg) => {
    setSuccessMsg(msg);
    setTimeout(() => setSuccessMsg(null), 5000);
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setSuccessMsg(null);
    try {
      // Step 1: Save name (if admin), dietary preference, age group, gender, phone
      await apiFetch("/auth/my-profile", {
        method: "PUT",
        body: JSON.stringify({
          name:               editName.trim() || undefined,
          dietary_preference: dietPref,
          age_group:          ageGroup,
          gender:             gender,
          phone_number:       phone,
        }),
      });

      // Step 2: Save restrictions via dedicated self-restrictions endpoint
      const restrictions = valueToRestrictions(restrictionValue);
      await apiFetch("/auth/my-profile/restrictions", {
        method: "POST",
        body: JSON.stringify({ restrictions }),
      });

      // Step 3: Reload profile from DB to confirm what was saved
      const updated = await apiFetch("/auth/my-profile");
      setProfile(updated);
      setDietPref(updated.dietary_preference || "Veg");
      setAgeGroup(updated.age_group || null);
      setGender(updated.gender || null);
      setPhone(updated.phone_number || "");
      setRestrictionValue(restrictionsToValue(updated.restrictions || []));

      showSuccess("✓ Profile saved successfully!");
      window.scrollTo({ top: 0, behavior: "smooth" });
    } catch (e) {
      setError(e.message || t("myProfile.saveError"));
    } finally {
      setSaving(false);
    }
  };

  const inputStyle = {
    width: "100%", padding: "9px 12px", borderRadius: 8,
    border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text,
    background: "#F1EFE8", outline: "none", boxSizing: "border-box",
  };

  // Restriction summary counts
  const allergyCount = Object.values(restrictionValue).filter(v => v.allergy).length;
  const dislikeCount = Object.values(restrictionValue).filter(v => v.dislike).length;

  if (loading) return (
    <div style={{ minHeight: "100vh", background: C.bg, display: "flex", alignItems: "center", justifyContent: "center" }}>
      <div style={{ fontSize: 14, color: C.muted }}>{t("myProfile.loading")}</div>
    </div>
  );

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
          <span onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</span>
          <div style={{ fontSize: 17, fontWeight: 500, color: "#FDFCF8" }}>{t("myProfile.title")}</div>
          {isAdmin && (
            <button
              onClick={() => { setShowAddMember(true); setAddForm({ name: "", email: "", password: "" }); }}
              style={{ marginLeft: "auto", background: C.mint, color: C.green, border: "none", borderRadius: 10, padding: "7px 12px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}
            >{t("myProfile.addMember")}</button>
          )}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{ width: 56, height: 56, borderRadius: "50%", background: C.mint, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, fontWeight: 500, color: C.green }}>
            {(profile?.name || "U")[0].toUpperCase()}
          </div>
          <div>
            <div style={{ fontSize: 17, fontWeight: 500, color: "#FDFCF8" }}>{profile?.name}</div>
            <div style={{ fontSize: 12, color: "#5DCAA5", marginTop: 2 }}>{profile?.email || t("myProfile.noEmail")}</div>
            <div style={{ fontSize: 11, color: "#5DCAA5", marginTop: 1, textTransform: "uppercase", letterSpacing: "0.04em" }}>
              {(profile?.role || "").replace(/_/g, " ")}
            </div>
          </div>
        </div>
      </div>

      <div style={{ padding: "16px 16px 100px" }}>

        {/* Success message — fixed at top, prominent */}
        {successMsg && (
          <div style={{ background: "#1D9E75", borderRadius: 10, padding: "14px 16px", marginBottom: 16, fontSize: 14, color: "white", fontWeight: 500, display: "flex", alignItems: "center", gap: 10, boxShadow: "0 4px 12px rgba(29,158,117,0.3)" }}>
            <span style={{ fontSize: 20 }}>✓</span>
            <span>{successMsg}</span>
          </div>
        )}

        {error && (
          <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 10, padding: "12px 14px", marginBottom: 14, fontSize: 13, color: C.errorText }}>
            {error}
          </div>
        )}

        {/* ── Personal details ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>{t("myProfile.personalDetails")}</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>Full name</div>
            {isAdmin ? (
              <input
                value={editName}
                onChange={e => setEditName(e.target.value)}
                placeholder=t("myProfile.fullName")
                style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 14, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box" }}
              />
            ) : (
              <>
                <div style={{ fontSize: 14, color: C.text, padding: "9px 12px", background: "#F1EFE8", borderRadius: 8, border: `0.5px solid ${C.border}` }}>{profile?.name}</div>
                <div style={{ fontSize: 10, color: C.muted, marginTop: 3 }}>{t("myProfile.nameChangeHint")}</div>
              </>
            )}
          </div>
          <div style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>{t("myProfile.emailAddress")}</div>
            <div style={{ fontSize: 14, color: C.muted, padding: "9px 12px", background: "#F1EFE8", borderRadius: 8, border: `0.5px solid ${C.border}` }}>{profile?.email || "—"}</div>
            <div style={{ fontSize: 10, color: C.muted, marginTop: 3 }}>{t("myProfile.emailChangeHint")}</div>
          </div>
          <div>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 4 }}>{t("myProfile.phoneNumber")} <span style={{ color: "#B4B2A9" }}>({t("myProfile.phoneOptional")})</span></div>
            <input value={phone} onChange={e => setPhone(e.target.value)} placeholder="e.g. 98765 43210" style={inputStyle} />
          </div>
        </div>

        {/* ── Dietary preference ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>{t("myProfile.dietaryPreference")}</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            {DIET_PREFS.map(d => (
              <div key={d} onClick={() => setDietPref(d)}
                style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6, padding: "10px 8px", borderRadius: 12, border: `0.5px solid ${dietPref === d ? C.teal : C.border}`, background: dietPref === d ? "#E1F5EE" : "transparent", cursor: "pointer", transition: "all 0.15s" }}>
                <img src={DIET_IMAGES[d]} alt={d} style={{ width: 32, height: 32, objectFit: "contain" }} onError={e => e.target.style.display = "none"} />
                <span style={{ fontSize: 12, fontWeight: 500, color: dietPref === d ? C.deepTeal : C.muted }}>{t(`diet.${d === "Non-Veg" ? "nonVeg" : d === "Eggitarian" ? "eggitarian" : d.toLowerCase()}`)}</span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Age group ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>{t("myProfile.ageGroup")}</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            {AGE_GROUPS.map(ag => (
              <div key={ag.value} onClick={() => setAgeGroup(ageGroup === ag.value ? null : ag.value)}
                style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 12px", borderRadius: 12, border: `0.5px solid ${ageGroup === ag.value ? C.teal : C.border}`, background: ageGroup === ag.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                <span style={{ fontSize: 24 }}>{ag.emoji}</span>
                <div>
                  <div style={{ fontSize: 13, fontWeight: 500, color: ageGroup === ag.value ? C.deepTeal : C.text }}>{ag.label}</div>
                  <div style={{ fontSize: 10, color: C.muted }}>{ag.sub}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Gender ── */}
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>{t("myProfile.gender")}</div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {GENDERS.map(g => (
              <div key={g.value} onClick={() => setGender(gender === g.value ? null : g.value)}
                style={{ display: "flex", alignItems: "center", gap: 6, padding: "8px 12px", borderRadius: 20, border: `0.5px solid ${gender === g.value ? C.teal : C.border}`, background: gender === g.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                <span style={{ fontSize: 18 }}>{g.emoji}</span>
                <span style={{ fontSize: 12, color: gender === g.value ? C.deepTeal : C.muted }}>{g.label || g.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Allergies & dislikes — summary at top ── */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
          <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em" }}>{t("myProfile.allergiesDislikes")}</div>
          <div style={{ display: "flex", gap: 8 }}>
            {allergyCount > 0 && (
              <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 20, background: "#FAECE7", color: "#712B13", fontWeight: 500 }}>
                🚫 {allergyCount} {allergyCount === 1 ? t("myProfile.allergy") : t("myProfile.allergies")}
              </span>
            )}
            {dislikeCount > 0 && (
              <span style={{ fontSize: 11, padding: "2px 8px", borderRadius: 20, background: "#FAEEDA", color: "#633806", fontWeight: 500 }}>
                😕 {dislikeCount} {dislikeCount === 1 ? t("myProfile.dislike") : t("myProfile.dislikes")}
              </span>
            )}
          </div>
        </div>
        <div style={{ background: C.card, border: `0.5px solid ${C.border}`, borderRadius: 14, padding: "14px 16px", marginBottom: 14 }}>
          <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>
            Tap <strong style={{ color: "#E24B4A" }}>🚫 Allergy</strong> for medical restrictions ·
            <strong style={{ color: "#BA7517" }}> 😕 Dislike</strong> for preferences
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
      <div style={{ position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)", width: "100%", maxWidth: 480, background: C.card, padding: "14px 16px 28px", borderTop: `0.5px solid ${C.border}`, boxSizing: "border-box", zIndex: 10 }}>
        <button onClick={handleSave} disabled={saving}
          style={{ width: "100%", padding: 13, border: "none", borderRadius: 12, fontSize: 14, fontWeight: 500, color: C.green, background: C.mint, cursor: saving ? "not-allowed" : "pointer", opacity: saving ? 0.7 : 1 }}>
          {saving ? t("myProfile.saving") : t("myProfile.saveProfile")}
        </button>
      </div>

      {/* Add Member bottom sheet — admin only */}
      {showAddMember && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 100, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
          <div style={{ background: C.card, borderRadius: "20px 20px 0 0", padding: "24px 20px 40px", width: "100%", maxWidth: 480, boxSizing: "border-box" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
              <div style={{ fontSize: 15, fontWeight: 600, color: C.text }}>{t("myProfile.addMemberSheet.title")}</div>
              <span onClick={() => setShowAddMember(false)} style={{ fontSize: 18, color: C.muted, cursor: "pointer" }}>✕</span>
            </div>
            <input type="text" placeholder="Full name *" value={addForm.name}
              onChange={e => setAddForm(f => ({ ...f, name: e.target.value }))}
              style={{ width: "100%", padding: "10px 14px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 10 }} />
            <input type="email" placeholder="Email address (optional)" value={addForm.email}
              onChange={e => setAddForm(f => ({ ...f, email: e.target.value }))}
              style={{ width: "100%", padding: "10px 14px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 10 }} />
            <input type="password" placeholder="Temporary password *" value={addForm.password}
              onChange={e => setAddForm(f => ({ ...f, password: e.target.value }))}
              style={{ width: "100%", padding: "10px 14px", borderRadius: 10, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 16 }} />
            <button onClick={handleAddMember} disabled={addSaving}
              style={{ width: "100%", padding: 13, border: "none", borderRadius: 12, fontSize: 14, fontWeight: 500, color: C.green, background: C.mint, cursor: addSaving ? "not-allowed" : "pointer", opacity: addSaving ? 0.7 : 1 }}>
              {addSaving ? t("myProfile.addMemberSheet.adding") : t("myProfile.addMemberSheet.addBtn")}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
