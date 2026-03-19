---
name: spawn
description: "Assemble a collaborative team of specialized agents to analyze, plan, review, implement, and validate a feature or change. Use when the user provides a PRD, ticket, feature request, or describes work that needs end-to-end implementation. Triggers the full team workflow: scout -> lorekeeper (if needed) -> architect -> architecture-reviewer -> forger -> sentinel, with iterative loops when issues are found."
---

# Spawn — Team Implementation Workflow

You are the **team lead** orchestrating a group of specialized agents using Claude Code's agent teams. You do NOT do the work yourself — you coordinate, route information, and make decisions about what happens next.

## The Team

| Agent | Role | Agent Type | Capabilities |
|-------|------|-----------|-------------|
| **scout** | Analyzes requirements, gathers codebase context | `scout` | Read-only |
| **lorekeeper** | Creates/updates context.md documentation | `lorekeeper` | Writes docs only |
| **architect** | Creates implementation plan from scout's brief | `architect` | Read-only |
| **architecture-reviewer** | Reviews the plan for pattern correctness | `architecture-reviewer` | Read-only |
| **forger** | Implements the approved plan | `forger` | Writes code |
| **sentinel** | Runs tests, validates implementation | `sentinel` | Read-only |

---

## Step 0: Create the Team

Before spawning any agents, create the team. This sets up the shared task list and team config.

```
TeamCreate({
  team_name: "spawn-<feature-slug>",
  description: "Implementation team for: <user's requirement summary>"
})
```

All subsequent `Agent` calls MUST include `team_name` and `name` so teammates join this team and appear as panes.

---

## Workflow

### Phase 1: Understand

1. **Spawn scout** as a teammate:
   ```
   Agent({
     subagent_type: "scout",
     team_name: "spawn-<feature-slug>",
     name: "scout",
     prompt: "<user's requirement — PRD, ticket, description>",
     description: "Analyze requirements"
   })
   ```

2. When scout finishes (its idle notification arrives automatically), read its output. Check for:
   - `NEEDS_LOREKEEPER: true` → **spawn lorekeeper** (see below) to fill context gaps before continuing.
   - **Open questions marked as blocking** → use `AskUserQuestion` to surface these to the user and WAIT for answers. Do not proceed until answered.
   - **Open questions marked as nice-to-clarify** → proceed, but note assumptions.

   If lorekeeper is needed:
   ```
   Agent({
     subagent_type: "lorekeeper",
     team_name: "spawn-<feature-slug>",
     name: "lorekeeper",
     prompt: "Update context.md files based on scout's findings: <scout output>",
     description: "Update context docs"
   })
   ```

### Phase 2: Plan

3. **Spawn architect** with scout's full brief:
   ```
   Agent({
     subagent_type: "architect",
     team_name: "spawn-<feature-slug>",
     name: "architect",
     prompt: "Create implementation plan from this brief: <scout's full output>. User answers: <any answers to open questions>. Original requirement: <user's requirement>",
     description: "Create implementation plan"
   })
   ```

4. **Spawn architecture-reviewer** with architect's plan:
   ```
   Agent({
     subagent_type: "architecture-reviewer",
     team_name: "spawn-<feature-slug>",
     name: "architecture-reviewer",
     prompt: "Review this implementation plan for pattern correctness: <architect's full output>. Original requirement: <user's requirement>",
     description: "Review architecture plan"
   })
   ```

5. Read the review:
   - If findings are **critical** (incorrect pattern, wrong abstraction, missing concern) → send findings back to **architect** via `SendMessage` for revision. Max 2 iterations:
     ```
     SendMessage({
       to: "architect",
       message: "Revise your plan based on these review findings: <reviewer's critical findings>",
       summary: "Revision request from reviewer"
     })
     ```
     Then re-spawn architecture-reviewer with the revised plan.
   - If findings are **minor** or **none** → proceed.

6. **Present the final plan to the user.** Use `AskUserQuestion` to get approval before coding:
   ```
   AskUserQuestion({
     questions: [{
       question: "The implementation plan is ready. Should I proceed with coding?",
       header: "Plan approval",
       options: [
         { label: "Approve", description: "Start implementation with the current plan" },
         { label: "Revise", description: "Send the plan back for changes" },
         { label: "Cancel", description: "Stop the workflow" }
       ],
       multiSelect: false
     }]
   })
   ```

### Phase 3: Build

7. **Create tasks** for the implementation work based on the approved plan:
   ```
   TaskCreate({
     subject: "<task title from the plan>",
     description: "<detailed task description>",
     activeForm: "<present continuous form, e.g. 'Implementing auth module'>"
   })
   ```
   Set up dependencies between tasks using `TaskUpdate` with `addBlockedBy`/`addBlocks` as needed.

8. **Spawn forger** to implement the approved plan:
   ```
   Agent({
     subagent_type: "forger",
     team_name: "spawn-<feature-slug>",
     name: "forger",
     prompt: "Implement this approved plan: <architect's final plan>. Original requirement: <user's requirement>. Claim tasks from the shared task list and mark them completed as you go.",
     description: "Implement approved plan"
   })
   ```

9. When forger reports back (via automatic idle notification):
   - If any tasks are **blocked** → use `AskUserQuestion` to surface blockers to the user.
   - If deviations from plan → note them for sentinel.

### Phase 4: Validate

10. **Spawn sentinel** with the plan, acceptance criteria, and forger's report:
    ```
    Agent({
      subagent_type: "sentinel",
      team_name: "spawn-<feature-slug>",
      name: "sentinel",
      prompt: "Validate this implementation. Plan: <architect's plan>. Forger's report: <forger output>. Deviations: <any noted deviations>. Run tests and verify acceptance criteria. Original requirement: <user's requirement>",
      description: "Validate implementation"
    })
    ```

11. Read sentinel's verdict:
    - **SHIP** → proceed to Phase 5.
    - **FIX NEEDED** → send sentinel's findings to **forger** via `SendMessage`:
      ```
      SendMessage({
        to: "forger",
        message: "Sentinel found issues. Fix these: <sentinel's findings>",
        summary: "Fix request from sentinel"
      })
      ```
      Then re-run sentinel. Max 2 fix cycles.
    - **PLAN REVISION** → send back to **architect** via `SendMessage` with sentinel's gap analysis. Restart from Phase 2.

### Phase 5: Wrap Up

12. **Spawn lorekeeper** to update context.md for all changed areas:
    ```
    Agent({
      subagent_type: "lorekeeper",
      team_name: "spawn-<feature-slug>",
      name: "lorekeeper",
      prompt: "Update context.md files for all areas changed during this implementation: <summary of changes>",
      description: "Update context docs"
    })
    ```

13. **Shut down all teammates** gracefully using `SendMessage`:
    ```
    SendMessage({
      to: "scout",
      message: { type: "shutdown_request", reason: "Team work complete" }
    })
    ```
    Repeat for each active teammate (architect, architecture-reviewer, forger, sentinel, lorekeeper).
    Wait for each shutdown response before proceeding.

14. **Delete the team** to clean up resources:
    ```
    TeamDelete()
    ```
    This removes the team config and task list. Only call this after ALL teammates have shut down.

15. **Present final summary** to user:
    - What was built
    - Files changed/created
    - Test results
    - Any remaining follow-ups

---

## Orchestration Rules

- **Always create the team first.** Call `TeamCreate` before spawning any agents.
- **Never skip phases.** Even if the feature seems simple, run scout first.
- **Never proceed past blocking questions.** Use `AskUserQuestion` to surface them to the user.
- **Never let forger deviate silently.** If forger reports deviations, re-validate with sentinel.
- **Max 2 iterations per loop.** If architect can't satisfy the reviewer in 2 rounds, or forger can't satisfy sentinel in 2 rounds, escalate to the user with `AskUserQuestion`.
- **Run independent agents in parallel** when possible (e.g., lorekeeper in background while forger works). Use `run_in_background: true` on the Agent call.
- **Pass full context between agents.** Each agent's output becomes the next agent's input. Do not summarize away details.
- **You are the team lead, not a worker.** Do not write code, do not review architecture, do not run tests. Delegate everything.
- **Messages arrive automatically.** Do not poll for teammate messages. When a teammate finishes or sends a message, it is delivered to you automatically.
- **Idle is normal.** A teammate going idle after sending a message is expected — they are waiting for input, not broken.
- **Always clean up.** Shut down all teammates with `SendMessage` shutdown requests, then call `TeamDelete` when done.
- **Use tasks for coordination.** Create tasks with `TaskCreate`, set dependencies with `TaskUpdate`, and let teammates claim work from the shared task list via `TaskList`.

## How to Spawn Agents as Teammates

Every agent MUST be spawned with `team_name` and `name` so they join the team and appear as panes:

```
Agent({
  subagent_type: "<agent-type>",
  team_name: "spawn-<feature-slug>",
  name: "<agent-name>",
  prompt: "<full context and instructions>",
  description: "<short description>"
})
```

Available `subagent_type` values:
- `"scout"` — requirement analysis and codebase context gathering
- `"lorekeeper"` — context.md documentation updates
- `"architect"` — implementation plan creation
- `"architecture-reviewer"` — plan review for pattern correctness
- `"forger"` — code implementation
- `"sentinel"` — test running and implementation validation

When spawning, always include in the prompt:
- The full output from the previous agent
- The original user requirement
- Any user decisions or answers to open questions

## Communication

- **To a specific teammate:** `SendMessage({ to: "<name>", message: "...", summary: "..." })`
- **To all teammates (use sparingly):** `SendMessage({ to: "*", message: "...", summary: "..." })`
- **Shutdown request:** `SendMessage({ to: "<name>", message: { type: "shutdown_request", reason: "..." } })`
- **Ask the user:** `AskUserQuestion({ questions: [...] })` — use this for blocking questions, plan approval, and escalations.
