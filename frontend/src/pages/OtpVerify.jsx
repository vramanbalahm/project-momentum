import { useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

export default function OtpVerify({ email, name, onVerified, onBack }) {
  const [otp, setOtp] = useState("");
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  const [resent, setResent] = useState(false);

  const handleVerify = async () => {
    setError(null);
    if (otp.trim().length !== 6) { setError("Please enter the 6-digit code."); return; }
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/auth/verify-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, otp: otp.trim() })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || "Verification failed.");
      onVerified();
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    setResending(true);
    setError(null);
    setResent(false);
    try {
      await fetch(`${API_BASE}/auth/send-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, name })
      });
      setResent(true);
    } catch {
      setError("Could not resend code. Please try again.");
    } finally {
      setResending(false);
    }
  };

  const inputStyle = {
    width: "100%", padding: "10px 14px", borderRadius: 10,
    border: "0.5px solid #EDE8E0", fontSize: 24, fontWeight: 600,
    letterSpacing: 12, color: "#2C2C2A", background: "#F1EFE8",
    outline: "none", boxSizing: "border-box", textAlign: "center"
  };

  return (
    <div style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif", padding: "24px 0" }}>
      <div style={{ width: "100%", maxWidth: 400, padding: "0 24px" }}>

        <div style={{ textAlign: "center", marginBottom: 28 }}>
          <div style={{ fontSize: 32, marginBottom: 6 }}>📬</div>
          <div style={{ color: "#FDFCF8", fontSize: 22, fontWeight: 500 }}>Check your email</div>
          <div style={{ color: "#5DCAA5", fontSize: 12, marginTop: 6, lineHeight: 1.5 }}>
            We sent a 6-digit code to<br />
            <span style={{ color: "#9FE1CB", fontWeight: 500 }}>{email}</span>
          </div>
        </div>

        <div style={{ background: "#FFF9F2", borderRadius: 20, padding: "24px 20px" }}>

          {error && (
            <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>
              {error}
            </div>
          )}

          {resent && (
            <div style={{ background: "#E1F5EE", border: "0.5px solid #9FE1CB", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#1A3A2E" }}>
              New code sent! Check your inbox.
            </div>
          )}

          <div style={{ marginBottom: 20 }}>
            <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 8 }}>Enter verification code</div>
            <input
              type="text"
              inputMode="numeric"
              maxLength={6}
              value={otp}
              onChange={e => setOtp(e.target.value.replace(/\D/g, ""))}
              onKeyDown={e => e.key === "Enter" && handleVerify()}
              placeholder="——————"
              style={inputStyle}
              autoFocus
            />
            <div style={{ fontSize: 11, color: "#B4B2A9", marginTop: 6 }}>Code expires in 5 minutes</div>
          </div>

          <button
            onClick={handleVerify}
            disabled={loading}
            style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 500, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1 }}
          >
            {loading ? "Verifying..." : "Verify email"}
          </button>

          <div style={{ display: "flex", justifyContent: "space-between", marginTop: 16 }}>
            <span
              onClick={onBack}
              style={{ fontSize: 12, color: "#888780", cursor: "pointer" }}
            >
              ← Back
            </span>
            <span
              onClick={!resending ? handleResend : undefined}
              style={{ fontSize: 12, color: resending ? "#B4B2A9" : "#0F6E56", fontWeight: 500, cursor: resending ? "default" : "pointer" }}
            >
              {resending ? "Sending..." : "Resend code"}
            </span>
          </div>

        </div>
      </div>
    </div>
  );
}
