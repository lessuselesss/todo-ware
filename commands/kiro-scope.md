---
name: kiro-scope
description: Create a scoped implementation area with decomposed specs and local CLAUDE.md
aliases: [scope, new-scope]
---

# Create Scoped Implementation Area

Creates a scoped implementation directory with:
- Decomposed kiro specs from master files
- Scoped CLAUDE.md with fine-grain implementation details
- Test specification templates with pre-defined assertions
- Local nickel contracts
- TDD workflow setup

## Usage

```
/kiro-scope <path> [--from-task=<task-id>] [--description="scope description"]
```

## Arguments

- `path` (required): Directory path for the new scope (e.g., `src/auth`, `lib/database`)
- `--from-task`: Task ID from master tasks.md to decompose
- `--description`: Brief description of what this scope implements

## Examples

**Create scope for authentication module:**
```
/kiro-scope src/auth --from-task=AUTH-001 --description="JWT-based authentication with refresh tokens"
```

**Create scope for database layer:**
```
/kiro-scope lib/database --description="PostgreSQL connection pool and query builder"
```

## What Gets Created

```
<path>/
├── CLAUDE.md                       # Implementation workflow
└── .kiro-scope/                    # Scoped specifications
    ├── scoped-tasks.md             # Decomposed tasks from master
    ├── assertions.md               # TDD assertions (RED-GREEN-REFACTOR)
    ├── context.md                  # How module fits in project
    └── contracts/                  # Nickel type definitions (optional)
        └── (mirrors parent directory structure)
```

This structure follows the **kiro structural invariant**:

> Any directory containing source files MUST have:
> 1. `CLAUDE.md` - Implementation workflow
> 2. `.kiro-scope/` directory with required files

## Scope Generation Process

When you run `/kiro-scope`, Claude will:

1. **Create Directory Structure**
   - Create `<path>/` directory
   - Create `<path>/CLAUDE.md`
   - Create `<path>/.kiro-scope/` directory

2. **Generate scoped-tasks.md**
   - Extract tasks from `.kiro/spec/tasks.md` matching `--from-task`
   - Decompose into implementation steps
   - Add traceability metadata (parent_requirement, parent_design)
   - Include frontmatter with `decomposed_from`, `parent_tasks`, `module`

3. **Generate assertions.md**
   - Extract high-level acceptance criteria from tasks
   - Create detailed TDD assertions with RED-GREEN-REFACTOR phases
   - Use assertion ID convention: `TASK-###--A#` (double-dash!)
   - Each assertion includes test code, expected failure, implementation guidance

4. **Generate context.md**
   - Explain module purpose
   - Show position in architecture (ASCII diagram)
   - List dependencies (internal/external/stdlib)
   - List dependents
   - Define key interfaces (exports/imports)
   - Document design decisions
   - Define testing strategy

5. **Generate CLAUDE.md**
   - Implementation workflow steps
   - Current status tracking for each task
   - References to `.kiro-scope/` files
   - Key decisions and notes

6. **Validate Structure**
   - Run contract validation on all generated files
   - Ensure assertion IDs follow `TASK-###--A#` pattern
   - Verify frontmatter has required fields
   - Check context.md has all 7 required sections

## Contract Validation

After generating scope files, the command automatically validates:

### Structure Validation (via `.contracts/schema/scope-directory.ncl`)
- ✓ `CLAUDE.md` exists in parent directory
- ✓ `.kiro-scope/` directory exists
- ✓ Required files present: `scoped-tasks.md`, `assertions.md`, `context.md`

### Assertion ID Validation (via `.contracts/validation/assertion-ids.ncl`)
- ✓ All assertion IDs match `TASK-###--A#` pattern (double-dash!)
- ✓ Assertion IDs reference valid task IDs
- ✓ Task IDs match `MODULE-###` pattern

### Document Validation
- ✓ `scoped-tasks.md` has required frontmatter fields
- ✓ `assertions.md` has parent_task frontmatter
- ✓ `context.md` has all 7 required sections
- ✓ All frontmatter is valid YAML

Use Nushell to validate manually:

```bash
# Validate entire scope
nu -c "use tools/kiro.nu *; validate-scope-full 'src/auth'"

# Validate just assertion IDs
nu -c "use tools/kiro.nu *; validate-assertion-id 'AUTH-001--A3'"

# Find all scoped directories
nu -c "use tools/kiro.nu *; find-scoped-directories"
```

## TDD Workflow Integration

Each scoped area follows RED-to-GREEN:

1. **RED**: Write failing tests based on assertions.md
2. **GREEN**: Implement minimal code to pass tests
3. **REFACTOR**: Improve code while keeping tests green
4. **REPEAT**: Next test from assertions.md

## Best Practices

- Create scopes at logical boundaries (modules, features, layers)
- Keep scopes focused and cohesive
- Update scoped specs as implementation progresses
- Maintain contract alignment with code structure
- Commit scope creation separately for clean history

## See Also

- `/kiro-new` - Create new kiro project
- `/kiro-spec` - Update spec files
- `/kiro-eval` - Evaluate project standards
