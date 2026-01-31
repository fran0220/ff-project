#!/bin/bash
# FF Framework Validation Script

set -e

echo "=== FF Framework Validation ==="
echo ""

# Check directory structure
echo "1. Checking directory structure..."

required_files=(
  ".agents/skills/ff-start/SKILL.md"
  ".agents/skills/ff-implement/SKILL.md"
  ".agents/skills/ff-check/SKILL.md"
  ".agents/skills/ff-finish/SKILL.md"
  ".agents/skills/ff-linear/SKILL.md"
  ".agents/skills/ff-hd/SKILL.md"
  ".agents/skills/ff-hd/reference/brainstorming.md"
  ".agents/skills/ff-hd/reference/task-extraction.md"
  ".agents/skills/ff-hd/reference/task-graph.schema.json"
  ".agents/skills/ff-hd/reference/prd.template.md"
  ".ff/spec/guides/index.md"
  ".ff/spec/shared/index.md"
  "AGENTS.md"
)

missing=0
for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ $file (MISSING)"
    missing=$((missing + 1))
  fi
done

echo ""

# Check skill frontmatter
echo "2. Checking skill frontmatter..."

check_frontmatter() {
  local file=$1
  local expected_name=$2
  local expected_mode=$3
  
  if grep -q "name: $expected_name" "$file" && grep -q "mode: $expected_mode" "$file"; then
    echo "  ✓ $expected_name (mode: $expected_mode)"
  else
    echo "  ✗ $expected_name - frontmatter mismatch"
    missing=$((missing + 1))
  fi
}

check_frontmatter ".agents/skills/ff-start/SKILL.md" "ff-start" "smart"
check_frontmatter ".agents/skills/ff-implement/SKILL.md" "ff-implement" "deep"
check_frontmatter ".agents/skills/ff-check/SKILL.md" "ff-check" "deep"
check_frontmatter ".agents/skills/ff-finish/SKILL.md" "ff-finish" "rush"
check_frontmatter ".agents/skills/ff-linear/SKILL.md" "ff-linear" "rush"
check_frontmatter ".agents/skills/ff-hd/SKILL.md" "ff-hd" "smart"

echo ""

# Check AGENTS.md references
echo "3. Checking AGENTS.md spec references..."

if grep -q "@.ff/spec" "AGENTS.md"; then
  echo "  ✓ Spec @-mentions found"
else
  echo "  ✗ No spec @-mentions"
  missing=$((missing + 1))
fi

echo ""

# Summary
echo "=== Validation Summary ==="
if [ $missing -eq 0 ]; then
  echo "✓ All checks passed!"
  exit 0
else
  echo "✗ $missing issue(s) found"
  exit 1
fi
