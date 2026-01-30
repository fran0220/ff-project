---
name: ff-hd
description: "Handle complex tasks with parallel execution. Use for multi-task features requiring brainstorming, task decomposition, and coordinated implementation."
mode: deep
argument-hint: "<task-name>"
---

# FF HD (High-Density Parallel Execution)

Handle complex, multi-task features through structured phases.

## Invocation

**Must specify task name:**

```
ff-hd: <task-name>
```

Examples:
- `ff-hd: user-authentication`
- `ff-hd: payment-integration`
- `ff-hd: refactor-logging`

Task name is used for:
1. Directory: `.ff/tasks/{date}-{task-name}/`
2. Resume matching in Phase 0
3. Avoiding conflicts with parallel tasks

## Contract (Non-negotiable)

1. **Task name required**: No anonymous tasks
2. **5 phases**: Resume → Brainstorming → Decomposition → Execution → Review
3. **Thread is primary artifact**: Post phase summaries in thread
4. **Review gates**: Spec compliance + ff-check
5. **Dependency-aware scheduling**: max_parallel=2, serial for shared contracts

## Task Complexity Modes

| Mode | Subtasks | Session | Artifacts |
|------|----------|---------|-----------|
| **Medium** | 2-4 | Single | Markdown checklist in thread |
| **Long/Hard** | 5+ | Multi | task-graph.json + handoff support |

## Artifacts Location

```
.ff/tasks/{YYYY-MM-DD}-{name}/
├── prd.md            # Phase 1 output
└── task-graph.json   # Phase 2 output (long/hard only)
```

---

## Phase 0: Resume Check

**Goal**: Detect and resume interrupted work for the specified task.

```
1. Extract task-name from invocation (e.g., "ff-hd: user-auth" → "user-auth")
2. Search .ff/tasks/*-{task-name}/ for matching directory
3. If found with incomplete tasks in task-graph.json:
   → Show progress: "Found existing task: 3/5 done"
   → Ask: "Resume from T3?"
   → If yes: Skip to Phase 3 with remaining tasks
4. If no match found: Proceed to Phase 1 (new task)
```

**Multi-task isolation**: Each task name maps to exactly one directory, allowing parallel ff-hd instances on different tasks.

---

## Phase 1: Brainstorming

**Goal**: Transform requirement into structured PRD.

**Interaction Pattern**:
- Ask ONE question at a time
- Prefer multiple choice when possible
- If open-ended, keep focused

**Output Sections** (200-300 words each):
1. Problem Statement
2. Users & Use Cases
3. Non-goals (explicitly out of scope)
4. Approach Options (2-3 with trade-offs)
5. Chosen Approach (with rationale)
6. Acceptance Criteria
7. Risks & Mitigations

**Exit Criteria**:
- User confirms each section
- `prd.md` written to task directory
- **Post phase summary in thread**

**Example Questions**:
```
"What problem are we solving? Options:
A) Performance issue in X
B) Missing feature Y
C) User workflow improvement
D) Other (please describe)"

"Who are the primary users?
A) End users
B) Developers
C) Admins
D) Multiple (specify)"
```

---

## Phase 2: Task Decomposition

**Goal**: Extract actionable tasks with dependency awareness.

**Process**:
1. Parse `prd.md` acceptance criteria
2. Count subtasks to determine complexity mode
3. Identify dependencies using simple rules

**Complexity Decision**:
```
If subtasks <= 4: Medium mode
   → Use markdown checklist in thread
   → No task-graph.json needed

If subtasks >= 5: Long/Hard mode
   → Generate task-graph.json
   → Enable handoff/resume support
```

**Dependency Rules (Simple)**:

| Pattern | Action |
|---------|--------|
| Shared types/interfaces | Serial |
| Shared API routes | Serial |
| Shared DB schema | Serial |
| Frontend + Backend for same feature | Serial |
| Independent modules | Parallel (max 2) |

**Task Granularity**:
- One clear outcome per task
- Bounded file scope (1-3 files)
- Testable acceptance criteria

**Exit Criteria**:
- All tasks have clear acceptance criteria
- Dependencies identified
- **Post task list summary in thread**
- task-graph.json written (long/hard mode only)

---

## Phase 3: Parallel Execution

**Goal**: Execute tasks respecting dependencies.

**Scheduling Algorithm**:
```
1. Find ready tasks (no pending dependencies)
2. Apply parallel rules:
   - max_parallel = 2
   - Shared contract boundary → force serial
3. Dispatch via Task tool
4. Update status, post progress in thread
5. Repeat until all done
```

**Per-Task Dispatch** (minimal context):
```
Task(
  prompt: "Implement: {task.title}
  
  Acceptance Criteria:
  {task.acceptance_criteria}
  
  Context: @.ff/spec/shared/index.md
  [Only include backend OR frontend spec, not both]
  
  Constraints:
  - Follow ff-implement guidelines
  - Do NOT modify files outside scope
  - Run lint/typecheck when done",
  
  description: "{task.id}: {task.title}"
)
```

**Serial Boundaries** (always force serial):
- `types/`, `interfaces/`, `*.d.ts`
- `api/routes`, `server/routes`
- `schema/`, `migrations/`
- Shared state files

**Exit Criteria**:
- All tasks status="done"
- No lint/typecheck errors
- **Post execution summary in thread**

---

## Phase 4: Review Gates

**Goal**: Ensure quality before completion.

### Gate 1: Spec Compliance

Verify implementation matches `prd.md`:
- [ ] All acceptance criteria met
- [ ] No extra features added (YAGNI)
- [ ] Edge cases handled per spec

**If fails**: Return to Phase 3 for fixes, then re-review.

### Gate 2: Quality (= ff-check)

Load `ff-check` skill which verifies:
- [ ] Follows project patterns
- [ ] Proper error handling
- [ ] No `any` types
- [ ] lint/typecheck/test pass

**If fails**: Fix issues, re-run ff-check.

**Exit Criteria**:
- Gate 1 passes (spec compliance)
- Gate 2 passes (ff-check)
- **Post final summary in thread**
- Ready for `ff-finish`

---

## Integration Points

| Skill | Integration |
|-------|-------------|
| `ff-start` | Optional preflight (load specs) |
| `ff-implement` | Task execution guidelines |
| `ff-check` | Gate 2 in Phase 4 |
| `ff-finish` | After all gates pass |
| `ff-linear` | Optional: sync PRD to Linear issue |
| `handoff` | For long/hard tasks: transfer to new thread |

---

## Failure Recovery

| Failure | Recovery |
|---------|----------|
| Phase 1 ambiguity | Ask more clarifying questions |
| Phase 2 unclear deps | Return to Phase 1 for refinement |
| Phase 3 task fails | Debug, fix, re-run task |
| Phase 4 review fails | Return to Phase 3, then re-review |
| Session interrupted | Phase 0 resumes from task-graph.json |

---

## Handoff Support (Long/Hard Mode)

When task spans multiple sessions:

```
1. End current session:
   → Ensure task-graph.json is updated
   → Post handoff summary in thread

2. New session:
   → Load ff-hd
   → Phase 0 detects existing task-graph.json
   → Resume from last completed task
```

---

## Quick Reference

```
User: "ff-hd: user-auth"
    ↓
Phase 0: Check .ff/tasks/*-user-auth/ → Resume if found
    ↓
Phase 1: Brainstorm → .ff/tasks/{date}-user-auth/prd.md
    ↓
Phase 2: Decompose → checklist (medium) or task-graph.json (long/hard)
    ↓
Phase 3: Execute (max_parallel=2, serial for shared contracts)
    ↓
Phase 4: Gate 1 (spec) + Gate 2 (ff-check) → ff-finish
```

**Parallel tasks**: Multiple ff-hd instances can run simultaneously with different task names.
