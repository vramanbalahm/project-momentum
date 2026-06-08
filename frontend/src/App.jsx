import React, { useState, useEffect } from 'react';
import { DndContext, closestCenter, PointerSensor, KeyboardSensor, useSensor, useSensors } from '@dnd-kit/core';
import axios from './api/client'; // uses configured client with auth interceptor

// Component Imports
import DayColumn from './components/DayColumn';
import MealCard from './components/MealCard';
import MealEditor from './components/MealEditor';
import MealEditScreen from './components/MealEditScreen';
import SwapCopyBar from './components/SwapCopyBar';
import { swapSlots, swapDays, auditBlueprint, persistSwap } from './services/swapService';
import { useAuth } from './context/AuthContext';
import { useTranslation } from 'react-i18next';
import WeeklyQuestionnaire from './components/WeeklyQuestionnaire';
import MemberAvailability from './pages/MemberAvailability';
import ChangePassword from './pages/ChangePassword';

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";
// HH_ID now comes from authenticated user — see App() below
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

// Week overview thumbnail card — two-tap swap, no drag
const WeekThumbCard = ({ meal, slotId, onClick, isSelected = false, isSwapMode = false }) => {
  // Read from mains array first (multi-main), fall back to single main
  const mainsArr = meal?.mains && meal.mains.length > 0 ? meal.mains : (meal?.main ? [meal.main] : []);
  const main = mainsArr[0] || null;
  const extraMains = mainsArr.length > 1 ? mainsArr.length - 1 : 0;
  const sides = meal?.sides || [];
  const extraCount = extraMains + sides.length;
  let imgUrl = main?.thumb || main?.hero;
  if (!imgUrl && main?.name) {
    imgUrl = `/assets/meals/${main.name.toLowerCase().replace(/\s+/g, '_')}.png`;
  }

  return (
    <div style={{ width: "100%", height: "100%" }}>
    <div
      onClick={onClick}
      style={{
        width: "100%", height: "100%", minHeight: 56, borderRadius: 8,
        background: isSelected ? "#EF9F27" : "#EDE8E0",
        position: "relative", cursor: isSwapMode ? "pointer" : "default",
        border: isSelected ? "2px solid #BA7517" : isSwapMode ? "1.5px dashed #1A3A2E" : "1px solid #E0DBD3",
        zIndex: isSelected ? 20 : 1,
        userSelect: "none",
        WebkitUserSelect: "none",
        opacity: isSwapMode && !isSelected ? 0.75 : 1,
      }}
    >
      <div style={{ position: "absolute", inset: 0, borderRadius: 10, overflow: "hidden" }}>
      {imgUrl ? (
        <img
          key={imgUrl}
          src={imgUrl}
          alt={main?.name || "Meal"}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
          onError={(e) => {
            e.target.onerror = null;
            e.target.style.display = "none";
          }}
        />
      ) : null}

      {/* +N badge — extra mains + sides */}
      {extraCount > 0 && (
        <div style={{
          position: "absolute", top: 4, right: 4,
          background: "rgba(26,58,46,0.85)",
          color: "#9FE1CB",
          fontSize: 8, fontWeight: 500,
          padding: "2px 5px", borderRadius: 8,
          lineHeight: 1.2
        }}>
          +{extraCount}
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
    </div>
    </div>
  );
};

export default function App({ onBack }) {
  const { user, logout } = useAuth();
  const { t, i18n } = useTranslation();
  const HH_ID = user?.house_id; // declared early — used in useEffects below
  const isAdmin = user?.role === "household_admin" || user?.role === "platform_admin";
  const isPlatformAdmin = user?.role === "platform_admin";
  const [showAvailabilityOverlay, setShowAvailabilityOverlay] = useState(false);
  const [plannerMenuOpen, setPlannerMenuOpen] = useState(false);
  const [plannerShowChangePassword, setPlannerShowChangePassword] = useState(false);
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const [resetting, setResetting] = useState(false);

  const handleDevReset = async () => {
    setResetting(true);
    try {
      await axios.delete(`${API_BASE}/dev/reset-week`);
      setShowResetConfirm(false);
      onBack && onBack(); // go back to dashboard
    } catch (e) {
      console.error("Reset failed:", e);
    } finally {
      setResetting(false);
    }
  };
  const [plannerDirtyWarning, setPlannerDirtyWarning] = useState(false); // unsaved changes warning
  const [pendingNavAction, setPendingNavAction] = useState(null); // action to run after user confirms

  // Intercept navigation — warn if unsaved changes, else proceed
  const safeNavigate = (action) => {
    setPlannerMenuOpen(false);
    if (isDirty) {
      setPendingNavAction(() => action);
      setPlannerDirtyWarning(true);
    } else {
      action();
    }
  };
  const [authScreen, setAuthScreen] = useState('login'); // kept for reference — auth gate moved to main.jsx
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
  const skipNextLoad = React.useRef(false); // prevents loadWeekPlan overwriting copied blueprint
  const [hasNextWeekData, setHasNextWeekData] = useState(false);
  // Swap/Copy mode state — decoupled, can be feature-gated later
  const [swapMode, setSwapMode] = useState(null); // null | 'swap' | 'copy'
  const [swapSelected, setSwapSelected] = useState(null); // first selected slot key
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
    // Set blueprint FIRST before changing weekOffset
    // This prevents the useEffect from overwriting the copied data
    setBlueprint(copied);
    setIsAudited(false);
    setIsSaved(false);
    setIsDirty(true);
    setShowCopyConfirm(false);
    setSelectedDay(DAYS[0]);
    setViewMode('day');
    // Set weekOffset last — useEffect will fire but blueprint is already set
    skipNextLoad.current = true;
    setWeekOffset(0);
  };

  // DnD sensors for day view card reordering
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 8 } })
  );

  // Load plan whenever weekOffset changes
  // weekOffset === 0 reloads current week (fixes returning from past week showing stale data)
  useEffect(() => {
    if (!HH_ID) return; // wait until user is loaded — avoids /get-plan/undefined call
    if (skipNextLoad.current) { skipNextLoad.current = false; return; } // skip when copying
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
              // Support mains array (multi-main) — fallback to single main for backward compat
              const mainsArr = slot.mains && slot.mains.length > 0 ? slot.mains : [slot.main];
              weekMap[`${dayName}-${slot.type}`] = {
                main: slot.main,
                mains: mainsArr,
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
          // Reset plan state flags when returning to current week
          setIsAudited(false);
          setIsSaved(hasPlan);
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
  }, [weekOffset, suggestions.length, HH_ID]);
  // HH_ID in deps: re-runs when user loads (fixes first-visit blank plan)
  // suggestions.length in deps: re-runs gap-fill when suggestions arrive

  // Init — fetch suggestions + session constants once on load
  // Plan loading is handled entirely by the weekOffset useEffect
  useEffect(() => {
    if (!HH_ID) return; // wait until user is loaded
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
  }, [HH_ID]); // re-runs when user loads

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
      // If in week view, switch to day view at Monday so user sees audit results
      if (viewMode === 'week') {
        setViewMode('day');
        setSelectedDay('Monday');
      }
    } catch { console.error("Audit failed"); }
  };

  // ── Generate Plan (Bucket A recommendation engine) ──
  const [isGenerating, setIsGenerating] = useState(false);
  const [showQuestionnaire, setShowQuestionnaire] = useState(false);

  // Show questionnaire first, then generate
  const [showRegenWarning, setShowRegenWarning] = useState(false);

  const handleGenerateClick = () => {
    if (!isAdmin || weekOffset !== 0) return;
    // Check if plan already has meals
    const hasMeals = Object.keys(blueprint).length > 0;
    if (hasMeals && isSaved) {
      setShowRegenWarning(true);
    } else {
      setShowQuestionnaire(true);
    }
  };

  const generatePlan = async (weeklyConfig = {}) => {
    setShowQuestionnaire(false);
    setIsGenerating(true);
    try {
      const weekStart = toLocalDateString(getCurrentWeekMonday());

      const resp = await axios.post(`${API_BASE}/recommendation/generate`, {
        week_start: weekStart,
        fill_empty_only: false,
      });

      const plan = resp.data.plan;
      if (!plan) return;

      // Map API response into blueprint format
      // Blueprint key format: "Monday-Breakfast" (same as loadWeekPlan)
      const days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
      const slots = ["Breakfast","Lunch","Dinner"];
      const newBlueprint = {};

      days.forEach(day => {
        slots.forEach(slot => {
          const suggested = plan[day]?.[slot];
          if (suggested && suggested.recipe_id) {
            const bpKey = `${day}-${slot}`;
            newBlueprint[bpKey] = {
              main:  { name: suggested.dish_name, recipe_id: suggested.recipe_id, diet_type: suggested.diet_type, thumb: suggested.thumb, hero: suggested.hero },
              mains: [{ name: suggested.dish_name, dish_name: suggested.dish_name, recipe_id: suggested.recipe_id, diet_type: suggested.diet_type, thumb: suggested.thumb, hero: suggested.hero }],
              sides: (suggested.sides || []).map(s => ({
                name: s.dish_name, dish_name: s.dish_name,
                recipe_id: s.recipe_id, dish_category: s.dish_category
              })),
            };
          }
        });
      });

      setBlueprint(newBlueprint);
      setIsDirty(true);
      setIsAudited(false);
    } catch (e) {
      console.error("Generate plan failed:", e);
    } finally {
      setIsGenerating(false);
    }
  };

  const savePlan = async () => {
    const payload = {
      household_id: HH_ID,
      plan: Object.entries(blueprint).map(([key, val]) => {
        const [day, type] = key.split('-');
        const audit = auditResults[key] || {};
        // Build mains array — support both old (val.main) and new (val.mains) shape
        const mainsArr = val?.mains && val.mains.length > 0 ? val.mains : (val?.main ? [val.main] : []);
        const sidesArr = val?.sides || [];
        // dish_sequence: mains get 1,2,3... sides follow after
        const mainItems = mainsArr.map((m, idx) => ({ recipe_id: m.recipe_id || "", dish_type: "Main", dish_sequence: idx + 1 }));
        const sideItems = sidesArr.map((s, idx) => ({ recipe_id: s.recipe_id || "", dish_type: "Side", dish_sequence: mainsArr.length + idx + 1 }));
        return {
          date: getTargetDate(day), type,
          main: mainItems[0] || null,
          mains: mainItems,
          sides: sideItems,
          status: audit.status || "Success",
          message: audit.message || ""
        };
      }).filter(s => s.mains && s.mains.length > 0 && s.mains[0].recipe_id)
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

  const handleDragEnd = async (event) => {
    const { active, over } = event;
    if (!over) return;
    const sourceId = String(active.id);
    if (!sourceId.startsWith('drag-')) return;
    const sourceSlot = sourceId.replace('drag-', '');
    const targetSlot = over.id;
    if (sourceSlot === targetSlot) return;

    // 1. Swap in memory via swapService
    const newBlueprint = swapSlots(sourceSlot, targetSlot, blueprint);
    setBlueprint(newBlueprint);
    setIsDirty(true);
    setIsAudited(false);
    setIsSaved(false);

    // 2. Persist swap to DB via swapService
    const monday = getOffsetWeekMonday();
    const weekStart = toLocalDateString(monday);
    const result = await persistSwap(sourceSlot, targetSlot, getOffsetTargetDate, weekStart);

    if (!result.success) {
      console.error('Swap persist failed:', result);
      return;
    }

    // 3. Run audit on updated blueprint
    const auditResult = await auditBlueprint(newBlueprint, getTargetDate);
    if (auditResult.success) {
      setAuditResults(auditResult.results);
      setIsAudited(true);
    }
  };

  // ── SLOT TAP HANDLER — used by swap/copy mode ──
  const handleSlotTap = async (slotKey) => {
    if (!swapMode) return; // not in swap/copy mode — ignore

    if (!swapSelected) {
      // First tap — select source
      if (slotKey === swapSelected) {
        setSwapSelected(null); // tap again to deselect
      } else {
        setSwapSelected(slotKey);
      }
      return;
    }

    if (slotKey === swapSelected) {
      // Tap same card — deselect
      setSwapSelected(null);
      return;
    }

    // Second tap — execute swap or copy
    const sourceKey = swapSelected;
    const targetKey = slotKey;

    if (swapMode === 'swap') {
      const newBlueprint = swapSlots(sourceKey, targetKey, blueprint);
      setBlueprint(newBlueprint);
      setIsDirty(true);
      setIsAudited(false);
      setIsSaved(false);
      // Persist swap to DB
      const monday = getOffsetWeekMonday();
      const weekStart = toLocalDateString(monday);
      await persistSwap(sourceKey, targetKey, getOffsetTargetDate, weekStart);
    } else if (swapMode === 'copy') {
      // Copy source meal into target slot — source unchanged
      const sourceMeal = blueprint[sourceKey];
      if (sourceMeal) {
        setBlueprint(prev => ({ ...prev, [targetKey]: { ...sourceMeal } }));
        setIsDirty(true);
        setIsAudited(false);
        setIsSaved(false);
      }
    }

    // Reset mode
    setSwapMode(null);
    setSwapSelected(null);
  };

  // Button state — no lock concept. Always invite the user to review.
  // Saved plan on load → Review plan (warm, inviting)
  // After audit → Save plan (ready to persist)
  // After save → Saved ✓ briefly, then back to Review plan
  const getCtaButton = () => {
    if (isSaving) return {
      label: t("weeklyPlan.saving"),
      bg: "#B4B2A9", color: "#fff", border: "none",
      onClick: () => {}
    };
    if (isSaved && !isDirty) return {
      label: t("weeklyPlan.saved"),
      bg: "#5DCAA5", color: "#085041", border: "none",
      onClick: runAudit   // Tap saved → re-review anytime
    };
    if (!isAudited || isDirty) return {
      label: t("weeklyPlan.reviewPlan"),
      bg: "#EF9F27", color: "#2C2C2A", border: "none",
      onClick: runAudit
    };
    return {
      label: t("weeklyPlan.savePlan"),
      bg: "#FDFCF8", color: "#1A3A2E", border: "2px solid #5DCAA5",
      onClick: savePlan
    };
  };

  const cta = getCtaButton();

  // HH_ID declared above useAuth() — see line 157

  // ── AUTH GATE — after all hooks ──
  // Week events loaded from event_master
  const [weekEvents, setWeekEvents] = useState([]);

  useEffect(() => {
    if (!HH_ID) return;
    const monday = getCurrentWeekMonday();
    monday.setDate(monday.getDate() + weekOffset * 7);
    const ws = toLocalDateString(monday);
    axios.get(`${API_BASE}/onboarding/week-events?week_start=${ws}`)
      .then(r => setWeekEvents(r.data.events || []))
      .catch(() => setWeekEvents([]));
  }, [weekOffset, HH_ID]);

  // Map event_master rows to day-keyed structure
  const demoEvents = weekEvents.map(ev => ({
    dayName: ev.day_name,
    emoji: ev.icon || "🗓️",
    title: ev.event_name,
    pill: ev.is_sattvic_required ? "Satvik required" : "Feast day",
    pillBg: ev.is_sattvic_required ? "#E1F5EE" : "#FAECE7",
    pillColor: ev.is_sattvic_required ? "#085041" : "#712B13",
  }));

  const selectedDayMeals = MEAL_TYPES.map(type => ({
    type,
    meal: blueprint[`${selectedDay}-${type}`] || null,
    auditResult: auditResults[`${selectedDay}-${type}`] || null
  }));

  const greeting = new Date().getHours() < 12 ? "Good morning" : new Date().getHours() < 17 ? "Good afternoon" : "Good evening";

  return (
    <>
    <div style={{ minHeight: "100vh", background: "#F5F0E8", display: "flex", flexDirection: "column", alignItems: "center", fontFamily: "system-ui, -apple-system, sans-serif" }}>
      <div style={{ width: "100%", maxWidth: 430, minHeight: "100vh", background: "#FFF9F2", display: "flex", flexDirection: "column" }}>

        {/* ── HEADER ── */}
        <div style={{ background: "#1A3A2E", padding: "16px 20px 12px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 8 }}>
            <div>
              {onBack && <span onClick={() => safeNavigate(onBack)} style={{ color: "#9FE1CB", fontSize: 12, cursor: "pointer", display: "block", marginBottom: 4 }}>{t("weeklyPlan.backToDashboard")}</span>}
              {isAdmin && isCurrentWeek && ( // TODO: restrict to isPlatformAdmin before release
                <span
                  onClick={() => setShowResetConfirm(true)}
                  style={{ color: "#E24B4A", fontSize: 10, cursor: "pointer", display: "block", marginTop: 2, opacity: 0.7 }}
                >
                  🗑 Reset week [DEV]
                </span>
              )}
          <div style={{ color: "#9FE1CB", fontSize: 11, marginBottom: 1 }}>{greeting}, {user?.name?.split(' ')[0]} 👋</div>
              <div style={{ color: "#FDFCF8", fontSize: 16, fontWeight: 500, letterSpacing: -0.3 }}>{t("weeklyPlan.title")}</div>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              {/* Availability button — admin only */}
              {isAdmin && isCurrentWeek && (
                <button
                  onClick={() => setShowAvailabilityOverlay(true)}
                  style={{
                    background: "rgba(159,225,203,0.15)", color: "#9FE1CB",
                    border: "0.5px solid rgba(159,225,203,0.3)",
                    borderRadius: 12, padding: "8px 12px",
                    fontSize: 12, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  {t("weeklyPlan.availability")}
                </button>
              )}
              {/* Generate Plan button — admin only, current week only */}
              {isAdmin && isCurrentWeek && !isSaved && (
                <button
                  onClick={handleGenerateClick}
                  disabled={isGenerating}
                  style={{
                    background: isGenerating ? "#B4B2A9" : "#1A3A2E",
                    color: "#9FE1CB",
                    border: "none",
                    borderRadius: 12, padding: "8px 14px",
                    fontSize: 12, fontWeight: 500,
                    cursor: isGenerating ? "not-allowed" : "pointer"
                  }}
                >
                  {isGenerating ? "..." : "✨ " + t("weeklyPlan.generatePlan")}
                </button>
              )}
              {/* Save button in header — admin only, hidden when viewing past weeks */}
              {isAdmin && isCurrentWeek && (
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
              {/* Avatar — opens settings menu, consistent with Dashboard */}
              <div style={{ position: "relative" }}>
                <div
                  onClick={() => setPlannerMenuOpen(o => !o)}
                  style={{
                    width: 34, height: 34, borderRadius: "50%",
                    background: "#2C4A3E", border: "2px solid #5DCAA5",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    color: "#9FE1CB", fontSize: 13, fontWeight: 500, flexShrink: 0,
                    cursor: "pointer"
                  }}>
                  {user?.name?.charAt(0).toUpperCase() || 'U'}
                </div>
                {plannerMenuOpen && (
                  <>
                    <div onClick={() => setPlannerMenuOpen(false)} style={{ position: "fixed", inset: 0, zIndex: 40 }} />
                    <div style={{
                      position: "absolute", top: 40, right: 0, zIndex: 50,
                      background: "#FFF9F2", borderRadius: 14,
                      boxShadow: "0 8px 32px rgba(0,0,0,0.14)",
                      border: "0.5px solid #EDE8E0",
                      overflow: "hidden", minWidth: 200
                    }}>
                      <div style={{ padding: "12px 16px", borderBottom: "0.5px solid #EDE8E0", background: "#F7F4EE" }}>
                        <div style={{ fontSize: 13, fontWeight: 600, color: "#2C2C2A" }}>{user?.name}</div>
                        <div style={{ fontSize: 11, color: "#888780", marginTop: 2 }}>{user?.email}</div>
                      </div>
                      {onBack && (
                        <PlannerMenuItem icon="🏠" label={t("weeklyPlan.menu.dashboard")} onClick={() => safeNavigate(onBack)} />
                      )}
                      <PlannerMenuItem icon="🔑" label={t("weeklyPlan.menu.changePassword")} onClick={() => { setPlannerMenuOpen(false); setPlannerShowChangePassword(true); }} />
                      <PlannerMenuItem icon="🚪" label={t("weeklyPlan.menu.signOut")} onClick={() => safeNavigate(logout)} danger />
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Context icons — compact icon-only row */}
          <div style={{ display: "flex", gap: 16, marginTop: 6 }}>
            {["🛒", "🧊", "👨‍👩‍👧"].map((icon, i) => (
              <span key={i} style={{ fontSize: 18, cursor: "pointer", opacity: 0.85 }}>{icon}</span>
            ))}
          </div>
        </div>



        {/* ── VIEW TOGGLE ── */}
        <div style={{ background: "#EDE8E0", padding: "8px 16px", display: "flex", gap: 8, borderBottom: "1px solid #D3D1C7", alignItems: "center" }}>
          {['day', 'week'].map(mode => (
            <button
              key={mode}
              onClick={() => setViewMode(mode)}
              style={{
                padding: "5px 14px", borderRadius: 20,
                border: "none",
                background: viewMode === mode ? "#1A3A2E" : "rgba(255,255,255,0.5)",
                color: viewMode === mode ? "#9FE1CB" : "#888780",
                fontSize: 11, fontWeight: 500, cursor: "pointer"
              }}
            >
              {mode === 'day' ? t("weeklyPlan.dayView") : t("weeklyPlan.weekView")}

            </button>
          ))}
          {isAdmin && isDirty && (
            <div style={{ marginLeft: "auto", fontSize: 10, color: "#EF9F27", fontWeight: 500 }}>
              {t("weeklyPlan.unsavedChanges")}
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
                {weekOffset === 0 ? t("weeklyPlan.thisWeek") : weekOffset === -1 ? t("weeklyPlan.lastWeek") : weekOffset === 1 ? t("weeklyPlan.nextWeek") : weekOffset > 0 ? t("weeklyPlan.weeksAhead", { count: weekOffset }) : t("weeklyPlan.weeksAgo", { count: Math.abs(weekOffset) })}
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
                >{ t("weeklyPlan.today")}</button>
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
              <div style={{ fontSize: 11, color: "#854F0B", fontWeight: 500 }}>{weekOffset < 0 ? t("weeklyPlan.viewingPast") : t("weeklyPlan.viewingFuture")}</div>
              <button
                onClick={() => setShowCopyConfirm(true)}
                style={{ background: "#EF9F27", color: "#2C2C2A", border: "none", borderRadius: 8, padding: "5px 12px", fontSize: 11, fontWeight: 500, cursor: "pointer" }}
              >{t("weeklyPlan.copyToCurrentWeek")}</button>
            </div>
          )}

          {/* Day pills — only in day view */}
          {viewMode === 'day' && <div style={{ padding: "3px 12px 5px", display: "flex" }}>
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
                      padding: "5px 3px", borderRadius: 10,
                      cursor: "pointer",
                      background: active ? "#1A3A2E" : hasEvent ? "#FFF3DC" : "transparent",
                      border: today && !active ? "1.5px solid #EF9F27" : "1.5px solid transparent",
                      transition: "all 0.15s"
                    }}
                  >
                    <div style={{ fontSize: 8, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.04em", color: active ? "#9FE1CB" : "#B4B2A9" }}>
                      {day.substring(0, 3)}
                    </div>
                    <div style={{ fontSize: 14, fontWeight: 500, margin: "1px 0", color: active ? "#fff" : "#2C2C2A" }}>
                      {dayNum}
                    </div>
                    <div style={{ height: 3, borderRadius: 2, background: active ? "rgba(255,255,255,0.2)" : "#EDE8E0", marginTop: 4 }} />
                    {hasEvent && isCurrentWeek && (() => {
                      const ev = demoEvents.find(e => e.dayName === day);
                      return ev ? (
                        <div style={{ marginTop: 3, lineHeight: 1 }}>
                          <div style={{ fontSize: 10 }}>{ev.emoji}</div>
                          <div style={{ fontSize: 7, color: active ? "#9FE1CB" : "#854F0B", fontWeight: 500, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 36, margin: "0 auto" }}>
                            {ev.title.split(" ")[0]}
                          </div>
                        </div>
                      ) : null;
                    })()}
                  </div>
                );
              })}
            </div>}
          {/* end day pills */}
        </div>

        {/* ── CONTENT AREA ── */}
        <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column" }}>

          {isLoading ? (
            <div style={{ textAlign: "center", padding: "48px 0", color: "#B4B2A9", fontSize: 14 }}>
            {t("weeklyPlan.loading")}
            </div>
          ) : viewMode === 'day' ? (

            /* ── DAY VIEW ── */
            <div style={{ padding: "6px 8px", overflow: "visible" }}>
              {/* Empty state — past/future week with no plan */}
              {!isCurrentWeek && Object.keys(blueprint).length === 0 && (
                <div style={{ textAlign: "center", padding: "48px 20px", color: "#B4B2A9" }}>
                  <div style={{ fontSize: 32, marginBottom: 12 }}>📭</div>
                  <div style={{ fontSize: 14, fontWeight: 500, color: "#2C2C2A", marginBottom: 6 }}>{t("weeklyPlan.noPlanTitle")}</div>
                  <div style={{ fontSize: 12, color: "#B4B2A9", marginBottom: 20 }}>{t("weeklyPlan.noPlanDesc")}</div>
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
                      <span style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A" }}>{t(`weeklyPlan.${type.toLowerCase()}`)}</span>
                      <span style={{ fontSize: 10, color: "#B4B2A9", marginLeft: "auto" }}>{MEAL_CONFIG[type].time}</span>
                    </div>
                    <MealCard
                      key={`${selectedDay}-${type}`}
                      day={selectedDay}
                      type={type}
                      meal={meal}
                      auditResult={auditResult}
                      isEditable={isCurrentWeek}
                      isHighlighted={demoEvents.some(ev => ev.dayName === selectedDay)}
                      onClick={(data) => isAdmin && isCurrentWeek && setEditing(data)}
                    />
                  </div>
                ))}
              </DndContext>
            </div>

          ) : (

            /* ── WEEK VIEW — offset-aware, read-only for past weeks ── */
            <div style={{ padding: "6px 8px", overflow: "visible", flex: 1, display: "flex", flexDirection: "column" }}>
              {/* Empty state for week view */}
              {!isCurrentWeek && Object.keys(blueprint).length === 0 ? (
                <div style={{ textAlign: "center", padding: "48px 20px", color: "#B4B2A9" }}>
                  <div style={{ fontSize: 32, marginBottom: 12 }}>📭</div>
                  <div style={{ fontSize: 14, fontWeight: 500, color: "#2C2C2A", marginBottom: 6 }}>{t("weeklyPlan.noPlanTitle")}</div>
                  <div style={{ fontSize: 11, marginBottom: 10 }}>{t("weeklyPlan.noPlanDesc")}</div>
                  <button
                    onClick={() => { setWeekOffset(0); setSelectedDay(DAYS[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1]); }}
                    style={{ background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "10px 20px", fontSize: 13, fontWeight: 500, cursor: "pointer" }}
                  >Go to current week</button>
                </div>
              ) : (
              <>
              <div style={{ fontSize: 11, color: "#B4B2A9", marginBottom: 6, fontStyle: "italic" }}>
                {!isAdmin
                  ? t("weeklyPlan.viewOnlyDesc")
                  : isCurrentWeek
                    ? (swapMode ? "" : t("weeklyPlan.tapToEdit"))
                    : t("weeklyPlan.readOnly")}
              </div>

              {/* Swap / Copy action bar — admin + current week only */}
              {isAdmin && isCurrentWeek && (
                <SwapCopyBar
                  mode={swapMode}
                  selectedKey={swapSelected}
                  onSwap={() => { setSwapMode('swap'); setSwapSelected(null); }}
                  onCopy={() => { setSwapMode('copy'); setSwapSelected(null); }}
                  onCancel={() => { setSwapMode(null); setSwapSelected(null); }}
                />
              )}

              {/* Column headers — offset-aware dates */}
              <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 3, marginBottom: 2 }}>
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

              {/* Meal rows — label above each row, full width for cards */}
              <div style={{ display: "flex", flexDirection: "column", flex: 1, gap: 4 }}>
              {MEAL_TYPES.map(type => (
                <div key={type} style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "visible" }}>
                  {/* Meal type label — above the row */}
                  <div style={{ display: "flex", alignItems: "center", gap: 4, marginBottom: 3 }}>
                    <span style={{ fontSize: 11 }}>{MEAL_CONFIG[type].icon}</span>
                  <span style={{ fontSize: 8, color: "#B4B2A9", fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.04em" }}>{t(`weeklyPlan.${type.toLowerCase()}`)}</span>
                  </div>
                  {/* Cards row — full width */}
                  <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 3, flex: 1, overflow: "visible", position: "relative", zIndex: 1 }}>
                  {DAYS.map(day => {
                    const slotKey = `${day}-${type}`;
                    const isSelected = swapSelected === slotKey;
                    return (
                      <WeekThumbCard
                        key={slotKey}
                        slotId={slotKey}
                        meal={blueprint[slotKey]}
                        isSelected={isSelected}
                        isSwapMode={!!swapMode}
                        onClick={() => {
                          if (swapMode) {
                            handleSlotTap(slotKey);
                          } else {
                            setSelectedDay(day);
                            setViewMode('day');
                          }
                        }}
                      />
                    );
                  })}
                  </div>
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
            { val: "21", label: t("weeklyPlan.meals") },
            { val: "C2.4", label: t("weeklyPlan.avgLevel") },
            { val: "78%", label: t("weeklyPlan.fridge") },
          ].map((stat, i) => (
            <div key={i} style={{ textAlign: "center" }}>
              <div style={{ color: "#FDFCF8", fontSize: 14, fontWeight: 500 }}>{stat.val}</div>
              <div style={{ color: "#5DCAA5", fontSize: 9, marginTop: 1 }}>{stat.label}</div>
            </div>
          ))}

          {/* Past week → Copy button only (admin). Current week → normal CTA (admin). Members see nothing. */}
          {isAdmin && !isCurrentWeek && (
            <button
              onClick={() => setShowCopyConfirm(true)}
              style={{
                background: "#EF9F27", color: "#2C2C2A",
                border: "none", borderRadius: 14, padding: "11px 16px",
                fontSize: 12, fontWeight: 500, cursor: "pointer",
                boxShadow: "0 0 0 3px rgba(239,159,39,0.3)"
              }}
            >
              {t("weeklyPlan.copyToCurrentWeek")}
            </button>
          )}
          {isAdmin && isCurrentWeek && (
            <div style={{ display: "flex", gap: 8 }}>
              {!isSaved && (
              <button
                onClick={handleGenerateClick}
                disabled={isGenerating}
                style={{
                  background: isGenerating ? "#B4B2A9" : "#1A3A2E",
                  color: "#9FE1CB", border: "1px solid #5DCAA5",
                  borderRadius: 14, padding: "11px 16px",
                  fontSize: 13, fontWeight: 500,
                  cursor: isGenerating ? "not-allowed" : "pointer"
                }}
              >
                {isGenerating ? "..." : "✨ " + t("weeklyPlan.generatePlan")}
              </button>
              )}
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
            </div>
          )}
          {!isAdmin && (
            <div style={{ fontSize: 11, color: "#5DCAA5", fontStyle: "italic" }}>
            {t("weeklyPlan.viewOnly")}
            </div>
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
              {t("weeklyPlan.copyModal.title")}
              </div>
              <div style={{ fontSize: 13, color: "#888780", marginBottom: 24, lineHeight: 1.5 }}>
                {t("weeklyPlan.copyModal.desc", { weekLabel: getWeekLabel() })}
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
                  {t("weeklyPlan.copyModal.cancel")}
                </button>
                <button
                  onClick={copyToCurrentWeek}
                  style={{
                    flex: 2, padding: "13px", borderRadius: 14,
                    border: "none", background: "#1A3A2E",
                    color: "#9FE1CB", fontSize: 14, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  {t("weeklyPlan.copyModal.confirm")}
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>

        {/* ── MEAL EDIT SCREEN — outside app container so fixed overlay covers full viewport ── */}
        {editing && (
          <MealEditScreen
            selected={{ ...editing, date: getTargetDate(editing.day) }}
            onClose={() => setEditing(null)}
            onSave={(updated) => {
              setBlueprint(prev => ({ ...prev, [`${editing.day}-${editing.type}`]: updated }));
              setEditing(null);
              setIsDirty(true);
              setIsAudited(false);
              setIsSaved(false);
            }}
          />
        )}

        {/* ── DEV RESET CONFIRMATION ── */}
        {showResetConfirm && (
          <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.6)", zIndex: 300, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
            <div style={{ width: "100%", maxWidth: 430, background: "#FFF9F2", borderRadius: "24px 24px 0 0", padding: "28px 24px 40px" }}>
              <div style={{ fontSize: 18, fontWeight: 600, color: "#2C2C2A", marginBottom: 8 }}>🗑 Reset this week?</div>
              <div style={{ fontSize: 13, color: "#888780", marginBottom: 24, lineHeight: 1.6 }}>
                {t("weeklyPlan.resetModal.desc")}
              </div>
              <div style={{ display: "flex", gap: 12 }}>
                <button onClick={() => setShowResetConfirm(false)}
                  style={{ flex: 1, padding: "13px", borderRadius: 14, border: "1.5px solid #EDE8E0", background: "transparent", color: "#888780", fontSize: 14, fontWeight: 500, cursor: "pointer" }}>
                  {t("weeklyPlan.copyModal.cancel")}
                </button>
                <button onClick={handleDevReset} disabled={resetting}
                  style={{ flex: 1, padding: "13px", borderRadius: 14, border: "none", background: "#E24B4A", color: "#FDFCF8", fontSize: 14, fontWeight: 500, cursor: resetting ? "not-allowed" : "pointer", opacity: resetting ? 0.7 : 1 }}>
                  {resetting ? t("weeklyPlan.resetModal.confirming") : t("weeklyPlan.resetModal.confirm")}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ── UNSAVED CHANGES WARNING ── */}
        {plannerDirtyWarning && (
          <div style={{
            position: "fixed", inset: 0, background: "rgba(0,0,0,0.6)",
            zIndex: 300, display: "flex", alignItems: "flex-end", justifyContent: "center"
          }}>
            <div style={{
              width: "100%", maxWidth: 430, background: "#FFF9F2",
              borderRadius: "24px 24px 0 0", padding: "28px 24px 40px"
            }}>
              <div style={{ fontSize: 18, fontWeight: 600, color: "#2C2C2A", marginBottom: 8 }}>
                {t("weeklyPlan.unsavedModal.title")}
              </div>
              <div style={{ fontSize: 13, color: "#888780", marginBottom: 24, lineHeight: 1.6 }}>
                {t("weeklyPlan.unsavedModal.desc")}
              </div>
              <div style={{ display: "flex", gap: 12 }}>
                <button
                  onClick={() => setPlannerDirtyWarning(false)}
                  style={{
                    flex: 1, padding: "13px", borderRadius: 14,
                    border: "1.5px solid #EDE8E0", background: "transparent",
                    color: "#888780", fontSize: 14, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  {t("weeklyPlan.unsavedModal.goBack")}
                </button>
                <button
                  onClick={() => {
                    setPlannerDirtyWarning(false);
                    if (pendingNavAction) { pendingNavAction(); setPendingNavAction(null); }
                  }}
                  style={{
                    flex: 1, padding: "13px", borderRadius: 14,
                    border: "none", background: "#993C1D",
                    color: "#FDFCF8", fontSize: 14, fontWeight: 500, cursor: "pointer"
                  }}
                >
                  {t("weeklyPlan.unsavedModal.leave")}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ── CHANGE PASSWORD OVERLAY ── */}
        {plannerShowChangePassword && (
          <ChangePassword onClose={() => setPlannerShowChangePassword(false)} />
        )}

        {/* ── AVAILABILITY OVERLAY — admin only, full screen overlay within planner ── */}
        {showAvailabilityOverlay && (
          <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "#F7F4EE" }}>
            <MemberAvailability
              onBack={() => setShowAvailabilityOverlay(false)}
              onProceed={() => setShowAvailabilityOverlay(false)}
            />
          </div>
        )}

      {/* Re-generate warning modal */}
      {showRegenWarning && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 300, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 24px" }}>
          <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "24px 20px", width: "100%", maxWidth: 360 }}>
            <div style={{ fontSize: 16, fontWeight: 600, color: "#2C2C2A", marginBottom: 8 }}>Re-generate plan?</div>
            <div style={{ fontSize: 13, color: "#888780", marginBottom: 24 }}>This will replace your saved plan with new suggestions. This cannot be undone.</div>
            <div style={{ display: "flex", gap: 10 }}>
              <button onClick={() => setShowRegenWarning(false)}
                style={{ flex: 1, padding: "10px", borderRadius: 10, border: "0.5px solid #EDE8E0", background: "transparent", fontSize: 13, color: "#888780", cursor: "pointer" }}>
                Cancel
              </button>
              <button onClick={() => { setShowRegenWarning(false); setShowQuestionnaire(true); }}
                style={{ flex: 1, padding: "10px", borderRadius: 10, border: "none", background: "#1A3A2E", color: "#9FE1CB", fontSize: 13, fontWeight: 500, cursor: "pointer" }}>
                Yes, re-generate
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Weekly questionnaire modal */}
      {showQuestionnaire && (
        <WeeklyQuestionnaire
          onGenerate={(cfg) => generatePlan(cfg)}
          onClose={() => setShowQuestionnaire(false)}
        />
      )}
    </>
  );
}

function PlannerMenuItem({ icon, label, onClick, danger }) {
  return (
    <div
      onClick={onClick}
      style={{
        padding: "12px 16px", display: "flex", alignItems: "center", gap: 10,
        cursor: "pointer", fontSize: 13,
        color: danger ? "#993C1D" : "#2C2C2A",
        borderBottom: "0.5px solid #EDE8E0",
        background: "transparent"
      }}
    >
      <span style={{ fontSize: 16 }}>{icon}</span>
      <span>{label}</span>
    </div>
  );
}
