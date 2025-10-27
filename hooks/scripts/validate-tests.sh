#!/usr/bin/env bash
# Kiro TDD Validation Hook (Bash version)
# Ensures tests exist before implementation (Test-Driven Development)
#
# Note: A Nushell version is available in hooks/scripts-nu/validate-tests.nu
# When mcp-server-nu is configured, Claude can use the Nushell version
# via MCP tools for better test file detection and content validation.
# This bash version serves as a fallback for compatibility.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and file path from JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.toolInput.file_path // ""')

# Only validate if editing/writing implementation files (not test files themselves)
if [[ "$FILE_PATH" =~ ^src/ ]] && [[ ! "$FILE_PATH" =~ test|spec|\.test\.|\.spec\. ]]; then

  # Check if we're in a kiro project
  if [[ ! -d ".kiro" ]]; then
    # Not a kiro project, allow operation
    exit 0
  fi

  # Determine test file path based on common patterns
  # Support multiple testing patterns: __tests__, .test., .spec., tests/ directory
  DIR=$(dirname "$FILE_PATH")
  FILENAME=$(basename "$FILE_PATH")
  BASE="${FILENAME%.*}"
  EXT="${FILENAME##*.}"

  # Possible test file locations
  TEST_PATTERNS=(
    "$DIR/${BASE}.test.$EXT"
    "$DIR/${BASE}.spec.$EXT"
    "$DIR/__tests__/${BASE}.test.$EXT"
    "$DIR/__tests__/${BASE}.spec.$EXT"
    "${DIR/src/tests}/${BASE}.test.$EXT"
    "${DIR/src/tests}/${BASE}.spec.$EXT"
  )

  # Check if any test file exists
  TEST_EXISTS=false
  TEST_FILE=""
  for pattern in "${TEST_PATTERNS[@]}"; do
    if [[ -f "$pattern" ]]; then
      TEST_EXISTS=true
      TEST_FILE="$pattern"

      # Check if test file has actual test content (not empty/boilerplate)
      content_lines=$(grep -vE '^(#|/\*|\*|//|$|\s*$|import|require)' "$pattern" | wc -l || echo "0")
      if [[ "$content_lines" -lt 5 ]]; then
        # Test file exists but is empty/minimal
        ERROR_MSG="❌ TDD Validation Failed\\n\\n"
        ERROR_MSG+="Test file exists but has no test cases: $pattern\\n\\n"
        ERROR_MSG+="**Required action:** Write failing tests BEFORE implementing code.\\n\\n"
        ERROR_MSG+="**TDD Workflow:**\\n"
        ERROR_MSG+="1. 🔴 RED: Write a failing test that describes the desired behavior\\n"
        ERROR_MSG+="2. 🟢 GREEN: Write minimal code to make the test pass\\n"
        ERROR_MSG+="3. ♻️  REFACTOR: Improve the code while keeping tests green\\n\\n"
        ERROR_MSG+="**Why?** Tests first ensure we build what's needed and catch regressions."

        echo "{\"continue\": false, \"additionalContext\": \"$ERROR_MSG\"}"
        exit 2
      fi

      break
    fi
  done

  # If no test file exists, block the operation
  if [[ "$TEST_EXISTS" == false ]]; then
    ERROR_MSG="❌ TDD Validation Failed\\n\\n"
    ERROR_MSG+="No test file found for: $FILE_PATH\\n\\n"
    ERROR_MSG+="**Expected test file locations:**\\n"
    for pattern in "${TEST_PATTERNS[@]}"; do
      ERROR_MSG+="- $pattern\\n"
    done
    ERROR_MSG+="\\n**Required action:** Create test file with failing tests BEFORE implementing code.\\n\\n"
    ERROR_MSG+="**TDD Workflow:**\\n"
    ERROR_MSG+="1. 🔴 RED: Write a failing test that describes the desired behavior\\n"
    ERROR_MSG+="2. 🟢 GREEN: Write minimal code to make the test pass\\n"
    ERROR_MSG+="3. ♻️  REFACTOR: Improve the code while keeping tests green\\n\\n"
    ERROR_MSG+="**Why?** Writing tests first clarifies requirements and ensures testable, maintainable code."

    echo "{\"continue\": false, \"additionalContext\": \"$ERROR_MSG\"}"
    exit 2
  fi

fi

# Validation passed or not applicable
exit 0
