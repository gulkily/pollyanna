# Step 2: Feature Description

_Open this only after receiving “Approved Step 1” (or if Step 1 was skipped). Pause again after delivering Step 2 until the user sends “Approved Step 2.”_

## Objective
Capture the problem framing, desired outcomes, and shared-component considerations before planning implementation work.

## Deliverable
- Concise doc (≤1 page) stored in `doc/ai_plans/`
- Filename: `{feature_name}_step2_feature_description.md`

## Structure
- Problem: 1–2 sentences
- User stories: bullet list in the format “As [role], I want [goal] so that [benefit]”
- Core requirements: 3–5 bullets capturing non-negotiable behaviors
- Shared component inventory: enumerate every existing UI/API surface that already renders the data; specify whether the feature reuses/extends the canonical component or needs a new one (with rationale)
- Simple user flow: numbered steps
- Success criteria: measurable outcomes that confirm the feature solves the problem

## Guardrails
- Avoid implementation details, code, database schema, UI mockups, or verbose descriptions
- Keep the doc lightweight enough to consume at a glance

## Next
Deliver the document, request confirmation, and wait for "Approved Step 2." Once approved, continue with `doc/fdp/dev/feature_process/step3_development_plan_before.md`.
