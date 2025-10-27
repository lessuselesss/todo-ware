# Validate with Nickel - Helper Functions
#
# Converts filesystem state to Nickel-compatible JSON and validates
# using Nickel contracts. This provides a clean Nushell interface
# to runtime Nickel validation.

# Build Nickel-compatible JSON for scope directory state
export def build-scope-state [path: string] {
  {
    path: $path,
    has_source_files: true,
    has_claude_md: ($"($path)/CLAUDE.md" | path exists),
    has_kiro_scope_dir: ($"($path)/.kiro-scope" | path exists),
    required_files: {
      scoped_tasks: ($"($path)/.kiro-scope/scoped-tasks.md" | path exists),
      assertions: ($"($path)/.kiro-scope/assertions.md" | path exists),
      context: ($"($path)/.kiro-scope/context.md" | path exists),
    },
    optional_files: {
      contracts_dir: ($"($path)/.kiro-scope/contracts" | path exists),
    }
  }
}

# Convert Nushell record to Nickel format
# Nickel uses = instead of : for record fields
export def to-nickel-format [] -> string {
  let data = $in

  # Convert to JSON first
  let json_str = ($data | to json)

  # Replace : with = for Nickel syntax
  # Replace true/false with Nickel booleans
  $json_str
  | str replace --all '": ' '" = '
  | str replace --all ': ' ' = '
}

# Validate scope directory using Nickel contract
export def validate-scope-with-nickel [path: string] {
  # Build state
  let state = (build-scope-state $path)

  # Convert to Nickel format
  let nickel_input = ($state | to-nickel-format)

  # Path to contract
  let contract_path = ".contracts/schema/scope-directory-runtime.ncl"

  if not ($contract_path | path exists) {
    return {
      valid: false,
      error: "Nickel contract not found",
      path: $path
    }
  }

  # Run Nickel validation
  let result = (
    $nickel_input
    | nickel eval --field validate_and_format $contract_path
    | complete
  )

  if $result.exit_code == 0 {
    {
      valid: ($result.stdout | str contains "✓"),
      message: $result.stdout,
      path: $path
    }
  } else {
    {
      valid: false,
      message: $result.stderr,
      path: $path
    }
  }
}

# Validate scope structure (returns bool)
export def is-valid-scope-nickel [path: string] -> bool {
  let result = (validate-scope-with-nickel $path)
  $result.valid
}

# Validate and format for hook output
export def validate-for-hook [path: string] {
  let result = (validate-scope-with-nickel $path)

  if $result.valid {
    {continue: true}
  } else {
    {
      continue: false,
      additionalContext: $result.message
    }
  }
}

# Batch validate multiple directories
export def validate-all-scopes [] {
  glob **/.kiro-scope
  | each {|scope_dir|
      let parent = ($scope_dir | path dirname)
      {
        path: $parent,
        result: (validate-scope-with-nickel $parent)
      }
    }
}

# Generate validation report
export def scope-validation-report [] {
  let results = (validate-all-scopes)

  let valid = ($results | where result.valid)
  let invalid = ($results | where not result.valid)

  {
    total: ($results | length),
    valid: ($valid | length),
    invalid: ($invalid | length),
    invalid_scopes: ($invalid | each {|r| $r.path}),
    summary: (
      if ($invalid | length) == 0 {
        "✓ All scopes valid"
      } else {
        $"❌ ($invalid | length) invalid scope(s)"
      }
    )
  }
}

# Test Nickel validation with example data
export def test-nickel-validation [] {
  # Create test state (invalid - missing context.md)
  let test_state = {
    path: "src/test",
    has_source_files: true,
    has_claude_md: true,
    has_kiro_scope_dir: true,
    required_files: {
      scoped_tasks: true,
      assertions: true,
      context: false  # Missing!
    }
  }

  print "Testing Nickel validation with invalid state..."
  let nickel_input = ($test_state | to-nickel-format)
  print $nickel_input

  print "\nValidation result:"
  $nickel_input | nickel eval --field validate_and_format .contracts/schema/scope-directory-runtime.ncl
}
