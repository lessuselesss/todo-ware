# Kiro Scaffold Plugin for Claude Code

A comprehensive Claude Code plugin for creating spec-driven software projects using [kiro.dev](https://kiro.dev/) methodology with typix integration, nickel contracts, and TDD workflows.

## Overview

This plugin enables you to scaffold projects with:

- 📋 **Spec-Driven Development**: Requirements, design, and tasks defined before implementation
- 🔒 **Type Safety**: Nickel language contracts mirroring your repository structure
- ✅ **TDD Workflows**: Test-Driven Development with RED-to-GREEN best practices
- 🛠️ **Nix Integration**: Reproducible development environments via typix
- 📚 **Comprehensive Documentation**: CLAUDE.md and .aidocs for context-aware AI assistance
- 🎯 **Scoped Implementation**: Break down projects into manageable, well-specified scopes
- 📖 **Context7 Integration**: Up-to-date library documentation via MCP server
- 🔐 **Workflow Enforcement**: Automated hooks ensure specs, tests, and contracts are complete

## Features

### Slash Commands

- `/kiro-new` - Create a new spec-driven project (interactive or headless mode)
- `/kiro-spec` - Update or regenerate specification files
- `/kiro-scope` - Create scoped implementation areas with decomposed specs
- `/kiro-eval` - Evaluate project quality and standards compliance

### Specialized Agents

- **Kiro Architect** - Interactive project design through Q&A
- **Kiro Evaluator** - Quality assessment and standards validation  
- **TDD Coach** - Test-Driven Development guidance

### Autonomous Skills

- **Kiro Project Scaffolder** - Automatically activates when creating spec-driven projects
- **TDD Workflow Guide** - Automatically guides through RED-to-GREEN development

### MCP Servers

- **Context7** - Up-to-date, version-specific documentation for libraries and frameworks
- **Nushell** (mcp-server-nu) - Execute Nushell scripts for enhanced markdown parsing and structured data handling

### Workflow Hooks

- **Spec Validation** - Blocks code changes without complete specifications
- **TDD Enforcement** - Requires tests before implementation
- **Contract Validation** - Type-checks nickel contracts before commits
- **Documentation Sync** - Reminds to update docs after significant changes

## Installation

### Quick Install

```bash
# Add the marketplace
/plugin marketplace add <your-marketplace-url>

# Install the plugin
/plugin install kiro-scaffold
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/kiro-scaffold.git
   ```

2. Create a local marketplace:
   ```bash
   cd /path/to/your/marketplaces
   mkdir -p kiro-plugins
   cd kiro-plugins
   ```

3. Create `marketplace.json`:
   ```json
   {
     "name": "kiro-plugins",
     "plugins": {
       "kiro-scaffold": {
         "source": "path:/path/to/kiro-scaffold"
       }
     }
   }
   ```

4. Add and install:
   ```bash
   /plugin marketplace add /path/to/kiro-plugins
   /plugin install kiro-scaffold@kiro-plugins
   ```

## Quick Start

### Create Your First Kiro Project

**Interactive Mode** (Recommended for first-time use):

```bash
/kiro-new my-api-service
```

Claude will guide you through a Q&A to understand your requirements and generate a complete project scaffold.

**Headless Mode** (Autonomous inference):

```bash
/kiro-new my-api-service --mode=headless --description="A REST API for user authentication with JWT tokens, PostgreSQL database, and Redis caching"
```

Claude will analyze your description and generate an appropriate scaffold.

### Generated Project Structure

```
my-api-service/
├── .git/                      # Initialized repository
├── CLAUDE.md                  # AI assistant context
├── README.md                  # Project documentation
├── flake.nix                  # Nix environment with typix
├── .aidocs/                   # Reference documentation
│   ├── kiro/                 # kiro.dev methodology
│   ├── typix/                # typix/typist integration
│   └── nickel/               # nickel language reference
├── .kiro/                     # Master specifications
│   ├── steering/             # Project direction
│   └── spec/
│       ├── requirements.md   # What to build
│       ├── design.md         # How to build it
│       └── tasks.md          # Implementation tasks
├── .contracts/                # Nickel type definitions
│   └── (mirrors src/ structure)
└── src/                       # Source code
    └── (scoped implementation areas)
```

### Implementing a Feature with TDD

1. **Create a scoped implementation area**:
   ```bash
   /kiro-scope src/auth --from-task=AUTH-001 --description="JWT authentication"
   ```

2. **Claude will guide you through**:
   - Creating test assertions
   - Writing failing tests (RED)
   - Implementing minimal code (GREEN)
   - Refactoring safely

3. **Update specs as you go**:
   ```bash
   /kiro-spec --scope=src/auth
   ```

### Evaluate Project Quality

```bash
# Terminal report
/kiro-eval

# Generate HTML dashboard
/kiro-eval --report=html --output=quality-dashboard.html

# CI/CD integration
/kiro-eval --report=markdown --output=quality-report.md
```

## Workflow Example

### Complete Feature Implementation Flow

```bash
# 1. Create project
/kiro-new user-service

# [Interactive Q&A with Kiro Architect]

# 2. Create first implementation scope
/kiro-scope src/models --from-task=DATA-001

# 3. Claude TDD Coach automatically activates:
# "Let's start with the User model. I found assertions in assertions.md.
#  First failing test: User creation with valid data..."

# 4. Implement following RED-GREEN-REFACTOR cycle
# [Claude guides through each test]

# 5. Create next scope
/kiro-scope src/api --from-task=API-001

# 6. Evaluate progress
/kiro-eval

# 7. Update specs based on implementation
/kiro-spec

# 8. Continue with next feature...
```

## Key Concepts

### Spec-Driven Development

Write specifications **before** code:

1. **Requirements** - What needs to be built (WHAT)
2. **Design** - How it will be built (HOW)  
3. **Tasks** - Implementation breakdown (STEPS)

Benefits:
- Shared understanding across team
- Clear acceptance criteria
- Prevents scope creep
- Enables parallel work
- Better AI assistance (Claude knows the context)

### Scoped Implementation

Large projects decomposed into manageable scopes:

- Each scope has focused specifications
- Decomposed from master specs (traceability)
- Self-contained with local CLAUDE.md
- Independent development possible
- Easier to test and validate

### Nickel Contracts

The plugin includes **formal Nickel contracts** that define the kiro methodology:

**Plugin-level contracts** (`.contracts/` in plugin repo):
- Define what makes a valid kiro project structure
- Validate assertion ID format: `TASK-###--A#` (double-dash!)
- Enforce structural invariant: CLAUDE.md + .kiro-scope/
- Type-check generated specifications

**Project-level contracts** (`.contracts/` in generated projects):
- Mirror source code structure
- Define application types and interfaces
- Runtime validation via typix integration

Example plugin contract:

```nickel
# .contracts/validation/assertion-ids.ncl
{
  AssertionId = String
    | std.string.is_match "^[A-Z]+-[0-9]{3}--A[0-9]+$"
    | doc "Format: TASK-###--A# with DOUBLE-DASH (e.g., AUTH-001--A3)",
}
```

Example project contract:

```nickel
# my-project/.contracts/auth/user.ncl
{
  User = {
    id: String,
    email: String,
    | email | std.string.is_match "^[a-zA-Z0-9._%+-]+@.*$",
  },
}
```

Benefits:
- **Methodology enforcement** - Automated validation of kiro structures
- **Type safety** - Catch errors before runtime
- **Self-documenting** - Contracts serve as formal specification
- **Better AI assistance** - Claude knows exactly what's valid

See [docs/CONTRACTS.md](docs/CONTRACTS.md) for complete reference.

### TDD Workflow (RED-to-GREEN)

1. **RED**: Write a failing test
   - Based on assertions.md
   - Clear expected behavior
   - Fails for right reason

2. **GREEN**: Minimal implementation
   - Just enough to pass test
   - Don't optimize yet
   - Focus on correctness

3. **REFACTOR**: Improve code
   - Tests are safety net
   - Improve structure
   - Keep tests passing

4. **REPEAT**: Next test from assertions.md

Benefits:
- Better design (testable code)
- Confidence in changes
- Living documentation
- Fewer bugs

## Best Practices

### For Solo Developers

- Use headless mode for quick scaffolds
- Start with minimal scopes
- Iterate on specs as you learn
- Use /kiro-eval to maintain quality

### For Teams

- Use interactive mode for shared understanding
- Review and approve specs before implementation
- Standardize on nickel contracts early
- Set up CI/CD with /kiro-eval
- Configure repo-level plugin installation:

```json
// .claude/settings.json
{
  "plugins": {
    "enabled": ["kiro-scaffold"]
  }
}
```

### For Large Projects

- Create detailed master specs upfront
- Decompose into many small scopes
- Assign scopes to team members
- Use /kiro-spec to track progress
- Regular /kiro-eval runs
- Maintain contract coverage above 80%

## Evaluation Criteria

Projects are evaluated on:

### Generated Project Quality (70%)
- Structure compliance (25%)
- Specification completeness (20%)
- Contract coverage (15%)
- TDD setup (10%)

### Skill Correctness (20%)
- Documentation quality (10%)
- Integration health (10%)

### Workflow Effectiveness (10%)
- Process metrics (5%)
- Developer experience (5%)

**Target Score**: 70+ (Good), 90+ (Excellent)

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Kiro Quality Check

on: [push, pull_request]

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Claude Code
        run: |
          # Install Claude Code
          curl -sSL https://install.claude.sh | sh
      
      - name: Install Kiro Plugin
        run: |
          claude /plugin marketplace add <your-marketplace>
          claude /plugin install kiro-scaffold
      
      - name: Run Quality Evaluation
        run: |
          claude /kiro-eval --report=markdown --output=quality-report.md
      
      - name: Check Quality Threshold
        run: |
          score=$(grep "Overall Score" quality-report.md | grep -oP '\d+')
          if [ $score -lt 70 ]; then
            echo "Quality score $score below threshold 70"
            exit 1
          fi
      
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: quality-report
          path: quality-report.md
```

## Context7 MCP Server

### What is Context7?

Context7 is an MCP server that automatically fetches up-to-date, version-specific documentation for libraries and frameworks. It eliminates outdated docs and hallucinated APIs by pulling current documentation directly into Claude's context.

### Features

- ✅ **Always Current** - Fetches latest official documentation
- ✅ **Version-Specific** - Matches your project's library versions
- ✅ **Zero Context Switching** - No tab-switching to read docs
- ✅ **Works with All Libraries** - Supports any library with online docs

### Configuration

Context7 is automatically configured in all kiro projects via `.mcp.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {
        "DEFAULT_MINIMUM_TOKENS": "${DEFAULT_MINIMUM_TOKENS:-10000}",
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    }
  }
}
```

### Using Context7

Context7 provides MCP tools that Claude can invoke to fetch documentation:

```bash
# Context7 automatically provides documentation tools
# Claude can fetch docs for libraries as needed

# Example: When working with FastAPI
# Claude can fetch current FastAPI documentation
# to ensure accurate code generation
```

### Optional: API Key Setup

For higher rate limits and private repository access:

```bash
# Set environment variable
export CONTEXT7_API_KEY="your-api-key"

# Get your API key at https://context7.com/dashboard
```

### Customizing Token Limits

Adjust minimum documentation tokens:

```bash
# Set environment variable
export DEFAULT_MINIMUM_TOKENS=15000

# Default is 10000 tokens
```

## Workflow Hooks

Kiro includes automated workflow enforcement hooks that ensure consistent, high-quality outputs. Hooks can use **Nickel runtime validation** for type-safe enforcement. See **[docs/HOOKS.md](docs/HOOKS.md)** and **[docs/NICKEL-RUNTIME.md](docs/NICKEL-RUNTIME.md)** for detailed documentation.

### Quick Overview

**Spec Validation** (Blocking)
- Ensures `.kiro/spec/` files exist before code changes
- Validates requirements.md, design.md, tasks.md are complete
- Run `/kiro-spec` to resolve

**Scope Structure Validation** (Blocking - Optional Nickel-based)
- Validates CLAUDE.md + .kiro-scope/ structural invariant
- Uses Nickel contracts for type-safe validation at runtime
- See [docs/NICKEL-RUNTIME.md](docs/NICKEL-RUNTIME.md)

**TDD Enforcement** (Blocking)
- Requires test files before implementation
- Checks tests have actual test cases (not empty)
- Write failing tests first to resolve

**Contract Validation** (Blocking on commits)
- Runs `nickel typecheck` on all `.contracts/**/*.ncl` files
- Blocks commits if type-checking fails
- Fix nickel type errors to resolve

**Documentation Sync** (Non-blocking reminder)
- Reminds to update CLAUDE.md and README.md
- Triggers after significant code changes (>50 lines)
- Informational only, doesn't block operations

### Disabling Hooks

If you need to disable hooks temporarily, add to `.claude/settings.json`:

```json
{
  "hooks": {
    "enabled": false
  }
}
```

See [docs/HOOKS.md](docs/HOOKS.md) for more customization options.

## Nushell Integration

Kiro integrates **Nushell** via **mcp-server-nu** for powerful markdown parsing, spec validation, and structured data operations.

### What is Nushell?

Nushell is a modern shell that works with structured data (JSON, YAML, TOML, markdown) as first-class citizens. Unlike bash which treats everything as text, Nushell pipelines use typed tables, records, and lists.

### Why Nushell for Kiro?

- ✅ **Native markdown parsing** - Extract frontmatter, sections, code blocks without grep/sed
- ✅ **No jq/yq needed** - Built-in JSON/YAML support
- ✅ **Type safety** - Strongly typed data prevents errors
- ✅ **Cleaner syntax** - More readable than bash for complex operations
- ✅ **Better reports** - `to md` converts data to markdown tables

### Configuration

Automatically configured via `.mcp.json`:

```json
{
  "mcpServers": {
    "nushell": {
      "command": "npx",
      "args": ["-y", "mcp-server-nu", "--nu-config", "${CLAUDE_PLUGIN_ROOT}/tools/kiro.nu"]
    }
  }
}
```

### Kiro Nushell Utilities

The `tools/kiro.nu` library provides reusable functions:

**Spec Validation**
- `check-all-specs` - Validate requirements, design, tasks files
- `get-incomplete-specs` - List missing/incomplete specs

**Markdown Parsing**
- `parse-frontmatter` - Extract YAML frontmatter
- `get-markdown-sections` - Parse by heading level
- `extract-code-blocks` - Get code blocks by language

**Contract Coverage**
- `check-contract-coverage` - Analyze .contracts/ vs src/
- `find-missing-contracts` - List sources without contracts

**Test Coverage**
- `find-test-file` - Locate test for implementation file
- `validate-test-content` - Ensure tests have actual test cases

**Reports**
- `generate-quality-report` - Comprehensive quality metrics
- `generate-todo-list` - Markdown TODO from missing items

### Example Usage

```nushell
use tools/kiro.nu *

# Check spec completeness
check-all-specs

# Analyze contract coverage
check-contract-coverage

# Generate quality report
generate-quality-report

# Find sources without tests
list-sources | where {|s| not (check-test-exists $"src/($s)")}
```

### Hook Scripts

Nushell versions of hooks available in `hooks/scripts-nu/`:
- `validate-spec.nu` - Enhanced spec validation
- `validate-tests.nu` - Better test file detection
- `validate-contracts.nu` - Structured error parsing
- `check-docs-sync.nu` - Advanced staleness detection

Bash versions remain as fallback for compatibility.

### Security Notice

⚠️ **Important**: mcp-server-nu executes arbitrary Nushell code with full system access.

- Review scripts in `tools/kiro.nu` and `hooks/scripts-nu/`
- Only use in trusted development environments
- All scripts are transparent and version-controlled
- mcp-server-nu is experimental - not for production use

### Learn More

See **[docs/NUSHELL.md](docs/NUSHELL.md)** for:
- Complete function reference
- Usage examples
- Creating custom utilities
- Troubleshooting guide

## Troubleshooting

### Plugin Not Loading

```bash
# Check plugin status
/plugin

# Verify installation
claude --debug

# Reinstall if needed
/plugin uninstall kiro-scaffold
/plugin install kiro-scaffold
```

### Commands Not Appearing

Ensure directory structure is correct:
```
kiro-scaffold/
├── .claude-plugin/
│   └── plugin.json
├── commands/        # NOT inside .claude-plugin/
├── agents/          # At plugin root
└── skills/          # At plugin root
```

### Contracts Not Type-Checking

```bash
# Validate nickel syntax
nickel eval .contracts/your-file.ncl

# Check nickel installation
nickel --version

# Update flake if needed
nix flake update
```

## Contributing

Contributions welcome! Areas for improvement:

- Additional language support
- More testing frameworks
- Enhanced evaluation metrics
- Better contract templates
- Integration with more tools

### Development Setup

1. Fork and clone this repository
2. Make changes
3. Test locally with a marketplace pointing to your fork
4. Submit PR with description of changes

## Resources

- [kiro.dev documentation](https://kiro.dev/docs/)
- [Nickel language](https://nickel-lang.org/)
- [typix documentation](https://github.com/typix/typix)
- [Claude Code plugins docs](https://docs.claude.com/en/docs/claude-code/plugins)

## License

MIT License - See [LICENSE](LICENSE) file

## Support

- Issues: [GitHub Issues](https://github.com/yourusername/kiro-scaffold/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/kiro-scaffold/discussions)
- Discord: [Claude Developers Discord](https://discord.gg/claude-dev)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Acknowledgments

- kiro.dev team for the methodology
- Anthropic for Claude Code plugin system
- Nickel language community
- Nix/typix developers

---

**Happy spec-driven development!** 🚀
