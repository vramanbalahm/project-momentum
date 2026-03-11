import React from 'react';
import { useDraggable, useDroppable } from '@dnd-kit/core';

export default function MealCard({ day, type, meal, auditResult, onClick }) {
  const slotId = `${day}-${type}`; 
  
  // The 'drag-' prefix is crucial for the Swap algorithm in App.jsx
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

  return (
    <div 
      ref={setDroppableRef}
      className="p-4 bg-white border-2 border-dashed border-slate-100 rounded-3xl min-h-[120px] relative"
    >
      <div 
        ref={setDraggableRef} 
        style={style} 
        {...listeners} 
        {...attributes}
        onClick={() => onClick({ day, type, meal })}
        className="cursor-pointer group h-full"
      >
        <span className="text-[10px] font-black uppercase tracking-widest text-slate-300">{type}</span>
        <h4 className="font-bold text-slate-800 leading-tight mt-1">
          {meal?.name || "Skipped"}
        </h4>
        {auditResult && (
          <div className={`mt-2 text-[10px] font-bold ${auditResult.isAvailable ? 'text-green-500' : 'text-orange-500'}`}>
            ● {auditResult.message}
          </div>
        )}
      </div>
    </div>
  );
}