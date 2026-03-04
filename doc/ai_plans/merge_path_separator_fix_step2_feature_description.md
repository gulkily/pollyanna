# Step 2 Feature Description: Merge-Path Separator Fix

## Problem
During clean/build/index workflows, footerless items can be rewritten to include a bare `--` separator, which changes file content and item hash unexpectedly. This creates divergence between original post content and post-index stored content.

## User stories
- As an operator, I want indexing and organize flows to preserve footerless content so that item hashes stay stable.
- As a maintainer, I want separator behavior to be consistent across write and merge paths so that hash behavior is predictable.
- As an end user cloning/exporting data, I want rebuild/index runs to avoid mutating existing item text so that archives remain reproducible.

## Core requirements
- Reindex/organize must not introduce a separator when no footer content exists.
- Existing items that already contain meaningful footer metadata must continue to be handled correctly.
- New-item posting and rebuild/index workflows must produce consistent content outcomes for equivalent input.
- Behavior must remain configurable via existing separator policy controls without introducing regressions in current producer paths.

## Shared component inventory
- Canonical footer policy helper (`AppendFooterSeparator` in PHP/Perl):
  - Reuse as the single policy source for deciding whether a separator is emitted.
- File dedupe/organize merge surface (`MergeFiles` / `OrganizeFile`):
  - Extend to align with canonical separator policy instead of independent separator reconstruction.
- Posting/producer entry points (`store_new_comment.php`, `post.php`, `route.php`, access-log publish paths):
  - Reuse existing flows; no new producer surface needed.
- Index/render consumers (`IndexTextFile`, `item_template.pl`):
  - Reuse unchanged behavior expectations; they should consume stable content without additional mutation.

## Simple user flow
1. User creates or imports text content with or without footer metadata.
2. System stores content and later runs clean/build/index or organize operations.
3. Merge/organize path applies the same separator policy as other producer paths.
4. Item remains content-stable unless real footer content is present.

## Success criteria
- Rebuilding and reindexing a footerless item does not append a bare `--` separator.
- Content hash for unaffected footerless items remains stable across clean/build/index cycles.
- Existing footer-bearing items retain expected footer behavior after index and render.
- Logs and behavior confirm a single separator policy model is applied across producer and merge paths.
