---
name: qa-start
description: "Start a QA session — check what needs testing, review spec quality, plan exploratory tests. Trigger: 'start working as QA', 'QA session', 'start QA'."
---

<context>
You are starting a QA session. Your focus: quality oversight, edge cases, and exploratory testing. You do NOT need to verify basic test coverage (DEV handles that via TDD). You focus on what DEV didn't think of.
</context>

<instructions>

## Step 1 — Load context

Read (skip missing silently):
- `CLAUDE.md` — project overview
- `.sdlc/domain-context.md` — business domain
- `.sdlc/context-snapshot.md` — last session state
- `.sdlc/KNOWLEDGE.md` — known patterns and gotchas

## Step 2 — Check GitHub state

```bash
# Features ready for QA
gh issue list --label "adlc:ready-for-qa" --limit 20 --json number,title,labels

# Specs needing AC quality review (draft specs)
gh issue list --label "adlc:spec-draft" --limit 10 --json number,title

# QA-failed issues needing re-test
gh issue list --label "adlc:qa-failed" --limit 10 --json number,title

# Recently completed tasks (may need spot checks)
gh issue list --label "adlc:done" --limit 10 --json number,title,updatedAt
```

## Step 3 — Present summary

```
## QA Session — [project name]

**Ready for QA testing:** [count] features
[list with feature IDs and brief descriptions]

**Specs needing AC review:** [count]
[list — QA reviews if ACs are testable before BA approves]

**Failed QA, needs re-test:** [count]
[list with last failure reason]

**Suggested next action:** [highest priority item]
```

## Step 4 — Wait for user choice

Options:
- Review spec ACs for testability (pre-approval quality gate)
- Run adversarial tests on feature #N → invoke qa-test-adversarial
- Write UI edge case tests → invoke shared-write-ui-tests
- Plan exploratory test session (manual testing with AI guidance)
- Re-test previously failed feature

### Exploratory test planning

If user chooses exploratory testing, generate a structured test charter:
```
**Feature:** [FEAT-ID]
**Time box:** [30/60 min]
**Focus area:** [specific area to explore]
**Test ideas:**
1. [scenario to try manually]
2. [edge case to verify]
3. [integration point to check]
**What to look for:** [specific symptoms of problems]
**Record findings in:** .sdlc/reviews/[FEAT-ID]-exploratory.md
```

</instructions>
