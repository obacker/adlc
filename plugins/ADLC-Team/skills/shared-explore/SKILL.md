---
name: shared-explore
description: "Systematically map an existing codebase — stack detection, architecture, domain discovery, test coverage, tech debt. Trigger: 'explore codebase', 'onboard', Case C/D repo detection. Shared across all roles."
---

<context>
You map an unfamiliar codebase to build understanding before development starts. This is read-only — no code modifications.
</context>

<instructions>

## Step 1 — Project overview

Read configuration files to identify stack:
- `package.json`, `tsconfig.json` → Node.js/TypeScript
- `go.mod` → Go
- `pyproject.toml`, `requirements.txt` → Python
- `Cargo.toml` → Rust
- `pom.xml`, `build.gradle` → Java/Kotlin
- `Dockerfile`, `docker-compose.yml` → containerization
- `README.md`, `CLAUDE.md` — any existing docs

Record: language, framework, build tool, test framework, linter, CI/CD.

## Step 2 — Architecture map

```bash
# Directory structure (depth 3)
find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' | head -50

# Entry points
# Look for main files, index files, app files, server files
```

Identify:
- Architectural pattern (MVC, hexagonal, microservices, monolith)
- Entry points and request flow
- Database/ORM layer
- External service integrations
- Shared utilities and helpers

## Step 3 — Domain analysis

Scan for domain-specific types, interfaces, constants:
```bash
# Find type definitions, interfaces, models
grep -r "type\|interface\|class\|model\|schema" --include="*.ts" --include="*.go" --include="*.py" -l
```

Identify:
- Key domain entities and their relationships
- Business rules encoded in code
- Domain terminology (seed for domain-terms.md)

## Step 4 — Test coverage

```bash
# Find test files
find . -name "*test*" -o -name "*spec*" | grep -v node_modules | grep -v vendor

# Count test files vs production files
```

Identify well-tested vs untested areas.

## Step 5 — Code health

Look for:
- TODO/FIXME/HACK comments
- Dead code (unused exports, unreachable branches)
- Dependency freshness (outdated packages)
- Recent git activity: `git log --oneline -20`

## Output

Write to `.sdlc/exploration-report.md`:

```markdown
# Codebase Exploration Report

## Stack
- **Language:** [X]
- **Framework:** [X]
- **Database:** [X]
- **Test framework:** [X]
- **Build/lint:** [X]

## Architecture
[Pattern, entry points, key directories]

## Domain Concepts
[Key entities, relationships, business rules]
[Seed terms for domain-terms.md]

## Test Coverage
- Test files: [N]
- Production files: [N]
- Well-tested areas: [list]
- Gaps: [list]

## Code Health
- TODOs: [N]
- Recent activity: [pattern]
- Key concerns: [list]

## Recommended First Steps
1. [Most impactful action]
2. [Second action]
3. [Third action]
```

Also generate initial scaffold files if `.sdlc/` doesn't exist:
- `.sdlc/domain-context.md` (from exploration findings)
- `.sdlc/domain-terms.md` (seed from domain analysis)
- `.sdlc/verification.yml` (from detected stack)

## Constraint

This is READ-ONLY. No code modifications, no destructive commands, no database operations. If you find secrets, flag them without including values in the report.

</instructions>
