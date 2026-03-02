# Uncommitted Changes Outline (2026-02-23)

## Snapshot
- Branch: `master` (tracking `origin/master`)
- Staged: planning docs only (5 files)
- Unstaged: runtime code changes (3 files)
- Untracked: new feature files/settings/docs plus scratch artifacts

## Workstream A: Search auto-reply feature (runtime code)
Files:
- `default/template/php/post.php`
- `default/template/php/search_auto_reply.php` (new)
- `default/setting/search/auto_reply_sqlite` (new, value `0`)

What it adds:
- Includes a new helper module for search auto-reply handling.
- Adds direct redirect behavior when `#search` input is an item hash/prefix.
- Adds auto-reply trigger logic for new top-level `#search` posts.
- Enqueues `search_auto_reply` tasks and processes a small queue inline.
- New SQLite-backed helper for:
  - queue fetch/delete,
  - query text extraction from `.txt` source,
  - tokenized lookup against `item_flat`,
  - reply message formatting,
  - optional 8-char hash-prefix resolution.

## Workstream B: Hash normalization / merge footer cleanup (Perl runtime)
Files:
- `default/template/perl/utils.pl`
- `default/template/perl/file.pl`
- `doc/ai_plans/hash-divergence-plan.md` (new, untracked)
- `temp1/dad822c0f193ecc51369ddf85b53aa69bbcf425c.txt` (new, untracked)
- `temp1/b3a4c7a9468dfbfec89dc8dcf863194e72f29ec8.txt` (new, untracked)

What it changes:
- `GetFileHash` now hashes raw file bytes via `Digest::SHA->addfile` instead of hashing decoded text.
- `GetSHA1` and `GetMD5` now normalize to bytes once (no double UTF-8 encoding).
- `MergeFiles` footer handling now trims, removes blank lines, de-duplicates, and omits signature separator if no footer remains.

## Workstream C: Search planning docs (staged)
Files:
- `doc/ai_plans/collaborative_search_step1_solution_assessment.md`
- `doc/ai_plans/collaborative_search_step2_feature_description.md`
- `doc/ai_plans/search_auto_reply_step1_solution_assessment.md`
- `doc/ai_plans/search_auto_reply_step2_feature_description.md`
- `doc/ai_plans/search_auto_reply_step3_development_plan.md`

What it contains:
- Two planning tracks:
  - collaborative search workflow/queue concept,
  - automated `#search` first-reply behavior with SQLite lookup.
- Documents option analysis, feature requirements, and phased implementation stages.

## Workstream D: Agent/LLM documentation proposals (untracked)
Files:
- `doc/agent_engagement_proposals.md`
- `doc/ai_plans/llms_txt_generation_plan.md`

What it contains:
- Agent onboarding/process documentation proposals.
- Config-driven `/llms.txt` generation proposal and rollout plan.

## Workstream E: FDP sync/import (untracked)
Files:
- `doc/fdp/FEATURE_DEVELOPMENT_PROCESS.md`
- `doc/fdp/README.md`
- `doc/fdp/dev/feature_process/*.md` (10 files)

What it contains:
- Local copy of the updated feature development process package from `~/fdp`.
- Path normalization for this repository conventions:
  - `docs/dev/feature_process/...` -> `doc/fdp/dev/feature_process/...`
  - `docs/plans/...` -> `doc/ai_plans/...`
  - subtree prefix examples updated to `--prefix=doc/fdp`

## Branch split recommendation
1. `feature/search-auto-reply`
   - Include Workstream A runtime files.
   - Optionally include only matching search-auto-reply plan docs.
2. `fix/hash-normalization`
   - Include Workstream B Perl/hash changes.
   - Keep temp files out unless explicitly needed for reproducibility.
3. `docs/search-plans`
   - Collaborative search + auto-reply planning docs.
4. `docs/agent-llms`
   - Agent engagement + `/llms.txt` planning docs.
5. `docs/fdp-sync`
   - FDP framework docs and this outline update.

## Review findings (risk-oriented)
1. High: Multiple unrelated efforts are mixed in one working tree, combining PHP feature work, Perl hash behavior changes, and separate docs proposals. This increases review and rollback risk.
2. Medium: Hash behavior changes (`utils.pl`) are broad-impact and should not ship bundled with search auto-reply logic.
3. Medium: `temp1/` appears to contain local experiment artifacts (PGP-signed test text) and likely should not be committed unless intentionally used as fixtures.
4. Low: FDP sync is documentation-only and should stay isolated from runtime feature branches.
