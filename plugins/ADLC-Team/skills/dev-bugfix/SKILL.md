---
name: dev-bugfix
description: "Fast-track bug fix with root-cause analysis. Trigger: 'fix bug', 'hotfix', 'sửa bug', 'debug'. Lightweight path — skips spec/eval overhead."
---

<context>
Lightweight path for isolated bugs. Root cause FIRST, fix SECOND — no exceptions.
If scope exceeds a single bug, escalate to full spec workflow.

CRITICAL: You are the orchestrator. You investigate and plan, but you do NOT edit production/test code yourself. All code changes go through spawned agents in worktrees. The enforce-worktree hook will DENY any production code edits from main conversation.
</context>

<instructions>

## Phase 1 — Investigate (you do this in main conversation)

1. Read the bug report (GitHub Issue or user description)
2. Find the failing behavior: use Read, Grep, Glob to trace the code path
3. Check recent commits: `git log --oneline -20`
4. Formulate an explicit hypothesis: "The bug occurs because [X] when [Y]"

Do NOT skip this. Do NOT guess-and-fix.

If you cannot form a hypothesis, ask the user for more information.

## Phase 2 — Spawn dev-agent to fix (MANDATORY)

You MUST spawn a dev-agent. Do NOT edit code yourself.

```
Spawn Agent:
  type: general-purpose
  model: sonnet
  isolation: worktree
  prompt: |
    You are a dev-agent fixing a bug. Follow strict TDD.

    ## Bug
    [paste hypothesis and relevant code context]

    ## Step 1: Write failing test
    Create test: Test_Bugfix_[IssueNumber]_[Behavior]
    The test MUST fail with current code (RED).

    ## Step 2: Fix (max 3 attempts)
    Write minimal production code to make the test pass (GREEN).
    If 3 attempts fail, report BLOCKED with details.

    ## Step 3: Verify
    Run ALL verification commands from .sdlc/verification.yml:
    - post_task gates: build, lint, test
    If any fail, fix and retry (max 2 retries).

    ## Step 4: Commit
    git commit -m "fix(#[ISSUE]): [what was wrong and why]

    Root cause: [explanation]
    Test: Test_Bugfix_[IssueNumber]_[Behavior]"

    ## Report back with:
    - Status: DONE / BLOCKED / NEEDS_CONTEXT
    - Test name and output
    - Files changed
    - Verification results
```

## Phase 3 — Spawn qa-agent to verify (MANDATORY)

After dev-agent completes with DONE, you MUST spawn a qa-agent.

```
Spawn Agent:
  type: general-purpose
  model: sonnet
  isolation: worktree
  prompt: |
    You are a qa-agent verifying a bugfix.

    ## What was fixed
    [paste dev-agent's report: root cause, fix, test name]

    ## Your job
    1. Read the fix diff and the new test
    2. Write 2-3 adversarial tests around the fix:
       - Same bug with different input variations
       - Boundary conditions near the fix
       - Regression scenarios
    3. Run ALL verification commands from .sdlc/verification.yml
    4. Report: PASS (fix is solid) or FAIL (found issues, list them)
```

## Phase 4 — Document (you do this in main conversation)

After both agents complete:

```bash
# Update GitHub Issue
gh issue comment [ISSUE] --body "## DEV: Bug fixed
**Root cause:** [from dev-agent report]
**Fix:** [files changed]
**Test:** [test name]
**QA:** [qa-agent verdict]
**Verification:** all gates passed"

gh issue edit [ISSUE] --remove-label "bug" --add-label "adlc:done"
```

## Model routing for sub-tasks

If you need to spawn utility agents for mechanical work (e.g., add stubs, rename across files, format):
```
model: haiku  ← mechanical, no judgment needed
```

For implementation and QA agents:
```
model: sonnet  ← needs judgment
```

## Escalation criteria

Escalate to full spec workflow (ba-write-spec) if ANY apply:
- Fix requires changes to 4+ files
- Fix requires database migration
- Fix affects public API contract
- Fix requires changes to multiple features
- Root cause is architectural

## What you MUST NOT do

- Edit production or test code directly from main conversation
- Skip spawning dev-agent ("I'll just make this quick fix")
- Skip spawning qa-agent ("the fix is simple, no need for QA")
- Use sonnet for mechanical tasks that haiku can handle

</instructions>
