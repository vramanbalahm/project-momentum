import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { C, HelpTip, NavButtons } from "./householdShared.jsx";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const PANCHANG_ICONS = ["🌙","🌑","⭐","🌿","🌊","🎋","☀️","🌸","🕉️","🌺"];

// LunarEditor — reusable component for Panchangam / lunar calendar selection.
// Used by OnboardingWizard (with onBack/onSkip) and HouseholdSettings (standalone, onDone).
// Props:
//   onBack    — called when Back is tapped (optional)
//   onSkip    — called when Skip is tapped (optional)
//   onDone    — called after successful save
//   nextLabel — label for the primary action button (default: "Save & continue")

export default function LunarEditor({ onBack, onSkip, onDone, nextLabel = "Save & continue" }) {
  const { apiFetch } = useAuth();
  const [panchangamTypes, setPanchangamTypes] = useState([]);
  const [panchangamId, setPanchangamId]       = useState(null);
  const [loading, setLoading]                 = useState(true);
  const [saving, setSaving]                   = useState(false);
  const [error, setError]                     = useState(null);
  const [help, setHelp]                       = useState({});
  const [success, setSuccess]                 = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const d = await apiFetch("/onboarding/data");
        setPanchangamTypes(d.panchangam_types || []);
        if (d.panchangam_selected) setPanchangamId(d.panchangam_selected.id);
      } catch {
        setError("Failed to load lunar calendar settings.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      await apiFetch("/onboarding/panchangam", {
        method: "POST",
        body: JSON.stringify({ panchangam_type_id: panchangamId }),
      });
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
        Loading lunar calendar settings...
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
      <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Lunar calendar</div>
        <HelpTip
          text="Select which Panchangam your household follows. We'll use this to suggest Satvik meals on the correct days automatically."
          visible={help.lunar}
          onToggle={() => setHelp(h => ({ ...h, lunar: !h.lunar }))}
        />
      </div>
      <div style={{ fontSize: 12, color: C.muted, marginBottom: 14 }}>
        Which Panchangam does your household follow?
      </div>

      {error && (
        <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.errorText }}>
          {error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span>
        </div>
      )}

      {success && (
        <div style={{ background: C.satvik.bg, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.satvik.text }}>
          Lunar calendar saved ✓
        </div>
      )}

      <div style={{ flex: 1, overflowY: "auto", maxHeight: 360 }}>
        {panchangamTypes.map((pt, idx) => (
          <div key={pt.id}
            onClick={() => setPanchangamId(pt.id === panchangamId ? null : pt.id)}
            style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px", marginBottom: 8, background: panchangamId === pt.id ? "#E1F5EE" : "#F7F4EE", border: `0.5px solid ${panchangamId === pt.id ? C.teal : C.border}`, borderRadius: 12, cursor: "pointer", transition: "all 0.15s" }}
          >
            <div style={{ fontSize: 22, width: 32, textAlign: "center", flexShrink: 0 }}>
              {PANCHANG_ICONS[idx % PANCHANG_ICONS.length]}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: panchangamId === pt.id ? C.deepTeal : C.text }}>{pt.display_name}</div>
              <div style={{ fontSize: 11, color: C.muted }}>{pt.language} · {pt.region}</div>
            </div>
            {panchangamId === pt.id && (
              <div style={{ width: 18, height: 18, borderRadius: "50%", background: C.teal, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white" }}>✓</div>
            )}
          </div>
        ))}

        {/* None option */}
        <div
          onClick={() => setPanchangamId(null)}
          style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px", background: panchangamId === null ? "#E1F5EE" : "#F7F4EE", border: `0.5px solid ${panchangamId === null ? C.teal : C.border}`, borderRadius: 12, cursor: "pointer" }}
        >
          <div style={{ fontSize: 22, width: 32, textAlign: "center" }}>🚫</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 500, color: panchangamId === null ? C.deepTeal : C.text }}>We don't follow a Panchangam</div>
            <div style={{ fontSize: 11, color: C.muted }}>Skip lunar calendar — plan freely</div>
          </div>
          {panchangamId === null && (
            <div style={{ width: 18, height: 18, borderRadius: "50%", background: C.teal, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white" }}>✓</div>
          )}
        </div>
      </div>

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
