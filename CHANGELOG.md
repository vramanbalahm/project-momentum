# Changelog

All notable changes to Ladleful are documented here, one entry per version.
Versions are tagged in git at the exact commit deployed to QA
(`git tag`, or `git describe --tags` to see what's currently checked out).

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
