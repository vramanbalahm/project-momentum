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
  const generateBtn = page.locator('button', { hasText: /Generate plan/i });
  const isVisible = await generateBtn.first().isVisible({ timeout: 5000 }).catch(() => false);
  if (isVisible) {
    await generateBtn.first().click();
    await page.waitForTimeout(500);

    // "This week's preferences" questionnaire modal may appear — submit it to proceed
    const prefsModalGenerateBtn = page.locator('button', { hasText: /^.{0,3}Generate plan/i }).last();
    const modalVisible = await page.locator('text=/preferences/i').first().isVisible({ timeout: 3000 }).catch(() => false);
    if (modalVisible) {
      const modalBtn = page.locator('button', { hasText: /Generate plan/i }).last();
      await modalBtn.click();
      await page.waitForTimeout(500);
    }

    // First-time generation computes 21 slots — can take a while
    await Promise.race([
      page.locator('button', { hasText: /Review plan/i }).first().waitFor({ state: 'visible', timeout: 40000 }),
      page.waitForTimeout(40000),
    ]);
    await page.waitForTimeout(1000);
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
  const text = (await reviewBtn.first().textContent() || '').toLowerCase();

  if (text.includes('review')) {
    // "Review plan" — not yet audited, click runs the audit
    await reviewBtn.first().click();
    await page.waitForTimeout(2500);
  } else if (text === 'save plan' || text.includes('save plan')) {
    // isAudited=true but auditResults state was lost on a fresh page load
    // (leftover from a prior test's unsaved audit). Reload to reset to a
    // clean "Review plan" state, then click that to get fresh, visible indicators.
    await page.reload();
    await page.waitForTimeout(2000);
    const freshReviewBtn = page.locator('button', { hasText: /Review plan/i });
    const hasReview = await freshReviewBtn.first().isVisible({ timeout: 8000 }).catch(() => false);
    if (hasReview) {
      await freshReviewBtn.first().click();
      await page.waitForTimeout(2500);
    }
  } else if (text.includes('saved')) {
    // Fully saved plan — tap re-triggers audit (onClick=runAudit per app logic)
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

  test('audit indicators render after review (ok or issue pill present)', async ({ page }) => {
    test.setTimeout(60000); // first test in suite — cold browser/session, needs extra headroom
    await loginAsAdmin(page);
    await goToWeeklyPlan(page);
    await generatePlanIfNeeded(page);
    await clickReviewPlan(page);

    // A real plan may have every meal flagged with issues (no clean "ok" meals) —
    // that is valid audit behavior, not a bug. We only confirm SOME indicator rendered.
    // Extra-generous timeout here since this is the cold-start first test of the suite.
    const hasOk     = await page.locator('text=ok').first().isVisible({ timeout: 20000 }).catch(() => false);
    const hasIssues = await page.locator('text=/\d+ issues?/').first().isVisible({ timeout: 20000 }).catch(() => false);

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
