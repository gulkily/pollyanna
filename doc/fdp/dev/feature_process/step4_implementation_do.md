# Step 4: Implementation (Do)

_Open only after completing Step 4 Before._

## Objective
Execute the plan in atomic stages on a dedicated feature branch, documenting progress and verification as you go.

## Execution Rules
- Work stages sequentially, keeping each stage <2 hours
- Favor the simplest viable implementation first; iterate only when necessary
- Before adding new presentation markup or API payloads, confirm whether a canonical component/contract already exists per the Step 2 inventory and reuse/extend instead of duplicating
- Require one stage-scoped commit per completed stage; do not batch multiple stages into one commit
- Commit code plus the Step 4 summary update for that stage in the same commit before beginning the next stage

## Stage Boundary Protocol (Required)
At every stage boundary (including Stage 1), complete this sequence before starting the next stage:
1. Finish implementation scope for the current stage only.
2. Run manual smoke verification for that stage and capture commands/results in the Step 4 summary.
3. Update the current stage section in `{feature_name}_step4_implementation_summary.md`.
4. Run `git status --short` and confirm only intended files are included.
5. Commit with a stage-scoped message (example: `feat(stage 3): add rerun-safe historical write path`).
6. Run `git log --oneline --max-count 5` and confirm the new stage commit is present.
7. Only then begin the next stage.

## Implementation Summary Artifact
- Location: `doc/ai_plans/`
- Filename: `{feature_name}_step4_implementation_summary.md`
- Contents per stage:
  - Stage number/name
  - Changes shipped
  - Verification performed (manual steps)
  - Notes/risks

_Template_
```markdown
## Stage X - {title}
- Changes:
- Verification:
- Notes:
```

## Next
After all planned stages are implemented and committed, continue with `doc/fdp/dev/feature_process/step4_implementation_after.md`.
