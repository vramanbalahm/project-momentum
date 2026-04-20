// tests/login.spec.js — Login screen Playwright tests
//
// Test cases:
//  1. Page loads with all expected elements
//  2. Clicking "Create account" switches to Register screen
//  3. Empty form submission shows error
//  4. Only email filled shows error
//  5. Only password filled shows error
//  6. Valid credentials log in and land on Dashboard
//  7. Wrong password shows error
//  8. Non-existent email shows error
//
// Prerequisites:
//  - Frontend running: npm run dev (http://localhost:5173)
//  - Backend running: uvicorn main:app --reload (http://localhost:8000)
//  - Update VALID_EMAIL and VALID_PASSWORD below to a real account in your DB
//
// Cleanup: No DB cleanup needed — login tests create no data

import { test, expect } from '@playwright/test';

const VALID_EMAIL    = 'testadmin@momentum-test.com'; // update to a real account
const VALID_PASSWORD = 'TestAdmin1!';                 // update to match

async function goToLogin(page) {
  await page.goto('/');
  await page.waitForSelector('text=Sign in', { timeout: 10000 });
}

// ─────────────────────────────────────────────────────────────────────────────

test.describe('Login Screen', () => {

  test.beforeEach(async ({ page }) => {
    await goToLogin(page);
  });

  // Test 1
  test('page loads with all expected elements', async ({ page }) => {
    await expect(page.locator('text=🌿')).toBeVisible();
    await expect(page.locator('text=Momentum')).toBeVisible();
    await expect(page.locator('text=Your weekly meal planner')).toBeVisible();
    await expect(page.locator('text=Sign in').first()).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
    await expect(page.locator('button', { hasText: 'Sign in' })).toBeVisible();
    await expect(page.locator('text=Create account')).toBeVisible();
  });

  // Test 2
  test('clicking Create account switches to Register screen', async ({ page }) => {
    await page.locator('text=Create account').click();
    await expect(page.locator('text=New household signup')).toBeVisible();
  });

  // Test 3
  test('submitting empty form shows error', async ({ page }) => {
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // Test 4
  test('submitting with only email filled shows error', async ({ page }) => {
    await page.locator('input[type="email"]').fill('someone@example.com');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // Test 5
  test('submitting with only password filled shows error', async ({ page }) => {
    await page.locator('input[type="password"]').fill('SomePass1!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Please enter email and password')).toBeVisible();
  });

  // Test 6
  test('valid credentials log in and land on Dashboard', async ({ page }) => {
    await page.locator('input[type="email"]').fill(VALID_EMAIL);
    await page.locator('input[type="password"]').fill(VALID_PASSWORD);
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Good')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=Weekly Plan')).toBeVisible();
    await expect(page.locator('text=⚙️')).toBeVisible();
    await expect(page.locator('text=🚪')).toBeVisible();
  });

  // Test 7
  test('wrong password shows error message', async ({ page }) => {
    await page.locator('input[type="email"]').fill(VALID_EMAIL);
    await page.locator('input[type="password"]').fill('WrongPass999!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Invalid email or password')).toBeVisible({ timeout: 8000 });
  });

  // Test 8
  test('non-existent email shows error message', async ({ page }) => {
    await page.locator('input[type="email"]').fill('nobody@nowhere-at-all.com');
    await page.locator('input[type="password"]').fill('SomePass1!');
    await page.locator('button', { hasText: 'Sign in' }).click();
    await expect(page.locator('text=Invalid email or password')).toBeVisible({ timeout: 8000 });
  });

});
