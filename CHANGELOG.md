# Changelog

All notable changes to Ladleful are documented here, one entry per version.
Versions are tagged in git at the exact commit deployed to QA
(`git tag`, or `git describe --tags` to see what's currently checked out).

## v0.9.2-beta — 2026-09-19

- Fixed "Seed holiday templates" failing on QA with a file-not-found
  error — `backend/.dockerignore` had a blanket exclusion on the whole
  `scripts/` folder, so `tn_holidays_2026.json` (and every script built
  this session) never actually reached the deployed container, only
  local checkouts. Removed the exclusion; `recipe_images/` stays
  excluded since that's correctly handled via GCS separately.

**Data migration (no code change, same version):**
- Exported and imported today's AI-generated dishes (126 new),
  pairings (874), and duplicate suggestions (2) from local into QA —
  built `export_new_data.py` / `import_new_data.py` for this, since
  `psql` wasn't available locally
- Found and fixed a real sequence-drift issue on QA's `recipe_pairing`
  table (auto-increment counter was behind the actual max id, from an
  earlier bulk load that bypassed the sequence) — one-time `setval()`
  fix
- Cleaned up bad `matrix_seeded` pairing data on both local and QA:
  deleted entirely, after confirming (via `pairing_confirmed_no_sides`)
  that every dish which would lose its only side coverage had already
  been correctly judged by the AI pipeline as genuinely needing no
  side (continental dishes, cereals, etc.) — nothing left without
  legitimate coverage

## v0.9.1-beta — 2026-09-19

- Fixed QA's holiday backfill returning zero rows — the holiday
  templates had never been seeded there (only the lunar/Panchangam
  ones had), traced via a precise diagnostic query rather than
  assumption
- New "Seed holiday templates" button in Platform Admin, so this no
  longer requires manually running a script with a raw database
  connection string — matches the same self-service pattern as the
  existing Backfill button
- Clarified the `event_master` architecture: it holds a household's
  full calendar (lunar observances, government holidays, and personal
  events together, distinguished by `source`/`event_type`), while
  `panchangam_master` is the separate, platform-wide lunar template
  table — noted a future optimization idea (store only what a
  household has opted *out* of, rather than a full copy per household)
  as a backlog item to revisit once real usage justifies it

## v0.9.0-beta — 2026-09-19

**Original 10-item bug list — all resolved:**
- Fixed `cuisine_regions` duplicates and Tamil Brahmin naming
- Add Member button restored to onboarding wizard
- Fixed Lunar Calendar summary not recording completed steps
- Profile-only household members (no login required) via explicit toggle
- Fixed next-week planning being permanently locked out
- Dev reset button restricted to platform admins only
- Government holidays: seeded, auto-copied into every new household at registration, backfill tool for existing households
- Consolidated My Profile / My Config / Household Settings into one Settings entry point
- Comprehensive date-handling audit across the whole plan/generate/save/audit flow — current and next week now fully correct
- Availability screen fixed for next-week planning, consolidated into Weekly Plan itself with a red-dot indicator, redundant standalone screen and dead icons removed

**AI-powered side-dish pairing pipeline (new):**
- Built `seed_recipe_pairings_groq.py` using Groq/GPT-OSS-120B to properly pair mains with sides, replacing the old crude cross-product matrix
- Fixed diet-type misdetection, rate-limit handling with automatic retry, and cuisine scope (was incorrectly limited to Brahmin-only)
- Ran to completion across Breakfast, Lunch, and Dinner

**Platform Admin — new duplicate-cleanup toolkit:**
- New Platform Admin screen with an extensible tools list
- Manual merge tool: search-and-select duplicates on one side, pick a merge target on the other
- AI-verified duplicate suggestions: a separate tool that proactively scans for likely duplicates and has the AI itself judge each candidate (validated against real hard cases — catches genuine spelling variants like "Avial"/"Aviyal" that pure text-matching misses, while correctly avoiding false matches like different-legume Kadala curries)
- Search across the reviewer queue upgraded to trigram similarity (was missing spelling variants entirely)

**Known open items carried into the next version:**
- Ingredient image generation — explored a free hosted option (blocked, real credit requirement); local generation on a dedicated-GPU machine still being evaluated
- Member-profile redirect bug after adding a member (needs repro steps)
- Missing vegetables / custom ingredient creation
- Meal-plan generation intelligence — a bigger design conversation, parked for a dedicated session
