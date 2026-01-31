---
name: ff-update
description: "Update FF framework templates. Use to get latest skills, specs, and tools."
mode: smart
---

# FF Update

Update FF framework templates to the latest version.

## Quick Start

Run the update engine:

```bash
sh .ff/bin/ff-update
```

## Modes

| Mode | Command | Behavior |
|------|---------|----------|
| **Auto** (default) | `sh .ff/bin/ff-update` | Update unmodified files, skip conflicts |
| **Force** | `sh .ff/bin/ff-update --mode force` | Update all files (with backup) |
| **Dry Run** | `sh .ff/bin/ff-update --dry-run` | Preview changes without applying |

## What Gets Updated

| Path | Description |
|------|-------------|
| `.agents/skills/` | FF skills (ff-start, ff-implement, etc.) |
| `.ff/spec/` | Specification templates |
| `.ff/bin/` | Update tools and utilities |
| `AGENTS.md` | Managed block only (your content outside is preserved) |

## Conflict Handling

When you've modified a template file and there's a new version:

1. **Auto mode**: Skips the file, saves new version to `.ff/conflicts/<path>.ff-new`
2. **You review**: Compare your version with `.ff-new`
3. **Merge manually**: Apply changes you want
4. **Force update**: Run `--mode force` to accept all new templates

## Backups

All overwritten files are backed up to:
```
.ff/backups/<timestamp>/
```

## Version Tracking

Check current version:
```bash
cat .ff/.version
```

Check for updates:
```bash
sh .ff/bin/ff-update --dry-run
```

## Workflow Integration

```
┌─────────────────────────────────────┐
│  1. Check for updates (--dry-run)   │
│  2. Review what will change         │
│  3. Run update (auto or force)      │
│  4. If conflicts, merge manually    │
│  5. load ff-start (reload context)  │
└─────────────────────────────────────┘
```

## Options

| Option | Description |
|--------|-------------|
| `--mode auto` | Update only unmodified files (default) |
| `--mode force` | Update all files with backup |
| `--dry-run` | Show what would be done |
| `--verbose` | Show detailed output |
| `--ref <ref>` | Use specific git ref (tag/branch) |

## After Update

After updating, reload the context:
```
load ff-start
```

This ensures Amp picks up any changes to skills and specs.
