# ADLC-Solo Optimization Plan v2

**Date:** 2026-04-10
**Author:** Tuan + Claude (Co-founder AI)
**Scope:** Token/limit usage optimization + ADLC performance/accuracy/workflow enforcement
**Based on:** Claude Code Insights (1,434 messages, 172 sessions, 24 days, 2026-03-18 to 2026-04-10)

---

## 1. Current State Assessment

### 1.1 Setup & Context

| Item | Current | Optimized |
|------|---------|-----------|
| Seat type | Team Premium ($125/mo) | Team Premium (keep) |
| Default model | Opus 4.6 1M (Default recommended) | **Sonnet (200K)** — routes through Sonnet-specific limit |
| Advisor Tool | No advisor | **Opus 4.6 as advisor** |
| Effort level | High (Team default) | **High** (keep for interactive), Medium for headless/batch |
| Usage capacity | 6.25x Pro | Same (but ~70-85% less waste) |
| Subscription usage | ADLC coding only | ADLC coding + all other company work (email, analysis, docs, Cowork) |

**Goal:** Maximize output per token on Premium seat. Reduce waste from 650-1150 turns/month to under 200. Protect general limit for non-coding work.

### 1.2 Usage Profile (from Insights)

| Metric | Value |
|--------|-------|
| Messages | 1,434 across 172 sessions |
| Daily average | 79.7 msgs/day, ~10h/day |
| Agent tool calls | 534 (5th most used tool) |
| Parallel overlaps | 53 events, 70 sessions, 17% of messages |
| Top tools | Bash (4274), Read (1954), Edit (1239), Write (566), Agent (534), Grep (434) |
| Command failures | 277 |
| Buggy code incidents | 31 |
| Wrong approach incidents | 29 |
| Goal achievement | 95% (31 fully, 11 mostly, 2 partially out of 44 analyzed) |

### 1.3 Token Waste Sources (Prioritized by Impact)

| Source | Incidents | Est. Wasted Turns/Month | Root Cause |
|--------|-----------|------------------------|------------|
| Wrong approach → course correction | 29 | 300-500 | Over-engineering, planning instead of executing, ignoring procedures |
| Buggy code → fix iterations | 31 | 150-250 | Type mismatches, missing fields, Ent ORM edge bugs, wrong imports |
| Parallel agent conflicts | 53 overlaps | 100-200 | Worktree sharing, branch switching, overwriting work |
| Command failures → retry cycles | 277 | 50-100 | Build failures, wrong commands, missing deps |
| Redundant file reads | ~1954 Read calls | 50-100 | Re-reading same files, reading entire files instead of grep |
| **Total estimated waste** | | **650-1150 turns/month** | |

### 1.4 Insights Coverage Audit

Every recommendation from the Claude Code Insights report mapped to this plan:

| Insights Recommendation | Plan Coverage | Section |
|---|---|---|
| Encode ADLC phases into CLAUDE.md | ✅ | Appendix B |
| Hooks for compilation checks after edits | ✅ | M1-T2 (PostToolUse hook) + M1-T3 (project hooks) |
| Headless mode for batch audits | ⏭ Skipped | Not using headless/batch |
| Wrong approach friction | ✅ | M1-T4 (anti-drift) + Section 3 (Advisor) |
| Buggy code friction | ✅ | M1-T2 (compile-check) + Section 3 (Advisor) |
| Parallel agent conflicts | ✅ | M1-T1 (enforce-worktree fix) |
| CLAUDE.md additions (6 items) | ✅ | Appendix B |
| Project-level hooks (postEditCommand) | ✅ | M1-T3 |
| Custom /adlc unified skill | ✅ | M3-T2 |
| Stop repeating about process compliance | ✅ | M1-T4 + Appendix B |
| Self-Healing Parallel Agent Orchestration | ✅ | M2-T3 (auto-retry on agent failure) |
| Autonomous TDD Loop with Coverage Gates | ✅ | M2-T2 (coverage gates) |
| ADLC Autonomous Sprint Execution Engine | ✅ | M3-T3 (state machine gates) |

---

## 2. Model & Limit Strategy

### 2.1 Default Model: Switch to Sonnet (200K)

**Change:** Claude Code default model from "Default (Opus 4.6 1M)" → "Sonnet"

**Why:**
- Sonnet uses the **Sonnet-specific limit** — separate from general limit
- Opus advisor auto-escalates when Sonnet needs help (400-700 tokens/call, billed at Opus rate)
- 200K sufficient for orchestration; compaction at 75% (~150K usable) with save-context.sh recovery
- Sonnet 1M (option 3) billed as extra usage $3/$15 per Mtok — avoid
- **Protects general limit** for: spec-writer Opus, advisor escalations, non-coding work

**When to temporarily switch to Opus 1M:**
- Large unfamiliar codebase exploration (5+ packages)
- Multi-milestone strategic planning
- Debugging issues that span many files where Sonnet + advisor failed

### 2.2 Effort Level Strategy

| Context | Effort | Why |
|---------|--------|-----|
| Interactive ADLC sessions | **High** (keep default) | Quality matters; this is where features ship |
| Per-agent override | **Not yet supported** | Feature request pending (GitHub #31536). All agents inherit session effort. |

### 2.3 1M Context Window: When It Matters

| Model | Context | Retrieval Accuracy at 1M | Best For |
|-------|---------|--------------------------|----------|
| Opus 4.6 | 1M | 78.3% (MRCR v2) | spec-writer, codebase exploration, architectural decisions |
| Sonnet 4.6 | 1M (extra $) / 200K (included) | ~18.5% at 1M (degrades badly) | Implementation, QA, orchestration — use 200K, compact aggressively |
| Haiku 4.5 | 200K | N/A | Structured tasks, spec compliance, simple operations |

**Key insight:** Sonnet at 1M CAN hold 1M tokens but CANNOT reason over them reliably. Compact at 75% to keep effective context under ~150K where Sonnet remains accurate.

### 2.4 Team Premium Dual Limit Strategy

Team Premium has TWO weekly limits:
1. **General limit** — ALL models consume from this
2. **Sonnet-only limit** — ONLY Sonnet, separate budget

Since the same subscription covers ADLC coding + all other company work, protect general limit.

**ADLC Agent Routing (auto-selected by orchestrator, NOT manual):**

| Agent | Model | Limit Pool | Advisor | Rationale |
|-------|-------|------------|---------|-----------|
| spec-writer | `model: opus` | General | N/A (already Opus) | Spec quality too critical. ~30 turns/feature. |
| dev-agent | `model: sonnet` | **Sonnet limit** | Opus advisor | Heaviest consumer. Sonnet limit absorbs bulk. |
| qa-tester (spec compliance) | `model: haiku` (spawn override) | General (light) | Opus advisor | Structured task. Haiku sufficient. |
| qa-tester (adversarial) | `model: sonnet` (spawn override) | **Sonnet limit** | Opus advisor | Needs sustained creative reasoning. |
| Orchestrator | Sonnet (session default) | **Sonnet limit** | Opus advisor | Phase management. |
| **Non-coding** (email, docs, Cowork) | Varies | **General (protected)** | N/A | ~70% general limit available. |

**Rate Limit Budget Estimate:**

| Activity | Limit Pool | Est. % of Pool |
|----------|------------|----------------|
| spec-writer Opus (~30 turns/feature, ~3/week) | General | ~15% |
| Advisor escalations (~400-700 tok, ~5-10/day) | General | ~10% |
| Haiku QA spec compliance | General | ~5% |
| **Total ADLC on general** | General | **~30%** |
| **Non-coding work available** | General | **~70%** |
| dev-agent + adversarial QA + orchestrator | Sonnet limit | ~60-80% |

### 2.5 Model Routing: Auto-Selected by ADLC

All model decisions are encoded in ADLC skills — the orchestrator auto-selects based on task characteristics. Tuan does NOT manually choose models per agent.

**Routing rules (encoded in build-feature skill):**

For dev-agent spawning (Phase 4):
- Task ≤2 files + complete spec → spawn with `model: haiku`
- Task 3+ files or requires judgment → spawn with `model: sonnet` (default)
- Task requires architectural decisions → spawn with `model: opus`

For qa-tester spawning (Phase 5):
- Spec compliance mode → spawn with `model: haiku`
- Adversarial mode → spawn with `model: sonnet`

**Verification needed:** Agent frontmatter `model:` field may not be respected at runtime (conflicting reports). build-feature skill should explicitly pass `model:` parameter when spawning agents to guarantee correct routing.

---

## 3. Advisor Tool Strategy

### 3.1 How It Works

Executor model (Sonnet/Haiku) runs end-to-end. When facing a complex decision, it autonomously invokes the advisor (Opus). Opus receives curated context, returns short guidance (400-700 tokens), executor resumes. All within one API call.

**From [Anthropic blog](https://claude.com/blog/the-advisor-strategy):**
- Sonnet + Opus advisor: **11.9% cost reduction** vs Sonnet alone, **+2.7pp accuracy** on SWE-bench Multilingual
- Haiku + Opus advisor: 85% less cost than Sonnet solo, but trails by 29%
- `max_uses` caps advisor calls per request (default 3)
- Billing tiered by model — advisor Opus tokens at Opus rate, executor at executor rate

### 3.2 Why Advisor Is the Highest-Leverage Change

Insights: 60 friction incidents (29 wrong-approach + 31 buggy-code) where Sonnet circled or chose wrong strategy.

**Without Advisor:** Sonnet fails → wastes 10-20 turns → Tuan manually intervenes
**With Advisor:** Sonnet starts to fail → Opus auto-escalates → correct course in 1-2 turns

### 3.3 Synergy with Workflow Improvements

Advisor + improvements = multiplicative:
- PostToolUse compile-check catches bugs at platform level → fewer advisor escalations
- Anti-drift instructions prevent over-engineering → advisor only for genuinely complex decisions
- Enforce-worktree fix eliminates conflicts → fewer ambiguous failure states

Net effect: Advisor becomes a rare safety net, not a frequent crutch → minimal general limit impact.

---

## 4. Implementation Milestones

### Milestone 0: Configuration (Immediate, no code changes)

| Task | Action | Effort |
|------|--------|--------|
| M0-T1 | Set Advisor Tool = Opus 4.6 in Claude Code settings | 1 min |
| M0-T2 | Switch default model from "Default (Opus 4.6 1M)" to "Sonnet" | 1 min |
| M0-T3 | Keep effort level = High (default for interactive) | Already set |

**Verification:** Start a Claude Code session → confirm model shows Sonnet → trigger a complex question → verify Opus advisor activates (visible in token usage).

---

### Milestone 1: Eliminate Top Friction Sources

**Goal:** Address the 3 biggest waste sources from insights (buggy code, wrong approach, parallel conflicts).

**M1-T1: Fix enforce-worktree.py gap**
- Change: Block non-worktree production code edits on ALL branches (not just main/master)
- File: `hooks/scripts/enforce-worktree.py`
- Logic: `if not is_in_worktree() and not is_allowed_file(file_path): deny()`
- Remove: `is_on_protected_branch()` gate
- Safety: qa-tester exempt (writes test files → `is_allowed_file()` passes)
- Test: edit .go file from orchestrator on feature branch → verify deny
- Effort: 1h

**M1-T2: PostToolUse compile-check hook (plugin-level)**
- Create: `hooks/scripts/post-edit-compile-check.py`
- Behavior: After Edit/Write on `.go` → `go vet`; on `.ts/.tsx` → `tsc --noEmit`
- Returns WARNING (not deny) — agent sees error, fixes immediately
- Skip: `.md`, `.json`, `.yaml`, test files, `.sdlc/`
- Add to hooks.json: PostToolUse matcher "Edit|Write", timeout 15s
- Test: edit .go file with missing JSON tag → verify warning
- Effort: 2-3h

**M1-T3: Project-level hooks (.claude/settings.json)**
- These are SEPARATE from plugin hooks and coexist
- Add to project's `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "cd backend && go vet ./... 2>&1 | head -20; cd ../frontend && npx tsc --noEmit 2>&1 | head -20",
        "timeout": 15
      }]
    }],
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "cd backend && go build ./... && cd ../frontend && npm run lint",
        "timeout": 30
      }]
    }]
  }
}
```
- Why both plugin AND project hooks: Plugin hooks only active when ADLC plugin installed. Project hooks active in ALL Claude Code sessions (including non-ADLC debugging, infra work, etc.)
- Effort: 30 min

**M1-T4: Dev-agent anti-drift instructions**
- Update: `agents/dev-agent.md`
- Add sections: Anti-Drift Rules, Early Progress Check (turn 10 gate), Context Discipline
- Key rules: max 2 Read operations before first code edit; EXECUTE approved plans, don't re-plan; Grep instead of Read entire files
- Test: run build-feature on small feature → verify agent starts coding within first 5 turns
- Effort: 1h

**M1-T5: Agent frontmatter tuning**
- dev-agent: maxTurns 50 → 35
- qa-tester: maxTurns 50 → 30
- spec-writer: 30 (keep)
- Test: run build-feature → verify agents complete within new limits
- Effort: 10 min

**M1-T6: CLAUDE.md additions from Insights**
- Add all 6 suggested CLAUDE.md additions (see Appendix B)
- Add performance configuration (env vars)
- Effort: 30 min

**Milestone 1 verification:** Run 3 build-feature sessions. Track: compile errors caught by hook, worktree denials, turns-to-first-code-edit, total turns per agent.

---

### Milestone 2: Improve Agent Reliability

**Goal:** Reduce agent failure cascade, add coverage gates, improve orchestrator awareness.

**M2-T1: On-agent-stop warning surfacing**
- Modify: `hooks/scripts/on-agent-stop.sh` — output warnings to stdout (not just log file)
- Update: build-feature Phase 4 — read `.sdlc/agent-log.txt` after each dev-agent returns, investigate warnings before proceeding
- Test: force dev-agent to fail silently → verify warning surfaces to orchestrator
- Effort: 1h

**M2-T2: Coverage gates in TDD (from Insights "On the Horizon")**
- Add to dev-agent.md Phase 3 (after Green):
```markdown
## Coverage Gate
- Run `go test ./... -coverprofile=coverage.out && go tool cover -func=coverage.out`
- If coverage for changed packages < 85%: write additional tests targeting uncovered lines
- Re-run until gate passes or max 3 attempts
- If still below 85% after 3 attempts: report DONE_WITH_CONCERNS with coverage %
```
- For frontend: `npx vitest --coverage` with same 85% threshold
- Effort: 1h

**M2-T3: Auto-retry on agent failure (from Insights "Self-Healing")**
- Add to build-feature Phase 4 (after checking agent return status):
```markdown
If dev-agent returns BLOCKED or exits with error:
1. Read .sdlc/agent-log.txt for diagnostics
2. If error is "tool-use limit exhausted":
   - Spawn NEW dev-agent for remaining ACs, passing completed ACs list
   - Include context from failed agent's last commit
3. If error is "merge conflict":
   - Run `git merge --abort` in worktree
   - Re-spawn dev-agent with updated base branch
4. If error is unknown:
   - Report to user with diagnostics
5. Maximum 2 auto-retries per task. After 2: escalate to user.
```
- Effort: 1.5h

**M2-T4: QA-tester model split**
- Update: build-feature Phase 5
- Spec compliance: spawn qa-tester with `model: haiku` (general limit, light)
- Adversarial: spawn qa-tester with `model: sonnet` (Sonnet limit)
- Effort: 30 min

**Milestone 2 verification:** Run 3 build-feature sessions. Track: auto-retry triggers, coverage gate results, warning surfacing accuracy.

---

### Milestone 3: Advanced Automation

**Goal:** Headless batch operations, unified skill, autonomous sprint execution.

**M3-T1: Unified /adlc custom skill (from Insights)**
- Insights suggests: "A /adlc skill can enforce the full workflow, and /qa can standardize your audit process"
- ADLC-Solo already has 7 skills. The insight is about having a SINGLE entry point that routes to the right sub-workflow
- Create: `/adlc` meta-skill that reads context, identifies what phase the project is in, and routes to the correct existing skill
- Effort: 2h

**M3-T2: Autonomous Sprint Execution Engine (from Insights "On the Horizon")**
- Encode ADLC phases as a state machine with hard programmatic gates:
```markdown
State Machine (per milestone):
  SPEC → gate: spec file exists + user approved → 
  TDD → gate: all new tests FAILING → 
  IMPLEMENT → gate: all tests PASSING + zero compile errors → 
  REVIEW → gate: no critical findings → 
  QA → gate: all pre-existing tests still pass → 
  DOCS → gate: no TODO/FIXME in changed files + all AC statuses updated → 
  COMMIT → gate: git diff --cached --stat matches expected file list

If ANY gate fails: fix and re-run. Do not skip.
```
- This extends build-feature with actual verification commands at each gate (not just instructions)
- Effort: 3-4h

**Milestone 3 verification:** Run build-feature with state machine gates → verify gates actually block on failure. Test unified /adlc skill routing.

---

### Milestone 4: Measure & Iterate

**Goal:** Compare optimized metrics against Insights baseline.

**M4-T1: Collect new Insights report**
- After running 20+ sessions with all improvements
- Compare against baseline: buggy-code incidents, wrong-approach incidents, parallel conflicts, command failures, turns per session

**M4-T2: Tune based on data**
- If advisor triggers > 10x/day → investigate which tasks cause frequent escalation
- If dev-agent consistently hits DONE_WITH_CONCERNS before turn 30 → increase maxTurns to 40
- If Haiku QA spec compliance misses gaps → switch back to Sonnet for spec compliance
- If project-level hooks slow workflow → increase timeout or make async

---

## 5. Expected Outcomes

### Token/Limit Savings

| Improvement | Turns Saved/Month | % of Total Waste |
|-------------|-------------------|------------------|
| Advisor Tool (M0) | 100-200 | 10-20% |
| PostToolUse + project hooks (M1-T2, M1-T3) | 120-200 | 15-20% |
| Anti-drift instructions (M1-T4) | 150-250 | 20-25% |
| Enforce-worktree fix (M1-T1) | 100-200 | 15-20% |
| Turn limit tuning (M1-T5) | 50-100 | 5-10% |
| Coverage gates (M2-T2) | 30-50 | 3-5% |
| Auto-retry (M2-T3) | 30-50 | 3-5% |
| **Total** | **~580-1050 turns/month** | **~75-90% of current waste** |

### Quality Improvements

- Earlier error detection → cleaner code, fewer regressions
- Coverage gates → no more "tests pass" without evidence
- Better agent isolation → no more lost work from conflicts
- Tighter turn budgets → agents commit more frequently → less risk of lost progress
- Auto-retry → fewer manual interventions for predictable failures
- Unified /adlc skill → single entry point, auto-routes to correct workflow

---

## 6. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Advisor Opus triggers too often → eats general limit | MEDIUM | Less budget for non-coding | Workflow improvements reduce trigger frequency; monitor weekly |
| PostToolUse hook slows edit flow | LOW | Minor friction | 15s timeout; skip test/config files |
| Stricter enforce-worktree blocks legitimate edits | MEDIUM | Broken workflow | is_allowed_file() exempts .sdlc/, .md, test files |
| dev-agent 35 turns insufficient | MEDIUM | More DONE_WITH_CONCERNS | Turn Budget Management auto-spawns continuation |
| Haiku insufficient for QA spec compliance | LOW | Missed AC gaps | Fallback: Sonnet if Haiku accuracy < 95% |
| Agent frontmatter `model:` not respected | MEDIUM | Wrong model routing | build-feature skill explicitly passes `model:` at spawn time |
| Coverage gate slows dev-agent | LOW | Slightly longer sessions | 85% threshold is reasonable; max 3 attempts |

---

## Appendix A: Environment Configuration

Add to project's `CLAUDE.md`:

```markdown
## Performance Configuration

Environment variables for token optimization:
- CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75
- CLAUDE_CODE_MAX_OUTPUT_TOKENS=16000
- MAX_THINKING_TOKENS=8000

After compaction: always read .sdlc/context-snapshot.md first.
```

## Appendix B: Insights-Driven CLAUDE.md Additions

From the Claude Code Insights "Suggested CLAUDE.md Additions" (all 6 items):

```markdown
## Session Discipline

When completing a task, ALWAYS update context files (CLAUDE.md, domain-context.md, ROADMAP.md, etc.) before declaring the session closed. Never skip documentation updates.

## ADLC Process Compliance

Follow the ADLC workflow phases in order (spec → TDD → implement → review → QA). Do not skip phases or jump ahead without explicit user approval. If a process is defined, follow it before writing code.

Before you start: re-read the ## Session Discipline and ## Process & Workflow sections of CLAUDE.md. Confirm you understand the required phases. Do not skip any phase. Do not declare the session complete until all context files are updated and committed.

## Parallel Agent Isolation

When using parallel sub-agents or worktrees, ensure each agent works on isolated files/branches. Never let multiple agents share the same working tree or branch. Verify no overlapping file edits before committing.

When using parallel agents: assign each agent a specific set of files or packages. No two agents should edit the same file. Each agent must work on its own branch or verify no conflicts before committing. After all agents complete, I will review and merge.

## Language-Specific Conventions

For Go backend: always use json struct tags on exported fields. Before writing Go structs, check that all exported fields have json tags. Before any Docker build, confirm the target platform is linux/amd64. Before any deploy, read the deploy docs and use the documented procedure.

For frontend: never remove CSS classes without verifying they're unused across all files.
For Tailwind: use proper @import syntax for v4 — do not use @tailwind directives.

## Deployment Procedures

For GCP/Cloud Run deployments: always use the documented promote procedure (not manual deploy scripts). Build Docker images for linux/amd64. Use Cloud Build 2nd gen triggers. Never use os.Exit(1) in health checks — return errors gracefully.

## Execution Discipline

When asked to execute a plan, EXECUTE it immediately. Do not spend the entire session reading files and producing a migration plan. If a plan is already approved, begin implementation without re-analysis.
```

## Appendix C: Decision Log

| Date | Decision | Rationale | Status |
|------|----------|-----------|--------|
| 2026-04-10 | Set Advisor = Opus 4.6 | Auto-escalates on 60 friction incidents pattern; zero cost | Immediate |
| 2026-04-10 | Switch default model to Sonnet (200K) | Routes through Sonnet-specific limit; protects general for non-coding | Immediate |
| 2026-04-10 | Keep Premium seat | Heavy usage (80 msgs/day, 10h/day) + shared subscription for all company work | Confirmed |
| 2026-04-10 | Keep Opus for spec-writer only | Only model with reliable 1M context reasoning (78.3% vs ~18.5%) | Confirmed |
| 2026-04-10 | Compact Sonnet at 75% | Sonnet accuracy degrades past ~200K effective tokens | Planned |
| 2026-04-10 | All model routing auto-selected by ADLC | Orchestrator decides based on task characteristics, not manual choice | Confirmed |
| 2026-04-10 | Effort: High interactive, Medium headless | Team default = High; per-agent effort not yet supported | Confirmed |
| 2026-04-10 | Dual hooks: plugin + project-level | Plugin hooks for ADLC; project hooks for ALL sessions | Planned |
