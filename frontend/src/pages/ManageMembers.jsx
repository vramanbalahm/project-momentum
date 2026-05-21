import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";
import IngredientSelector, { restrictionsToValue, valueToRestrictions } from "../components/IngredientSelector";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5", deepTeal: "#0F6E56",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0", text: "#2C2C2A", muted: "#888780",
};

const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];
const DIET_IMAGES = {
  "Veg":        "https://cdn-icons-png.flaticon.com/512/2153/2153788.png",
  "Non-Veg":    "https://cdn-icons-png.flaticon.com/512/857/857681.png",
  "Vegan":      "https://cdn-icons-png.flaticon.com/512/2153/2153786.png",
  "Eggitarian": "https://cdn-icons-png.flaticon.com/512/837/837560.png",
};
const AGE_GROUPS = [
  { value: "Child",  emoji: "👶" },
  { value: "Teen",   emoji: "🧒" },
  { value: "Adult",  emoji: "🧑" },
  { value: "Senior", emoji: "👴" },
];
const GENDERS = [
  { value: "Male",              emoji: "👨" },
  { value: "Female",            emoji: "👩" },
  { value: "Transgender",       emoji: "🏳️" },
  { value: "Prefer not to say", emoji: "🤐" },
];

export default function ManageMembers({ onBack }) {
  const { user, apiFetch } = useAuth();
  const { t } = useTranslation();

  const AGE_GROUPS_T = [
    { value: "Child",  label: t("ageGroup.child"),  sub: t("ageGroup.childSub"),  emoji: "👶" },
    { value: "Teen",   label: t("ageGroup.teen"),   sub: t("ageGroup.teenSub"),   emoji: "🧒" },
    { value: "Adult",  label: t("ageGroup.adult"),  sub: t("ageGroup.adultSub"),  emoji: "🧑" },
    { value: "Senior", label: t("ageGroup.senior"), sub: t("ageGroup.seniorSub"), emoji: "👴" },
  ];
  const GENDERS_T = [
    { value: "Male",              label: t("gender.male"),            emoji: "👨" },
    { value: "Female",            label: t("gender.female"),          emoji: "👩" },
    { value: "Transgender",       label: t("gender.transgender"),     emoji: "🏳️" },
    { value: "Prefer not to say", label: t("gender.preferNotToSay"), emoji: "🤐" },
  ];

  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [addForm, setAddForm] = useState({ name: "", email: "", password: "" });
  const [adding, setAdding] = useState(false);
  const [actionLoading, setActionLoading] = useState(null);
  const [editMember, setEditMember]     = useState(null);
  const [editForm, setEditForm]         = useState({});
  const [editSaving, setEditSaving]     = useState(false);
  const [profileLoading, setProfileLoading] = useState(false);
  const [copyFrom, setCopyFrom]             = useState(null);
  const [copyTo, setCopyTo]                 = useState({});
  const [addFormPrefs, setAddFormPrefs]     = useState(null); // copied preferences for new member

  // Copy preferences from an existing member into the add form
  const applyCopyFrom = async (memberId) => {
    setCopyFrom(memberId);
    if (!memberId) return;
    try {
      const profile = await apiFetch(`/auth/my-profile?target_user_id=${memberId}`);
      setAddFormPrefs({
        dietary_preference: profile.dietary_preference || "Veg",
        age_group:          profile.age_group || null,
        gender:             profile.gender || null,
        restrictionValue:   restrictionsToValue(profile.restrictions || []),
      });
    } catch {
      // silently ignore — copy is best-effort
    }
  };

  const loadMembers = async () => {
    try {
      const data = await apiFetch("/auth/members");
      setMembers(data);
    } catch (e) {
      setError(t("manageMembers.loadError"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadMembers(); }, []);

  const handleRoleChange = async (memberId, currentRole) => {
    const newRole = currentRole === "household_admin" ? "household_member" : "household_admin";
    const action = newRole === "household_admin" ? "promote" : "demote";
    if (!confirm(`${action === "promote" ? "Promote" : "Demote"} this member? ${action === "promote" ? "A temporary password will be emailed to them." : ""}`)) return;

    setError(null); setSuccess(null);
    setActionLoading(memberId);
    try {
      const res = await apiFetch("/auth/members/role", {
        method: "PUT",
        body: JSON.stringify({ user_id: memberId, new_role: newRole })
      });
      setSuccess(res.message);
      setTimeout(() => setSuccess(null), 4000);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleToggleActive = async (memberId, currentActive) => {
    const action = currentActive ? "deactivate" : "activate";
    if (!confirm(`${action.charAt(0).toUpperCase() + action.slice(1)} this member?`)) return;

    setError(null); setSuccess(null);
    setActionLoading(memberId);
    try {
      const res = await apiFetch("/auth/members/deactivate", {
        method: "PUT",
        body: JSON.stringify({ user_id: memberId, is_active: !currentActive })
      });
      setSuccess(res.message);
      setTimeout(() => setSuccess(null), 4000);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setActionLoading(null);
    }
  };

  const openEdit = async (m) => {
    setProfileLoading(true);
    setEditMember(m);  // Open sheet with loading state
    try {
      // Load full profile from DB — target_user_id allows admin to view any member
      const profile = await apiFetch(`/auth/my-profile?target_user_id=${m.user_id}`);
      setEditForm({
        user_id:            m.user_id,
        name:               m.name,  // editable by admin
        dietary_preference: profile.dietary_preference || "Veg",
        age_group:          profile.age_group || null,
        gender:             profile.gender || null,
        phone_number:       profile.phone_number || "",
        restrictionValue:   restrictionsToValue(profile.restrictions || []),
      });
    } catch (e) {
      setError(t("manageMembers.loadProfileError"));
      setEditMember(null);
    } finally {
      setProfileLoading(false);
    }
  };

  const handleSaveEdit = async () => {
    setEditSaving(true);
    setError(null);
    try {
      // Save name + phone via PUT /auth/my-profile with target_user_id
      await apiFetch(`/auth/my-profile?target_user_id=${editForm.user_id}`, {
        method: "PUT",
        body: JSON.stringify({
          name:               editForm.name,
          dietary_preference: editForm.dietary_preference || "Veg",
          age_group:          editForm.age_group,
          gender:             editForm.gender,
          phone_number:       editForm.phone_number,
        })
      });
      // Save restrictions separately
      await apiFetch("/auth/my-profile/restrictions", {
        method: "POST",
        body: JSON.stringify({
          target_user_id: editForm.user_id,
          restrictions: valueToRestrictions(editForm.restrictionValue || {}),
        })
      });
      // Reload member list to reflect changes
      await loadMembers();
      setSuccess(`${editForm.name}'s profile updated successfully!`);
      setTimeout(() => setSuccess(null), 5000);
      setEditMember(null);
    } catch (e) {
      setError(e.message || "Save failed. Please try again.");
    } finally {
      setEditSaving(false);
    }
  };

  const handleAddMember = async () => {
    setError(null);
    if (!addForm.name || !addForm.email || !addForm.password) { setError(t("manageMembers.allFieldsRequired")); return; }
    if (addForm.password.length < 8) { setError(t("manageMembers.passwordMin8")); return; }
    setAdding(true);
    try {
      const newMember = await apiFetch("/auth/members/create", {
        method: "POST",
        body: JSON.stringify(addForm)
      });
      // If preferences were copied — save them against the new member
      if (addFormPrefs && newMember?.user_id) {
        await apiFetch(`/auth/my-profile?target_user_id=${newMember.user_id}`, {
          method: "PUT",
          body: JSON.stringify({
            dietary_preference: addFormPrefs.dietary_preference,
            age_group:          addFormPrefs.age_group,
            gender:             addFormPrefs.gender,
          })
        });
        if (addFormPrefs.restrictionValue && Object.keys(addFormPrefs.restrictionValue).length > 0) {
          await apiFetch("/auth/my-profile/restrictions", {
            method: "POST",
            body: JSON.stringify({
              target_user_id: newMember.user_id,
              restrictions: valueToRestrictions(addFormPrefs.restrictionValue),
            })
          });
        }
      }
      setSuccess(`${addForm.name} added successfully!`);
      setTimeout(() => setSuccess(null), 4000);
      setAddForm({ name: "", email: "", password: "" });
      setAddFormPrefs(null);
      setCopyFrom(null);
      setShowAddForm(false);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setAdding(false);
    }
  };

  const inputStyle = { width: "100%", padding: "10px 14px", borderRadius: 10, border: "0.5px solid #EDE8E0", fontSize: 13, color: "#2C2C2A", background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 10 };

  return (
    <div style={{ minHeight: "100vh", background: "#F7F4EE", fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <span onClick={onBack} style={{ color: "#9FE1CB", fontSize: 20, cursor: "pointer" }}>←</span>
            <div>
              <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500 }}>{t("manageMembers.title")}</div>
              <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>{user?.house_name}</div>
            </div>
          </div>
          <button onClick={() => { setShowAddForm(!showAddForm); setError(null); }} style={{ background: "#9FE1CB", color: "#1A3A2E", border: "none", borderRadius: 10, padding: "8px 14px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
            {showAddForm ? t("manageMembers.cancel") : t("manageMembers.addMember")}
          </button>
        </div>
      </div>

      <div style={{ padding: "20px" }}>

        {error && <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>{error}</div>}
        {success && <div style={{ background: "#E1F5EE", border: "0.5px solid #9FE1CB", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#1A3A2E" }}>✅ {success}</div>}

        {/* Add member form */}
        {showAddForm && (
          <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 16, border: "0.5px solid #EDE8E0" }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: "#2C2C2A", marginBottom: 14 }}>{t("manageMembers.newMember")}</div>
            <input type="text" placeholder={t("manageMembers.namePlaceholder")} value={addForm.name} onChange={e => setAddForm(p => ({ ...p, name: e.target.value }))} style={inputStyle} />
            <input type="email" placeholder={t("manageMembers.emailPlaceholder")} value={addForm.email} onChange={e => setAddForm(p => ({ ...p, email: e.target.value }))} style={inputStyle} />
            <input type="password" placeholder={t("manageMembers.passwordPlaceholder")} value={addForm.password} onChange={e => setAddForm(p => ({ ...p, password: e.target.value }))} style={{ ...inputStyle, marginBottom: 14 }} />

            {/* Copy preferences from existing member */}
            {members.length > 0 && (
              <div style={{ marginBottom: 14 }}>
                <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.copyFrom")}</div>
                <select
                  value={copyFrom || ""}
                  onChange={e => applyCopyFrom(e.target.value || null)}
                  style={{ ...inputStyle, marginBottom: 0, appearance: "none", cursor: "pointer" }}
                >
                  <option value="">{t("manageMembers.dontCopy")}</option>
                  {members.map(m => (
                    <option key={m.user_id} value={m.user_id}>{m.name}</option>
                  ))}
                </select>
                {addFormPrefs && (
                  <div style={{ marginTop: 6, fontSize: 11, color: "#0F6E56", background: "#E1F5EE", borderRadius: 8, padding: "6px 10px" }}>
                    ✓ Preferences copied from {members.find(m => m.user_id === copyFrom)?.name} — diet, age, gender and restrictions will be pre-filled
                  </div>
                )}
              </div>
            )}

            <button onClick={handleAddMember} disabled={adding} style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "12px", fontSize: 14, fontWeight: 500, cursor: adding ? "not-allowed" : "pointer", opacity: adding ? 0.7 : 1 }}>
              {adding ? t("manageMembers.adding") : t("manageMembers.addBtn")}
            </button>
          </div>
        )}

        {/* Members list */}
        {loading ? (
          <div style={{ textAlign: "center", color: "#888780", fontSize: 13, padding: 40 }}>{t("manageMembers.loading")}</div>
        ) : (
          members.map(m => {
            const isMe = m.user_id === user?.user_id;
            const isAdmin = m.role === "household_admin";
            const busy = actionLoading === m.user_id;
            return (
              <div key={m.user_id} style={{ background: "#FFF9F2", borderRadius: 16, padding: "16px", marginBottom: 10, border: "0.5px solid #EDE8E0", opacity: m.is_active ? 1 : 0.6 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <div style={{ fontSize: 14, fontWeight: 600, color: "#2C2C2A" }}>
                      {m.name} {isMe && <span style={{ fontSize: 10, color: "#888780" }}>({t("manageMembers.you")})</span>}
                    </div>
                    <div style={{ fontSize: 11, color: "#888780", marginTop: 2 }}>{m.email}</div>
                    <div style={{ display: "flex", gap: 6, marginTop: 8 }}>
                      <span style={{ fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 8, background: isAdmin ? "#E1F5EE" : "#F1EFE8", color: isAdmin ? "#1A3A2E" : "#888780" }}>
                        {isAdmin ? t("manageMembers.admin") : t("manageMembers.member")}
                      </span>
                      <span style={{ fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 8, background: m.is_active ? "#E1F5EE" : "#FAECE7", color: m.is_active ? "#1A3A2E" : "#712B13" }}>
                        {m.is_active ? t("manageMembers.active") : t("manageMembers.inactive")}
                      </span>
                    </div>
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", gap: 6, alignItems: "flex-end" }}>
                    <button
                      onClick={() => openEdit(m)}
                      style={{ fontSize: 11, padding: "5px 10px", borderRadius: 8, border: "0.5px solid #EDE8E0", background: "#E1F5EE", color: "#0F6E56", cursor: "pointer", fontWeight: 500 }}
                    >
                      {t("manageMembers.editProfile")}
                    </button>
                  {!isMe && (
                    <div style={{ display: "flex", flexDirection: "column", gap: 6, alignItems: "flex-end" }}>
                      <button
                        onClick={() => handleRoleChange(m.user_id, m.role)}
                        disabled={busy}
                        style={{ fontSize: 11, padding: "5px 10px", borderRadius: 8, border: "0.5px solid #EDE8E0", background: "transparent", color: "#1A3A2E", cursor: busy ? "not-allowed" : "pointer", fontWeight: 500 }}
                      >
                        {busy ? "..." : isAdmin ? t("manageMembers.demote") : t("manageMembers.promote")}
                      </button>
                      <button
                        onClick={() => handleToggleActive(m.user_id, m.is_active)}
                        disabled={busy}
                        style={{ fontSize: 11, padding: "5px 10px", borderRadius: 8, border: "0.5px solid #EDE8E0", background: "transparent", color: m.is_active ? "#C0392B" : "#1A3A2E", cursor: busy ? "not-allowed" : "pointer", fontWeight: 500 }}
                      >
                        {busy ? "..." : m.is_active ? t("manageMembers.deactivate") : t("manageMembers.activate")}
                      </button>
                    </div>
                  )}
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Member Edit Bottom Sheet */}
      {editMember && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", zIndex: 50, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
          <div style={{ background: C.card, borderRadius: "16px 16px 0 0", padding: 20, width: "100%", maxWidth: 480, maxHeight: "85vh", overflowY: "auto" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
              <div style={{ fontSize: 15, fontWeight: 500, color: C.text }}>{t("manageMembers.editTitle", { name: editMember.name })}</div>
              <span onClick={() => setEditMember(null)} style={{ fontSize: 16, color: C.muted, cursor: "pointer" }}>✕</span>
            </div>

            {profileLoading ? (
              <div style={{ textAlign: "center", padding: "40px 0", fontSize: 13, color: C.muted }}>
                {t("manageMembers.loadingProfile")}
              </div>
            ) : (<>

            {/* Name */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>Full name</div>
            <input
              value={editForm.name || ""}
              onChange={e => setEditForm(f => ({ ...f, name: e.target.value }))}
              placeholder={t("manageMembers.fullNamePlaceholder")}
              style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 14 }}
            />

            {/* Dietary preference */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.dietaryPreference")}</div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 14 }}>
              {DIET_PREFS.map(d => (
                <div key={d} onClick={() => setEditForm(f => ({ ...f, dietary_preference: d }))}
                  style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 5, padding: "8px 6px", borderRadius: 10, border: `0.5px solid ${editForm.dietary_preference === d ? C.teal : C.border}`, background: editForm.dietary_preference === d ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                  <img src={DIET_IMAGES[d]} alt={d} style={{ width: 28, height: 28, objectFit: "contain" }} onError={e => e.target.style.display="none"} />
                  <span style={{ fontSize: 11, fontWeight: 500, color: editForm.dietary_preference === d ? C.deepTeal : C.muted }}>{t(`diet.${d === "Non-Veg" ? "nonVeg" : d === "Eggitarian" ? "eggitarian" : d.toLowerCase()}`)}</span>
                </div>
              ))}
            </div>

            {/* Age group */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.ageGroup")}</div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6, marginBottom: 14 }}>
              {AGE_GROUPS_T.map(ag => (
                <div key={ag.value} onClick={() => setEditForm(f => ({ ...f, age_group: ag.value }))}
                  style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 10px", borderRadius: 10, border: `0.5px solid ${editForm.age_group === ag.value ? C.teal : C.border}`, background: editForm.age_group === ag.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                  <span style={{ fontSize: 20 }}>{ag.emoji}</span>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 500, color: editForm.age_group === ag.value ? C.deepTeal : C.text }}>{ag.label}</div>
                    <div style={{ fontSize: 10, color: C.muted }}>{ag.sub}</div>
                  </div>
                </div>
              ))}
            </div>

            {/* Gender */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.gender")}</div>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 14 }}>
              {GENDERS_T.map(g => (
                <div key={g.value} onClick={() => setEditForm(f => ({ ...f, gender: g.value }))}
                  style={{ display: "flex", alignItems: "center", gap: 6, padding: "6px 10px", borderRadius: 20, border: `0.5px solid ${editForm.gender === g.value ? C.teal : C.border}`, background: editForm.gender === g.value ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                  <span style={{ fontSize: 16 }}>{g.emoji}</span>
                  <span style={{ fontSize: 11, color: editForm.gender === g.value ? C.deepTeal : C.muted }}>{g.label || g.value}</span>
                </div>
              ))}
            </div>

            {/* Phone */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.phoneOptional")}</div>
            <input value={editForm.phone_number || ""} onChange={e => setEditForm(f => ({ ...f, phone_number: e.target.value }))}
              placeholder={t("manageMembers.phonePlaceholder")}
              style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text, background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 14 }} />

            {/* Allergies & dislikes */}
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 6 }}>{t("manageMembers.allergiesDislikes")}</div>
            <IngredientSelector
              mode="restriction"
              value={editForm.restrictionValue || {}}
              onChange={rv => setEditForm(f => ({ ...f, restrictionValue: rv }))}
              showImages={true}
              maxHeight="200px"
            />

            <button onClick={handleSaveEdit} disabled={editSaving}
              style={{ width: "100%", padding: 12, border: "none", borderRadius: 10, fontSize: 13, fontWeight: 500, color: C.green, background: C.mint, cursor: editSaving ? "not-allowed" : "pointer", opacity: editSaving ? 0.7 : 1, marginTop: 14 }}>
              {editSaving ? t("manageMembers.saving") : t("manageMembers.saveProfile")}
            </button>
            </>)}
          </div>
        </div>
      )}
    </div>
  );
}
