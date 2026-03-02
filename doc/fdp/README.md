# Feature Development Process (FDP)

This repo packages a lightweight but strict workflow you can hand to Claude Code, GitHub Copilot, or Codex when they keep wandering off while you try to deliver a real feature. The files here explain _exactly_ how to scope work, gather approvals, and move through implementation without blowing the context window or letting the assistant improvise.

## Why use this?
- Keeps multi-step feature work inside the model context window by splitting guidance across files.
- Forces approvals between steps so the assistant cannot sprint ahead without human review.
- Encourages reuse of shared UI/API components instead of letting the AI fork markup or payloads.
- Limits plan bloat so every deliverable stays within a page and can be reviewed quickly.

If you frequently see Claude/Codex derail because requirements evolve mid-stream, treat this repo as the “rails” that keep both you and the assistant honest.

## Repo layout
- `FEATURE_DEVELOPMENT_PROCESS.md` – one-page overview of the entire chain plus key rules and warning signs.
- `doc/fdp/dev/feature_process/` – canonical instructions for each step. The assistant reprints these every time it advances.
  - `step1_solution_assessment.md`
  - `step2_feature_description.md`
  - `step3_development_plan_before.md`, `step3_development_plan_do.md`, `step3_development_plan_after.md`
  - `step4_implementation_before.md`, `step4_implementation_do.md`, `step4_implementation_after.md`
  - `step3_development_plan.md`, `step4_implementation.md` (compatibility entrypoints)
- `doc/ai_plans/` (create per feature) – where you store the working artifacts: `{feature}_stepN_*.md` plus any auxiliary research. Move large efforts into `doc/ai_plans/{feature}/` and update a local README for navigation.

## Reusing across projects (recommended)
Use this repo as the single source of truth and sync it into each project with `git subtree`.

One-time in a consuming project:
```bash
git remote add fdp <fdp-repo-url>
git subtree add --prefix=doc/fdp fdp main --squash
```

Update later:
```bash
git fetch fdp
git subtree pull --prefix=doc/fdp fdp main --squash
```

This keeps each project self-contained (no submodule workflow) while still letting you pull upstream FDP updates.

## How to run the chain with your AI pair
1. Kick things off with a plain request like `As a user, I would like to <story>, please write Step 1 of FEATURE_DEVELOPMENT_PROCESS.md.` Make the story explicit so the assistant starts from the user’s perspective.
2. Let the assistant draft the artifact in `doc/ai_plans/`, then review/edit it directly or issue follow-up instructions until you’re satisfied.
3. When the doc hits the bar, reply verbatim with `Approved Step N, please continue to Step N+1.` The bot must stop until that phrase arrives, so you control scope creep.
4. Repeat the review/approval loop for each step. Keep Step 1-3 planning docs uncommitted through drafting/review.
5. After `Approved Step 3`, create the Step 4 feature branch and make the first commit with only the approved Step 1-3 docs.
6. During Step 4, make at least one stage-scoped commit per implemented stage, and include that stage's Step 4 summary update in the same commit.

The strict per-step files mean you always paste a small, targeted instruction block into the chat; no more scrolling through a 4k-token mega-brief.

## What each step enforces
| Step | Goal | Key outputs |
| --- | --- | --- |
| Step 1 – Solution Assessment (optional) | Resolve ambiguity across competing approaches. | ≤1-page pros/cons doc ending with a recommendation. |
| Step 2 – Feature Description | Nail down problem context, user stories, requirements, shared components, and success criteria. | `{feature}_step2_feature_description.md` |
| Step 3 – Development Plan | Break work into atomic stages with dependencies, verification notes, and component touchpoints. | `{feature}_step3_development_plan.md` |
| Step 4 – Implementation | Execute stages sequentially on a feature branch, logging verification in a Step 4 summary. | `{feature}_step4_implementation_summary.md` |

Each step/phase file lists guardrails plus "Next" instructions so the model always knows when to stop.

## Tips for stubborn assistants
- **Reprint instructions**: before starting a step/phase, force the assistant to paste the relevant `doc/fdp/dev/feature_process/stepX...` file back to you. This keeps both sides aligned and provides an audit trail.
- **Call out warning signs early**: if a stage threatens to exceed the one-page or ~1-hour limit, bounce back to Step 2/3 instead of winging it mid-implementation.
- **Shared component inventory**: Step 2 explicitly asks which canonical UI/API bits already exist. Reuse them; duplication is the fastest way models drift.
- **Manual verification only**: Step 4 leans on quick smoke tests. If you need deeper coverage, capture that as a new feature request and restart the chain.

## Extending the process
- Need a domain-specific checklist? Fork one of the step files, add the extra bullets, and point your assistant to the customized version.
- Supporting artifacts (mockups, DB diagrams) belong beside the step docs in `doc/ai_plans/{feature}/`. Reference them inside the deliverables but keep the main files concise.
- When a feature balloons past eight stages, spin up a new feature name with its own Step 2/3 docs to keep things reviewable.

## Getting help
Because every instruction lives in plain Markdown, you can diff tweaks, annotate lines for your assistant, or even inline reminders like “STOP after this file.” When in doubt, start from `FEATURE_DEVELOPMENT_PROCESS.md` and follow the breadcrumbs.
