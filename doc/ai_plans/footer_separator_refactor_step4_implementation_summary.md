# Step 4 Implementation Summary: Footer Separator Refactor

## Stage 1 - Add canonical helper APIs
- Changes:
  - Added `AppendFooterSeparator(...)` helper to [utils.php](/home/wsl/pollyanna/default/template/php/utils.php).
  - Added `AppendFooterSeparator(...)` helper to [utils.pl](/home/wsl/pollyanna/default/template/perl/utils.pl).
  - No producer call sites were migrated in this stage.
- Verification:
  - Ran `rg -n "AppendFooterSeparator\\s*\\(" default/template/php/utils.php default/template/perl/utils.pl` and confirmed both helper definitions exist.
  - Ran `rg -n "AppendFooterSeparator\\s*\\(" default/template/php default/template/perl | head -n 50` and confirmed only helper definitions exist (no migrated call sites yet).
- Notes:
  - Helpers expose options for separator override, trim behavior, and skip conditions so later stages can migrate call sites without duplicating logic.

## Stage 2 - Migrate primary PHP producer path
- Changes:
  - Replaced inline separator append in [store_new_comment.php](/home/wsl/pollyanna/default/template/php/store_new_comment.php) with `AppendFooterSeparator($comment, $signatureContent)`.
  - Preserved existing `skip_footer_when_pubkey` branch behavior.
- Verification:
  - Ran `rg -n "AppendFooterSeparator\\(|skip_footer_when_pubkey|signatureSeparator" default/template/php/store_new_comment.php` and confirmed helper usage plus pubkey skip branch remained.
  - Source-checked that `StoreNewComment` still gathers the same metadata fields before append.
- Notes:
  - Functional behavior remains the same when separator policy is unchanged; this stage only centralizes append mechanics.
