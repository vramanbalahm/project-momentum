import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { DndContext, useDraggable, useDroppable, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import EventManagement from './features/Events/EventManagement';

// --- UI COMPONENTS ---

function MealCard({ day, type, meal, auditResult, onClick }) {
  const mealId = `meal-${day}-${type}`;
  const { setNodeRef: setDropRef } = useDroppable({ id: mealId });
  const { attributes, listeners, setNodeRef: setDragRef, transform, isDragging } = useDraggable({
    id: mealId,
    data: { day, type, meal },
  });

  const style = transform ? {
    transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
    zIndex: isDragging ? 100 : 1,
  } : undefined;

  return (
    <div
      ref={(node) => { setDragRef(node); setDropRef(node); }}
      style={style}
      {...listeners}
      {...attributes}
      onClick={(e) => { e.stopPropagation(); onClick({ day, type, current: meal }); }}
      className={`relative bg-white p-3 rounded-xl shadow-sm border-2 min-h-[130px] cursor-grab active:cursor-grabbing transition-all
        ${meal ? 'border-transparent hover:border-orange-200' : 'border-dashed border-gray-200 bg-gray-50/50'}`}
    >
      {auditResult && (
        <div className={`absolute -right-1 -top-1 w-6 h-6 rounded-full border-2 border-white flex items-center justify-center shadow-lg z-20 
          ${auditResult.isAvailable ? 'bg-green-500' : 'bg-orange-500'}`}>
          <span className="text-white text-[10px] font-black">{auditResult.isAvailable ? '✓' : '!'}</span>
        </div>
      )}
      <span className="text-[9px] uppercase text-gray-400 block mb-2 font-bold">{type}</span>
      {meal ? (
        <>
          <img src={meal.img || "https://via.placeholder.com/150?text=Meal"} className="w-full h-16 object-cover rounded-md mb-2 pointer-events-none" />
          <p className="text-xs font-bold leading-tight pointer-events-none">{meal.name}</p>
        </>
      ) : (
        <div className="flex flex-col items-center justify-center h-16 border border-gray-100 rounded-md">
           <p className="text-[10px] text-gray-300 font-bold uppercase tracking-widest">Skipped</p>
        </div>
      )}
    </div>
  );
}

function DayColumn({ day, date, children }) {
  const { attributes, listeners, setNodeRef: setDragRef, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });
  const { setNodeRef: setDropRef } = useDroppable({ id: `day-${day}` });

  return (
    <div ref={setDropRef} className={`flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px] relative transition-opacity ${isDragging ? 'opacity-40' : 'opacity-100'}`}>
      <div ref={setDragRef} {...listeners} {...attributes}
        className="flex flex-col items-center py-3 bg-white rounded-xl shadow-sm border border-gray-100 cursor-grab active:cursor-grabbing h-[85px] justify-center hover:border-orange-300 transition-colors"
      >
        <span className="text-[10px] font-black text-gray-400 uppercase mb-1">{day}</span>
        <div className="px-3 py-1 bg-orange-500 rounded-lg shadow-inner">
           <span className="text-lg font-black text-white">{date.split('-')[2]}</span>
        </div>
        <span className="text-[9px] font-bold text-orange-400 uppercase mt-1">Mar</span>
      </div>
      <div className="flex flex-col gap-4">{children}</div>
    </div>
  );
}

function MealEditor({ selected, onSave, onClose }) {
  const [editedMeal, setEditedMeal] = useState(selected.current || { name: "", portion: "Standard" });
  return (
    <div className="fixed inset-0 bg-black/60 z-50 flex items-end justify-center backdrop-blur-sm" onClick={onClose}>
      <div className="w-full max-w-2xl bg-white rounded-t-[3rem] p-10 shadow-2xl" onClick={e => e.stopPropagation()}>
        <div className="flex justify-between items-start mb-8">
          <div>
            <span className="text-orange-500 font-black uppercase text-xs tracking-widest">{selected.day} • {selected.type}</span>
            <h2 className="text-3xl font-black text-gray-900 mt-1">Edit Preparation</h2>
          </div>
          <button onClick={onClose} className="p-3 bg-gray-100 rounded-full hover:bg-gray-200">✕</button>
        </div>
        <div className="space-y-6 mb-10">
          <input 
            type="text"
            value={editedMeal.name}
            onChange={(e) => setEditedMeal({...editedMeal, name: e.target.value})}
            className="w-full p-4 bg-gray-50 border-2 border-gray-100 rounded-2xl font-bold focus:border-orange-500 outline-none transition-all"
          />
        </div>
        <div className="flex gap-4">
          <button onClick={onClose} className="flex-1 py-4 rounded-2xl bg-gray-100 text-gray-500 font-black uppercase text-xs">Cancel</button>
          <button onClick={() => onSave(editedMeal)} className="flex-[2] py-4 rounded-2xl bg-orange-600 text-white font-black uppercase text-xs">Update Blueprint</button>
        </div>
      </div>
    </div>
  );
}

// --- MAIN APP ---

export default function App() {
  const myUuid = "HOUSEHOLD_001";
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const dates = { 
    'Mon':'2026-03-09', 'Tue':'2026-03-10', 'Wed':'2026-03-11', 
    'Thu':'2026-03-12', 'Fri':'2026-03-13', 'Sat':'2026-03-14', 'Sun':'2026-03-15' 
  };
  const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  const sensor = useSensor(PointerSensor, { activationConstraint: { distance: 8 } });
  const sensors = useSensors(sensor);

  // Helper to create blank week structure
  const createEmptyWeek = () => days.reduce((acc, day) => ({
    ...acc, [day]: { Breakfast: null, Lunch: null, Dinner: null }
  }), {});

  const [baselineData, setBaselineData] = useState(createEmptyWeek());
  const [weekData, setWeekData] = useState(createEmptyWeek());
  const [selectedMeal, setSelectedMeal] = useState(null);
  const [isReviewed, setIsReviewed] = useState(false);
  const [auditResults, setAuditResults] = useState({});
  const [loading, setLoading] = useState(true);

  // --- INITIAL DATA LOAD ---
  useEffect(() => {
    const init = async () => {
      try {
        const planRes = await fetch(`http://127.0.0.1:8000/get-plan/${myUuid}`);
        const savedPlan = await planRes.json();

        if (savedPlan.plan && savedPlan.plan.length > 0) {
          const transformed = createEmptyWeek();
          savedPlan.plan.forEach(p => {
            const dayKey = days.find(d => dates[d] === p.date);
            if (dayKey) transformed[dayKey][p.type] = { name: p.meal_name };
          });
          setWeekData(transformed);
          setBaselineData(JSON.parse(JSON.stringify(transformed)));
        } else {
          const sugRes = await fetch('http://127.0.0.1:8000/generate-suggestions');
          const suggestions = await sugRes.json();
          const autoPlan = createEmptyWeek();
          days.forEach(d => mealTypes.forEach(t => {
            const random = suggestions[Math.floor(Math.random() * suggestions.length)];
            autoPlan[d][t] = { name: random.name };
          }));
          setWeekData(autoPlan);
        }
      } catch (e) {
        console.error("Backend offline, using empty grid");
      } finally {
        setLoading(false);
      }
    };
    init();
  }, []);

  const hasChanges = JSON.stringify(baselineData) !== JSON.stringify(weekData);

  const runReview = async () => {
    const changes = [];
    days.forEach(d => mealTypes.forEach(t => {
      if (weekData[d][t]?.name !== baselineData[d][t]?.name) {
        changes.push({ 
          day: d, 
          type: t, 
          to_meal: weekData[d][t]?.name || "Skipped",
          date: dates[d] 
        });
      }
    }));

    try {
      const response = await fetch('http://127.0.0.1:8000/audit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(changes),
      });
      const data = await response.json();
      const resultsMap = {};
      data.forEach(res => { resultsMap[`${res.day}-${res.type}`] = res; });
      setAuditResults(resultsMap);
      setIsReviewed(true);
    } catch (e) { alert("Python Server Offline"); }
  };

  const confirmAndSave = async () => {
    const fullPlan = [];
    days.forEach(d => {
      mealTypes.forEach(t => {
        fullPlan.push({
          day: d,
          type: t,
          meal_name: weekData[d][t]?.name || "Skipped",
          date: dates[d]
        });
      });
    });

    try {
      const response = await fetch('http://127.0.0.1:8000/save-plan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ household_id: myUuid, plan: fullPlan }),
      });

      if (response.ok) {
        setBaselineData(JSON.parse(JSON.stringify(weekData)));
        setIsReviewed(false);
        setAuditResults({});
        alert("Plan successfully saved to the database!");
      }
    } catch (e) { alert("Error saving plan."); }
  };

  const handleMealUpdate = (updatedMeal) => {
    setWeekData(prev => ({
      ...prev,
      [selectedMeal.day]: { ...prev[selectedMeal.day], [selectedMeal.type]: updatedMeal }
    }));
    setSelectedMeal(null);
  };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    setWeekData((prev) => {
      const newData = JSON.parse(JSON.stringify(prev));
      const [, sDay, sType] = active.id.split('-');
      const tDay = over.id.startsWith('day-') ? over.id.replace('day-', '') : over.id.split('-')[1];
      const tType = over.id.startsWith('day-') ? sType : over.id.split('-')[2];
      const sourceMeal = newData[sDay][sType];
      newData[sDay][sType] = newData[tDay][tType];
      newData[tDay][tType] = sourceMeal;
      return newData;
    });
  };

  if (loading) return (
    <div className="min-h-screen bg-orange-50/30 flex items-center justify-center">
      <div className="text-center">
        <div className="w-12 h-12 border-4 border-orange-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
        <p className="font-black text-orange-600 uppercase tracking-widest">Restoring Blueprint...</p>
      </div>
    </div>
  );

  return (
    <Router>
      <Routes>
        <Route path="/" element={
          <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
            <div className="min-h-screen bg-orange-50/30 p-8 text-gray-800 pb-32">
              <header className="mb-8 flex justify-between items-center">
                <div>
                  <h1 className="text-2xl font-bold text-orange-600 uppercase tracking-tighter">Weekly Blueprint</h1>
                  <p className="text-[10px] font-black text-orange-400 uppercase tracking-[0.2em]">Household: {myUuid}</p>
                </div>
                <div className="flex gap-3">
                  {!hasChanges ? (
                    <div className="px-5 py-2 bg-white/50 text-gray-400 rounded-xl text-xs font-black uppercase border border-gray-100 cursor-not-allowed">Plan Locked ✓</div>
                  ) : !isReviewed ? (
                    <button onClick={runReview} className="px-5 py-2 bg-orange-600 text-white rounded-xl text-xs font-black uppercase hover:bg-orange-700 shadow-lg transition-all active:scale-95">Review Changes</button>
                  ) : (
                    <button onClick={confirmAndSave} className="px-5 py-2 bg-green-600 text-white rounded-xl text-xs font-black uppercase hover:bg-green-700 shadow-lg transition-all active:scale-95">Save & Lock Plan</button>
                  )}
                </div>
              </header>
              <div className="grid grid-cols-7 gap-4">
                {days.map((day) => (
                  <DayColumn key={day} day={day} date={dates[day]}>
                    {mealTypes.map((type) => (
                      <MealCard 
                        key={`${day}-${type}`} 
                        day={day} 
                        type={type} 
                        meal={weekData[day][type]} 
                        auditResult={auditResults[`${day}-${type}`]}
                        onClick={setSelectedMeal} 
                      />
                    ))}
                  </DayColumn>
                ))}
              </div>
              {selectedMeal && <MealEditor selected={selectedMeal} onSave={handleMealUpdate} onClose={() => setSelectedMeal(null)} />}
            </div>
          </DndContext>
        } />
        <Route path="/Events" element={<EventManagement householdId={myUuid} />} />
      </Routes>
    </Router>
  );
}