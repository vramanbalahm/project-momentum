import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import OtpVerify from "./OtpVerify";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";
const REGIONS = ["Tamil Nadu", "Kerala", "Karnataka", "Andhra Pradesh", "Telangana", "Maharashtra", "Other"];
const DIET_PREFS = ["Veg", "Non-Veg", "Vegan"];

// Moved outside Register to prevent re-mount on every keystroke (focus-loss fix)
const Field = ({ label, children }) => (
  <div style={{ marginBottom: 14 }}>
    <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>{label}</div>
    {children}
  </div>
);

export default function Register({ onSwitchToLogin }) {
  const { register } = useAuth();
  const [form, setForm] = useState({
    name: "", email: "", password: "", confirmPassword: "",
    house_name: "", primary_region: "Tamil Nadu",
    current_city: "", dietary_preference: "Veg"
  });
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [otpStep, setOtpStep] = useState(false); // true = show OTP screen

  const set = (k, v) => setForm(prev => ({ ...prev, [k]: v }));

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
      // Send OTP first — if EMAIL_VERIFY_ENABLED=false, backend returns enabled:false and we skip OTP screen
      const res = await fetch(`${API_BASE}/auth/send-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: form.email, name: form.name })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || "Failed to send verification email.");

      if (data.enabled === false) {
        // Email verification disabled — register directly
        await register({
          name: form.name, email: form.email, password: form.password,
          house_name: form.house_name, primary_region: form.primary_region,
          current_city: form.current_city || form.primary_region,
          dietary_preference: form.dietary_preference
        });
      } else {
        // Show OTP screen
        setOtpStep(true);
      }
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const handleOtpVerified = async () => {
    // OTP verified — now create the account
    setLoading(true);
    try {
      await register({
        name: form.name, email: form.email, password: form.password,
        house_name: form.house_name, primary_region: form.primary_region,
        current_city: form.current_city || form.primary_region,
        dietary_preference: form.dietary_preference
      });
    } catch (e) {
      setOtpStep(false);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  // Show OTP screen after form submit
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

  const inputStyle = { width: "100%", padding: "10px 14px", borderRadius: 10, border: "0.5px solid #EDE8E0", fontSize: 13, color: "#2C2C2A", background: "#F1EFE8", outline: "none", boxSizing: "border-box" };

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

          <Field label="Home region">
            <select value={form.primary_region} onChange={e => set("primary_region", e.target.value)} style={{ ...inputStyle, cursor: "pointer" }}>
              {REGIONS.map(r => <option key={r}>{r}</option>)}
            </select>
          </Field>

          <Field label="Current city">
            <input type="text" value={form.current_city} onChange={e => set("current_city", e.target.value)} placeholder="e.g. Bengaluru" style={inputStyle} />
          </Field>

          <Field label="Dietary preference">
            <div style={{ display: "flex", gap: 8 }}>
              {DIET_PREFS.map(d => (
                <button key={d} onClick={() => set("dietary_preference", d)}
                  style={{ flex: 1, padding: "8px 0", borderRadius: 8, fontSize: 12, fontWeight: 500, cursor: "pointer",
                    background: form.dietary_preference === d ? "#1A3A2E" : "transparent",
                    color: form.dietary_preference === d ? "#9FE1CB" : "#888780",
                    border: form.dietary_preference === d ? "none" : "0.5px solid #EDE8E0"
                  }}>
                  {d}
                </button>
              ))}
            </div>
          </Field>

          <button
            onClick={handleRegister}
            disabled={loading}
            style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 500, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1, marginTop: 6 }}
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
