import { useState } from "react";
import { useAuth } from "../context/AuthContext";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const inputStyle = {
  width: "100%", padding: "10px 14px", borderRadius: 10,
  border: "0.5px solid #EDE8E0", fontSize: 14, color: "#2C2C2A",
  background: "#F1EFE8", outline: "none", boxSizing: "border-box"
};

export default function ChangePassword({ onClose }) {
  const { apiFetch } = useAuth();
  const [form, setForm] = useState({ current_password: "", new_password: "", confirm_password: "" });
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);

  const set = (k, v) => setForm(prev => ({ ...prev, [k]: v }));

  const handleSubmit = async () => {
    setError(null);
    if (!form.current_password || !form.new_password || !form.confirm_password) {
      setError("Please fill in all fields."); return;
    }
    if (form.new_password !== form.confirm_password) {
      setError("New passwords do not match."); return;
    }
    if (form.new_password.length < 8) {
      setError("New password must be at least 8 characters."); return;
    }
    setLoading(true);
    try {
      await apiFetch("/auth/change-password", {
        method: "POST",
        body: JSON.stringify({ current_password: form.current_password, new_password: form.new_password })
      });
      setSuccess(true);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)",
      zIndex: 100, display: "flex", alignItems: "flex-end", justifyContent: "center"
    }}>
      <div style={{
        width: "100%", maxWidth: 430, background: "#FFF9F2",
        borderRadius: "24px 24px 0 0", padding: "28px 24px 40px"
      }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
          <div style={{ fontSize: 17, fontWeight: 600, color: "#2C2C2A" }}>Change Password</div>
          <span onClick={onClose} style={{ fontSize: 20, cursor: "pointer", color: "#888780" }}>✕</span>
        </div>

        {success ? (
          <div style={{ textAlign: "center", padding: "20px 0" }}>
            <div style={{ fontSize: 36, marginBottom: 12 }}>✅</div>
            <div style={{ fontSize: 15, fontWeight: 500, color: "#2C2C2A" }}>Password changed!</div>
            <div style={{ fontSize: 13, color: "#888780", marginTop: 6 }}>Your password has been updated successfully.</div>
            <button onClick={onClose} style={{ marginTop: 20, background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "12px 32px", fontSize: 14, fontWeight: 500, cursor: "pointer" }}>Done</button>
          </div>
        ) : (
          <>
            {error && (
              <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>
                {error}
              </div>
            )}
            <div style={{ marginBottom: 14 }}>
              <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>Current password</div>
              <input type="password" value={form.current_password} onChange={e => set("current_password", e.target.value)} placeholder="••••••••" style={inputStyle} />
            </div>
            <div style={{ marginBottom: 14 }}>
              <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>New password</div>
              <input type="password" value={form.new_password} onChange={e => set("new_password", e.target.value)} placeholder="Min 8 characters" style={inputStyle} />
            </div>
            <div style={{ marginBottom: 20 }}>
              <div style={{ fontSize: 11, color: "#888780", fontWeight: 500, marginBottom: 5 }}>Confirm new password</div>
              <input type="password" value={form.confirm_password} onChange={e => set("confirm_password", e.target.value)} placeholder="Repeat new password" style={inputStyle} onKeyDown={e => e.key === "Enter" && handleSubmit()} />
            </div>
            <button onClick={handleSubmit} disabled={loading} style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "13px", fontSize: 14, fontWeight: 500, cursor: loading ? "not-allowed" : "pointer", opacity: loading ? 0.7 : 1 }}>
              {loading ? "Updating..." : "Update password"}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
