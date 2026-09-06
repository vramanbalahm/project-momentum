import { useState } from "react";
import { useAuth } from "../context/AuthContext";

export default function Login({ onSwitchToRegister }) {
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    setError(null);
    if (!email || !password) { setError("Please enter email and password."); return; }
    setLoading(true);
    try {
      await login(email, password);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif" }}>
      <div style={{ width: "100%", maxWidth: 400, padding: "0 24px" }}>

        {/* Logo */}
        <div style={{ textAlign: "center", marginBottom: 36 }}>
          <div style={{ display: "inline-block", background: "#FAF9F5", borderRadius: 16, padding: "16px 20px", marginBottom: 8 }}>
            <img src="/assets/branding/ladleful-logo.png" alt="Ladleful" style={{ height: 64, display: "block" }} />
          </div>
          <div style={{ color: "#5DCAA5", fontSize: 13, marginTop: 8 }}>Your weekly meal planner</div>
        </div>

        {/* Card */}
        <div style={{ background: "#FFF9F2", borderRadius: 20, padding: "28px 24px" }}>
          <div style={{ fontSize: 18, fontWeight: 500, color: "#2C2C2A", marginBottom: 20 }}>Sign in</div>

          {error && (
            <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 16, fontSize: 13, color: "#712B13" }}>
              {error}
            </div>
          )}

          <div style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>Email</div>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="you@example.com"
              style={{ width: "100%", padding: "10px 14px", borderRadius: 10, border: "0.5px solid #EDE8E0", fontSize: 14, color: "#2C2C2A", background: "#F1EFE8", outline: "none", boxSizing: "border-box" }}
            />
          </div>

          <div style={{ marginBottom: 20 }}>
            <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>Password</div>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
              onKeyDown={e => e.key === "Enter" && handleLogin()}
              style={{ width: "100%", padding: "10px 14px", borderRadius: 10, border: "0.5px solid #EDE8E0", fontSize: 14, color: "#2C2C2A", background: "#F1EFE8", outline: "none", boxSizing: "border-box" }}
            />
          </div>

          <button
            onClick={handleLogin}
            disabled={loading}
            style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 500, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1 }}
          >
            {loading ? "Signing in..." : "Sign in"}
          </button>

          <div style={{ textAlign: "center", marginTop: 16, fontSize: 13, color: "#888780" }}>
            New household?{" "}
            <span onClick={onSwitchToRegister} style={{ color: "#0F6E56", fontWeight: 500, cursor: "pointer" }}>
              Create account
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
