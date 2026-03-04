# Step 1 Solution Assessment: Merge-Path Separator Fix

## Problem statement
Reindex/organize can rewrite footerless items to include a bare `--` separator, causing content drift and hash divergence.

## Option A: Minimal merge-behavior correction (recommended)

### Pros
- Smallest scope and fastest stabilization path.
- Directly targets the observed divergence trigger.
- Low rollout risk and easy to reason about.

### Cons
- Leaves broader duplicate-file workflow behavior unchanged.
- May not address other non-separator merge edge cases.

## Option B: Disable organize/merge behavior broadly

### Pros
- Quickly avoids this entire class of merge-time rewrites.
- Very low code-change surface.

### Cons
- Reduces current dedupe/organization behavior.
- Risks storage/path drift and operational regressions elsewhere.

## Option C: Broader write-path consolidation

### Pros
- Reduces likelihood of duplicate-file collisions long term.
- Improves consistency of item lifecycle behavior.

### Cons
- Larger scope and higher regression risk.
- Slower path to immediate production stabilization.

## Recommendation
Choose **Option A** now to stop the hash-divergence behavior quickly, then evaluate Option C as a follow-up hardening effort once stability is confirmed.
