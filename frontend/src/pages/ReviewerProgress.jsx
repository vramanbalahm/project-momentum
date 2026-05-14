import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green:  "#1A3A2E",
  mint:   "#9FE1CB",
  teal:   "#5DCAA5",
  bg:     "#F7F4EE",
  card:   "#FFF9F2",
  border: "#EDE8E0",
  text:   "#2C2C2A",
  muted:  "#888780",
};

const StatusBadge = ({ count, color, label }) => (
  <div style={{ textAlign: "center", flex: 1 }}>
    <div style={{ fontSize: 15, fontWeight: 500, color }}>{count}</div>
    <div style={{ fontSize: 9, color: C.muted, marginTop: 1 }}>{label}</div>
  </div>
);

const ProgressBar = ({ value, max, color = C.teal }) => {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", fontSize: 10, color: C.muted, marginBottom: 4 }}>
        <span>Progress</span>
        <span>{pct}%</span>
      </div>
      <div style={{ height: 6, background: C.border, borderRadius: 6, overflow: "hidden" }}>
        <div style={{ height: "100%", background: color, borderRadius: 6, width: `${pct}%`, transition: "width 0.4s" }} />
      </div>
    </div>
  );
};

export default function ReviewerProgress({ onBack, onNavigate }) {
  const { apiFetch } = useAuth();
  const [data, setData]         = useState(null);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState(null);
  const [activeTab, setActiveTab] = useState("all");

  useEffect(() => { load(); }, []);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const d = await apiFetch("/recipes/reviewer-progress");
      setData(d);
    } catch (e) {
      setError(e.message || "Failed to load progress.");
    } finally {
      setLoading(false);
    }
  };

  const visibleReviewers = data
    ? (activeTab === "all" ? data.reviewers : data.reviewers.filter(r => r.name === activeTab))
    : [];

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ color: C.mint, fontSize: 12, cursor: "pointer", marginBottom: 6 }} onClick={onBack}>
          ← Dashboard
        </div>
        <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500 }}>Review Progress</div>
        <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>Platform admin view</div>
      </div>

      <div style={{ padding: "16px" }}>

        {loading && (
          <div style={{ textAlign: "center", padding: 40, color: C.muted, fontSize: 13 }}>Loading...</div>
        )}

        {error && (
          <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", fontSize: 13, color: "#712B13", marginBottom: 16 }}>
            {error}
          </div>
        )}

        {data && (
          <>
            {/* ── Vault overview ── */}
            <div style={{ background: C.card, borderRadius: 16, padding: "14px 16px", border: `0.5px solid ${C.border}`, marginBottom: 16 }}>
              <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>
                Vault overview — {data.totals.total} recipes
              </div>
              <div style={{ display: "flex", justifyContent: "space-around", marginBottom: 14 }}>
                <StatusBadge count={data.totals.pending}  color="#633806" label="Pending"  />
                <StatusBadge count={data.totals.saved}    color="#1A3A6E" label="Saved"    />
                <StatusBadge count={data.totals.approved} color="#085041" label="Approved" />
                <StatusBadge count={data.totals.rejected} color="#712B13" label="Rejected" />
              </div>
              <ProgressBar
                value={data.totals.approved + data.totals.rejected}
                max={data.totals.total}
                color={C.teal}
              />
            </div>

            {/* ── Reviewer tabs ── */}
            <div style={{ display: "flex", gap: 6, overflowX: "auto", paddingBottom: 4, marginBottom: 14 }}>
              {["all", ...data.reviewers.map(r => r.name)].map(tab => (
                <div
                  key={tab}
                  onClick={() => setActiveTab(tab)}
                  style={{
                    padding: "5px 12px", borderRadius: 20, fontSize: 12, fontWeight: 500,
                    cursor: "pointer", whiteSpace: "nowrap", flexShrink: 0,
                    background: activeTab === tab ? C.green : "transparent",
                    color: activeTab === tab ? C.mint : C.muted,
                    border: `0.5px solid ${activeTab === tab ? C.green : C.border}`,
                    transition: "all 0.15s",
                  }}
                >
                  {tab === "all" ? "All reviewers" : tab}
                </div>
              ))}
            </div>

            {/* ── Reviewer cards ── */}
            {visibleReviewers.map((r, i) => {
              const notStarted = r.total_done === 0;
              return (
                <div key={i} style={{
                  background: C.card, borderRadius: 14, padding: "14px 16px",
                  border: `0.5px solid ${C.border}`, marginBottom: 12,
                  opacity: notStarted ? 0.55 : 1,
                }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                    <div>
                      <div style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{r.name}</div>
                      <div style={{ fontSize: 11, color: C.muted }}>{r.email}</div>
                    </div>
                    {notStarted
                      ? <span style={{ fontSize: 10, background: "#F0EFEC", color: C.muted, padding: "3px 8px", borderRadius: 10 }}>Not started</span>
                      : <span style={{ fontSize: 12, fontWeight: 500, color: C.green }}>{r.total_done} done</span>
                    }
                  </div>

                  <div style={{ display: "flex", justifyContent: "space-around", marginBottom: 12 }}>
                    <StatusBadge count={r.pending}  color="#633806" label="Pending"  />
                    <StatusBadge count={r.saved}    color="#1A3A6E" label="Saved"    />
                    <StatusBadge count={r.approved} color="#085041" label="Approved" />
                    <StatusBadge count={r.rejected} color="#712B13" label="Rejected" />
                  </div>

                  <ProgressBar value={r.approved + r.rejected} max={data.totals.total} color={C.mint} />

                  {/* View in Recipe Review — only if they have work */}
                  {!notStarted && (
                    <div
                      onClick={() => onNavigate("recipe_review")}
                      style={{ marginTop: 12, padding: "8px", borderRadius: 8, background: C.green, color: C.mint, fontSize: 12, fontWeight: 500, textAlign: "center", cursor: "pointer" }}
                    >
                      View {r.name}'s approved recipes →
                    </div>
                  )}
                </div>
              );
            })}
          </>
        )}
      </div>
    </div>
  );
}
