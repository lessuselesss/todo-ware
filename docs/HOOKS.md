# Kiro Workflow Hooks Documentation

This plugin includes automated workflow enforcement hooks that ensure consistent, high-quality project outputs by validating specifications, tests, contracts, and documentation.

## Overview

Kiro hooks implement **guardrails** for spec-driven, test-driven development workflows. They activate automatically in projects created with `/kiro-new` and help enforce best practices without being overly restrictive.

## Available Hooks

### 1. Spec Validation Hook

**Trigger:** Before writing/editing implementation files in `src/`
**Type:** Blocking
**Purpose:** Ensures specifications exist before code implementation

#### What It Checks

- ✅ `.kiro/spec/requirements.md` exists and has content
- ✅ `.kiro/spec/design.md` exists and has content
- ✅ `.kiro/spec/tasks.md` exists and has content
- ✅ Each file has meaningful content (>3 non-header lines)

#### When It Blocks

- Missing any required spec file
- Spec files exist but are empty or contain only headers
- Attempting to modify `src/` without complete specifications

#### Error Message Example

```
❌ Spec Validation Failed

Cannot modify source code without complete specifications.

Missing files:
- .kiro/spec/requirements.md
- .kiro/spec/design.md

Required action: Run `/kiro-spec` to create/update specifications
before implementing code.

Why? Spec-driven development ensures we understand requirements,
design, and tasks before writing code.
```

#### How to Resolve

```bash
# Generate or update specifications
/kiro-spec

# Or manually create/edit the files
# - .kiro/spec/requirements.md (WHAT to build)
# - .kiro/spec/design.md (HOW to build it)
# - .kiro/spec/tasks.md (implementation breakdown)
```

---

### 2. TDD Enforcement Hook

**Trigger:** Before writing/editing implementation files in `src/`
**Type:** Blocking
**Purpose:** Enforces test-driven development (tests before implementation)

#### What It Checks

- ✅ Test file exists for the implementation file
- ✅ Test file has actual test cases (>5 meaningful lines)
- ✅ Supports multiple test patterns:
  - `src/foo.js` → `src/foo.test.js`
  - `src/foo.js` → `src/foo.spec.js`
  - `src/foo.js` → `src/__tests__/foo.test.js`
  - `src/foo.js` → `tests/foo.test.js`

#### When It Blocks

- No test file found for implementation file
- Test file exists but is empty or has only imports

#### Error Message Example

```
❌ TDD Validation Failed

No test file found for: src/auth/user.js

Expected test file locations:
- src/auth/user.test.js
- src/auth/user.spec.js
- src/auth/__tests__/user.test.js
- tests/auth/user.test.js

Required action: Create test file with failing tests BEFORE
implementing code.

TDD Workflow:
1. 🔴 RED: Write a failing test that describes the desired behavior
2. 🟢 GREEN: Write minimal code to make the test pass
3. ♻️  REFACTOR: Improve the code while keeping tests green

Why? Writing tests first clarifies requirements and ensures
testable, maintainable code.
```

#### How to Resolve

```bash
# Create test file first
# Write failing tests based on specifications
# Then implement the code to make tests pass

# Example: src/auth/user.test.js
describe('User', () => {
  it('should create user with valid data', () => {
    // Test implementation
  });
});
```

---

### 3. Contract Validation Hook

**Trigger:** Before git commit operations
**Type:** Blocking (if nickel is installed)
**Purpose:** Validates nickel type contracts before committing

#### What It Checks

- ✅ All `.contracts/**/*.ncl` files pass `nickel typecheck`
- ✅ No type errors in contract definitions
- ✅ Contracts are syntactically valid

#### When It Blocks

- Nickel type-checking fails for any contract file
- Syntax errors in `.ncl` files
- Type mismatches in contract definitions

#### Error Message Example

```
❌ Contract Validation Failed

Nickel type-checking failed for contract files.

Errors found:

**.contracts/auth/user.ncl:**
```
error: Type mismatch
  ┌─ .contracts/auth/user.ncl:5:5
  │
5 │     email: Number,
  │            ^^^^^^ Expected String, found Number
```

Required action: Fix contract type errors before committing.

Why? Nickel contracts ensure type safety and prevent runtime errors.
```

#### How to Resolve

```bash
# Manually validate contracts
nickel typecheck .contracts/path/to/file.ncl

# Fix type errors in the contract file
# Then retry the commit
```

#### If Nickel Not Installed

Hook provides a warning but does **not block** operations:

```
⚠️  Nickel not found - skipping contract validation

Install nickel to enable contract type-checking:
- Via nix: `nix profile install nixpkgs#nickel`
- Via cargo: `cargo install nickel-lang-cli`
```

---

### 4. Documentation Sync Reminder

**Trigger:** After writing/editing implementation files in `src/`
**Type:** Non-blocking (reminder only)
**Purpose:** Reminds you to keep documentation in sync with code

#### What It Checks

- ✅ Detects significant changes (>50 lines or new files)
- ✅ Checks when `CLAUDE.md` was last modified
- ✅ Checks when `README.md` was last modified

#### When It Reminds

- Making significant code changes
- Documentation hasn't been updated in >1 hour
- New files added to `src/`

#### Reminder Message Example

```
📝 Documentation Sync Reminder

Significant code changes detected in: src/auth/user.js

- ⚠️  CLAUDE.md may need updating (last modified: 3 hours ago)
- ⚠️  README.md may need updating (last modified: 5 hours ago)

Recommended:
- Update CLAUDE.md with implementation details and context
- Update README.md if public API or usage has changed
- Run `/kiro-spec` to sync specifications with implementation

Why? Keeping docs in sync helps Claude assist more effectively
and improves team collaboration.
```

#### How to Address

```bash
# Update project documentation
# Edit CLAUDE.md with implementation context
# Update README.md if API changed

# Sync specifications with implementation
/kiro-spec
```

This is a **reminder only** and will not block your operations.

---

## Hook Configuration

Hooks are configured in `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-spec.sh",
          "timeout": 5000
        },
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-tests.sh",
          "timeout": 5000
        }
      ]
    },
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-contracts.sh",
          "timeout": 10000
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/check-docs-sync.sh",
          "timeout": 3000
        }
      ]
    }
  ]
}
```

## Disabling Hooks

### Temporarily Disable (Current Session)

Hooks can be overridden in your user or project settings:

**Project-level** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PreToolUse": []
  }
}
```

**User-level** (`~/.config/claude/settings.json`):
```json
{
  "hooks": {
    "enabled": false
  }
}
```

### Permanently Disable for a Project

Add to `.claude/settings.json` in your project:

```json
{
  "plugins": {
    "kiro-scaffold": {
      "hooks": {
        "enabled": false
      }
    }
  }
}
```

### Disable Specific Hooks

To disable only certain validations, create custom hook overrides:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-spec.sh"
          }
          // Removed validate-tests.sh - TDD hook disabled
        ]
      }
    ]
  }
}
```

## Customizing Hook Behavior

### Adjust Validation Strictness

Edit hook scripts in `hooks/scripts/` to customize validation logic:

**Example:** Reduce required spec content from 3 to 1 line:

```bash
# In hooks/scripts/validate-spec.sh
# Change line ~51:
if [[ "$content_lines" -lt 1 ]]; then  # Was: -lt 3
```

### Add Custom Hooks

Create new hook scripts following the pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read JSON input
INPUT=$(cat)

# Extract relevant data
FILE_PATH=$(echo "$INPUT" | jq -r '.toolInput.file_path // ""')

# Validation logic
if [[ condition ]]; then
  echo "{\"continue\": false, \"additionalContext\": \"Error message\"}"
  exit 2
fi

# Success
exit 0
```

Register in `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-custom-hook.sh",
          "timeout": 5000
        }
      ]
    }
  ]
}
```

## Hook Exit Codes

Hooks communicate results via exit codes:

- **Exit 0**: Success - allow operation
- **Exit 2**: Blocking error - prevent operation
- **Other codes**: Non-blocking error - log but allow

## Hook Response Format

Hooks output JSON to communicate with Claude Code:

### Blocking Response
```json
{
  "continue": false,
  "additionalContext": "Error message explaining why operation was blocked"
}
```

### Non-blocking Response (Warning)
```json
{
  "continue": true,
  "additionalContext": "Warning or informational message"
}
```

### Success (Silent)
Exit 0 with no output.

## Troubleshooting

### "Hook script not found"

Ensure scripts are:
- Located in `hooks/scripts/`
- Executable: `chmod +x hooks/scripts/*.sh`
- Referenced with `${CLAUDE_PLUGIN_ROOT}` prefix

### "Hook timeout"

Increase timeout in `hooks/hooks.json`:

```json
{
  "timeout": 10000  // 10 seconds
}
```

### "jq: command not found"

Hooks require `jq` for JSON parsing. Install it:

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Nix
nix profile install nixpkgs#jq
```

### Hooks Not Activating

1. Check plugin is enabled: `/plugin`
2. Verify hooks.json syntax is valid
3. Check Claude Code debug logs: `claude --debug`
4. Ensure you're in a kiro project (has `.kiro/` directory)

## Best Practices

### For Solo Developers

- Keep hooks enabled to maintain discipline
- Adjust validation strictness to your workflow
- Use documentation sync reminders to maintain context

### For Teams

- Enable all hooks for consistency
- Document any customizations in project README
- Share hook configurations in `.claude/settings.json`
- Consider stricter validation for production branches

### For Learning TDD

- Start with hooks enabled to build good habits
- Don't disable TDD hook - it teaches the workflow
- Write minimal tests at first, improve over time

## Philosophy

These hooks implement **guardrails, not gates**:

- ✅ Prevent common mistakes (missing specs, no tests)
- ✅ Enforce proven workflows (TDD, spec-driven)
- ✅ Provide helpful guidance (clear error messages)
- ❌ Not overly restrictive (can be disabled if needed)
- ❌ Not punitive (informative error messages)

The goal is to make doing the right thing easy and doing the wrong thing obvious.

## See Also

- [Claude Code Hooks Documentation](https://docs.claude.com/en/docs/claude-code/hooks)
- [Kiro Workflow Guide](../README.md#workflow-example)
- [TDD Best Practices](../README.md#tdd-workflow-red-to-green)
