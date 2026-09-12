import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
  errorBg: "#FAECE7", errorText: "#712B13",
  successBg: "#E1F5EE", successText: "#085041",
};

export default function PlatformAdmin({ onBack }) {
  const { apiFetch } = useAuth();
  const [runningId, setRunningId] = useState(null);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const runTool = async (tool) => {
    setRunningId(tool.id);
    setError(null);
    setResult(null);
    try {
      const res = await apiFetch(tool.endpoint, { method: "POST" });
      setResult(res.message);
    } catch (e) {
      setError(e.message || "Something went wrong.");
    } finally {
      setRunningId(null);
    }
  };

  // Add future admin-only tools here — each renders as its own list item below.
  const tools = [
    {
      id: "backfill_holidays",
      icon: "📅",
      title: "Backfill holiday events",
      desc: "Copies this year's government-published holidays into every existing household's own events. Only affects households that don't already have them — safe to run more than once.",
      endpoint: "/auth/admin/backfill-holidays",
      actionLabel: "Run backfill",
    },
  ];

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div onClick={onBack} style={{ color: C.mint, fontSize: 20, cursor: "pointer" }}>←</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: C.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>LADLEFUL · ADMIN</div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500, marginTop: 2 }}>Platform Admin</div>
            <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>{tools.length} tool{tools.length === 1 ? "" : "s"} available</div>
          </div>
        </div>
      </div>

      {/* Banners */}
      <div style={{ padding: result || error ? "10px 14px 0" : 0 }}>
        {result && <div style={{ background: C.successBg, border: `0.5px solid ${C.mint}`, borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.successText }}>✅ {result}</div>}
        {error && <div style={{ background: C.errorBg, border: "0.5px solid #F0997B", borderRadius: 10, padding: "10px 14px", fontSize: 12, color: C.errorText }}>{error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span></div>}
      </div>

      {/* Tools list */}
      <div style={{ padding: "14px", display: "flex", flexDirection: "column", gap: 8 }}>
        {tools.map(tool => (
          <div key={tool.id} style={{ background: C.card, borderRadius: 12, border: `0.5px solid ${C.border}`, overflow: "hidden" }}>
            <div style={{ display: "flex", alignItems: "flex-start", padding: "12px 14px", gap: 10 }}>
              <div style={{ fontSize: 24, flexShrink: 0 }}>{tool.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>{tool.title}</div>
                <div style={{ fontSize: 11, color: C.muted, marginTop: 2, lineHeight: 1.4 }}>{tool.desc}</div>
                <button
                  onClick={() => runTool(tool)}
                  disabled={runningId === tool.id}
                  style={{
                    marginTop: 10, background: runningId === tool.id ? "#B4B2A9" : C.green, color: C.mint,
                    border: "none", borderRadius: 8, padding: "7px 14px",
                    fontSize: 12, fontWeight: 500, cursor: runningId === tool.id ? "not-allowed" : "pointer"
                  }}
                >
                  {runningId === tool.id ? "Running…" : tool.actionLabel}
                </button>
              </div>
            </div>
          </div>
        ))}

        <div style={{ fontSize: 11, color: C.muted, textAlign: "center", marginTop: 8 }}>
          More admin tools will appear here over time.
        </div>
      </div>
    </div>
  );
}
