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
├── .local.kiro/                     # Project-level Kiro Specs for Spec-Driven Implementation
│   ├── spec/      
│   │   ├── requirements.md    # 
│   │   ├── design.md          # 
│   │   └── tasks.md           # 
│   └── steering/              # 
├── CLAUDE.md                  # Implementation guidance
├── .contracts/                # Nickel contracts & type definitions
├── tests/
│   └── assertions.md          # Pre-defined test assertions
└── README.md                  # Module documentation
```

## Scope Decomposition Process

1. **Extract Relevant Requirements**
   - Identifies requirements from master that apply to this scope
   - Creates focused requirements document
   - Maintains traceability to master

2. **Design Decomposition**
   - Extracts relevant design decisions
   - Adds scope-specific design details
   - Documents interfaces and contracts

3. **Task Breakdown**
   - Decomposes high-level tasks into implementation steps
   - Orders tasks for TDD workflow
   - Defines acceptance criteria

4. **Test Specification**
   - Creates test templates
   - Defines assertions BEFORE implementation
   - Sets up test harness

5. **Contract Definition**
   - Creates nickel type definitions
   - Mirrors scope's code structure
   - Defines input/output contracts

## Scoped CLAUDE.md Contents

The scoped CLAUDE.md includes:
- **Context**: What this scope implements and why
- **Dependencies**: Other scopes and external dependencies
- **Contracts**: Types and interfaces defined here
- **Testing Strategy**: How to test this scope
- **Implementation Notes**: Specific guidance for Claude
- **TDD Workflow**: RED-to-GREEN steps for this scope

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
