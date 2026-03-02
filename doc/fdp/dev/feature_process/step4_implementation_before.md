# Step 4: Implementation (Before)

_Open only after the user responds "Approved Step 3."_

## Objective
Set up the Step 4 branch and lock in planning artifacts before implementation starts.

## Planning Docs Commit Gate (Required)
After `Approved Step 3` and before any implementation changes:
1. Create the Step 4 feature branch.
2. Run `git status --short` and confirm Step 1-3 planning docs are present and unstaged/unchanged as expected.
3. Commit only the approved Step 1-3 planning documents as the first commit on the branch.
4. Run `git log --oneline --max-count 1` and confirm that planning-doc commit is at `HEAD`.
5. Only then begin Stage 1 implementation.

## Next
Continue with `doc/fdp/dev/feature_process/step4_implementation_do.md`.
