import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import ChangePassword from "./ChangePassword";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

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
  const [checkingAvailability, setCheckingAvailability] = useState(false);

  const isAdmin = user?.role === "household_admin" || user?.role === "platform_admin";
  const isReviewer = user?.role === "platform_admin" || user?.role === "reviewer";
  const isReviewerOnly = user?.role === "reviewer"; // pure reviewer — no household access

  // Smart Weekly Plan navigation — admin checks availability first, member goes straight to planner
  const handleWeeklyPlanTap = async () => {
    // reviewers now navigate via Recipe Review tile
    if (!isAdmin) {
      onNavigate("weekly_plan");
      return;
    }
    setCheckingAvailability(true);
    try {
      const token = localStorage.getItem("access_token");
      const today = new Date();
      const day = today.getDay();
      const diff = day === 0 ? -6 : 1 - day;
      const monday = new Date(today);
      monday.setDate(today.getDate() + diff);
      const yyyy = monday.getFullYear();
      const mm = String(monday.getMonth() + 1).padStart(2, "0");
      const dd = String(monday.getDate()).padStart(2, "0");
      const weekStart = `${yyyy}-${mm}-${dd}`;
      const res = await fetch(`${API_BASE}/availability/week?week_start=${weekStart}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        // has_saved = true means rows exist in DB for this week — go straight to planner
        onNavigate(data.has_saved ? "weekly_plan" : "member_availability");
      } else {
        onNavigate("member_availability");
      }
    } catch {
      onNavigate("member_availability");
    } finally {
      setCheckingAvailability(false);
    }
  };

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
      id: "member_availability",
      icon: "🗓️",
      label: "Availability",
      desc: "Who's home this week",
      color: "#FFF3DC",
      available: true,
    },
    {
      id: "family_profile",
      icon: "🏠",
      label: "Family Profile",
      desc: isAdmin ? "Update household settings" : "Admin access only",
      color: "#E6F1FB",
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
      id: "household_settings",
      icon: "⚙️",
      label: "Household Settings",
      desc: isAdmin ? "Satvik, lunar & events" : "Admin access only",
      color: "#FAEEDA",
      available: isAdmin,
    },
    {
      id: "recipe_review",
      icon: "📋",
      label: "Recipe Review",
      desc: "Review and approve recipes",
      color: "#E1F5EE",
      available: true,
      hidden: !isReviewer,
    },
    {
      id: "reviewer_progress",
      icon: "📊",
      label: "Review Progress",
      desc: user?.role === "platform_admin" ? "Reviewer stats & progress" : "",
      color: "#E6F1FB",
      available: user?.role === "platform_admin",
      hidden: user?.role !== "platform_admin",
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

          {/* ── Top right — logout + settings icons ── */}
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>

            {/* Settings icon — opens dropdown */}
            <div style={{ position: "relative" }}>
              <div
                onClick={() => setMenuOpen(!menuOpen)}
                title="Settings"
                style={{
                  width: 38, height: 38, borderRadius: 10,
                  background: "rgba(159,225,203,0.12)",
                  border: "0.5px solid rgba(159,225,203,0.25)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 18, cursor: "pointer", userSelect: "none"
                }}
              >
                ⚙️
              </div>

              {/* Settings dropdown */}
              {menuOpen && (
                <>
                  <div
                    onClick={() => setMenuOpen(false)}
                    style={{ position: "fixed", inset: 0, zIndex: 40 }}
                  />
                  <div style={{
                    position: "absolute", top: 44, right: 0, zIndex: 50,
                    background: COLORS.card, borderRadius: 14,
                    boxShadow: "0 8px 32px rgba(0,0,0,0.14)",
                    border: `0.5px solid ${COLORS.border}`,
                    overflow: "hidden", minWidth: 210
                  }}>
                    {/* User info header */}
                    <div style={{ padding: "12px 16px", borderBottom: `0.5px solid ${COLORS.border}`, background: "#F7F4EE" }}>
                      <div style={{ fontSize: 13, fontWeight: 600, color: COLORS.text }}>{user?.name}</div>
                      <div style={{ fontSize: 11, color: COLORS.muted, marginTop: 2 }}>{user?.email}</div>
                      <div style={{ fontSize: 10, color: isAdmin ? "#1A3A2E" : COLORS.muted, fontWeight: 600, marginTop: 4, textTransform: "uppercase", letterSpacing: "0.04em" }}>
                        {isAdmin ? "Household Admin" : isReviewer ? "Reviewer" : "Member"}
                      </div>
                    </div>

                    {/* My Profile — not for reviewer */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="👤"
                        label="My Profile"
                        available={true}
                        onClick={() => { setMenuOpen(false); onNavigate("my_profile"); }}
                      />
                    )}

                    {/* Member Availability — not for reviewer */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="🗓️"
                        label="Member Availability"
                        available={true}
                        onClick={() => { setMenuOpen(false); onNavigate("member_availability"); }}
                      />
                    )}

                    {/* Recipe Review — platform admin and reviewer only */}
                    {isReviewer && (
                      <SettingsItem
                        icon="📋"
                        label="Recipe Review"
                        available={true}
                        onClick={() => { setMenuOpen(false); onNavigate("recipe_review"); }}
                      />
                    )}

                    {/* Change Password — not for reviewer */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="🔑"
                        label="Change Password"
                        available={true}
                        onClick={() => { setMenuOpen(false); setShowChangePassword(true); }}
                      />
                    )}

                    {/* Family Profile — admin only */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="🏠"
                        label="Family Profile"
                        available={isAdmin}
                        onClick={() => { setMenuOpen(false); onNavigate("family_profile"); }}
                      />
                    )}

                    {/* Manage Members — admin only */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="👥"
                        label="Manage Members"
                        available={isAdmin}
                        onClick={() => { setMenuOpen(false); onNavigate("manage_members"); }}
                      />
                    )}

                    {/* Household Settings — admin only */}
                    {!isReviewerOnly && (
                      <SettingsItem
                        icon="⚙️"
                        label="Household Settings"
                        available={isAdmin}
                        onClick={() => { setMenuOpen(false); onNavigate("household_settings"); }}
                      />
                    )}
                  </div>
                </>
              )}
            </div>

            {/* Logout icon — direct tap, no dropdown */}
            <div
              onClick={logout}
              title="Logout"
              style={{
                width: 38, height: 38, borderRadius: 10,
                background: "rgba(255,100,80,0.12)",
                border: "0.5px solid rgba(255,100,80,0.25)",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 18, cursor: "pointer", userSelect: "none"
              }}
            >
              🚪
            </div>
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

      {/* ── Tiles grid ── */}
      <div style={{ padding: "24px 20px" }}>
        <div style={{ fontSize: 11, color: COLORS.muted, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 16 }}>
          What would you like to do?
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {tiles.filter(tile => !tile.hidden && (isReviewerOnly ? tile.id === "recipe_review" : true)).map(tile => (
            <div
              key={tile.id}
              onClick={() => {
              if (!tile.available) return;
              if (tile.id === "weekly_plan") { handleWeeklyPlanTap(); return; }
              onNavigate(tile.id);
            }}
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
                {tile.id === "weekly_plan" && checkingAvailability ? "Checking…" : tile.label}
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

function SettingsItem({ icon, label, available, onClick }) {
  return (
    <div
      onClick={available ? onClick : undefined}
      style={{
        padding: "12px 16px", display: "flex", alignItems: "center", gap: 10,
        cursor: available ? "pointer" : "default",
        fontSize: 13,
        color: available ? COLORS.text : COLORS.muted,
        borderBottom: `0.5px solid ${COLORS.border}`,
        opacity: available ? 1 : 0.5,
        background: "transparent"
      }}
    >
      <span style={{ fontSize: 16 }}>{icon}</span>
      <span style={{ flex: 1 }}>{label}</span>
      {!available && <span style={{ fontSize: 10, color: "#C4A882", fontWeight: 500 }}>🔒 Admin</span>}
    </div>
  );
}

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 17) return "afternoon";
  return "evening";
}
