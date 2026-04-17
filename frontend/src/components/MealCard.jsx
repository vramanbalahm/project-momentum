import React from "react";
import { useDraggable, useDroppable } from "@dnd-kit/core";

// FT-041: MealCard supports multiple main dishes (split hero) + horizontal sides with names
// DnD enabled for day view slot reordering
export default function MealCard({ day, type, meal, auditResult, onClick, isEditable = true, isHighlighted = false }) {
  const slotId = `${day}-${type}`;

  const { attributes, listeners, setNodeRef: setDraggableRef, transform } = useDraggable({
    id: `drag-${slotId}`,
    data: { meal }
  });

  const { setNodeRef: setDroppableRef } = useDroppable({ id: slotId });

  const dragStyle = transform ? {
    transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
    zIndex: 50
  } : undefined;

  // Support both old shape (meal.main) and new shape (meal.mains array)
  const mainsRaw = meal?.mains || (meal?.main ? [meal.main] : []);
  const mains = mainsRaw.slice(0, 3);
  const sides = meal?.sides || [];

  const getImgUrl = (dish) => {
    let url = dish?.thumb || dish?.hero || dish?.carousel_thumb_url || dish?.hero_image_url;
    if (!url && dish?.name) {
      url = `/assets/meals/${dish.name.toLowerCase().replace(/\s+/g, "_")}.png`;
    }
    return decodeURIComponent(url || "/assets/meals/placeholder.png");
  };

  const auditColor = auditResult?.status === "Success" ? "#1D9E75"
    : auditResult?.status === "Warning" ? "#EF9F27"
    : auditResult?.status === "Conflict" ? "#E24B4A"
    : "#B4B2A9";

  return (
    <div
      ref={setDroppableRef}
      style={{
        background: isHighlighted ? "#FFF3DC" : "#fff",
        borderRadius: 20,
        border: isHighlighted ? "1px solid #FAC775" : "1px solid #EDE8E0",
        overflow: dragStyle ? "visible" : "hidden",
        marginBottom: 12,
        position: "relative"
      }}
    >
      <div
        ref={setDraggableRef}
        style={{ ...dragStyle, position: "relative", zIndex: dragStyle ? 100 : 1 }}
        {...listeners}
        {...attributes}
      >
        {/* HERO — splits equally across all mains */}
        <div
          style={{ height: 110, display: "flex", position: "relative", overflow: "hidden", cursor: "pointer" }}
          onClick={() => mains.length > 0 && onClick({ day, type, meal })}
        >
          {/* Edit button */}
          {isEditable && (
            <div
              onClick={e => { e.stopPropagation(); mains.length > 0 && onClick({ day, type, meal }); }}
              style={{
                position: "absolute", top: 8, left: 8, zIndex: 10,
                background: "rgba(26,58,46,0.88)", color: "#9FE1CB",
                fontSize: 10, fontWeight: 500, borderRadius: 8,
                padding: "4px 10px", cursor: "pointer"
              }}
            >Edit</div>
          )}

          {/* Audit pill */}
          {auditResult && (
            <div style={{
              position: "absolute", top: 8, right: 8, zIndex: 10,
              display: "flex", alignItems: "center", gap: 4,
              background: "rgba(255,255,255,0.92)", borderRadius: 20, padding: "3px 8px"
            }}>
              <div style={{ width: 6, height: 6, borderRadius: "50%", background: auditColor, flexShrink: 0 }} />
              <span style={{ fontSize: 9, color: "#444441", fontWeight: 500 }}>
                {auditResult.status === "Success" ? "Ready"
                  : auditResult.status === "Warning" ? "Check"
                  : auditResult.status === "Conflict" ? "Conflict"
                  : "Pending"}
              </span>
            </div>
          )}

          {mains.length === 0 ? (
            <div style={{ flex: 1, background: "#EDE8E0", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontSize: 11, color: "#B4B2A9" }}>No meal set</span>
            </div>
          ) : (
            mains.map((dish, idx) => (
              <div key={idx} style={{ flex: 1, position: "relative", borderLeft: idx > 0 ? "0.5px solid rgba(255,255,255,0.3)" : "none" }}>
                <img
                  src={getImgUrl(dish)}
                  alt={dish?.name || "Meal"}
                  style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }}
                  onError={e => {
                    e.target.onerror = null;
                    e.target.src = `https://placehold.co/400x160/C8B89A/2C2C2A?text=${encodeURIComponent(dish?.name || "Meal")}`;
                  }}
                />
                <div style={{
                  position: "absolute", bottom: 0, left: 0, right: 0,
                  background: "linear-gradient(to top, rgba(26,58,46,0.85), transparent)",
                  padding: "18px 6px 6px"
                }}>
                  <div style={{
                    color: "#fff",
                    fontSize: mains.length === 1 ? 13 : 9,
                    fontWeight: 500, lineHeight: 1.2,
                    whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
                  }}>
                    {dish?.name || "Meal"}
                  </div>
                </div>
                {idx === 0 && dish?.is_sattvic && (
                  <div style={{
                    position: "absolute", bottom: 6, right: 4,
                    background: "rgba(93,202,165,0.25)", color: "#085041",
                    fontSize: 8, padding: "2px 5px", borderRadius: 20, fontWeight: 500
                  }}>Satvik</div>
                )}
              </div>
            ))
          )}
        </div>

        {/* SIDES — horizontal with name beside thumbnail */}
        {sides.length > 0 && (
          <div style={{ padding: "7px 14px 8px", borderTop: "1px solid #F5F0E8" }}>
            <div style={{ fontSize: 9, fontWeight: 500, textTransform: "uppercase", letterSpacing: "0.08em", color: "#B4B2A9", marginBottom: 5 }}>
              Goes with
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
              {sides.map((side, idx) => {
                let sideUrl = side?.thumb || side?.hero;
                if (!sideUrl && side?.name) {
                  sideUrl = `/assets/meals/${side.name.toLowerCase().replace(/\s+/g, "_")}.png`;
                }
                return (
                  <div key={idx} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                    <img
                      src={sideUrl || `https://placehold.co/36x28/E8D5B0/2C2C2A?text=${encodeURIComponent(side?.name?.substring(0, 3) || "Side")}`}
                      alt={side?.name || "Side"}
                      style={{ width: 36, height: 28, borderRadius: 6, objectFit: "cover", flexShrink: 0 }}
                      onError={e => {
                        e.target.onerror = null;
                        e.target.src = `https://placehold.co/36x28/E8D5B0/2C2C2A?text=${encodeURIComponent(side?.name?.substring(0, 3) || "Side")}`;
                      }}
                    />
                    <span style={{ fontSize: 11, color: "#444441", fontWeight: 500 }}>{side?.name || "Side dish"}</span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

      </div>
    </div>
  );
}
