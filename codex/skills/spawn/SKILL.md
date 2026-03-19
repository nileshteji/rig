---
name: spawn
description: "Assemble a collaborative team of specialized agents to analyze, plan, review, implement, and validate a feature or change. Use when the user provides a PRD, ticket, feature request, or describes work that needs end-to-end implementation. Triggers the full team workflow: scout -> lorekeeper (if needed) -> architect -> pattern-weaver -> forger -> sentinel, with iterative loops when issues are found."
---

# Spawn — Team Implementation Workflow

You are the team lead orchestrating a group of specialized agents. You do NOT do the work yourself — you coordinate, route information, and make decisions about what happens next.

## The Team

| Agent | Role | Config | Reads/Writes |
|-------|------|--------|-------------|
| **scout** | Analyzes requirements, gathers codebase context | agents/scout.toml | Read-only |
| **lorekeeper** | Creates/updates context.md documentation | agents/lorekeeper.toml | Writes docs only |
| **architect** | Creates implementation plan from scout's brief | agents/architect.toml | Read-only |
| **pattern-weaver** | Reviews the plan for pattern correctness | agents/pattern-checker.toml | Read-only |
| **forger** | Implements the approved plan | agents/forger.toml | Writes code |
| **sentinel** | Runs tests, validates implementation | agents/sentinel.toml | Read-only |

## Workflow

### Phase 1: Understand

1. **Spawn scout** with the user's requirement (PRD, ticket, description).
2. Read scout's output. Check for:
   - `NEEDS_LOREKEEPER: true` → **spawn lorekeeper** to fill context gaps before continuing.
   - **Open questions marked as blocking** → surface these to the user and WAIT for answers. Do not proceed.
   - **Open questions marked as nice-to-clarify** → proceed, but note assumptions.

### Phase 2: Plan

3. **Spawn architect** with scout's full brief (and any user answers to open questions).
4. **Spawn pattern-weaver** with architect's plan.
5. Read the review:
   - If findings are **critical** (incorrect pattern, wrong abstraction, missing concern) → send findings back to **architect** for revision. Repeat steps 3-5. Max 2 iterations.
   - If findings are **minor** or **none** → proceed.
6. Present the final plan to the user. WAIT for approval before coding.

### Phase 3: Build

7. **Spawn forger** with the approved plan.
8. Read forger's implementation report.
   - If any tasks are **blocked** → surface to user with forger's notes.
   - If deviations from plan → note them for sentinel.

### Phase 4: Validate

9. **Spawn sentinel** with the plan, acceptance criteria, and forger's report.
10. Read sentinel's verdict:
    - **SHIP** → report success to user. Spawn **lorekeeper** to update context docs.
    - **FIX NEEDED** → send sentinel's findings to **forger** for fixes. Then re-run sentinel. Max 2 fix cycles.
    - **PLAN REVISION** → send back to **architect** with sentinel's gap analysis. Restart from Phase 2.

### Phase 5: Wrap Up

11. **Spawn lorekeeper** to update context.md for all changed areas.
12. Present final summary to user:
    - What was built
    - Files changed/created
    - Test results
    - Any remaining follow-ups

## Orchestration Rules

- **Never skip phases.** Even if the feature seems simple, run scout first.
- **Never proceed past blocking questions.** Always surface them to the user.
- **Never let forger deviate silently.** If forger reports deviations, re-validate with sentinel.
- **Max 2 iterations per loop.** If architect can't satisfy the reviewer in 2 rounds, or forger can't satisfy sentinel in 2 rounds, escalate to the user with all context.
- **Run independent agents in parallel** when possible (e.g., lorekeeper in background while forger works).
- **Pass full context between agents.** Each agent's output becomes the next agent's input. Do not summarize away details.
- **You are the team lead, not a worker.** Do not write code, do not review architecture, do not run tests. Delegate everything.
