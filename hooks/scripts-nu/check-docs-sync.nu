#!/usr/bin/env nu
# Kiro Documentation Sync Reminder Hook (Nushell version)
# Non-blocking reminder to update documentation after significant code changes

use ../../../tools/kiro.nu *

# Main validation logic
def main []: string -> record {
  # Read JSON input from stdin
  let input = $in | from json

  # Extract file info
  let file_path = ($input.toolInput?.file_path? | default "")
  let new_content = ($input.toolInput?.content? | default "")

  # Only check for source files (not docs themselves)
  if not ($file_path | str starts-with "src/") {
    return {continue: true}
  }

  if ($file_path | str contains "README") or ($file_path | str contains "CLAUDE.md") {
    return {continue: true}
  }

  # Check if we're in a kiro project
  if not (is-kiro-project) {
    return {continue: true}
  }

  # Count lines in new content
  let line_count = ($new_content | lines | length)

  # Check if this is a significant change (>50 lines) or new file
  let is_new_file = not ($file_path | path exists)
  let is_significant = $line_count > 50

  if not ($is_new_file or $is_significant) {
    return {continue: true}
  }

  # Check documentation staleness
  let docs_check = (check-docs-stale)

  # If docs are fresh (updated in last hour), no reminder needed
  if not ($docs_check.claude_stale or $docs_check.readme_stale) {
    return {continue: true}
  }

  # Build reminder message
  mut reminder_parts = ["📝 Documentation Sync Reminder\n\n"]
  $reminder_parts = ($reminder_parts | append $"Significant code changes detected in: ($file_path)\n\n")

  if $docs_check.claude_stale {
    $reminder_parts = ($reminder_parts | append $"- ⚠️  CLAUDE.md may need updating (last modified: ($docs_check.claude_age_hours) hours ago)\n")
  }

  if $docs_check.readme_stale {
    $reminder_parts = ($reminder_parts | append $"- ⚠️  README.md may need updating (last modified: ($docs_check.readme_age_hours) hours ago)\n")
  }

  $reminder_parts = ($reminder_parts | append "\n**Recommended:**\n")
  $reminder_parts = ($reminder_parts | append "- Update CLAUDE.md with implementation details and context\n")
  $reminder_parts = ($reminder_parts | append "- Update README.md if public API or usage has changed\n")
  $reminder_parts = ($reminder_parts | append "- Run `/kiro-spec` to sync specifications with implementation\n\n")
  $reminder_parts = ($reminder_parts | append "**Why?** Keeping docs in sync helps Claude assist more effectively and improves team collaboration.")

  # Non-blocking reminder
  {
    continue: true,
    additionalContext: ($reminder_parts | str join "")
  }
}

# Run main with stdin
main
