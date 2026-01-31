# FF Project

Spec-driven development with optimal Amp modes.

## Specs

See @.ff/spec/guides/index.md
See @.ff/spec/shared/index.md

## Skills

| Skill | Mode | When |
|-------|------|------|
| `ff-start` | smart | Begin session |
| `ff-implement` | deep | Write code |
| `ff-check` | deep | Review code |
| `ff-finish` | rush | Before commit |
| `ff-linear` | rush | Sync with Linear |
| `ff-hd` | smart | Complex multi-task (coordinator) |
| `ff-update` | smart | Capture learnings, update specs |

## Workflows

### Simple Task (Single Thread)

```
1. Load ff-start     → Read specs, understand context
2. Load ff-implement → Write code (deep mode)
3. Load ff-check     → Review changes (deep mode)
4. Load ff-finish    → Pre-commit checklist
```

### Complex Task (Parallel Execution)

```
1. Load ff-hd        → 4-phase workflow:
   ├─ Phase 1: Brainstorming → prd.md
   ├─ Phase 2: Task Decomposition → task-graph.json
   ├─ Phase 3: Parallel Execution (via Task tool)
   └─ Phase 4: Review Gates → ff-check → ff-finish
```

Use `ff-hd` when:
- Multiple independent subtasks
- Cross-layer changes (frontend + backend)
- Needs requirement clarification first

## Linear Integration (Optional)

If using Linear MCP for issue tracking, load `ff-linear` skill for setup.

Status mapping:
- ff-start → In Progress
- ff-check → In Review  
- ff-finish → Done

## Developer

Check `.ff/.developer` for current developer identity.

To set: `echo "your-name" > .ff/.developer`

## Rules

1. **Read specs before coding** - Skills reference specs via @-mention
2. **Use deep mode for code** - ff-implement and ff-check use deep mode
3. **One task per thread** - Keep threads focused
4. **Never commit directly** - Use ff-finish first
