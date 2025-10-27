#!/usr/bin/env bash
# Kiro Spec Validation Hook (Bash version)
# Validates that .kiro/spec files exist and are complete before code changes
#
# Note: A Nushell version is available in hooks/scripts-nu/validate-spec.nu
# When mcp-server-nu is configured, Claude can use the Nushell version
# via MCP tools for enhanced markdown parsing and structured data handling.
# This bash version serves as a fallback for compatibility.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and file path from JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.toolInput.file_path // ""')

# Only validate if editing/writing source files (not test files, not spec files)
if [[ "$FILE_PATH" =~ ^src/ ]] && [[ ! "$FILE_PATH" =~ test|spec|\.test\.|\.spec\. ]]; then

  # Check if we're in a kiro project (has .kiro directory)
  if [[ ! -d ".kiro" ]]; then
    # Not a kiro project, allow operation
    exit 0
  fi

  # Define required spec files
  SPEC_DIR=".kiro/spec"
  REQUIRED_FILES=("requirements.md" "design.md" "tasks.md")
  MISSING_FILES=()
  INCOMPLETE_FILES=()

  # Check if spec directory exists
  if [[ ! -d "$SPEC_DIR" ]]; then
    echo "{\"continue\": false, \"additionalContext\": \"❌ Spec Validation Failed\\n\\nCannot modify source code without specifications.\\n\\nMissing: $SPEC_DIR directory\\n\\n**Required action:** Run \\\`/kiro-spec\\\` to generate specifications before implementing code.\"}"
    exit 2
  fi

  # Check each required file
  for file in "${REQUIRED_FILES[@]}"; do
    file_path="$SPEC_DIR/$file"

    if [[ ! -f "$file_path" ]]; then
      MISSING_FILES+=("$file")
    else
      # Check if file has meaningful content (more than just headers/whitespace)
      content_lines=$(grep -vE '^(#|$|\s*$)' "$file_path" | wc -l || echo "0")
      if [[ "$content_lines" -lt 3 ]]; then
        INCOMPLETE_FILES+=("$file")
      fi
    fi
  done

  # If any files are missing or incomplete, block the operation
  if [[ ${#MISSING_FILES[@]} -gt 0 ]] || [[ ${#INCOMPLETE_FILES[@]} -gt 0 ]]; then
    ERROR_MSG="❌ Spec Validation Failed\\n\\n"
    ERROR_MSG+="Cannot modify source code without complete specifications.\\n\\n"

    if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
      ERROR_MSG+="**Missing files:**\\n"
      for file in "${MISSING_FILES[@]}"; do
        ERROR_MSG+="- $SPEC_DIR/$file\\n"
      done
      ERROR_MSG+="\\n"
    fi

    if [[ ${#INCOMPLETE_FILES[@]} -gt 0 ]]; then
      ERROR_MSG+="**Incomplete files (need more content):**\\n"
      for file in "${INCOMPLETE_FILES[@]}"; do
        ERROR_MSG+="- $SPEC_DIR/$file\\n"
      done
      ERROR_MSG+="\\n"
    fi

    ERROR_MSG+="**Required action:** Run \\\`/kiro-spec\\\` to create/update specifications before implementing code.\\n\\n"
    ERROR_MSG+="**Why?** Spec-driven development ensures we understand requirements, design, and tasks before writing code."

    echo "{\"continue\": false, \"additionalContext\": \"$ERROR_MSG\"}"
    exit 2
  fi

fi

# Validation passed or not applicable
exit 0
