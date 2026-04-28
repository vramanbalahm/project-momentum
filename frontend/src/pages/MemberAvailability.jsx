import { useState, useEffect, useCallback } from "react";
import { useAuth } from "../context/AuthContext";

const C = {
  green: "#1A3A2E", mint: "#9FE1CB", teal: "#5DCAA5",
  card: "#FFF9F2", bg: "#F7F4EE", border: "#EDE8E0",
  text: "#2C2C2A", muted: "#888780",
  amber: "#EF9F27", amberBg: "#FFF3DC",
  errorBg: "#FAECE7", errorText: "#712B13",
  successBg: "#E1F5EE", successText: "#085041",
};

const MEAL_SLOTS = ["Breakfast", "Lunch", "Dinner"];
const MEAL_ICONS = { Breakfast: "🌅", Lunch: "☀️", Dinner: "🌙" };

// Day names aligned to ISO week (Mon=0 … Sun=6)
const DAY_NAMES = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const DAY_FULL  = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

// Avatar colour palette — cycles through members
const AVATAR_COLORS = [
  { bg: "#EEEDFE", text: "#3C3489" },
  { bg: "#E1F5EE", text: "#085041" },
  { bg: "#FAEEDA", text: "#633806" },
  { bg: "#FBEAF0", text: "#72243E" },
  { bg: "#E6F1FB", text: "#0C447C" },
  { bg: "#EAF3DE", text: "#27500A" },
];

function initials(name = "") {
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name.slice(0, 2).toUpperCase();
}

function getMonday(d = new Date()) {
  const day = d.getDay(); // 0=Sun
  const diff = day === 0 ? -6 : 1 - day;
  const mon = new Date(d);
  mon.setDate(d.getDate() + diff);
  mon.setHours(0, 0, 0, 0);
  return mon;
}

function dateStr(d) {
  // Use local date parts to avoid UTC offset shifting the date (critical for IST +5:30)
  const yyyy = d.getFullYear();
  const mm   = String(d.getMonth() + 1).padStart(2, "0");
  const dd   = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function formatDisplayDate(isoStr) {
  const d = new Date(isoStr + "T00:00:00");
  return d.toLocaleDateString("en-IN", { day: "numeric", month: "short" });
}

// Build a set key for (date, slot)
function slotKey(date, slot) { return `${date}__${slot}`; }

export default function MemberAvailability({ onBack, onProceed }) {
  const { apiFetch } = useAuth();

  const [loading, setLoading]   = useState(true);
  const [saving, setSaving]     = useState(false);
  const [error, setError]       = useState(null);
  const [success, setSuccess]   = useState(null);

  const [members, setMembers]   = useState([]);
  const [weekStart, setWeekStart] = useState(""); // YYYY-MM-DD

  // absent: Map<slotKey, Set<user_id>>
  const [absent, setAbsent] = useState({});

  // Which day accordion is open
  const [openDay, setOpenDay] = useState(0);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const monday = getMonday();
      const data = await apiFetch(`/availability/week?week_start=${dateStr(monday)}`);
      setWeekStart(data.week_start);
      setMembers(data.members || []);

      // Build absent map from response
      const map = {};
      for (const slot of data.slots) {
        const key = slotKey(slot.meal_date, slot.meal_slot);
        map[key] = new Set(slot.absent_member_ids || []);
      }
      setAbsent(map);
    } catch (e) {
      setError(e.message || "Failed to load availability.");
    } finally {
      setLoading(false);
    }
  }, [apiFetch]);

  useEffect(() => { load(); }, [load]);

  // Toggle a member's absence for a given date+slot
  const toggle = (mealDate, mealSlot, userId) => {
    const key = slotKey(mealDate, mealSlot);
    setAbsent(prev => {
      const next = { ...prev };
      const set = new Set(next[key] || []);
      if (set.has(userId)) set.delete(userId);
      else set.add(userId);
      next[key] = set;
      return next;
    });
  };

  const isAway = (mealDate, mealSlot, userId) => {
    const key = slotKey(mealDate, mealSlot);
    return (absent[key] || new Set()).has(userId);
  };

  // Summary line for collapsed day
  function daySummary(dayIndex) {
    if (!weekStart || members.length === 0) return "";
    const d = new Date(weekStart + "T00:00:00");
    d.setDate(d.getDate() + dayIndex);
    const dStr = dateStr(d);

    let minPresent = members.length;
    for (const slot of MEAL_SLOTS) {
      const key = slotKey(dStr, slot);
      const absentCount = (absent[key] || new Set()).size;
      const present = members.length - absentCount;
      if (present < minPresent) minPresent = present;
    }

    if (minPresent === members.length) return `All ${members.length} available`;
    return `${minPresent}–${members.length} of ${members.length} available`;
  }

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const slots = [];
      for (let i = 0; i < 7; i++) {
        const d = new Date(weekStart + "T00:00:00");
        d.setDate(d.getDate() + i);
        const dStr = dateStr(d);
        for (const slot of MEAL_SLOTS) {
          const key = slotKey(dStr, slot);
          slots.push({
            meal_date: dStr,
            meal_slot: slot,
            absent_member_ids: [...(absent[key] || new Set())]
          });
        }
      }
      await apiFetch("/availability/save", {
        method: "POST",
        body: JSON.stringify({ week_start_date: weekStart, slots })
      });
      setSuccess("Availability saved for this week.");
      setTimeout(() => setSuccess(null), 4000);
      if (onProceed) setTimeout(onProceed, 800);
    } catch (e) {
      setError(e.message || "Save failed. Please try again.");
      window.scrollTo({ top: 0, behavior: "smooth" });
    } finally {
      setSaving(false);
    }
  };

  // ── Render ──────────────────────────────────────────────────────────────────

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: C.green, padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div
            onClick={onBack}
            style={{ color: C.mint, fontSize: 20, cursor: "pointer", lineHeight: 1, padding: "4px 0" }}
          >←</div>
          <div>
            <div style={{ color: C.mint, fontSize: 11, fontWeight: 500, letterSpacing: "0.05em" }}>MOMENTUM</div>
            <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500, marginTop: 2 }}>Member Availability</div>
            {weekStart && (
              <div style={{ color: C.teal, fontSize: 11, marginTop: 2 }}>
                Week of {formatDisplayDate(weekStart)} — {formatDisplayDate(dateStr((() => { const d = new Date(weekStart + "T00:00:00"); d.setDate(d.getDate() + 6); return d; })()))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ padding: "16px 16px 100px" }}>

        {/* Success banner */}
        {success && (
          <div style={{ background: C.successBg, border: `0.5px solid #9FE1CB`, borderRadius: 10, padding: "12px 16px", marginBottom: 14, color: C.successText, fontSize: 13, fontWeight: 500 }}>
            ✓ {success}
          </div>
        )}

        {/* Error banner */}
        {error && (
          <div style={{ background: C.errorBg, border: `0.5px solid #F0997B`, borderRadius: 10, padding: "12px 16px", marginBottom: 14, color: C.errorText, fontSize: 13 }}>
            {error}
          </div>
        )}

        {/* Loading */}
        {loading && (
          <div style={{ textAlign: "center", padding: "48px 0", color: C.muted, fontSize: 13 }}>
            Loading members…
          </div>
        )}

        {/* Hint */}
        {!loading && !error && (
          <div style={{ fontSize: 12, color: C.muted, marginBottom: 14, lineHeight: 1.5 }}>
            Tap a day to expand · tap an avatar to mark someone away · save when done
          </div>
        )}

        {/* Accordion */}
        {!loading && members.length > 0 && weekStart && DAY_NAMES.map((dayName, i) => {
          const d = new Date(weekStart + "T00:00:00");
          d.setDate(d.getDate() + i);
          const dStr = dateStr(d);
          const isOpen = openDay === i;
          const summary = daySummary(i);
          const hasAway = !summary.startsWith("All");

          return (
            <div
              key={dayName}
              style={{
                background: C.card, borderRadius: 12,
                border: `0.5px solid ${C.border}`,
                marginBottom: 8, overflow: "hidden"
              }}
            >
              {/* Day header */}
              <div
                onClick={() => setOpenDay(isOpen ? -1 : i)}
                style={{
                  display: "flex", alignItems: "center",
                  justifyContent: "space-between",
                  padding: "12px 16px", cursor: "pointer",
                  userSelect: "none"
                }}
              >
                <div>
                  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                    <span style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{DAY_FULL[i]}</span>
                    <span style={{ fontSize: 11, color: C.muted }}>{formatDisplayDate(dStr)}</span>
                  </div>
                  <div style={{ fontSize: 12, color: hasAway ? C.amber : C.teal, marginTop: 3, fontWeight: hasAway ? 500 : 400 }}>
                    {hasAway ? "⚠ " : "✓ "}{summary}
                  </div>
                </div>
                <div style={{ color: C.muted, fontSize: 12, transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
                  ▼
                </div>
              </div>

              {/* Meal slots */}
              {isOpen && (
                <div style={{ borderTop: `0.5px solid ${C.border}` }}>
                  {MEAL_SLOTS.map((slot, si) => {
                    const key = slotKey(dStr, slot);
                    const absentSet = absent[key] || new Set();

                    return (
                      <div
                        key={slot}
                        style={{
                          display: "flex", alignItems: "center",
                          gap: 12, padding: "12px 16px",
                          borderBottom: si < 2 ? `0.5px solid ${C.border}` : "none"
                        }}
                      >
                        {/* Meal label */}
                        <div style={{ width: 72, flexShrink: 0 }}>
                          <div style={{ fontSize: 11, color: C.muted }}>
                            {MEAL_ICONS[slot]} {slot}
                          </div>
                        </div>

                        {/* Avatars */}
                        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                          {members.map((m, mi) => {
                            const away = absentSet.has(m.user_id);
                            const col = AVATAR_COLORS[mi % AVATAR_COLORS.length];
                            return (
                              <div
                                key={m.user_id}
                                onClick={() => toggle(dStr, slot, m.user_id)}
                                title={away ? `${m.name} — Away` : `${m.name} — Present`}
                                style={{
                                  width: 38, height: 38, borderRadius: "50%",
                                  background: away ? "#F0EFEC" : col.bg,
                                  color: away ? C.muted : col.text,
                                  display: "flex", alignItems: "center", justifyContent: "center",
                                  fontSize: 12, fontWeight: 500,
                                  cursor: "pointer", userSelect: "none",
                                  position: "relative",
                                  border: away ? `1.5px solid ${C.border}` : "1.5px solid transparent",
                                  opacity: away ? 0.55 : 1,
                                  transition: "opacity 0.15s"
                                }}
                              >
                                {initials(m.name)}
                                {away && (
                                  <div style={{
                                    position: "absolute", top: -1, right: -1,
                                    width: 10, height: 10, borderRadius: "50%",
                                    background: "#E24B4A",
                                    border: `1.5px solid ${C.card}`
                                  }} />
                                )}
                              </div>
                            );
                          })}
                        </div>

                        {/* Away count badge */}
                        {absentSet.size > 0 && (
                          <div style={{
                            marginLeft: "auto", flexShrink: 0,
                            fontSize: 11, color: "#993C1D",
                            background: "#FAECE7", borderRadius: 20,
                            padding: "2px 8px", fontWeight: 500
                          }}>
                            {absentSet.size} away
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}

        {/* Empty state */}
        {!loading && members.length === 0 && !error && (
          <div style={{ textAlign: "center", padding: "48px 0", color: C.muted, fontSize: 13 }}>
            No household members found.
          </div>
        )}
      </div>

      {/* Sticky save footer */}
      {!loading && members.length > 0 && (
        <div style={{
          position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)",
          width: "100%", maxWidth: 480,
          background: C.card, borderTop: `0.5px solid ${C.border}`,
          padding: "14px 20px", boxSizing: "border-box"
        }}>
          <button
            onClick={handleSave}
            disabled={saving}
            style={{
              width: "100%", padding: "14px",
              background: saving ? "#5DCAA5" : C.green,
              color: "#FDFCF8", border: "none",
              borderRadius: 12, fontSize: 15, fontWeight: 500,
              cursor: saving ? "default" : "pointer",
              transition: "background 0.2s"
            }}
          >
            {saving ? "Saving…" : "Save Availability"}
          </button>
        </div>
      )}
    </div>
  );
}
