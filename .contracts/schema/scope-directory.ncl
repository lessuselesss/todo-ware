# Scope Directory Schema
#
# Defines the structural invariant for .kiro-scope/ directories.
# This is the core architectural rule of the kiro methodology:
#
# ANY directory containing source files MUST have:
#   1. CLAUDE.md (implementation workflow)
#   2. .kiro-scope/ directory with required files

{
  # Required files in .kiro-scope/
  RequiredFiles = [
    "scoped-tasks.md",
    "assertions.md",
    "context.md",
  ],

  # Optional files in .kiro-scope/
  OptionalFiles = [
    "contracts/",  # Directory containing nickel contracts
    "README.md",   # Additional documentation
  ],

  # The structural invariant
  ScopeDirectoryInvariant = {
    # Parent directory must have CLAUDE.md
    has_claude_md | Bool | doc "Parent directory contains CLAUDE.md",

    # .kiro-scope/ directory must exist
    has_kiro_scope_dir | Bool | doc ".kiro-scope/ directory exists",

    # Required files must all be present
    required_files | {
      scoped_tasks | Bool | doc ".kiro-scope/scoped-tasks.md exists",
      assertions | Bool | doc ".kiro-scope/assertions.md exists",
      context | Bool | doc ".kiro-scope/context.md exists",
    },

    # Optional but recommended
    optional_files | {
      contracts_dir | Bool | optional | doc ".kiro-scope/contracts/ exists",
      readme | Bool | optional | doc ".kiro-scope/README.md exists",
    } | optional,
  },

  # Validation: All required components present
  validate_invariant = fun inv =>
    inv.has_claude_md &&
    inv.has_kiro_scope_dir &&
    inv.required_files.scoped_tasks &&
    inv.required_files.assertions &&
    inv.required_files.context,

  # Directory layout specification
  DirectoryLayout = {
    path | String | doc "Path to the directory",
    has_source_files | Bool | doc "Contains implementation files (.py, .ts, etc.)",

    # If has_source_files = true, invariant must hold
    scope_structure | ScopeDirectoryInvariant | doc "Scope structure validation",
  },

  # Validate directory follows kiro structure
  validate_directory = fun layout =>
    if layout.has_source_files then
      validate_invariant layout.scope_structure
    else
      true,  # Non-source directories don't need scopes

  # Expected directory structure (for documentation/generation)
  ExpectedStructure = {
    description | String | default = m%"
      Expected structure for a kiro scoped directory:

      my-module/
      ├── CLAUDE.md                    # Implementation workflow
      ├── source-file.py               # Implementation files
      └── .kiro-scope/
          ├── scoped-tasks.md          # Decomposed tasks
          ├── assertions.md            # TDD assertions
          ├── context.md               # Module context
          └── contracts/               # Nickel contracts (optional)
              └── source-file.ncl
    "%,

    validation_rules | Array String | default = [
      "CLAUDE.md MUST exist in the same directory as source files",
      ".kiro-scope/ MUST exist in the same directory as source files",
      ".kiro-scope/scoped-tasks.md MUST exist",
      ".kiro-scope/assertions.md MUST exist",
      ".kiro-scope/context.md MUST exist",
      ".kiro-scope/contracts/ SHOULD mirror parent directory structure",
    ],
  },

  # Generate directory structure specification
  generate_structure_spec = fun module_name => {
    module = module_name,
    required = {
      claude_md = module_name ++ "/CLAUDE.md",
      kiro_scope_dir = module_name ++ "/.kiro-scope/",
      scoped_tasks = module_name ++ "/.kiro-scope/scoped-tasks.md",
      assertions = module_name ++ "/.kiro-scope/assertions.md",
      context = module_name ++ "/.kiro-scope/context.md",
    },
    optional = {
      contracts_dir = module_name ++ "/.kiro-scope/contracts/",
      readme = module_name ++ "/.kiro-scope/README.md",
    },
  },
}
