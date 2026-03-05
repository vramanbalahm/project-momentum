import React, { useState, useEffect } from 'react';
import { DndContext, useDraggable, useDroppable, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { mockWeek } from './mockData';

// --- COMPONENTS (No changes to MealCard or DayColumn) ---

function MealCard({ day, type, meal, onClick }) {
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
      onClick={() => onClick({ day, type, current: meal })}
      className={`bg-white p-3 rounded-xl shadow-sm border-2 min-h-[130px] cursor-grab active:cursor-grabbing transition-all
        ${meal ? 'border-transparent hover:border-satvik-gold' : 'border-dashed border-gray-200 bg-gray-50/50'}`}
    >
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

function DayColumn({ day, children }) {
  const { attributes, listeners, setNodeRef: setDragRef, transform, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });
  const { setNodeRef: setDropRef } = useDroppable({ id: `day-${day}`, data: { type: 'day', day } });

  const style = {
    transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
    zIndex: isDragging ? 50 : 1,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div ref={setDropRef} className="flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px]">
      <div ref={setDragRef} style={style} {...listeners} {...attributes}
        className="text-center font-bold text-satvik-teal py-3 uppercase text-[10px] tracking-widest cursor-grab active:cursor-grabbing bg-white/40 rounded-xl mb-1 shadow-sm border border-white/50">
        ⋮⋮ {day}
      </div>
      {children}
    </div>
  );
}

export default function App() {
  // 1. STORAGE: Existing (Baseline) vs Changed (Live)
  const [baselineData] = useState(JSON.parse(JSON.stringify(mockWeek))); // Original retrieval
  const [weekData, setWeekData] = useState(mockWeek); // Edited data
  const [selectedMeal, setSelectedMeal] = useState(null);
  const [showAudit, setShowAudit] = useState(false);

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 8 } }));

  // 2. LOGIC: Comparison Engine (Identifies what changed)
  // --- REPLACE your existing getChanges function with this ---
  const getChanges = () => {
    let changes = [];
    days.forEach(day => {
      mealTypes.forEach(type => {
        const original = baselineData[day][type]?.name;
        const current = weekData[day][type]?.name;
        
        if (original !== current) {
          // MOCK CHECK: In production, this calls the Python Backend
          // For now, we simulate availability based on the recipe name
          const isAvailable = current !== "Paneer Butter Masala"; // Example: Out of Paneer

          changes.append({ 
            day, 
            type, 
            from: original || "Skipped", 
            to: current || "Skipped",
            isAvailable: current === "Skipped" ? true : isAvailable 
          });
        }
      });
    });
    return changes;
  };
  const activeChanges = getChanges();

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const isActiveDay = active.id.startsWith('day-');

    setWeekData((prev) => {
      const newData = JSON.parse(JSON.stringify(prev));
      if (isActiveDay) {
        const sourceDay = active.id.replace('day-', '');
        const targetDay = over.id.startsWith('day-') ? over.id.replace('day-', '') : over.id.split('-')[1];
        const temp = newData[sourceDay];
        newData[sourceDay] = newData[targetDay];
        newData[targetDay] = temp;
      } else {
        const [ , sDay, sType] = active.id.split('-');
        const isTargetADay = over.id.startsWith('day-');
        const tDay = isTargetADay ? over.id.replace('day-', '') : over.id.split('-')[1];
        const tType = isTargetADay ? sType : over.id.split('-')[2];
        const sMeal = newData[sDay][sType];
        newData[sDay][sType] = newData[tDay][tType];
        newData[tDay][tType] = sMeal;
      }
      return newData;
    });
  };

  return (
    <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
      <div className="min-h-screen bg-culinary-sand p-8 text-gray-800 pb-32">
        <header className="mb-8 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-satvik-teal tracking-tighter uppercase">Weekly Blueprint</h1>
          <div className="text-xs font-mono bg-white px-3 py-1 rounded border shadow-sm">STRESS: ₹1,277</div>
        </header>

        <div className="grid grid-cols-7 gap-4">
          {days.map((day) => (
            <DayColumn key={day} day={day}>
              {mealTypes.map((type) => (
                <MealCard key={`${day}-${type}`} day={day} type={type} meal={weekData[day][type]} onClick={setSelectedMeal} />
              ))}
            </DayColumn>
          ))}
        </div>

        {/* 3. UI: Review Changes Button (Only shows if there are changes) */}
        {activeChanges.length > 0 && (
          <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-40">
            <button 
              onClick={() => setShowAudit(true)}
              className="bg-satvik-teal text-white px-8 py-4 rounded-full font-bold shadow-2xl flex items-center gap-3 animate-bounce"
            >
              Review {activeChanges.length} Changes
            </button>
          </div>
        )}

        {/* Surgical Edit Drawer (Option 3 & 4) */}
        {selectedMeal && (
          <div className="fixed inset-0 bg-black/60 z-50 flex items-end">
            <div className="w-full bg-white rounded-t-[3rem] p-8 shadow-2xl">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold">Edit {selectedMeal.day} {selectedMeal.type}</h2>
                <button onClick={() => setSelectedMeal(null)} className="text-2xl text-gray-400">✕</button>
              </div>
              <div className="grid grid-cols-3 gap-4 mb-8">
                {selectedMeal.current?.alternatives?.map(alt => (
                  <div key={alt.name} onClick={() => {
                    const newData = JSON.parse(JSON.stringify(weekData));
                    newData[selectedMeal.day][selectedMeal.type] = alt;
                    setWeekData(newData);
                    setSelectedMeal(null);
                  }} className="border p-3 rounded-2xl hover:border-satvik-gold cursor-pointer">
                    <img src={alt.img} className="w-full h-20 object-cover rounded-xl mb-2" />
                    <p className="text-xs font-bold">{alt.name}</p>
                  </div>
                ))}
              </div>
              <button onClick={() => {
                const newData = JSON.parse(JSON.stringify(weekData));
                newData[selectedMeal.day][selectedMeal.type] = null;
                setWeekData(newData);
                setSelectedMeal(null);
              }} className="w-full py-4 rounded-2xl bg-red-50 text-red-600 font-bold uppercase text-xs">Skip Meal</button>
            </div>
          </div>
        )}

        {/* 4. UI: Comparative Audit Drawer */}
        {/* --- REPLACE the content inside the showAudit div with this --- */}
        {showAudit && (
          <div className="fixed inset-0 bg-satvik-teal/90 z-50 flex items-center justify-center p-6">
            <div className="bg-white w-full max-w-lg rounded-[2rem] p-8 shadow-2xl">
              <h2 className="text-2xl font-bold text-satvik-teal mb-6">Stock Audit</h2>
              
              <div className="space-y-4 mb-8">
                {activeChanges.map((change, i) => (
                  <div key={i} className="flex items-center justify-between border-b pb-4 border-gray-100">
                    <div>
                      <p className="text-[10px] font-bold text-gray-400 uppercase">{change.day} • {change.type}</p>
                      <div className="flex items-center gap-2">
                         <p className="text-sm font-bold">{change.to}</p>
                         {/* Availability Badge */}
                         {change.isAvailable ? (
                           <span className="text-[9px] bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-bold uppercase">In Stock</span>
                         ) : (
                           <span className="text-[9px] bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-bold uppercase">Missing Items</span>
                         )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className="flex gap-4">
                <button onClick={() => setShowAudit(false)} className="flex-1 py-4 font-bold text-gray-500 uppercase text-xs">Edit More</button>
                <button className="flex-1 py-4 bg-satvik-teal text-white rounded-2xl font-bold uppercase text-xs shadow-lg">Confirm Plan</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DndContext>
  );
}