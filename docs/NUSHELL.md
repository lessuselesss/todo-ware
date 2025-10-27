# Nushell Integration Guide

This plugin integrates **Nushell** via **mcp-server-nu** for enhanced markdown parsing, spec validation, and structured data manipulation. This guide explains how Nushell is used, how to work with it, and how to extend it.

## Table of Contents

- [Overview](#overview)
- [What is mcp-server-nu?](#what-is-mcp-server-nu)
- [Why Nushell for Kiro?](#why-nushell-for-kiro)
- [Installation & Setup](#installation--setup)
- [Kiro Nushell Utilities](#kiro-nushell-utilities)
- [Using Nushell in Hooks](#using-nushell-in-hooks)
- [Examples](#examples)
- [Creating Custom Utilities](#creating-custom-utilities)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

---

## Overview

Kiro integrates Nushell through the Model Context Protocol (MCP) to provide:

- ✅ **Native markdown parsing** - Extract frontmatter, sections, code blocks
- ✅ **Structured data handling** - JSON, YAML, TOML without external tools
- ✅ **Type-safe operations** - Strongly typed data manipulation
- ✅ **Better spec validation** - Parse and validate `.kiro/spec/` files
- ✅ **Contract coverage analysis** - Compare `.contracts/` to `src/` structure
- ✅ **Enhanced reporting** - Generate quality reports with markdown tables

## What is mcp-server-nu?

**mcp-server-nu** is an MCP server (by cablehead) that allows AI assistants to execute Nushell scripts through the Model Context Protocol.

### Key Features

- Executes Nushell scripts via `nu -c "<script>"`
- Returns structured output (stdout, stderr, exit code)
- Supports custom Nushell configurations
- Works with standard Nushell installations (no compilation needed)

### Current Status

⚠️ **Experimental** - mcp-server-nu is actively developed but lacks safety mechanisms. Only use in trusted environments.

##  Why Nushell for Kiro?

| Feature | Bash | Nushell |
|---------|------|---------|
| **Markdown parsing** | grep/sed/awk | Native structured parsing |
| **JSON/YAML** | jq/yq required | Built-in `from json`/`from yaml` |
| **Type safety** | Everything is strings | Strongly typed data |
| **Data pipelines** | Text streams | Structured tables |
| **Readability** | Complex for data work | Clean, functional syntax |
| **Cross-platform** | Platform differences | Consistent everywhere |

### Perfect for Kiro Because

1. **Spec files are markdown** - Nushell can parse frontmatter, sections, tables
2. **Structured validation** - Check completeness with typed data
3. **Contract analysis** - Compare directory structures easily
4. **Report generation** - `to md` converts data to markdown tables
5. **Better maintainability** - `tools/kiro.nu` is easier to extend than bash

## Installation & Setup

### Requirements

- Node.js (for npx)
- Nushell installed (`cargo install nu` or `nix profile install nixpkgs#nushell`)

### Configuration

The plugin automatically configures mcp-server-nu in `.mcp.json`:

```json
{
  "mcpServers": {
    "nushell": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-server-nu",
        "--nu-config",
        "${CLAUDE_PLUGIN_ROOT}/tools/kiro.nu"
      ]
    }
  }
}
```

This loads `tools/kiro.nu` which provides kiro-specific utilities.

### Verification

Check if Nushell MCP is available:

```bash
# The MCP server will be available when Claude Code starts
# Claude can then invoke Nushell scripts via MCP exec tool
```

## Kiro Nushell Utilities

The `tools/kiro.nu` library provides reusable functions organized by category.

### Spec Validation

#### `validate-spec-file`
Check if a spec file has meaningful content.

```nushell
use tools/kiro.nu *

validate-spec-file ".kiro/spec/requirements.md"
# Returns: {status: "ok", file: "...", lines: 42}
```

#### `check-all-specs`
Validate all three required spec files.

```nushell
check-all-specs
# Returns: {
#   valid: true,
#   missing: [],
#   incomplete: [],
#   details: [...]
# }
```

#### `get-incomplete-specs`
Get list of missing or incomplete spec files.

```nushell
get-incomplete-specs
# Returns: [
#   {file: "design.md", reason: "incomplete"},
#   {file: "tasks.md", reason: "missing"}
# ]
```

### Markdown Parsing

#### `parse-frontmatter`
Extract YAML frontmatter from markdown files.

```nushell
parse-frontmatter ".kiro/spec/requirements.md"
# Returns: {title: "...", version: "1.0", ...}
```

#### `get-markdown-sections`
Get headings at a specific level.

```nushell
get-markdown-sections "README.md" --level 2
# Returns: ["Installation", "Usage", "Contributing"]
```

#### `extract-code-blocks`
Get code blocks from markdown.

```nushell
extract-code-blocks "README.md" --language "bash"
# Returns: [
#   {language: "bash", code: "npm install"},
#   {language: "bash", code: "npm test"}
# ]
```

#### `count-meaningful-lines`
Count non-empty, non-comment lines.

```nushell
count-meaningful-lines "src/index.js"
# Returns: 127
```

### Contract Coverage

#### `list-contracts`
List all nickel contract files.

```nushell
list-contracts
# Returns: ["auth/user", "api/routes", ...]
```

#### `list-sources`
List all source files (supports custom extensions).

```nushell
list-sources
# Default: ["js", "ts", "py", "rs"]

list-sources --extensions ["go", "rs"]
# Custom extensions
```

#### `check-contract-coverage`
Analyze contract coverage.

```nushell
check-contract-coverage
# Returns: {
#   total: 50,
#   covered: 45,
#   coverage_percent: 90,
#   missing_contracts: ["utils/helper", ...]
# }
```

#### `find-missing-contracts`
Get list of sources without contracts.

```nushell
find-missing-contracts
# Returns: ["utils/helper", "api/middleware"]
```

### Test Coverage

#### `find-test-file`
Locate test file for an implementation file.

```nushell
find-test-file "src/auth/user.js"
# Returns: "src/auth/user.test.js" (or null)
```

#### `check-test-exists`
Boolean check for test existence.

```nushell
check-test-exists "src/auth/user.js"
# Returns: true
```

#### `validate-test-content`
Ensure test has actual test cases.

```nushell
validate-test-content "src/auth/user.test.js"
# Returns: {valid: true, lines: 45}
```

### Documentation Sync

#### `get-file-age`
Get file age in seconds.

```nushell
get-file-age "CLAUDE.md"
# Returns: 7200 (2 hours)
```

#### `check-docs-stale`
Check if documentation needs updates.

```nushell
check-docs-stale --threshold 3600
# Returns: {
#   claude_stale: false,
#   readme_stale: true,
#   claude_age_hours: 1,
#   readme_age_hours: 5
# }
```

#### `list-recent-changes`
Files modified in last N hours.

```nushell
list-recent-changes 24
# Returns: [
#   {file: "src/auth/user.js", age: 3600},
#   {file: "src/api/routes.js", age: 7200}
# ]
```

### Report Generation

#### `generate-quality-report`
Create structured quality metrics.

```nushell
generate-quality-report
# Returns comprehensive quality data structure
```

#### `format-as-table`
Convert data to markdown table.

```nushell
[
  {name: "spec", status: "ok"},
  {name: "contracts", status: "incomplete"}
] | format-as-table
```

#### `generate-todo-list`
Create TODO list from missing items.

```nushell
generate-todo-list
# Returns markdown TODO list
```

### Helper Functions

#### `is-kiro-project`
Check if current directory is a kiro project.

```nushell
is-kiro-project
# Returns: true
```

#### `get-project-root`
Find project root (where .kiro exists).

```nushell
get-project-root
# Returns: "/path/to/project"
```

## Using Nushell in Hooks

Hook scripts are available in **two versions**:

- **Bash**: `hooks/scripts/*.sh` - Always work, no dependencies
- **Nushell**: `hooks/scripts-nu/*.nu` - Enhanced when mcp-server-nu is available

### Bash Hooks (Current Default)

The `hooks/hooks.json` currently references bash scripts:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-spec.sh"
        }
      ]
    }
  ]
}
```

### Nushell Hook Scripts

Nushell versions provide:
- ✅ Better markdown parsing
- ✅ Structured error messages
- ✅ Cleaner code logic
- ✅ Reuse of `tools/kiro.nu` utilities

Located in `hooks/scripts-nu/`:
- `validate-spec.nu`
- `validate-tests.nu`
- `validate-contracts.nu`
- `check-docs-sync.nu`

### Claude's Usage

When mcp-server-nu is configured, Claude can:
1. Invoke Nushell utilities via MCP `exec` tool
2. Parse hook results more intelligently
3. Provide richer error context

The bash hooks remain as fallback for compatibility.

## Examples

### Example 1: Check Spec Completeness

```nushell
use tools/kiro.nu *

# Simple check
if not (is-kiro-project) {
  print "Not a kiro project"
  exit 1
}

let check = (check-all-specs)

if not $check.valid {
  print "❌ Spec validation failed:"
  print $check.missing
  print $check.incomplete
} else {
  print "✅ All specs are complete"
}
```

### Example 2: Analyze Contract Coverage

```nushell
use tools/kiro.nu *

let coverage = (check-contract-coverage)

print $"Coverage: ($coverage.coverage_percent)%"
print $"Total sources: ($coverage.total)"
print $"Covered: ($coverage.covered)"

if ($coverage.missing_contracts | length) > 0 {
  print "\nMissing contracts:"
  $coverage.missing_contracts | each {|f| print $"  - ($f)"}
}
```

### Example 3: Generate Quality Report

```nushell
use tools/kiro.nu *

let report = (generate-quality-report)

print "# Kiro Quality Report"
print $"Generated: ($report.timestamp)"
print ""

print "## Specifications"
print $"Valid: ($report.specifications.valid)"

print "\n## Contract Coverage"
print $"Coverage: ($report.contracts.coverage_percent)%"
print $"Covered: ($report.contracts.covered)/($report.contracts.total_sources)"

print "\n## Documentation"
if $report.documentation.claude_stale {
  print $"⚠️  CLAUDE.md is ($report.documentation.claude_age_hours) hours old"
}
if $report.documentation.readme_stale {
  print $"⚠️  README.md is ($report.documentation.readme_age_hours) hours old"
}
```

### Example 4: Parse Markdown Frontmatter

```nushell
use tools/kiro.nu *

let frontmatter = (parse-frontmatter ".kiro/spec/requirements.md")

if $frontmatter != null {
  print $"Title: ($frontmatter.title)"
  print $"Version: ($frontmatter.version)"
  print $"Status: ($frontmatter.status)"
}
```

### Example 5: Find Sources Without Tests

```nushell
use tools/kiro.nu *

let sources = (list-sources)

let without_tests = (
  $sources
  | each {|src| {file: $src, has_test: (check-test-exists $"src/($src)")}}
  | where has_test == false
  | get file
)

if ($without_tests | length) > 0 {
  print "❌ Sources without tests:"
  $without_tests | each {|f| print $"  - ($f)"}
} else {
  print "✅ All sources have tests"
}
```

## Creating Custom Utilities

You can extend `tools/kiro.nu` with your own utilities.

### Adding a New Function

```nushell
# Add to tools/kiro.nu

# Count TODO comments in a file
export def count-todos [file: path] {
  if not ($file | path exists) {
    return 0
  }

  open $file
  | lines
  | where {|line| $line | str contains "TODO"}
  | length
}

# Find all TODOs in project
export def find-all-todos [] {
  glob src/**/*.{js,ts,py,rs}
  | each {|file|
      let count = (count-todos $file)
      if $count > 0 {
        {file: $file, todos: $count}
      }
    }
  | compact
  | sort-by todos --reverse
}
```

### Using Custom Utilities

```nushell
use tools/kiro.nu *

let todos = (find-all-todos)

if ($todos | length) > 0 {
  print "📝 TODO Comments Found:"
  $todos | each {|item|
    print $"  ($item.file): ($item.todos) TODOs"
  }
}
```

### Best Practices

1. **Export functions** with `export def`
2. **Type parameters** (`file: path`, `count: int`)
3. **Handle edge cases** (file doesn't exist, empty data)
4. **Return structured data** (records, tables, lists)
5. **Document with comments**
6. **Test with sample data**

## Security Considerations

⚠️ **Important**: mcp-server-nu executes arbitrary Nushell code on your system.

### What This Means

- **Full file system access** - Can read, write, delete files
- **Network access** - Can make HTTP requests
- **System commands** - Can execute any command Nushell can run
- **Environment access** - Can read environment variables

### Safety Measures

1. **Review scripts** - All scripts in `tools/kiro.nu` and `hooks/scripts-nu/` are visible
2. **Trusted environments** - Only use in environments you control
3. **Audit MCP usage** - Check what Claude invokes via MCP
4. **No production use** - mcp-server-nu explicitly warns against production use

### What Kiro Does

- ✅ **Transparent scripts** - All Nushell code is in version control
- ✅ **Read-only operations** - Most utilities only read data
- ✅ **No network calls** - kiro.nu doesn't make external requests
- ✅ **Scoped operations** - Functions operate within project boundaries

### Recommendations

- Review `tools/kiro.nu` before using
- Only add custom utilities you understand
- Monitor what Claude invokes via MCP logs
- Use in development/testing environments

## Troubleshooting

### mcp-server-nu not available

**Symptom**: Claude says Nushell tools aren't available

**Solutions**:
```bash
# 1. Check Nushell is installed
nu --version

# 2. Check npx works
npx -y mcp-server-nu --help

# 3. Restart Claude Code
# The MCP server loads on startup

# 4. Check .mcp.json exists
cat .mcp.json
```

### "module not found" errors

**Symptom**: `use tools/kiro.nu` fails

**Cause**: Nushell can't find the module

**Solutions**:
```bash
# 1. Check file exists
ls tools/kiro.nu

# 2. Check path is correct
# From project root:
use tools/kiro.nu *

# From subdirectory:
use ../tools/kiro.nu *
```

### Functions not working as expected

**Debug approach**:
```nushell
# 1. Test function in isolation
use tools/kiro.nu *

# 2. Check return value
let result = (check-all-specs)
$result | describe  # Show type
$result | table     # Show data

# 3. Add debug prints
def my-function [] {
  print "Debug: starting..."
  let data = (some-operation)
  print $"Debug: got ($data | length) items"
  $data
}
```

### Path issues

**Symptom**: Functions can't find files

**Solutions**:
```nushell
# Always check if path exists
if not (".kiro" | path exists) {
  print "Not in kiro project root"
  exit 1
}

# Use absolute paths when needed
let project_root = (get-project-root)
let spec_file = $"($project_root)/.kiro/spec/requirements.md"
```

### Performance issues

**Symptom**: Scripts are slow

**Optimization tips**:
```nushell
# Use filters early
glob src/**/*.js
| where {|f| ($f | path type) == "file"}  # Filter early
| each {|f| process $f}

# Avoid redundant reads
let content = (open file.md)  # Read once
let lines = ($content | lines)
let sections = ($content | get-markdown-sections)

# Use built-ins
# Good: where, filter, select
# Avoid: each with complex logic
```

## Additional Resources

- [Nushell Documentation](https://www.nushell.sh/)
- [mcp-server-nu GitHub](https://github.com/cablehead/mcp-server-nu)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Kiro Plugin README](../README.md)
- [Hook Documentation](./HOOKS.md)

## Contributing

To add new Nushell utilities:

1. Edit `tools/kiro.nu`
2. Add exported function with type annotations
3. Update this documentation with examples
4. Test with sample data
5. Submit PR with clear description

---

**Questions?** Check the main README or open an issue on GitHub.
