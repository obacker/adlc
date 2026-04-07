---
name: shared-write-ui-tests
description: "Generate Playwright UI tests from BDD scenarios. Shared by DEV (happy path) and QA (edge cases). Trigger: 'UI tests for [FEAT-ID]', 'Playwright tests', 'behavior tests', 'e2e tests'."
---

<context>
You generate Playwright tests from BDD acceptance criteria. DEV uses you for happy-path tests during TDD. QA uses you for edge case and error state tests. Tests use intent-based selectors — never CSS selectors or XPath.
</context>

<instructions>

## Step 1 — Load spec

Read:
- `.sdlc/specs/[FEAT-ID]-*-spec.md` — acceptance criteria
- Existing test files — avoid duplicating tests
- `.sdlc/domain-terms.md` — use correct terminology

## Step 2 — Determine scope

Ask the user:
- **DEV mode** (happy path): Generate tests for the GREEN path of each AC
- **QA mode** (edge cases): Generate tests for error states, empty states, boundary inputs, concurrent actions

## Step 3 — Generate tests

Selector strategy (in priority order):
1. `data-testid` attributes (preferred)
2. ARIA roles: `page.getByRole('button', { name: 'Submit' })`
3. Text content: `page.getByText('Welcome')`
4. Placeholder: `page.getByPlaceholder('Enter email')`
5. NEVER use CSS selectors, XPath, or DOM structure

Test naming: `test('[FEAT-ID] AC-[N]: [behavior description]', ...)`

Test structure:
```typescript
import { test, expect } from '@playwright/test';

test.describe('[FEAT-ID]: [Feature name]', () => {
  test('AC-001: [behavior from spec]', async ({ page }) => {
    // Arrange — Given
    await page.goto('/path');

    // Act — When
    await page.getByRole('button', { name: 'Action' }).click();

    // Assert — Then
    await expect(page.getByText('Expected result')).toBeVisible();
  });
});
```

For QA edge case tests, include:
- Empty state (no data)
- Error state (API failure mock)
- Loading state (slow response)
- Boundary inputs (max length, special characters)
- Concurrent actions (double-click, rapid navigation)

## Step 4 — Output

Write tests to the project's test directory (match existing convention).
If no convention exists, use: `tests/e2e/[FEAT-ID].spec.ts`

After writing:
```bash
# Run the tests
npx playwright test tests/e2e/[FEAT-ID].spec.ts

# If tests need data-testid attributes added to components,
# list required attributes:
```

If components need `data-testid` attributes, output a list for DEV:
```
## Required data-testid attributes
- `[component]` needs `data-testid="[id]"`
```

## Step 5 — Update registry

For each AC with a new UI test, update the feature registry:
```bash
# Read current registry
cat .sdlc/specs/[FEAT-ID]-registry.json

# For each AC tested, update test_function field:
python3 -c "
import json
with open('.sdlc/specs/[FEAT-ID]-registry.json') as f:
    reg = json.load(f)
for ac in reg['acceptance_criteria']:
    if ac['id'] == 'AC-NNN':
        ac['test_function'] = 'test_name_here'
        ac['passes'] = True  # or False if test fails
with open('.sdlc/specs/[FEAT-ID]-registry.json', 'w') as f:
    json.dump(reg, f, indent=2)
"
```

</instructions>

<documents>
- `.sdlc/specs/[FEAT-ID]-*-spec.md`
- `.sdlc/domain-terms.md`
- Existing test files in project
</documents>
