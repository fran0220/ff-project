# Task Extraction Guidelines

## From PRD to Tasks

### Step 1: Parse Acceptance Criteria

Each acceptance criterion typically maps to 1-2 tasks:

```
PRD Criterion: "Users can filter by date range"
    ↓
Tasks:
- T1: Add date picker component
- T2: Implement filter API endpoint
- T3: Connect UI to API
```

### Step 2: Count Tasks → Determine Mode

```
If tasks <= 4: Medium mode
   → Track in thread as markdown checklist
   → No task-graph.json

If tasks >= 5: Long/Hard mode
   → Generate task-graph.json
   → Enable resume support
```

### Step 3: Detect Dependencies (Simple Rules)

**Serial Boundaries** (always force serial):

| Pattern | Examples |
|---------|----------|
| Shared types | `types/`, `interfaces/`, `*.d.ts` |
| Shared API | `api/routes/`, `server/routes/` |
| Shared DB | `schema/`, `migrations/`, `prisma/` |
| Shared state | Redux store, Zustand, context files |
| Same feature layer | Frontend + Backend for same endpoint |

**Parallel OK**:
- Independent modules
- Separate features
- Test files (usually)

---

## Task Granularity

### Good Task Size

- **Outcome**: One clear, testable result
- **Files**: 1-3 files modified
- **Time**: 5-15 minutes for agent
- **Criteria**: 1-3 acceptance criteria

### Too Big

❌ "Implement entire authentication system"
✅ Split into:
- T1: Add auth middleware
- T2: Create login endpoint
- T3: Create logout endpoint
- T4: Add session management

### Too Small

❌ "Add import statement"
✅ Combine into meaningful unit:
- "Add date formatting utility with tests"

---

## Task Template (Simplified)

**Medium mode (in thread)**:
```markdown
## Tasks

- [ ] T0: Add date picker component
- [ ] T1: Implement filter API endpoint  
- [ ] T2: Connect UI to API (depends: T0, T1)
```

**Long/Hard mode (task-graph.json)**:
```json
{
  "version": "1.1",
  "prd_path": ".ff/tasks/2026-01-31-filters/prd.md",
  "tasks": [
    {
      "id": "T0",
      "title": "Add date picker component",
      "depends_on": [],
      "acceptance": "Component renders and emits date range",
      "status": "todo"
    },
    {
      "id": "T1", 
      "title": "Implement filter API endpoint",
      "depends_on": [],
      "acceptance": "GET /api/filters returns filtered data",
      "status": "todo"
    },
    {
      "id": "T2",
      "title": "Connect UI to API",
      "depends_on": ["T0", "T1"],
      "acceptance": "Date picker triggers API call",
      "status": "todo"
    }
  ]
}
```

---

## Dependency Graph Example

```
PRD: "Add user search with filters"

Tasks:
T0: Add search API endpoint (no deps)
T1: Add filter types (no deps)
T2: Add search UI component (depends: T1)
T3: Connect UI to API (depends: T0, T2)
T4: Add tests (depends: T3)

Graph:
T0 ──────────────┐
                 ├──→ T3 ──→ T4
T1 ──→ T2 ───────┘

Execution:
Round 1: T0, T1 (parallel)
Round 2: T2 (after T1)
Round 3: T3 (after T0, T2)
Round 4: T4 (after T3)
```

---

## Scheduling Example

```
Ready tasks: [T0, T1, T2]

T0: frontend component (no deps)
T1: backend API (no deps)
T2: connect UI to API (depends: T0, T1)

Round 1: Dispatch T0, T1 (parallel, max 2)
         - Different layers, no shared contracts
         
Round 2: Wait for T0, T1 to complete

Round 3: Dispatch T2 (serial, has dependencies)

Done.
```

**max_parallel = 2** keeps things manageable and reduces conflict risk.
