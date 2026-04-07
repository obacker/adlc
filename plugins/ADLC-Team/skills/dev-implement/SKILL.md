---
name: dev-implement
description: "Pick up tasks, plan parallel execution, manage implementation progress. Trigger: 'start implementing', 'pick up tasks for [FEAT-ID]', 'what's next', 'create issues for spec'. This is the bridge between BA spec work and actual coding."
---

<context>
You orchestrate implementation work. You turn approved task breakdowns into GitHub Issues, plan execution order, spawn dev-agents for implementation, and track progress across sessions.
</context>

<instructions>

## Step 0 — Guard: verify readiness

Before creating issues or starting implementation:
```bash
# Check spec status
gh issue view [SPEC_ISSUE] --json labels --jq '.labels[].name' | grep -q "adlc:tasks-ready"
```
If not `adlc:tasks-ready`, stop: "Tasks not ready. Check with BA."

## Step 1 — Load state

Read:
- `.sdlc/tasks/[FEAT-ID]/slice-plan.md` — execution plan
- `.sdlc/tasks/[FEAT-ID]/task-*.md` — task details
- `.sdlc/_active/[FEAT-ID].progress.md` — resume point (if continuing)
- `.sdlc/verification.yml` — verification gates

## Step 2 — Create GitHub Issues (if not yet created)

For each task file without a corresponding issue:
```bash
gh issue create \
  --title "[FEAT-ID]-T[NNN]: [title]" \
  --body-file .sdlc/tasks/[FEAT-ID]/task-[NNN].md \
  --label "adlc:task,adlc:ready" \
  --project [PROJECT_NUMBER]
```

Record issue numbers in progress file.

## Step 3 — Plan execution

Based on slice-plan.md:
1. Identify tasks with no unmet dependencies → can start now
2. Among those, identify which can run in parallel
3. Present execution plan to user:
   ```
   **Next up:**
   - T001 (simple, no deps) — can start now
   - T002 (moderate, no deps) — can start in parallel with T001
   - T003 (moderate, depends on T001) — after T001 completes
   ```

## Step 4 — Start implementation

When user confirms, for each task to implement:

1. Update issue status:
   ```bash
   gh issue edit [TASK_ISSUE] --remove-label "adlc:ready" --add-label "adlc:in-progress"
   ```

2. Create feature branch:
   ```bash
   git checkout -b agent/[FEAT-ID]-[task-slug]
   ```

3. Spawn dev-agent for the task (with worktree isolation):
   - Pass: task file content, spec ACs, verification commands
   - dev-agent runs TDD cycle autonomously
   - On completion, dev-agent reports status (DONE/BLOCKED/NEEDS_CONTEXT)

4. Post audit comment:
   ```bash
   gh issue comment [TASK_ISSUE] --body "## DEV: Implementation started — [FEAT-ID]-T[NNN]
   **Branch:** agent/[FEAT-ID]-[task-slug]
   **Agent:** dev-agent (sonnet, worktree)
   **Status:** In Progress"
   ```

## Step 5 — Handle completion

On dev-agent DONE:
```bash
# Run post_task verification
# (read commands from .sdlc/verification.yml post_task section)

# If pass:
gh issue edit [TASK_ISSUE] --remove-label "adlc:in-progress" --add-label "adlc:done"
gh issue comment [TASK_ISSUE] --body "## DEV: Task complete — [FEAT-ID]-T[NNN]
**Tests:** all passing
**Verification:** all gates passed
**Branch:** ready for PR"

# If fail (max 2 retries):
gh issue edit [TASK_ISSUE] --add-label "adlc:blocked"
gh issue comment [TASK_ISSUE] --body "## DEV: Task blocked — verification failed
**Error:** [details]
**Retries:** [count]/2 exhausted"
```

On dev-agent BLOCKED or NEEDS_CONTEXT:
```bash
gh issue edit [TASK_ISSUE] --add-label "adlc:blocked"
gh issue comment [TASK_ISSUE] --body "## DEV: Task blocked
**Reason:** [from dev-agent report]
**Needs:** [who needs to act]"
```

## Step 6 — Update progress

After each task completes or blocks, update `.sdlc/_active/[FEAT-ID].progress.md`:

```markdown
# [FEAT-ID] Progress

## Tasks
| Task | Status | Issue | Branch | Notes |
|---|---|---|---|---|
| T001 | done | #42 | agent/FEAT-001-setup | merged |
| T002 | in-progress | #43 | agent/FEAT-001-logic | |
| T003 | ready | #44 | — | depends on T001 |

## Discoveries
- [pattern/gotcha found during implementation]

## Next session
- Continue T002 on branch agent/FEAT-001-logic
- Then start T003
```

## Step 7 — Slice completion

When all tasks in a slice are done:
1. Run post_slice verification from `.sdlc/verification.yml`
2. Cross-check feature registry: every AC should have test_function and passes=true
3. If all pass, notify: "Slice complete. Ready for QA review."
4. Update spec issue label: `adlc:ready-for-qa`

</instructions>

<documents>
- `.sdlc/tasks/[FEAT-ID]/` — task files and slice plan
- `.sdlc/_active/[FEAT-ID].progress.md` — progress tracking
- `.sdlc/verification.yml` — verification gates
- `.sdlc/specs/[FEAT-ID]-registry.json` — AC tracking
</documents>
