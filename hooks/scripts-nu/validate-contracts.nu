#!/usr/bin/env nu
# Kiro Contract Validation Hook (Nushell version)
# Validates nickel contracts before git commits

# Main validation logic
def main []: string -> record {
  # Read JSON input from stdin
  let input = $in | from json

  # Extract command
  let command = ($input.toolInput?.command? | default "")

  # Only validate on git commit operations
  if not ($command | str contains "git commit") {
    return {continue: true}
  }

  # Check if we're in a kiro project with contracts
  if not (".contracts" | path exists) {
    return {continue: true}
  }

  # Check if nickel is available
  let nickel_available = (which nickel | length) > 0

  if not $nickel_available {
    return {
      continue: true,
      additionalContext: "⚠️  Nickel not found - skipping contract validation\n\nInstall nickel to enable contract type-checking:\n- Via nix: `nix profile install nixpkgs#nickel`\n- Via cargo: `cargo install nickel-lang-cli`"
    }
  }

  # Find all nickel contract files
  let contract_files = (glob .contracts/**/*.ncl)

  if ($contract_files | length) == 0 {
    return {continue: true}
  }

  # Validate each contract file
  mut errors = []

  for file in $contract_files {
    let result = (do { nickel typecheck $file } | complete)

    if $result.exit_code != 0 {
      $errors = ($errors | append {
        file: $file,
        error: $result.stderr
      })
    }
  }

  # If there are errors, block the commit
  if ($errors | length) > 0 {
    mut error_parts = ["❌ Contract Validation Failed\n\n"]
    $error_parts = ($error_parts | append "Nickel type-checking failed for contract files.\n\n")
    $error_parts = ($error_parts | append "**Errors found:**\n")

    for err in $errors {
      $error_parts = ($error_parts | append $"\n**($err.file):**\n```\n($err.error)\n```\n")
    }

    $error_parts = ($error_parts | append "\n**Required action:** Fix contract type errors before committing.\n\n")
    $error_parts = ($error_parts | append "**Why?** Nickel contracts ensure type safety and prevent runtime errors.")

    return {
      continue: false,
      additionalContext: ($error_parts | str join "")
    }
  }

  # All contracts valid
  {
    continue: true,
    additionalContext: "✅ Contract validation passed - all nickel types are valid"
  }
}

# Run main with stdin
main
