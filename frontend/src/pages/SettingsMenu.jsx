import { useTranslation } from "react-i18next";
import { useAuth } from "../context/AuthContext";
import { C } from "../components/householdShared.jsx";

// SettingsMenu — single consolidated entry point for the three previously
// scattered settings surfaces (My Profile, My Config, Household Settings).
// Each row navigates to its existing, unchanged screen via onNavigate --
// this is purely a shared front door, nothing about those screens changes.

export default function SettingsMenu({ onBack, onNavigate }) {
  const { t } = useTranslation();
  const { user } = useAuth();
  const isAdmin = user?.role === "household_admin" || user?.role === "platform_admin";

  const MENU_ITEMS = [
    { id: "my_profile", icon: "👤", label: t("settingsMenu.myProfile.label"), desc: t("settingsMenu.myProfile.desc"), color: "#E1F5EE", available: true },
    { id: "my_config",  icon: "🔍", label: t("settingsMenu.myConfig.label"),  desc: t("settingsMenu.myConfig.desc"),  color: "#EEF0FE", available: true },
    // Household Settings edits Satvik/Lunar/Events for the whole household --
    // admin-only today via the Dashboard tile gate, replicated here since
    // HouseholdSettings.jsx itself has no internal check of its own.
    { id: "household_settings", icon: "⚙️", label: t("settingsMenu.householdSettings.label"), desc: isAdmin ? t("settingsMenu.householdSettings.desc") : t("dashboard.menu.adminOnly"), color: "#FAEEDA", available: isAdmin },
  ];

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ color: "#9FE1CB", fontSize: 12, cursor: "pointer", marginBottom: 6 }} onClick={onBack}>
          {t("householdSettings.backToDashboard")}
        </div>
        <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500 }}>{t("settingsMenu.title")}</div>
        <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>{t("settingsMenu.subtitle")}</div>
      </div>

      {/* Menu items */}
      <div style={{ padding: "24px 20px" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {MENU_ITEMS.map(item => (
            <div
              key={item.id}
              data-testid={`settings-row-${item.id}`}
              onClick={() => item.available && onNavigate(item.id)}
              style={{
                background: "#FFF9F2", borderRadius: 16, padding: "16px",
                border: `0.5px solid ${C.border}`, cursor: item.available ? "pointer" : "not-allowed",
                opacity: item.available ? 1 : 0.55,
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
              {item.available && <div style={{ color: C.muted, fontSize: 18 }}>›</div>}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
