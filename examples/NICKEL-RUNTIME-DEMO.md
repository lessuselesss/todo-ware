# Nickel Runtime Validation Demo

This demonstrates **full runtime Nickel validation** in kiro-scaffold hooks.

## What Was Built

### 1. Runtime Contract
**`.contracts/schema/scope-directory-runtime.ncl`**
- Takes filesystem state as JSON input
- Validates against structural invariant
- Returns human-readable error messages
- Can be called from command line or hooks

### 2. Three Implementation Approaches

#### Approach A: Pure Bash
**`hooks/scripts/validate-scope-nickel.sh`**
```bash
# Inspect filesystem
has_claude_md="true"
has_context="false"

# Build Nickel JSON
echo '{ path = "src/auth", has_claude_md = true, ... }'

# Validate
nickel eval --field validate_and_format scope-directory-runtime.ncl
```

#### Approach B: Nushell + Nickel
**`hooks/scripts-nu/validate-scope-nickel.nu`**
```nushell
# Clean filesystem checks
let state = build-scope-state "src/auth"

# Validate using helper
validate-for-hook "src/auth"
```

#### Approach C: Nushell Helpers
**`tools/validate-with-nickel.nu`**
```nushell
# Reusable functions
export def validate-scope-with-nickel [path: string]
export def scope-validation-report []
export def test-nickel-validation []
```

## How It Works

### The Flow

```
1. Claude: Write("src/auth/jwt.py")
   ↓
2. Hook triggers: validate-scope-nickel.sh
   ↓
3. Inspect filesystem:
   src/auth/CLAUDE.md ✓
   src/auth/.kiro-scope/ ✓
   src/auth/.kiro-scope/scoped-tasks.md ✓
   src/auth/.kiro-scope/assertions.md ✓
   src/auth/.kiro-scope/context.md ✗  ← Missing!
   ↓
4. Build JSON state:
   {
     path = "src/auth",
     has_claude_md = true,
     has_kiro_scope_dir = true,
     required_files = {
       scoped_tasks = true,
       assertions = true,
       context = false  # Invalid!
     }
   }
   ↓
5. Call Nickel:
   echo "$json" | nickel eval --validate scope-directory-runtime.ncl
   ↓
6. Nickel validates and returns:
   "❌ Scope Validation Failed for src/auth
    Errors:
      - .kiro-scope/context.md not found

    Required action: Run /kiro-scope src/auth"
   ↓
7. Hook blocks Write operation
   ↓
8. User sees error, fixes structure
```

## Testing

### Run the test script:
```bash
./examples/test-nickel-validation.sh
```

### Manual tests:

**Test 1: Valid scope**
```bash
echo '{
  path = "src/auth",
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = true,
  }
}' | nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl
```

Output:
```
✓ Scope structure valid for src/auth
```

**Test 2: Invalid scope**
```bash
echo '{
  path = "src/api",
  has_claude_md = false,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = false,
    context = false,
  }
}' | nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl
```

Output:
```
❌ Scope Validation Failed for src/api

Errors:
  - CLAUDE.md not found in directory
  - .kiro-scope/assertions.md not found
  - .kiro-scope/context.md not found

**Required action:** Run `/kiro-scope src/api`
```

**Test 3: Using Nushell**
```bash
nu -c "use tools/validate-with-nickel.nu *; test-nickel-validation"
```

## Enable in Your Plugin

### Option 1: Replace default hooks
```bash
cp hooks/hooks-nickel.json hooks/hooks.json
```

### Option 2: Add to existing hooks.json
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

### Option 3: Use Nushell version
```json
{
  "hooks": [
    {
      "type": "command",
      "command": "nu ${CLAUDE_PLUGIN_ROOT}/hooks/scripts-nu/validate-scope-nickel.nu",
      "timeout": 5000
    }
  ]
}
```

## Benefits Demonstrated

### 1. Type Safety
```nickel
# Contract catches type errors
{
  has_claude_md = "yes"  # ERROR: Should be Bool, not String!
}
```

### 2. Single Source of Truth
```nickel
# Define validation ONCE in contract
validate_scope_state = fun state => { ... }

# Use EVERYWHERE (bash, nushell, CI, tests)
```

### 3. Maintainability
```nickel
# Want to require README.md?
# Just update the contract:
required_files = {
  scoped_tasks | Bool,
  assertions | Bool,
  context | Bool,
  readme | Bool,  # NEW!
}

# All hooks automatically enforce it!
```

### 4. Self-Documenting
```nickel
RuntimeScopeState = {
  path | String | doc "Path to the directory being validated",
  has_claude_md | Bool | doc "CLAUDE.md exists in directory",
  ...
}
```

### 5. Testable
```bash
# Easy to test validation logic
echo '{ ... test data ... }' | nickel eval ...

# Can create test suite
for test in tests/*.ncl; do
  nickel eval --validate scope-directory-runtime.ncl < $test
done
```

## Performance

```bash
# Pure bash validation
time bash hooks/scripts/validate-spec.sh
# Real: 0.05s

# Nickel validation
time bash hooks/scripts/validate-scope-nickel.sh
# Real: 0.15s
```

**Trade-off:** ~100ms overhead for type safety and maintainability.

## Comparison Table

| Feature | Bash Only | Nickel Runtime |
|---------|-----------|----------------|
| Type safety | ❌ | ✅ |
| Single source of truth | ❌ | ✅ |
| Self-documenting | ❌ | ✅ |
| Easy to test | ❌ | ✅ |
| Performance | ✅ (50ms) | ⚠️ (150ms) |
| Maintainability | ❌ | ✅ |
| Reusability | ❌ | ✅ |

## Next Steps

1. **Try it:**
   ```bash
   ./examples/test-nickel-validation.sh
   ```

2. **Enable it:**
   ```bash
   cp hooks/hooks-nickel.json hooks/hooks.json
   ```

3. **Customize it:**
   Edit `.contracts/schema/scope-directory-runtime.ncl`

4. **Extend it:**
   Create similar runtime contracts for assertions, tasks, etc.

## Documentation

- **[docs/NICKEL-RUNTIME.md](../docs/NICKEL-RUNTIME.md)** - Complete guide
- **[docs/CONTRACTS.md](../docs/CONTRACTS.md)** - Contract reference
- **[docs/HOOKS.md](../docs/HOOKS.md)** - Hook documentation

## Real-World Example

When you run `/kiro-scope src/auth` and it generates files, then you try to write code without completing the structure:

```bash
# Claude tries to write
Write("src/auth/jwt.py")

# Hook validates
validate-scope-nickel.sh
  → Checks filesystem
  → Missing context.md!
  → Calls Nickel contract
  → Returns error

# Claude sees error
"❌ .kiro-scope/context.md not found"

# Claude fixes it
/kiro-scope src/auth  # Regenerate with all files

# Now Write succeeds
Write("src/auth/jwt.py") ✓
```

The contract enforces the structural invariant **at runtime**!

## Summary

This demonstrates **full runtime Nickel validation**:

✅ Contracts define structure formally
✅ Hooks inspect filesystem at runtime
✅ Nickel validates filesystem state
✅ Operations blocked if invalid
✅ Type-safe, maintainable, testable

The contracts are no longer just documentation - they're **executable specifications** that enforce the methodology at runtime!
