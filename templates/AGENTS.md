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

### Simple Task

```
1. Load ff-start     → Read specs, understand context
2. Load ff-implement → Write code (deep mode)
3. Load ff-check     → Review changes (deep mode)
4. Load ff-finish    → Pre-commit checklist
```

### Complex Task (ff-hd)

```
ff-hd: <task-name>

Phase 0: Resume      → Detect interrupted work
Phase 1: Brainstorm  → Generate prd.md
Phase 2: Decompose   → Extract tasks
Phase 3: Execute     → Parallel dispatch
Phase 4: Review      → Gates + ff-check
```

## Developer

Check `.ff/.developer` for current developer identity.
