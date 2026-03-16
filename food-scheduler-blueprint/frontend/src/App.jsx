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

const getTargetDate = (dayName) => {
  const start = new Date("2026-03-09T00:00:00");
  start.setDate(start.getDate() + DAYS.indexOf(dayName));
  return start.toISOString().split('T')[0];
};

export default function App() {
  const [blueprint, setBlueprint] = useState({});
  const [suggestions, setSuggestions] = useState([]);
  const [auditResults, setAuditResults] = useState({});
  const [editing, setEditing] = useState(null);

  const [isAudited, setIsAudited] = useState(false);
  const [isDirty, setIsDirty] = useState(false);

  const sensors = useSensors(useSensor(PointerSensor), useSensor(KeyboardSensor));

  useEffect(() => {
    const init = async () => {
      try {
        const [suggRes, planRes] = await Promise.all([
          axios.get(`${API_BASE}/generate-suggestions/${HH_ID}`),
          axios.get(`${API_BASE}/get-plan/${HH_ID}`)
        ]);

        setSuggestions(suggRes.data);
        const initialMap = {};

        // 1. Map from meal_event_detail
        if (planRes.data?.plan && planRes.data.plan.length > 0) {
          planRes.data.plan.forEach(item => {
            const dateObj = new Date(item.date + "T00:00:00");
            const dayName = dateObj.toLocaleDateString('en-US', { weekday: 'long' });
            if (item.meal_name && item.meal_name !== "Skipped") {
              initialMap[`${dayName}-${item.type}`] = {
                name: item.meal_name,
                recipe_id: item.recipe_id, 
                hero_image: item.hero,
                code: item.code
              };
            }
          });
        }

        // 2. Fill gaps
        let suggestionIdx = 0;
        DAYS.forEach(day => {
          MEAL_TYPES.forEach(type => {
            const key = `${day}-${type}`;
            if (!initialMap[key] && suggRes.data.length > 0) {
              const pick = suggRes.data[suggestionIdx % suggRes.data.length];
              initialMap[key] = {
                name: pick.name,
                recipe_id: pick.recipe_id, 
                hero_image: pick.hero, 
                code: pick.code
              };
              suggestionIdx++;
            }
          });
        });

        setBlueprint(initialMap);

        // >>> THE ONLY NEW ADDITION: Page Load Handshake
        // We create the payload from initialMap to avoid waiting for State
        // 1. Setting the UI state
        setBlueprint(initialMap);

        // 2. THE REFRESH HANDSHAKE (Using your preferred variable name)
        const auditPayload = Object.entries(initialMap).map(([key, val]) => {
          const [day, type] = key.split('-');
          return {
            day,
            type,
            to_meal: val?.name || "Skipped",
            recipe_id: val?.recipe_id || "", 
            date: getTargetDate(day)
          };
        });

        // 3. Calling the audit immediately on load
        const auditRes = await axios.post(`${API_BASE}/audit`, auditPayload);
        
        const resultMap = {};
        auditRes.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
        
        setAuditResults(resultMap);
        setIsAudited(true);
        // >>> END ADDITION

      } catch (err) {
        console.error("Critical: Sync Error during init:", err);
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
        to_meal: val?.name || "Skipped",
        recipe_id: val?.recipe_id || "",
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
    // 1. Prepare the payload by merging Blueprint (data) and Audit (metadata)
    const payload = {
      household_id: HH_ID,
      plan: Object.entries(blueprint).map(([key, val]) => {
        const [day, type] = key.split('-');
        
        // Retrieve the audit result for this specific slot (if it exists)
        const audit = auditResults[key] || {}; 

        return {
          day,
          type,
          date: getTargetDate(day),
          meal_name: val?.name || "Skipped",
          // The "Multi-lookup" ensures we send a string the backend can validate
          recipe_id: val?.recipe_id || "", 
          // New: Persistence of the Momentum highlights
          status: audit.status || "Success",
          message: audit.message || ""
        };
      })
    };

    try {
      // 2. Execute the Atomic Sync (Delete -> Insert -> Audit)
      const response = await axios.post(`${API_BASE}/save-plan`, payload);
      
      if (response.data.status === "success") {
        // 3. Reset UI state on success
        setIsDirty(false);
        setIsAudited(true); // Keep highlights visible
        alert("Plan & Audit History Saved Successfully!");
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
        newBlueprint[sourceSlot] = mealAtTarget || { name: "Skipped", recipe_id: "" };
      }
      return newBlueprint;
    });

    setIsDirty(true);
    setIsAudited(false);
  };

  return (
    <div className="min-h-screen bg-[#FDFCFB] p-8 font-sans text-slate-900">
      <header className="flex justify-between items-center mb-12 max-w-7xl mx-auto">
        <div>
          <h1 className="text-4xl font-black tracking-tight italic">MOMENTUM <span className="text-orange-600">DIVERGENCE</span></h1>
          <p className="text-slate-400 font-bold text-xs uppercase tracking-tighter mt-1">
            Sprint 3 • Continuous Persistence
          </p>
        </div>

        <div className="flex gap-3">
          {(!isAudited || isDirty) ? (
            <button onClick={runAudit} className="px-6 py-3 bg-white border-2 border-orange-600 text-orange-600 rounded-2xl font-black text-xs uppercase hover:bg-orange-50 transition-all shadow-md">
              Review Plan
            </button>
          ) : (
            <button onClick={savePlan} className="px-6 py-3 bg-green-600 text-white rounded-2xl font-black text-xs uppercase shadow-lg shadow-green-200 hover:scale-105 transition-all">
              Save Plan
            </button>
          )}
        </div>
      </header>

      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
        <div className="grid grid-cols-7 gap-6 max-w-[1600px] mx-auto">
          {DAYS.map(day => (
            <DayColumn key={day} day={day} date={getTargetDate(day)}>
              {MEAL_TYPES.map(type => (
                <MealCard
                  key={`${day}-${type}`}
                  day={day}
                  type={type}
                  meal={blueprint[`${day}-${type}`]}
                  auditResult={auditResults[`${day}-${type}`]}
                  onClick={(data) => setEditing(data)}
                />
              ))}
            </DayColumn>
          ))}
        </div>
      </DndContext>

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
          }}
        />
      )}
    </div>
  );
}