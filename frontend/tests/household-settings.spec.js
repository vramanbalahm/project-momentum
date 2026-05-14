// tests/household-settings.spec.js — Household Settings screen Playwright tests

import { test, expect } from '@playwright/test';

const ADMIN_EMAIL     = process.env.ADMIN_EMAIL     || 'vramanbala@yahoo.com';
const ADMIN_PASSWORD  = process.env.ADMIN_PASSWORD  || 'A1234567*';
const MEMBER_EMAIL    = process.env.MEMBER_EMAIL    || 'testmember@momentum.qa';
const MEMBER_PASSWORD = process.env.MEMBER_PASSWORD || 'Member@123';

// ── Helpers ───────────────────────────────────────────────────────────────────

async function loginAs(page, email, password) {
  await page.goto('/');
  await page.waitForSelector('input[type="email"]', { timeout: 15000 });
  await page.locator('input[type="email"]').fill(email);
  await page.locator('input[type="password"]').fill(password);
  const signInBtn = page.locator('button', { hasText: 'Sign in' });
  await signInBtn.waitFor({ state: 'visible', timeout: 10000 });
  await signInBtn.click();
  await page.waitForSelector('text=What would you like to do', { timeout: 30000 });
}

async function loginAsAdmin(page) {
  await loginAs(page, ADMIN_EMAIL, ADMIN_PASSWORD);
}

async function loginAsMember(page) {
  await loginAs(page, MEMBER_EMAIL, MEMBER_PASSWORD);
}

async function goToHouseholdSettings(page) {
  await page.locator('[data-testid="tile-household_settings"]').click();
  await page.waitForSelector('text=Configure your household preferences', { timeout: 8000 });
}

// ── Dashboard tile visibility ─────────────────────────────────────────────────

test.describe('Household Settings tile visibility', () => {

  // Test 1
  test('tile is visible for household admin', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page.locator('[data-testid="tile-household_settings"]')).toBeVisible();
  });

  // Test 2
  test('tile is NOT visible for plain household member', async ({ page }) => {
    await loginAsMember(page);
    // Household Settings tile should either not exist or not be available (dimmed/non-clickable)
    const tile = page.locator('[data-testid="tile-household_settings"]');
    const count = await tile.count();
    if (count > 0) {
      // If tile exists, it should not be available (opacity 0.6, cursor default)
      const opacity = await tile.evaluate(el => getComputedStyle(el).opacity);
      expect(parseFloat(opacity)).toBeLessThan(1);
    }
    // If count is 0, tile is correctly hidden — pass
  });

});

// ── Navigation ────────────────────────────────────────────────────────────────

test.describe('Household Settings navigation', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
  });

  // Test 3
  test('tapping tile navigates to Household Settings screen', async ({ page }) => {
    await page.locator('[data-testid="tile-household_settings"]').click();
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
  });

  // Test 4
  test('screen shows three menu items', async ({ page }) => {
    await goToHouseholdSettings(page);
    await expect(page.locator('text=Satvik definition')).toBeVisible();
    await expect(page.locator('text=Lunar calendar')).toBeVisible();
    await expect(page.locator('text=Events & special days')).toBeVisible();
  });

  // Test 5
  test('back navigation returns to Dashboard', async ({ page }) => {
    await goToHouseholdSettings(page);
    await page.locator('text=← Dashboard').click();
    await expect(page.locator('text=What would you like to do')).toBeVisible({ timeout: 8000 });
  });

  // Test 6
  test('Household Settings accessible from settings dropdown', async ({ page }) => {
    await page.locator('text=⚙️').first().click();
    await expect(page.locator('text=Household Settings').last()).toBeVisible();
    await page.locator('text=Household Settings').last().click({ force: true });
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
  });

});

// ── Satvik editor ─────────────────────────────────────────────────────────────

test.describe('Satvik settings', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToHouseholdSettings(page);
    await page.locator('text=Satvik definition').click();
    await page.waitForSelector('text=Satvik definition', { timeout: 8000 });
  });

  // Test 7
  test('Satvik item navigates to Satvik editor', async ({ page }) => {
    await expect(page.locator('text=Back to settings')).toBeVisible();
  });

  // Test 8
  test('Satvik editor loads with ingredient list', async ({ page }) => {
    await expect(page.locator('text=AVOIDS')).toBeVisible({ timeout: 8000 });
  });

  // Test 9
  test('saving Satvik settings shows success toast', async ({ page }) => {
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Satvik settings saved')).toBeVisible({ timeout: 5000 });
  });

  // Test 10
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
    await page.waitForSelector('text=Lunar calendar', { timeout: 8000 });
  });

  // Test 11
  test('Lunar item navigates to Lunar editor', async ({ page }) => {
    await expect(page.locator('text=Back to settings')).toBeVisible();
  });

  // Test 12
  test('Lunar editor loads with Panchangam options', async ({ page }) => {
    await expect(page.locator("text=We don't follow a Panchangam")).toBeVisible({ timeout: 8000 });
  });

  // Test 13
  test('saving Lunar preference shows success toast', async ({ page }) => {
    await page.locator("text=We don't follow a Panchangam").click();
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Lunar calendar saved')).toBeVisible({ timeout: 5000 });
  });

  // Test 14
  test('back navigation returns to Household Settings menu', async ({ page }) => {
    await page.locator('text=← Back to settings').click();
    await expect(page.locator('text=Configure your household preferences')).toBeVisible({ timeout: 8000 });
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

  // Test 15
  test('Events editor loads with Add an event option', async ({ page }) => {
    await expect(page.locator('text=Add an event')).toBeVisible();
  });

  // Test 16
  test('adding an event and saving shows success toast', async ({ page }) => {
    await page.locator('text=+ Add an event').click();
    await page.locator('input[placeholder*="Birthday"]').fill("Test Event");
    await page.locator('input[placeholder*="15-03"]').fill("06-15");
    await page.locator('button', { hasText: 'Add event' }).click();
    await page.locator('button', { hasText: 'Save' }).click();
    await expect(page.locator('text=Events saved')).toBeVisible({ timeout: 5000 });
  });

});
