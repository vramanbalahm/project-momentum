import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useTranslation } from "react-i18next";
import { C, HelpTip, NavButtons } from "./householdShared.jsx";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

const PANCHANG_ICONS = ["🌙","🌑","⭐","🌿","🌊","🎋","☀️","🌸","🕉️","🌺"];

export default function LunarEditor({ onBack, onSkip, onDone, nextLabel }) {
  const { apiFetch } = useAuth();
  const { t } = useTranslation();

  const [panchangamTypes, setPanchangamTypes] = useState([]);
  const [panchangamId, setPanchangamId]       = useState(null);
  const [prevPanchangamId, setPrevPanchangamId] = useState(null); // to detect change
  const [observations, setObservations]       = useState([]); // { event_name, local_name, icon, is_active }
  const [loading, setLoading]                 = useState(true);
  const [saving, setSaving]                   = useState(false);
  const [error, setError]                     = useState(null);
  const [help, setHelp]                       = useState({});
  const [success, setSuccess]                 = useState(false);
  const [showWarning, setShowWarning]         = useState(false);
  const [pendingPanchangamId, setPendingPanchangamId] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        const d = await apiFetch("/onboarding/data");
        setPanchangamTypes(d.panchangam_types || []);
        if (d.panchangam_selected) {
          setPanchangamId(d.panchangam_selected.id);
          setPrevPanchangamId(d.panchangam_selected.id);
        }
        // Load existing household observations
        try {
          const obs = await apiFetch("/onboarding/lunar-observations");
          setObservations(obs.observations || []);
        } catch {
          // No observations yet — will be populated after panchangam save
          setObservations([]);
        }
      } catch {
        setError(t("common.error"));
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // Handle panchangam selection — warn if changing existing selection
  const handlePanchangamSelect = (id) => {
    if (prevPanchangamId && prevPanchangamId !== id && observations.length > 0) {
      // Warn user that customisations will be lost
      setPendingPanchangamId(id);
      setShowWarning(true);
    } else {
      setPanchangamId(id === panchangamId ? null : id);
    }
  };

  // Confirm panchangam change — clear observations, set new panchangam
  const handleConfirmChange = () => {
    setPanchangamId(pendingPanchangamId);
    setObservations([]); // will be refreshed after save
    setPendingPanchangamId(null);
    setShowWarning(false);
  };

  // Toggle individual observation active/inactive
  const toggleObservation = (eventName) => {
    setObservations(obs =>
      obs.map(o => o.event_name === eventName ? { ...o, is_active: !o.is_active } : o)
    );
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      // Step 1 — Save panchangam type (this also copies ADMIN events if needed)
      await apiFetch("/onboarding/panchangam", {
        method: "POST",
        body: JSON.stringify({ panchangam_type_id: panchangamId }),
      });

      // Step 2 — If we have observations, refresh them (in case just populated)
      if (observations.length === 0 && panchangamId) {
        const obs = await apiFetch("/onboarding/lunar-observations");
        setObservations(obs.observations || []);
        // Save default active state
        if (obs.observations?.length > 0) {
          await apiFetch("/onboarding/lunar-observations", {
            method: "PUT",
            body: JSON.stringify({
              observations: obs.observations.map(o => ({
                event_name: o.event_name,
                is_active: o.is_active
              }))
            })
          });
        }
      } else if (observations.length > 0) {
        // Step 3 — Save observation toggles
        await apiFetch("/onboarding/lunar-observations", {
          method: "PUT",
          body: JSON.stringify({
            observations: observations.map(o => ({
              event_name: o.event_name,
              is_active: o.is_active
            }))
          })
        });
      }

      setPrevPanchangamId(panchangamId);
      setSuccess(true);
      setTimeout(() => setSuccess(false), 4000);
      if (onDone) onDone();
    } catch (e) {
      setError(e.message || t("common.error"));
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div style={{ padding: "32px 0", textAlign: "center", color: C.muted, fontSize: 13 }}>
        {t("common.loading")}
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", minHeight: 480 }}>

      {/* Warning modal — changing panchangam */}
      {showWarning && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 200, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 24px" }}>
          <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "24px 20px", width: "100%", maxWidth: 360 }}>
            <div style={{ fontSize: 16, fontWeight: 600, color: "#2C2C2A", marginBottom: 8 }}>{t("lunarEditor.changeWarningTitle")}</div>
            <div style={{ fontSize: 13, color: "#888780", marginBottom: 24 }}>{t("lunarEditor.changeWarningDesc")}</div>
            <div style={{ display: "flex", gap: 10 }}>
              <button onClick={() => { setPendingPanchangamId(null); setShowWarning(false); }}
                style={{ flex: 1, padding: "10px", borderRadius: 10, border: "0.5px solid #EDE8E0", background: "transparent", fontSize: 13, color: "#888780", cursor: "pointer" }}>
                {t("lunarEditor.changeWarningCancel")}
              </button>
              <button onClick={handleConfirmChange}
                style={{ flex: 1, padding: "10px", borderRadius: 10, border: "none", background: "#1A3A2E", color: "#9FE1CB", fontSize: 13, fontWeight: 500, cursor: "pointer" }}>
                {t("lunarEditor.changeWarningConfirm")}
              </button>
            </div>
          </div>
        </div>
      )}

      <div style={{ display: "flex", alignItems: "center", marginBottom: 4 }}>
        <div style={{ fontSize: 17, fontWeight: 500, color: C.text }}>{t("lunarEditor.title")}</div>
        <HelpTip
          text="Select which Panchangam your household follows. We'll use this to suggest Satvik meals on the correct days automatically."
          visible={help.lunar}
          onToggle={() => setHelp(h => ({ ...h, lunar: !h.lunar }))}
        />
      </div>
      <div style={{ fontSize: 12, color: C.muted, marginBottom: 14 }}>
        {t("lunarEditor.subtitle")}
      </div>

      {error && (
        <div style={{ background: C.error, border: `0.5px solid #F5C4B3`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.errorText }}>
          {error} <span onClick={() => setError(null)} style={{ cursor: "pointer", float: "right" }}>✕</span>
        </div>
      )}

      {success && (
        <div style={{ background: C.satvik.bg, border: `0.5px solid ${C.teal}`, borderRadius: 8, padding: "8px 12px", marginBottom: 12, fontSize: 12, color: C.satvik.text }}>
          {t("lunarEditor.saved")}
        </div>
      )}

      <div style={{ flex: 1, overflowY: "auto", maxHeight: 360 }}>

        {/* Panchangam type selection */}
        {panchangamTypes.map((pt, idx) => (
          <div key={pt.id}
            onClick={() => handlePanchangamSelect(pt.id)}
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
          onClick={() => handlePanchangamSelect(null)}
          style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px", marginBottom: 16, background: panchangamId === null ? "#E1F5EE" : "#F7F4EE", border: `0.5px solid ${panchangamId === null ? C.teal : C.border}`, borderRadius: 12, cursor: "pointer" }}
        >
          <div style={{ fontSize: 22, width: 32, textAlign: "center" }}>🚫</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 500, color: panchangamId === null ? C.deepTeal : C.text }}>{t("lunarEditor.noFollow")}</div>
            <div style={{ fontSize: 11, color: C.muted }}>{t("lunarEditor.noFollowDesc")}</div>
          </div>
          {panchangamId === null && (
            <div style={{ width: 18, height: 18, borderRadius: "50%", background: C.teal, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 10, color: "white" }}>✓</div>
          )}
        </div>

        {/* Observation toggles — shown only when panchangam is selected and observations exist */}
        {panchangamId && observations.length > 0 && (
          <div style={{ marginTop: 4 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: C.muted, textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 6 }}>
              {t("lunarEditor.observations")}
            </div>
            <div style={{ fontSize: 11, color: C.muted, marginBottom: 12 }}>
              {t("lunarEditor.observationsHint")}
            </div>
            {observations.map(obs => (
              <div key={obs.event_name}
                style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 14px", marginBottom: 6, background: "#F7F4EE", border: `0.5px solid ${C.border}`, borderRadius: 10 }}
              >
                <div style={{ fontSize: 18, width: 28, textAlign: "center" }}>{obs.icon || "🌙"}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{obs.event_name}</div>
                  {obs.local_name && <div style={{ fontSize: 11, color: C.muted }}>{obs.local_name}</div>}
                </div>
                {/* Toggle */}
                <div
                  onClick={() => toggleObservation(obs.event_name)}
                  style={{ width: 40, height: 22, borderRadius: 11, background: obs.is_active ? C.teal : "#D1CFC8", cursor: "pointer", position: "relative", transition: "background 0.2s", flexShrink: 0 }}
                >
                  <div style={{ position: "absolute", top: 3, left: obs.is_active ? 20 : 3, width: 16, height: 16, borderRadius: "50%", background: "white", transition: "left 0.2s" }} />
                </div>
              </div>
            ))}
          </div>
        )}

      </div>

      <NavButtons
        onBack={onBack}
        onSkip={onSkip}
        onNext={handleSave}
        nextLabel={saving ? t("common.saving") : nextLabel}
        loading={saving}
      />
    </div>
  );
}
