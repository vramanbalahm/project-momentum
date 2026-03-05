import React, { useState } from 'react';
import { 
  DndContext, 
  useDraggable, 
  useDroppable, 
  PointerSensor, 
  useSensor, 
  useSensors 
} from '@dnd-kit/core';
import { mockWeek } from './mockData';

// --- Draggable Meal Card (Option 1) ---
function MealCard({ day, type, meal, onClick }) {
  // 1. Define the unique ID
  const mealId = `meal-${day}-${type}`;

  // 2. Set up Droppable (The landing zone)
  const { setNodeRef: setDropRef } = useDroppable({ id: mealId });

  // 3. Set up Draggable (The moving object)
  const { attributes, listeners, setNodeRef: setDragRef, transform, isDragging } = useDraggable({
    id: mealId,
    data: { day, type, meal },
    // Removed 'disabled: !meal' so we can drag into skipped slots!
  });

  const style = transform ? {
    transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
    zIndex: isDragging ? 100 : 1,
  } : undefined;

  return (
    <div
      ref={(node) => { setDragRef(node); setDropRef(node); }} // Combine refs
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
        <div className="flex flex-col items-center justify-center h-16 border border-gray-50 rounded-md">
           <p className="text-[10px] text-gray-300 font-bold uppercase tracking-widest">Skipped</p>
        </div>
      )}
    </div>
  );
}

// --- Droppable Day Column (Option 2 Handle) ---
// --- REPLACE your existing DayColumn function with this ---
// --- REPLACE your existing DayColumn function with this ---
function DayColumn({ day, children }) {
  // 1. Draggable logic for the handle
  const { attributes, listeners, setNodeRef: setDragRef, transform, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });

  // 2. Droppable logic for the WHOLE column
  const { setNodeRef: setDropRef } = useDroppable({ 
    id: `day-${day}`,
    data: { type: 'day', day }
  });

  const style = {
    transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
    zIndex: isDragging ? 50 : 1,
    opacity: isDragging ? 0.5 : 1, // Visual feedback while dragging
  };

  return (
    <div 
      ref={setDropRef} // Entire column is a landing zone
      className="flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px] border-2 border-transparent transition-colors hover:bg-black/10"
    >
      <div 
        ref={setDragRef} 
        style={style}
        {...listeners} 
        {...attributes}
        className="text-center font-bold text-satvik-teal py-3 uppercase text-[10px] tracking-widest cursor-grab active:cursor-grabbing bg-white/40 rounded-xl mb-1 shadow-sm border border-white/50"
      >
        ⋮⋮ {day}
      </div>
      {children}
    </div>
  );
}

export default function App() {
  const [weekData, setWeekData] = useState(mockWeek);
  const [selectedMeal, setSelectedMeal] = useState(null);

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  // --- FIX: Sensors to distinguish between CLICK and DRAG ---
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // User must move 8px before it's a drag. Tap stays a click!
      },
    })
  );

  // --- Logic for Drag & Drop (Options 1 & 2) ---
  // --- REPLACE your entire handleDragEnd with this robust version ---
const handleDragEnd = (event) => {
  const { active, over } = event;
  if (!over || active.id === over.id) return;

  const isActiveDay = active.id.startsWith('day-');

  setWeekData((prev) => {
    const newData = JSON.parse(JSON.stringify(prev));

    if (isActiveDay) {
      // --- ROBUST DAY SWAP ---
      const sourceDay = active.id.replace('day-', '');
      
      // Target extraction: If we drop on a meal card, we extract the day from it
      const targetDay = over.id.startsWith('day-') 
        ? over.id.replace('day-', '') 
        : over.id.split('-')[1]; // Extracts 'Tue' from 'meal-Tue-Lunch'

      if (sourceDay && targetDay && sourceDay !== targetDay) {
        const tempDayData = newData[sourceDay];
        newData[sourceDay] = newData[targetDay];
        newData[targetDay] = tempDayData;
      }
    } else {
      // --- ROBUST MEAL SWAP ---
      const [ , sourceDay, sourceType] = active.id.split('-');
      
      // If we drop a meal on a Day Header, we find a slot for it
      const isTargetADay = over.id.startsWith('day-');
      const targetDay = isTargetADay ? over.id.replace('day-', '') : over.id.split('-')[1];
      const targetType = isTargetADay ? sourceType : over.id.split('-')[2];

      const sourceMeal = newData[sourceDay][sourceType];
      const targetMeal = newData[targetDay][targetType];

      newData[targetDay][targetType] = sourceMeal;
      newData[sourceDay][sourceType] = targetMeal;
    }
    return newData;
  });
};

  return (
    <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
      <div className="min-h-screen bg-culinary-sand p-8 text-gray-800">
        <header className="mb-8 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-satvik-teal uppercase tracking-tighter">Weekly Blueprint</h1>
          <div className="text-xs font-mono bg-white px-3 py-1 rounded border shadow-sm">INVENTORY: 85%</div>
        </header>

        <div className="grid grid-cols-7 gap-4">
          {days.map((day) => (
            <DayColumn key={day} day={day}>
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

        {/* --- Options 3 & 4: Surgical Edit & Skip --- */}
        {selectedMeal && (
          <div className="fixed inset-0 bg-black/60 z-50 flex items-end">
            <div className="w-full bg-white rounded-t-[3rem] p-8 shadow-2xl animate-in slide-in-from-bottom">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-satvik-teal">Edit {selectedMeal.day} {selectedMeal.type}</h2>
                <button onClick={() => setSelectedMeal(null)} className="text-2xl text-gray-400 font-bold">✕</button>
              </div>

              {/* Option 3: Replace Alone */}
              <p className="text-[10px] font-bold text-gray-400 uppercase mb-4">Alternatives</p>
              <div className="grid grid-cols-3 gap-4 mb-8">
                {selectedMeal.current?.alternatives?.map(alt => (
                  <div 
                    key={alt.name} 
                    onClick={() => {
                      const newData = { ...weekData };
                      newData[selectedMeal.day][selectedMeal.type] = alt;
                      setWeekData(newData);
                      setSelectedMeal(null);
                    }}
                    className="border-2 border-gray-100 p-3 rounded-2xl hover:border-satvik-gold transition cursor-pointer"
                  >
                    <img src={alt.img} className="w-full h-20 object-cover rounded-xl mb-2" />
                    <p className="text-xs font-bold">{alt.name}</p>
                  </div>
                )) || <p className="col-span-3 text-center text-gray-400 py-4">No alternatives for this slot.</p>}
              </div>

              {/* Option 4: Skip */}
              <div className="flex gap-4">
                <button 
                  onClick={() => {
                    const newData = { ...weekData };
                    newData[selectedMeal.day][selectedMeal.type] = null;
                    setWeekData(newData);
                    setSelectedMeal(null);
                  }}
                  className="flex-1 py-4 rounded-2xl bg-red-50 text-red-600 font-bold uppercase text-xs border border-red-100"
                >
                  Skip Meal
                </button>
                <button onClick={() => setSelectedMeal(null)} className="flex-1 py-4 rounded-2xl bg-gray-100 text-gray-600 font-bold uppercase text-xs">
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DndContext>
  );
}