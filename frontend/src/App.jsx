import React, { useState, useEffect } from 'react';
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import axios from 'axios';

// Component Imports
import DayColumn from './components/DayColumn';
import MealCard from './components/MealCard';
import MealEditor from './components/MealEditor';

const API_BASE = "http://localhost:8000";
const HH_ID = "HOUSEHOLD_001";
const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const MEAL_TYPES = ['Breakfast', 'Lunch', 'Dinner'];

// --- Date utilities — pure local arithmetic, no toISOString() to avoid IST/UTC shift ---

// Format a Date object as YYYY-MM-DD using local date parts (never UTC)
const toLocalDateString = (d) => {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
};

// Get this week's Monday as a Date (local time)
const getCurrentWeekMonday = () => {
  const today = new Date();
  const day = today.getDay(); // 0=Sun, 1=Mon ... 6=Sat
  const diff = day === 0 ? -6 : 1 - day;
  const monday = new Date(today);
  monday.setDate(today.getDate() + diff);
  monday.setHours(0, 0, 0, 0);
  return monday;
};

// Returns YYYY-MM-DD for a given day name in the current week (local date)
const getTargetDate = (dayName) => {
  const monday = getCurrentWeekMonday();
  monday.setDate(monday.getDate() + DAYS.indexOf(dayName));
  return toLocalDateString(monday);
};

// Day-of-month number for ribbon display
const formatDisplayDate = (dayName) => {
  const parts = getTargetDate(dayName).split('-');
  return parseInt(parts[2], 10);
};

const getMonthLabel = (dayName) => {
  const parts = getTargetDate(dayName).split('-');
  const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
  return d.toLocaleDateString('en-IN', { month: 'short' }).toUpperCase();
};

// Today check — compare local date strings directly
const isToday = (dayName) => {
  return getTargetDate(dayName) === toLocalDateString(new Date());
};

// Event date label for event banner
const getEventDateLabel = (dayName) => {
  const parts = getTargetDate(dayName).split('-');
  const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
  return d.toLocaleDateString('en-IN', { weekday: 'short', day: 'numeric', month: 'short' });
};

const MEAL_CONFIG = {
  Breakfast: { icon: '☀️', color: '#FFF3DC', time: '7:00 – 9:00 am' },
  Lunch:     { icon: '🌿', color: '#E1F5EE', time: '12:30 – 2:00 pm' },
  Dinner:    { icon: '🌙', color: '#EEEDFE', time: '7:30 – 9:00 pm' }
};

// FIX 3: Week overview thumbnail card — with +N sides indicator
const WeekThumbCard = ({ meal, onClick }) => {
  const main = meal?.main;
  const sides = meal?.sides || [];
  let imgUrl = main?.thumb || main?.hero;
  if (!imgUrl && main?.name) {
    imgUrl = `/assets/meals/${main.name.toLowerCase().replace(/\s+/g, '_')}.png`;
  }
  return (
    <div
      onClick={onClick}
      style={{
        width: "100%", height: 64, borderRadius: 10,
        overflow: "hidden", background: "#EDE8E0",
        position: "relative", cursor: "pointer",
        border: "1px solid #E0DBD3"
      }}
    >
      {imgUrl ? (
        <img
          src={imgUrl}
          alt={main?.name || "Meal"}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
          onError={(e) => {
            e.target.onerror = null;
            e.target.style.display = "none";
          }}
        />
      ) : null}

      {/* +N sides badge — top right corner */}
      {sides.length > 0 && (
        <div style={{
          position: "absolute", top: 4, right: 4,
          background: "rgba(26,58,46,0.85)",
          color: "#9FE1CB",
          fontSize: 8, fontWeight: 500,
          padding: "2px 5px", borderRadius: 8,
          lineHeight: 1.2
        }}>
          +{sides.length}
        </div>
      )}

      {/* Dish name overlay — bottom */}
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        background: "linear-gradient(to top, rgba(26,58,46,0.85), transparent)",
        padding: "16px 5px 4px"
      }}>
        <div style={{
          color: "#fff", fontSize: 8, fontWeight: 500,
          lineHeight: 1.2, textAlign: "center",
          overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap"
        }}>
          {main?.name ? main.name.split(' ').slice(0, 2).join(' ') : "—"}
        </div>
      </div>
    </div>
  );
};

export default function App() {
  const [blueprint, setBlueprint] = useState({});
  const [suggestions, setSuggestions] = useState([]);
  const [auditResults, setAuditResults] = useState({});
  const [editing, setEditing] = useState(null);
  const [isAudited, setIsAudited] = useState(false);
  const [isDirty, setIsDirty] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  // Week navigation — 0 = current week, negative = past weeks, positive blocked for MVP
  const [weekOffset, setWeekOffset] = useState(0);
  const [showCopyConfirm, setShowCopyConfirm] = useState(false);
  const [hasNextWeekData, setHasNextWeekData] = useState(false);
  // Session constants — fetched once on load, cached for session
  const [oldestPlanWeekOffset, setOldestPlanWeekOffset] = useState(null); // null = no history at all
  const [memberCount, setMemberCount] = useState(0);

  // FIX 3: View mode — 'day' or 'week'
  const [viewMode, setViewMode] = useState('day');

  const [selectedDay, setSelectedDay] = useState(() => {
    const today = new Date();
    const dayNames = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    const todayName = dayNames[today.getDay()];
    return DAYS.includes(todayName) ? todayName : 'Monday';
  });

  // Week-offset aware date helpers
  const getOffsetWeekMonday = () => {
    const monday = getCurrentWeekMonday();
    monday.setDate(monday.getDate() + weekOffset * 7);
    return monday;
  };

  const getOffsetTargetDate = (dayName) => {
    const monday = getOffsetWeekMonday();
    monday.setDate(monday.getDate() + DAYS.indexOf(dayName));
    return toLocalDateString(monday);
  };

  const getWeekLabel = () => {
    const monday = getOffsetWeekMonday();
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    const fmt = (d) => d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
    return `${fmt(monday)} – ${fmt(sunday)}`;
  };

  const isCurrentWeek = weekOffset === 0;

  // Copy previous week blueprint into current week draft
  const copyToCurrentWeek = () => {
    // Remap blueprint keys from offset week dates → current week dates
    const copied = {};
    DAYS.forEach(day => {
      MEAL_TYPES.forEach(type => {
        const sourceKey = `${day}-${type}`;
        if (blueprint[sourceKey]) {
          copied[sourceKey] = { ...blueprint[sourceKey] };
        }
      });
    });
    setWeekOffset(0);
    setBlueprint(copied);
    setIsAudited(false);
    setIsSaved(false);
    setIsDirty(true);
    setShowCopyConfirm(false);
    setSelectedDay(DAYS[0]); // Jump to Monday of current week
    setViewMode('day');
  };

  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor));

  // Load plan whenever weekOffset changes
  // weekOffset === 0 reloads current week (fixes returning from past week showing stale data)
  useEffect(() => {
    const loadWeekPlan = async () => {
      setIsLoading(true);
      try {
        const monday = getOffsetWeekMonday();
        const mondayStr = toLocalDateString(monday);
        const planRes = await axios.get(`${API_BASE}/get-plan/${HH_ID}?week_start=${mondayStr}`);
        const weekMap = {};
        const hasPlan = planRes.data?.plan && planRes.data.plan.length > 0;

        if (hasPlan) {
          planRes.data.plan.forEach(slot => {
            const [yyyy, mm, dd] = slot.date.split('-').map(Number);
            const dateObj = new Date(yyyy, mm - 1, dd);
            const dayName = dateObj.toLocaleDateString('en-US', { weekday: 'long' });
            if (slot.main && slot.main.name !== "Skipped") {
              weekMap[`${dayName}-${slot.type}`] = {
                main: slot.main,
                sides: slot.sides || [],
                event_id: slot.event_id
              };
            }
          });
        }

        // Check if next week (offset+1) has data — gates >> button
        const nextMonday = new Date(monday);
        nextMonday.setDate(monday.getDate() + 7);
        const nextMondayStr = toLocalDateString(nextMonday);
        const nextRes = await axios.get(`${API_BASE}/get-plan/${HH_ID}?week_start=${nextMondayStr}`);
        setHasNextWeekData(nextRes.data?.plan && nextRes.data.plan.length > 0);

        if (weekOffset === 0) {
          // Current week: fill gaps with suggestions
          let suggestionIdx = 0;
          DAYS.forEach(day => {
            MEAL_TYPES.forEach(type => {
              const key = `${day}-${type}`;
              if (!weekMap[key]) {
                const sugg = suggestions[suggestionIdx % (suggestions.length || 1)];
                if (sugg) {
                  weekMap[key] = {
                    main: { name: sugg.name, recipe_id: sugg.recipe_id, hero: sugg.hero, thumb: sugg.thumb, is_sattvic: sugg.is_sattvic, diet_type: sugg.diet_type },
                    sides: []
                  };
                  suggestionIdx++;
                }
              }
            });
          });
          // Reset plan state flags when returning to current week
          setIsAudited(false);
          setIsSaved(false);
          setIsDirty(false);
        }

        setBlueprint(weekMap);
      } catch (err) {
        console.error("Failed to load week plan:", err);
      } finally {
        setIsLoading(false);
      }
    };
    loadWeekPlan();
  }, [weekOffset]);

  // Init — fetch suggestions + session constants once on load
  // Plan loading is handled entirely by the weekOffset useEffect
  useEffect(() => {
    const init = async () => {
      try {
        const [suggRes, sessionRes] = await Promise.all([
          axios.get(`${API_BASE}/generate-suggestions/${HH_ID}`),
          axios.get(`${API_BASE}/session-constants/${HH_ID}`)
        ]);

        setSuggestions(suggRes.data);

        // Cache session constants — used throughout session without re-fetching
        const sc = sessionRes.data;
        setMemberCount(sc.member_count || 0);
        if (sc.oldest_plan_week) {
          const parts = sc.oldest_plan_week.split('-').map(Number);
          const oldestMonday = new Date(parts[0], parts[1] - 1, parts[2]);
          const currentMonday = getCurrentWeekMonday();
          const diffWeeks = Math.round((currentMonday - oldestMonday) / (7 * 24 * 60 * 60 * 1000));
          setOldestPlanWeekOffset(-diffWeeks); // e.g. -4 means 4 weeks back
        }
      } catch (err) {
        console.error("Critical: Init failed:", err);
      }
    };
    init();
  }, []);

  // RETAINED: Manual Audit
  const runAudit = async () => {
    const payload = Object.entries(blueprint).map(([key, val]) => {
      const [day, type] = key.split('-');
      return { day, type, to_meal: val?.main?.name || "Skipped", date: getTargetDate(day) };
    });
    try {
      const res = await axios.post(`${API_BASE}/audit`, payload);
      const resultMap = {};
      res.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
      setAuditResults(resultMap);
      setIsAudited(true);
      setIsDirty(false);
    } catch { console.error("Audit failed"); }
  };

  const savePlan = async () => {
    const payload = {
      household_id: HH_ID,
      plan: Object.entries(blueprint).map(([key, val]) => {
        const [day, type] = key.split('-');
        const audit = auditResults[key] || {};
        return {
          date: getTargetDate(day), type,
          main: val?.main ? { recipe_id: val.main.recipe_id || "", dish_type: "Main", dish_sequence: 1 } : null,
          sides: (val?.sides || []).map((s, idx) => ({ recipe_id: s.recipe_id || "", dish_type: "Side", dish_sequence: idx + 2 })),
          status: audit.status || "Success",
          message: audit.message || ""
        };
      }).filter(s => s.main && s.main.recipe_id)
    };
    try {
      setIsSaving(true);
      const response = await axios.post(`${API_BASE}/save-plan`, payload);
      if (response.data.status === "success") {
        setIsDirty(false);
        setIsAudited(true);
        setIsSaved(true);
        setIsSaving(false);
      }
    } catch (err) {
      setIsSaving(false);
      console.error("Critical: Save failed:", err);
      alert("Saving Failed. Please check your connection or database.");
    }
  };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over) return;
    const targetSlot = over.id;
    const draggedMeal = active.data.current?.meal;
    const sourceId = String(active.id);
    setBlueprint(prev => {
      const newBlueprint = { ...prev };
      if (sourceId.startsWith('drag-')) {
        const sourceSlot = sourceId.replace('drag-', '');
        if (sourceSlot === targetSlot) return prev;
        const mealAtTarget = newBlueprint[targetSlot];
        newBlueprint[targetSlot] = draggedMeal;
        newBlueprint[sourceSlot] = mealAtTarget || { main: null, sides: [] };
      }
      return newBlueprint;
    });
    setIsDirty(true); setIsAudited(false); setIsSaved(false);
  };

  // Button state — no lock concept. Always invite the user to review.
  // Saved plan on load → Review plan (warm, inviting)
  // After audit → Save plan (ready to persist)
  // After save → Saved ✓ briefly, then back to Review plan
  const getCtaButton = () => {
    if (isSaving) return {
      label: "Saving...",
      bg: "#B4B2A9", color: "#fff", border: "none",
      onClick: () => {}
    };
    if (isSaved && !isDirty) return {
      label: "Saved ✓",
      bg: "#5DCAA5", color: "#085041", border: "none",
      onClick: runAudit   // Tap saved → re-review anytime
    };
    if (!isAudited || isDirty) return {
      label: "Review plan",
      bg: "#EF9F27", color: "#2C2C2A", border: "none",
      onClick: runAudit
    };
    return {
      label: "Save plan",
      bg: "#FDFCF8", color: "#1A3A2E", border: "2px solid #5DCAA5",
      onClick: savePlan
    };
  };

  const cta = getCtaButton();

  // FIX 1: Demo events matched to actual current week dates
  const demoEvents = [
    { dayName: "Wednesday", emoji: "🎂", title: "Amma's Birthday", pill: "Feast day", pillBg: "#FAECE7", pillColor: "#712B13" },
    { dayName: "Friday",    emoji: "🕉",  title: "Amavasai",       pill: "Satvik required", pillBg: "#E1F5EE", pillColor: "#085041" }
  ];

  const selectedDayMeals = MEAL_TYPES.map(type => ({
    type,
    meal: blueprint[`${selectedDay}-${type}`] || null,
    auditResult: auditResults[`${selectedDay}-${type}`] || null
  }));

  const greeting = new Date().getHours() < 12 ? "Good morning" : new Date().getHours() < 17 ? "Good afternoon" : "Good evening";

  return (
    <div style={{ minHeight: "100vh", background: "#F5F0E8", display: "flex", flexDirection: "column", alignItems: "center", fontFamily: "system-ui, -apple-system, sans-serif" }}>
      <div style={{ width: "100%", maxWidth: 430, minHeight: "100vh", background: "#FFF9F2", display: "flex", flexDirection: "column" }}>

        {/* ── HEADER ── */}
        <div style={{ background: "#1A3A2E", padding: "48px 20px 14px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
            <div>
              <div style={{ color: "#9FE1CB", fontSize: 12, marginBottom: 2 }}>{greeting}, Bala 👋</div>
              <div style={{ color: "#FDFCF8", fontSize: 20, fontWeight: 500, letterSpacing: -0.3 }}>Your week awaits</div>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              {/* Save button in header — hidden when viewing past weeks */}
              {isCurrentWeek && (
                <button
                  onClick={cta.onClick}
                  style={{
                    background: cta.bg, color: cta.color,
                    border: cta.border || "none",
                    borderRadius: 12, padding: "8px 14px",
                    fontSize: 12, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  {cta.label}
                </button>
              )}
              <div style={{
                width: 34, height: 34, borderRadius: "50%",
                background: "#2C4A3E", border: "2px solid #5DCAA5",
                display: "flex", alignItems: "center", justifyContent: "center",
                color: "#9FE1CB", fontSize: 13, fontWeight: 500, flexShrink: 0
              }}>V</div>
            </div>
          </div>

          {/* Context chips */}
          <div style={{ display: "flex", gap: 8 }}>
            {[
              { icon: "🛒", val: "Market", label: "Check signals" },
              { icon: "🧊", val: "Fridge", label: "Update stock" },
              { icon: "👨‍👩‍👧", val: "4 members", label: "This week" }
            ].map((chip, i) => (
              <div key={i} style={{ flex: 1, background: "rgba(255,255,255,0.08)", borderRadius: 10, padding: "8px 8px", border: "0.5px solid rgba(255,255,255,0.12)" }}>
                <div style={{ fontSize: 14, marginBottom: 2 }}>{chip.icon}</div>
                <div style={{ color: "#FDFCF8", fontSize: 11, fontWeight: 500 }}>{chip.val}</div>
                <div style={{ color: "#9FE1CB", fontSize: 9, marginTop: 1 }}>{chip.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* ── EVENT BANNER — FIX 1: dates match current week ── */}
        <div style={{ background: "#FFF3DC", borderBottom: "1.5px solid #FAC775", padding: "10px 16px" }}>
          <div style={{ fontSize: 9, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.1em", color: "#854F0B", marginBottom: 8 }}>
            Special this week
          </div>
          <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 2 }}>
            {demoEvents.map((ev, i) => (
              <div key={i} style={{
                flexShrink: 0, background: "#fff", borderRadius: 14,
                padding: "8px 12px", border: "1px solid #FAC775",
                display: "flex", alignItems: "center", gap: 8, minWidth: 165
              }}>
                <span style={{ fontSize: 22 }}>{ev.emoji}</span>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A" }}>{ev.title}</div>
                  {/* FIX 1: Dynamic date from actual current week */}
                  <div style={{ fontSize: 10, color: "#888780", marginTop: 1 }}>
                    {getEventDateLabel(ev.dayName)}
                  </div>
                  <div style={{
                    display: "inline-block", fontSize: 9, padding: "1px 7px",
                    borderRadius: 20, fontWeight: 500, marginTop: 3,
                    background: ev.pillBg, color: ev.pillColor
                  }}>{ev.pill}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── VIEW TOGGLE — FIX 3 ── */}
        <div style={{ background: "#FFF9F2", padding: "8px 16px", display: "flex", gap: 8, borderBottom: "1px solid #EDE8E0", alignItems: "center" }}>
          {['day', 'week'].map(mode => (
            <button
              key={mode}
              onClick={() => setViewMode(mode)}
              style={{
                padding: "5px 14px", borderRadius: 20,
                border: viewMode === mode ? "none" : "1px solid #EDE8E0",
                background: viewMode === mode ? "#1A3A2E" : "transparent",
                color: viewMode === mode ? "#9FE1CB" : "#888780",
                fontSize: 11, fontWeight: 500, cursor: "pointer"
              }}
            >
              {mode === 'day' ? '📅 Day view' : '📆 Week view'}
            </button>
          ))}
          {isDirty && (
            <div style={{ marginLeft: "auto", fontSize: 10, color: "#EF9F27", fontWeight: 500 }}>
              ● Unsaved changes
            </div>
          )}
        </div>

        {/* ── WEEK NAVIGATOR — shown in both day and week view ── */}
        <div style={{ background: "#FFF9F2", borderBottom: "1px solid #EDE8E0" }}>

          {/* Week nav row — << week label [Today] >> */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "6px 12px 2px" }}>
            {/* Previous week — disabled at oldest recorded week */}
            <button
              onClick={() => { if (oldestPlanWeekOffset === null || weekOffset > oldestPlanWeekOffset) { setWeekOffset(prev => prev - 1); setSelectedDay('Monday'); } }}
              disabled={oldestPlanWeekOffset !== null && weekOffset <= oldestPlanWeekOffset}
              style={{ background: "none", border: "none", fontSize: 16, padding: "2px 6px", borderRadius: 8,
                color: (oldestPlanWeekOffset !== null && weekOffset <= oldestPlanWeekOffset) ? "#D0CEC8" : "#1A3A2E",
                cursor: (oldestPlanWeekOffset !== null && weekOffset <= oldestPlanWeekOffset) ? "not-allowed" : "pointer"
              }}
            >‹‹</button>

            {/* Week label + Today button */}
            <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
              <div style={{ fontSize: 10, fontWeight: 500, color: weekOffset === 0 ? "#1A3A2E" : "#EF9F27", letterSpacing: "0.02em", textAlign: "center" }}>
                {weekOffset === 0 ? "This week" : weekOffset === -1 ? "Last week" : weekOffset === 1 ? "Next week" : weekOffset > 0 ? `${weekOffset} weeks ahead` : `${Math.abs(weekOffset)} weeks ago`}
                <span style={{ color: "#B4B2A9", fontWeight: 400, display: "block", fontSize: 9 }}>{getWeekLabel()}</span>
              </div>
              {/* Today button — only shown when not on current week */}
              {!isCurrentWeek && (
                <button
                  onClick={() => { setWeekOffset(0); setSelectedDay(DAYS[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1]); setViewMode('day'); }}
                  style={{
                    background: "#1A3A2E", color: "#9FE1CB",
                    border: "none", borderRadius: 10, padding: "3px 10px",
                    fontSize: 10, fontWeight: 500, cursor: "pointer"
                  }}
                >Today</button>
              )}
            </div>

            {/* Next week — always enabled when going back (offset<0), gated on data for future */}
            <button
              onClick={() => { if (weekOffset < 0 || hasNextWeekData) { setWeekOffset(prev => prev + 1); setSelectedDay('Monday'); } }}
              disabled={weekOffset >= 0 && !hasNextWeekData}
              style={{ background: "none", border: "none", fontSize: 16, padding: "2px 6px", borderRadius: 8,
                color: (weekOffset < 0 || hasNextWeekData) ? "#1A3A2E" : "#D0CEC8",
                cursor: (weekOffset < 0 || hasNextWeekData) ? "pointer" : "not-allowed"
              }}
            >››</button>
          </div>

          {/* Copy to Current Week banner — shown at top when viewing past/future week */}
          {!isCurrentWeek && (
            <div style={{ margin: "4px 12px", padding: "8px 12px", background: "#FFF3DC", borderRadius: 10, border: "1px solid #FAC775", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ fontSize: 11, color: "#854F0B", fontWeight: 500 }}>Viewing {weekOffset < 0 ? "past" : "future"} week</div>
              <button
                onClick={() => setShowCopyConfirm(true)}
                style={{ background: "#EF9F27", color: "#2C2C2A", border: "none", borderRadius: 8, padding: "5px 12px", fontSize: 11, fontWeight: 500, cursor: "pointer" }}
              >Copy to Current Week</button>
            </div>
          )}

          {/* Day pills — only in day view */}
          {viewMode === 'day' && <div style={{ padding: "4px 12px 8px", display: "flex" }}>
              {DAYS.map(day => {
                const active = day === selectedDay;
                const today = isCurrentWeek && isToday(day);
                const hasEvent = demoEvents.some(ev => ev.dayName === day);
                const dateStr = getOffsetTargetDate(day);
                const dateParts = dateStr.split('-');
                const dayNum = parseInt(dateParts[2], 10);
                return (
                  <div
                    key={day}
                    onClick={() => setSelectedDay(day)}
                    style={{
                      flex: 1, textAlign: "center",
                      padding: "7px 4px", borderRadius: 14,
                      cursor: "pointer",
                      background: active ? "#1A3A2E" : "transparent",
                      border: today && !active ? "1.5px solid #EF9F27" : "1.5px solid transparent",
                      transition: "all 0.15s"
                    }}
                  >
                    <div style={{ fontSize: 9, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.04em", color: active ? "#9FE1CB" : "#B4B2A9" }}>
                      {day.substring(0, 3)}
                    </div>
                    <div style={{ fontSize: 17, fontWeight: 500, margin: "2px 0", color: active ? "#fff" : "#2C2C2A" }}>
                      {dayNum}
                    </div>
                    <div style={{ height: 3, borderRadius: 2, background: active ? "rgba(255,255,255,0.2)" : "#EDE8E0", marginTop: 4 }} />
                    {hasEvent && isCurrentWeek && (
                      <div style={{ width: 5, height: 5, borderRadius: "50%", background: "#EF9F27", margin: "3px auto 0" }} />
                    )}
                  </div>
                );
              })}
            </div>}
          {/* end day pills */}
        </div>

        {/* ── CONTENT AREA ── */}
        <div style={{ flex: 1, overflowY: "auto" }}>

          {isLoading ? (
            <div style={{ textAlign: "center", padding: "48px 0", color: "#B4B2A9", fontSize: 14 }}>
              Loading your plan...
            </div>
          ) : viewMode === 'day' ? (

            /* ── DAY VIEW ── */
            <div style={{ padding: "12px 14px" }}>
              {/* Empty state — past/future week with no plan */}
              {!isCurrentWeek && Object.keys(blueprint).length === 0 && (
                <div style={{ textAlign: "center", padding: "48px 20px", color: "#B4B2A9" }}>
                  <div style={{ fontSize: 32, marginBottom: 12 }}>📭</div>
                  <div style={{ fontSize: 14, fontWeight: 500, color: "#2C2C2A", marginBottom: 6 }}>No plan for this week</div>
                  <div style={{ fontSize: 12, color: "#B4B2A9", marginBottom: 20 }}>No meals were saved for this period.</div>
                  <button
                    onClick={() => { setWeekOffset(0); setSelectedDay(DAYS[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1]); }}
                    style={{ background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "10px 20px", fontSize: 13, fontWeight: 500, cursor: "pointer" }}
                  >Go to current week</button>
                </div>
              )}
              <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
                {selectedDayMeals.map(({ type, meal, auditResult }) => (
                  <div key={type} style={{ marginBottom: 4 }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 6, padding: "6px 2px 4px" }}>
                      <div style={{ width: 26, height: 26, borderRadius: "50%", background: MEAL_CONFIG[type].color, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13 }}>
                        {MEAL_CONFIG[type].icon}
                      </div>
                      <span style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A" }}>{type}</span>
                      <span style={{ fontSize: 10, color: "#B4B2A9", marginLeft: "auto" }}>{MEAL_CONFIG[type].time}</span>
                    </div>
                    <MealCard
                      key={`${selectedDay}-${type}`}
                      day={selectedDay}
                      type={type}
                      meal={meal}
                      auditResult={auditResult}
                      isEditable={isCurrentWeek}
                      onClick={(data) => isCurrentWeek && setEditing(data)}
                    />
                  </div>
                ))}
              </DndContext>
            </div>

          ) : (

            /* ── WEEK VIEW — offset-aware, read-only for past weeks ── */
            <div style={{ padding: "12px 14px" }}>
              {/* Empty state for week view */}
              {!isCurrentWeek && Object.keys(blueprint).length === 0 ? (
                <div style={{ textAlign: "center", padding: "48px 20px", color: "#B4B2A9" }}>
                  <div style={{ fontSize: 32, marginBottom: 12 }}>📭</div>
                  <div style={{ fontSize: 14, fontWeight: 500, color: "#2C2C2A", marginBottom: 6 }}>No plan for this week</div>
                  <div style={{ fontSize: 12, marginBottom: 20 }}>No meals were saved for this period.</div>
                  <button
                    onClick={() => { setWeekOffset(0); setSelectedDay(DAYS[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1]); }}
                    style={{ background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "10px 20px", fontSize: 13, fontWeight: 500, cursor: "pointer" }}
                  >Go to current week</button>
                </div>
              ) : (
              <>
              <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 12, fontStyle: "italic" }}>
                {isCurrentWeek ? "Tap any meal to edit that day" : "Read-only view — use Copy to Current Week to edit"}
              </div>

              {/* Column headers — offset-aware dates */}
              <div style={{ display: "grid", gridTemplateColumns: "60px repeat(7, 1fr)", gap: 4, marginBottom: 6 }}>
                <div />
                {DAYS.map(day => {
                  const dateStr = getOffsetTargetDate(day);
                  const dayNum = parseInt(dateStr.split('-')[2], 10);
                  return (
                    <div key={day} style={{ textAlign: "center" }}>
                      <div style={{ fontSize: 9, fontWeight: 500, color: "#B4B2A9", textTransform: "uppercase" }}>
                        {day.substring(0, 3)}
                      </div>
                      <div style={{
                        fontSize: 13, fontWeight: 500,
                        color: isCurrentWeek && isToday(day) ? "#EF9F27" : "#2C2C2A",
                        background: day === selectedDay ? "#E1F5EE" : "transparent",
                        borderRadius: 6, padding: "1px 0"
                      }}>
                        {dayNum}
                      </div>
                      {isCurrentWeek && demoEvents.some(ev => ev.dayName === day) && (
                        <div style={{ width: 4, height: 4, borderRadius: "50%", background: "#EF9F27", margin: "2px auto 0" }} />
                      )}
                    </div>
                  );
                })}
              </div>

              {/* Meal rows */}
              {MEAL_TYPES.map(type => (
                <div key={type} style={{ display: "grid", gridTemplateColumns: "60px repeat(7, 1fr)", gap: 4, marginBottom: 6, alignItems: "start" }}>
                  {/* Meal type label */}
                  <div style={{ display: "flex", flexDirection: "column", alignItems: "center", paddingTop: 8 }}>
                    <div style={{ fontSize: 14 }}>{MEAL_CONFIG[type].icon}</div>
                    <div style={{ fontSize: 8, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", marginTop: 2 }}>
                      {type.substring(0, 5)}
                    </div>
                  </div>

                  {/* Meal thumbnail per day */}
                  {DAYS.map(day => (
                    <WeekThumbCard
                      key={`${day}-${type}`}
                      meal={blueprint[`${day}-${type}`]}
                      onClick={() => { setSelectedDay(day); setViewMode('day'); }}
                    />
                  ))}
                </div>
              ))}

              {/* Weekly summary */}
              <div style={{
                marginTop: 12, padding: "10px 14px",
                background: "#1A3A2E", borderRadius: 14,
                display: "flex", justifyContent: "space-around"
              }}>
                {[
                  { val: "21", label: "Total meals" },
                  { val: "C2.4", label: "Avg level" },
                  { val: "78%", label: "Fridge use" }
                ].map((s, i) => (
                  <div key={i} style={{ textAlign: "center" }}>
                    <div style={{ color: "#FDFCF8", fontSize: 15, fontWeight: 500 }}>{s.val}</div>
                    <div style={{ color: "#5DCAA5", fontSize: 9, marginTop: 1 }}>{s.label}</div>
                  </div>
                ))}
              </div>
              </>
              )}
            </div>
          )}
        </div>

        {/* ── BOTTOM NAV BAR ── */}
        <div style={{ background: "#1A3A2E", padding: "12px 20px 28px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          {[
            { val: "21", label: "Meals" },
            { val: "C2.4", label: "Avg level" },
            { val: "78%", label: "Fridge" }
          ].map((stat, i) => (
            <div key={i} style={{ textAlign: "center" }}>
              <div style={{ color: "#FDFCF8", fontSize: 14, fontWeight: 500 }}>{stat.val}</div>
              <div style={{ color: "#5DCAA5", fontSize: 9, marginTop: 1 }}>{stat.label}</div>
            </div>
          ))}

          {/* Past week → Copy button only. Current week → normal CTA */}
          {!isCurrentWeek ? (
            <button
              onClick={() => setShowCopyConfirm(true)}
              style={{
                background: "#EF9F27", color: "#2C2C2A",
                border: "none", borderRadius: 14, padding: "11px 16px",
                fontSize: 12, fontWeight: 500, cursor: "pointer",
                boxShadow: "0 0 0 3px rgba(239,159,39,0.3)"
              }}
            >
              Copy to Current Week
            </button>
          ) : (
            <button
              onClick={cta.onClick}
              style={{
                background: cta.bg, color: cta.color,
                border: cta.border || "none",
                borderRadius: 14, padding: "11px 20px",
                fontSize: 13, fontWeight: 500, cursor: "pointer",
                boxShadow: !isSaved ? "0 0 0 3px rgba(239,159,39,0.3)" : "none"
              }}
            >
              {cta.label}
            </button>
          )}
        </div>

        {/* ── COPY CONFIRMATION MODAL ── */}
        {showCopyConfirm && (
          <div style={{
            position: "fixed", inset: 0, background: "rgba(0,0,0,0.6)",
            zIndex: 100, display: "flex", alignItems: "flex-end", justifyContent: "center"
          }}>
            <div style={{
              width: "100%", maxWidth: 430, background: "#FFF9F2",
              borderRadius: "24px 24px 0 0", padding: "28px 24px 40px"
            }}>
              <div style={{ fontSize: 18, fontWeight: 600, color: "#2C2C2A", marginBottom: 8 }}>
                Copy to Current Week?
              </div>
              <div style={{ fontSize: 13, color: "#888780", marginBottom: 24, lineHeight: 1.5 }}>
                This will replace your current week's plan with the meals from {getWeekLabel()}. You can review before saving.
              </div>
              <div style={{ display: "flex", gap: 12 }}>
                <button
                  onClick={() => setShowCopyConfirm(false)}
                  style={{
                    flex: 1, padding: "13px", borderRadius: 14,
                    border: "1.5px solid #EDE8E0", background: "transparent",
                    color: "#888780", fontSize: 14, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  Cancel
                </button>
                <button
                  onClick={copyToCurrentWeek}
                  style={{
                    flex: 2, padding: "13px", borderRadius: 14,
                    border: "none", background: "#1A3A2E",
                    color: "#9FE1CB", fontSize: 14, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  Yes, copy it
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ── MEAL EDITOR MODAL ── */}
        {editing && (
          <MealEditor
            selected={editing}
            onClose={() => setEditing(null)}
            suggestions={suggestions}
            onSave={(updated) => {
              setBlueprint(prev => ({ ...prev, [`${editing.day}-${editing.type}`]: updated }));
              setEditing(null);
              setIsDirty(true);
              setIsAudited(false);
              setIsSaved(false);
            }}
          />
        )}

      </div>
    </div>
  );
}
