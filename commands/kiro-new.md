---
name: kiro-new
description: Create a new spec-driven project with kiro.dev structure
aliases: [scaffold, new-kiro]
---

# Create New Kiro Project

Creates a spec-driven software project following kiro.dev methodology with complete scaffolding for:
- Nix/Nix Flakes, with integration with
  - Nickel Language, contracts
  - Typix (nix + typist language/project & plugins)
- Root-level CLAUDE.md with project resource map/documentation
  - .aidocs/ with kiro.dev, typix, and nickel documentation
  - .kiro/ fully defined "master" project docs; spec-driven steering and requirements/design/tasks files and instructions
  - .contracts/ mirroring repository structure with nickel code, contracts/type definitions
- Scoped/Hierarchical files to provide in-contexts implementation details in directories where code will be created:
  - CLAUDE.md that provides context for implmentation and TDD workflow support, tasks.md integration (todo-list) with RED-to-GREEN TDD best practices
  - tasks.md decomposed from the top-level tasks.md /w defined and complete test assertion sub-tasks.
  - other decomposed kiro spec-driven docs if necessary

## Usage

```
/kiro-new [project-name] [--mode=interactive|headless] [--description="project description"]
```

## Arguments

- `project-name` (required): Name of the project to scaffold
- `--mode`: Choose between `interactive` (Q&A) or `headless` (infer from description) - default: interactive
- `--description`: Project description (required for headless mode)

## Examples

**Interactive mode (default):**
```
/kiro-new my-api-service
```
Claude will guide you through a Q&A to understand your project requirements.

**Headless mode with description:**
```
/kiro-new my-api-service --mode=headless --description="A REST API service for user authentication with JWT tokens, PostgreSQL database, and Redis caching"
```
Claude will infer requirements and scaffold automatically.

## What Gets Created

### 1. Root Structure
```
project-name/
├── .git/                    # Initialized git repository
├── CLAUDE.md               # Main resource documentation
├── .aidocs/                # Dependency documentation
│   ├── kiro/              # kiro.dev spec & steering docs
│   ├── typix/             # typix/typist integration docs
│   └── nickel/            # nickel language reference
├── .kiro/                  # Project-level master files
│   ├── steering/          # High-level project direction
│   └── spec/              # Requirements, design, tasks
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
├── .contracts/            # Nickel type definitions mirroring repo
├── flake.nix              # Nix flake with typix integration
└── src/                   # Source code with scoped docs
```

### 2. Scoped Implementation Structure
Each implementation directory contains:
- Scoped `.kiro/` files decomposed from master
- Scoped `CLAUDE.md` with fine-grain implementation details
- Test specifications with assertions defined BEFORE implementation
- Nickel contracts for that scope

### 3. TDD Workflow Support
- Pre-defined test assertions for each testable piece of logic
- RED-to-GREEN workflow documentation
- Test harness setup with appropriate testing framework

## After Scaffolding

Claude will:
1. Initialize the git repository
2. Generate all documentation files
3. Set up the development environment
4. Create initial commit with scaffold
5. Display next steps for implementation

## Integration with Claude Code

This scaffold creates a project optimized for Claude Code workflows:
- **CLAUDE.md** guides Claude with project-specific context
- **.kiro/ files** enable spec-driven development
- **Scoped documentation** keeps Claude focused on current task
- **Nickel contracts** provide type safety and validation
- **TDD structure** enforces test-first development
- **Context7 MCP server** provides up-to-date library documentation
- **Workflow hooks** ensure specifications, tests, and contracts are complete

### MCP Server Integration

Projects are automatically configured with two MCP servers via `.mcp.json`:

**Context7** - Library Documentation
- Fetches up-to-date, version-specific documentation for libraries
- Eliminates outdated docs and hallucinated APIs
- Works with all libraries and frameworks
- Optional API key support for higher rate limits

**Nushell** (mcp-server-nu) - Enhanced Data Processing
- Execute Nushell scripts for markdown parsing
- Structured data handling (JSON, YAML, TOML)
- Type-safe operations with kiro.nu utility library
- Better spec validation and contract analysis

### Workflow Enforcement Hooks

Scaffolded projects include automated validation hooks:

**Spec Validation** - Blocks code changes without complete specifications
- Ensures .kiro/spec/ files exist and have content
- Prevents implementation before planning

**TDD Enforcement** - Requires tests before implementation
- Blocks implementation file changes without corresponding test files
- Validates tests have actual test cases

**Contract Validation** - Type-checks nickel contracts before commits
- Runs `nickel typecheck` on all .contracts/ files
- Prevents commits with type errors

**Documentation Sync** - Reminds to update docs after changes
- Non-blocking reminders when CLAUDE.md/README.md are stale
- Helps maintain up-to-date documentation

See the generated project's documentation for hook details and customization.

## See Also

- `/kiro-spec` - Update or regenerate spec files
- `/kiro-scope` - Create scoped implementation area
- `/kiro-eval` - Evaluate project against kiro.dev standards
