---
description: Lightweight bug fix with root-cause analysis — reproduce, diagnose, test, fix, verify. Skips spec/milestone phases.
argument-hint: Bug description or error message
---

# ADLC Bugfix

Fix a bug using systematic root-cause analysis. No spec or milestone phases — straight to diagnosis and fix.

## Principles

- Root cause FIRST, fix SECOND — no exceptions
- Write a failing test that reproduces the bug BEFORE fixing
- Verify the fix doesn't break anything else

## Process

### Phase 1: Root Cause Investigation

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

1. Read the bug description / error message completely
2. Reproduce the bug:
   - Find or write a command/test that triggers the error
   - If can't reproduce: gather more evidence, don't guess
3. Check recent changes: `git log --oneline -20` — did something change recently?
4. Trace data flow backward from the error:
   - What function threw? What called it? What data was passed?
   - Add instrumentation at component boundaries if needed
5. Find a working example: is there similar code that works? What's different?
6. Form ONE hypothesis. Write it down explicitly:
   ```
   Hypothesis: [specific cause] because [evidence]
   ```

### Phase 2: Test

1. Write a failing test that reproduces the bug:
   - Name: `Test_Bugfix_[Component]_[Behavior]`
   - Test MUST fail before the fix (proving it captures the bug)
   - Run it. Confirm it fails with the expected error.

### Phase 3: Fix

1. Implement the minimal fix — change as little as possible
2. Run the new test — must pass now
3. Run ALL tests — nothing else should break
4. If fix attempt fails (test still fails or other tests break):
   - Max 3 attempts
   - After 3 failures: STOP. Question the hypothesis, not attempt fix #4.
   - Report to user: "Root cause may be different than hypothesized. Here's what I found: [evidence]"

### Phase 4: Verify

1. Run ALL verification commands from verification.yml FRESH
2. Read test output — confirm bug test passes, no regressions
3. Commit: `fix([scope]): [description of what was wrong and why]`

## Anti-Rationalization List

- "Quick fix, investigate later" → You'll never investigate later. Do it now.
- "Obviously it's X" → If it were obvious, it wouldn't be a bug. Verify.
- "Just try this" → Random changes create random results. Hypothesize first.
- "Multiple things might be wrong" → Test one variable at a time.

## Output

```
## Bugfix Report

### Root Cause
[What was wrong and why — 2-3 sentences]

### Hypothesis
[What you tested]

### Fix
[What you changed — files and summary]

### Test
[Test name, command to run, output showing it passes]

### Verification
[All verification commands run, results shown]

### Commit
[commit hash]: fix([scope]): [message]
```

## Rules

- If the bug relates to an existing milestone: update feature-registry.json if relevant ACs were affected
- If the bug reveals a missing AC: note it but don't modify milestone-spec.md (suggest adding in next milestone)
- Never "fix" by disabling or skipping a test
