# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**kiro-scaffold** is a Claude Code plugin that implements the kiro.dev spec-driven development methodology. It scaffolds projects with formal specifications, TDD workflows, Nickel contracts, and automated validation hooks.

## Architecture

### Three-Layer Validation System

The plugin enforces the kiro methodology through a three-layer architecture:

1. **Specification Layer** (`.contracts/` - Nickel)
   - Defines valid kiro structures formally
   - Assertion ID format: `TASK-###--A#` (double-dash separator is critical!)
   - Structural invariant: CLAUDE.md + .kiro-scope/ required
   - See [docs/CONTRACTS.md](docs/CONTRACTS.md) for complete reference

2. **Validation Layer** (`tools/kiro.nu` - Nushell)
   - 20+ validation functions referencing contracts
   - Filesystem structure checking
   - Cross-file traceability validation
   - See [docs/NUSHELL.md](docs/NUSHELL.md) for function reference

3. **Generation Layer** (`commands/`, `agents/`, `skills/`)
   - Slash commands: `/kiro-new`, `/kiro-scope`, `/kiro-spec`, `/kiro-eval`
   - Agents: Kiro Architect, TDD Coach, Kiro Evaluator
   - Skills: Auto-activate for scaffolding and TDD guidance

### Critical Structural Invariant

**Any directory with source files MUST have:**
1. `CLAUDE.md` - Implementation workflow
2. `.kiro-scope/` directory containing:
   - `scoped-tasks.md` (frontmatter: decomposed_from, parent_tasks, module)
   - `assertions.md` (frontmatter: parent_task, methodology)
   - `context.md` (7 required sections: Purpose, Position in Architecture, Dependencies, Dependents, Key Interfaces, Design Decisions, Testing Strategy)

This is enforced by `.contracts/schema/scope-directory.ncl`.

### Assertion ID Convention (CRITICAL)

**Format:** `TASK-###--A#` with **DOUBLE-DASH** separator

Examples:
- ✓ `AUTH-001--A3` (correct)
- ✗ `AUTH-001-A3` (single dash - INVALID)
- ✗ `AUTH-001_A3` (underscore - INVALID)

The double-dash enables unambiguous parsing: `task_id, assertion_num = id.split("--")`.

Defined in `.contracts/validation/assertion-ids.ncl` and validated by `tools/kiro.nu` functions.

## Plugin Development Workflow

### Testing Changes

```bash
# 1. Uninstall current version
/plugin uninstall kiro-scaffold-dev

# 2. Reinstall from local path
/plugin install kiro-scaffold-dev@dev-plugins

# 3. Test commands
/kiro-new test-project --mode=headless --description="Test scaffolding"
/kiro-scope src/test --from-task=TEST-001

# 4. Validate generated structures
nu -c "use tools/kiro.nu *; validate-scope-full 'src/test'"
nu -c "use tools/kiro.nu *; validate-assertion-id 'TEST-001--A1'"
```

### Contract Validation

```bash
# Validate a single nickel contract
nickel typecheck .contracts/validation/assertion-ids.ncl

# Validate all contracts
for f in .contracts/**/*.ncl; nickel typecheck $f; done

# Test contract against data
echo '"AUTH-001--A3"' | nickel eval --validate .contracts/validation/assertion-ids.ncl
```

### Nushell Utilities Testing

```bash
# Source kiro.nu and test functions
nu -c "
  use tools/kiro.nu *

  # Test ID validation
  validate-assertion-id 'AUTH-001--A3'

  # Test scope validation
  validate-scope-full 'src/auth'

  # Find all scoped directories
  find-scoped-directories
"
```

## File Structure

```
kiro-scaffold/
├── .contracts/              # Nickel contracts (methodology specification)
│   ├── validation/          # ID patterns, markdown, traceability
│   ├── schema/              # Generated project structure definitions
│   └── plugin/              # Plugin self-specification
├── commands/                # Slash commands (*.md) - MUST be at root!
├── agents/                  # Specialized agents (*.md) - MUST be at root!
├── skills/                  # Autonomous skills (*/SKILL.md) - MUST be at root!
├── hooks/                   # Workflow enforcement
│   ├── hooks.json          # Hook configuration
│   ├── scripts/            # Bash implementations
│   └── scripts-nu/         # Nushell implementations
├── tools/
│   └── kiro.nu             # Nushell utility library (20+ functions)
├── docs/                    # Detailed documentation
│   ├── CONTRACTS.md        # Contract reference
│   ├── NUSHELL.md          # Nushell utilities guide
│   └── HOOKS.md            # Hook documentation
└── .mcp.json               # MCP servers (Context7, Nushell)
```

**CRITICAL:** `commands/`, `agents/`, `skills/` MUST be at plugin root, NOT inside `.claude-plugin/`!

## Component Types

### Commands (`commands/*.md`)

Slash commands with YAML frontmatter:
- `name` - Command name (without slash)
- `description` - Short description
- `aliases` - Alternative names (optional)

Contract: `.contracts/plugin/command.ncl`

### Agents (`agents/*.md`)

Specialized AI agents with YAML frontmatter:
- `description` - Agent purpose
- `capabilities` - List of capabilities

Contract: `.contracts/plugin/agent.ncl`

### Skills (`skills/*/SKILL.md`)

Auto-activating workflows. Each skill is a directory with SKILL.md inside.

### Hooks (`hooks/`)

Event-driven validation:
- **PreToolUse** hooks on Write/Edit: Spec validation, TDD enforcement
- **PreToolUse** hooks on Bash: Contract validation
- **PostToolUse** hooks on Write/Edit: Documentation sync reminder

Both bash (`.sh`) and Nushell (`.nu`) implementations provided.

## Key Concepts

### TDD Workflow (RED-GREEN-REFACTOR)

Assertions in `assertions.md` follow three phases:
- **RED Phase:** Write failing test, document expected failure
- **GREEN Phase:** Minimal implementation to pass test
- **REFACTOR Phase:** Improve code (optional)

Each assertion has ID `TASK-###--A#` linking to parent task.

### Traceability Chain

```
REQ-002 (Requirement in .kiro/spec/requirements.md)
  └─> DES-003 (Design in .kiro/spec/design.md)
      └─> AUTH-001 (Task in .kiro/spec/tasks.md)
          ├─> AUTH-001--A1 (Assertion in scoped assertions.md)
          ├─> AUTH-001--A2
          └─> AUTH-001--A3
```

Validated by `.contracts/validation/traceability.ncl`.

### Context7 Integration

MCP server for fetching up-to-date library documentation. Configured in `.mcp.json`.

Users can fetch docs for any library at their specific version, eliminating hallucinated APIs.

## Common Tasks

### Adding a New Contract

1. Create `.contracts/{validation|schema|plugin}/new-contract.ncl`
2. Follow existing patterns (use imports from `validation/`)
3. Add validation functions
4. Update `docs/CONTRACTS.md` with examples
5. Add Nushell validation function to `tools/kiro.nu`
6. Test: `nickel typecheck .contracts/path/to/new-contract.ncl`

### Adding a New Command

1. Create `commands/new-command.md` with frontmatter
2. Follow contract: `.contracts/plugin/command.ncl`
3. Include Usage, Arguments, Examples, What Gets Created sections
4. Test: `/new-command <args>`

### Adding a New Nushell Function

1. Add to `tools/kiro.nu` with `export def function-name []`
2. Use existing functions as building blocks
3. Reference contracts in `.contracts/` for validation logic
4. Document in `docs/NUSHELL.md`
5. Test: `nu -c "use tools/kiro.nu *; function-name 'arg'"`

### Modifying Hooks

1. Edit both `hooks/scripts/*.sh` and `hooks/scripts-nu/*.nu`
2. Update `hooks/hooks.json` if changing matcher or timeout
3. Test by triggering the hook condition (Write, Edit, Bash)
4. Document behavior in `docs/HOOKS.md`

## Validation Commands

```bash
# Validate assertion ID format
nu -c "use tools/kiro.nu *; validate-assertion-id 'AUTH-001--A3'"

# Validate scope directory structure
nu -c "use tools/kiro.nu *; validate-scope-structure 'src/auth'"

# Full scope validation (structure + all files)
nu -c "use tools/kiro.nu *; validate-scope-full 'src/auth'"

# Find all scoped directories in project
nu -c "use tools/kiro.nu *; find-scoped-directories"

# Validate specific scoped files
nu -c "use tools/kiro.nu *; validate-assertions-file 'src/auth/.kiro-scope/assertions.md'"
nu -c "use tools/kiro.nu *; validate-scoped-tasks-file 'src/auth/.kiro-scope/scoped-tasks.md'"
nu -c "use tools/kiro.nu *; validate-context-file 'src/auth/.kiro-scope/context.md'"

# Check contract coverage
nu -c "use tools/kiro.nu *; check-contract-coverage"

# Generate quality report
nu -c "use tools/kiro.nu *; generate-quality-report"
```

## Important Conventions

1. **Always use double-dash in assertion IDs** - `TASK-###--A#` not `TASK-###-A#`
2. **Maintain traceability** - Every scoped file references parent via frontmatter
3. **Seven required sections in context.md** - Purpose, Position in Architecture, Dependencies, Dependents, Key Interfaces, Design Decisions, Testing Strategy
4. **YAML frontmatter validation** - All spec files need valid frontmatter
5. **Component locations** - commands/, agents/, skills/ at plugin root, never nested

## Documentation

- **README.md** - Plugin overview, installation, quick start
- **docs/CONTRACTS.md** - Complete Nickel contracts reference
- **docs/NUSHELL.md** - Nushell utilities documentation
- **docs/HOOKS.md** - Workflow hooks guide
- **CONTRIBUTING.md** - Development setup and guidelines
- **CHANGELOG.md** - Version history

## MCP Servers

Configured in `.mcp.json`:
- **context7** - Up-to-date library documentation (@upstash/context7-mcp)
- **nushell** - Nushell script execution (mcp-server-nu)

The Nushell MCP server loads `tools/kiro.nu` via `--nu-config` flag for enhanced markdown/spec validation.

## Plugin Metadata

Version: 1.2.0 (see `.claude-plugin/plugin.json`)

Components:
- 4 commands (/kiro-new, /kiro-scope, /kiro-spec, /kiro-eval)
- 3 agents (Kiro Architect, TDD Coach, Kiro Evaluator)
- 2 skills (Project Scaffolder, TDD Workflow Guide)
- 4 hooks (Spec validation, TDD enforcement, Contract validation, Docs sync)
- 2 MCP servers (Context7, Nushell)
- 20+ Nushell utilities

## Related Resources

- [kiro.dev documentation](https://kiro.dev/docs/)
- [Nickel language](https://nickel-lang.org/)
- [Claude Code plugins docs](https://docs.claude.com/en/docs/claude-code/plugins)
