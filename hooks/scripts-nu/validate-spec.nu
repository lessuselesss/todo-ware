#!/usr/bin/env nu
# Kiro Spec Validation Hook (Nushell version)
# Validates that .kiro/spec files exist and are complete before code changes

use ../../../tools/kiro.nu *

# Main validation logic
def main []: string -> record {
  # Read JSON input from stdin
  let input = $in | from json

  # Extract tool info
  let tool_name = ($input.toolName? | default "")
  let file_path = ($input.toolInput?.file_path? | default "")

  # Only validate if editing/writing source files (not test files, not spec files)
  if not ($file_path | str starts-with "src/") {
    return {continue: true}
  }

  if ($file_path | str contains "test") or ($file_path | str contains "spec") {
    return {continue: true}
  }

  # Check if we're in a kiro project
  if not (is-kiro-project) {
    return {continue: true}
  }

  # Check all spec files
  let spec_check = (check-all-specs)

  if $spec_check.valid {
    return {continue: true}
  }

  # Build error message
  mut error_parts = ["❌ Spec Validation Failed\n\n"]
  $error_parts = ($error_parts | append "Cannot modify source code without complete specifications.\n\n")

  if ($spec_check.missing | length) > 0 {
    $error_parts = ($error_parts | append "**Missing files:**\n")
    for file in $spec_check.missing {
      $error_parts = ($error_parts | append $"- .kiro/spec/($file)\n")
    }
    $error_parts = ($error_parts | append "\n")
  }

  if ($spec_check.incomplete | length) > 0 {
    $error_parts = ($error_parts | append "**Incomplete files (need more content):**\n")
    for file in $spec_check.incomplete {
      $error_parts = ($error_parts | append $"- .kiro/spec/($file)\n")
    }
    $error_parts = ($error_parts | append "\n")
  }

  $error_parts = ($error_parts | append "**Required action:** Run `/kiro-spec` to create/update specifications before implementing code.\n\n")
  $error_parts = ($error_parts | append "**Why?** Spec-driven development ensures we understand requirements, design, and tasks before writing code.")

  {
    continue: false,
    additionalContext: ($error_parts | str join "")
  }
}

# Run main with stdin
main
