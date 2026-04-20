// tests/login.spec.js — Login screen Playwright tests
//
// Test cases:
//   1. Login page loads — logo, heading, fields, link visible
//   2. "Create account" link switches to Register screen
//   3. Empty form submission shows error
//   4. Only email filled shows error
//   5. Only password filled shows error
//   6. Valid credentials log in and land on Dashboard
//   7. Wrong password shows error message
//   8. Non-existent email shows error message
//
// Prerequisites:
//   - Frontend running on http://localhost:5173
//   - Backend running on http://localhost:8000
//   - A valid test account must exist in the DB before running test 6.
//     Create one manually via the Register screen or pgAdmin.
//     Then update VALID_EMAIL and VALID_PASSWORD below.
//
// Cleanup: No DB cleanup needed for login tests — no data is created.

import { test, expect } from '@playwright/test';

// ── Valid test account — update these to match a real account in your DB ──────
const VALID_EMAIL = 'testadmin@momentum-test.com';
const VALID_PASSWORD = 'TestAdmin1!';

// ── Helper — navigate to login screen ─────────────────────────────────────────
async function goToLogin(page) {
  await page.goto('/');
  // Wait for the login card to be visible
  await page.waitForSelector('text=Sign in', { timeout: 10000 });
}

// ─────────────────────────────────────────────────────────────────────────────

test.describe('Login Screen', () => {

  test.beforeEach(async ({ page }) => {
    await goToLogin(page);
  });

  // ── Test 1: Page loads correctly ──────────────────────────────────────────

  test('login page loads with all expected elements', async ({ page }) => {
    // Momentum logo emoji
    await expect(page.locator('text=🌿')).toBeVisible();
    // App name
    await expect(page.locator('text=Momentum')).toBeVisible();
    // Sign in heading
    await expect(page.locator('text=Sign in')).toBeVisible();
    // Email input
    await expect(page.locator('input[type="email"]')).toBeVisible();
    // Password input
    await expect(page.locator('input[type="password"]')).toBeVisible();
    // Sign in button
    await expect(page.locator('button', { hasText: 'Sign in' })).toBeVisible();
    // Create account link
    await expect(page.locator('text=Create account')).toBeVisible();
  });

  // ── Test 2: Switch to Register ────────────────────────────────────────────

  test('clicking Create account link switches to Register screen', async ({ page }) => {
    await page.locator('text=Create account').click();
    await expect(page.locator('text=New household signup')).toBeVisible();
  });

  // ── Test 3: Empty form submission ─────────────────────────────────────────

  test('submitting empty form shows error', async ({ page }) => {
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // ── Test 4: Only email filled ─────────────────────────────────────────────

  test('submitting with only email filled shows error', async ({ page }) => {
    await page.locator('input[type="email"]').fill('someone@example.com');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // ── Test 5: Only password filled ──────────────────────────────────────────

  test('submitting with only password filled shows error', async ({ page }) => {
    await page.locator('input[type="password"]').fill('SomePass1!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // ── Test 6: Valid login lands on Dashboard ────────────────────────────────

  test('valid credentials log in and land on Dashboard', async ({ page }) => {
    await page.locator('input[type="email"]').fill(VALID_EMAIL);
    await page.locator('input[type="password"]').fill(VALID_PASSWORD);
    await page.locator('button', { hasText: 'Sign in' }).click();
    // Dashboard shows a greeting
    await expect(page.locator('text=Good')).toBeVisible({ timeout: 10000 });
    // Weekly Plan tile is present
    await expect(page.locator('text=Weekly Plan')).toBeVisible();
  });

  // ── Test 7: Wrong password shows error ────────────────────────────────────

  test('wrong password shows error message', async ({ page }) => {
    await page.locator('input[type="email"]').fill(VALID_EMAIL);
    await page.locator('input[type="password"]').fill('WrongPass999!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    // Error message visible — exact text comes from backend
    await expect(page.locator('text=Invalid email or password')).toBeVisible({ timeout: 8000 });
  });

  // ── Test 8: Non-existent email shows error ────────────────────────────────

  test('non-existent email shows error message', async ({ page }) => {
    await page.locator('input[type="email"]').fill('nobody_at_all@nowhere.com');
    await page.locator('input[type="password"]').fill('SomePass1!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Invalid email or password')).toBeVisible({ timeout: 8000 });
  });

});
