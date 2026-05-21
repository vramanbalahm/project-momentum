import { useState } from "react";
import { useTranslation } from "react-i18next";
import SatvikEditor from "../components/SatvikEditor.jsx";
import LunarEditor  from "../components/LunarEditor.jsx";
import EventEditor  from "../components/EventEditor.jsx";
import { C } from "../components/householdShared.jsx";

// HouseholdSettings — admin-only screen accessible from Dashboard.
// Acts as a menu; each item navigates to the corresponding editor.
// Editors are the same components used in OnboardingWizard — no duplication.



export default function HouseholdSettings({ onBack }) {
  const { t } = useTranslation();
  const [activeEditor, setActiveEditor] = useState(null);

  const MENU_ITEMS = [
    { id: "satvik", icon: "🕉️", label: t("householdSettings.satvik.label"), desc: t("householdSettings.satvik.desc"), color: "#E1F5EE" },
    { id: "lunar",  icon: "🌙", label: t("householdSettings.lunar.label"),  desc: t("householdSettings.lunar.desc"),  color: "#EEEDFE" },
    { id: "events", icon: "🎂", label: t("householdSettings.events.label"), desc: t("householdSettings.events.desc"), color: "#FAEEDA" },
  ]; // null | "satvik" | "lunar" | "events"

  // ── Editor screens ────────────────────────────────────────────────────────
  if (activeEditor === "satvik") {
    return (
      <EditorShell title={t("householdSettings.satvik.label")} testId="editor-satvik" onBack={() => setActiveEditor(null)}>
        <SatvikEditor
          onDone={null}
          nextLabel={t("common.save")}
        />
      </EditorShell>
    );
  }

  if (activeEditor === "lunar") {
    return (
      <EditorShell title={t("householdSettings.lunar.label")} testId="editor-lunar" onBack={() => setActiveEditor(null)}>
        <LunarEditor
          onDone={null}
          nextLabel={t("common.save")}
        />
      </EditorShell>
    );
  }

  if (activeEditor === "events") {
    return (
      <EditorShell title={t("householdSettings.events.label")} testId="editor-events" onBack={() => setActiveEditor(null)}>
        <EventEditor
          onDone={null}
          nextLabel={t("common.save")}
        />
      </EditorShell>
    );
  }

  // ── Menu screen ───────────────────────────────────────────────────────────
  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ color: "#9FE1CB", fontSize: 12, cursor: "pointer", marginBottom: 6 }} onClick={onBack}>
          {t("householdSettings.backToDashboard")}
        </div>
        <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500 }}>{t("householdSettings.title")}</div>
        <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>{t("householdSettings.subtitle")}</div>
      </div>

      {/* Menu items */}
      <div style={{ padding: "24px 20px" }}>
        <div style={{ fontSize: 11, color: C.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>
          {t("householdSettings.settings")}
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {MENU_ITEMS.map(item => (
            <div
              key={item.id}
              onClick={() => setActiveEditor(item.id)}
              style={{
                background: "#FFF9F2", borderRadius: 16, padding: "16px",
                border: `0.5px solid ${C.border}`, cursor: "pointer",
                display: "flex", alignItems: "center", gap: 14,
                boxShadow: "0 2px 8px rgba(0,0,0,0.04)",
              }}
            >
              <div style={{
                width: 44, height: 44, borderRadius: 12,
                background: item.color, display: "flex",
                alignItems: "center", justifyContent: "center", fontSize: 22, flexShrink: 0
              }}>
                {item.icon}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{item.label}</div>
                <div style={{ fontSize: 12, color: C.muted, marginTop: 2 }}>{item.desc}</div>
              </div>
              <div style={{ color: C.muted, fontSize: 18 }}>›</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// Shell wrapper for each editor — provides header with back nav
function EditorShell({ title, onBack, children, testId }) {
  const { t } = useTranslation();
  return (
    <div data-testid={testId} style={{ minHeight: "100vh", background: "#1A3A2E", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", fontFamily: "system-ui, sans-serif", padding: "24px 0" }}>
      <div style={{ width: "100%", maxWidth: 400, padding: "0 16px" }}>
        <div style={{ background: C.card, borderRadius: 20, padding: "20px 18px", position: "relative" }}>
          <div onClick={onBack} style={{ fontSize: 12, color: C.muted, cursor: "pointer", marginBottom: 12 }}>
            {t("householdSettings.backToSettings")}
          </div>
          {children}
        </div>
      </div>
    </div>
  );
}
