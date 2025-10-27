#!/usr/bin/env bash
# Kiro Contract Validation Hook (Bash version)
# Validates nickel contracts before git commits
#
# Note: A Nushell version is available in hooks/scripts-nu/validate-contracts.nu
# When mcp-server-nu is configured, Claude can use the Nushell version
# via MCP tools for structured error parsing and reporting.
# This bash version serves as a fallback for compatibility.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract command from JSON
COMMAND=$(echo "$INPUT" | jq -r '.toolInput.command // ""')

# Only validate on git commit operations
if [[ "$COMMAND" =~ git[[:space:]]+commit ]]; then

  # Check if we're in a kiro project with contracts
  if [[ ! -d ".contracts" ]]; then
    # No contracts directory, allow operation
    exit 0
  fi

  # Check if nickel is available
  if ! command -v nickel &> /dev/null; then
    # Nickel not installed, provide warning but don't block
    echo "{\"continue\": true, \"additionalContext\": \"⚠️  Nickel not found - skipping contract validation\\n\\nInstall nickel to enable contract type-checking:\\n- Via nix: \\\`nix profile install nixpkgs#nickel\\\`\\n- Via cargo: \\\`cargo install nickel-lang-cli\\\`\"}"
    exit 0
  fi

  # Find all nickel contract files
  CONTRACT_FILES=$(find .contracts -name "*.ncl" 2>/dev/null || echo "")

  if [[ -z "$CONTRACT_FILES" ]]; then
    # No contract files found, allow operation
    exit 0
  fi

  # Validate each contract file
  ERRORS=""
  HAS_ERRORS=false

  while IFS= read -r file; do
    if [[ -n "$file" ]]; then
      # Try to typecheck the nickel file
      if ! nickel typecheck "$file" 2>&1 > /dev/null; then
        HAS_ERRORS=true
        ERROR_OUTPUT=$(nickel typecheck "$file" 2>&1 || echo "Unknown error")
        ERRORS+="\\n**$file:**\\n\`\`\`\\n$ERROR_OUTPUT\\n\`\`\`\\n"
      fi
    fi
  done <<< "$CONTRACT_FILES"

  # If there are errors, block the commit
  if [[ "$HAS_ERRORS" == true ]]; then
    ERROR_MSG="❌ Contract Validation Failed\\n\\n"
    ERROR_MSG+="Nickel type-checking failed for contract files.\\n\\n"
    ERROR_MSG+="**Errors found:**$ERRORS\\n"
    ERROR_MSG+="**Required action:** Fix contract type errors before committing.\\n\\n"
    ERROR_MSG+="**Why?** Nickel contracts ensure type safety and prevent runtime errors."

    echo "{\"continue\": false, \"additionalContext\": \"$ERROR_MSG\"}"
    exit 2
  fi

  # All contracts valid
  echo "{\"continue\": true, \"additionalContext\": \"✅ Contract validation passed - all nickel types are valid\"}"
  exit 0

fi

# Not a commit operation, allow
exit 0
