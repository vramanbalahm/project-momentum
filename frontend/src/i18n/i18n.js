// src/i18n/i18n.js
// Initialises react-i18next with English and Tamil translations.
// Both JSONs are bundled at build time — zero network calls, instant language switch.

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from './en.json';
import ta from './ta.json';

const savedLanguage = localStorage.getItem('momentum_language') || 'en';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      ta: { translation: ta },
    },
    lng: savedLanguage,
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false, // React already escapes values
    },
  });

export default i18n;
