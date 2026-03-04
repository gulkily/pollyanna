# Step 3 Development Plan: Footer Separator Refactor

## Stage 1 - Add canonical helper APIs (no call-site migration yet)
- Goal: Introduce one footer-append helper per runtime as the canonical contract.
- Dependencies: Approved Step 2.
- Expected changes (conceptual):
  - Add PHP helper(s) in `default/template/php/utils.php`.
  - Add Perl helper(s) in `default/template/perl/utils.pl`.
  - Planned signatures:
    - PHP: `AppendFooterSeparator($message, $footerContent, $options = array())`
    - Perl: `AppendFooterSeparator($message, $footerContent, \%options)`
- Verification approach: Confirm helpers exist, are referenced in docs/comments, and no producer behavior changes yet.
- Risks/open questions:
  - Option parameter shape drift between PHP and Perl.
  - Naming collisions with existing utility functions.
- Canonical components/API contracts touched: `utils.php`, `utils.pl`.

## Stage 2 - Migrate primary PHP producer path to helper
- Goal: Make `store_new_comment.php` use canonical helper instead of inline separator append logic.
- Dependencies: Stage 1.
- Expected changes (conceptual):
  - Replace direct `"\n-- \n"` append logic with helper call.
  - Keep existing metadata collection (`Authorization/Cookie/Received/Client/Host/Hash`) behavior intact.
- Verification approach: Compare pre/post logic flow in `StoreNewComment` and ensure no functional branches were removed.
- Risks/open questions:
  - Pubkey skip path (`skip_footer_when_pubkey`) interaction with helper options.
  - Whitespace/trim behavior changing effective output.
- Canonical components/API contracts touched: `store_new_comment.php`, PHP helper contract.

## Stage 3 - Migrate remaining PHP producers to helper
- Goal: Remove scattered PHP append logic from `post.php` and `route.php`.
- Dependencies: Stage 2.
- Expected changes (conceptual):
  - Batch tag footer and parameter footer paths in `post.php` call helper.
  - System metadata messages in `route.php` use helper or canonical formatter path.
- Verification approach: Ensure PHP producers no longer manually construct separator append behavior except intentionally literal message content.
- Risks/open questions:
  - `route.php` system message formatting may be interpreted as content rather than metadata.
  - Batch mode edge cases when footer already exists.
- Canonical components/API contracts touched: `post.php`, `route.php`, PHP helper contract.

## Stage 4 - Migrate Perl producers to helper
- Goal: Align Perl producer behavior with the same canonical append policy.
- Dependencies: Stage 1.
- Expected changes (conceptual):
  - `script/access_log_read.pl` host footer append uses Perl helper.
  - `dialog/toolbox_item_publish.pl` fallback metadata formatting uses Perl helper/formatter path.
- Verification approach: Confirm direct separator append logic is removed/reduced in Perl producer paths.
- Risks/open questions:
  - Publish fallback may need distinct formatting guarantees for interoperability.
  - Access log ingestion might rely on current exact string shape.
- Canonical components/API contracts touched: `access_log_read.pl`, `toolbox_item_publish.pl`, Perl helper contract.

## Stage 5 - Introduce global separator feature gate
- Goal: Add a single configuration switch governing separator production.
- Dependencies: Stages 2-4.
- Expected changes (conceptual):
  - Add `default/setting/admin/footer_separator/enable` (default `1`).
  - Helper APIs become sole place that evaluates the gate.
- Verification approach: Static review confirms producer paths delegate gate decisions to helper only.
- Risks/open questions:
  - Ambiguity about behavior when gate is off and footer content exists.
  - Potential mismatch with existing per-feature logging flags.
- Canonical components/API contracts touched: new setting file, helper contracts, producer call sites.

## Stage 6 - Documentation and rollout notes
- Goal: Document behavior and operator controls for safe rollout.
- Dependencies: Stage 5.
- Expected changes (conceptual):
  - Update `doc/settings.md` with new setting and semantics.
  - Add migration note describing backward compatibility for existing separator content.
- Verification approach: Documentation references match implemented helper/gate behavior and file paths.
- Risks/open questions:
  - Docs drifting from final implementation details if staged commits diverge.
- Canonical components/API contracts touched: `doc/settings.md`, relevant AI plan docs.
