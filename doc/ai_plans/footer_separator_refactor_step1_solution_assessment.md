# Step 1 Solution Assessment: Footer Separator Refactor

## Problem statement
Footer/separator appending behavior is duplicated across multiple code paths, causing drift, hash instability risk, and hard-to-control rollout for separator removal.

## Option A: Single helper API per runtime (recommended)

### Pros
- Centralizes footer append rules in one place for PHP and one place for Perl.
- Gives one control point for `setting/admin/footer_separator/enable`.
- Minimizes regression risk by keeping existing call flow mostly intact.
- Supports incremental migration of call sites.

### Cons
- Still requires touching many call sites to adopt helpers.
- Two runtime helpers (PHP + Perl) must stay aligned.

## Option B: Full metadata pipeline redesign first

### Pros
- Solves root architecture (metadata out of message body) in one push.
- Could eliminate separator logic quickly after migration.

### Cons
- Larger scope before immediate stabilization.
- Higher rollout and migration risk (archive/import compatibility changes).
- Slower path to immediate hash-divergence mitigation.

## Option C: Keep existing paths, add only global feature flags

### Pros
- Fastest to ship.
- Minimal structural code change.

### Cons
- Duplication remains; future drift likely.
- Harder to reason about behavior consistency.
- Refactor debt remains for next iterations.

## Recommendation
Choose **Option A** now.

It gives a high-leverage structural improvement with limited scope increase, aligns directly with the planned `footer_separator/enable` gate, and preserves momentum toward separator deprecation without forcing full metadata architecture migration in the same step.
