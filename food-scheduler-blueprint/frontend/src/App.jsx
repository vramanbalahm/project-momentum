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
  
  // State Machine for Review & Lock Flow
  const [isAudited, setIsAudited] = useState(false);
  const [isDirty, setIsDirty] = useState(false); 
  const [isLocked, setIsLocked] = useState(false); // Point 10: Persistent Lock state

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
        
        if (planRes.data && planRes.data.plan) {
          planRes.data.plan.forEach(item => {
            const dateObj = new Date(item.date + "T00:00:00"); 
            const dayName = dateObj.toLocaleDateString('en-US', { weekday: 'long' });
            if (item.meal_name && item.meal_name !== "Skipped") {
              initialMap[`${dayName}-${item.type}`] = { name: item.meal_name, code: item.code };
            }
          });
        }

        let suggestionIdx = 0;
        let autoFilled = false;

        DAYS.forEach(day => {
          MEAL_TYPES.forEach(type => {
            const key = `${day}-${type}`;
            if (!initialMap[key] && suggRes.data.length > 0) {
              const pick = suggRes.data[suggestionIdx % suggRes.data.length];
              initialMap[key] = { name: pick.name, code: pick.code };
              suggestionIdx++;
              autoFilled = true; 
            }
          });
        });

        setBlueprint(initialMap);
        if (autoFilled) { setIsDirty(true); setIsAudited(false); }
      } catch (err) { console.error("Sync Error", err); }
    };
    init();
  }, []);

  // Point 8: The Review Action
  const runAudit = async () => {
    const payload = Object.entries(blueprint).map(([key, val]) => {
      const [day, type] = key.split('-');
      return { 
        day, 
        type, 
        to_meal: val?.name || "Skipped", 
        date: getTargetDate(day) 
      };
    });
    const res = await axios.post(`${API_BASE}/audit`, payload);
    const resultMap = {};
    res.data.forEach(r => { resultMap[`${r.day}-${r.type}`] = r; });
    
    setAuditResults(resultMap);
    setIsAudited(true); 
    setIsDirty(false); 
  };

  // Point 10: The Save & Lock Action
  const savePlan = async () => {
    const payload = {
      household_id: HH_ID,
      plan: Object.entries(blueprint).map(([key, val]) => {
        const [day, type] = key.split('-');
        return { 
          day, 
          type, 
          meal_name: val?.name || "Skipped", 
          date: getTargetDate(day) 
        };
      })
    };
    try {
        await axios.post(`${API_BASE}/save-plan`, payload);
        setIsLocked(true); // Lock the UI
        setIsAudited(false); 
        setIsDirty(false);
        alert("Plan Locked Successfully!");
    } catch (e) {
        alert("Locking Failed. Check Console.");
    }
  };

  const handleDragEnd = (event) => {
    if (isLocked) return; // Point 5: Prevent drags if locked
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
        newBlueprint[sourceSlot] = mealAtTarget || { name: "Skipped", code: null };
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
            Sprint 2 • {isLocked ? "Week Finalized" : "Drafting Week"}
          </p>
        </div>
        
        <div className="flex gap-3">
          {isLocked ? (
            <div className="px-6 py-3 bg-slate-100 text-slate-400 rounded-2xl font-black text-xs uppercase border border-slate-200">
              🔒 Finalized
            </div>
          ) : (!isAudited || isDirty) ? (
            <button onClick={runAudit} className="px-6 py-3 bg-white border-2 border-orange-600 text-orange-600 rounded-2xl font-black text-xs uppercase hover:bg-orange-50 transition-all shadow-md">
              Review Plan
            </button>
          ) : (
            <button onClick={savePlan} className="px-6 py-3 bg-green-600 text-white rounded-2xl font-black text-xs uppercase shadow-lg shadow-green-200 hover:scale-105 transition-all">
              Save and Lock
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
                  onClick={(data) => !isLocked && setEditing(data)} // Point 5: Disable clicks if locked
                />
              ))}
            </DayColumn>
          ))}
        </div>
      </DndContext>

      {editing && !isLocked && (
        <MealEditor 
          selected={editing} 
          onClose={() => setEditing(null)} 
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