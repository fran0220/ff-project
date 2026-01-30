# Brainstorming Guidelines

## Question Patterns

### One Question at a Time
Never ask multiple questions. Break complex topics into sequential questions.

❌ Bad:
```
"What's the problem and who are the users?"
```

✅ Good:
```
"What problem are we solving?
A) Performance issue
B) Missing feature
C) Workflow improvement
D) Other"

[wait for answer]

"Who are the primary users?
A) End users
B) Developers
C) Admins"
```

### Multiple Choice Preferred

When possible, provide options:

```
"Which approach do you prefer?

**A) Server-side rendering**
- Pros: SEO, initial load
- Cons: Server cost, complexity

**B) Client-side rendering**
- Pros: Simpler, cheaper
- Cons: SEO issues

**C) Hybrid (SSR + CSR)**
- Pros: Best of both
- Cons: Most complex"
```

### Open-ended When Necessary

For exploratory questions:

```
"Describe the current pain point in your own words."
```

---

## PRD Section Templates

### 1. Problem Statement (200-300 words)

```markdown
## Problem

**Current State**: [What exists today]

**Pain Point**: [Specific problem users face]

**Impact**: [Business/user impact if unsolved]

**Root Cause**: [Why this problem exists]
```

### 2. Users & Use Cases

```markdown
## Users

**Primary**: [Main user type]
- Use case: [How they'll use this]
- Frequency: [Daily/weekly/etc]

**Secondary**: [Other users]
- Use case: [How they'll use this]
```

### 3. Non-goals

```markdown
## Non-goals (Out of Scope)

- ❌ [Thing we're NOT doing]
- ❌ [Another thing explicitly excluded]
- ❌ [Future consideration, not now]
```

### 4. Approach Options

```markdown
## Approaches Considered

### Option A: [Name]
- **How**: [Brief description]
- **Pros**: [Benefits]
- **Cons**: [Drawbacks]
- **Effort**: S/M/L

### Option B: [Name]
...

### Option C: [Name]
...
```

### 5. Chosen Approach

```markdown
## Chosen Approach: [Option X]

**Rationale**: [Why this option]

**Key Decisions**:
1. [Decision 1 and why]
2. [Decision 2 and why]

**Trade-offs Accepted**:
- [Trade-off we're okay with]
```

### 6. Acceptance Criteria

```markdown
## Acceptance Criteria

### Must Have
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### Should Have
- [ ] [Criterion 3]

### Nice to Have
- [ ] [Criterion 4]
```

### 7. Risks & Mitigations

```markdown
## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [How to handle] |
```

---

## Validation Pattern

After each section, confirm:

```
"Here's the Problem Statement:

[content]

Does this capture the problem correctly?
A) Yes, move on
B) Needs adjustment (please specify)"
```
