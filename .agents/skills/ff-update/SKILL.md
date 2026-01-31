---
name: ff-update
description: "Update FF framework to latest version. Alias for ff-init."
mode: smart
---

# FF Update

Update FF framework to the latest version.

## Instructions for Agent

**This skill is an alias for ff-init.**

When loaded, immediately load ff-init skill:

```
load ff-init
```

The ff-init skill will:
1. Detect current FF installation
2. Download latest templates
3. Update changed files (skip user-modified files)
4. Report results

For force update (overwrite user changes):
```
"ff-init force"
```
