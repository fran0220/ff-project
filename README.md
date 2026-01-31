# FF (Fast Flow)

Spec-driven development framework for [Amp](https://ampcode.com).

## What is FF?

FF is a lightweight framework that leverages Amp's native features to enable structured, spec-driven development workflows. It provides skills for common development phases and supports parallel execution of complex tasks.

**Key Principles:**
- Thread = Task (no external task tracking needed)
- @-mention = Context injection (no complex JSONL files)
- Skill mode = Model selection (smart/deep as appropriate)

## Installation

```bash
cd your-project
curl -fsSL https://github.com/fran0220/ff-project/raw/main/install.sh | sh
```

Options:
- `--force` - Overwrite existing files
- `--verbose` - Show detailed output
- `--ref <tag>` - Use specific version (default: main)

Example with options:
```bash
curl -fsSL https://github.com/fran0220/ff-project/raw/main/install.sh | sh -s -- --force --verbose
```

**Requirements:** `curl`, `tar`, `awk` (standard on macOS/Linux)

**File policy:**
- `.agents/skills/`, `.ff/spec/`: Skip existing files (use `--force` to overwrite)
- `AGENTS.md`: Uses managed block `<!-- ff-project:begin -->...<!-- ff-project:end -->` (safe to add content outside block)

## Skills

| Skill | Mode | Description |
|-------|------|-------------|
| `ff-start` | smart | Initialize session, read specs |
| `ff-implement` | deep | Write code with extended thinking |
| `ff-check` | deep | Review code changes |
| `ff-finish` | rush | Pre-commit checklist |
| `ff-linear` | rush | Linear issue tracking integration |
| `ff-hd` | smart | Complex multi-task coordinator |
| `ff-update` | smart | Capture learnings, update specs |

### Mode Selection Philosophy

| Mode | Strength | Use For |
|------|----------|---------|
| **smart** | Planning, coordination, decision-making | ff-start, ff-hd, ff-update |
| **deep** | Complex reasoning, code generation | ff-implement, ff-check |
| **rush** | Fast execution, simple tasks | ff-finish, ff-linear |

## Workflows

### Simple Task (Single Thread)

```
1. Load ff-start     → Read specs, understand context
2. Load ff-implement → Write code (deep mode)
3. Load ff-check     → Review changes
4. Load ff-finish    → Pre-commit checklist
```

### Complex Task (ff-hd Parallel Execution)

For multi-task features requiring brainstorming and coordinated implementation:

```
ff-hd: <task-name>

Phase 0: Resume Check    → Detect and resume interrupted work
Phase 1: Brainstorming   → Generate prd.md
Phase 2: Decomposition   → Extract tasks, identify dependencies
Phase 3: Execution       → Parallel dispatch (max 2 concurrent)
Phase 4: Review Gates    → Spec compliance + ff-check
```

## Project Structure

```
your-project/
├── .agents/
│   └── skills/
│       ├── ff-start/
│       ├── ff-implement/
│       ├── ff-check/
│       ├── ff-finish/
│       ├── ff-linear/
│       └── ff-hd/
│           ├── SKILL.md
│           └── reference/
│               ├── brainstorming.md
│               ├── prd.template.md
│               ├── task-extraction.md
│               └── task-graph.schema.json
├── .ff/
│   ├── spec/
│   │   ├── guides/
│   │   ├── shared/
│   │   ├── backend/
│   │   └── frontend/
│   ├── tasks/           # ff-hd task artifacts
│   └── .developer       # Developer identity
└── AGENTS.md            # Entry point with @-mentions
```

## Specs

FF uses a spec-driven approach. Specs are referenced via `@`-mention in AGENTS.md:

```markdown
# AGENTS.md

See @.ff/spec/guides/index.md
See @.ff/spec/shared/index.md
```

### Available Specs

- **guides/**: Thinking guides (cross-layer, code reuse, error handling)
- **shared/**: TypeScript conventions, git conventions, code quality
- **backend/**: Backend-specific patterns
- **frontend/**: Frontend-specific patterns

## ff-hd: Parallel Execution

For complex tasks with multiple subtasks:

```
"ff-hd: user-authentication"
```

### Task Complexity Modes

| Mode | Subtasks | Artifacts |
|------|----------|-----------|
| Medium | 2-4 | Markdown checklist in thread |
| Long/Hard | 5+ | task-graph.json + handoff support |

### Dependency Rules

| Pattern | Action |
|---------|--------|
| Shared types/interfaces | Serial |
| Shared API routes | Serial |
| Shared DB schema | Serial |
| Independent modules | Parallel (max 2) |

### Multi-task Parallelism

Multiple ff-hd instances can run simultaneously with different task names:

```
Thread A: "ff-hd: auth"      → .ff/tasks/2026-01-31-auth/
Thread B: "ff-hd: payment"   → .ff/tasks/2026-01-31-payment/
```

## Linear Integration

Optional integration with Linear for issue tracking. Requires system-level Linear MCP server deployment with `LINEAR_API_TOKEN` configured.

## Configuration

### Developer Identity

```bash
echo "your-name" > .ff/.developer
```

### Customizing Specs

Edit files in `.ff/spec/` to match your project's conventions:

- `shared/index.md` - Cross-project standards
- `backend/index.md` - Backend patterns
- `frontend/index.md` - Frontend patterns
- `guides/` - Thinking guides for complex decisions

## Origin

FF was migrated from [Trellis](https://github.com/anthropics/trellis) (a Claude Code framework) to leverage Amp's native features:

| Trellis | FF |
|---------|-----|
| Shell scripts | Amp skills |
| JSONL context files | @-mention |
| External task tracking | Thread = task |
| worktree.yaml | handoff tool |

## License

MIT
