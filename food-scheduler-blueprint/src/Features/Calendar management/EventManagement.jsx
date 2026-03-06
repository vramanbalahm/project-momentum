import React, { useState } from 'react';
import IconPickerModal from './IconPickerModal';

const AddEventScreen = ({ householdId }) => {
  const [formData, setFormData] = useState({
    local_name: '',
    event_date: new Date().toISOString().split('T')[0],
    is_sattvic: false,
    icon: '🎂'
  });
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleSave = async () => {
    // Calls the Node.js API we built previously
    const response = await fetch('/api/events/user-event', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...formData, household_id: householdId })
    });
    if (response.ok) alert("Event Baseline Updated!");
  };

  return (
    <div className="p-6 space-y-6">
      <h2 className="text-xl font-bold">Add New Family Event</h2>
      
      {/* Icon Trigger */}
      <div className="flex flex-col items-center">
        <button 
          onClick={() => setIsModalOpen(true)}
          className="text-5xl p-4 bg-orange-50 rounded-full border-2 border-orange-200"
        >
          {formData.icon}
        </button>
        <span className="text-sm text-gray-500 mt-2">Tap to change icon</span>
      </div>

      {/* Inputs */}
      <input 
        type="date" 
        value={formData.event_date}
        onChange={(e) => setFormData({...formData, event_date: e.target.value})}
        className="w-full p-3 border rounded-lg"
      />

      <input 
        placeholder="Event Name (e.g. Mom's Birthday)"
        value={formData.local_name}
        onChange={(e) => setFormData({...formData, local_name: e.target.value})}
        className="w-full p-3 border rounded-lg"
      />

      {/* Sattvic Toggle */}
      <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
        <span>Sattvic Meal Required?</span>
        <input 
          type="checkbox" 
          checked={formData.is_sattvic}
          onChange={(e) => setFormData({...formData, is_sattvic: e.target.checked})}
          className="w-6 h-6"
        />
      </div>

      <button onClick={handleSave} className="w-full bg-orange-500 text-white p-4 rounded-xl font-bold">
        Add to Family Calendar
      </button>

      {isModalOpen && (
        <IconPickerModal 
          selected={formData.icon} 
          onSelect={(icon) => { setFormData({...formData, icon}); setIsModalOpen(false); }}
          onClose={() => setIsModalOpen(false)}
        />
      )}
    </div>
  );
};