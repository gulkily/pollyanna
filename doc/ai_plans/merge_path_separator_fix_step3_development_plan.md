# Step 3 Development Plan: Merge-Path Separator Fix

## Stage 1 - Align merge output with canonical separator policy
- Goal: Ensure merge/organize does not emit a bare separator when merged footer content is empty.
- Dependencies: Approved Step 2.
- Expected changes (conceptual):
  - Update merge-content construction in `file.pl` to use canonical separator decision logic.
  - Preserve existing function signatures:
    - Perl: `MergeFiles(@files)`
    - Perl: `AppendFooterSeparator($message, $footerContent, \%options)` (already present)
- Verification approach: Manual review of merge path confirms footerless merge result remains body-only; separator appears only when footer content exists.
- Risks/open questions:
  - Interaction with existing `setting/admin/footer_separator/enable` gate during merge behavior.
  - Footer trimming/normalization could alter legacy edge-case formatting.
- Canonical components/API contracts touched: `file.pl` merge path, `AppendFooterSeparator` contract.

## Stage 2 - Harden duplicate-file collision handling in organize path
- Goal: Reduce content mutation risk when organize encounters source/destination collisions.
- Dependencies: Stage 1.
- Expected changes (conceptual):
  - Refine `OrganizeFile` collision flow to clearly distinguish identical-content collisions from true merge-needed collisions.
  - Keep existing function signature:
    - Perl: `OrganizeFile($file)`
- Verification approach: Manual path review confirms collision branch only performs merge when needed and avoids unnecessary content rewrites.
- Risks/open questions:
  - Legacy datasets with mixed historical footer formats may still require merge behavior in specific collisions.
  - Collision-path changes may affect assumptions in existing maintenance scripts.
- Canonical components/API contracts touched: `OrganizeFile` in `file.pl`, merge contract expectations.

## Stage 3 - Improve observability of separator/merge decisions
- Goal: Make hash-divergence investigations easier by logging key merge/organize decisions in existing debug style.
- Dependencies: Stages 1-2.
- Expected changes (conceptual):
  - Add/standardize `WriteLog` messages for collision detection, merge invocation, and separator-emission decisions in the organize/merge path.
  - Keep existing logging interface unchanged:
    - Perl: `WriteLog($text)`
- Verification approach: Manual smoke check confirms logs contain clear decision breadcrumbs for a collision path without excessive noise.
- Risks/open questions:
  - Additional log volume in large reindex runs.
  - Need to keep messages concise to avoid obscuring higher-priority warnings.
- Canonical components/API contracts touched: `WriteLog` usage patterns, `OrganizeFile`/`MergeFiles` decision surfaces.
