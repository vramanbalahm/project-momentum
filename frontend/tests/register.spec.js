// tests/register.spec.js — Register screen Playwright tests
//
// Test cases:
//   9.  Register page loads with all expected fields
//  10.  "Sign in" link switches back to Login screen
//  11.  Submitting with all fields empty shows error
//  12.  Passwords that don't match shows error
//  13.  Password under 8 characters shows error
//  14.  Duplicate email address shows error
//  15.  Valid registration with EMAIL_VERIFY_ENABLED=false lands on Dashboard
//  16.  Veg is selected by default for dietary preference
//  17.  Clicking Non-Veg toggles selection
//  18.  Clicking Vegan toggles selection
//  19.  Home region dropdown contains expected states
//
// Prerequisites:
//   - Frontend running on http://localhost:5173
//   - Backend running on http://localhost:8000
//   - EMAIL_VERIFY_ENABLED=false in backend .env
//   - RATE_LIMIT_ENABLED=false in backend .env
//
// ── Cleanup after running these tests ────────────────────────────────────────
// Tests 14 and 15 create real users in the DB.
// After running, clean up in pgAdmin with:
//
//   DELETE FROM refresh_tokens rt
//   USING users u
//   WHERE rt.user_id = u.user_id
//     AND u.email LIKE '%@playwright-test.com';
//
//   DELETE FROM household_master hm
//   USING users u
//   WHERE hm.household_id = u.house_id
//     AND u.email LIKE '%@playwright-test.com';
//
//   DELETE FROM users WHERE email LIKE '%@playwright-test.com';
//
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from '@playwright/test';

// ── Test email domain — easy to identify and clean up ─────────────────────────
const TEST_DOMAIN = '@playwright-test.com';

// ── A known existing email for duplicate test (test 14) ───────────────────────
// This must be a real account already in your DB.
// Update this to match a real email in your system.
const EXISTING_EMAIL = 'testadmin@momentum-test.com';

// ── Helper — unique email per test run ────────────────────────────────────────
function uniqueEmail(prefix = 'reg') {
  return `${prefix}_${Date.now()}${TEST_DOMAIN}`;
}

// ── Helper — navigate to Register screen ─────────────────────────────────────
async function goToRegister(page) {
  await page.goto('/');
  await page.waitForSelector('text=Sign in', { timeout: 10000 });
  await page.locator('text=Create account').click();
  await page.waitForSelector('text=New household signup', { timeout: 10000 });
}

// ── Helper — fill the full registration form ──────────────────────────────────
async function fillRegisterForm(page, {
  name = 'Test User',
  email = uniqueEmail(),
  password = 'ValidPass1!',
  confirmPassword = 'ValidPass1!',
  houseName = 'Test Household',
} = {}) {
  const inputs = page.locator('input[type="text"]');
  const emailInput = page.locator('input[type="email"]');
  const passwordInputs = page.locator('input[type="password"]');

  await inputs.nth(0).fill(name);          // Your name
  await emailInput.fill(email);            // Email
  await passwordInputs.nth(0).fill(password);       // Password
  await passwordInputs.nth(1).fill(confirmPassword); // Confirm password
  await inputs.nth(1).fill(houseName);    // Household name
}

// ─────────────────────────────────────────────────────────────────────────────

test.describe('Register Screen', () => {

  test.beforeEach(async ({ page }) => {
    await goToRegister(page);
  });

  // ── Test 9: Page loads with all fields ────────────────────────────────────

  test('register page loads with all expected elements', async ({ page }) => {
    await expect(page.locator('text=🌿')).toBeVisible();
    await expect(page.locator('text=New household signup')).toBeVisible();
    // Required fields
    await expect(page.locator('text=Your name *')).toBeVisible();
    await expect(page.locator('text=Email *')).toBeVisible();
    await expect(page.locator('text=Password *')).toBeVisible();
    await expect(page.locator('text=Confirm password *')).toBeVisible();
    await expect(page.locator('text=Household name *')).toBeVisible();
    // Household details
    await expect(page.locator('text=Home region')).toBeVisible();
    await expect(page.locator('text=Current city')).toBeVisible();
    await expect(page.locator('text=Dietary preference')).toBeVisible();
    // Continue button
    await expect(page.locator('button', { hasText: 'Continue' })).toBeVisible();
    // Sign in link
    await expect(page.locator('text=Sign in')).toBeVisible();
  });

  // ── Test 10: Switch to Login ───────────────────────────────────────────────

  test('clicking Sign in link switches back to Login screen', async ({ page }) => {
    await page.locator('text=Already have an account?').locator('..').locator('text=Sign in').click();
    await expect(page.locator('text=Sign in').first()).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
  });

  // ── Test 11: Empty form shows error ───────────────────────────────────────

  test('submitting with all required fields empty shows error', async ({ page }) => {
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=Please fill in all required fields')).toBeVisible();
  });

  // ── Test 12: Passwords don't match ────────────────────────────────────────

  test('passwords that do not match shows error', async ({ page }) => {
    await fillRegisterForm(page, {
      password: 'ValidPass1!',
      confirmPassword: 'DifferentPass1!'
    });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=Passwords do not match')).toBeVisible();
  });

  // ── Test 13: Password too short ───────────────────────────────────────────

  test('password under 8 characters shows error', async ({ page }) => {
    await fillRegisterForm(page, {
      password: 'Ab1!',
      confirmPassword: 'Ab1!'
    });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=at least 8 characters')).toBeVisible();
  });

  // ── Test 14: Duplicate email ──────────────────────────────────────────────

  test('duplicate email address shows error', async ({ page }) => {
    await fillRegisterForm(page, { email: EXISTING_EMAIL });
    await page.locator('button', { hasText: 'Continue' }).click();
    // Backend returns 409 — frontend shows the error message
    await expect(page.locator('text=already registered')).toBeVisible({ timeout: 10000 });
  });

  // ── Test 15: Valid registration lands on Dashboard ────────────────────────
  // NOTE: This creates a real user in the DB.
  // Clean up after with the SQL in the file header comments.

  test('valid registration with email verify disabled lands on Dashboard', async ({ page }) => {
    const email = uniqueEmail('newuser');
    await fillRegisterForm(page, { email, name: 'Playwright User', houseName: 'PW Test House' });
    await page.locator('button', { hasText: 'Continue' }).click();
    // Should land on Dashboard — greeting visible
    await expect(page.locator('text=Good')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Weekly Plan')).toBeVisible();
  });

  // ── Test 16: Veg is default dietary preference ────────────────────────────

  test('Veg is selected by default for dietary preference', async ({ page }) => {
    // The Veg button should have the active dark background colour
    const vegButton = page.locator('button', { hasText: 'Veg' });
    await expect(vegButton).toBeVisible();
    // Active button has dark green background — check background style
    const bg = await vegButton.evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)'); // #1A3A2E
  });

  // ── Test 17: Clicking Non-Veg toggles selection ───────────────────────────

  test('clicking Non-Veg toggles dietary preference selection', async ({ page }) => {
    const nonVegButton = page.locator('button', { hasText: 'Non-Veg' });
    await nonVegButton.click();
    const bg = await nonVegButton.evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)'); // #1A3A2E — active
  });

  // ── Test 18: Clicking Vegan toggles selection ─────────────────────────────

  test('clicking Vegan toggles dietary preference selection', async ({ page }) => {
    const veganButton = page.locator('button', { hasText: 'Vegan' });
    await veganButton.click();
    const bg = await veganButton.evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)'); // #1A3A2E — active
  });

  // ── Test 19: Home region dropdown contains expected states ────────────────

  test('home region dropdown contains expected states', async ({ page }) => {
    const select = page.locator('select');
    await expect(select).toBeVisible();
    const options = await select.locator('option').allTextContents();
    const expected = ['Tamil Nadu', 'Kerala', 'Karnataka', 'Andhra Pradesh', 'Telangana', 'Maharashtra'];
    for (const state of expected) {
      expect(options).toContain(state);
    }
  });

});
