// src/features/Events/eventService.js

const API_BASE_URL = '/api/events'; // Adjust based on your backend config

export const eventService = {
  
  // 1. FETCH ALL: Gets both Admin (NULL house_id) and User events
  getEvents: async (householdId) => {
    try {
      const response = await fetch(`${API_BASE_URL}?household_id=${householdId}`);
      if (!response.ok) throw new Error('Failed to fetch events');
      return await response.json();
    } catch (error) {
      console.error("Service Error [getEvents]:", error);
      return [];
    }
  },

  // 2. CREATE: Handles the "Add to Family Calendar" action
  createUserEvent: async (eventData) => {
    try {
      const response = await fetch(`${API_BASE_URL}/user-event`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData), // Includes local_name, date, is_sattvic, icon, household_id
      });
      return await response.json();
    } catch (error) {
      console.error("Service Error [createUserEvent]:", error);
      throw error;
    }
  },

  // 3. UPDATE: For editing existing personal events
  updateUserEvent: async (eventCode, updateData) => {
    try {
      const response = await fetch(`${API_BASE_URL}/${eventCode}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updateData),
      });
      return await response.json();
    } catch (error) {
      console.error("Service Error [updateUserEvent]:", error);
      throw error;
    }
  },

  // 4. DELETE: Removes personal events only
  deleteUserEvent: async (eventCode) => {
    try {
      const response = await fetch(`${API_BASE_URL}/${eventCode}`, {
        method: 'DELETE',
      });
      return await response.json();
    } catch (error) {
      console.error("Service Error [deleteUserEvent]:", error);
      throw error;
    }
  }
};