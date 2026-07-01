import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";

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
  selected: "#E1F5EE",
};

export default function WeeklyQuestionnaire({ onGenerate, onClose }) {
  const { apiFetch } = useAuth();
  const { t } = useTranslation();

  const [config, setConfig] = useState({
    continental_days:       0,
    allow_same_day_repeat:  false,
    allow_same_week_repeat: true,
    prefer_millet:          false,
    pantry_only:            false,
  });
  const [weeksCollected, setWeeksCollected] = useState(0);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    // Load existing config for this week
    Promise.all([
      apiFetch("/weekly-config"),
      apiFetch("/weekly-config/should-ask"),
    ]).then(([cfg, status]) => {
      setConfig({
        continental_days:       cfg.continental_days,
        allow_same_day_repeat:  cfg.allow_same_day_repeat,
        allow_same_week_repeat: cfg.allow_same_week_repeat,
        prefer_millet:          cfg.prefer_millet,
        pantry_only:            cfg.pantry_only || false,
      });
      setWeeksCollected(status.weeks_collected);
    }).catch(() => {});
  }, []);

  const handleGenerate = async () => {
    setSaving(true);
    try {
      // Save questionnaire answers
      await apiFetch("/weekly-config", {
        method: "POST",
        body: JSON.stringify(config),
      });
      // Trigger plan generation with config
      onGenerate(config);
    } catch (e) {
      console.error("Failed to save config:", e);
      onGenerate(config); // still generate even if save fails
    } finally {
      setSaving(false);
    }
  };

  const toggle = (key) => setConfig(prev => ({ ...prev, [key]: !prev[key] }));

  return (
    <div style={{
      position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)",
      zIndex: 300, display: "flex", alignItems: "flex-end", justifyContent: "center"
    }}>
      <div style={{
        width: "100%", maxWidth: 430,
        background: C.card, borderRadius: "20px 20px 0 0",
        padding: "24px 20px 32px",
      }}>
        {/* Header */}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
          <div style={{ fontSize: 16, fontWeight: 600, color: C.text }}>✨ This week's preferences</div>
          <span onClick={onClose} style={{ color: C.muted, fontSize: 18, cursor: "pointer" }}>✕</span>
        </div>
        <div style={{ fontSize: 11, color: C.muted, marginBottom: 20 }}>
          {weeksCollected < 8
            ? `Week ${weeksCollected + 1} of 8 — helping us learn your family's preferences`
            : "Using your learned preference profile"}
        </div>

        {/* Q1 — Continental breakfast days */}
        <div style={{ marginBottom: 20 }}>
          <div style={{ fontSize: 13, fontWeight: 500, color: C.text, marginBottom: 4 }}>
            🥐 How many days would you like continental breakfast?
          </div>
          <div style={{ fontSize: 11, color: C.muted, marginBottom: 10 }}>
            Bread, oats, cornflakes etc. — rest will be traditional
          </div>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {[0,1,2,3,4,5,6,7].map(n => (
              <div key={n} onClick={() => setConfig(prev => ({ ...prev, continental_days: n }))}
                style={{
                  width: 36, height: 36, borderRadius: 10,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 13, fontWeight: 500, cursor: "pointer",
                  background: config.continental_days === n ? C.green : C.bg,
                  color: config.continental_days === n ? C.mint : C.text,
                  border: `0.5px solid ${config.continental_days === n ? C.teal : C.border}`,
                }}>
                {n}
              </div>
            ))}
          </div>
        </div>

        {/* Q3 — Same week repeat */}
        <div style={{ marginBottom: 16 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "12px 14px", background: C.bg, borderRadius: 12, border: `0.5px solid ${C.border}` }}>
            <div>
              <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>
                🔄 Allow same dish to repeat this week?
              </div>
              <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>
                e.g. Idli on Monday and again on Wednesday
              </div>
            </div>
            <div onClick={() => toggle("allow_same_week_repeat")}
              style={{
                width: 44, height: 24, borderRadius: 12, cursor: "pointer",
                background: config.allow_same_week_repeat ? C.teal : "#D1CFC8",
                position: "relative", flexShrink: 0, transition: "background 0.2s"
              }}>
              <div style={{
                position: "absolute", top: 4,
                left: config.allow_same_week_repeat ? 22 : 4,
                width: 16, height: 16, borderRadius: "50%",
                background: "white", transition: "left 0.2s"
              }} />
            </div>
          </div>
        </div>

        {/* Q2 — Same day repeat */}
        <div style={{ marginBottom: 16 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "12px 14px", background: C.bg, borderRadius: 12, border: `0.5px solid ${C.border}` }}>
            <div>
              <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>
                🍽️ Allow same dish across meals in a day?
              </div>
              <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>
                e.g. Idli for breakfast and dinner same day
              </div>
            </div>
            <div onClick={() => toggle("allow_same_day_repeat")}
              style={{
                width: 44, height: 24, borderRadius: 12, cursor: "pointer",
                background: config.allow_same_day_repeat ? C.teal : "#D1CFC8",
                position: "relative", flexShrink: 0, transition: "background 0.2s"
              }}>
              <div style={{
                position: "absolute", top: 4,
                left: config.allow_same_day_repeat ? 22 : 4,
                width: 16, height: 16, borderRadius: "50%",
                background: "white", transition: "left 0.2s"
              }} />
            </div>
          </div>
        </div>

        {/* Q4 — Millet preference */}
        <div style={{ marginBottom: 24 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "12px 14px", background: C.bg, borderRadius: 12, border: `0.5px solid ${C.border}` }}>
            <div>
              <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>
                🌾 Prefer millet-based dishes this week?
              </div>
              <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>
                Ragi, kambu, thinai, varagu etc.
              </div>
            </div>
            <div onClick={() => toggle("prefer_millet")}
              style={{
                width: 44, height: 24, borderRadius: 12, cursor: "pointer",
                background: config.prefer_millet ? C.teal : "#D1CFC8",
                position: "relative", flexShrink: 0, transition: "background 0.2s"
              }}>
              <div style={{
                position: "absolute", top: 4,
                left: config.prefer_millet ? 22 : 4,
                width: 16, height: 16, borderRadius: "50%",
                background: "white", transition: "left 0.2s"
              }} />
            </div>
          </div>
        </div>

          {/* Pantry toggle */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 0", borderBottom: `0.5px solid ${C.border}` }}>
            <div style={{ flex: 1, paddingRight: 12 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>
                🧊 Prioritise pantry ingredients?
              </div>
              <div style={{ fontSize: 11, color: C.muted, marginTop: 2 }}>
                Only use ingredients currently in your pantry
              </div>
            </div>
            <div onClick={() => toggle("pantry_only")}
              style={{
                width: 44, height: 24, borderRadius: 12, cursor: "pointer",
                background: config.pantry_only ? C.teal : "#D1CFC8",
                position: "relative", flexShrink: 0, transition: "background 0.2s"
              }}>
              <div style={{
                position: "absolute", top: 4,
                left: config.pantry_only ? 22 : 4,
                width: 16, height: 16, borderRadius: "50%",
                background: "white", transition: "left 0.2s"
              }} />
            </div>
          </div>
        </div>

        {/* Generate button */}
        <button onClick={handleGenerate} disabled={saving}
          style={{
            width: "100%", background: C.green, color: C.mint,
            border: "none", borderRadius: 14, padding: "14px",
            fontSize: 14, fontWeight: 500,
            cursor: saving ? "not-allowed" : "pointer",
            opacity: saving ? 0.7 : 1,
          }}>
          {saving ? "Saving preferences..." : "✨ Generate plan"}
        </button>
      </div>
    </div>
  );
}
