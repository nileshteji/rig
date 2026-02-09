---
name: implement-plan
description: Execute a user-approved implementation plan end-to-end by translating plan steps into concrete code changes, tests, and status updates. Use when the user asks to implement a plan, execute planned tasks, carry out roadmap items, or convert a checklist/spec into completed work.
---

# Implement Plan

Execute this workflow to turn an approved plan into completed, verified changes.

## 1. Confirm scope

- Restate the exact plan items to implement.
- Confirm completion bar: code only, code plus tests, or code plus tests plus docs.
- If details are missing, choose the smallest safe interpretation and proceed.

## 2. Build execution map

- Convert plan items into atomic engineering tasks.
- Order tasks by dependency.
- Define a verification command per task before editing.

## 3. Implement incrementally

- Make focused edits per task.
- Preserve existing architecture and module boundaries.
- Place new files in structured packages/modules with domain-specific names that match the target stack's conventions (for example, Android package naming for Android code and TypeScript package/module naming for TypeScript code).
- If you create a new package/module directory, add a `context.md` file in that directory with a one-line responsibility summary for each file in the package.
- Introduce backward-compatible defaults for new flags or fields.

## 4. Verify continuously

- Run the smallest meaningful checks after each task.
- Fix regressions before moving to the next task.
- Record what was validated and what could not be validated.

## 5. Report completion

- Mark each original plan item as done, partial, or blocked.
- Summarize changed files and rationale.
- Note residual risks and concrete follow-up actions.

## Heuristics

- Prefer a fully verified subset over a broad, partially verified implementation.
- Choose the lowest-blast-radius approach when multiple valid implementations exist.
- Keep rollback simple by avoiding unnecessary refactors.
