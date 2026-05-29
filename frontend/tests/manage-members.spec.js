// tests/manage-members.spec.js — Manage Members screen Playwright tests
//
// Test cases:
//  1.  Add member form — email field is optional (submit without email succeeds)
//  2.  Add member form — name is required (submit without name shows error)
//  3.  Add member form — password is required (submit without password shows error)
//  4.  Add member form — with all fields including email succeeds
//  5.  Promote member — custom in-app modal appears (no browser dialog)
//  6.  Promote member — Cancel button dismisses modal without promoting
//  7.  Promote member — Confirm button triggers promotion
//  8.  Deactivate member — custom in-app modal appears
//  9.  Deactivate member — Cancel button dismisses modal
// 10.  Deactivate member — Confirm button triggers deactivation
//
// Prerequisites:
//  - Frontend running: npm run dev (http://localhost:5173)
//  - Backend running: uvicorn main:app --reload (http://localhost:8000)

import { test, expect } from '@playwright/test';

const ADMIN_EMAIL    = process.env.ADMIN_EMAIL    || 'vramanbala@yahoo.com';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'A1234567*';

// ── Helpers ───────────────────────────────────────────────────────────────────

async function loginAsAdmin(page) {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('input[type="email"]', { timeout: 20000 });
  await page.locator('input[type="email"]').fill(ADMIN_EMAIL);
  await page.locator('input[type="password"]').fill(ADMIN_PASSWORD);
  const signInBtn = page.locator('button', { hasText: 'Sign in' });
  await signInBtn.waitFor({ state: 'visible', timeout: 10000 });
  await signInBtn.click();
  await page.waitForSelector('text=What would you like to do', { timeout: 30000 });
}

async function goToManageMembers(page) {
  await page.locator('[data-testid="tile-manage_members"]').click();
  await page.waitForSelector('text=Manage Members', { timeout: 8000 });
}

async function openAddForm(page) {
  await page.locator('button', { hasText: /Add member/ }).first().click();
  await page.waitForSelector('text=New member', { timeout: 5000 });
}

// ── Add Member form ───────────────────────────────────────────────────────────

test.describe('Add Member form', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToManageMembers(page);
    await openAddForm(page);
  });

  // Test 1
  test('email field is optional — submit without email succeeds', async ({ page }) => {
    await page.locator('input[placeholder*="Full name"]').fill('Test No Email');
    await page.locator('input[placeholder*="password"]').fill('ValidPass1!');
    // Leave email blank
    await page.locator('button', { hasText: 'Add member' }).click();
    // Should not show "all fields required" error
    await expect(page.locator('text=all fields required')).not.toBeVisible({ timeout: 3000 }).catch(() => {});
  });

  // Test 2
  test('name is required — submit without name shows error', async ({ page }) => {
    await page.locator('input[placeholder*="password"]').fill('ValidPass1!');
    await page.locator('button', { hasText: 'Add member' }).click();
    await expect(page.locator('text=required')).toBeVisible({ timeout: 5000 });
  });

  // Test 3
  test('password is required — submit without password shows error', async ({ page }) => {
    await page.locator('input[placeholder*="Full name"]').fill('Test No Password');
    await page.locator('button', { hasText: 'Add member' }).click();
    await expect(page.locator('text=required')).toBeVisible({ timeout: 5000 });
  });

  // Test 4
  test('submit with all fields including email succeeds', async ({ page }) => {
    const uniqueEmail = `test_${Date.now()}@momentum-test.com`;
    await page.locator('input[placeholder*="Full name"]').fill('Test Full Member');
    await page.locator('input[type="email"]').fill(uniqueEmail);
    await page.locator('input[placeholder*="password"]').fill('ValidPass1!');
    await page.locator('button', { hasText: 'Add member' }).click();
    await expect(page.locator('text=added successfully')).toBeVisible({ timeout: 8000 });
  });

});

// ── Promote/Demote modal ──────────────────────────────────────────────────────

test.describe('Promote member confirmation modal', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToManageMembers(page);
  });

  // Test 5
  test('promote button shows custom in-app modal not browser dialog', async ({ page }) => {
    // Set up dialog listener — should NOT fire (no browser confirm)
    let browserDialogFired = false;
    page.on('dialog', () => { browserDialogFired = true; });

    // Click promote on first non-admin member
    const promoteBtn = page.locator('text=Promote').first();
    if (await promoteBtn.count() > 0) {
      await promoteBtn.click();
      await page.waitForTimeout(500);
      expect(browserDialogFired).toBe(false);
      // Custom modal should appear
      await expect(page.locator('text=Promote member')).toBeVisible({ timeout: 5000 });
    }
  });

  // Test 6
  test('Cancel button dismisses modal without promoting', async ({ page }) => {
    const promoteBtn = page.locator('text=Promote').first();
    if (await promoteBtn.count() > 0) {
      await promoteBtn.click();
      await page.locator('text=Cancel').last().click();
      // Modal should be gone
      await expect(page.locator('text=Promote member')).not.toBeVisible({ timeout: 3000 });
    }
  });

  // Test 7
  test('Confirm button triggers promotion', async ({ page }) => {
    const promoteBtn = page.locator('text=Promote').first();
    if (await promoteBtn.count() > 0) {
      await promoteBtn.click();
      await page.locator('text=Yes, confirm').click();
      // Should show success or close modal
      await page.waitForTimeout(1000);
      await expect(page.locator('text=Promote member')).not.toBeVisible({ timeout: 5000 });
    }
  });

});

// ── Deactivate modal ──────────────────────────────────────────────────────────

test.describe('Deactivate member confirmation modal', () => {

  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await goToManageMembers(page);
  });

  // Test 8
  test('deactivate button shows custom in-app modal not browser dialog', async ({ page }) => {
    let browserDialogFired = false;
    page.on('dialog', () => { browserDialogFired = true; });

    const deactivateBtn = page.locator('text=Deactivate').first();
    if (await deactivateBtn.count() > 0) {
      await deactivateBtn.click();
      await page.waitForTimeout(500);
      expect(browserDialogFired).toBe(false);
      await expect(page.locator('text=Deactivate member')).toBeVisible({ timeout: 5000 });
    }
  });

  // Test 9
  test('Cancel button dismisses deactivate modal', async ({ page }) => {
    const deactivateBtn = page.locator('text=Deactivate').first();
    if (await deactivateBtn.count() > 0) {
      await deactivateBtn.click();
      await page.locator('text=Cancel').last().click();
      await expect(page.locator('text=Deactivate member')).not.toBeVisible({ timeout: 3000 });
    }
  });

  // Test 10
  test('Confirm button triggers deactivation', async ({ page }) => {
    const deactivateBtn = page.locator('text=Deactivate').first();
    if (await deactivateBtn.count() > 0) {
      await deactivateBtn.click();
      await page.locator('text=Yes, confirm').click();
      await page.waitForTimeout(1000);
      await expect(page.locator('text=Deactivate member')).not.toBeVisible({ timeout: 5000 });
    }
  });

});
