import React from 'react';
import { useTranslation } from 'react-i18next';

export default function SwapCopyBar({ mode, selectedKey, onSwap, onCopy, onCancel }) {
  const { t } = useTranslation();

  if (!mode) {
    return (
      <div style={{ display: "flex", gap: 6, padding: "5px 0 6px", borderBottom: "0.5px solid #EDE8E0" }}>
        <button onClick={onSwap} style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 5, background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 8, padding: "6px 0", fontSize: 11, fontWeight: 500, cursor: "pointer" }}>
          <span style={{ fontSize: 12 }}>⇄</span> {t("swapCopy.swap")}
        </button>
        <button onClick={onCopy} style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", gap: 5, background: "transparent", color: "#1A3A2E", border: "1px solid #1A3A2E", borderRadius: 8, padding: "6px 0", fontSize: 11, fontWeight: 500, cursor: "pointer" }}>
          <span style={{ fontSize: 12 }}>⧉</span> {t("swapCopy.copy")}
        </button>
      </div>
    );
  }

  const isSwap = mode === 'swap';
  const barBg     = isSwap ? "#E1F5EE" : "#FAEEDA";
  const barBorder = isSwap ? "#5DCAA5" : "#EF9F27";
  const btnBg     = isSwap ? "#0F6E56" : "#BA7517";
  const btnColor  = isSwap ? "#9FE1CB" : "#FAEEDA";
  const label = isSwap
    ? (selectedKey ? t("swapCopy.swapTap2") : t("swapCopy.swapTap1"))
    : (selectedKey ? t("swapCopy.copyTapDst") : t("swapCopy.copyTapSrc"));

  return (
    <div style={{ display: "flex", alignItems: "center", gap: 6, padding: "5px 0 6px", background: barBg, borderBottom: `0.5px solid ${barBorder}`, borderRadius: 4 }}>
      <div style={{ flex: 1, textAlign: "center", background: btnBg, color: btnColor, fontSize: 10, fontWeight: 500, borderRadius: 8, padding: "6px 0" }}>
        {label}
      </div>
      <button onClick={onCancel} style={{ background: "none", border: "none", color: "#993C1D", fontSize: 13, fontWeight: 500, cursor: "pointer", padding: "0 8px", lineHeight: 1 }}>✕</button>
    </div>
  );
}
