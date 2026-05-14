import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { C, HelpTip, NavButtons, Toggle, Chip, Field, EVENT_ICONS } from "./householdShared.jsx";

// EventEditor — reusable component for Events & Special Days.
// Used by OnboardingWizard (with onBack/onSkip) and HouseholdSettings (standalone, onDone).
// Props:
//   onBack    — called when Back is tapped (optional)
//   onSkip    — called when Skip is tapped (optional)
//   onDone    — called after successful save
//   nextLabel — label for the primary action button (default: "Save & continue")

const EMPTY_EVENT = {
  event_name: "", event_date: "", event_type: "Personal",
  is_sattvic_required: false, recurring_annual: true, icon: "🎂"
};

export default function EventEditor({ onBack, onSkip, onDone, nextLabel = "Save & continue" }) {
  const { apiFetch } = useAuth();
  const [events, setEvents]         = useState([]);
  const [newEvent, setNewEvent]     = useState(EMPTY_EVENT);
  const [addingEvent, setAddingEvent] = useState(false);
  const [loading, setLoading]       = useState(true);
  const [saving, setSaving]         = useState(false);
  const [error, setError]           = useState(null);
  const [help, setHelp]             = useState({});
  const [success, setSuccess]       = useState(false);

  const inputStyle = {
    width: "100%", padding: "9px 12px", borderRadius: 8,
    border: `0.5px solid ${C.border}`, fontSize: 13, color: C.text,
    background: "#F1EFE8", outline: "none", boxSizing: "border-box"
  };
  const cardStyle = {
    background: "#F7F4EE", border: `0.5px solid ${C.border}`,
    borderRadius: 12, padding: "12px 14px", marginBottom: 10
  };

  useEffect(() => {
    (async () => {
      try {
        const d = await apiFetch("/onboarding/data");
        setEvents((d.events || []).filter(e => e.source === "USER"));
      } catch {
        setError("Failed to load events.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      if (events.length > 0) {
        await apiFetch("/onboarding/events", {
          method: "POST",
          body: JSON.stringify({
            events: events.map(e => ({
              event_name:          e.event_name,
              event_date:          e.event_date,
              event_type:          e.event_type,
              is_sattvic_required: e.is_sattvic_required,
              recurring_annual:    e.recurring_annual,
            }))
          })
        });
      }
      setSuccess(true);
      setTimeout(() => setSuccess(false), 4000);
      if (onDone) onDone();
    } catch (e) {
      setError(e.message || "Failed to save. Please try again.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div style={{ padding: "32px 0", textAlign: "center", color: C.muted, fontSize: 13 }}>
        Loading events...
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
      <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Events & special days</div>
        <HelpTip
          text="Add birthdays, anniversaries or any special day. Feast = we suggest celebratory dishes. Satvik = Satvik rules apply. Our system learns from these every year."
          visible={help.events}
          onToggle={() => setHelp(h => ({ ...h, events: !h.events }))}
        />
      </div>
      <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>
        We'll suggest the right meals automatically on these days.
      </div>

      {error && (
        <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.errorText }}>
          {error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span>
        </div>
      )}

      {success && (
        <div style={{ background: C.satvik.bg, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.satvik.text }}>
          Events saved ✓
        </div>
      )}

      <div style={{ flex: 1, overflowY: "auto", maxHeight: 300 }}>
        {events.length === 0 && !addingEvent && (
          <div style={{ textAlign: "center", padding: "20px 0", fontSize: 13, color: C.muted }}>No events added yet</div>
        )}

        {events.map((e, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, padding: "9px 0", borderBottom: `0.5px solid ${C.border}` }}>
            <div style={{ fontSize: 18, width: 24, textAlign: "center", flexShrink: 0 }}>{e.icon || (e.is_sattvic_required ? "🙏" : "🎉")}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, color: C.text }}>{e.event_name}</div>
              <div style={{ fontSize: 11, color: C.muted }}>{e.event_date}{e.recurring_annual ? " — every year" : ""}</div>
            </div>
            <span style={{ fontSize: 10, padding: "2px 6px", borderRadius: 10, ...(e.is_sattvic_required ? C.satvik : C.feast) }}>
              {e.is_sattvic_required ? "Satvik" : "Feast"}
            </span>
            <span onClick={() => setEvents(ev => ev.filter((_, j) => j !== i))} style={{ fontSize: 13, color: "#E24B4A", cursor: "pointer" }}>✕</span>
          </div>
        ))}

        {/* Add event form */}
        {addingEvent && (
          <div style={{ ...cardStyle, marginTop: 8 }}>
            <Field label="Event name">
              <input value={newEvent.event_name} onChange={e => setNewEvent(n => ({ ...n, event_name: e.target.value }))} placeholder="e.g. Bala's Birthday" style={inputStyle} />
            </Field>
            <Field label="Date (DD-MM)" hint="Day and month only — e.g. 15-03 for 15th March">
              <input value={newEvent.event_date} onChange={e => setNewEvent(n => ({ ...n, event_date: e.target.value }))} placeholder="e.g. 15-03" style={inputStyle} />
            </Field>
            <Field label="Type">
              <div style={{ display: "flex", gap: 6 }}>
                {["Personal", "Social", "Ritual"].map(t => (
                  <Chip key={t} label={t} active={newEvent.event_type === t} onClick={() => setNewEvent(n => ({ ...n, event_type: t }))} />
                ))}
              </div>
            </Field>
            <Field label="Icon">
              <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
                {EVENT_ICONS.map(icon => (
                  <button key={icon} onClick={() => setNewEvent(n => ({ ...n, icon }))}
                    style={{ width: 34, height: 34, borderRadius: 8, fontSize: 18, border: `0.5px solid ${newEvent.icon === icon ? C.teal : C.border}`, background: newEvent.icon === icon ? "#E1F5EE" : "transparent", cursor: "pointer" }}>
                    {icon}
                  </button>
                ))}
              </div>
            </Field>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0" }}>
              <span style={{ fontSize: 13, color: C.text }}>Satvik day</span>
              <Toggle value={newEvent.is_sattvic_required} onChange={v => setNewEvent(n => ({ ...n, is_sattvic_required: v }))} />
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0" }}>
              <span style={{ fontSize: 13, color: C.text }}>Repeats annually</span>
              <Toggle value={newEvent.recurring_annual} onChange={v => setNewEvent(n => ({ ...n, recurring_annual: v }))} />
            </div>
            <div style={{ display: "flex", gap: 8, marginTop: 10 }}>
              <button onClick={() => { setAddingEvent(false); setNewEvent(EMPTY_EVENT); }}
                style={{ flex: 1, padding: 9, border: `0.5px solid ${C.border}`, borderRadius: 8, fontSize: 12, color: C.muted, background: "transparent", cursor: "pointer" }}>
                Cancel
              </button>
              <button onClick={() => {
                if (!newEvent.event_name || !newEvent.event_date) return;
                setEvents(ev => [...ev, { ...newEvent }]);
                setNewEvent(EMPTY_EVENT);
                setAddingEvent(false);
              }} style={{ flex: 2, padding: 9, border: "none", borderRadius: 8, fontSize: 12, fontWeight: 500, color: C.green, background: C.mint, cursor: "pointer" }}>
                Add event
              </button>
            </div>
          </div>
        )}
      </div>

      {!addingEvent && (
        <div onClick={() => setAddingEvent(true)}
          style={{ fontSize: 12, color: C.deepTeal, border: `0.5px dashed ${C.teal}`, borderRadius: 8, padding: 8, textAlign: "center", marginTop: 8, cursor: "pointer" }}>
          + Add an event
        </div>
      )}

      <NavButtons
        onBack={onBack}
        onSkip={onSkip}
        onNext={handleSave}
        nextLabel={saving ? "Saving..." : nextLabel}
        loading={saving}
      />
    </div>
  );
}
