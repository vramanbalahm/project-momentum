// tests/household-quick-entry.spec.js — Household quick-entry dish Playwright tests
//
// Covers:
//  1. "Add your own dish" CTA appears when Dish Search comes up empty
//  2. Modal opens prefilled with the search query
//  3. Submit is disabled until dish name + diet type + main ingredient are all set
//  4. Successful creation shows the new dish in Dish Search results
//  5. Meal-replace flow (MealEditScreen): creating a quick dish selects it
//     straight into the slot instead of just refreshing a list
//  6. Cross-household isolation: a second, freshly-registered household
//     cannot see the first household's quick dish in their own search
//
// Prerequisites:
//  - Frontend running: npm run dev (http://localhost:5173)
//  - Backend running: uvicorn main:app --reload --host 0.0.0.0 --port 8000
//  - Schema v30 migration applied (created_by_house_id FK/index/comment)
//
// Test 6 registers a real throwaway second household via the UI (same
// pattern as register.spec.js). Clean up afterward with:
//
//   DO $$ DECLARE v_house_id UUID;
//   BEGIN
//     SELECT house_id INTO v_house_id FROM users WHERE email LIKE '%@playwright-test.com';
//     DELETE FROM refresh_tokens    WHERE house_id = v_house_id;
//     DELETE FROM users             WHERE house_id = v_house_id;
//     DELETE FROM household_master  WHERE household_id = v_house_id;
//   END $$;
//
// Also clean up any quick dishes created by the main ADMIN_EMAIL account
// during this spec run:
//
//   DELETE FROM recipe_ingredients WHERE recipe_id IN
//     (SELECT recipe_id FROM recipe_dna_master WHERE dish_name LIKE 'PW Quick Dish%');
//   DELETE FROM recipe_dna_master WHERE dish_name LIKE 'PW Quick Dish%';

import { test, expect } from '@playwright/test';

const ADMIN_EMAIL    = process.env.ADMIN_EMAIL    || 'vramanbala@yahoo.com';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'A1234567*';
const TEST_DOMAIN    = '@playwright-test.com';

function uniqueDishName() {
  return `PW Quick Dish ${Date.now()}`;
}

function uniqueEmail() {
  return `qe_${Date.now()}${TEST_DOMAIN}`;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

async function login(page, email = ADMIN_EMAIL, password = ADMIN_PASSWORD) {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('input[type="email"]', { timeout: 20000 });
  await page.locator('input[type="email"]').fill(email);
  await page.locator('input[type="password"]').fill(password);
  await page.locator('button', { hasText: 'Sign in' }).click();
  await page.waitForSelector('text=What would you like to do', { timeout: 30000 });
}

async function goToDishSearch(page) {
  await page.locator('[data-testid="tile-dish_search"]').click();
  await page.waitForSelector('input[placeholder="Search dishes..."]', { timeout: 10000 });
}

async function fillQuickEntryModal(page, { dishName, diet = 'Veg', ingredient }) {
  await expect(page.locator('text=Add your own dish')).toBeVisible({ timeout: 5000 });

  await page.locator('[data-testid="quick-entry-dish-name"]').fill(dishName);
  await page.locator(`[data-testid="quick-entry-diet-${diet}"]`).click();

  await page.locator('[data-testid="quick-entry-ingredient-search"]').fill(ingredient);
  await page.waitForSelector('[data-testid="quick-entry-ingredient-results"]', { timeout: 5000 });
  await page.locator('[data-testid="quick-entry-ingredient-results"] > div').first().click();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

test.describe('Household Quick-Entry Dish — Dish Search', () => {

  test.beforeEach(async ({ page }) => {
    await login(page);
    await goToDishSearch(page);
  });

  test('CTA appears when search comes up empty', async ({ page }) => {
    const gibberish = `Zzqx${Date.now()}NoSuchDish`;
    await page.locator('input[placeholder="Search dishes..."]').fill(gibberish);
    await expect(page.locator('text=No dishes found')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('button', { hasText: /Add ".*" as your own dish/i })).toBeVisible();
  });

  test('modal opens prefilled with the search query', async ({ page }) => {
    const gibberish = `Zzqx${Date.now()}NoSuchDish`;
    await page.locator('input[placeholder="Search dishes..."]').fill(gibberish);
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();
    await expect(page.locator('text=Add your own dish')).toBeVisible();
    await expect(page.locator('[data-testid="quick-entry-dish-name"]')).toHaveValue(gibberish);
  });

  test('submit stays disabled until all required fields are set', async ({ page }) => {
    const gibberish = `Zzqx${Date.now()}NoSuchDish`;
    await page.locator('input[placeholder="Search dishes..."]').fill(gibberish);
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();

    const submitBtn = page.locator('[data-testid="quick-entry-submit"]');
    await expect(submitBtn).toBeDisabled();

    // Diet type only — still disabled, no ingredient yet
    await page.locator('[data-testid="quick-entry-diet-Veg"]').click();
    await expect(submitBtn).toBeDisabled();
  });

  test('creating a dish shows it in search results afterward', async ({ page }) => {
    const dishName = uniqueDishName();
    await page.locator('input[placeholder="Search dishes..."]').fill(dishName);
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();

    await fillQuickEntryModal(page, { dishName, diet: 'Veg', ingredient: 'Rice' });

    const submitBtn = page.locator('[data-testid="quick-entry-submit"]');
    await expect(submitBtn).toBeEnabled({ timeout: 5000 });
    await submitBtn.click();

    // Modal closes, results refresh, the new dish should now appear
    await expect(page.locator('text=Add your own dish')).not.toBeVisible({ timeout: 10000 });
    await expect(page.locator(`text=${dishName}`)).toBeVisible({ timeout: 10000 });
  });

  test('closing the modal without submitting discards it cleanly', async ({ page }) => {
    const gibberish = `Zzqx${Date.now()}NoSuchDish`;
    await page.locator('input[placeholder="Search dishes..."]').fill(gibberish);
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();
    await expect(page.locator('text=Add your own dish')).toBeVisible();

    await page.locator('[data-testid="quick-entry-close"]').click();
    await expect(page.locator('text=Add your own dish')).not.toBeVisible();
    // Original empty state should still be there, untouched
    await expect(page.locator('text=No dishes found')).toBeVisible();
  });
});


test.describe('Household Quick-Entry Dish — Meal Replace Flow', () => {

  test.beforeEach(async ({ page }) => {
    await login(page);
    await page.locator('[data-testid="tile-weekly_plan"]').click();
    await page.waitForTimeout(2000);
  });

  test('creating a quick dish in the meal-replace screen selects it directly into the slot', async ({ page }) => {
    // Tapping a meal card is the app's existing entry point into the edit
    // sheet; from there "Replace" opens MealEditScreen's search panel.
    const mealCard = page.locator('[data-testid^="meal-card-"]').first();
    if (!(await mealCard.isVisible({ timeout: 5000 }).catch(() => false))) {
      test.skip(true, 'No meal card visible -- requires an existing generated/saved plan for this week');
    }
    await mealCard.click();

    const replaceBtn = page.locator('button', { hasText: 'Replace' }).first();
    await replaceBtn.waitFor({ state: 'visible', timeout: 5000 });
    await replaceBtn.click();

    await page.waitForSelector('text=Choose a dish', { timeout: 10000 });

    const gibberish = `Zzqx${Date.now()}NoSuchDish`;
    await page.locator('input[placeholder="Search dishes..."]').fill(gibberish);
    await expect(page.locator('button', { hasText: /Add ".*" as your own dish/i })).toBeVisible({ timeout: 10000 });
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();

    const dishName = uniqueDishName();
    await fillQuickEntryModal(page, { dishName, diet: 'Veg', ingredient: 'Rice' });

    const submitBtn = page.locator('[data-testid="quick-entry-submit"]');
    await expect(submitBtn).toBeEnabled({ timeout: 5000 });
    await submitBtn.click();

    // Should land back on the plan/edit sheet with the new dish now in the slot,
    // not still sitting on the search panel.
    await expect(page.locator('text=Choose a dish')).not.toBeVisible({ timeout: 10000 });
    await expect(page.locator(`text=${dishName}`)).toBeVisible({ timeout: 10000 });
  });
});


test.describe('Household Quick-Entry Dish — Cross-Household Isolation', () => {

  test('a second household cannot see the first household\'s quick dish', async ({ page }) => {
    // Step 1 — create a quick dish as the main admin account
    await login(page);
    await goToDishSearch(page);
    const dishName = uniqueDishName();
    await page.locator('input[placeholder="Search dishes..."]').fill(dishName);
    await page.locator('button', { hasText: /Add ".*" as your own dish/i }).click();
    await fillQuickEntryModal(page, { dishName, diet: 'Veg', ingredient: 'Rice' });
    await page.locator('[data-testid="quick-entry-submit"]').click();
    await expect(page.locator(`text=${dishName}`)).toBeVisible({ timeout: 10000 });

    // Step 2 — log out, register a fresh throwaway household
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await page.waitForSelector('text=Sign in', { timeout: 10000 });
    await page.locator('text=Create account').click();
    await page.waitForSelector('text=New household signup', { timeout: 10000 });

    await page.locator('input[type="text"]').nth(0).fill('Isolation Test User');
    await page.locator('input[type="email"]').fill(uniqueEmail());
    await page.locator('input[type="password"]').nth(0).fill('ValidPass1!');
    await page.locator('input[type="password"]').nth(1).fill('ValidPass1!');
    await page.locator('input[type="text"]').nth(1).fill('Isolation Test House');
    await page.locator('button', { hasText: 'Continue' }).click();
    await expect(page.locator('text=MOMENTUM')).toBeVisible({ timeout: 15000 });

    // Step 3 — this new household searches for the first household's dish name
    await goToDishSearch(page);
    await page.locator('input[placeholder="Search dishes..."]').fill(dishName);
    await expect(page.locator('text=No dishes found')).toBeVisible({ timeout: 10000 });
    await expect(page.locator(`text=${dishName}`)).not.toBeVisible();
  });
});
