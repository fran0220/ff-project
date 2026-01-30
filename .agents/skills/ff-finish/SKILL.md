---
name: ff-finish
description: "Pre-commit checklist. Use before committing changes."
mode: smart
---

# FF Finish

Final verification before commit.

## Checklist

### 1. Code Quality

```bash
pnpm lint
pnpm typecheck
pnpm test
```

- [ ] Lint passes (0 errors)
- [ ] Types pass
- [ ] Tests pass

### 2. Changes Review

```bash
git status
git diff
```

- [ ] Only expected files changed
- [ ] No debug code left
- [ ] No unintended changes

### 3. Spec Updates

Did you learn something new? Update specs if needed:
- `.ff/spec/backend/index.md`
- `.ff/spec/frontend/index.md`
- `.ff/spec/guides/index.md`

## Ready to Commit

Tell user they can now commit:

```bash
git add <files>
git commit -m "type(scope): description"
```

Commit types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

## Linear Integration (Optional)

If tracking with Linear, update the issue:

```
# Update status to "Done"
mcp__linear__linear_updateIssue({
  issueId: "<issue-id>",
  stateId: "<done-state-id>"
})

# Add completion comment
mcp__linear__linear_createComment({
  issueId: "<issue-id>",
  body: "## Completed\n- Commit: <hash>\n- Summary: <what was done>"
})
```
