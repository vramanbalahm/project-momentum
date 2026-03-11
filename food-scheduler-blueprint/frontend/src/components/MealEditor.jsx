import React, { useState } from 'react';

export default function MealEditor({ selected, onSave, onClose }) {
  const [editedMeal, setEditedMeal] = useState(selected.current || { name: "" });
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
        <input 
            type="text"
            value={editedMeal.name}
            onChange={(e) => setEditedMeal({...editedMeal, name: e.target.value})}
            className="w-full p-4 bg-gray-50 border-2 border-gray-100 rounded-2xl font-bold focus:border-orange-500 outline-none mb-10"
        />
        <div className="flex gap-4">
          <button onClick={onClose} className="flex-1 py-4 rounded-2xl bg-gray-100 text-gray-500 font-black uppercase text-xs">Cancel</button>
          <button onClick={() => onSave(editedMeal)} className="flex-[2] py-4 rounded-2xl bg-orange-600 text-white font-black uppercase text-xs">Update Blueprint</button>
        </div>
      </div>
    </div>
  );
}