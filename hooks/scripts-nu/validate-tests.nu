#!/usr/bin/env nu
# Kiro TDD Validation Hook (Nushell version)
# Ensures tests exist before implementation (Test-Driven Development)

use ../../../tools/kiro.nu *

# Main validation logic
def main []: string -> record {
  # Read JSON input from stdin
  let input = $in | from json

  # Extract file path
  let file_path = ($input.toolInput?.file_path? | default "")

  # Only validate if editing/writing implementation files (not test files themselves)
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

  # Find test file
  let test_file = (find-test-file $file_path)

  if $test_file == null {
    # Generate list of expected test locations
    let dir = ($file_path | path dirname)
    let filename = ($file_path | path basename)
    let stem = ($filename | path parse | get stem)
    let ext = ($filename | path parse | get extension)

    let patterns = [
      $"($dir)/($stem).test.($ext)",
      $"($dir)/($stem).spec.($ext)",
      $"($dir)/__tests__/($stem).test.($ext)",
      $"($dir)/__tests__/($stem).spec.($ext)",
      ($"($dir)/($stem).test.($ext)" | str replace "src/" "tests/"),
      ($"($dir)/($stem).spec.($ext)" | str replace "src/" "tests/")
    ]

    mut error_parts = ["❌ TDD Validation Failed\n\n"]
    $error_parts = ($error_parts | append $"No test file found for: ($file_path)\n\n")
    $error_parts = ($error_parts | append "**Expected test file locations:**\n")

    for pattern in $patterns {
      $error_parts = ($error_parts | append $"- ($pattern)\n")
    }

    $error_parts = ($error_parts | append "\n**Required action:** Create test file with failing tests BEFORE implementing code.\n\n")
    $error_parts = ($error_parts | append "**TDD Workflow:**\n")
    $error_parts = ($error_parts | append "1. 🔴 RED: Write a failing test that describes the desired behavior\n")
    $error_parts = ($error_parts | append "2. 🟢 GREEN: Write minimal code to make the test pass\n")
    $error_parts = ($error_parts | append "3. ♻️  REFACTOR: Improve the code while keeping tests green\n\n")
    $error_parts = ($error_parts | append "**Why?** Writing tests first clarifies requirements and ensures testable, maintainable code.")

    return {
      continue: false,
      additionalContext: ($error_parts | str join "")
    }
  }

  # Test file exists, validate it has content
  let validation = (validate-test-content $test_file)

  if not $validation.valid {
    mut error_parts = ["❌ TDD Validation Failed\n\n"]
    $error_parts = ($error_parts | append $"Test file exists but has no test cases: ($test_file)\n\n")
    $error_parts = ($error_parts | append "**Required action:** Write failing tests BEFORE implementing code.\n\n")
    $error_parts = ($error_parts | append "**TDD Workflow:**\n")
    $error_parts = ($error_parts | append "1. 🔴 RED: Write a failing test that describes the desired behavior\n")
    $error_parts = ($error_parts | append "2. 🟢 GREEN: Write minimal code to make the test pass\n")
    $error_parts = ($error_parts | append "3. ♻️  REFACTOR: Improve the code while keeping tests green\n\n")
    $error_parts = ($error_parts | append "**Why?** Tests first ensure we build what's needed and catch regressions.")

    return {
      continue: false,
      additionalContext: ($error_parts | str join "")
    }
  }

  # Validation passed
  {continue: true}
}

# Run main with stdin
main
