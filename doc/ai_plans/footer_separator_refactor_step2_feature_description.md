# Step 2 Feature Description: Footer Separator Refactor

## Problem
Footer separator appending is currently handled in multiple places, which makes behavior inconsistent and increases risk when changing separator policy. We need one consistent behavior model without breaking existing posting and rendering flows.

## User stories
- As an operator, I want footer separator behavior to be controlled consistently so that policy changes do not create content drift.
- As a maintainer, I want one canonical append pathway per runtime so that future fixes happen once instead of in many files.
- As a user cloning or posting content, I want normal posting and display behavior to remain stable while the refactor is introduced.

## Core requirements
- Introduce a canonical footer-append API for each runtime path currently producing separator metadata.
- Preserve existing default behavior until explicitly changed by configuration.
- Ensure all current producer entry points can use the canonical API without changing user-facing posting flows.
- Keep backward compatibility for existing content that already includes separator footers.
- Keep the change scoped to refactoring behavior control, not full metadata storage redesign.

## Shared component inventory
- Posting entry points:
  - `store_new_comment.php` (primary post path) should become canonical for PHP-side footer append behavior.
  - `post.php` and `route.php` should reuse the canonical append pathway rather than maintaining separate append logic.
- Access-log ingestion:
  - `script/access_log_read.pl` should use the Perl-side canonical append pathway for host/footer additions.
- Publish/share fallback content:
  - `dialog/toolbox_item_publish.pl` should align with canonical separator policy instead of independent formatting.
- Display/index surfaces (compatibility constraints):
  - `item_template.pl`, `token_defs.pl`, and related welcome-page consumers must continue to handle existing separator content during rollout.

## Simple user flow
1. Operator enables or disables footer separator behavior through configuration.
2. User submits content (normal post, batch/system post, or access-log sourced post).
3. Producer path delegates separator/footer handling to canonical runtime API.
4. Item is stored/indexed and rendered through existing display paths.

## Success criteria
- All producer paths apply the same separator decision logic from canonical APIs.
- No net-new separator behavior differences between producer paths when config is unchanged.
- Separator policy can be changed in one place per runtime and observed uniformly in new items.
- Existing items with separator content still render/index correctly after the refactor.
