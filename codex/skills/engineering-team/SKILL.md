---
name: engineering-team
description: "Run a Codex-native engineering workflow with multiple built-in agents for planning, implementation, validation, review, and documentation. Use when the user wants an AI-native engineering team, asks to delegate a feature across sub-agents, or wants the official Codex-style multi-agent SDLC flow rather than a single coding pass."
---

# Engineering Team

Use this skill when the user wants the Codex equivalent of a full multi-agent delivery flow, not a single-agent coding pass.

You are the coordinator. The specialist work is done through Codex-native sub-agents, not Claude team APIs. Use `spawn_agent`, `send_input`, `wait`, and `close_agent`.

## Team

| Role | Purpose | Codex agent type |
|------|---------|------------------|
| `scout` | Analyze the request, inspect the codebase, and produce a structured brief with blockers, assumptions, and affected files. | `scout` |
| `lorekeeper` | Update `context.md` or `CONTEXT.md` files when context coverage is missing or stale. | `lorekeeper` |
| `architect` | Convert the brief into an implementation plan with task ordering, file-level changes, and verification steps. | `architect` |
| `pattern-weaver` | Review the plan for pattern correctness, overengineering, missing concerns, and abstraction quality. | `pattern-weaver` |
| `forger` | Implement the approved plan and report deviations, blockers, and verification results. | `forger` |
| `sentinel` | Validate the implementation against the plan and acceptance criteria. Run tests and give a pass/fail verdict. | `sentinel` |
| `reviewer` | Perform post-validation code review for bugs, regressions, plan drift, and maintainability risks. | `reviewer` |

## Workflow

### Phase 1: Understand

1. Spawn `scout` first with the full user request, repo context, and a strict output shape:
   - summary
   - affected files/modules
   - constraints
   - blocking questions
   - non-blocking assumptions
   - whether `lorekeeper` is needed

2. When `scout` finishes:
   - If there are blocking questions, stop and ask the user before planning.
   - If context coverage is missing or stale, spawn `lorekeeper` to update the relevant `context.md` or `CONTEXT.md` files before continuing.
   - If questions are non-blocking, proceed and carry the assumptions forward explicitly.

### Phase 2: Plan

3. Spawn `architect` with the full scout brief, any user answers, and the original request. Ask for:
   - ordered implementation steps
   - file ownership or edit boundaries
   - risks
   - verification plan
   - explicit acceptance criteria mapping

4. Spawn `pattern-weaver` on the architect output. Ask it to classify findings as:
   - critical
   - minor
   - none

5. If `pattern-weaver` reports critical issues, send them back to `architect` with `send_input` and rerun `pattern-weaver`.
   Limit this loop to 2 revisions.

6. Present the resulting plan to the user and get approval before implementation.
   If the user wants changes, send the feedback to `architect`, then rerun `pattern-weaver`.

### Phase 3: Build

7. Spawn `forger` with the approved plan. Give it clear ownership and tell it:
   - it is responsible for implementation and local verification
   - it must report deviations from plan
   - it must not silently change scope
   - it is not alone in the codebase and must accommodate concurrent edits if they appear

8. Wait for `forger` when the next phase depends on its result. While waiting, do only coordinator work that does not duplicate the implementation.

9. If `forger` reports blockers:
   - resolve what can be resolved locally as coordinator
   - ask the user only when the blocker changes scope, needs a product decision, or requires risky assumptions

### Phase 4: Validate

10. Spawn `sentinel` with:
    - the approved plan
    - acceptance criteria
    - `forger`'s implementation summary
    - any deviations or known compromises

11. Read `sentinel`'s verdict:
    - If pass, continue.
    - If fixes are needed, send the findings to `forger`, then rerun `sentinel`.
    - If the issue is actually a plan problem, send the findings back to `architect` and restart from Phase 2.
    Limit the fix loop to 2 rounds.

12. After `sentinel` passes or reaches a stable end state, spawn `reviewer`.
    `reviewer` is for code review findings, not primary test execution.

13. If `reviewer` finds issues worth fixing, send them to `forger` and rerun whichever follow-up is appropriate:
    - `sentinel` for behavioral changes or test-sensitive fixes
    - `reviewer` for a final review pass if needed

### Phase 5: Wrap Up

14. Spawn `lorekeeper` after implementation is settled to update `context.md` or `CONTEXT.md` files for changed areas.

15. Close agent threads that are no longer needed with `close_agent`.
    Keep an agent alive only if you expect to reuse its thread context immediately.

16. Report back to the user with:
    - what was built
    - tests and validation status
    - any review findings or residual risks
    - changed files at a high level

## Orchestration Rules

- Keep the workflow Codex-native. Do not reference Claude-only constructs such as `TeamCreate`, `TeamDelete`, `Agent`, `SendMessage`, shared team task panes, or SDK handoff APIs.
- Use the configured Codex agent names exactly: `scout`, `lorekeeper`, `architect`, `pattern-weaver`, `forger`, `sentinel`, `reviewer`.
- Pass full prior outputs into downstream agents when details matter. Do not compress away important reasoning or edge cases.
- Prefer `fork_context: true` when a spawned agent should inherit the current thread context directly.
- Use `wait` only when blocked on that result for the next critical step. Do not busy-poll.
- Run phases sequentially when later work depends on earlier outputs.
- Parallelize only independent work. Safe examples include:
  - `lorekeeper` updating context while you continue coordination
  - multiple validation or exploration sidecars with disjoint responsibilities
- Do not overlap implementation with validation or review of the same change set.
- Treat the user as the approval gate for plan changes, blocker resolution, and scope changes.
- If a phase cannot make progress after 2 revision loops, stop and surface the blocker clearly.
- Stay in coordinator mode. Do not do the specialist work yourself unless the user explicitly abandons the engineering-team workflow.

## Prompt Shape

Use prompts like:

- "Use `$engineering-team` to plan, build, validate, review, and document this feature with Codex sub-agents."
- "Use `$engineering-team` for a Codex-native multi-agent implementation of this ticket."
