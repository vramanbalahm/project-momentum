import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";

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

const STATUS_MAP = {
  pending:  { tab: "under_review", color: "#0C447C", bg: "#E6F1FB", labelColor: "#185FA5" },
  saved:    { tab: "saved",        color: "#633806", bg: "#FAEEDA", labelColor: "#854F0B" },
  approved: { tab: "approved",     color: "#085041", bg: "#E1F5EE", labelColor: "#0F6E56" },
  rejected: { tab: "rejected",     color: "#712B13", bg: "#FAECE7", labelColor: "#993C1D" },
};

const ProgressBar = ({ value, max, color = C.teal }) => {
  const { t } = useTranslation();
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", fontSize: 10, color: C.muted, marginBottom: 4 }}>
        <span>{t("reviewProgress.progress")}</span><span>{pct}%</span>
      </div>
      <div style={{ height: 6, background: C.border, borderRadius: 6, overflow: "hidden" }}>
        <div style={{ height: "100%", background: color, borderRadius: 6, width: `${pct}%`, transition: "width 0.4s" }} />
      </div>
    </div>
  );
};

export default function ReviewerProgress({ onBack, onNavigate }) {
  const { apiFetch } = useAuth();
  const { t } = useTranslation();
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
      setError(e.message || t("common.error"));
    } finally {
      setLoading(false);
    }
  };

  // Navigate to RecipeReview with tab pre-selected (all reviewers)
  const goToTab = (statusKey) => {
    onNavigate({ initialTab: STATUS_MAP[statusKey].tab });
  };

  // Navigate to RecipeReview filtered to a specific reviewer + approved tab
  const goToReviewer = (reviewer) => {
    onNavigate({ initialTab: "approved", filterReviewerId: reviewer.user_id });
  };

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ color: C.mint, fontSize: 12, cursor: "pointer", marginBottom: 6 }} onClick={onBack}>
          {t("reviewProgress.backToDashboard")}
        </div>
        <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500 }}>{t("reviewProgress.title")}</div>
        <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>{t("reviewProgress.subtitle")}</div>
      </div>

      <div style={{ padding: "16px" }}>

        {loading && (
          <div style={{ textAlign: "center", padding: 40, color: C.muted, fontSize: 13 }}>{t("common.loading")}</div>
        )}

        {error && (
          <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", fontSize: 13, color: "#712B13", marginBottom: 16 }}>
            {error}
          </div>
        )}

        {data && (
          <>
            {/* ── Vault overview — stats are clickable ── */}
            <div style={{ background: C.card, borderRadius: 16, padding: "14px 16px", border: `0.5px solid ${C.border}`, marginBottom: 12 }}>
              <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>
                {t("reviewProgress.vaultOverview")} — {data.totals.total} {t("reviewProgress.recipes")}
              </div>
              <div style={{ display: "flex", gap: 6, marginBottom: 12 }}>
                {Object.entries(STATUS_MAP).map(([key, { tab, color, bg, labelColor }]) => (
                  <div key={key} onClick={() => goToTab(key)}
                    style={{ flex: 1, cursor: "pointer", background: bg, borderRadius: 8, padding: "8px 6px", textAlign: "center" }}>
                    <div style={{ fontSize: 17, fontWeight: 500, color }}>{data.totals[key]}</div>
                    <div style={{ fontSize: 9, color: labelColor, marginTop: 2, textTransform: "capitalize" }}>{t(`reviewProgress.${key}`)}</div>
                    <div style={{ fontSize: 8, color: labelColor, marginTop: 1, opacity: 0.7 }}>{t("common.tapToFilter")}</div>
                  </div>
                ))}
              </div>
              <ProgressBar
                value={data.totals.approved + data.totals.rejected}
                max={data.totals.total}
                color={C.teal}
              />
            </div>

            {/* Open Recipe Review button */}
            <div
              onClick={() => onNavigate({ initialTab: "under_review" })}
              style={{ background: C.green, color: C.mint, borderRadius: 12, padding: "12px 16px", textAlign: "center", fontSize: 13, fontWeight: 500, cursor: "pointer", marginBottom: 20 }}
            >
              {t("reviewProgress.openRecipeReview")}
            </div>

            {/* ── Reviewer cards — each clickable ── */}
            <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>
              {t("reviewProgress.reviewerBreakdown")}
            </div>

            {data.reviewers.map((r, i) => {
              const notStarted = r.total_done === 0;
              return (
                <div key={i}
                  onClick={() => !notStarted && goToReviewer(r)}
                  style={{
                    background: C.card, borderRadius: 14, padding: "14px 16px",
                    border: `0.5px solid ${C.border}`, marginBottom: 12,
                    opacity: notStarted ? 0.55 : 1,
                    cursor: notStarted ? "default" : "pointer",
                  }}
                >
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
                    <div>
                      <div style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{r.name}</div>
                      <div style={{ fontSize: 11, color: C.muted }}>{r.email}</div>
                    </div>
                    {notStarted
                      ? <span style={{ fontSize: 10, background: "#F0EFEC", color: C.muted, padding: "3px 8px", borderRadius: 10 }}>{t("reviewProgress.notStarted")}</span>
                      : <span style={{ fontSize: 12, fontWeight: 500, color: C.green }}>{r.total_done} {t("reviewProgress.done")} ›</span>
                    }
                  </div>

                  <div style={{ display: "flex", gap: 5, marginBottom: 10 }}>
                    {Object.entries(STATUS_MAP).map(([key, { color, bg, labelColor }]) => (
                      <div key={key} style={{ flex: 1, background: bg, borderRadius: 6, padding: "5px 4px", textAlign: "center" }}>
                        <div style={{ fontSize: 13, fontWeight: 500, color }}>{r[key]}</div>
                        <div style={{ fontSize: 8, color: labelColor, marginTop: 1, textTransform: "capitalize" }}>{t(`reviewProgress.${key}`)}</div>
                      </div>
                    ))}
                  </div>

                  <ProgressBar value={r.approved + r.rejected} max={data.totals.total} color={C.mint} />
                </div>
              );
            })}
          </>
        )}
      </div>
    </div>
  );
}
