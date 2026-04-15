import React from 'react';
import { useDraggable, useDroppable } from '@dnd-kit/core';

// FT-033: MealCard updated to show main dish + side dishes
// Matches wireframe v3 — hero image, sides chips, audit pill
export default function MealCard({ day, type, meal, auditResult, onClick, isEditable = true }) {
  const slotId = `${day}-${type}`;

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

  // FT-033: main dish and sides come from grouped plan structure
  const mainDish = meal?.main || meal;
  const sides = meal?.sides || [];

  // AUTO-RECOVERY LOGIC for main dish image
  let rawUrl = mainDish?.thumb || mainDish?.hero || mainDish?.carousel_thumb_url || mainDish?.hero_image_url;
  if (!rawUrl && mainDish?.name) {
    const formattedName = mainDish.name.toLowerCase().replace(/\s+/g, '_');
    rawUrl = `/assets/meals/${formattedName}.png`;
  }
  const imageUrl = decodeURIComponent(rawUrl || "/assets/meals/placeholder.png");

  // Audit status color
  const auditColor = auditResult?.status === "Success" ? "#1D9E75"
    : auditResult?.status === "Warning" ? "#EF9F27"
    : auditResult?.status === "Conflict" ? "#E24B4A"
    : "#B4B2A9";

  return (
    <div
      ref={setDroppableRef}
      style={{
        background: "#fff",
        borderRadius: 20,
        border: "1px solid #EDE8E0",
        overflow: "hidden",
        marginBottom: 12
      }}
    >
      <div
        ref={setDraggableRef}
        style={style}
        {...listeners}
        {...attributes}
      >
        {/* Main dish hero image */}
        <div
          style={{ height: 110, position: "relative", overflow: "hidden", cursor: "pointer" }}
          onClick={() => mainDish && onClick({ day, type, meal })}
        >
          <img
            src={imageUrl}
            alt={mainDish?.name || "Meal"}
            style={{ width: "100%", height: "100%", objectFit: "cover" }}
            onError={(e) => {
              e.target.onerror = null;
              e.target.src = `https://placehold.co/400x160/C8B89A/2C2C2A?text=${encodeURIComponent(mainDish?.name || 'Meal')}`;
            }}
          />

          {/* Audit status pill — top right */}
          {auditResult && (
            <div style={{
              position: "absolute",
              top: 8,
              right: 8,
              display: "flex",
              alignItems: "center",
              gap: 4,
              background: "rgba(255,255,255,0.92)",
              borderRadius: 20,
              padding: "3px 8px"
            }}>
              <div style={{
                width: 6,
                height: 6,
                borderRadius: "50%",
                background: auditColor,
                flexShrink: 0
              }} />
              <span style={{ fontSize: 9, color: "#444441", fontWeight: 500 }}>
                {auditResult.status === "Success" ? "Ready"
                  : auditResult.status === "Warning" ? "Check"
                  : auditResult.status === "Conflict" ? "Conflict"
                  : "Pending"}
              </span>
            </div>
          )}

          {/* Satvik badge — top left */}
          {mainDish?.is_sattvic && (
            <div style={{
              position: "absolute",
              top: 8,
              left: 8,
              background: "rgba(93,202,165,0.25)",
              color: "#085041",
              fontSize: 9,
              padding: "2px 7px",
              borderRadius: 20,
              fontWeight: 500
            }}>
              Satvik
            </div>
          )}

          {/* Dish name overlay */}
          <div style={{
            position: "absolute",
            bottom: 0,
            left: 0,
            right: 0,
            padding: "24px 12px 8px",
            background: "linear-gradient(to top, rgba(26,58,46,0.85), transparent)"
          }}>
            <div style={{ color: "#fff", fontSize: 14, fontWeight: 500, lineHeight: 1.2 }}>
              {mainDish?.name || "Skipped"}
            </div>
          </div>
        </div>

        {/* Side dishes — FT-033 */}
        {sides.length > 0 && (
          <div style={{
            padding: "8px 14px",
            borderTop: "1px solid #F5F0E8"
          }}>
            <div style={{
              fontSize: 9,
              fontWeight: 500,
              textTransform: "uppercase",
              letterSpacing: "0.08em",
              color: "#B4B2A9",
              marginBottom: 6
            }}>
              Goes with
            </div>
            <div style={{
              display: "flex",
              gap: 6,
              overflowX: "auto",
              paddingBottom: 2
            }}>
              {sides.map((side, idx) => {
                let sideUrl = side?.thumb || side?.hero;
                if (!sideUrl && side?.name) {
                  sideUrl = `/assets/meals/${side.name.toLowerCase().replace(/\s+/g, '_')}.png`;
                }
                return (
                  <div key={idx} style={{
                    flexShrink: 0,
                    background: "#FFF9F2",
                    borderRadius: 10,
                    border: "1px solid #EDE8E0",
                    overflow: "hidden",
                    width: 60
                  }}>
                    <img
                      src={sideUrl || `https://placehold.co/60x44/E8D5B0/2C2C2A?text=${encodeURIComponent(side?.name?.substring(0, 3) || 'Side')}`}
                      alt={side?.name || "Side dish"}
                      style={{ width: 60, height: 44, objectFit: "cover", display: "block" }}
                      onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = `https://placehold.co/60x44/E8D5B0/2C2C2A?text=${encodeURIComponent(side?.name?.substring(0, 3) || 'Side')}`;
                      }}
                    />
                    <div style={{
                      fontSize: 9,
                      color: "#444441",
                      textAlign: "center",
                      padding: "3px 3px 4px",
                      lineHeight: 1.2
                    }}>
                      {side?.name || "Side"}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Action buttons — hidden for past/future week views */}
        {isEditable && (
          <div style={{
            display: "flex",
            gap: 8,
            padding: "8px 14px 12px",
            borderTop: "1px solid #F5F0E8"
          }}>
            <button
              onClick={() => mainDish && onClick({ day, type, meal })}
              style={{
                flex: 1,
                background: "#1A3A2E",
                color: "#FDFCF8",
                border: "none",
                borderRadius: 12,
                padding: "9px 0",
                fontSize: 12,
                fontWeight: 500,
                cursor: "pointer"
              }}
            >
              Edit dishes
            </button>
            <button
              style={{
                flex: 1,
                background: "#FFF9F2",
                color: "#444441",
                border: "1px solid #EDE8E0",
                borderRadius: 12,
                padding: "9px 0",
                fontSize: 12,
                cursor: "pointer"
              }}
            >
              Swap
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
