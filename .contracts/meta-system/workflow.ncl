# Master Workflow Contract Types
#
# This is the foundational contract that defines the kiro methodology itself.
# All phases, steps, artifacts, and validations are specified here.

{
  # ============================================================================
  # Core Type Definitions
  # ============================================================================

  Workflow = {
    version
      | String
      | doc "Semantic version of workflow definition (e.g., '1.0.0')",

    phases
      | Array Phase
      | doc "All phases in execution order",

    global_artifacts
      | Array Artifact
      | doc "Artifacts that exist across all phases"
      | default = [],
  },

  Phase = {
    id
      | String
      | doc "Phase identifier (P1, P2, P3)",

    name
      | String
      | doc "Phase name (generation, pre_implementation, implementation)",

    description
      | String
      | doc "Human-readable description of phase purpose",

    steps
      | Array Step
      | doc "Steps in execution order within this phase",

    entry_conditions
      | {
          previous_phase_complete
            | Bool
            | doc "Previous phase must be complete before starting this phase",

          required_global_state
            | {_: Dyn}
            | doc "Global state values that must be set"
            | optional,
        }
      | doc "Conditions that must be met to enter this phase",

    exit_conditions
      | {
          all_steps_complete
            | Bool
            | doc "All steps in this phase must be complete",

          validation_passes
            | Array String
            | doc "Validator IDs that must pass (contract paths or script paths)",

          blocking_issues_resolved
            | Bool
            | doc "No blocking issues preventing advancement",
        }
      | doc "Conditions that must be met to exit this phase",
  },

  Step = {
    id
      | String
      | doc "Step identifier (e.g., P1.S1, P1.S2)",

    name
      | String
      | doc "Step name (snake_case identifier)",

    description
      | String
      | doc "Human-readable description of what this step does",

    order
      | Number
      | doc "Execution order within phase (1-indexed)",

    dependencies
      | {
          previous_steps
            | Array String
            | doc "Step IDs that must be complete before this step"
            | default = [],

          required_files
            | Array String
            | doc "File paths that must exist before this step"
            | default = [],

          required_contracts
            | Array String
            | doc "Contract paths that must be valid before this step"
            | default = [],

          required_state
            | {_: Dyn}
            | doc "State values that must be set before this step"
            | optional,
        }
      | doc "What must exist before this step can execute",

    artifacts
      | {
          files
            | Array FileArtifact
            | default = [],

          directories
            | Array DirectoryArtifact
            | default = [],

          contracts
            | Array ContractArtifact
            | default = [],

          scripts
            | Array ScriptArtifact
            | default = [],

          docs
            | Array DocArtifact
            | default = [],
        }
      | doc "What this step creates",

    validation
      | {
          files_exist
            | Array String
            | doc "File paths that must exist after step"
            | default = [],

          files_not_empty
            | Array String
            | doc "File paths that must have content after step"
            | default = [],

          contracts_valid
            | Array String
            | doc "Contract paths that must pass 'nickel eval --validate'"
            | default = [],

          scripts_executable
            | Array String
            | doc "Script paths that must be executable"
            | default = [],

          content_matches
            | Array ContentCheck
            | doc "Content validation checks"
            | default = [],

          custom_validators
            | Array String
            | doc "Script paths to run for custom validation"
            | default = [],
        }
      | doc "What must be true after this step completes",

    state_updates
      | {
          set_values
            | {_: Dyn}
            | doc "State values to set after step completion"
            | optional,

          append_to_history
            | {_: Dyn}
            | doc "Values to append to phase history"
            | optional,
        }
      | doc "State updates after successful completion",

    next_step
      | {
          on_success
            | String | Null
            | doc "Next step ID, or null if phase complete",

          on_failure
            | [| 'retry, 'skip, 'halt, 'fallback_step |]
            | doc "What to do if step validation fails"
            | default = 'halt,

          max_retries
            | Number
            | doc "Maximum number of retry attempts"
            | default = 3,
        }
      | doc "What happens after this step",
  },

  # ============================================================================
  # Artifact Type Definitions
  # ============================================================================

  Artifact = FileArtifact | DirectoryArtifact | ContractArtifact | ScriptArtifact | DocArtifact,

  FileArtifact = {
    path
      | String
      | doc "File path relative to project root",

    content_source
      | [| 'template, 'generated, 'user_input, 'empty |]
      | doc "How file content is created",

    template_path
      | String
      | doc "Path to template file (if content_source is 'template')"
      | optional,

    generator_script
      | String
      | doc "Script path to run to generate content (if content_source is 'generated')"
      | optional,

    validation_contract
      | String
      | doc "Nickel contract path to validate file content"
      | optional,

    is_executable
      | Bool
      | doc "Whether file should have execute permissions"
      | default = false,
  },

  DirectoryArtifact = {
    path
      | String
      | doc "Directory path relative to project root",

    required_subdirs
      | Array String
      | doc "Subdirectories that must exist within this directory"
      | default = [],
  },

  ContractArtifact = {
    path
      | String
      | doc "Contract file path relative to project root",

    contract_type
      | [| 'schema, 'workflow, 'type, 'validator, 'meta |]
      | doc "Category of contract",

    depends_on
      | Array String
      | doc "Other contract paths this contract imports"
      | default = [],

    source
      | [| 'static, 'generated_from_spec, 'generated_from_template |]
      | doc "How contract is created",

    generator_script
      | String
      | doc "Script to generate contract (if source is generated_*)"
      | optional,
  },

  ScriptArtifact = {
    path
      | String
      | doc "Script file path relative to project root",

    language
      | [| 'nushell, 'bash, 'nickel |]
      | doc "Script language",

    purpose
      | String
      | doc "What this script does",

    makes_system_changes
      | Bool
      | doc "Whether script modifies system state (files, processes, etc.)",
  },

  DocArtifact = {
    path
      | String
      | doc "Documentation file path relative to project root",

    doc_type
      | [| 'spec, 'guide, 'reference, 'template |]
      | doc "Type of documentation",

    is_template
      | Bool
      | doc "Whether this is a template to be filled in",

    filled_by
      | [| 'generator, 'user, 'both |]
      | doc "Who/what fills in the content",
  },

  ContentCheck = {
    file
      | String
      | doc "File path to check",

    check_type
      | [| 'regex_match, 'contains_string, 'json_valid, 'yaml_valid, 'has_section |]
      | doc "Type of content check to perform",

    pattern
      | String
      | doc "Pattern/string to check for",

    should_match
      | Bool
      | doc "Whether pattern should match (true) or not match (false)"
      | default = true,
  },
}
