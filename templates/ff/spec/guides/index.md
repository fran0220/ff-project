# Thinking Guides

> Expand your thinking to catch things you might not have considered.

---

## Why Thinking Guides?

**Most bugs come from "didn't think of that"**, not lack of skill:

- Didn't think about layer boundaries → cross-layer bugs
- Didn't think about code patterns → duplication
- Didn't think about edge cases → runtime errors
- Didn't think about maintainers → unreadable code

**30 minutes of thinking saves 3 hours of debugging.**

---

## Available Guides

| Guide | Purpose | When to Use |
|-------|---------|-------------|
| [Cross-Layer Thinking](./cross-layer.md) | Data flow across layers | Features spanning API/Service/UI |
| [Code Reuse](./code-reuse.md) | Reduce duplication | Repeated patterns |
| [Error Handling](./error-handling.md) | Robust error flows | Any error-prone code |

---

## Quick Triggers

### Cross-Layer Issues
- [ ] Feature touches 3+ layers
- [ ] Data format changes between layers
- [ ] Multiple consumers need same data
→ Read [Cross-Layer Guide](./cross-layer.md)

### Code Reuse
- [ ] Writing similar code to existing
- [ ] Same pattern repeated 3+ times
- [ ] Creating new utility function
→ Read [Code Reuse Guide](./code-reuse.md)

---

## Pre-Modification Rule

> **Before changing ANY value, search first!**

```bash
grep -r "value_to_change" .
```

This prevents most "forgot to update X" bugs.
