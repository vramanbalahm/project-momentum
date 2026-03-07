import React, { useState, useEffect } from 'react';
import { DndContext, useDraggable, useDroppable, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { mockWeek } from './mockData';

// path declaration 

<Route path="/manage-events" element={<EventManagement householdId={myUuid} />} />

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
        ${meal ? 'border-transparent hover:border-satvik-gold' : 'border-dashed border-gray-200 bg-gray-50/50'}`}
    >
      {auditResult && (
        <div className={`absolute -right-1 -top-1 w-6 h-6 rounded-full border-2 border-white flex items-center justify-center shadow-lg z-20 group 
          ${auditResult.isAvailable ? 'bg-green-500' : 'bg-orange-500'}`}>
          <span className="text-white text-[10px] font-black">{auditResult.isAvailable ? '✓' : '!'}</span>
          <div className="absolute bottom-full mb-2 hidden group-hover:block bg-gray-900 text-white text-[9px] p-2 rounded shadow-xl w-32 text-center leading-tight">
             {auditResult.message}
          </div>
        </div>
      )}

      <span className="text-[9px] uppercase text-gray-400 block mb-2 font-bold">{type}</span>
      {meal ? (
        <>
          <img src={meal.img} className="w-full h-16 object-cover rounded-md mb-2 pointer-events-none" />
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
  // 1. DYNAMIC DATA STRUCTURE (Ready for DB integration)
  const dynamicEvents = { 
    'Mon': { icon: '🌙', tooltip: 'Lunar Phase: Full Moon' }, 
    'Fri': { icon: '🚩', tooltip: 'Ekadashi: Fasting Rules Apply' }, 
    'Sun': { icon: '🎉', tooltip: 'Community Feast' } 
  };

  const event = dynamicEvents[day];

  const { attributes, listeners, setNodeRef: setDragRef, transform, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });
  const { setNodeRef: setDropRef } = useDroppable({ id: `day-${day}` });

  return (
    <div ref={setDropRef} className="flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px] relative">
      
      {/* FEATURE: FLOATING ICON (Absolute pos prevents row pushing) */}
      {event && (
        <div className="absolute -top-3 -right-1 z-30 group cursor-help">
          <div className="bg-white shadow-lg border border-gray-100 w-8 h-8 rounded-full flex items-center justify-center text-sm hover:scale-110 transition-transform">
            {event.icon}
          </div>
          {/* THE DYNAMIC TOOLTIP */}
          <div className="absolute bottom-full right-0 mb-2 hidden group-hover:block bg-gray-900 text-white text-[10px] p-2 rounded-lg shadow-xl w-32 text-center font-bold z-50">
            {event.tooltip}
          </div>
        </div>
      )}

      {/* HEADER: Fixed height keeps everything aligned */}
      <div ref={setDragRef} {...listeners} {...attributes}
        className="flex flex-col items-center py-3 bg-white rounded-xl shadow-sm border border-gray-100 cursor-grab active:cursor-grabbing h-[85px] justify-center">
        <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">{day}</span>
        <div className="px-3 py-1 bg-satvik-teal rounded-lg shadow-inner">
           <span className="text-lg font-black text-white leading-none">{date.split(' ')[0]}</span>
        </div>
        <span className="text-[9px] font-bold text-satvik-teal/60 uppercase mt-1">{date.split(' ')[1]}</span>
      </div>

      {/* MEAL CARDS (Now perfectly aligned) */}
      <div className="flex flex-col gap-4">
        {children}
      </div>
    </div>
  );
}

export default function App() {
  const [baselineData, setBaselineData] = useState(JSON.parse(JSON.stringify(mockWeek)));
  const [weekData, setWeekData] = useState(mockWeek);
  const [auditResults, setAuditResults] = useState({}); 
  const [isReviewed, setIsReviewed] = useState(false);
  const [selectedMeal, setSelectedMeal] = useState(null);

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const dates = { 'Mon':'02 Mar', 'Tue':'03 Mar', 'Wed':'04 Mar', 'Thu':'05 Mar', 'Fri':'06 Mar', 'Sat':'07 Mar', 'Sun':'08 Mar' };
  const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 8 } }));

  const hasChanges = JSON.stringify(baselineData) !== JSON.stringify(weekData);
  
  useEffect(() => {
    setIsReviewed(false);
    setAuditResults({});
  }, [weekData]);

  const runReview = async () => {
    const changes = [];
    days.forEach(d => mealTypes.forEach(t => {
      if (weekData[d][t]?.name !== baselineData[d][t]?.name) {
        changes.push({ day: d, type: t, to_meal: weekData[d][t]?.name || "Skipped" });
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

  const confirmAndSave = () => {
    setBaselineData(JSON.parse(JSON.stringify(weekData)));
    setIsReviewed(false);
    alert("Plan Baselines and Saved to Vault.");
  };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    setWeekData((prev) => {
      const newData = JSON.parse(JSON.stringify(prev));
      if (active.id.startsWith('day-')) {
        const sourceDay = active.id.replace('day-', '');
        const targetDay = over.id.startsWith('day-') ? over.id.replace('day-', '') : over.id.split('-')[1];
        const temp = newData[sourceDay];
        newData[sourceDay] = newData[targetDay];
        newData[targetDay] = temp;
      } else {
        const [, sDay, sType] = active.id.split('-');
        const isTargetDayColumn = over.id.startsWith('day-');
        const tDay = isTargetDayColumn ? over.id.replace('day-', '') : over.id.split('-')[1];
        const tType = isTargetDayColumn ? sType : over.id.split('-')[2];
        const sourceMeal = newData[sDay][sType];
        newData[sDay][sType] = newData[tDay][tType];
        newData[tDay][tType] = sourceMeal;
      }
      return newData;
    });
  };

  return (
    <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
      <div className="min-h-screen bg-culinary-sand p-8 text-gray-800 pb-32">
        <header className="mb-8 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-satvik-teal tracking-tighter uppercase">Weekly Blueprint</h1>
          <div className="text-[10px] font-mono bg-white px-3 py-1 rounded border shadow-sm tracking-widest uppercase">
             {hasChanges ? "Drafting Mode" : "Baseline Locked"}
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

        {/* FEATURE: MULTI-STAGE BUTTON - Always Visible if needed */}
        <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-40">
          {!hasChanges ? (
             <button onClick={confirmAndSave} className="bg-satvik-teal text-white px-12 py-5 rounded-full font-black shadow-2xl uppercase text-xs tracking-[0.2em] opacity-80 hover:opacity-100 transition-all">
               Confirm & Lock Plan
             </button>
          ) : !isReviewed ? (
             <button onClick={runReview} className="bg-orange-500 text-white px-12 py-5 rounded-full font-black shadow-2xl uppercase text-xs tracking-[0.2em] animate-pulse">
               Review Changes
             </button>
          ) : (
             <button onClick={confirmAndSave} className="bg-satvik-teal text-white px-12 py-5 rounded-full font-black shadow-2xl uppercase text-xs tracking-[0.2em]">
               Save & Lock Plan
             </button>
          )}
        </div>

        {/* CLICK-TO-EDIT DRAWER */}
        {selectedMeal && (
          <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setSelectedMeal(null)}>
            <div className="w-full bg-white rounded-t-[3rem] p-8" onClick={e => e.stopPropagation()}>
               {/* Drawer content as before... */}
               <button onClick={() => setSelectedMeal(null)} className="w-full py-5 rounded-2xl bg-gray-50 font-bold uppercase text-[10px]">Close</button>
            </div>
          </div>
        )}
      </div>
    </DndContext>
  );
}