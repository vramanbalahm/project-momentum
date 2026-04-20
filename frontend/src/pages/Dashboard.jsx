import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import ChangePassword from "./ChangePassword";

const COLORS = {
  bg: "#1A3A2E",
  card: "#FFF9F2",
  green: "#1A3A2E",
  mint: "#9FE1CB",
  amber: "#EF9F27",
  text: "#2C2C2A",
  muted: "#888780",
  border: "#EDE8E0",
};

export default function Dashboard({ onNavigate }) {
  const { user, logout } = useAuth();
  const [menuOpen, setMenuOpen] = useState(false);
  const [showChangePassword, setShowChangePassword] = useState(false);

  const isAdmin = user?.role === "household_admin" || user?.role === "platform_admin";

  const initials = (user?.name || "U")
    .split(" ").map(w => w[0]).join("").toUpperCase().slice(0, 2);

  const tiles = [
    {
      id: "weekly_plan",
      icon: "📅",
      label: "Weekly Plan",
      desc: "Plan your week's meals",
      color: "#E1F5EE",
      available: true,
    },
    {
      id: "family_profile",
      icon: "🏠",
      label: "Family Profile",
      desc: isAdmin ? "Update household settings" : "Admin access only",
      color: "#FFF3DC",
      available: isAdmin,
    },
    {
      id: "manage_members",
      icon: "👥",
      label: "Manage Members",
      desc: isAdmin ? "Add, promote or manage members" : "Admin access only",
      color: "#EEEDFE",
      available: isAdmin,
    },
    {
      id: "coming_soon_1",
      icon: "🛒",
      label: "Market Prices",
      desc: "Coming soon",
      color: "#F5F5F5",
      available: false,
    },
  ];

  return (
    <div style={{ minHeight: "100vh", background: "#F7F4EE", fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* ── Top bar ── */}
      <div style={{ background: COLORS.bg, padding: "16px 20px 20px", position: "relative", zIndex: 10 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <div style={{ color: COLORS.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>MOMENTUM</div>
            <div style={{ color: "#FDFCF8", fontSize: 18, fontWeight: 500, marginTop: 2 }}>
              Good {getGreeting()}, {user?.name?.split(" ")[0] || "there"} 👋
            </div>
            <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>{user?.house_name}</div>
          </div>

          {/* Avatar / initials button */}
          <div
            onClick={() => setMenuOpen(!menuOpen)}
            style={{
              width: 40, height: 40, borderRadius: "50%",
              background: COLORS.mint, color: COLORS.green,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 14, fontWeight: 700, cursor: "pointer",
              position: "relative", userSelect: "none"
            }}
          >
            {initials}
          </div>
        </div>

        {/* Role badge */}
        <div style={{ marginTop: 12 }}>
          <span style={{
            background: isAdmin ? "rgba(159,225,203,0.15)" : "rgba(255,255,255,0.08)",
            color: isAdmin ? COLORS.mint : "#5DCAA5",
            fontSize: 10, fontWeight: 600, padding: "3px 10px",
            borderRadius: 20, letterSpacing: "0.04em",
            border: `0.5px solid ${isAdmin ? "rgba(159,225,203,0.3)" : "rgba(255,255,255,0.1)"}`
          }}>
            {isAdmin ? "HOUSEHOLD ADMIN" : "MEMBER"}
          </span>
        </div>
      </div>

      {/* ── User menu dropdown ── */}
      {menuOpen && (
        <>
          <div
            onClick={() => setMenuOpen(false)}
            style={{ position: "fixed", inset: 0, zIndex: 40 }}
          />
          <div style={{
            position: "absolute", top: 56, right: 20, zIndex: 50,
            background: COLORS.card, borderRadius: 14,
            boxShadow: "0 8px 32px rgba(0,0,0,0.12)",
            border: `0.5px solid ${COLORS.border}`,
            overflow: "hidden", minWidth: 200
          }}>
            <div style={{ padding: "12px 16px", borderBottom: `0.5px solid ${COLORS.border}` }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: COLORS.text }}>{user?.name}</div>
              <div style={{ fontSize: 11, color: COLORS.muted, marginTop: 2 }}>{user?.email}</div>
            </div>
            <MenuItem icon="🔑" label="Change Password" onClick={() => { setMenuOpen(false); setShowChangePassword(true); }} />
            <MenuItem icon="🚪" label="Logout" onClick={logout} danger />
          </div>
        </>
      )}

      {/* ── Tiles grid ── */}
      <div style={{ padding: "24px 20px" }}>
        <div style={{ fontSize: 11, color: COLORS.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>
          What would you like to do?
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {tiles.map(tile => (
            <div
              key={tile.id}
              onClick={() => tile.available && onNavigate(tile.id)}
              style={{
                background: tile.available ? COLORS.card : "#F0EFEC",
                borderRadius: 16, padding: "20px 16px",
                border: `0.5px solid ${COLORS.border}`,
                cursor: tile.available ? "pointer" : "default",
                opacity: tile.available ? 1 : 0.6,
                transition: "transform 0.1s",
                boxShadow: tile.available ? "0 2px 8px rgba(0,0,0,0.04)" : "none"
              }}
            >
              <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: tile.color, display: "flex",
                alignItems: "center", justifyContent: "center",
                fontSize: 20, marginBottom: 12
              }}>
                {tile.icon}
              </div>
              <div style={{ fontSize: 13, fontWeight: 600, color: tile.available ? COLORS.text : COLORS.muted }}>
                {tile.label}
              </div>
              <div style={{ fontSize: 11, color: COLORS.muted, marginTop: 4, lineHeight: 1.4 }}>
                {tile.desc}
              </div>
              {!tile.available && tile.id !== "coming_soon_1" && (
                <div style={{ marginTop: 8, fontSize: 10, color: "#C4A882", fontWeight: 500 }}>🔒 Admin only</div>
              )}
              {tile.id === "coming_soon_1" && (
                <div style={{ marginTop: 8, fontSize: 10, color: COLORS.muted, fontWeight: 500 }}>⏳ Coming soon</div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* ── Change Password modal ── */}
      {showChangePassword && (
        <ChangePassword onClose={() => setShowChangePassword(false)} />
      )}
    </div>
  );
}

function MenuItem({ icon, label, onClick, danger }) {
  return (
    <div
      onClick={onClick}
      style={{
        padding: "12px 16px", display: "flex", alignItems: "center", gap: 10,
        cursor: "pointer", fontSize: 13,
        color: danger ? "#C0392B" : COLORS.text,
        borderBottom: `0.5px solid ${COLORS.border}`
      }}
    >
      <span>{icon}</span>
      <span>{label}</span>
    </div>
  );
}

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 17) return "afternoon";
  return "evening";
}
