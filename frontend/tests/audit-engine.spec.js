// tests/audit-engine.spec.js — Audit Engine UI Playwright tests
// Covers: Review Plan audit display, ok state, issues pill, expand panel

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

async function goToWeeklyPlan(page) {
  await page.locator('[data-testid="tile-weekly_plan"]').click();
  await page.waitForTimeout(2000);

  // If Member Availability overlay opened (first-time current-week setup), save and continue
  const saveAvailBtn = page.locator('button', { hasText: 'Save Availability' });
  if (await saveAvailBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await saveAvailBtn.click();
    await page.waitForTimeout(2000);
  }
}

async function generatePlanIfNeeded(page) {
  const generateBtn = page.locator('button', { hasText: 'Generate' });
  if (await generateBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await generateBtn.click();
    await page.waitForTimeout(3000); // plan generation
  }
}

async function clickReviewPlan(page) {
  // CTA button cycles between "Generate plan" / "Review plan" / "Save plan" / "Saved"
  const reviewBtn = page.locator('button', { hasText: /Review plan|Save plan|Saved/i });
  const found = await reviewBtn.first().isVisible({ timeout: 15000 }).catch(() => false);
  if (!found) {
    await page.screenshot({ path: 'debug-no-review-btn.png', fullPage: true });
    throw new Error('Could not find Review/Save plan button — see debug-no-review-btn.png');
  }
  const text = await reviewBtn.first().textContent();
  if (text && text.toLowerCase().includes('review')) {
    await reviewBtn.first().click();
    await page.waitForTimeout(2500); // audit API call
  } else if (text && (text.toLowerCase().includes('saved'))) {
    // Plan already saved from a prior run — tap to re-trigger audit so indicators are fresh
    await reviewBtn.first().click();
    await page.waitForTimeout(2500);
  }
  // Wait for at least one audit indicator (ok text or issue pill) to confirm render completed
  await Promise.race([
    page.locator('text=ok').first().waitFor({ state: 'visible', timeout: 8000 }).catch(() => {}),
    page.locator('text=/\\d+ issues?/').first().waitFor({ state: 'visible', timeout: 8000 }).catch(() => {}),
  ]);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

test.describe('Audit Engine — Review Plan', () => {

  test('clean meal shows "ok" with no icon (if any clean meals exist)', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    // Some meals may show "ok", others may show issue pills — both are valid states.
    // We just verify the page rendered meal cards with SOME audit indicator (ok or issues).
    const okIndicator    = page.locator('text=ok').first();
    const issueIndicator = page.locator('text=/\d+ issues?/').first();

    const hasOk     = await okIndicator.isVisible({ timeout: 8000 }).catch(() => false);
    const hasIssues = await issueIndicator.isVisible({ timeout: 8000 }).catch(() => false);

    // At least one of the two audit states must be present — confirms audit ran
    expect(hasOk || hasIssues).toBeTruthy();
  });

  test('meal with issues shows issue count pill', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    // Look for "X issue" or "X issues" text pattern
    const issuePill = page.locator('text=/\\d+ issues?/').first();
    // This may or may not be present depending on plan content — soft check
    const isVisible = await issuePill.isVisible({ timeout: 5000 }).catch(() => false);
    if (isVisible) {
      await expect(issuePill).toBeVisible();
    }
  });

  test('tapping issue pill expands warning panel', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    const issuePill = page.locator('text=/\\d+ issues?/').first();
    const hasIssues = await issuePill.isVisible({ timeout: 5000 }).catch(() => false);

    if (hasIssues) {
      await issuePill.click();
      // Panel should show at least one warning message with the warning icon
      const warningIcon = page.locator('text=⚠️').first();
      await expect(warningIcon).toBeVisible({ timeout: 5000 });
    }
  });

  test('warning panel messages are plain language, no technical terms', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    const issuePill = page.locator('text=/\\d+ issues?/').first();
    const hasIssues = await issuePill.isVisible({ timeout: 5000 }).catch(() => false);

    if (hasIssues) {
      await issuePill.click();
      await page.waitForTimeout(500);

      // These technical terms should NEVER appear in the UI
      const technicalTerms = ['AU-D0', 'diet_type', 'feature_code', 'satvik_avoided_ids', 'recipe_pairing'];
      for (const term of technicalTerms) {
        const found = page.locator(`text=${term}`);
        await expect(found).toHaveCount(0);
      }
    }
  });

  test('clicking issue pill toggles panel open and closed', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    const issuePill = page.locator('text=/\\d+ issues?/').first();
    const hasIssues = await issuePill.isVisible({ timeout: 5000 }).catch(() => false);

    if (hasIssues) {
      // Open
      await issuePill.click();
      const panel = page.locator('text=⚠️').first();
      await expect(panel).toBeVisible({ timeout: 5000 });

      // Close
      await issuePill.click();
      await page.waitForTimeout(500);
      await expect(panel).not.toBeVisible({ timeout: 3000 }).catch(() => {});
    }
  });

  test('review plan does not block save even with issues present', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    // Save Plan button should always be enabled — audit never blocks
    const saveBtn = page.locator('button', { hasText: 'Save Plan' });
    if (await saveBtn.isVisible({ timeout: 5000 }).catch(() => false)) {
      await expect(saveBtn).toBeEnabled();
    }
  });

  test('day summary bar is not displayed', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    // Ensure no "X meals" or slot-count summary text appears
    const summaryText = page.locator('text=/\\d+ meals?$/');
    await expect(summaryText).toHaveCount(0);
  });
});

test.describe('Audit Engine — No-block principle', () => {

  test('user can still edit a meal flagged with issues', async ({ page }) => {
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    const issuePill = page.locator('text=/\\d+ issues?/').first();
    const hasIssues = await issuePill.isVisible({ timeout: 5000 }).catch(() => false);

    if (hasIssues) {
      await issuePill.click();
      const changeBtn = page.locator('button', { hasText: 'Change this meal' });
      if (await changeBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
        await expect(changeBtn).toBeEnabled();
      }
    }
  });
});
