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

// Get current week's Monday
const getCurrentWeekMonday = () => {
  const today = new Date();
  const day = today.getDay();
  const diff = today.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(today.setDate(diff));
  monday.setHours(0, 0, 0, 0);
  return monday;
};

const getTargetDate = (dayName) => {
  const monday = getCurrentWeekMonday();
  monday.setDate(monday.getDate() + DAYS.indexOf(dayName));
  return monday.toISOString().split('T')[0];
};

const formatDisplayDate = (dayName) => {
  const dateStr = getTargetDate(dayName);
  const d = new Date(dateStr + 'T00:00:00');
  return d.getDate();
};

const getMonthLabel = (dayName) => {
  const dateStr = getTargetDate(dayName);
  const d = new Date(dateStr + 'T00:00:00');
  return d.toLocaleDateString('en-IN', { month: 'short' }).toUpperCase();
};

const isToday = (dayName) => {
  const dateStr = getTargetDate(dayName);
  const today = new Date().toISOString().split('T')[0];
  return dateStr === today;
};

// MEAL TYPE CONFIG
const MEAL_CONFIG = {
  Breakfast: { icon: '☀️', color: '#FFF3DC', time: '7:00 – 9:00 am' },
  Lunch:     { icon: '🌿', color: '#E1F5EE', time: '12:30 – 2:00 pm' },
  Dinner:    { icon: '🌙', color: '#EEEDFE', time: '7:30 – 9:00 pm' }
};

export default function App() {
  const [blueprint, setBlueprint] = useState({});
  const [suggestions, setSuggestions] = useState([]);
  const [auditResults, setAuditResults] = useState({});
  const [editing, setEditing] = useState(null);
  const [isAudited, setIsAudited] = useState(false);
  const [isDirty, setIsDirty] = useState(false);
  const [selectedDay, setSelectedDay] = useState(() => {
    const today = new Date();
    const dayNames = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    const todayName = dayNames[today.getDay()];
    return DAYS.includes(todayName) ? todayName : 'Monday';
  });
  const [isPlanLocked, setIsPlanLocked] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor));

  useEffect(() => {
    const init = async () => {
      setIsLoading(true);
      try {
        const [suggRes, planRes] = await Promise.all([
          axios.get(`${API_BASE}/generate-suggestions/${HH_ID}`),
          axios.get(`${API_BASE}/get-plan/${HH_ID}`)
        ]);

        setSuggestions(suggRes.data);
        const initialMap = {};

        // FT-033: Map from grouped plan (main + sides per slot)
        if (planRes.data?.plan && planRes.data.plan.length > 0) {
          planRes.data.plan.forEach(slot => {
            const dateObj = new Date(slot.date + "T00:00:00");
            const dayName = dateObj.toLocaleDateString('en-US', { weekday: 'long' });
            if (slot.main && slot.main.name !== "Skipped") {
              initialMap[`${dayName}-${slot.type}`] = {
                main: slot.main,
                sides: slot.sides || [],
                event_id: slot.event_id
              };
            }
          });
        }

        // Fill gaps with suggestions
        let suggestionIdx = 0;
        DAYS.forEach(day => {
          MEAL_TYPES.forEach(type => {
            const key = `${day}-${type}`;
            if (!initialMap[key] && suggRes.data.length > 0) {
              const pick = suggRes.data[suggestionIdx % suggRes.data.length];
              initialMap[key] = {
                main: {
                  name: pick.name,
                  recipe_id: pick.recipe_id,
                  hero: pick.hero,
                  thumb: pick.thumb,
                  is_sattvic: pick.is_sattvic,
                  diet_type: pick.diet_type
                },
                sides: []
              };
              suggestionIdx++;
            }
          });
        });

        setBlueprint(initialMap);

        // Auto audit on load
        const auditPayload = Object.entries(initialMap).map(([key, val]) => {
          const [day, type] = key.split('-');
          return {
            day,
            type,
            to_meal: val?.main?.name || "Skipped",
            date: getTargetDate(day)
          };
        });

        const auditRes = await axios.post(`${API_BASE}/audit`, auditPayload);
        const resultMap = {};
        auditRes.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
        setAuditResults(resultMap);
        setIsAudited(true);

      } catch (err) {
        console.error("Critical: Sync Error during init:", err);
      } finally {
        setIsLoading(false);
      }
    };
    init();
  }, []);

  // RETAINED: Manual Audit triggered ONLY by the button
  const runAudit = async () => {
    const payload = Object.entries(blueprint).map(([key, val]) => {
      const [day, type] = key.split('-');
      return {
        day,
        type,
        to_meal: val?.main?.name || "Skipped",
        date: getTargetDate(day)
      };
    });

    try {
      const res = await axios.post(`${API_BASE}/audit`, payload);
      const resultMap = {};
      res.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
      setAuditResults(resultMap);
      setIsAudited(true);
      setIsDirty(false);
    } catch {
      console.error("Audit failed");
    }
  };

  const savePlan = async () => {
    // FT-033: Build multi-dish payload
    const payload = {
      household_id: HH_ID,
      plan: Object.entries(blueprint).map(([key, val]) => {
        const [day, type] = key.split('-');
        const audit = auditResults[key] || {};
        return {
          date: getTargetDate(day),
          type,
          main: val?.main ? {
            recipe_id: val.main.recipe_id || "",
            dish_type: "Main",
            dish_sequence: 1
          } : null,
          sides: (val?.sides || []).map((s, idx) => ({
            recipe_id: s.recipe_id || "",
            dish_type: "Side",
            dish_sequence: idx + 2
          })),
          status: audit.status || "Success",
          message: audit.message || ""
        };
      }).filter(s => s.main && s.main.recipe_id)
    };

    try {
      const response = await axios.post(`${API_BASE}/save-plan`, payload);
      if (response.data.status === "success") {
        setIsDirty(false);
        setIsAudited(true);
        setIsPlanLocked(true);
      }
    } catch (err) {
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

    setIsDirty(true);
    setIsAudited(false);
    setIsPlanLocked(false);
  };

  // Determine CTA button state
  const getCtaButton = () => {
    if (isPlanLocked) return {
      label: "Plan locked",
      bg: "#5DCAA5", color: "#085041",
      onClick: () => { setIsPlanLocked(false); setIsDirty(true); }
    };
    if (!isAudited || isDirty) return {
      label: "Review plan",
      bg: "#EF9F27", color: "#2C2C2A",
      onClick: runAudit
    };
    return {
      label: "Save & lock",
      bg: "#1A3A2E", color: "#FDFCF8",
      onClick: savePlan
    };
  };

  const cta = getCtaButton();

  // Selected day's meals
  const selectedDayMeals = MEAL_TYPES.map(type => ({
    type,
    meal: blueprint[`${selectedDay}-${type}`] || null,
    auditResult: auditResults[`${selectedDay}-${type}`] || null
  }));

  return (
    <div style={{
      minHeight: "100vh",
      background: "#F5F0E8",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      fontFamily: "system-ui, -apple-system, sans-serif"
    }}>
      {/* Phone frame wrapper — mobile-first */}
      <div style={{
        width: "100%",
        maxWidth: 430,
        minHeight: "100vh",
        background: "#FFF9F2",
        display: "flex",
        flexDirection: "column",
        position: "relative"
      }}>

        {/* ── HEADER ── */}
        <div style={{ background: "#1A3A2E", padding: "48px 20px 16px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
            <div>
              <div style={{ color: "#9FE1CB", fontSize: 12, marginBottom: 2 }}>
                Good {new Date().getHours() < 12 ? "morning" : new Date().getHours() < 17 ? "afternoon" : "evening"} 👋
              </div>
              <div style={{ color: "#FDFCF8", fontSize: 20, fontWeight: 500, letterSpacing: -0.3 }}>
                Your week awaits
              </div>
            </div>
            <div style={{
              width: 36, height: 36, borderRadius: "50%",
              background: "#2C4A3E", border: "2px solid #5DCAA5",
              display: "flex", alignItems: "center", justifyContent: "center",
              color: "#9FE1CB", fontSize: 13, fontWeight: 500
            }}>V</div>
          </div>

          {/* Context chips */}
          <div style={{ display: "flex", gap: 8 }}>
            {[
              { icon: "🛒", val: "Market", label: "Check signals" },
              { icon: "🧊", val: "Fridge", label: "Update stock" },
              { icon: "👨‍👩‍👧", val: "4", label: "Members this week" }
            ].map((chip, i) => (
              <div key={i} style={{
                flex: 1, background: "rgba(255,255,255,0.08)",
                borderRadius: 10, padding: "8px 8px",
                border: "0.5px solid rgba(255,255,255,0.12)"
              }}>
                <div style={{ fontSize: 14, marginBottom: 2 }}>{chip.icon}</div>
                <div style={{ color: "#FDFCF8", fontSize: 11, fontWeight: 500 }}>{chip.val}</div>
                <div style={{ color: "#9FE1CB", fontSize: 9, marginTop: 1 }}>{chip.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* ── EVENT BANNER ── */}
        <div style={{ background: "#FFF3DC", borderBottom: "1.5px solid #FAC775", padding: "10px 16px" }}>
          <div style={{ fontSize: 9, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.1em", color: "#854F0B", marginBottom: 8 }}>
            Special this week
          </div>
          <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 2 }}>
            {[
              { emoji: "🎂", title: "Amma's Birthday", date: "Wed, 15 Apr", pill: "Feast day", pillBg: "#FAECE7", pillColor: "#712B13" },
              { emoji: "🕉", title: "Amavasai", date: "Fri, 18 Apr", pill: "Satvik required", pillBg: "#E1F5EE", pillColor: "#085041" }
            ].map((ev, i) => (
              <div key={i} style={{
                flexShrink: 0, background: "#fff", borderRadius: 14,
                padding: "8px 12px", border: "1px solid #FAC775",
                display: "flex", alignItems: "center", gap: 8, minWidth: 160
              }}>
                <span style={{ fontSize: 22 }}>{ev.emoji}</span>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A" }}>{ev.title}</div>
                  <div style={{ fontSize: 10, color: "#888780", marginTop: 1 }}>{ev.date}</div>
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

        {/* ── DAY RIBBON ── */}
        <div style={{
          background: "#FFF9F2", padding: "10px 12px",
          display: "flex", gap: 6, overflowX: "auto",
          borderBottom: "1px solid #EDE8E0"
        }}>
          {DAYS.map(day => {
            const active = day === selectedDay;
            const today = isToday(day);
            return (
              <div
                key={day}
                onClick={() => setSelectedDay(day)}
                style={{
                  flexShrink: 0, textAlign: "center",
                  padding: "7px 8px", borderRadius: 14,
                  cursor: "pointer", minWidth: 44,
                  background: active ? "#1A3A2E" : "transparent",
                  border: today && !active ? "1.5px solid #EF9F27" : "none",
                  transition: "all 0.15s"
                }}
              >
                <div style={{
                  fontSize: 9, fontWeight: 500,
                  textTransform: "uppercase", letterSpacing: "0.04em",
                  color: active ? "#9FE1CB" : "#B4B2A9"
                }}>{day.substring(0, 3)}</div>
                <div style={{
                  fontSize: 17, fontWeight: 500, margin: "2px 0",
                  color: active ? "#fff" : "#2C2C2A"
                }}>{formatDisplayDate(day)}</div>
                {/* Inventory bar */}
                <div style={{ height: 3, borderRadius: 2, background: active ? "#5DCAA5" : "#EDE8E0", marginTop: 4, overflow: "hidden" }}>
                  <div style={{ height: "100%", borderRadius: 2, background: "#1D9E75", width: `${Math.max(10, 90 - DAYS.indexOf(day) * 12)}%` }} />
                </div>
              </div>
            );
          })}
        </div>

        {/* ── SELECTED DAY MEALS ── */}
        <div style={{ flex: 1, padding: "12px 14px", overflowY: "auto" }}>
          {isLoading ? (
            <div style={{ textAlign: "center", padding: "40px 0", color: "#B4B2A9", fontSize: 14 }}>
              Loading your plan...
            </div>
          ) : (
            <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
              {selectedDayMeals.map(({ type, meal, auditResult }) => (
                <div key={type} style={{ marginBottom: 4 }}>
                  {/* Meal type label */}
                  <div style={{
                    display: "flex", alignItems: "center", gap: 6,
                    padding: "6px 2px 4px"
                  }}>
                    <div style={{
                      width: 26, height: 26, borderRadius: "50%",
                      background: MEAL_CONFIG[type].color,
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 13
                    }}>{MEAL_CONFIG[type].icon}</div>
                    <span style={{ fontSize: 12, fontWeight: 500, color: "#2C2C2A" }}>{type}</span>
                    <span style={{ fontSize: 10, color: "#B4B2A9", marginLeft: "auto" }}>{MEAL_CONFIG[type].time}</span>
                  </div>

                  <MealCard
                    key={`${selectedDay}-${type}`}
                    day={selectedDay}
                    type={type}
                    meal={meal}
                    auditResult={auditResult}
                    onClick={(data) => setEditing(data)}
                  />
                </div>
              ))}
            </DndContext>
          )}
        </div>

        {/* ── BOTTOM NAV BAR ── */}
        <div style={{
          background: "#1A3A2E",
          padding: "12px 20px 28px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center"
        }}>
          {/* Weekly stats */}
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

          {/* CTA Button */}
          <button
            onClick={cta.onClick}
            style={{
              background: cta.bg,
              color: cta.color,
              border: "none",
              borderRadius: 14,
              padding: "10px 18px",
              fontSize: 13,
              fontWeight: 500,
              cursor: "pointer",
              transition: "all 0.15s"
            }}
          >
            {cta.label}
          </button>
        </div>

        {/* ── MEAL EDITOR MODAL ── */}
        {editing && (
          <MealEditor
            selected={editing}
            onClose={() => setEditing(null)}
            suggestions={suggestions}
            onSave={(updated) => {
              setBlueprint(prev => ({
                ...prev,
                [`${editing.day}-${editing.type}`]: updated
              }));
              setEditing(null);
              setIsDirty(true);
              setIsAudited(false);
              setIsPlanLocked(false);
            }}
          />
        )}

      </div>
    </div>
  );
}
