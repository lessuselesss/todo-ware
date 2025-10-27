---
name: kiro-spec
description: Update or regenerate kiro spec files based on current project state
aliases: [spec-update, refresh-spec]
---

# Update Kiro Spec Files

Updates or regenerates the master kiro specification files in `.kiro/spec/` based on:
- Current project state
- New requirements or changes
- Implementation progress
- User input

## Usage

```
/kiro-spec [--scope=master|<path>] [--type=requirements|design|tasks|all]
```

## Arguments

- `--scope`: Which spec to update
  - `master`: Update project-level master specs (default)
  - `<path>`: Update scoped specs for specific directory
- `--type`: Which spec file to update
  - `requirements`: Update requirements.md
  - `design`: Update design.md
  - `tasks`: Update tasks.md
  - `all`: Update all spec files (default)

## Examples

**Update all master specs:**
```
/kiro-spec
```

**Update only design document:**
```
/kiro-spec --type=design
```

**Update scoped specs for a module:**
```
/kiro-spec --scope=src/auth --type=tasks
```

## What It Does

1. **Analyzes Current State**
   - Reviews existing code
   - Checks test coverage
   - Examines git history
   - Identifies completed vs pending tasks

2. **Updates Specifications**
   - Marks completed tasks
   - Adds new requirements if needed
   - Updates design based on implementation
   - Maintains traceability

3. **Propagates Changes**
   - Updates scoped specs that depend on master
   - Ensures consistency across decomposed specs
   - Updates CLAUDE.md if needed

4. **Validates Against Standards**
   - Checks spec format compliance
   - Verifies nickel contract alignment
   - Ensures TDD structure maintained

## Integration with Workflow

Use this command:
- After completing major features
- When requirements change
- Before starting new implementation phase
- During code reviews
- To keep specs synchronized with reality

## See Also

- `/kiro-new` - Create new kiro project
- `/kiro-scope` - Create scoped implementation area
- `/kiro-eval` - Evaluate project standards compliance
