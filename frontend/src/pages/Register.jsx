import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import OtpVerify from "./OtpVerify";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

// All 4 dietary preferences — matches diet_pref enum in DB
const DIET_PREFS = ["Veg", "Non-Veg", "Vegan", "Eggitarian"];

// Moved outside Register to prevent re-mount on every keystroke (focus-loss fix)
const Field = ({ label, hint, children }) => (
  <div style={{ marginBottom: 14 }}>
    <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 4 }}>{label}</div>
    {hint && <div style={{ fontSize: 10, color: "#B4B2A9", marginBottom: 5, lineHeight: 1.4 }}>{hint}</div>}
    {children}
  </div>
);

export default function Register({ onSwitchToLogin }) {
  const { register } = useAuth();

  const [form, setForm] = useState({
    name: "", email: "", password: "", confirmPassword: "",
    house_name: "", dietary_preference: "Veg", household_allergies: "",
    cuisine_state: "", cuisine_region: "", cuisine_sub_region_id: "",
    city_state: "", current_city: ""
  });

  // Lookup data
  const [cuisineStates, setCuisineStates]   = useState([]);
  const [regions, setRegions]               = useState([]);
  const [subRegions, setSubRegions]         = useState([]);
  const [cityStates, setCityStates]         = useState([]);
  const [cities, setCities]                 = useState([]);

  const [error, setError]     = useState(null);
  const [loading, setLoading] = useState(false);
  const [otpStep, setOtpStep] = useState(false);

  const set = (k, v) => setForm(prev => ({ ...prev, [k]: v }));

  // Load cuisine states and city states on mount
  useEffect(() => {
    Promise.all([
      fetch(`${API_BASE}/lookup/cuisine-region-states`).then(r => r.json()),
      fetch(`${API_BASE}/lookup/city-states`).then(r => r.json())
    ]).then(([cs, cis]) => {
      setCuisineStates(cs);
      setCityStates(cis);
    }).catch(() => {
      // Lookup load failure is non-fatal — user can still register
    });
  }, []);

  // Load regions when cuisine state changes
  useEffect(() => {
    if (!form.cuisine_state) { setRegions([]); setSubRegions([]); return; }
    fetch(`${API_BASE}/lookup/cuisine-regions/${encodeURIComponent(form.cuisine_state)}`)
      .then(r => r.json()).then(setRegions);
    set("cuisine_region", "");
    set("cuisine_sub_region_id", "");
    setSubRegions([]);
  }, [form.cuisine_state]);

  // Load sub-regions when region changes
  useEffect(() => {
    if (!form.cuisine_state || !form.cuisine_region) { setSubRegions([]); return; }
    fetch(`${API_BASE}/lookup/cuisine-sub-regions/${encodeURIComponent(form.cuisine_state)}/${encodeURIComponent(form.cuisine_region)}`)
      .then(r => r.json()).then(setSubRegions);
    set("cuisine_sub_region_id", "");
  }, [form.cuisine_region]);

  // Load cities when city state changes
  useEffect(() => {
    if (!form.city_state) { setCities([]); return; }
    fetch(`${API_BASE}/lookup/cities/${encodeURIComponent(form.city_state)}`)
      .then(r => r.json()).then(setCities);
    set("current_city", "");
  }, [form.city_state]);

  const buildPayload = () => ({
    name:                  form.name,
    email:                 form.email,
    password:              form.password,
    house_name:            form.house_name,
    dietary_preference:    form.dietary_preference,
    household_allergies:   form.household_allergies || undefined,
    primary_region:        form.cuisine_state || "Tamil Nadu",
    current_city:          form.current_city || form.city_state || "Bengaluru",
    cuisine_sub_region_id: form.cuisine_sub_region_id ? parseInt(form.cuisine_sub_region_id) : undefined
  });

  const handleRegister = async () => {
    setError(null);
    if (!form.name || !form.email || !form.password || !form.house_name) {
      setError("Please fill in all required fields."); return;
    }
    if (form.password !== form.confirmPassword) {
      setError("Passwords do not match."); return;
    }
    if (form.password.length < 8) {
      setError("Password must be at least 8 characters."); return;
    }
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/auth/send-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: form.email, name: form.name })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || "Failed to send verification email.");
      if (data.enabled === false) {
        await register(buildPayload());
      } else {
        setOtpStep(true);
      }
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const handleOtpVerified = async () => {
    setLoading(true);
    try {
      await register(buildPayload());
    } catch (e) {
      setOtpStep(false);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  if (otpStep) {
    return (
      <OtpVerify
        email={form.email}
        name={form.name}
        onVerified={handleOtpVerified}
        onBack={() => setOtpStep(false)}
      />
    );
  }

  const inputStyle = {
    width: "100%", padding: "10px 14px", borderRadius: 10,
    border: "0.5px solid #EDE8E0", fontSize: 13, color: "#2C2C2A",
    background: "#F1EFE8", outline: "none", boxSizing: "border-box"
  };
  const selectStyle = { ...inputStyle, cursor: "pointer" };

  return (
    <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif", padding: "24px 0" }}>
      <div style={{ width: "100%", maxWidth: 400, padding: "0 24px" }}>

        <div style={{ textAlign: "center", marginBottom: 28 }}>
          <div style={{ fontSize: 32, marginBottom: 6 }}>🌿</div>
          <div style={{ color: "#FDFCF8", fontSize: 22, fontWeight: 500 }}>Momentum</div>
          <div style={{ color: "#5DCAA5", fontSize: 12, marginTop: 3 }}>Create your household</div>
        </div>

        <div style={{ background: "#FFF9F2", borderRadius: 20, padding: "24px 20px" }}>
          <div style={{ fontSize: 16, fontWeight: 500, color: "#2C2C2A", marginBottom: 18 }}>New household signup</div>

          {error && (
            <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>
              {error}
            </div>
          )}

          <Field label="Your name *">
            <input type="text" value={form.name} onChange={e => set("name", e.target.value)} placeholder="Bala" style={inputStyle} />
          </Field>

          <Field label="Email *">
            <input type="email" value={form.email} onChange={e => set("email", e.target.value)} placeholder="you@example.com" style={inputStyle} />
          </Field>

          <Field label="Password *">
            <input type="password" value={form.password} onChange={e => set("password", e.target.value)} placeholder="Min 8 characters" style={inputStyle} />
          </Field>

          <Field label="Confirm password *">
            <input type="password" value={form.confirmPassword} onChange={e => set("confirmPassword", e.target.value)} placeholder="Repeat password" style={inputStyle} />
          </Field>

          <div style={{ height: 0.5, background: "#EDE8E0", margin: "16px 0" }} />
          <div style={{ fontSize: 11, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>Household details</div>

          <Field label="Household name *">
            <input type="text" value={form.house_name} onChange={e => set("house_name", e.target.value)} placeholder="e.g. Bala Family" style={inputStyle} />
          </Field>

          <Field label="Dietary preference">
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
              {DIET_PREFS.map(d => (
                <button key={d} onClick={() => set("dietary_preference", d)}
                  style={{
                    padding: "7px 12px", borderRadius: 8, fontSize: 12, fontWeight: 500, cursor: "pointer",
                    background: form.dietary_preference === d ? "#1A3A2E" : "transparent",
                    color: form.dietary_preference === d ? "#9FE1CB" : "#888780",
                    border: form.dietary_preference === d ? "none" : "0.5px solid #EDE8E0"
                  }}>
                  {d}
                </button>
              ))}
            </div>
          </Field>

          <Field label="Household allergies" hint="Ingredients the household avoids — affects meal suggestions">
            <input type="text" value={form.household_allergies} onChange={e => set("household_allergies", e.target.value)} placeholder="e.g. Peanuts, Shellfish, Gluten" style={inputStyle} />
          </Field>

          <div style={{ height: 0.5, background: "#EDE8E0", margin: "16px 0" }} />
          <div style={{ fontSize: 11, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>Home cuisine region</div>

          <Field label="State" hint="Helps us personalise recipes to your family's culinary roots — e.g. Chettinad, Udupi, Malabar">
            <select value={form.cuisine_state} onChange={e => set("cuisine_state", e.target.value)} style={selectStyle}>
              <option value="">— Select state —</option>
              {cuisineStates.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </Field>

          {regions.length > 0 && (
            <Field label="Region">
              <select value={form.cuisine_region} onChange={e => set("cuisine_region", e.target.value)} style={selectStyle}>
                <option value="">— Select region —</option>
                {regions.map(r => <option key={r} value={r}>{r}</option>)}
              </select>
            </Field>
          )}

          {subRegions.length > 0 && (
            <Field label="Sub-region / Cuisine style">
              <select value={form.cuisine_sub_region_id} onChange={e => set("cuisine_sub_region_id", e.target.value)} style={selectStyle}>
                <option value="">— Select sub-region —</option>
                {subRegions.map(sr => <option key={sr.id} value={sr.id}>{sr.sub_region}</option>)}
              </select>
            </Field>
          )}

          <div style={{ height: 0.5, background: "#EDE8E0", margin: "16px 0" }} />
          <div style={{ fontSize: 11, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>Current location</div>

          <Field label="State" hint="Used to fetch local mandi prices for your area">
            <select value={form.city_state} onChange={e => set("city_state", e.target.value)} style={selectStyle}>
              <option value="">— Select state —</option>
              {cityStates.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </Field>

          {cities.length > 0 && (
            <Field label="City / Town">
              <select value={form.current_city} onChange={e => set("current_city", e.target.value)} style={selectStyle}>
                <option value="">— Select city —</option>
                {cities.map(c => <option key={c.id} value={c.display_name}>{c.display_name}</option>)}
              </select>
            </Field>
          )}

          <button
            onClick={handleRegister}
            disabled={loading}
            style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 500, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1, marginTop: 18 }}
          >
            {loading ? "Sending code..." : "Continue"}
          </button>

          <div style={{ textAlign: "center", marginTop: 14, fontSize: 13, color: "#888780" }}>
            Already have an account?{" "}
            <span onClick={onSwitchToLogin} style={{ color: "#0F6E56", fontWeight: 500, cursor: "pointer" }}>Sign in</span>
          </div>
        </div>
      </div>
    </div>
  );
}
