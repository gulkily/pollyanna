# Step 3: Development Plan (Do)

_Open only after completing Step 3 Before._

## Objective
Break the feature into atomic implementation stages, identify dependencies, and define verification expectations before coding starts.

## Deliverable
- Numbered plan (<=1 page) saved in `doc/ai_plans/`
- Filename: `{feature_name}_step3_development_plan.md`

## Structure
For each stage include:
- Goal
- Dependencies
- Expected changes (conceptual only; include database/function signature updates without implementations)
- Verification approach (manual smoke checks are sufficient)
- Risks or open questions (bullet points)
- Reminder of canonical components/API contracts that will be touched

Additional requirements:
- Stages should be about <=1 hour or <=50 lines of change; split anything larger before implementation
- Document database changes conceptually (no SQL)
- Include planned function signatures when relevant, without code

## Guardrails
- Avoid full code, HTML templates, detailed SQL, or verbose explanations
- Keep stage count manageable; if work exceeds about eight stages or a day of effort, split into separate features before moving on

## Next
After drafting the Step 3 plan document, continue with `doc/fdp/dev/feature_process/step3_development_plan_after.md`.
