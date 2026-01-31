---
name: ff-update
description: "Update FF framework templates. Use to get latest skills, specs, and tools."
mode: smart
---

# FF Update

Update FF framework templates to the latest version.

## Instructions for Agent

**When this skill is loaded, immediately run:**

```bash
sh .ff/bin/ff-update
```

Then report the results to the user.

---

## Command Options

| Mode | Command | Behavior |
|------|---------|----------|
| **Auto** (default) | `sh .ff/bin/ff-update` | Update unmodified files, skip conflicts |
| **Force** | `sh .ff/bin/ff-update --mode force` | Update all files (with backup) |
| **Dry Run** | `sh .ff/bin/ff-update --dry-run` | Preview changes without applying |
| **Verbose** | `sh .ff/bin/ff-update --verbose` | Show detailed output |

## What Gets Updated

- `.agents/skills/` - FF skills
- `.ff/spec/` - Specification templates
- `.ff/bin/` - Update tools
- `AGENTS.md` - Managed block only

## Conflict Handling

When a conflict is detected:
1. New version saved to `.ff/conflicts/<path>.ff-new`
2. User should compare and merge manually
3. Then run `--mode force` to complete update

## After Update

Tell the user to reload context:
```
load ff-start
```
