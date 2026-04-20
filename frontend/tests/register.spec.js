// tests/register.spec.js — Register screen Playwright tests
//
// Test cases:
//  9.  Page loads with all sections visible
// 10.  Clicking Sign in switches back to Login
// 11.  Empty required fields shows error
// 12.  Passwords don't match shows error
// 13.  Password too short shows error
// 14.  Password no uppercase shows error
// 15.  Password no number shows error
// 16.  Password no special character shows error
// 17.  Duplicate email shows error
// 18.  Valid registration lands on Dashboard
// 19.  Veg is selected by default
// 20.  Clicking Non-Veg toggles selection
// 21.  Clicking Vegan toggles selection
// 22.  Clicking Eggitarian toggles selection
// 23.  Selecting cuisine state loads regions
// 24.  Selecting cuisine region loads sub-regions
// 25.  Selecting city state loads cities
//
// Prerequisites:
//  - Frontend running: npm run dev (http://localhost:5173)
//  - Backend running: uvicorn main:app --reload (http://localhost:8000)
//  - EMAIL_VERIFY_ENABLED=false and RATE_LIMIT_ENABLED=false in backend .env
//  - EXISTING_EMAIL below must be a real account already in your DB
//
// ── Cleanup after running test 17 and 18 ─────────────────────────────────────
// Run this in pgAdmin after the test suite to remove test registrations:
//
//   DO $$ DECLARE v_house_id UUID;
//   BEGIN
//     SELECT house_id INTO v_house_id FROM users WHERE email LIKE '%@playwright-test.com';
//     DELETE FROM refresh_tokens    WHERE house_id = v_house_id;
//     DELETE FROM profile_audit_log WHERE house_id = v_house_id;
//     DELETE FROM users             WHERE house_id = v_house_id;
//     DELETE FROM household_master  WHERE household_id = v_house_id;
//   END $$;
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from '@playwright/test';

// Set in frontend/.env.test — same account used for login tests
const EXISTING_EMAIL = process.env.TEST_EMAIL || 'testadmin@momentum-test.com';
const TEST_DOMAIN    = '@playwright-test.com';

function uniqueEmail() {
  return `reg_${Date.now()}${TEST_DOMAIN}`;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

async function goToRegister(page) {
  await page.goto('/');
  await page.waitForSelector('text=Sign in', { timeout: 10000 });
  await page.locator('text=Create account').click();
  await page.waitForSelector('text=New household signup', { timeout: 10000 });
}

async function fillForm(page, {
  name            = 'Test User',
  email           = uniqueEmail(),
  password        = 'ValidPass1!',
  confirmPassword = 'ValidPass1!',
  houseName       = 'Test Household',
} = {}) {
  // name — first text input
  await page.locator('input[type="text"]').nth(0).fill(name);
  // email
  await page.locator('input[type="email"]').fill(email);
  // password
  await page.locator('input[type="password"]').nth(0).fill(password);
  // confirm password
  await page.locator('input[type="password"]').nth(1).fill(confirmPassword);
  // household name — second text input
  await page.locator('input[type="text"]').nth(1).fill(houseName);
}

// ─────────────────────────────────────────────────────────────────────────────

test.describe('Register Screen', () => {

  test.beforeEach(async ({ page }) => {
    await goToRegister(page);
  });

  // Test 9
  test('page loads with all sections visible', async ({ page }) => {
    await expect(page.locator('text=🌿')).toBeVisible();
    await expect(page.locator('text=New household signup')).toBeVisible();
    // Personal detail fields
    await expect(page.locator('text=Your name *')).toBeVisible();
    await expect(page.locator('text=Email *')).toBeVisible();
    await expect(page.locator('text=Password *').first()).toBeVisible();
    await expect(page.locator('text=Confirm password *')).toBeVisible();
    // Household details
    await expect(page.locator('text=Household name *')).toBeVisible();
    await expect(page.locator('text=Dietary preference')).toBeVisible();
    await expect(page.locator('text=Household allergies')).toBeVisible();
    // Cuisine region section
    await expect(page.locator('text=Home cuisine region')).toBeVisible();
    // Current location section
    await expect(page.locator('text=Current location')).toBeVisible();
    // Continue button
    await expect(page.locator('button', { hasText: 'Continue' })).toBeVisible();
    // Sign in link
    await expect(page.locator('text=Already have an account?')).toBeVisible();
  });

  // Test 10
  test('clicking Sign in link switches back to Login screen', async ({ page }) => {
    await page.locator('text=Sign in').last().click();
    await expect(page.locator('text=Your weekly meal planner')).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
  });

  // Test 11
  test('submitting with empty required fields shows error', async ({ page }) => {
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=Please fill in all required fields')).toBeVisible();
  });

  // Test 12
  test('passwords that do not match shows error', async ({ page }) => {
    await fillForm(page, { password: 'ValidPass1!', confirmPassword: 'DifferentPass1!' });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=Passwords do not match')).toBeVisible();
  });

  // Test 13
  test('password under 8 characters shows error', async ({ page }) => {
    await fillForm(page, { password: 'Ab1!', confirmPassword: 'Ab1!' });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=at least 8 characters')).toBeVisible();
  });

  // Test 14
  test('password with no uppercase letter shows error', async ({ page }) => {
    await fillForm(page, { password: 'validpass1!', confirmPassword: 'validpass1!' });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=uppercase')).toBeVisible();
  });

  // Test 15
  test('password with no number shows error', async ({ page }) => {
    await fillForm(page, { password: 'ValidPass!', confirmPassword: 'ValidPass!' });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=number')).toBeVisible();
  });

  // Test 16
  test('password with no special character shows error', async ({ page }) => {
    await fillForm(page, { password: 'ValidPass1', confirmPassword: 'ValidPass1' });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=special character')).toBeVisible();
  });

  // Test 17
  test('duplicate email shows already registered error', async ({ page }) => {
    await fillForm(page, { email: EXISTING_EMAIL });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=already registered').first()).toBeVisible({ timeout: 10000 });
  });

  // Test 18 — creates a real user, clean up with SQL in header comment
  test('valid registration lands on Dashboard', async ({ page }) => {
    await fillForm(page, {
      email:    uniqueEmail(),
      name:     'Playwright User',
      houseName: 'PW Test House'
    });
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=MOMENTUM')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Weekly Plan')).toBeVisible();
    await expect(page.locator('text=⚙️')).toBeVisible();
  });

  // Test 19
  test('Veg is selected by default', async ({ page }) => {
    const vegBtn = page.getByRole('button', { name: 'Veg', exact: true });
    await expect(vegBtn).toBeVisible();
    const bg = await vegBtn.evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)'); // #1A3A2E — active state
  });

  // Test 20
  test('clicking Non-Veg toggles selection', async ({ page }) => {
    await page.getByRole('button', { name: 'Non-Veg', exact: true }).click();
    const bg = await page.getByRole('button', { name: 'Non-Veg', exact: true }).evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)');
    // Veg should now be inactive
    const vegBg = await page.getByRole('button', { name: 'Veg', exact: true }).evaluate(el => el.style.background);
    expect(vegBg).not.toBe('rgb(26, 58, 46)');
  });

  // Test 21
  test('clicking Vegan toggles selection', async ({ page }) => {
    await page.getByRole('button', { name: 'Vegan', exact: true }).click();
    const bg = await page.getByRole('button', { name: 'Vegan', exact: true }).evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)');
  });

  // Test 22
  test('clicking Eggitarian toggles selection', async ({ page }) => {
    await page.getByRole('button', { name: 'Eggitarian', exact: true }).click();
    const bg = await page.getByRole('button', { name: 'Eggitarian', exact: true }).evaluate(el => el.style.background);
    expect(bg).toBe('rgb(26, 58, 46)');
  });

  // Test 23
  test('selecting cuisine state loads regions dropdown', async ({ page }) => {
    const selects = page.locator('select');
    // First select is cuisine state
    await selects.nth(0).selectOption('Tamil Nadu');
    // Region select should appear
    await expect(page.getByText('Region', { exact: true })).toBeVisible({ timeout: 5000 });
    const regionSelect = selects.nth(1);
    await expect(regionSelect).toBeVisible();
    const options = await regionSelect.locator('option').allTextContents();
    expect(options.some(o => o.includes('Tamil Nadu'))).toBeTruthy();
  });

  // Test 24
  test('selecting cuisine region loads sub-regions dropdown', async ({ page }) => {
    const selects = page.locator('select');
    await selects.nth(0).selectOption('Tamil Nadu');
    await page.waitForTimeout(500);
    await selects.nth(1).selectOption('Central Tamil Nadu');
    await expect(page.getByText('Sub-region / Cuisine style', { exact: true })).toBeVisible({ timeout: 5000 });
    const subOptions = await selects.nth(2).locator('option').allTextContents();
    expect(subOptions.some(o => o.includes('Chettinad'))).toBeTruthy();
  });

  // Test 25
  test('selecting city state loads cities dropdown', async ({ page }) => {
    // City state is the last select on the page — scroll down first
    await page.locator('text=Current location').scrollIntoViewIfNeeded();
    const selects = page.locator('select');
    const count = await selects.count();
    // Last select before city loads is the city state select
    await selects.nth(count - 1).selectOption('Karnataka');
    await expect(page.locator('text=City / Town')).toBeVisible({ timeout: 5000 });
    const cityOptions = await page.locator('select').last().locator('option').allTextContents();
    expect(cityOptions.some(o => o.includes('Bengaluru'))).toBeTruthy();
  });

});
