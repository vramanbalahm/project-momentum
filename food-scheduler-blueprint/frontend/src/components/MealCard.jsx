import React from 'react';
import { useDraggable, useDroppable } from '@dnd-kit/core';

export default function MealCard({ day, type, meal, auditResult, onClick }) {
  const slotId = `${day}-${type}`; 
  
  const { attributes, listeners, setNodeRef: setDraggableRef, transform } = useDraggable({
    id: `drag-${slotId}`,
    data: { meal }
  });

  const { setNodeRef: setDroppableRef } = useDroppable({
    id: slotId
  });

  const style = transform ? {
    transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
    zIndex: 50
  } : undefined;

  // CRUX: AUTO-RECOVERY LOGIC
  // 1. Try DB fields first
  let rawUrl = meal?.thumb || meal?.hero || meal?.carousel_thumb_url || meal?.hero_image_url;

  // 2. If DB fields are empty, try to construct the path from the meal name
  if (!rawUrl && meal?.name) {
    const formattedName = meal.name.toLowerCase().replace(/\s+/g, '_');
    rawUrl = `/assets/meals/${formattedName}.png`;
  }

  // 3. Absolute final fallback
  const imageUrl = decodeURIComponent(rawUrl || "/assets/meals/placeholder.png");

  return (
    <div 
      ref={setDroppableRef}
      className="p-0 bg-white border-2 border-dashed border-slate-100 rounded-3xl min-h-[160px] relative overflow-hidden shadow-sm hover:shadow-md transition-shadow"
    >
      <div 
        ref={setDraggableRef} 
        style={style} 
        {...listeners} 
        {...attributes}
        onClick={() => meal && onClick({ day, type, meal })}
        className="cursor-pointer group h-full flex flex-col"
      >
        <div className="h-28 w-full overflow-hidden bg-slate-100">
          <img 
            src={imageUrl} 
            alt={meal?.name || "Meal"} 
            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
            onError={(e) => {
                e.target.onerror = null;
                // Tells you exactly which file the system is looking for
                const filename = imageUrl.split('/').pop();
                e.target.src = `https://placehold.co/400x200?text=Check+File:+${filename}`;
            }}
          />
        </div>

        <div className="p-3 flex-grow">
          <span className="text-[9px] font-black uppercase tracking-widest text-slate-400">{type}</span>
          <h4 className="font-bold text-slate-800 text-sm leading-tight mt-1">
            {meal?.name || meal?.meal_name || "Skipped"}
          </h4>
          
          {auditResult && (
            <div className={`mt-2 text-[10px] font-bold ${auditResult.isAvailable ? 'text-green-500' : 'text-orange-500'}`}>
              ● {auditResult.message}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}