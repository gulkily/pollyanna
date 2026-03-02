# Step 4: Implementation (After)

_Open only after completing Step 4 Do._

## Objective
Run final Step 4 verification gates and prepare handoff.

## Final Verification Checklist
1. Confirm all planned stages were implemented and manually verified.
2. Confirm each completed stage has a stage-scoped commit that includes the corresponding Step 4 summary update.
3. Run `git log --oneline` and verify:
   - the first Step 4 commit is the planning-doc commit for approved Step 1-3 docs
   - commit count is not lower than `1 + number_of_stages`
4. Confirm feature behavior is accessible through normal UI/CLI flows (not only direct URLs).
5. Confirm required roles, migrations, or other dependencies are resolved.
6. Confirm documentation is updated, including the finalized Step 4 implementation summary.

## Next
Notify the user for review/handoff. If additional scope emerges, return to the appropriate earlier step instead of improvising within Step 4.
