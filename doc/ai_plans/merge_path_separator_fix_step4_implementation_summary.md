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

## Stage 2 - Harden duplicate-file collision handling in organize path
- Changes:
  - Updated [file.pl](/home/wsl/pollyanna/default/template/perl/file.pl) `OrganizeFile()` collision branch (`-e $fileHashPath`) to compare source/destination content hashes before merge.
  - When content is identical, `OrganizeFile()` now attempts to remove the duplicate source file instead of invoking `MergeFiles()`.
  - `MergeFiles()` is now only called when collision content differs.
- Verification:
  - Ran `rg -n "incomingFileHash|existingFileHash|destination already has identical content|destination content differs, calling MergeFiles" default/template/perl/file.pl` and confirmed hash-based branch separation is present.
  - Ran `rg -n "if \\(-e \\$fileHashPath\\)|MergeFiles\\(|unlink\\(\\$file\\)" default/template/perl/file.pl` and confirmed collision handling flow now distinguishes dedupe vs merge paths.
- Notes:
  - This reduces unnecessary merge rewrites for identical-content collisions while preserving merge behavior for true content conflicts.

## Stage 3 - Improve observability of separator/merge decisions
- Changes:
  - Added merge-path decision logs in [file.pl](/home/wsl/pollyanna/default/template/perl/file.pl) for normalized body/footer lengths and expected separator behavior before helper call.
  - Added explicit logs for whether merged output contains a separator after helper application.
  - Added organize collision logs for incoming/existing hash comparison, duplicate-source unlink success/failure, and merge invocation context.
- Verification:
  - Ran `rg -n "normalized lengths|helper should|output contains separator|output has no separator" default/template/perl/file.pl` and confirmed merge decision breadcrumbs are present.
  - Ran `rg -n "collision hash comparison|duplicate source file removed|calling MergeFiles\\(\\); incoming" default/template/perl/file.pl` and confirmed organize collision observability messages are present.
- Notes:
  - Logging remains aligned with existing `WriteLog` style and focuses on decision points needed for hash-divergence triage.
