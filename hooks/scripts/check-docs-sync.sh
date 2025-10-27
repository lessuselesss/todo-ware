#!/usr/bin/env bash
# Kiro Documentation Sync Reminder Hook (Bash version)
# Non-blocking reminder to update documentation after significant code changes
#
# Note: A Nushell version is available in hooks/scripts-nu/check-docs-sync.nu
# When mcp-server-nu is configured, Claude can use the Nushell version
# via MCP tools for better file age calculations and staleness detection.
# This bash version serves as a fallback for compatibility.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from JSON
FILE_PATH=$(echo "$INPUT" | jq -r '.toolInput.file_path // ""')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.toolInput.content // ""')

# Only check for source files (not docs themselves)
if [[ "$FILE_PATH" =~ ^src/ ]] && [[ ! "$FILE_PATH" =~ README|CLAUDE\.md ]]; then

  # Check if we're in a kiro project
  if [[ ! -d ".kiro" ]]; then
    # Not a kiro project, skip
    exit 0
  fi

  # Count lines in new content
  LINE_COUNT=$(echo "$NEW_CONTENT" | wc -l || echo "0")

  # If this is a significant change (>50 lines) or a new file
  if [[ $LINE_COUNT -gt 50 ]] || [[ ! -f "$FILE_PATH" ]]; then

    # Check when CLAUDE.md and README.md were last modified
    CLAUDE_MD_AGE=9999
    README_AGE=9999

    if [[ -f "CLAUDE.md" ]]; then
      CLAUDE_MD_AGE=$(( $(date +%s) - $(stat -c %Y "CLAUDE.md" 2>/dev/null || stat -f %m "CLAUDE.md" 2>/dev/null || echo "0") ))
    fi

    if [[ -f "README.md" ]]; then
      README_AGE=$(( $(date +%s) - $(stat -c %Y "README.md" 2>/dev/null || stat -f %m "README.md" 2>/dev/null || echo "0") ))
    fi

    # If docs haven't been updated in the last hour (3600 seconds), provide reminder
    if [[ $CLAUDE_MD_AGE -gt 3600 ]] || [[ $README_AGE -gt 3600 ]]; then

      REMINDER_MSG="📝 Documentation Sync Reminder\\n\\n"
      REMINDER_MSG+="Significant code changes detected in: $FILE_PATH\\n\\n"

      if [[ $CLAUDE_MD_AGE -gt 3600 ]]; then
        REMINDER_MSG+="- ⚠️  CLAUDE.md may need updating (last modified: $(( $CLAUDE_MD_AGE / 3600 )) hours ago)\\n"
      fi

      if [[ $README_AGE -gt 3600 ]]; then
        REMINDER_MSG+="- ⚠️  README.md may need updating (last modified: $(( $README_AGE / 3600 )) hours ago)\\n"
      fi

      REMINDER_MSG+="\\n**Recommended:**\\n"
      REMINDER_MSG+="- Update CLAUDE.md with implementation details and context\\n"
      REMINDER_MSG+="- Update README.md if public API or usage has changed\\n"
      REMINDER_MSG+="- Run \\\`/kiro-spec\\\` to sync specifications with implementation\\n\\n"
      REMINDER_MSG+="**Why?** Keeping docs in sync helps Claude assist more effectively and improves team collaboration."

      # Non-blocking reminder
      echo "{\"continue\": true, \"additionalContext\": \"$REMINDER_MSG\"}"
      exit 0
    fi

  fi

fi

# No reminder needed
exit 0
