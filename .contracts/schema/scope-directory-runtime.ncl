# Scope Directory Runtime Validator
#
# This is a runtime-friendly version of scope-directory.ncl that can be
# called from hooks to validate filesystem state at runtime.
#
# Usage:
#   echo '{"path": "src/auth", ...}' | nickel eval --validate scope-directory-runtime.ncl

let scope = import "scope-directory.ncl" in

{
  # Runtime validation input format
  # This represents the current filesystem state
  RuntimeScopeState = {
    path | String | doc "Path to the directory being validated",
    has_source_files | doc "Directory contains source files" | Bool | default = true,
    has_claude_md | Bool | doc "CLAUDE.md exists in directory",
    has_kiro_scope_dir | Bool | doc ".kiro-scope/ directory exists",

    required_files | {
      scoped_tasks | Bool | doc ".kiro-scope/scoped-tasks.md exists",
      assertions | Bool | doc ".kiro-scope/assertions.md exists",
      context | Bool | doc ".kiro-scope/context.md exists",
    },

    optional_files | {
      contracts_dir | doc ".kiro-scope/contracts/ exists" | Bool | default = false,
      readme | doc ".kiro-scope/README.md exists" | Bool | default = false,
    } | optional,
  },

  # Validation result format
  ValidationResult = {
    valid | Bool | doc "Is the scope valid?",
    path | String | doc "Path that was validated",
    errors | doc "List of validation errors" | Array String | default = [],
    warnings | doc "List of warnings (non-blocking)" | Array String | default = [],
  },

  # Main validation function
  # Takes RuntimeScopeState, returns ValidationResult
  validate_scope_state = fun state => {
    # Build list of errors
    errors =
      (if !state.has_source_files then
        []
      else
        (if !state.has_claude_md then
          ["CLAUDE.md not found in directory"]
        else [])
        ++
        (if !state.has_kiro_scope_dir then
          [".kiro-scope/ directory not found"]
        else [])
        ++
        (if state.has_kiro_scope_dir then
          (if !state.required_files.scoped_tasks then
            [".kiro-scope/scoped-tasks.md not found"]
          else [])
          ++
          (if !state.required_files.assertions then
            [".kiro-scope/assertions.md not found"]
          else [])
          ++
          (if !state.required_files.context then
            [".kiro-scope/context.md not found"]
          else [])
        else [])),

    # Build list of warnings
    warnings =
      if std.record.has_field "optional_files" state then
        (if !state.optional_files.contracts_dir then
          [".kiro-scope/contracts/ directory recommended but not required"]
        else [])
      else [],

    # Return validation result
    valid = std.array.length errors == 0,
    path = state.path,
    errors = errors,
    warnings = warnings,
  } | ValidationResult,

  # Format validation result as human-readable message
  format_validation_result = fun result =>
    if result.valid then
      "✓ Scope structure valid for " ++ result.path
    else
      let error_list = std.array.fold_right
        (fun err acc => "  - " ++ err ++ "\n" ++ acc)
        ""
        result.errors
      in
      "❌ Scope Validation Failed for " ++ result.path ++ "\n\n" ++
      "Errors:\n" ++ error_list ++
      "\n**Required action:** Run `/kiro-scope " ++ result.path ++ "` to generate proper scope structure.\n\n" ++
      "**Structural Invariant:** Any directory with source files MUST have:\n" ++
      "1. CLAUDE.md - Implementation workflow\n" ++
      "2. .kiro-scope/ directory with:\n" ++
      "   - scoped-tasks.md\n" ++
      "   - assertions.md\n" ++
      "   - context.md",

  # Validate and format in one call (for command-line use)
  validate_and_format = fun state =>
    let result = validate_scope_state state in
    format_validation_result result,

  # Check if directory should be validated
  # Only validate directories with source files
  should_validate_directory = fun path =>
    # Source directories that should have scopes
    std.string.starts_with path "src/" ||
    std.string.starts_with path "lib/" ||
    std.string.starts_with path "app/",

  # Get parent directory from file path
  # Example: "src/auth/jwt.py" -> "src/auth"
  get_parent_directory = fun file_path =>
    let parts = std.string.split "/" file_path in
    let without_file = std.array.slice 0 (std.array.length parts - 1) parts in
    std.string.join "/" without_file,

  # Quick validation (just returns bool)
  is_valid_scope = fun state =>
    state.has_claude_md &&
    state.has_kiro_scope_dir &&
    state.required_files.scoped_tasks &&
    state.required_files.assertions &&
    state.required_files.context,
}
