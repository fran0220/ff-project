# Shared Standards

> Cross-project conventions for TypeScript, code quality, git, and error handling.

---

## Table of Contents

1. [TypeScript Conventions](#typescript-conventions)
2. [Code Quality Standards](#code-quality-standards)
3. [Git Conventions](#git-conventions)
4. [Error Handling Patterns](#error-handling-patterns)

---

## TypeScript Conventions

### Strict Mode

All projects use `strict: true` in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

This enables:
- `strictNullChecks` - Null and undefined must be explicitly handled
- `strictFunctionTypes` - Function parameter types are checked strictly
- `noImplicitAny` - All types must be explicit

### Explicit Return Types

All functions must declare return types:

```typescript
// ✅ Good: Explicit return type
function processData(input: string): ProcessedData {
  // ...
}

async function fetchUser(id: string): Promise<User | null> {
  // ...
}

// ❌ Bad: Missing return type
function processData(input: string) {
  // ...
}
```

### Type Organization

| Type | Location | Purpose |
|------|----------|---------|
| Shared types | `src/types/` or `types/` | Cross-module types |
| Local types | Same file or `*.types.ts` | Component/module-specific |
| API types | `src/api/types.ts` | Request/response shapes |
| Database types | Auto-generated | Prisma/Drizzle schemas |

### Nullish Coalescing & Optional Chaining

```typescript
// ✅ Good: Nullish coalescing
const name = options.name ?? "default";

// ✅ Good: Optional chaining
const version = config?.version;

// ❌ Bad: Logical OR (treats 0, empty string as falsy)
const name = options.name || "default";
```

### Forbidden TypeScript Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| `any` | Bypasses type safety | `unknown`, generics, proper types |
| `x!` non-null assertion | Runtime null errors | Optional chaining, type guards |
| `var` | Hoisting issues | `const` or `let` |
| `// @ts-ignore` | Hides real errors | Fix the type issue |
| `as any` | Type assertion escape | Proper typing or `as unknown as T` |

---

## Code Quality Standards

### ESLint Rules

All projects enforce these rules:

```javascript
// eslint.config.js
rules: {
  "@typescript-eslint/no-explicit-any": "error",
  "@typescript-eslint/no-non-null-assertion": "error",
  "@typescript-eslint/explicit-function-return-type": "error",
  "@typescript-eslint/prefer-nullish-coalescing": "error",
  "@typescript-eslint/prefer-optional-chain": "error",
  "prefer-const": "error",
  "no-var": "error",
  "@typescript-eslint/no-unused-vars": [
    "error",
    { argsIgnorePattern: "^_", varsIgnorePattern: "^_" }
  ]
}
```

### Const by Default

```typescript
// ✅ Good: const for non-reassigned
const cwd = process.cwd();
const options: InitOptions = { force: true };

// ✅ Good: let only when reassignment needed
let developerName = options.user;
if (!developerName) {
  developerName = detectFromGit();
}

// ❌ Bad: let for non-reassigned
let cwd = process.cwd();
```

### Unused Variables

Prefix unused parameters with underscore:

```typescript
// ✅ Good: Prefixed with underscore
function handler(_req: Request, res: Response): void {
  res.send("OK");
}

// ❌ Bad: Unused without prefix
function handler(req: Request, res: Response): void {
  res.send("OK");
}
```

### Quality Checklist

Before committing:

- [ ] `pnpm lint` passes
- [ ] `pnpm typecheck` passes
- [ ] All functions have explicit return types
- [ ] No `any` types
- [ ] No `// @ts-ignore` or `// @ts-expect-error`
- [ ] Using `??` instead of `||` for defaults
- [ ] Using `const` by default

---

## Git Conventions

### Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `chore` | Build, CI, dependencies |

### Examples

```bash
# Feature
feat(auth): add OAuth2 login flow

# Bug fix
fix(api): handle null response from external service

# Breaking change
feat(api)!: change response format for /users endpoint

BREAKING CHANGE: Response now returns array instead of object
```

### Branch Naming

```
<type>/<slug>
```

Examples:
- `feat/oauth-login`
- `fix/null-response-handling`
- `refactor/auth-module`

### Pull Request Rules

1. **One logical change per PR** - Don't mix unrelated changes
2. **Passing CI** - All checks must pass before merge
3. **Descriptive title** - Use conventional commit format
4. **Link issues** - Reference related issues with `Fixes #123`

---

## Error Handling Patterns

### Top-Level Catch Pattern

Errors bubble up to the top level and are caught once:

```typescript
// Command/API handler level
async function handleRequest(req: Request, res: Response): Promise<void> {
  try {
    const result = await processRequest(req);
    res.json(result);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    res.status(500).json({ error: message });
  }
}
```

### Type Guard for Errors

Always use type guard when accessing error properties:

```typescript
// ✅ Good: Type guard
catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  console.error("Error:", message);
}

// ❌ Bad: Assuming error is Error
catch (error) {
  console.error(error.message); // TypeScript error
}
```

### Error Patterns by Situation

| Situation | Pattern | Example |
|-----------|---------|---------|
| Critical failure | Throw, let bubble up | `throw new Error("Database unavailable")` |
| Optional operation | Silent catch with comment | Git config detection |
| Recoverable error | Return result object | `{ success: false, error: "..." }` |
| Degraded operation | Warn and continue | `console.warn("Cache miss, fetching...")` |

### Silent Failure for Optional Operations

```typescript
// Optional: detect developer name from git
let developerName: string | undefined;
try {
  developerName = execSync("git config user.name", {
    encoding: "utf-8",
  }).trim();
} catch {
  // Git not available - silently ignore, will prompt later
}
```

### Result Objects

```typescript
interface Result<T> {
  success: boolean;
  data?: T;
  error?: string;
}

function parseConfig(path: string): Result<Config> {
  if (!fs.existsSync(path)) {
    return { success: false, error: "Config file not found" };
  }
  
  try {
    const data = JSON.parse(fs.readFileSync(path, "utf-8"));
    return { success: true, data };
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : "Parse failed" 
    };
  }
}
```

### DO / DON'T

#### DO
- Catch errors at the top level (command/API handlers)
- Use `error instanceof Error` type guard
- Use empty catch for truly optional operations (with comment)
- Return result objects for recoverable errors
- Log errors with context

#### DON'T
- Don't catch errors in utility functions unless you can handle them
- Don't assume `error` is an `Error` type
- Don't swallow errors silently without explaining why
- Don't re-throw errors without adding context
- Don't log full stack traces to users

---

## Quick Reference

### Imports

```typescript
// ✅ Good: Named imports, organized
import { type User, type Config } from "./types";
import { processData, validateInput } from "./utils";

// ❌ Bad: Default imports for non-default exports
import utils from "./utils";
```

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Utilities | camelCase | `formatDate.ts` |
| Types | camelCase or PascalCase | `user.types.ts` |
| Tests | `.test.ts` suffix | `formatDate.test.ts` |
| Constants | SCREAMING_SNAKE | `API_BASE_URL` |

### Pre-Modification Rule

> **Before changing ANY value, search first!**

```bash
grep -r "value_to_change" .
```

This prevents "forgot to update X" bugs.
