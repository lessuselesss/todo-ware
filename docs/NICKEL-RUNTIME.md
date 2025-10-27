# Nickel Runtime Validation

This document explains how to use **Nickel contracts for runtime validation** in kiro-scaffold hooks.

## Overview

The kiro-scaffold plugin includes a complete **runtime Nickel validation** system that:

1. **Defines** structure formally in Nickel contracts
2. **Inspects** filesystem at runtime
3. **Converts** filesystem state to Nickel-compatible JSON
4. **Validates** using `nickel eval --validate`
5. **Blocks** operations if validation fails

This provides **type-safe enforcement** of the kiro methodology at runtime.

## Architecture

```
Claude attempts Write("src/auth/jwt.py")
    ↓
Hook: validate-scope-nickel.sh
    ↓
1. Extract file path: "src/auth/jwt.py"
2. Get parent directory: "src/auth"
3. Inspect filesystem:
   - CLAUDE.md exists? ✓
   - .kiro-scope/ exists? ✓
   - scoped-tasks.md? ✓
   - assertions.md? ✓
   - context.md? ✗  ← Missing!
    ↓
4. Build Nickel JSON:
   {
     path = "src/auth",
     has_claude_md = true,
     has_kiro_scope_dir = true,
     required_files = {
       scoped_tasks = true,
       assertions = true,
       context = false  ← Invalid!
     }
   }
    ↓
5. Validate with Nickel:
   echo "$json" | nickel eval --validate scope-directory-runtime.ncl
    ↓
6. Nickel returns error:
   "❌ Scope Validation Failed for src/auth
   Errors:
     - .kiro-scope/context.md not found

   **Required action:** Run `/kiro-scope src/auth`"
    ↓
7. Hook blocks Write operation
    ↓
User sees error, must fix structure
```

## Files

### 1. Runtime Contract
**`.contracts/schema/scope-directory-runtime.ncl`**

Defines validation logic in Nickel:

```nickel
{
  RuntimeScopeState = {
    path | String,
    has_claude_md | Bool,
    has_kiro_scope_dir | Bool,
    required_files | {
      scoped_tasks | Bool,
      assertions | Bool,
      context | Bool,
    },
  },

  validate_scope_state = fun state => {
    # Returns ValidationResult with errors list
  },
}
```

### 2. Bash Hook
**`hooks/scripts/validate-scope-nickel.sh`**

Bash script that:
- Inspects filesystem
- Builds Nickel JSON
- Calls nickel eval
- Formats response for Claude

### 3. Nushell Hook
**`hooks/scripts-nu/validate-scope-nickel.nu`**

Nushell script that:
- Uses cleaner syntax for filesystem checks
- Leverages `validate-with-nickel.nu` helpers
- More maintainable than bash

### 4. Nushell Helpers
**`tools/validate-with-nickel.nu`**

Reusable functions:
- `build-scope-state` - Filesystem → JSON
- `validate-scope-with-nickel` - Run validation
- `validate-for-hook` - Format for hook response
- `scope-validation-report` - Batch validate all scopes

## Usage

### Enable Nickel Validation

**Option 1: Replace default hooks**
```bash
cd /path/to/kiro-scaffold
cp hooks/hooks-nickel.json hooks/hooks.json
```

**Option 2: Manual integration**

Edit `hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-scope-nickel.sh",
          "timeout": 5000
        }
      ]
    }
  ]
}
```

### Test Validation

```bash
# Using Nushell
nu -c "use tools/validate-with-nickel.nu *; validate-scope-with-nickel 'src/auth'"

# Test with example data
nu -c "use tools/validate-with-nickel.nu *; test-nickel-validation"

# Generate report for all scopes
nu -c "use tools/validate-with-nickel.nu *; scope-validation-report"
```

### Command-Line Validation

```bash
# Build state manually
cat > state.ncl <<EOF
{
  path = "src/auth",
  has_source_files = true,
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = false,  # Invalid!
  },
}
EOF

# Validate
nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl < state.ncl
```

## Benefits

### 1. Single Source of Truth

Validation logic lives in Nickel contracts, not scattered across bash scripts:

```nickel
# Define ONCE in contract
validate_scope_state = fun state =>
  errors = (if not state.has_claude_md then ["CLAUDE.md not found"] else [])
  ...

# Use EVERYWHERE (bash, nushell, CI, tests)
```

### 2. Type Safety

Nickel catches structure errors:

```nickel
# This would fail at evaluation:
{
  path = "src/auth",
  has_claude_md = "yes"  # Should be Bool, not String!
}
```

### 3. Maintainability

Update validation rules in one place:

```nickel
# Want to require README.md in scopes?
# Just update the contract:
required_files = {
  scoped_tasks | Bool,
  assertions | Bool,
  context | Bool,
  readme | Bool,  # NEW!
}

# All hooks automatically enforce new rule!
```

### 4. Self-Documenting

Contracts serve as formal specification:

```nickel
RuntimeScopeState = {
  path | String | doc "Path to the directory being validated",
  has_claude_md | Bool | doc "CLAUDE.md exists in directory",
  ...
}
```

### 5. Testable

Easy to test validation logic:

```bash
# Create test states
echo '{ path = "test", has_claude_md = false, ... }' | nickel eval ...

# Automated tests
for test_case in tests/*.ncl; do
  nickel eval --validate scope-directory-runtime.ncl < $test_case
done
```

## Comparison: Before vs. After

### Before (Pure Bash)

```bash
# validate-spec.sh
if [[ ! -f "$SPEC_DIR/requirements.md" ]]; then
  MISSING_FILES+=("requirements.md")
fi

content_lines=$(grep -vE '^(#|$|\s*$)' "$file_path" | wc -l)
if [[ "$content_lines" -lt 3 ]]; then
  INCOMPLETE_FILES+=("requirements.md")
fi

# Validation logic in bash (hard to maintain)
```

**Issues:**
- Logic in bash (not reusable)
- No type safety
- Hard to test
- Duplicated across hooks

### After (Nickel Runtime)

```nickel
# scope-directory-runtime.ncl
validate_scope_state = fun state => {
  errors =
    (if not state.has_claude_md then ["CLAUDE.md not found"] else [])
    ++
    (if not state.required_files.context then ["context.md not found"] else []),

  valid = std.array.length errors == 0,
  ...
}
```

```bash
# validate-scope-nickel.sh
SCOPE_STATE=$(build_scope_state "$DIR_PATH")
nickel eval --field validate_and_format scope-directory-runtime.ncl <<< "$SCOPE_STATE"
```

**Benefits:**
- Logic in Nickel (declarative, maintainable)
- Type-safe
- Easily testable
- Single source of truth

## Advanced Usage

### Custom Validation Functions

Add to `scope-directory-runtime.ncl`:

```nickel
{
  # Check if scope has enough assertions (at least 3)
  has_sufficient_assertions = fun state =>
    if state.has_kiro_scope_dir then
      let assertions_file = state.path ++ "/.kiro-scope/assertions.md" in
      let count = count_assertions assertions_file in
      count >= 3
    else
      false,

  # Validate with custom rules
  validate_strict = fun state => {
    errors = (validate_scope_state state).errors
      ++
      (if not (has_sufficient_assertions state) then
        ["At least 3 assertions required"]
      else []),
    ...
  },
}
```

### Validate Other Files

Create similar runtime contracts:

```nickel
# assertion-ids-runtime.ncl
{
  validate_assertion_id = fun id =>
    if std.string.is_match "^[A-Z]+-[0-9]{3}--A[0-9]+$" id then
      { valid = true, id = id }
    else
      { valid = false, error = "Invalid format", id = id },
}
```

Use in hooks:

```bash
echo '"AUTH-001--A3"' | nickel eval --field validate_assertion_id assertion-ids-runtime.ncl
```

### CI Integration

```yaml
# .github/workflows/validate.yml
- name: Validate All Scopes
  run: |
    nu -c "use tools/validate-with-nickel.nu *; scope-validation-report" > report.json

    invalid_count=$(jq '.invalid' report.json)
    if [ "$invalid_count" -gt 0 ]; then
      echo "❌ $invalid_count invalid scope(s)"
      exit 1
    fi
```

## Troubleshooting

### Nickel Not Found

```bash
# Install Nickel
nix profile install nixpkgs#nickel

# Or use dev shell
nix develop

# Or add to PATH
export PATH="/path/to/nickel:$PATH"
```

### Validation Always Passes

Check that contract path is correct:

```bash
# In hook script
CONTRACT_PATH="${CLAUDE_PLUGIN_ROOT}/.contracts/schema/scope-directory-runtime.ncl"

# Verify it exists
ls -la "$CONTRACT_PATH"
```

### JSON Format Errors

Nickel uses `=` not `:` for records:

```bash
# WRONG (JSON)
{ "path": "src/auth" }

# RIGHT (Nickel)
{ path = "src/auth" }
```

Use `to-nickel-format` helper in Nushell to convert.

### Hook Timeout

Increase timeout in `hooks.json`:

```json
{
  "command": "validate-scope-nickel.sh",
  "timeout": 10000  // Increase to 10 seconds
}
```

## Performance

### Benchmarks

```bash
# Pure bash validation
time bash hooks/scripts/validate-spec.sh
# Real: 0.05s

# Nickel validation
time bash hooks/scripts/validate-scope-nickel.sh
# Real: 0.15s
```

**Trade-off:** Nickel adds ~100ms overhead but provides:
- Type safety
- Maintainability
- Single source of truth

For most workflows, 100ms is acceptable.

### Optimization

Cache Nickel evaluations:

```bash
# Precompile contract
nickel export scope-directory-runtime.ncl > scope-validator-compiled.ncl

# Use compiled version in hook
nickel eval scope-validator-compiled.ncl < state.json
```

## See Also

- [docs/CONTRACTS.md](CONTRACTS.md) - Complete contract reference
- [docs/NUSHELL.md](NUSHELL.md) - Nushell utilities guide
- [docs/HOOKS.md](HOOKS.md) - Hook documentation
- [Nickel Language](https://nickel-lang.org/)

## Examples

### Example 1: Valid Scope

```bash
$ echo '{
  path = "src/auth",
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = true,
  }
}' | nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl

✓ Scope structure valid for src/auth
```

### Example 2: Invalid Scope (Missing Files)

```bash
$ echo '{
  path = "src/api",
  has_claude_md = false,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = false,
    context = false,
  }
}' | nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl

❌ Scope Validation Failed for src/api

Errors:
  - CLAUDE.md not found in directory
  - .kiro-scope/assertions.md not found
  - .kiro-scope/context.md not found

**Required action:** Run `/kiro-scope src/api` to generate proper scope structure.

**Structural Invariant:** Any directory with source files MUST have:
1. CLAUDE.md - Implementation workflow
2. .kiro-scope/ directory with:
   - scoped-tasks.md
   - assertions.md
   - context.md
```

### Example 3: Batch Validation

```bash
$ nu -c "use tools/validate-with-nickel.nu *; scope-validation-report"

{
  total: 5,
  valid: 4,
  invalid: 1,
  invalid_scopes: ["src/api"],
  summary: "❌ 1 invalid scope(s)"
}
```

## Future Enhancements

Potential improvements:

1. **Content Validation** - Parse markdown, validate structure
2. **Assertion Counting** - Ensure minimum number of assertions
3. **Dependency Checking** - Validate task dependencies
4. **Traceability Validation** - Check parent references
5. **Contract Coverage** - Ensure contracts exist for sources

All can be added to `scope-directory-runtime.ncl` with proper Nickel functions!
