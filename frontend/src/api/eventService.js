// src/features/Events/eventService.js

const API_BASE_URL = '/api/events'; 

export const eventService = {
  
  // 1. FETCH BY YEAR: Gets Admin (NULL house_id) and User events for a specific year
  getEvents: async (householdId, year) => {
    try {
      const response = await fetch(`${API_BASE_URL}?household_id=${householdId}&year=${year}`);
      if (!response.ok) throw new Error('Failed to fetch events');
      return await response.json();
    } catch (error) {
      console.error("Service Error [getEvents]:", error);
      return [];
    }
  },

  // 2. CREATE: Handles adding a new UE00x2026 event
  createUserEvent: async (eventData) => {
    try {
      const response = await fetch(`${API_BASE_URL}/user-event`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });
      return await response.json();
    } catch (error) {
      console.error("Service Error [createUserEvent]:", error);
      throw error;
    }
  },

  // 3. DELETE: Removes a personal event
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