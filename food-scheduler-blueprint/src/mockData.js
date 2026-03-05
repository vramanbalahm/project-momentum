export const mockWeek = {
    Mon: {
      Breakfast: { name: "Savory Poha", img: "https://images.unsplash.com/photo-1601050638917-3f94dd58995c?q=80&w=200", complexity: "C2" },
      Lunch: {
        
        name: "Dal Tadka & Rice", 
      img: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=200", 
      complexity: "C3",
      // THE DRAWER NEEDS THIS ARRAY:
      alternatives: [
        { name: "Tomato Kootu", type: "Regional Swap A", img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200" },
        { name: "Majjige Huli", type: "Regional Swap B", img: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200" },
        { name: "Yellow Moong Dal", type: "AI Best Match", img: "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=200" }
      ]
     },
      Dinner: { name: "Vegetable Upma", img: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=200", complexity: "C2" }
    },
    Tue: {
      Breakfast: { name: "Mixed Fruit Bowl", img: "https://images.unsplash.com/photo-1519996529931-28324d5a630e?q=80&w=200", complexity: "C1" },
      Lunch: { name: "Kichdi", img: "https://images.unsplash.com/photo-1606491956689-2ea8c5119c85?q=80&w=200", complexity: "C2" },
      Dinner: { name: "Roti & Thoran", img: "https://images.unsplash.com/photo-1589302168068-964664d93dc0?q=80&w=200", complexity: "C3" }
    },
    // Adding placeholders for others to keep the grid full
    Wed: {}, Thu: {}, Fri: {}, Sat: {}, Sun: {}
  };