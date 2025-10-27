#!/usr/bin/env nu
# Kiro Scope Validation Hook (Nushell + Nickel version)
# Validates scope directory structure using Nickel contracts at runtime

use ../../../tools/validate-with-nickel.nu *

# Main validation logic
def main []: string -> record {
  # Read JSON input from stdin
  let input = $in | from json

  # Extract tool info
  let tool_name = ($input.toolName? | default "")
  let file_path = ($input.toolInput?.file_path? | default "")

  # Only validate source files (not tests, specs, or docs)
  let is_source = (
    ($file_path | str starts-with "src/") or
    ($file_path | str starts-with "lib/") or
    ($file_path | str starts-with "app/")
  )

  let is_test = (
    ($file_path | str contains "test") or
    ($file_path | str contains "spec")
  )

  if not $is_source or $is_test {
    return {continue: true}
  }

  # Check if we're in a kiro project
  if not (".kiro" | path exists) {
    return {continue: true}
  }

  # Get parent directory
  let dir_path = ($file_path | path dirname)

  # Check if directory has source files
  let has_source_files = (
    try {
      ls $dir_path | where type == file | length
    } catch {
      0
    }
  ) > 0

  if not $has_source_files {
    return {continue: true}
  }

  # Validate using Nickel
  validate-for-hook $dir_path
}

# Run main with stdin
main
