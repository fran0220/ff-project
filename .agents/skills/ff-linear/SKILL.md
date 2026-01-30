---
name: ff-linear
description: "Sync with Linear. Use when starting a task, updating progress, or completing work."
mode: rush
---

# FF Linear Integration

Sync development work with Linear issue tracking.

## Prerequisites

Set environment variable before starting Amp:

```bash
export LINEAR_API_TOKEN="lin_api_xxxxx"
```

MCP server is bundled via `mcp.json` - tools auto-register when this skill loads.

## Workflow Integration

### When Starting Work

```
┌─────────────────────────────────────────┐
│  1. Create/Find Linear Issue            │
│  2. Load ff-implement skill             │
│  3. Update issue: In Progress           │
└─────────────────────────────────────────┘
```

### During Development

```
┌─────────────────────────────────────────┐
│  - Add comments for key decisions       │
│  - Update status at milestones          │
└─────────────────────────────────────────┘
```

### When Done

```
┌─────────────────────────────────────────┐
│  1. Load ff-finish skill                │
│  2. Update issue: Done / In Review      │
│  3. Add completion comment              │
└─────────────────────────────────────────┘
```

---

## Commands

### Start Task

Create a new issue or find existing one:

```
# Create new issue
mcp__linear__linear_createIssue({
  teamId: "<team-id>",
  title: "Feature: <description>",
  description: "## Goal\n<goal>\n\n## Acceptance Criteria\n- [ ] ...",
  priority: 2  // 1=Urgent, 2=High, 3=Medium, 4=Low
})

# Or search existing
mcp__linear__linear_searchIssues({
  query: "<keyword>"
})
```

### Update Status

Change issue state:

```
# Get workflow states for team
mcp__linear__linear_getWorkflowStates()

# Update issue status
mcp__linear__linear_updateIssue({
  issueId: "<issue-id>",
  stateId: "<state-id>"  // e.g., "In Progress", "In Review", "Done"
})
```

### Add Comment

Document progress or decisions:

```
mcp__linear__linear_createComment({
  issueId: "<issue-id>",
  body: "## Progress Update\n- Implemented X\n- Next: Y"
})
```

### Complete Task

```
mcp__linear__linear_updateIssue({
  issueId: "<issue-id>",
  stateId: "<done-state-id>"
})

mcp__linear__linear_createComment({
  issueId: "<issue-id>",
  body: "## Completed\n- PR: <url>\n- Summary: <what was done>"
})
```

---

## Quick Reference

| Action | Tool |
|--------|------|
| Create issue | `linear_createIssue` |
| Find issue | `linear_searchIssues` / `linear_getIssueById` |
| Update status | `linear_updateIssue` |
| Add comment | `linear_createComment` |
| Get my issues | `linear_getIssues` |
| Get team states | `linear_getWorkflowStates` |

## Status Mapping

| FF Phase | Linear Status |
|----------|---------------|
| ff-start | Backlog / Todo |
| ff-implement | In Progress |
| ff-check | In Review |
| ff-finish | Done |

---

## Example Flow

**1. Start task:**
```
User: "I need to add user authentication"

Agent:
1. Create Linear issue
2. Note issue ID (e.g., ENG-123)
3. Update status to "In Progress"
4. Load ff-implement skill
```

**2. During implementation:**
```
Agent adds comment:
"## Implementation Started
- Using JWT for tokens
- Adding middleware for route protection"
```

**3. After ff-check passes:**
```
Agent:
1. Update status to "In Review"
2. Add comment with PR link
```

**4. After ff-finish:**
```
Agent:
1. Update status to "Done"
2. Add completion summary
```
