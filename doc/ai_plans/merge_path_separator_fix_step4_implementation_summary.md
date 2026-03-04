# Step 4 Implementation Summary: Merge-Path Separator Fix

## Stage 1 - Align merge output with canonical separator policy
- Changes:
  - Updated [file.pl](/home/wsl/pollyanna/default/template/perl/file.pl) `MergeFiles()` to stop direct `"\n-- \n"` reconstruction.
  - `MergeFiles()` now calls `AppendFooterSeparator($fileBody, $fileFooter, \%appendOptions)` with `respect_gate => 0` and `skip_if_footer_empty => 1`.
  - Added footer normalization (`trim`) before helper invocation.
- Verification:
  - Ran `rg -n "AppendFooterSeparator|fileOutContent|skip_if_footer_empty|respect_gate" default/template/perl/file.pl` and confirmed merge output now routes through the helper.
  - Ran `rg -n --fixed-strings "\\n-- \\n" default/template/perl/file.pl` and confirmed no active direct merge-output construction remains.
- Notes:
  - Merge behavior now avoids emitting bare separators when there is no footer content.
  - Gate bypass (`respect_gate => 0`) preserves merge-time footer materialization semantics for non-empty footers.
