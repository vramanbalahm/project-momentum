import React from 'react';
import { useDraggable, useDroppable } from '@dnd-kit/core';

export default function DayColumn({ day, date, children }) {
  const { attributes, listeners, setNodeRef: setDragRef, isDragging } = useDraggable({
    id: `day-${day}`,
    data: { type: 'day', day }
  });
  const { setNodeRef: setDropRef } = useDroppable({ id: `day-${day}` });

  return (
    <div ref={setDropRef} className={`flex flex-col gap-4 bg-black/5 p-2 rounded-2xl min-h-[500px] transition-opacity ${isDragging ? 'opacity-40' : 'opacity-100'}`}>
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