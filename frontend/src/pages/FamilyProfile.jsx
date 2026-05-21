import { useState, useEffect, useRef } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";
import i18n from "../i18n/i18n.js";
import IngredientSelector, { restrictionsToValue, valueToRestrictions } from "../components/IngredientSelector";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";
const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggetarian"];

const inputStyle = {
  width: "100%", padding: "10px 14px", borderRadius: 10,
  border: "0.5px solid #EDE8E0", fontSize: 13, color: "#2C2C2A",
  background: "#F1EFE8", outline: "none", boxSizing: "border-box"
};

const selectStyle = { ...inputStyle, cursor: "pointer" };

const Field = ({ label, hint, children }) => (
  <div style={{ marginBottom: 16 }}>
    <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 4 }}>{label}</div>
    {hint && <div style={{ fontSize: 10, color: "#B4B2A9", marginBottom: 5, lineHeight: 1.4 }}>{hint}</div>}
    {children}
  </div>
);

export default function FamilyProfile({ onBack }) {
  const { user, apiFetch } = useAuth();
  const { t } = useTranslation();
  const [form, setForm] = useState({
    house_name: "", dietary_preference: "Veg",
    cuisine_state: "", cuisine_region: "", cuisine_sub_region_id: "",
    city_state: "", current_city: "", preferred_language: "en"
  });
  const [regions, setRegions] = useState([]);
  const [subRegions, setSubRegions] = useState([]);
  const [cities, setCities] = useState([]);
  const [cuisineStates, setCuisineStates] = useState([]);
  const [cityStates, setCityStates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [householdRestrictions, setHouseholdRestrictions] = useState({});

  const set = (k, v) => setForm(prev => ({ ...prev, [k]: v }));

  // Tracks whether the initial pre-fill is complete
  // Prevents cascade useEffects from resetting values during init
  const initialised = useRef(false);

  // Load lookup states on mount
  useEffect(() => {
    const init = async () => {
      try {
        const [cs, cis] = await Promise.all([
          fetch(`${API_BASE}/lookup/city-states`).then(r => r.json()),
          fetch(`${API_BASE}/lookup/cuisine-region-states`).then(r => r.json())
        ]);
        setCityStates(cs);
        setCuisineStates(cis);

        // Load current household profile — pre-fill all fields from /auth/me
        const [me, hRestrictions] = await Promise.all([
          apiFetch("/auth/me"),
          apiFetch("/onboarding/household-restrictions").catch(() => [])
        ]);
        setHouseholdRestrictions(restrictionsToValue(hRestrictions));
        setForm(prev => ({
          ...prev,
          house_name:            me.house_name || "",
          preferred_language:    me.preferred_language || "en",
          dietary_preference:    me.dietary_preference || "Veg",
          // household_allergies removed — handled by IngredientSelector household restrictions
          cuisine_state:         me.cuisine_state || "",
          cuisine_region:        me.cuisine_region || "",
          cuisine_sub_region_id: me.cuisine_sub_region_id ? String(me.cuisine_sub_region_id) : "",
          city_state:            me.city_state || "",
          current_city:          me.current_city || "",
        }));

        // Pre-load regions if cuisine_state is set
        if (me.cuisine_state) {
          const r = await fetch(`${API_BASE}/lookup/cuisine-regions/${encodeURIComponent(me.cuisine_state)}`).then(x => x.json());
          setRegions(r);
        }
        // Pre-load sub-regions if cuisine_region is set
        if (me.cuisine_state && me.cuisine_region) {
          const sr = await fetch(`${API_BASE}/lookup/cuisine-sub-regions/${encodeURIComponent(me.cuisine_state)}/${encodeURIComponent(me.cuisine_region)}`).then(x => x.json());
          setSubRegions(sr);
        }
        // Pre-load cities if city_state is set
        if (me.city_state) {
          const c = await fetch(`${API_BASE}/lookup/cities/${encodeURIComponent(me.city_state)}`).then(x => x.json());
          setCities(c);
        }
      } catch (e) {
        setError(t("familyProfile.loadError"));
      } finally {
        setLoading(false);
        initialised.current = true;  // pre-fill complete — cascade effects can now reset on user change
      }
    };
    init();
  }, []);

  // Load regions when cuisine state changes — skip reset during initial pre-fill
  useEffect(() => {
    if (!form.cuisine_state) { setRegions([]); setSubRegions([]); return; }
    fetch(`${API_BASE}/lookup/cuisine-regions/${encodeURIComponent(form.cuisine_state)}`)
      .then(r => r.json()).then(setRegions);
    if (initialised.current) {
      set("cuisine_region", "");
      set("cuisine_sub_region_id", "");
      setSubRegions([]);
    }
  }, [form.cuisine_state]);

  // Load sub-regions when region changes — skip reset during initial pre-fill
  useEffect(() => {
    if (!form.cuisine_state || !form.cuisine_region) { setSubRegions([]); return; }
    fetch(`${API_BASE}/lookup/cuisine-sub-regions/${encodeURIComponent(form.cuisine_state)}/${encodeURIComponent(form.cuisine_region)}`)
      .then(r => r.json()).then(setSubRegions);
    if (initialised.current) {
      set("cuisine_sub_region_id", "");
    }
  }, [form.cuisine_region]);

  // Load cities when city state changes — skip reset during initial pre-fill
  useEffect(() => {
    if (!form.city_state) { setCities([]); return; }
    fetch(`${API_BASE}/lookup/cities/${encodeURIComponent(form.city_state)}`)
      .then(r => r.json()).then(setCities);
    if (initialised.current) {
      set("current_city", "");
    }
  }, [form.city_state]);

  const handleSave = async () => {
    setError(null); setSuccess(null);
    if (!form.house_name.trim()) { setError(t("familyProfile.nameRequired")); return; }
    setSaving(true);
    try {
      const payload = {
        house_name: form.house_name,
        dietary_preference: form.dietary_preference,
        current_city: form.current_city || undefined,
        // household_allergies removed — handled by /onboarding/household-restrictions
        cuisine_sub_region_id: form.cuisine_sub_region_id ? parseInt(form.cuisine_sub_region_id) : undefined,
        preferred_language: form.preferred_language
      };
      const res = await apiFetch("/auth/profile", { method: "PUT", body: JSON.stringify(payload) });
      // Save household-level restrictions
      await apiFetch("/onboarding/household-restrictions", {
        method: "POST",
        body: JSON.stringify({ restrictions: valueToRestrictions(householdRestrictions) })
      });
      setSuccess(t("familyProfile.savedSuccess"));
      // Apply language change immediately
      i18n.changeLanguage(form.preferred_language);
      localStorage.setItem("momentum_language", form.preferred_language);
      // Navigate to dashboard after short delay
      setTimeout(() => onBack(), 1000);
    } catch (e) {
      setError(e.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) return (
    <div style={{ minHeight: "100vh", background: "#F7F4EE", display: "flex", alignItems: "center", justifyContent: "center" }}>
      <div style={{ color: "#888780", fontSize: 14 }}>{t("familyProfile.loading")}</div>
    </div>
  );

  return (
    <div style={{ minHeight: "100vh", background: "#F7F4EE", fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <span onClick={onBack} style={{ color: "#9FE1CB", fontSize: 20, cursor: "pointer" }}>←</span>
          <div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500 }}>{t("familyProfile.title")}</div>
            <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>Admin — {user?.house_name}</div>
          </div>
        </div>
      </div>

      <div style={{ padding: "20px 20px 100px" }}>

        {error && <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>{error}</div>}
        {success && <div style={{ background: "#E1F5EE", border: "0.5px solid #9FE1CB", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#1A3A2E" }}>✅ {success}</div>}

        {/* Basic info */}
        <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 12 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "#B4B2A9", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>{t("familyProfile.household")}</div>

          <Field label={t("familyProfile.householdName")}>
            <input type="text" value={form.house_name} onChange={e => set("house_name", e.target.value)} style={inputStyle} />
          </Field>

          <Field label={t("familyProfile.dietaryPreference")}>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
              {DIET_PREFS.map(d => (
                <button key={d} onClick={() => set("dietary_preference", d)} style={{
                  padding: "7px 12px", borderRadius: 8, fontSize: 12, fontWeight: 500, cursor: "pointer",
                  background: form.dietary_preference === d ? "#1A3A2E" : "transparent",
                  color: form.dietary_preference === d ? "#9FE1CB" : "#888780",
                  border: form.dietary_preference === d ? "none" : "0.5px solid #EDE8E0"
                }}>{t(`diet.${d === "Non-Veg" ? "nonVeg" : d === "Eggetarian" ? "eggitarian" : d.toLowerCase()}`)}</button>
              ))}
            </div>
          </Field>


        </div>

        {/* Cuisine region */}
        <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 12 }}>
          {/* ── Preferred language ── */}
          <div style={{ background: "#FFF9F2", borderRadius: 14, padding: "16px", border: "0.5px solid #EDE8E0", marginBottom: 16 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: "#B4B2A9", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8 }}>{t("familyProfile.preferredLanguage")}</div>
            <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 12 }}>{t("familyProfile.languageHint")}</div>
            <div style={{ display: "flex", gap: 8 }}>
              {[{ value: "en", label: t("familyProfile.english") }, { value: "ta", label: t("familyProfile.tamil") }].map(lang => (
                <div key={lang.value} onClick={() => set("preferred_language", lang.value)}
                  style={{ flex: 1, padding: "10px 8px", borderRadius: 10, textAlign: "center", cursor: "pointer",
                    border: `0.5px solid ${form.preferred_language === lang.value ? "#5DCAA5" : "#EDE8E0"}`,
                    background: form.preferred_language === lang.value ? "#E1F5EE" : "transparent" }}>
                  <div style={{ fontSize: 13, fontWeight: 500, color: form.preferred_language === lang.value ? "#0F6E56" : "#2C2C2A" }}>{lang.label}</div>
                </div>
              ))}
            </div>
          </div>

          <div style={{ fontSize: 12, fontWeight: 600, color: "#B4B2A9", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>{t("familyProfile.homeCuisine")}</div>
          <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 14, lineHeight: 1.5 }}>
            {t("familyProfile.cuisineHint")}
          </div>

          <Field label={t("familyProfile.state")}>
            <select value={form.cuisine_state} onChange={e => set("cuisine_state", e.target.value)} style={selectStyle}>
              <option value="">{t("familyProfile.selectState")}</option>
              {cuisineStates.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </Field>

          {regions.length > 0 && (
            <Field label={t("familyProfile.region")}>
              <select value={form.cuisine_region} onChange={e => set("cuisine_region", e.target.value)} style={selectStyle}>
                <option value="">{t("familyProfile.selectRegion")}</option>
                {regions.map(r => <option key={r} value={r}>{r}</option>)}
              </select>
            </Field>
          )}

          {subRegions.length > 0 && (
            <Field label={t("familyProfile.subRegion")}>
              <select value={form.cuisine_sub_region_id} onChange={e => set("cuisine_sub_region_id", e.target.value)} style={selectStyle}>
                <option value="">{t("familyProfile.selectSubRegion")}</option>
                {subRegions.map(sr => <option key={sr.id} value={sr.id}>{sr.sub_region}</option>)}
              </select>
            </Field>
          )}
        </div>

        {/* Current city */}
        <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 20 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "#B4B2A9", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>{t("familyProfile.currentLocation")}</div>
          <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 14, lineHeight: 1.5 }}>
            {t("familyProfile.locationHint")}
          </div>

          <Field label={t("familyProfile.state")}>
            <select value={form.city_state} onChange={e => set("city_state", e.target.value)} style={selectStyle}>
              <option value="">{t("familyProfile.selectState")}</option>
              {cityStates.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </Field>

          {cities.length > 0 && (
            <Field label={t("familyProfile.cityTown")}>
              <select value={form.current_city} onChange={e => set("current_city", e.target.value)} style={selectStyle}>
                <option value="">{t("familyProfile.selectCity")}</option>
                {cities.map(c => <option key={c.id} value={c.display_name}>{c.display_name}</option>)}
              </select>
            </Field>
          )}
        </div>

        {/* Family-level restrictions */}
        <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 100 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "#B4B2A9", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 6 }}>{t("familyProfile.familyRestrictions")}</div>
          <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 14, lineHeight: 1.5 }}>
            {t("familyProfile.restrictionsHint")}
          </div>
          <IngredientSelector
            mode="restriction"
            value={householdRestrictions}
            onChange={setHouseholdRestrictions}
            showImages={true}
            maxHeight="250px"
          />
        </div>

      </div>

      {/* Save button — fixed bottom, constrained to container maxWidth */}
      <div style={{ position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)", width: "100%", maxWidth: 480, background: "#FFF9F2", padding: "16px 20px 32px", borderTop: "0.5px solid #EDE8E0", boxSizing: "border-box" }}>
        <button onClick={handleSave} disabled={saving} style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 14, padding: "14px", fontSize: 15, fontWeight: 500, cursor: saving ? "not-allowed" : "pointer", opacity: saving ? 0.7 : 1 }}>
          {saving ? t("familyProfile.saving") : t("familyProfile.saveChanges")}
        </button>
      </div>
    </div>
  );
}
