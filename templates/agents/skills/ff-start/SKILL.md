---
name: ff-start
description: "Initialize FF session. Use when starting work or beginning a new task."
mode: smart
---

# FF Start

Initialize your development session.

## Steps

### 1. Check Developer Identity

```bash
cat .ff/.developer
```

If not set: `echo "your-name" > .ff/.developer`

### 2. Read Specs

Read the relevant specifications:

- @.ff/spec/guides/index.md - Thinking guides
- @.ff/spec/shared/index.md - Shared patterns

Based on task type:
- @.ff/spec/backend/index.md - Backend work
- @.ff/spec/frontend/index.md - Frontend work

### 3. Ask What to Do

After reading specs, ask: **"What would you like to work on?"**

## Next Steps

| Task Type | Action |
|-----------|--------|
| Write code | Load `ff-implement` skill |
| Review code | Load `ff-check` skill |
| Ready to commit | Load `ff-finish` skill |

## Linear Integration (Optional)

If using Linear for issue tracking:

1. Create or find issue: `mcp__linear__linear_createIssue` or `linear_searchIssues`
2. Update status to "In Progress": `mcp__linear__linear_updateIssue`
3. Note the issue ID for later updates

Load `ff-linear` skill for detailed Linear workflow.
