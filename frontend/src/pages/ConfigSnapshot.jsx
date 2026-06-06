import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green:    "#1A3A2E",
  mint:     "#9FE1CB",
  teal:     "#5DCAA5",
  deepTeal: "#0F6E56",
  text:     "#2C2C2A",
  muted:    "#888780",
  border:   "#EDE8E0",
  card:     "#FFF9F2",
  bg:       "#F7F4EE",
};

const Section = ({ title, emoji, children }) => (
  <div style={{ background: C.card, borderRadius: 14, border: `0.5px solid ${C.border}`, marginBottom: 12, overflow: "hidden" }}>
    <div style={{ background: C.bg, padding: "10px 14px", borderBottom: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", gap: 8 }}>
      <span style={{ fontSize: 16 }}>{emoji}</span>
      <span style={{ fontSize: 12, fontWeight: 600, color: C.text, textTransform: "uppercase", letterSpacing: "0.05em" }}>{title}</span>
    </div>
    <div style={{ padding: "12px 14px" }}>{children}</div>
  </div>
);

const Row = ({ label, value, highlight }) => (
  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "5px 0", borderBottom: `0.5px solid ${C.border}` }}>
    <span style={{ fontSize: 12, color: C.muted }}>{label}</span>
    <span style={{ fontSize: 12, fontWeight: 500, color: highlight ? C.deepTeal : C.text }}>{value ?? "—"}</span>
  </div>
);

const Badge = ({ label, color = C.teal, bg = "#E1F5EE" }) => (
  <span style={{ fontSize: 10, fontWeight: 500, color, background: bg, borderRadius: 6, padding: "2px 7px", marginRight: 4, marginBottom: 4, display: "inline-block" }}>
    {label}
  </span>
);

export default function ConfigSnapshot({ onBack }) {
  const { apiFetch } = useAuth();
  const [data, setData]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

  useEffect(() => {
    apiFetch("/config-snapshot")
      .then(d => setData(d))
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <div style={{ minHeight: "100vh", background: C.green, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif" }}>
      <div style={{ color: C.mint, fontSize: 14 }}>Loading configuration...</div>
    </div>
  );

  return (
    <div style={{ minHeight: "100vh", background: C.green, display: "flex", flexDirection: "column", alignItems: "center", fontFamily: "system-ui, sans-serif" }}>
      <div style={{ width: "100%", maxWidth: 430, flex: 1, display: "flex", flexDirection: "column" }}>

        {/* Header */}
        <div style={{ background: C.green, padding: "48px 16px 14px", flexShrink: 0 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <span onClick={onBack} style={{ color: C.mint, fontSize: 12, cursor: "pointer" }}>← Dashboard</span>
            <span style={{ color: "#FDFCF8", fontSize: 15, fontWeight: 500 }}>My Configuration</span>
            <span style={{ width: 60 }} />
          </div>
        </div>

        {/* Content */}
        <div style={{ flex: 1, padding: "14px 16px", overflowY: "auto", background: C.bg }}>

          {error && (
            <div style={{ background: "#FAECE7", borderRadius: 10, padding: "12px 14px", marginBottom: 12, fontSize: 12, color: "#712B13" }}>
              {error}
            </div>
          )}

          {data && (
            <>
              {/* Household */}
              <Section title="Household" emoji="🏠">
                <Row label="Name"             value={data.house_name} highlight />
                <Row label="Household diet"   value={data.household_diet} />
                <Row label="Language"         value={data.preferred_language === "ta" ? "Tamil" : "English"} />
                <Row label="Panchangam"       value={data.panchangam || "Not set"} />
                <Row label="Satvik items"     value={`${data.satvik_count} ingredients avoided`} />
                <Row label="Pantry items"     value={`${data.pantry_items} items available`} />
              </Section>

              {/* Members */}
              <Section title="Members" emoji="👨‍👩‍👧‍👦">
                {(data.members || []).map((m, i) => (
                  <div key={i} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "6px 0", borderBottom: `0.5px solid ${C.border}` }}>
                    <div>
                      <div style={{ fontSize: 12, fontWeight: 500, color: C.text }}>{m.name}</div>
                      <div style={{ fontSize: 10, color: C.muted }}>{m.age || "—"} · {m.diet}</div>
                    </div>
                    <Badge label={m.diet}
                      color={m.diet === "Vegan" ? "#5B2D8E" : m.diet === "Non-Veg" ? "#A63A1A" : C.deepTeal}
                      bg={m.diet === "Vegan" ? "#F0E6FF" : m.diet === "Non-Veg" ? "#FAECE7" : "#E1F5EE"}
                    />
                  </div>
                ))}
              </Section>

              {/* Weekly questionnaire */}
              <Section title="This Week's Preferences" emoji="📋">
                {data.latest_weekly_config ? (
                  <>
                    <Row label="Week"                   value={data.latest_weekly_config.week_start} />
                    <Row label="Continental breakfast"  value={`${data.latest_weekly_config.continental_days} day(s)`} />
                    <Row label="Allow same week repeat" value={data.latest_weekly_config.allow_same_week_repeat ? "Yes" : "No"} />
                    <Row label="Allow same day repeat"  value={data.latest_weekly_config.allow_same_day_repeat ? "Yes" : "No"} />
                    <Row label="Prefer millet"          value={data.latest_weekly_config.prefer_millet ? "Yes" : "No"} />
                  </>
                ) : (
                  <div style={{ fontSize: 12, color: C.muted, textAlign: "center", padding: "8px 0" }}>
                    No questionnaire answered yet this week
                  </div>
                )}
              </Section>

              {/* Last plan generation audit */}
              <Section title="Last Plan Generation Audit" emoji="🔍">
                {(data.last_audit || []).length === 0 ? (
                  <div style={{ fontSize: 12, color: C.muted, textAlign: "center", padding: "8px 0" }}>
                    No plan generated yet
                  </div>
                ) : (
                  (data.last_audit || []).map((a, i) => (
                    <div key={i} style={{ padding: "6px 0", borderBottom: `0.5px solid ${C.border}` }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <span style={{ fontSize: 11, fontWeight: 600, color: C.deepTeal }}>{a.formula}</span>
                        <span style={{ fontSize: 11, color: a.avg_in === a.avg_out ? C.muted : "#E24B4A", fontWeight: 500 }}>
                          {a.avg_in} → {a.avg_out}
                          {a.avg_in !== a.avg_out && ` (-${a.avg_in - a.avg_out})`}
                        </span>
                      </div>
                      <div style={{ fontSize: 10, color: C.muted, marginTop: 2 }}>{a.reason}</div>
                    </div>
                  ))
                )}
              </Section>

              {/* Bucket A formulas status */}
              <Section title="Recommendation Engine" emoji="⚙️">
                <div style={{ display: "flex", flexWrap: "wrap", gap: 4, paddingTop: 4 }}>
                  {(data.bucket_a_formulas || []).map((f, i) => (
                    <Badge
                      key={i}
                      label={`${f.code} ${f.active ? "✓" : "✗"}`}
                      color={f.active ? C.deepTeal : "#E24B4A"}
                      bg={f.active ? "#E1F5EE" : "#FAECE7"}
                    />
                  ))}
                </div>
              </Section>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
