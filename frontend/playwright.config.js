// playwright.config.js — Momentum frontend test configuration
import { defineConfig } from '@playwright/test';
import { config } from 'dotenv';

// Load test credentials from .env.test — never committed to repo
config({ path: '.env.test' });

export default defineConfig({
  testDir: './tests',
  timeout: 60000,          // 60s per test — first-time plan generation can be slow
  retries: 0,              // no retries — we want to see real failures
  workers: 1,              // run tests sequentially — avoids race conditions on shared UI state

  use: {
    baseURL: 'http://localhost:5173',
    headless: true,        // set to false if you want to watch the browser during debugging
    viewport: { width: 390, height: 844 },  // iPhone 14 — Momentum is mobile-first
    screenshot: 'only-on-failure',          // saves screenshot when a test fails
    video: 'off',
  },

  reporter: [['list']],   // clean line-by-line output in terminal
});
