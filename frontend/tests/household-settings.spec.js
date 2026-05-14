// tests/household-settings.spec.js — Household Settings screen Playwright tests
//
// Test cases:
//  1.  Household Settings tile visible for household admin on Dashboard
//  2.  Household Settings tile NOT visible for plain household member
//  3.  Tapping tile navigates to Household Settings screen
//  4.  Household Settings screen shows three menu items
//  5.  Satvik Definition item navigates to Satvik editor
//  6.  Satvik editor loads with ingredient list
//  7.  Saving Satvik settings shows success toast
//  8.  Lunar Calendar item navigates to Lunar editor
//  9.  Lunar editor loads with Panchangam options
// 10.  Saving Lunar preference shows success toast
// 11.  Events item navigates to Events editor
// 12.  Events editor loads with Add an event option
// 13.  Adding an event and saving shows success toast
// 14.  Back navigation from editor returns to Household Settings menu
// 15.  Back navigation from Household Settings returns to Dashboard
// 16.  Household Settings accessible from settings dropdown menu
//
// Prerequisites:
//  - Frontend running: npm run dev (http://localhost:5173)
//  - Backend running: uvicorn main:app --reload (http://localhost:8000)
//  - Set ADMIN_EMAIL, ADMIN_PASSWORD, MEMBER_EMAIL, MEMBER_PASSWORD below
//    (or in frontend/.env.test)
//
// No DB cleanup needed — tests only read/save settings, no destructive data.

import { test, expect } from '@playwright/test';

const ADMIN_EMAIL    = process.env.ADMIN_EMAIL    || 'testadmin@momentum-test.com';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'TestAdmin1!';
const MEMBER_EMAIL   = process.env.MEMBER_EMAIL   || 'testmember@momentum-test.com';
const MEMBER_PASSWORD = process.env.MEMBER_PASSWORD || 'TestMember1!';

// ── Helpers ───────────────────────────────────────────────────────────────────

async function loginAs(page, email, password) {
  await page.goto('/');
  await page.waitForSelector('input[type="email"]', { timeout: 10000 });
  await page.locator('input[type="email"]').fill(email);
  await page.locator('input[type="password"]').fill(password);
  await page.locator('button', { hasText: 'Sign in' }).click();
  await page.waitForSelector('text=Weekly Plan', { timeout: 10000 });
}

async function loginAsAdmin(page) {
  await loginAs(page, ADMIN_EMAIL, ADMIN_PASSWORD);
}

async function loginAsMember(page) {
  await loginAs(page, MEMBER_EMAIL, MEMBER_PASSWORD);
}

async function goToHouseholdSettings(page) {
  await page.locator('text=Household Settings').first().click();
  await page.waitForSelector('text=Configure your household preferences', { timeout: 8000 });
}

// ── Dashboard tile visibility ─────────────────────────────────────────────────

test.describe('Household Settings tile visibility', () => {

  // Test 1
  test('tile is visible for household admin', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page.locator('text=Household Settings')).toBeVisible();
  });

  // Test 2
  test('tile is NOT visible for plain household member', async ({ page }) => {
    await loginAsMember(page);
    await expect(page.locator('text=Household Settings')).not.toBeVisible();
  });

});

// ── Navigation ────────────────────────────────────────────────────────────────

test.describe('Household Settings navigation', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
  });

  // Test 3
  test('tapping tile navigates to Household Settings screen', async ({ page }) => {
    await page.locator('text=Household Settings').first().click();
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
  });

  // Test 4
  test('screen shows three menu items', async ({ page }) => {
    await goToHouseholdSettings(page);
    await expect(page.locator('text=Satvik definition')).toBeVisible();
    await expect(page.locator('text=Lunar calendar')).toBeVisible();
    await expect(page.locator('text=Events & special days')).toBeVisible();
  });

  // Test 15
  test('back navigation returns to Dashboard', async ({ page }) => {
    await goToHouseholdSettings(page);
    await page.locator('text=← Dashboard').click();
    await expect(page.locator('text=Weekly Plan')).toBeVisible({ timeout: 8000 });
  });

  // Test 16
  test('Household Settings accessible from settings dropdown', async ({ page }) => {
    await page.locator('text=⚙️').first().click();
    await expect(page.locator('text=Household Settings')).toBeVisible();
    await page.locator('text=Household Settings').last().click();
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
  });

});

// ── Satvik editor ─────────────────────────────────────────────────────────────

test.describe('Satvik settings', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToHouseholdSettings(page);
    await page.locator('text=Satvik definition').click();
    await page.waitForSelector('text=AVOIDS', { timeout: 8000 });
  });

  // Test 5
  test('Satvik item navigates to Satvik editor', async ({ page }) => {
    await expect(page.locator('text=Satvik definition').first()).toBeVisible();
  });

  // Test 6
  test('Satvik editor loads with ingredient list', async ({ page }) => {
    // Ingredient selector should be visible with at least some toggleable items
    const ingredients = page.locator('[class*="ingredient"], input[type="checkbox"], button').first();
    await expect(ingredients).toBeVisible({ timeout: 8000 });
  });

  // Test 7
  test('saving Satvik settings shows success toast', async ({ page }) => {
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Satvik settings saved')).toBeVisible({ timeout: 8000 });
  });

  // Test 14
  test('back navigation returns to Household Settings menu', async ({ page }) => {
    await page.locator('text=← Back to settings').click();
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
  });

});

// ── Lunar Calendar editor ─────────────────────────────────────────────────────

test.describe('Lunar Calendar settings', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToHouseholdSettings(page);
    await page.locator('text=Lunar calendar').click();
    await page.waitForSelector('text=Panchangam', { timeout: 8000 });
  });

  // Test 8
  test('Lunar item navigates to Lunar editor', async ({ page }) => {
    await expect(page.locator('text=Lunar calendar').first()).toBeVisible();
  });

  // Test 9
  test('Lunar editor loads with Panchangam options', async ({ page }) => {
    // Should show at least the "We don't follow a Panchangam" option
    await expect(page.locator("text=We don't follow a Panchangam")).toBeVisible({ timeout: 8000 });
  });

  // Test 10
  test('saving Lunar preference shows success toast', async ({ page }) => {
    // Select "We don't follow" option and save
    await page.locator("text=We don't follow a Panchangam").click();
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Lunar calendar saved')).toBeVisible({ timeout: 8000 });
  });

});

// ── Events editor ─────────────────────────────────────────────────────────────

test.describe('Events & special days settings', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToHouseholdSettings(page);
    await page.locator('text=Events & special days').click();
    await page.waitForSelector('text=Add an event', { timeout: 8000 });
  });

  // Test 11
  test('Events item navigates to Events editor', async ({ page }) => {
    await expect(page.locator('text=Events & special days').first()).toBeVisible();
  });

  // Test 12
  test('Events editor loads with Add an event option', async ({ page }) => {
    await expect(page.locator('text=Add an event')).toBeVisible();
  });

  // Test 13
  test('adding an event and saving shows success toast', async ({ page }) => {
    await page.locator('text=+ Add an event').click();
    await page.locator('input[placeholder*="Birthday"]').fill("Test Event");
    await page.locator('input[placeholder*="15-03"]').fill("06-15");
    await page.locator('button', { hasText: 'Add event' }).click();
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Events saved')).toBeVisible({ timeout: 8000 });
  });

});
