---
name: ff-check
description: "Review code with deep reasoning. Use after implementation or for code review."
mode: deep
---

# FF Check

Multi-dimensional code review with deep reasoning.

## Before Review

**Read the relevant specs:**

- @.ff/spec/guides/index.md
- @.ff/spec/shared/index.md

For backend: @.ff/spec/backend/index.md
For frontend: @.ff/spec/frontend/index.md

---

## Review Process

### Step 1: See What Changed

```bash
git status
git diff
```

### Step 2: Run Quality Checks

```bash
pnpm lint
pnpm typecheck
pnpm test
```

### Step 3: Multi-Dimensional Review

Review changes through **5 dimensions** to prevent "didn't think of it" bugs:

---

## Dimension A: Cross-Layer Data Flow

Check data consistency across layers (API → Service → UI).

| Check | Question |
|-------|----------|
| Read path | Does data flow correctly from source to display? |
| Write path | Does mutation propagate correctly to all consumers? |
| Type consistency | Are types identical across layer boundaries? |
| Error propagation | Are errors handled at each layer? |
| Loading states | Are loading/error/empty states handled? |

**Common Issues:**
- API returns `snake_case`, UI expects `camelCase`
- Error in service layer not surfaced to UI
- Missing loading state causes flash of empty content

---

## Dimension B: Code Reuse

Check for duplication and proper abstraction.

### B1: Constants & Configuration

| Check | Question |
|-------|----------|
| Magic values | Are hardcoded values extracted to constants? |
| Config duplication | Is config defined in one place? |
| Environment vars | Are env vars properly typed and validated? |

### B2: Utility Functions

Before creating new utility:
```
1. Search codebase for similar functionality
2. Check if existing util can be extended
3. Only create new if truly unique
```

### B3: Batch Modifications

When changing a pattern:
```bash
# Find all occurrences
grep -r "pattern" --include="*.ts"

# Ensure ALL instances are updated
```

---

## Dimension C: Import & Dependencies

| Check | Question |
|-------|----------|
| Import paths | Are relative/absolute paths correct? |
| Circular deps | Any circular import chains? |
| Barrel exports | Are index.ts files updated? |
| Unused imports | Any dead imports? |

**Detection:**
```bash
# Check for circular dependencies (if tool available)
npx madge --circular src/

# Check unused exports
npx ts-prune
```

---

## Dimension D: Same-Layer Consistency

| Check | Question |
|-------|----------|
| Naming | Does naming match existing patterns? |
| Structure | Does file structure match similar features? |
| Patterns | Are established patterns followed? |
| Conventions | Are team conventions respected? |

**Example Checks:**
- New API route follows same structure as existing routes
- New component follows same prop naming as similar components
- New hook follows same return pattern as existing hooks

---

## Dimension E: Edge Cases & Error States

| Check | Question |
|-------|----------|
| Null/undefined | Are null cases handled? |
| Empty arrays | Is empty state handled? |
| Network errors | Are API failures handled? |
| Validation | Is user input validated? |
| Boundaries | Are array bounds checked? |

---

## Quick Checklist

### Code Quality
- [ ] No `any` types
- [ ] No `console.log` statements
- [ ] No `// @ts-ignore`
- [ ] Proper error handling
- [ ] Tests pass
- [ ] Lint passes

### Cross-Layer (Dimension A)
- [ ] Types consistent across boundaries
- [ ] Errors propagate correctly
- [ ] Loading states handled

### Code Reuse (Dimension B)
- [ ] No magic values
- [ ] No duplicated utilities
- [ ] All occurrences updated (batch changes)

### Dependencies (Dimension C)
- [ ] Import paths correct
- [ ] No circular dependencies
- [ ] Exports updated

### Consistency (Dimension D)
- [ ] Naming matches patterns
- [ ] Structure matches similar code
- [ ] Conventions followed

### Edge Cases (Dimension E)
- [ ] Null/empty handled
- [ ] Errors handled
- [ ] Validation present

---

## Self-Fix Loop

```
Issue Found
    ↓
Fix the issue
    ↓
Run checks again (lint, typecheck, test)
    ↓
Re-verify dimension checklist
    ↓
Repeat until all pass
```

---

## When Done

All dimensions verified → Load `ff-finish` skill

If learned something new → Load `ff-update` skill to capture learnings
