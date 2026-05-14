import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import IngredientSelector, { satvikToValue, valueToSatvik } from "./IngredientSelector";
import { C, HelpTip, NavButtons } from "./householdShared.jsx";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

// SatvikEditor — reusable component for Satvik definition.
// Used by OnboardingWizard (with onBack/onSkip) and HouseholdSettings (standalone, onDone).
// Props:
//   onBack   — called when Back is tapped (optional — omit in standalone mode)
//   onSkip   — called when Skip is tapped (optional — omit in standalone mode)
//   onDone   — called after successful save (replaces onNext in standalone mode)
//   nextLabel — label for the primary action button (default: "Save & continue")

export default function SatvikEditor({ onBack, onSkip, onDone, nextLabel = "Save & continue" }) {
  const { apiFetch } = useAuth();
  const [satvikValue, setSatvikValue] = useState({});
  const [loading, setLoading]         = useState(true);
  const [saving, setSaving]           = useState(false);
  const [error, setError]             = useState(null);
  const [help, setHelp]               = useState({});
  const [success, setSuccess]         = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const d = await apiFetch("/onboarding/data");
        setSatvikValue(satvikToValue(d.satvik));
      } catch {
        setError("Failed to load Satvik settings.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      await apiFetch("/onboarding/satvik", {
        method: "POST",
        body: JSON.stringify({ restrictions: valueToSatvik(satvikValue) }),
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
        Loading Satvik settings...
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>
      <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>Satvik definition</div>
        <HelpTip
          text="Select ingredients your household AVOIDS on Satvik days. e.g. most Tamil Brahmin households avoid onion and garlic. These rules apply on all Satvik-tagged days."
          visible={help.satvik}
          onToggle={() => setHelp(h => ({ ...h, satvik: !h.satvik }))}
        />
      </div>
      <div style={{ fontSize: 12, color: C.muted, marginBottom: 10 }}>
        Toggle ingredients your household <strong>AVOIDS</strong> on Satvik days.
      </div>

      {error && (
        <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.errorText }}>
          {error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span>
        </div>
      )}

      {success && (
        <div style={{ background: C.satvik.bg, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.satvik.text }}>
          Satvik settings saved ✓
        </div>
      )}

      <IngredientSelector
        mode="satvik"
        value={satvikValue}
        onChange={setSatvikValue}
        showImages={true}
        maxHeight="320px"
      />

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
