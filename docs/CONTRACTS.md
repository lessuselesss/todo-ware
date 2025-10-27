# Kiro Contracts Documentation

This document describes the Nickel contracts that formally define the kiro.dev methodology for spec-driven development.

## Overview

Kiro uses a **three-layer architecture** to ensure structural correctness:

1. **Specification Layer** (Nickel contracts) - Defines what is valid
2. **Validation Layer** (Nushell scripts) - Checks filesystem and cross-file constraints
3. **Generation Layer** (Commands) - Creates valid structures

## Contract Organization

```
.contracts/
├── validation/          # Reusable validation predicates
│   ├── assertion-ids.ncl    # Task and assertion ID patterns
│   ├── markdown.ncl         # Markdown document structure
│   └── traceability.ncl     # Cross-reference validation
├── schema/              # Generated project structure
│   ├── assertions.ncl       # TDD assertions format
│   ├── scoped-tasks.ncl     # Decomposed tasks format
│   ├── context.ncl          # Module context format
│   ├── claude-md.ncl        # CLAUDE.md workflow format
│   └── scope-directory.ncl  # Directory structure invariant
└── plugin/              # Plugin self-specification
    ├── command.ncl          # Command file format
    └── agent.ncl            # Agent file format
```

## Core Validation Contracts

### Assertion IDs (`validation/assertion-ids.ncl`)

The kiro methodology uses a specific ID convention for traceability:

**Task IDs**: `MODULE-###`
- Example: `AUTH-001`, `API-042`, `DATA-003`
- Module name in UPPERCASE
- Three-digit number

**Assertion IDs**: `TASK-###--A#` (DOUBLE-DASH!)
- Example: `AUTH-001--A3`, `API-042--A15`
- Task ID followed by double-dash (`--`)
- Assertion number with `A` prefix

The double-dash separator is **critical** for unambiguous parsing.

#### Example Usage

```nickel
let ids = import ".contracts/validation/assertion-ids.ncl" in

# Validate a task ID
"AUTH-001" | ids.TaskId  # ✓ Valid
"auth-001" | ids.TaskId  # ✗ Invalid (lowercase)
"AUTH-1" | ids.TaskId    # ✗ Invalid (not 3 digits)

# Validate an assertion ID
"AUTH-001--A3" | ids.AssertionId  # ✓ Valid
"AUTH-001-A3" | ids.AssertionId   # ✗ Invalid (single dash)
"AUTH-001_A3" | ids.AssertionId   # ✗ Invalid (underscore)

# Parse assertion ID
let parsed = ids.parse_assertion_id "AUTH-001--A3" in
# Returns: { task: "AUTH-001", assertion: "A3", full: "AUTH-001--A3" }

# Check if assertion matches task
ids.assertion_matches_task "AUTH-001--A3" "AUTH-001"  # true
ids.assertion_matches_task "AUTH-001--A3" "AUTH-002"  # false
```

### Markdown Documents (`validation/markdown.ncl`)

Validates markdown document structure including frontmatter, sections, and heading hierarchy.

#### Example Usage

```nickel
let md = import ".contracts/validation/markdown.ncl" in

# Define a document structure
let doc = {
  frontmatter = {
    title = "My Document",
    date = "2025-10-26",
  },
  sections = [
    { level = 1, title = "Introduction", content = "..." },
    { level = 2, title = "Background", content = "..." },
  ],
} in

# Validate has required sections
md.has_sections doc ["Introduction", "Background"]  # true
md.has_sections doc ["Conclusion"]  # false

# Check heading hierarchy
md.validate_heading_hierarchy doc.sections  # true/false
```

### Traceability (`validation/traceability.ncl`)

Validates cross-references between specification documents.

#### Example Usage

```nickel
let trace = import ".contracts/validation/traceability.ncl" in

# Validate assertions reference valid tasks
let tasks = [
  { id = "AUTH-001", ... },
  { id = "AUTH-002", ... },
] in
let assertions = [
  { id = "AUTH-001--A1", ... },
  { id = "AUTH-001--A2", ... },
  { id = "AUTH-999--A1", ... },  # Orphaned!
] in

trace.validate_assertion_references assertions tasks  # false
trace.find_orphaned_assertions assertions tasks
# Returns: [{ id = "AUTH-999--A1", ... }]
```

## Schema Contracts

### Assertions Document (`schema/assertions.ncl`)

Defines the structure of `assertions.md` files following RED-to-GREEN TDD methodology.

#### Document Structure

```nickel
{
  frontmatter = {
    parent_task = "AUTH-001",
    methodology = "RED-to-GREEN",
  },
  assertions = [
    {
      id = "AUTH-001--A1",
      task_id = "AUTH-001",
      description = "Valid credentials produce token",
      red = {
        test_code = "...",
        expected_failure = "Function not implemented",
      },
      green = {
        implementation = "Implement generate_token()",
        test_passes = true,
      },
      refactor = {  # Optional
        improvements = "Extract token signing to separate function",
      } | optional,
    },
  ],
}
```

#### Example Markdown

```markdown
---
parent_task: AUTH-001
methodology: RED-to-GREEN
---

# Auth Module Assertions

## AUTH-001--A1: Valid credentials produce token

**RED Phase:**
```python
def test_generate_token_with_valid_user():
    token = generate_token("user_123")
    assert token is not None
```
Expected failure: Function `generate_token` not implemented

**GREEN Phase:**
Implement minimal `generate_token()` function
✓ Test passes

**REFACTOR:**
Extract token signing logic to `_sign_jwt()` helper
✓ Tests still pass
```

### Scoped Tasks Document (`schema/scoped-tasks.ncl`)

Defines tasks decomposed from master `.kiro/spec/tasks.md`.

#### Document Structure

```nickel
{
  frontmatter = {
    decomposed_from = ".kiro/spec/tasks.md",
    parent_tasks = ["AUTH-001", "AUTH-002"],
    module = "auth",
  },
  tasks = [
    {
      id = "AUTH-001",
      parent_requirement = "REQ-002",
      parent_design = "DES-003",
      description = "Implement JWT token generation",
      acceptance_criteria = [
        "Valid credentials produce signed JWT tokens",
        "Tokens contain required claims",
      ],
      dependencies = [],
      status = 'pending,
    },
  ],
}
```

### Context Document (`schema/context.ncl`)

Defines how a module fits into the project architecture.

#### Required Sections

1. **Purpose** - What this module does and why
2. **Position in Architecture** - How it fits in the system (ASCII diagram encouraged)
3. **Dependencies** - What this module depends on (internal/external/stdlib)
4. **Dependents** - What depends on this module
5. **Key Interfaces** - Exports and imports
6. **Design Decisions** - Important architectural choices
7. **Testing Strategy** - How to test this module

#### Document Structure

```nickel
{
  frontmatter = {
    module_name = "auth",
    scope_path = "src/auth",
  },
  purpose = "Provides authentication and authorization...",
  architecture = "...",  # ASCII diagram
  dependencies = {
    internal = [
      { module = "src/models/user.py", reason = "User model", type = 'internal },
    ],
    external = [
      { module = "PyJWT", reason = "JWT token operations", type = 'external },
    ],
  },
  dependents = [
    { module = "src/api/routes", usage = "Protects routes with @require_auth" },
  ],
  interfaces = {
    exports = [
      { name = "generate_token", signature = "(user_id: str) -> str", description = "..." },
    ],
    imports = [
      { name = "User", from_module = "src/models/user", description = "..." },
    ],
  },
  design_decisions = [
    {
      decision = "Use RS256 instead of HS256",
      rationale = "Enables public key verification",
      alternatives = "HS256 (symmetric)",
    },
  ],
  testing_strategy = {
    unit_tests = "Test token generation/validation in isolation",
    integration_tests = "Test middleware with mock requests",
    coverage_target = 90,
  },
}
```

### CLAUDE.md Document (`schema/claude-md.ncl`)

Defines implementation workflow for a module.

#### Document Structure

```nickel
{
  frontmatter = {
    module_name = "auth",
    scope_path = "src/auth",
  },
  workflow = {
    description = "Follow TDD workflow with scoped specs",
    steps = [
      {
        step_number = 1,
        description = "Review scoped-tasks.md",
        reference = ".kiro-scope/scoped-tasks.md",
      },
      {
        step_number = 2,
        description = "Implement RED-GREEN-REFACTOR cycle",
        reference = ".kiro-scope/assertions.md",
      },
    ],
    kiro_scope_reference = ".kiro-scope/",
  },
  current_status = {
    summary = "AUTH-001 in progress",
    tasks = [
      { task_id = "AUTH-001", status = 'in_progress },
      { task_id = "AUTH-002", status = 'pending },
    ],
    next_steps = ["Complete AUTH-001--A3", "Start AUTH-002"],
  },
  key_decisions = [
    {
      title = "Use PyJWT library",
      description = "...",
      date = "2025-10-26",
    },
  ],
}
```

### Scope Directory (`schema/scope-directory.ncl`)

Defines the **structural invariant** of kiro:

> **ANY directory containing source files MUST have:**
> 1. `CLAUDE.md` (implementation workflow)
> 2. `.kiro-scope/` directory with:
>    - `scoped-tasks.md`
>    - `assertions.md`
>    - `context.md`

#### Directory Layout

```
my-module/
├── CLAUDE.md                    # Required
├── source-file.py               # Implementation
└── .kiro-scope/                 # Required
    ├── scoped-tasks.md          # Required
    ├── assertions.md            # Required
    ├── context.md               # Required
    └── contracts/               # Optional (but recommended)
        └── source-file.ncl
```

#### Validation

```nickel
let scope = import ".contracts/schema/scope-directory.ncl" in

# Validate directory follows kiro structure
let layout = {
  path = "src/auth",
  has_source_files = true,
  scope_structure = {
    has_claude_md = true,
    has_kiro_scope_dir = true,
    required_files = {
      scoped_tasks = true,
      assertions = true,
      context = true,
    },
  },
} in

scope.validate_directory layout  # true
```

## Plugin Contracts

### Command Files (`plugin/command.ncl`)

Defines structure for command documentation (`commands/*.md`).

#### Example Structure

```markdown
---
name: kiro-scope
description: Create a scoped implementation area
aliases: [scope, new-scope]
---

# Create Scoped Implementation Area

Creates a scoped implementation directory...

## Usage

/kiro-scope <path> [--from-task=<task-id>]

## Arguments

- `path` (required): Directory path

## Examples

**Create auth scope:**
/kiro-scope src/auth --from-task=AUTH-001
```

### Agent Files (`plugin/agent.ncl`)

Defines structure for agent documentation (`agents/*.md`).

#### Example Structure

```markdown
---
description: Interactive project architect for kiro scaffolding
capabilities: ["requirements-gathering", "project-design"]
---

# Kiro Architect Agent

## Role and Expertise
...

## When to Invoke This Agent
...

## Capabilities
...
```

## Using Contracts

### Runtime Validation

Commands use contracts to validate generated files:

```bash
# Validate an assertions.md file
nickel eval --validate .contracts/schema/assertions.ncl < src/auth/.kiro-scope/assertions.md
```

### Nushell Integration

Nushell scripts reference contracts for validation:

```nushell
# tools/validate-scope.nu
def validate-assertions [path: string] {
    let contract_path = ".contracts/schema/assertions.ncl"
    let file_path = $"($path)/.kiro-scope/assertions.md"

    # Use nickel to validate
    nickel eval --validate $contract_path < $file_path
}
```

### Generation

Commands read contracts to know what to generate:

```nushell
# Generate scope structure based on contract
def generate-scope [module: string] {
    let spec = nickel eval ".contracts/schema/scope-directory.ncl" --field generate_structure_spec --arg $module

    # Create directories and files based on spec
    mkdir $spec.required.kiro_scope_dir
    touch $spec.required.claude_md
    touch $spec.required.scoped_tasks
    touch $spec.required.assertions
    touch $spec.required.context
}
```

## Best Practices

### 1. Always Use Double-Dash for Assertions

```
✓ AUTH-001--A3  (correct)
✗ AUTH-001-A3   (wrong - single dash)
✗ AUTH-001_A3   (wrong - underscore)
```

### 2. Maintain Traceability

Every scoped file must reference its parent:

```nickel
# scoped-tasks.md frontmatter
{
  decomposed_from = ".kiro/spec/tasks.md",
  parent_tasks = ["AUTH-001"],  # References to master tasks
}
```

### 3. Complete All Required Sections

Context.md requires 7 sections. Don't skip any.

### 4. Validate Before Committing

Use hooks to ensure validity:

```bash
# .git/hooks/pre-commit
nickel eval --validate .contracts/schema/assertions.ncl < .kiro-scope/assertions.md
```

### 5. Keep Contracts in Sync

When updating methodology, update contracts first, then implementation.

## Troubleshooting

### "Field not found" errors

Ensure all required fields are present:

```nickel
# Missing optional field - use `| optional`
refactor | RefactorPhase | optional
```

### Type mismatch errors

Check enum values match contract:

```nickel
status = 'pending  # Correct (symbol)
status = "pending"  # Wrong (string)
```

### Import errors

Use relative imports from contract location:

```nickel
# In .contracts/schema/assertions.ncl
let ids = import "../validation/assertion-ids.ncl" in
```

## Version History

- **v1.0.0** (2025-10-26): Initial contract definitions
  - Core validation contracts
  - Schema contracts for generated projects
  - Plugin self-specification

## See Also

- [Nickel Language Documentation](https://nickel-lang.org/)
- [Kiro Methodology](https://kiro.dev/)
- [NUSHELL.md](NUSHELL.md) - Nushell integration
- [HOOKS.md](HOOKS.md) - Workflow enforcement
