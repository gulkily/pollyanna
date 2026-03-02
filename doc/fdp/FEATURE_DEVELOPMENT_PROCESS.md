# Feature Development Process

## Overview
Feature work flows through four tightly scoped steps with an optional solution assessment upfront. To keep the instructions inside the context window, the detailed guidance for each step now lives in separate files that you open only when you are ready for that step.

## How to Use This Chain
1. Start with the highest-numbered approved step (usually Step 1 unless explicitly skipped).
2. Read only the relevant instruction file in `doc/fdp/dev/feature_process/` and reprint it before starting work.
3. For Steps 3 and 4, use phase files in order: `*_before.md` -> `*_do.md` -> `*_after.md`.
4. Request approval in the format `Approved Step N` when required, and do not open the next step's files until approval is received.

## Step Guide
- **Step 1 – Solution Assessment (Optional)**: resolve uncertainty across multiple approaches. `doc/fdp/dev/feature_process/step1_solution_assessment.md`
- **Step 2 – Feature Description**: capture problem framing, user stories, requirements, and success criteria. `doc/fdp/dev/feature_process/step2_feature_description.md`
- **Step 3 – Development Plan**: break work into atomic stages with dependencies and verification notes. Start with `doc/fdp/dev/feature_process/step3_development_plan_before.md`, then follow the `do` and `after` files.
- **Step 4 – Implementation**: execute staged work on a feature branch and maintain the implementation summary. Start with `doc/fdp/dev/feature_process/step4_implementation_before.md`, then follow the `do` and `after` files.

Each phase file ends with instructions for when to proceed so you never overrun the context window.

## Planning Artifacts
Each step MUST be a separate file in `doc/ai_plans/`:
- **Step 1**: `{feature_name}_step1_solution_assessment.md`
- **Step 2**: `{feature_name}_step2_feature_description.md`
- **Step 3**: `{feature_name}_step3_development_plan.md`
- **Step 4**: `{feature_name}_step4_implementation_summary.md`

**Directory structure**: When a feature accumulates four or more planning artifacts (e.g., all Step 1–4 docs plus auxiliary notes), move them into `doc/ai_plans/{feature_name}/`. Keep smaller efforts at the root until they grow, and update `doc/ai_plans/README.md` when a new folder appears so others can navigate.

**Commit discipline**:
- Keep Step 1-3 planning documents uncommitted while they are being drafted/revised.
- Do not commit Step 1-3 planning documents when Step 1 or Step 2 is approved.
- After the user explicitly responds `Approved Step 3`, create the Step 4 feature branch.
- The first commit on that feature branch must contain only the approved Step 1-3 planning documents.
- During Step 4, each completed implementation stage must be committed with its Step 4 summary update in the same commit before starting the next stage.

**Plan review**: Do not begin Step 4 until the user explicitly responds `Approved Step 3`. The first commit after branching for Step 4 must capture the approved Step 1-3 planning files.

**Step 4 commit cadence (mandatory)**:
- Make one planning commit at the start of Step 4 containing only approved Step 1–3 docs.
- Then make at least one stage-scoped implementation commit per Step 3 stage.
- Do not start Stage `N+1` until Stage `N` has:
  - manual verification completed,
  - Step 4 summary updated for that stage,
  - a commit recorded on the branch.
- Do not squash/rebase/amend stage commits during active Step 4 execution.
- Expected minimum commit count by end of Step 4: `1 + (# of Step 3 stages)`.

## Key Rules

**AI coding assistant**
- Recommend Step 1 for complex features or whenever multiple solutions exist
- Stay in the current step; do not draft/edit later deliverables without approval
- After delivering each step, explicitly request “Approved Step N” and pause until the user responds with that exact phrase
- Create separate files for each step only after receiving the relevant approval
- ALWAYS create a feature branch before Step 4 implementation
- Enforce Step 4 commit cadence: first Step 4 commit contains approved Step 1-3 planning docs; each completed stage has a stage-scoped commit that includes the Step 4 summary update
- Prefer shared components/API contracts first; reuse or extend instead of forking markup, CSS, or payloads
- Flag scope creep early and bounce back to planning steps rather than improvising mid-implementation
- Keep projected work within roughly a day or eight Step 3 stages; otherwise recommend splitting the feature
- Avoid database schema changes when possible—lean on existing models/fields
- Reprint the current step/phase instructions (from the linked file) before you begin that work

**User**
- Review and approve explicitly at each step
- Flag issues early so adjustments happen before implementation
- Resist adding scope during Step 4
- Prefer solutions that avoid database migrations; rely on existing schema where feasible

## Warning Signs
- **Step 1**: >1 page, >4 options, or verbose explanations
- **Step 2**: >1 page, includes code/DB details, or drifts into UI mockups
- **Step 3**: >1 page, stages >2 hours, or tangled dependencies
- **Step 4**: Missing feature branch, missing initial Step 1-3 planning-doc commit, skipping stages, changing requirements mid-flight, a stage without a stage-scoped commit + summary update, or commit count lower than `1 + stage count`

## Workflows
- **Simple**: Step 2 → Step 3 → Step 4 (feature branch → implement stages → test/commit → complete)
- **Complex**: Step 1 (solution assessment) → Step 2 → Step 3 → Step 4
