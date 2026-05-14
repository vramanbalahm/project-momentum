import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const C = {
  green:   "#1A3A2E",
  mint:    "#9FE1CB",
  teal:    "#5DCAA5",
  bg:      "#F7F4EE",
  card:    "#FFF9F2",
  border:  "#EDE8E0",
  text:    "#2C2C2A",
  muted:   "#888780",
};

const StatusBadge = ({ count, color, bg, label }) => (
  <div style={{ textAlign: "center", minWidth: 48 }}>
    <div style={{ fontSize: 15, fontWeight: 600, color }}>{count}</div>
    <div style={{ fontSize: 9, color: C.muted, marginTop: 1 }}>{label}</div>
  </div>
);

export default function ReviewerProgress({ onBack, onNavigate }) {
  const { apiFetch } = useAuth();
  const [data, setData]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

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

  const pct = (done, total) => total > 0 ? Math.round((done / total) * 100) : 0;

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ color: "#9FE1CB", fontSize: 12, cursor: "pointer", marginBottom: 6 }} onClick={onBack}>
          ← Dashboard
        </div>
        <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500 }}>Review Progress</div>
        <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>Platform admin view</div>
      </div>

      <div style={{ padding: "20px 16px" }}>

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
            {/* ── Vault totals ── */}
            <div style={{ background: C.card, borderRadius: 16, padding: "16px", border: `0.5px solid ${C.border}`, marginBottom: 20 }}>
              <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 14 }}>
                Vault Overview — {data.totals.total} recipes total
              </div>
              <div style={{ display: "flex", justifyContent: "space-around" }}>
                <StatusBadge count={data.totals.pending}  color="#633806" label="Pending"  />
                <StatusBadge count={data.totals.saved}    color="#1A3A6E" label="Saved"    />
                <StatusBadge count={data.totals.approved} color="#085041" label="Approved" />
                <StatusBadge count={data.totals.rejected} color="#712B13" label="Rejected" />
              </div>

              {/* Overall progress bar */}
              <div style={{ marginTop: 16 }}>
                <div style={{ display: "flex", justifyContent: "space-between", fontSize: 11, color: C.muted, marginBottom: 5 }}>
                  <span>Overall review progress</span>
                  <span>{pct(data.totals.approved + data.totals.rejected, data.totals.total)}% done</span>
                </div>
                <div style={{ height: 8, background: C.border, borderRadius: 8, overflow: "hidden" }}>
                  <div style={{ height: "100%", background: C.teal, borderRadius: 8, width: `${pct(data.totals.approved + data.totals.rejected, data.totals.total)}%`, transition: "width 0.5s" }} />
                </div>
              </div>
            </div>

            {/* ── Per reviewer ── */}
            <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>
              Reviewer Breakdown
            </div>

            {data.reviewers.length === 0 && (
              <div style={{ textAlign: "center", padding: 24, color: C.muted, fontSize: 13 }}>No reviews recorded yet.</div>
            )}

            {data.reviewers.map((r, i) => (
              <div key={i} style={{ background: C.card, borderRadius: 14, padding: "14px 16px", border: `0.5px solid ${C.border}`, marginBottom: 12 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
                  <div>
                    <div style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{r.name}</div>
                    <div style={{ fontSize: 11, color: C.muted }}>{r.email}</div>
                  </div>
                  <div style={{ fontSize: 13, fontWeight: 600, color: C.green }}>
                    {r.total_done} done
                  </div>
                </div>

                <div style={{ display: "flex", justifyContent: "space-around", marginBottom: 12 }}>
                  <StatusBadge count={r.pending}  color="#633806" label="Pending"  />
                  <StatusBadge count={r.saved}    color="#1A3A6E" label="Saved"    />
                  <StatusBadge count={r.approved} color="#085041" label="Approved" />
                  <StatusBadge count={r.rejected} color="#712B13" label="Rejected" />
                </div>

                {/* Per-reviewer progress bar */}
                <div style={{ height: 6, background: C.border, borderRadius: 6, overflow: "hidden" }}>
                  <div style={{ height: "100%", background: C.mint, borderRadius: 6, width: `${pct(r.approved + r.rejected, data.totals.total)}%`, transition: "width 0.5s" }} />
                </div>
                <div style={{ fontSize: 10, color: C.muted, marginTop: 4, textAlign: "right" }}>
                  {pct(r.approved + r.rejected, data.totals.total)}% of total vault
                </div>
              </div>
            ))}

            {/* ── Go to Recipe Review ── */}
            <div
              onClick={() => onNavigate("recipe_review")}
              style={{ background: C.green, color: C.mint, borderRadius: 14, padding: "14px 16px", textAlign: "center", fontSize: 14, fontWeight: 500, cursor: "pointer", marginTop: 8 }}
            >
              Open Recipe Review →
            </div>
          </>
        )}
      </div>
    </div>
  );
}
