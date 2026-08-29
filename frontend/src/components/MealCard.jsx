import React from "react";
import { useDraggable, useDroppable } from "@dnd-kit/core";

// FT-041: MealCard supports multiple main dishes (split hero) + horizontal sides with names
import { getDishImage } from '../utils/imageUtils';
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
    return getDishImage(dish) || null;
  };

  const hasIssues = auditResult?.issues?.length > 0;
  const [showAuditPanel, setShowAuditPanel] = React.useState(false);

  return (
    <>
    <div
      ref={setDroppableRef}
      data-testid={`meal-card-${slotId}`}
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

          {/* Audit indicator */}
          {auditResult && (
            hasIssues ? (
              <div
                onClick={e => { e.stopPropagation(); setShowAuditPanel(v => !v); }}
                style={{
                  position: "absolute", top: 8, right: 8, zIndex: 10,
                  display: "flex", alignItems: "center", gap: 4,
                  background: "rgba(255,255,255,0.92)", borderRadius: 20,
                  padding: "3px 8px", cursor: "pointer"
                }}>
                <div style={{ width: 7, height: 7, borderRadius: "50%", background: "#EF9F27", flexShrink: 0 }} />
                <span style={{ fontSize: 9, color: "#444441", fontWeight: 500 }}>
                  {auditResult.issues.length} {auditResult.issues.length === 1 ? "issue" : "issues"}
                </span>
              </div>
            ) : (
              <div style={{
                position: "absolute", top: 8, right: 8, zIndex: 10,
                background: "rgba(255,255,255,0.92)", borderRadius: 20, padding: "3px 8px"
              }}>
                <span style={{ fontSize: 9, color: "#888780" }}>ok</span>
              </div>
            )
          )}

          {mains.length === 0 ? (
            <div style={{ flex: 1, background: meal?.pantry_exhausted ? "#F0FAF6" : "#EDE8E0",
              display: "flex", alignItems: "center", justifyContent: "center",
              flexDirection: "column", gap: 2, padding: "8px 0" }}>
              {meal?.pantry_exhausted ? (
                <>
                  <span style={{ fontSize: 18 }}>🧊</span>
                  <span style={{ fontSize: 11, color: "#0F6E56", fontWeight: 500 }}>Pantry exhausted</span>
                  <span style={{ fontSize: 10, color: "#888780" }}>No matching dishes in pantry</span>
                </>
              ) : (
                <span style={{ fontSize: 11, color: "#B4B2A9" }}>No meal set</span>
              )}
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
                let sideUrl = getDishImage(side);
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

    {/* Audit issues panel */}
    {showAuditPanel && hasIssues && (
      <div style={{
        margin: "0 0 8px", background: "#FDFCF8",
        borderRadius: "0 0 16px 16px",
        border: "0.5px solid #EDE8E0", borderTop: "none",
        overflow: "hidden"
      }}>
        <div style={{ padding: "10px 14px", display: "flex", flexDirection: "column", gap: 8 }}>
          {auditResult.issues.map((issue, i) => (
            <div key={i} style={{
              display: "flex", gap: 10, alignItems: "flex-start",
              padding: "8px 10px", background: "#FFF9E6",
              borderRadius: 8, borderLeft: "3px solid #EF9F27"
            }}>
              <span style={{ fontSize: 14, flexShrink: 0 }}>⚠️</span>
              <div style={{ fontSize: 12, color: "#2C2C2A", lineHeight: 1.5 }}>{issue}</div>
            </div>
          ))}
        </div>
      </div>
    )}
    </>
  );
}
