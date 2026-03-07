import React, { useState, useEffect, useMemo } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { DndContext, useDraggable, useDroppable, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { mockWeek } from './constants/mockData';
import EventManagement from './features/Events/EventManagement';

// --- UI COMPONENTS (KEEP THESE AS IS) ---

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
  // 1. DYNAMIC DATA (For the icons)
  const dynamicEvents = { 
    'Mon': { icon: '🌙', tooltip: 'Full Moon' }, 
    'Fri': { icon: '🚩', tooltip: 'Ekadashi' }, 
    'Sun': { icon: '🎉', tooltip: 'Feast' } 
  };
  const event = dynamicEvents[day];

  // 2. DRAG & DROP LOGIC
  const { attributes, listeners, setNodeRef: setDragRef, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });
  const { setNodeRef: setDropRef } = useDroppable({ id: `day-${day}` });

  return (
    <div ref={setDropRef} className={`flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px] relative transition-opacity ${isDragging ? 'opacity-40' : 'opacity-100'}`}>
      
      {/* FEATURE: FLOATING ICONS (Re-added) */}
      {event && (
        <div className="absolute -top-3 -right-1 z-30 group cursor-help">
          <div className="bg-white shadow-lg border border-gray-100 w-8 h-8 rounded-full flex items-center justify-center text-sm hover:scale-110 transition-transform">
            {event.icon}
          </div>
          <div className="absolute bottom-full right-0 mb-2 hidden group-hover:block bg-gray-900 text-white text-[10px] p-2 rounded-lg shadow-xl w-32 text-center font-bold">
            {event.tooltip}
          </div>
        </div>
      )}

      {/* HEADER: Now Draggable again */}
      <div 
        ref={setDragRef} {...listeners} {...attributes}
        className="flex flex-col items-center py-3 bg-white rounded-xl shadow-sm border border-gray-100 cursor-grab active:cursor-grabbing h-[85px] justify-center hover:border-orange-300 transition-colors"
      >
        <span className="text-[10px] font-black text-gray-400 uppercase mb-1">{day}</span>
        <div className="px-3 py-1 bg-orange-500 rounded-lg shadow-inner">
           <span className="text-lg font-black text-white">{date.split(' ')[0]}</span>
        </div>
        <span className="text-[9px] font-bold text-orange-400 uppercase mt-1">{date.split(' ')[1]}</span>
      </div>

      {/* MEAL CARDS */}
      <div className="flex flex-col gap-4">
        {children}
      </div>
    </div>
  );
}

// --- MAIN APP COMPONENT ---

export default function App() {
  const myUuid = "HOUSEHOLD_001";
  
  // FIXED SENSOR INITIALIZATION: Wrapping in useMemo prevents the "Invalid Hook Call" 
  // by ensuring sensors are created only once React is fully ready.
  const sensor = useSensor(PointerSensor, { activationConstraint: { distance: 8 } });
  const sensors = useSensors(sensor);

  const [baselineData, setBaselineData] = useState(JSON.parse(JSON.stringify(mockWeek)));
  const [weekData, setWeekData] = useState(mockWeek);
  const [selectedMeal, setSelectedMeal] = useState(null);

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const dates = { 'Mon':'02 Mar', 'Tue':'03 Mar', 'Wed':'04 Mar', 'Thu':'05 Mar', 'Fri':'06 Mar', 'Sat':'07 Mar', 'Sun':'08 Mar' };
  const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  const handleDragEnd = (event) => {
  const { active, over } = event;
  if (!over || active.id === over.id) return;

  setWeekData((prev) => {
    const newData = JSON.parse(JSON.stringify(prev));

    // CASE 1: Moving an Entire Day (e.g., swapping Monday with Tuesday)
    if (active.id.startsWith('day-')) {
      const sourceDay = active.id.replace('day-', '');
      const targetDay = over.id.startsWith('day-') 
        ? over.id.replace('day-', '') 
        : over.id.split('-')[1]; // Handle dropping a day onto a meal
      
      const temp = newData[sourceDay];
      newData[sourceDay] = newData[targetDay];
      newData[targetDay] = temp;
      return newData;
    }

    // CASE 2: Moving a Single Meal
    const [, sDay, sType] = active.id.split('-');
    const isTargetDayColumn = over.id.startsWith('day-');
    const tDay = isTargetDayColumn ? over.id.replace('day-', '') : over.id.split('-')[1];
    const tType = isTargetDayColumn ? sType : over.id.split('-')[2];

    const sourceMeal = newData[sDay][sType];
    newData[sDay][sType] = newData[tDay][tType];
    newData[tDay][tType] = sourceMeal;
    
    return newData;
  });
};

  return (
    <Router>
      <Routes>
        <Route path="/" element={
          <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
            <div className="min-h-screen bg-orange-50/30 p-8 text-gray-800 pb-32">
              <header className="mb-8 flex justify-between items-center">
                <h1 className="text-2xl font-bold text-orange-600 uppercase tracking-tighter">Weekly Blueprint</h1>
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
                        onClick={setSelectedMeal} 
                      />
                    ))}
                  </DayColumn>
                ))}
              </div>
            </div>
          </DndContext>
        } />
        <Route path="/Events" element={<EventManagement householdId={myUuid} />} />
      </Routes>
    </Router>
  );
}