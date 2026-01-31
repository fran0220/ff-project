---
name: ff-init
description: "Initialize or update FF framework in current project. Use when starting FF or updating to latest version."
mode: smart
---

# FF Init

Initialize or update FF framework in the current project.

## Instructions for Agent

When this skill is loaded, execute the following phases:

---

## Phase 1: Detect Current State

Run these checks in parallel using Task tool:

### Task 1.1: Check FF Status
```bash
if [ -f ".ff/manifest.json" ]; then
  echo "STATUS: update"
  cat .ff/manifest.json
else
  echo "STATUS: install"
fi
```

### Task 1.2: Detect Project Type
```bash
# Check for frontend indicators
has_frontend=0
[ -f "package.json" ] && {
  [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ] || \
  [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] || \
  [ -d "src/pages" ] || [ -d "src/app" ] || [ -d "app" ]
} && has_frontend=1

# Check for backend indicators  
has_backend=0
[ -f "go.mod" ] || [ -f "pom.xml" ] || [ -f "Cargo.toml" ] || \
[ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && has_backend=1

if [ "$has_frontend" -eq 1 ] && [ "$has_backend" -eq 1 ]; then
  echo "TYPE: fullstack"
elif [ "$has_frontend" -eq 1 ]; then
  echo "TYPE: frontend"
elif [ "$has_backend" -eq 1 ]; then
  echo "TYPE: backend"
else
  echo "TYPE: unknown"
fi
```

### Task 1.3: Download Latest Templates
```bash
FF_REPO="fran0220/ff-project"
FF_REF="main"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://codeload.github.com/$FF_REPO/tar.gz/$FF_REF" | tar -xz -C "$TMP_DIR"
echo "TEMPLATES: $TMP_DIR/ff-project-main/templates"
cat "$TMP_DIR/ff-project-main/templates/ff/VERSION" 2>/dev/null || echo "VERSION: unknown"
```

---

## Phase 2: Plan Installation

Based on Phase 1 results:

1. **First Install** (no manifest.json):
   - Install all components
   - Create manifest.json
   - Create .developer file

2. **Update** (manifest.json exists):
   - Compare versions
   - Check file hashes for conflicts
   - Plan updates for changed files only

---

## Phase 3: Execute Installation

### 3.1 Install Skills
Copy from downloaded templates to `.agents/skills/`:
- ff-start, ff-implement, ff-check, ff-finish, ff-hd, ff-linear, ff-init, ff-update

### 3.2 Install Specs
Copy from downloaded templates to `.ff/spec/`:
- guides/, shared/, backend/, frontend/

### 3.3 Update AGENTS.md
Use managed block strategy:
```
<!-- ff-project:begin -->
[FF AGENTS.md content]
<!-- ff-project:end -->
```

If AGENTS.md exists, only update the managed block.
If not, create new file with managed block.

### 3.4 Create/Update Manifest
Write `.ff/manifest.json`:
```json
{
  "schema": 1,
  "ffVersion": "<version from templates>",
  "installedAt": "<ISO timestamp>",
  "updatedAt": "<ISO timestamp>",
  "projectType": "<detected type>",
  "repo": "fran0220/ff-project",
  "ref": "main",
  "managedPaths": [
    ".agents/skills/ff-*",
    ".ff/spec/",
    "AGENTS.md (managed block only)"
  ]
}
```

### 3.5 Setup Developer Identity
```bash
if [ ! -f ".ff/.developer" ]; then
  name=$(git config --get user.name 2>/dev/null || echo "${USER:-developer}")
  echo "$name" > .ff/.developer
fi
```

---

## Phase 4: Report Results

Output summary:
```
✨ FF Initialized!

Version: <version>
Project Type: <type>
Developer: <name>

Installed:
- .agents/skills/ (X skills)
- .ff/spec/ (X specs)
- AGENTS.md (managed block)

Next: load ff-start
```

---

## Conflict Handling

If a file was modified by user (hash mismatch):

1. **Auto mode** (default): Skip file, report as conflict
2. **Force mode**: Backup original, overwrite with new

Conflicts are reported at the end:
```
⚠️ Conflicts (skipped):
- .ff/spec/shared/index.md (user modified)

To resolve: Review changes and run with --force, or manually merge.
```

---

## Command Variations

User can specify mode:
- `load ff-init` - Auto mode (safe, skip conflicts)
- "ff-init force" - Force mode (backup and overwrite)
- "ff-init dry-run" - Preview changes only

---

## Cleanup

After installation, remove temp directory:
```bash
rm -rf "$TMP_DIR"
```
