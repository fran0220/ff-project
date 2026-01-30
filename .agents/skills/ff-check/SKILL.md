---
name: ff-check
description: "Review code with deep reasoning. Use after implementation or for code review."
mode: deep
---

# FF Check

Review code changes with deep mode (extended reasoning).

## Before Review

**Read the relevant specs:**

- @.ff/spec/guides/index.md
- @.ff/spec/shared/index.md

For backend: @.ff/spec/backend/index.md
For frontend: @.ff/spec/frontend/index.md

## Review Process

### 1. See What Changed

```bash
git status
git diff
```

### 2. Verify Against Specs

Check each change against the loaded specs:
- Code quality standards
- Naming conventions
- Error handling patterns
- Type safety

### 3. Run Quality Checks

```bash
pnpm lint
pnpm typecheck
pnpm test
```

## Checklist

- [ ] No `any` types
- [ ] No `console.log` statements
- [ ] Proper error handling
- [ ] Tests pass
- [ ] Lint passes

## Self-Fix

If issues found:
1. Fix the issue
2. Run checks again
3. Verify fix is correct

## When Done

Load `ff-finish` skill when all checks pass.
