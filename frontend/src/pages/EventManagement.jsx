import React, { useState, useEffect } from 'react';
import IconPickerModal from './IconPickerModal';
import { eventService } from './eventService';

const EventManagement = ({ householdId }) => {
  // 1. All State must be inside the component
  const [formData, setFormData] = useState({
    local_name: '',
    event_date: `${new Date().getFullYear()}-${String(new Date().getMonth()+1).padStart(2,'0')}-${String(new Date().getDate()).padStart(2,'0')}`,
    is_sattvic: false,
    icon: '🎂'
  });
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [events, setEvents] = useState([]);

  // 2. Data fetching must be inside a useEffect
  useEffect(() => {
    const loadInitialData = async () => {
      const myId = "USER_001"; // Testing ID
      try {
        const data = await eventService.getEvents(myId, 2026);
        setEvents(data);
      } catch (error) {
        console.error("Failed to load events:", error);
      }
    };
    loadInitialData();
  }, []);

  // 3. The Save Logic
  const handleSave = async () => {
    try {
      // Option A: Using the service you imported
      await eventService.createUserEvent(formData);
      
      // Option B: Your manual fetch logic
      const response = await fetch('/api/events/user-event', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...formData, household_id: householdId })
      });

      if (response.ok) alert("Event Baseline Updated!");
    } catch (error) {
      alert("Error saving event.");
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h2 className="text-xl font-bold text-orange-600">Add New Family Event</h2>
      
      {/* Icon Trigger */}
      <div className="flex flex-col items-center">
        <button 
          onClick={() => setIsModalOpen(true)}
          className="text-5xl p-4 bg-orange-50 rounded-full border-2 border-orange-200 hover:scale-105 transition"
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
        className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-orange-300 outline-none"
      />

      <input 
        placeholder="Event Name (e.g. Mom's Birthday)"
        value={formData.local_name}
        onChange={(e) => setFormData({...formData, local_name: e.target.value})}
        className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-orange-300 outline-none"
      />

      {/* Sattvic Toggle */}
      <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
        <span>Sattvic Meal Required?</span>
        <input 
          type="checkbox" 
          checked={formData.is_sattvic}
          onChange={(e) => setFormData({...formData, is_sattvic: e.target.checked})}
          className="w-6 h-6 accent-orange-500"
        />
      </div>

      <button onClick={handleSave} className="w-full bg-orange-500 hover:bg-orange-600 text-white p-4 rounded-xl font-bold shadow-lg transition">
        Add to Family Calendar
      </button>

      {/* Modal - only shows when isModalOpen is true */}
      {isModalOpen && (
        <IconPickerModal 
          selected={formData.icon} 
          onSelect={(icon) => { 
            setFormData({...formData, icon}); 
            setIsModalOpen(false); 
          }}
          onClose={() => setIsModalOpen(false)}
        />
      )}
    </div>
  );
};

export default EventManagement;