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

## Stage 3 - Migrate remaining PHP producers
- Changes:
  - Replaced batch footer append in [post.php](/home/wsl/pollyanna/default/template/php/post.php) with `AppendFooterSeparator(...)`.
  - Replaced request-parameter footer append in [post.php](/home/wsl/pollyanna/default/template/php/post.php) with helper call plus `skip_if_present`.
  - Replaced system metadata separator construction in [route.php](/home/wsl/pollyanna/default/template/php/route.php) with helper-based assembly for refresh/reindex/upgrade metadata items.
- Verification:
  - Ran `rg -n --fixed-strings "\\n-- \\n" default/template/php/post.php default/template/php/route.php` and confirmed no active inline separator construction remains in those migrated paths.
  - Ran `rg -n "AppendFooterSeparator\\(" default/template/php/post.php default/template/php/route.php` and confirmed helper usage is present in all targeted call sites.
- Notes:
  - Kept existing metadata message contents intact while centralizing separator append mechanics.
