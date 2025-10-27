# Changelog

All notable changes to the Kiro Scaffold plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-10-26

### Added

#### Nushell Integration via mcp-server-nu
- **mcp-server-nu MCP Server**: Execute Nushell scripts for enhanced data processing
- **tools/kiro.nu**: Comprehensive utility library with 20+ reusable functions
  - Spec validation functions (check-all-specs, validate-spec-file, get-incomplete-specs)
  - Markdown parsing functions (parse-frontmatter, get-markdown-sections, extract-code-blocks)
  - Contract coverage analysis (check-contract-coverage, find-missing-contracts, list-contracts)
  - Test coverage functions (find-test-file, check-test-exists, validate-test-content)
  - Documentation sync functions (get-file-age, check-docs-stale, list-recent-changes)
  - Report generation (generate-quality-report, format-as-table, generate-todo-list)
  - Helper utilities (is-kiro-project, get-project-root, count-meaningful-lines)

#### Nushell Hook Scripts
- **hooks/scripts-nu/validate-spec.nu**: Nushell version of spec validation
- **hooks/scripts-nu/validate-tests.nu**: Enhanced test file detection
- **hooks/scripts-nu/validate-contracts.nu**: Structured nickel error parsing
- **hooks/scripts-nu/check-docs-sync.nu**: Advanced staleness detection
- All Nushell hooks use tools/kiro.nu utilities for consistency

#### Documentation
- **docs/NUSHELL.md**: Comprehensive 400+ line Nushell integration guide
  - Complete function reference with examples
  - Security considerations and best practices
  - Custom utility development guide
  - Troubleshooting section
  - Usage examples for all major functions

- **Updated README.md**: Added Nushell Integration section
  - Why Nushell for Kiro
  - Configuration details
  - Utility overview
  - Security notice
  - Link to detailed documentation

### Changed
- **Bash hooks**: Added header comments explaining Nushell alternatives
  - All bash scripts now document corresponding Nushell versions
  - Clarify that bash remains as fallback for compatibility

- **.mcp.json**: Added nushell MCP server configuration
  - Configured to load tools/kiro.nu via --nu-config
  - Uses ${CLAUDE_PLUGIN_ROOT} for portable paths

### Technical Details

**Nushell Advantages**:
- Native structured data handling (JSON, YAML, TOML, markdown)
- Type-safe operations with strongly typed pipelines
- Better markdown parsing without grep/sed/awk complexity
- Built-in table formatting and data transformation
- Cross-platform consistency

**Integration Approach**:
- mcp-server-nu over official nu --mcp (no compilation required)
- Dual bash/Nushell hook implementation (compatibility + enhancement)
- Centralized utility library in tools/kiro.nu
- MCP exec tool invocation for Claude's use
- All scripts transparent and version-controlled

**Security Considerations**:
- mcp-server-nu is experimental (⚠️ no safety mechanisms)
- All scripts visible for review
- Read-only operations for most utilities
- No network calls in kiro.nu
- Documented security implications

## [1.1.0] - 2025-10-26

### Added

#### MCP Server Integration
- **Context7 MCP Server**: Automatic integration with Context7 for up-to-date, version-specific library documentation
- `.mcp.json` configuration with support for both free tier and API key authentication
- Environment variable support for `CONTEXT7_API_KEY` and `DEFAULT_MINIMUM_TOKENS`
- Cross-platform compatibility (Linux, macOS, Windows)

#### Workflow Enforcement Hooks
- **Spec Validation Hook**: Blocks source code changes when `.kiro/spec/` files are missing or incomplete
  - Validates requirements.md, design.md, and tasks.md exist and have meaningful content
  - Provides clear error messages with remediation steps
  - Ensures spec-driven development workflow is followed

- **TDD Enforcement Hook**: Enforces test-driven development by requiring tests before implementation
  - Blocks implementation file changes if corresponding test files don't exist
  - Validates test files have actual test cases (not empty/boilerplate)
  - Supports multiple test patterns: `.test.`, `.spec.`, `__tests__/`, `tests/`
  - Provides TDD workflow guidance in error messages

- **Contract Validation Hook**: Type-checks nickel contracts before git commits
  - Runs `nickel typecheck` on all `.contracts/**/*.ncl` files
  - Blocks commits if type-checking fails
  - Reports specific contract errors with file:line references
  - Gracefully degrades if nickel is not installed (warning only)

- **Documentation Sync Reminder**: Non-blocking reminder to update documentation
  - Detects significant code changes (>50 lines or new files)
  - Checks when CLAUDE.md and README.md were last modified
  - Provides reminders when docs are >1 hour out of sync
  - Suggests running `/kiro-spec` to sync specifications

#### Documentation
- **docs/HOOKS.md**: Comprehensive documentation for all workflow hooks
  - Detailed explanation of each hook's purpose and behavior
  - Troubleshooting guide for hook validation errors
  - Customization instructions and examples
  - Best practices for solo developers, teams, and learners

- **Updated README.md**: Added sections for Context7 and workflow hooks
  - Context7 setup and configuration instructions
  - Quick overview of all workflow hooks
  - Hook disabling and customization options

### Changed
- **Plugin Version**: Bumped to 1.1.0
- **Plugin Description**: Updated to include Context7 and hooks
- **Keywords**: Added "mcp", "context7", "hooks", "validation", "workflow"
- **Plugin Manifest**: Added `components` and `features` metadata

### Technical Details
- All hook scripts are written in bash with proper error handling
- Hooks use `jq` for JSON parsing of Claude Code events
- Cross-platform path detection using `stat` with fallbacks
- Uses `${CLAUDE_PLUGIN_ROOT}` for portable plugin paths
- Hooks communicate via JSON output for rich error messages
- Exit code 2 blocks operations, exit code 0 allows them

## [1.0.0] - 2025-10-27

### Added

#### Commands
- `/kiro-new` - Create new spec-driven projects with interactive or headless mode
- `/kiro-spec` - Update or regenerate specification files (master or scoped)
- `/kiro-scope` - Create scoped implementation areas with decomposed specs
- `/kiro-eval` - Evaluate project quality against kiro.dev standards

#### Agents
- **Kiro Architect** - Interactive project design through structured Q&A
  - Requirements gathering
  - Technology stack selection
  - Architecture design
  - Scaffold generation
  
- **Kiro Evaluator** - Comprehensive quality assessment
  - Structure validation (25% weight)
  - Specification completeness (20% weight)
  - Contract coverage analysis (15% weight)
  - TDD compliance checking (10% weight)
  - Report generation (terminal, markdown, HTML)
  
- **TDD Coach** - Test-Driven Development guidance
  - Assertion design
  - RED-to-GREEN workflow enforcement
  - Test quality assessment
  - Refactoring support

#### Skills (Autonomous Activation)
- **Kiro Project Scaffolder** - Auto-activates for spec-driven project creation
  - Recognizes explicit and implicit project creation intent
  - Supports interactive and headless modes
  - Validates generated scaffolds
  
- **TDD Workflow Guide** - Auto-activates during feature implementation
  - Enforces test-first discipline
  - Guides through RED-to-GREEN cycles
  - Ensures test quality

#### Features
- **Project Structure**: Complete kiro.dev-compliant scaffolding
  - Master specifications (.kiro/spec/)
  - Documentation structure (CLAUDE.md, .aidocs/)
  - Nickel contracts (.contracts/)
  - Typix/Nix integration (flake.nix)
  - Git repository initialization
  
- **Scoped Implementation**: Decomposed development areas
  - Scoped specifications
  - Local CLAUDE.md files
  - Test assertion templates
  - Local nickel contracts
  
- **Quality Evaluation**: Multi-dimensional assessment
  - Golden file testing
  - Schema validation
  - Contract coverage metrics
  - TDD workflow compliance
  - Quality scoring (0-100)
  - Trend tracking
  
- **Documentation**: Comprehensive reference materials
  - kiro.dev methodology docs
  - typix/typist integration guides
  - Nickel language reference
  - TDD workflow documentation

### Project Metadata
- Initial release
- MIT License
- Comprehensive README with examples
- Plugin manifest with proper metadata
- Standard directory structure

### Development Tools
- CI/CD integration examples
- GitHub Actions workflow templates
- Quality threshold enforcement
- Debugging guidance

## [Unreleased]

### Planned Features
- Additional language/framework templates
- Extended testing framework support
- Enhanced contract generation
- Visual specification editor
- Team collaboration features
- Migration tools for existing projects
- Integration with project management tools
- Real-time quality dashboards

### Under Consideration
- VSCode extension integration
- Specification versioning
- Contract testing tools
- Performance benchmarking
- Security scanning integration
- Documentation generation from specs
- API documentation generation
- Dependency analysis

---

## Version History Legend

- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Vulnerability fixes
