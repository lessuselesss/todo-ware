#!/usr/bin/env bash
# Kiro Scope Validation Hook (Nickel-based)
# Validates scope directory structure using Nickel contracts at runtime
#
# This demonstrates FULL RUNTIME NICKEL VALIDATION:
# 1. Extract file path from Claude's tool invocation
# 2. Build JSON representation of filesystem state
# 3. Pass to Nickel contract for validation
# 4. Block operation if validation fails

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and file path from JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.toolInput.file_path // ""')

# Only validate source files (not tests, not specs, not docs)
if [[ ! "$FILE_PATH" =~ ^(src|lib|app)/ ]] || [[ "$FILE_PATH" =~ test|spec|\.test\.|\.spec\. ]]; then
  exit 0
fi

# Check if we're in a kiro project
if [[ ! -d ".kiro" ]]; then
  exit 0
fi

# Get parent directory of the file
DIR_PATH=$(dirname "$FILE_PATH")

# Check if directory should be validated
# Only validate if it has actual source files (not just subdirectories)
if [[ ! -f "$DIR_PATH"/*.* ]] 2>/dev/null; then
  exit 0
fi

# Build JSON representation of filesystem state
build_scope_state() {
  local path="$1"

  # Check filesystem
  local has_claude_md="false"
  local has_kiro_scope_dir="false"
  local has_scoped_tasks="false"
  local has_assertions="false"
  local has_context="false"
  local has_contracts_dir="false"

  [[ -f "$path/CLAUDE.md" ]] && has_claude_md="true"
  [[ -d "$path/.kiro-scope" ]] && has_kiro_scope_dir="true"
  [[ -f "$path/.kiro-scope/scoped-tasks.md" ]] && has_scoped_tasks="true"
  [[ -f "$path/.kiro-scope/assertions.md" ]] && has_assertions="true"
  [[ -f "$path/.kiro-scope/context.md" ]] && has_context="true"
  [[ -d "$path/.kiro-scope/contracts" ]] && has_contracts_dir="true"

  # Build JSON (Nickel-compatible format)
  cat <<EOF
{
  path = "$path",
  has_source_files = true,
  has_claude_md = $has_claude_md,
  has_kiro_scope_dir = $has_kiro_scope_dir,
  required_files = {
    scoped_tasks = $has_scoped_tasks,
    assertions = $has_assertions,
    context = $has_context,
  },
  optional_files = {
    contracts_dir = $has_contracts_dir,
  },
}
EOF
}

# Build scope state JSON
SCOPE_STATE=$(build_scope_state "$DIR_PATH")

# Validate using Nickel contract
CONTRACT_PATH="${CLAUDE_PLUGIN_ROOT}/.contracts/schema/scope-directory-runtime.ncl"

if [[ ! -f "$CONTRACT_PATH" ]]; then
  # Contract not found - fall back to allowing operation
  echo "Warning: Nickel contract not found at $CONTRACT_PATH" >&2
  exit 0
fi

# Run Nickel validation
VALIDATION_OUTPUT=$(echo "$SCOPE_STATE" | nickel eval --field validate_and_format "$CONTRACT_PATH" 2>&1 || true)

# Check if validation passed
if echo "$VALIDATION_OUTPUT" | grep -q "^✓"; then
  # Validation passed
  exit 0
else
  # Validation failed - format error message
  ERROR_MSG=$(echo "$VALIDATION_OUTPUT" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

  echo "{\"continue\": false, \"additionalContext\": \"$ERROR_MSG\"}"
  exit 2
fi
