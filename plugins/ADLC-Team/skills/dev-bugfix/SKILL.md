---
name: dev-bugfix
description: "Fast-track bug fix with root-cause analysis. Trigger: 'fix bug', 'hotfix', 'sửa bug', 'debug'. Lightweight path — skips spec/eval overhead."
---

<context>
Lightweight 6-step path for isolated bugs. Root cause FIRST, fix SECOND — no exceptions. If scope exceeds a single bug, escalate to full spec workflow.
</context>

<instructions>

## Step 1 — Reproduce

Confirm the bug exists:
- Read the bug report (GitHub Issue or user description)
- Find the failing behavior in code
- Write or run a test that demonstrates the failure

If you cannot reproduce, stop and ask for more information.

## Step 2 — Root cause analysis

Trace the error backward:
- Check recent commits: `git log --oneline -20`
- Find the code path that produces the bug
- Compare with working examples or tests
- Formulate an explicit hypothesis: "The bug occurs because [X] when [Y]"

Do NOT skip this step. Do NOT guess-and-fix.

## Step 3 — Write failing test

Create a test that:
- Fails with the current code (RED)
- Will pass when the fix is applied
- Naming: `Test_Bugfix_[IssueNumber]_[Behavior]`

## Step 4 — Fix (max 3 attempts)

Apply the fix. If the test passes (GREEN), proceed.

If 3 fix attempts fail, the hypothesis is likely wrong:
- Revisit Step 2
- Consider if this is actually a deeper issue requiring full spec workflow
- Escalate if needed: "This bug is more complex than expected — recommend full spec workflow."

## Step 5 — Verify

Run ALL verification commands from `.sdlc/verification.yml`:
- Build
- Lint
- Full test suite (not just the new test)
- Confirm no regressions

## Step 6 — Document and commit

```bash
# Commit
git commit -m "fix(#[ISSUE]): [what was wrong and why]

Root cause: [1-line explanation]
Test: Test_Bugfix_[IssueNumber]_[Behavior]"

# Update GitHub Issue
gh issue comment [ISSUE] --body "## DEV: Bug fixed
**Root cause:** [explanation]
**Fix:** [what changed]
**Test:** [test name]
**Verification:** all gates passed"

gh issue edit [ISSUE] --remove-label "bug" --add-label "adlc:done"
```

## Escalation criteria

Escalate to full spec workflow if ANY of these apply:
- Fix requires changes to 4+ files
- Fix requires database migration
- Fix affects public API contract
- Fix requires changes to multiple features
- Root cause is architectural (not a simple code bug)

</instructions>
