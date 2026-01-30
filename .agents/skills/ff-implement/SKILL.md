---
name: ff-implement
description: "Write code with extended thinking. Use when implementing features or writing code."
mode: deep
---

# FF Implement

Write code with deep mode (extended thinking).

## Before Coding

**Read the relevant specs:**

- @.ff/spec/guides/index.md
- @.ff/spec/shared/index.md

For backend: @.ff/spec/backend/index.md
For frontend: @.ff/spec/frontend/index.md

## Guidelines

### ✅ DO

- Follow existing patterns in codebase
- Use proper TypeScript types (no `any`)
- Handle errors explicitly
- Keep functions small and focused
- Run lint/typecheck frequently

### ❌ DON'T

- Execute `git commit`
- Add `console.log` (use proper logger)
- Use `!` non-null assertions
- Modify unrelated files

## Quality Checks

```bash
pnpm lint        # or your lint command
pnpm typecheck   # or your typecheck command
```

## When Done

Load `ff-check` skill to review changes, or `ff-finish` if ready to commit.
