---
name: ff-update
description: "Update specs from code learnings. Use after fixing bugs, discovering patterns, or establishing conventions."
mode: smart
---

# FF Update

Capture learnings and update specs to keep constraints in sync with codebase.

## When to Use

| Trigger | Action |
|---------|--------|
| Fixed a bug | Update error-handling or quality guidelines |
| Discovered a pattern | Add to patterns section |
| Hit a gotcha | Document as non-obvious behavior |
| Established convention | Update relevant spec |
| Cross-layer insight | Update thinking guides |

## Process

### Step 1: Analyze What You Learned

Ask yourself:
- What was the root cause?
- Why wasn't this caught earlier?
- How can we prevent this in the future?

### Step 2: Categorize the Learning

```
┌─────────────────────────────────────────┐
│  1. Missing spec          → Add to spec │
│  2. Cross-layer contract  → Update guide│
│  3. Change propagation    → Add checklist│
│  4. Test gap              → Document pattern│
│  5. Implicit assumption   → Make explicit│
└─────────────────────────────────────────┘
```

### Step 3: Update the Right Spec

| Learning Type | Target Spec |
|--------------|-------------|
| Backend pattern | `.ff/spec/backend/index.md` |
| Frontend pattern | `.ff/spec/frontend/index.md` |
| TypeScript convention | `.ff/spec/shared/index.md` |
| Cross-layer issue | `.ff/spec/guides/cross-layer.md` |
| Code reuse pattern | `.ff/spec/guides/code-reuse.md` |
| Error handling | `.ff/spec/guides/error-handling.md` |

### Step 4: Document the Change

Format for spec additions:

```markdown
### [Pattern/Convention Name]

**Context**: When this applies

**Rule**: What to do

**Example**:
```code
// Good
...
// Bad
...
```

**Rationale**: Why this matters
```

---

## Quick Update Templates

### Bug Fix → Spec Update

```markdown
## [Bug Category] Handling

**Issue**: [What went wrong]

**Root Cause**: [Why it happened]

**Prevention**:
- [ ] Check X before Y
- [ ] Validate Z

**Example**:
```code
// Before (bug)
...
// After (fixed)
...
```
```

### Pattern Discovery → Spec Update

```markdown
## [Pattern Name]

**When to use**: [Conditions]

**Implementation**:
```code
// Pattern code
```

**Benefits**:
- [Benefit 1]
- [Benefit 2]
```

### Convention → Spec Update

```markdown
## [Convention Name]

**Rule**: Always/Never [do X]

**Rationale**: [Why]

**Enforcement**: [How to check - lint rule, code review, etc.]
```

---

## Spec Structure Reference

```
.ff/spec/
├── guides/
│   ├── index.md              # Thinking guide overview
│   ├── cross-layer.md        # Cross-layer patterns
│   ├── code-reuse.md         # Code reuse patterns
│   └── error-handling.md     # Error handling patterns
├── shared/
│   └── index.md              # TypeScript, git, code quality
├── backend/
│   └── index.md              # Backend-specific patterns
└── frontend/
    └── index.md              # Frontend-specific patterns
```

---

## 5-Dimension Bug Analysis

When updating specs after a bug fix, analyze:

1. **Root Cause Category**
   - Missing spec
   - Cross-layer contract violation
   - Change propagation failure
   - Test gap
   - Implicit assumption

2. **Why It Wasn't Caught**
   - No lint rule
   - No type check
   - No test coverage
   - Unclear documentation

3. **Prevention Mechanism**
   - Documentation (spec update)
   - Compile-time (type, lint)
   - Runtime (validation, error handling)
   - Test (unit, integration)

4. **Systematic Check**
   - Are there similar issues elsewhere?
   - Is this a design flaw?
   - Is this a process flaw?

5. **Knowledge Capture**
   - Update which spec?
   - Create follow-up task?

---

## Checklist Before Completing

- [ ] Learning documented in correct spec file
- [ ] Example code included (good vs bad)
- [ ] Rationale explained
- [ ] Related specs cross-referenced if needed
- [ ] Consider: Should this be a lint rule instead?

## After Update

Inform the team:
- Commit spec changes with clear message
- Consider mentioning in PR description
- If significant, discuss in team channel
