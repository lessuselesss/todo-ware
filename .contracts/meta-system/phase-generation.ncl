# Phase 1: Generation - Complete Step-by-Step Definition
#
# This contract defines all steps in the Generation phase, where kiro-scaffold
# creates the project skeleton with contracts and validation infrastructure.

let workflow = import "workflow.ncl" in

{
  generation_phase = {
    id = "P1",
    name = "generation",
    description = "kiro-scaffold plugin generates project skeleton with contracts",

    entry_conditions = {
      previous_phase_complete = true,
      required_global_state = {},
    },

    steps = [
      # ============== P1.S1: Initialize Base Structure ==============
      {
        id = "P1.S1",
        name = "init_structure",
        description = "Create base directory structure",
        order = 1,

        dependencies = {
          previous_steps = [],
          required_files = [],
          required_contracts = [],
        },

        artifacts = {
          directories = [
            { path = ".", required_subdirs = [] },
            { path = ".kiro", required_subdirs = [] },
            { path = ".kiro-scope", required_subdirs = [] },
            { path = ".contracts", required_subdirs = ["meta-system", "schema", "workflow", "types", "validators"] },
            { path = ".contracts/meta-system", required_subdirs = [] },
            { path = ".contracts/schema", required_subdirs = [] },
            { path = ".contracts/workflow", required_subdirs = [] },
            { path = ".contracts/types", required_subdirs = [] },
            { path = ".contracts/validators", required_subdirs = [] },
            { path = "hooks", required_subdirs = ["scripts", "scripts-nu"] },
            { path = "hooks/scripts", required_subdirs = [] },
            { path = "hooks/scripts-nu", required_subdirs = [] },
            { path = "tools", required_subdirs = ["parsers", "generators", "state", "validators"] },
            { path = "tools/parsers", required_subdirs = [] },
            { path = "tools/generators", required_subdirs = [] },
            { path = "tools/state", required_subdirs = [] },
            { path = "tools/validators", required_subdirs = [] },
            { path = "docs", required_subdirs = [] },
          ],
          files = [
            {
              path = ".gitignore",
              content_source = 'template,
              template_path = "templates/gitignore.template",
              is_executable = false,
            },
            {
              path = "README.md",
              content_source = 'template,
              template_path = "templates/README.template.md",
              is_executable = false,
            },
          ],
          contracts = [],
          scripts = [],
          docs = [],
        },

        validation = {
          files_exist = [".gitignore", "README.md"],
          files_not_empty = [".gitignore"],
          contracts_valid = [],
          scripts_executable = [],
          content_matches = [],
          custom_validators = [],
        },

        state_updates = {
          set_values = {
            current_phase = "generation",
            current_step = "P1.S1",
            step_P1_S1_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S2",
          on_failure = 'halt,
          max_retries = 3,
        },
      },

      # ============== P1.S2: Create CLAUDE.md ==============
      {
        id = "P1.S2",
        name = "create_claude_md",
        description = "Create repository guidance for Claude",
        order = 2,

        dependencies = {
          previous_steps = ["P1.S1"],
          required_files = [".gitignore"],
          required_contracts = [],
        },

        artifacts = {
          directories = [],
          files = [
            {
              path = "CLAUDE.md",
              content_source = 'generated,
              generator_script = "tools/generators/generate-claude-md.nu",
              validation_contract = ".contracts/schema/claude-md.ncl",
              is_executable = false,
            },
          ],
          contracts = [
            {
              path = ".contracts/schema/claude-md.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
          ],
          scripts = [],
          docs = [],
        },

        validation = {
          files_exist = ["CLAUDE.md", ".contracts/schema/claude-md.ncl"],
          files_not_empty = ["CLAUDE.md"],
          contracts_valid = [".contracts/schema/claude-md.ncl"],
          scripts_executable = [],
          content_matches = [
            {
              file = "CLAUDE.md",
              check_type = 'has_section,
              pattern = "# Repository Purpose",
              should_match = true,
            },
          ],
          custom_validators = [],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S2",
            step_P1_S2_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S3",
          on_failure = 'retry,
          max_retries = 3,
        },
      },

      # ============== P1.S3: Create Spec Templates ==============
      {
        id = "P1.S3",
        name = "create_spec_templates",
        description = "Create kiro spec templates in .kiro-scope/",
        order = 3,

        dependencies = {
          previous_steps = ["P1.S2"],
          required_files = ["CLAUDE.md"],
          required_contracts = [],
        },

        artifacts = {
          directories = [],
          files = [],
          contracts = [
            {
              path = ".contracts/schema/requirements.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/schema/design.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/schema/tasks.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/schema/scoped-tasks.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/schema/assertions.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/schema/context.ncl",
              contract_type = 'schema,
              depends_on = [],
              source = 'static,
            },
          ],
          scripts = [],
          docs = [
            {
              path = ".kiro-scope/requirements.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'user,
            },
            {
              path = ".kiro-scope/design.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'user,
            },
            {
              path = ".kiro-scope/tasks.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'user,
            },
            {
              path = ".kiro-scope/scoped-tasks.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'user,
            },
            {
              path = ".kiro-scope/assertions.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'user,
            },
            {
              path = ".kiro-scope/context.md",
              doc_type = 'template,
              is_template = true,
              filled_by = 'both,
            },
          ],
        },

        validation = {
          files_exist = [
            ".kiro-scope/requirements.md",
            ".kiro-scope/design.md",
            ".kiro-scope/tasks.md",
            ".kiro-scope/scoped-tasks.md",
            ".kiro-scope/assertions.md",
            ".kiro-scope/context.md",
          ],
          files_not_empty = [
            ".kiro-scope/requirements.md",
            ".kiro-scope/design.md",
          ],
          contracts_valid = [
            ".contracts/schema/requirements.ncl",
            ".contracts/schema/design.ncl",
            ".contracts/schema/tasks.ncl",
            ".contracts/schema/scoped-tasks.ncl",
            ".contracts/schema/assertions.ncl",
            ".contracts/schema/context.ncl",
          ],
          scripts_executable = [],
          content_matches = [],
          custom_validators = [],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S3",
            step_P1_S3_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S4",
          on_failure = 'retry,
          max_retries = 3,
        },
      },

      # ============== P1.S4: Generate Workflow Contracts ==============
      {
        id = "P1.S4",
        name = "generate_workflow_contracts",
        description = "Create workflow-level Nickel contracts",
        order = 4,

        dependencies = {
          previous_steps = ["P1.S3"],
          required_files = [
            ".contracts/schema/requirements.ncl",
            ".contracts/schema/design.ncl",
            ".contracts/schema/tasks.ncl",
          ],
          required_contracts = [
            ".contracts/schema/requirements.ncl",
            ".contracts/schema/design.ncl",
          ],
        },

        artifacts = {
          directories = [],
          files = [],
          contracts = [
            {
              path = ".contracts/meta-system/workflow.ncl",
              contract_type = 'meta,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/meta-system/phase-generation.ncl",
              contract_type = 'meta,
              depends_on = [".contracts/meta-system/workflow.ncl"],
              source = 'static,
            },
            {
              path = ".contracts/meta-system/phase-pre-implementation.ncl",
              contract_type = 'meta,
              depends_on = [".contracts/meta-system/workflow.ncl"],
              source = 'static,
            },
            {
              path = ".contracts/meta-system/phase-implementation.ncl",
              contract_type = 'meta,
              depends_on = [".contracts/meta-system/workflow.ncl"],
              source = 'static,
            },
            {
              path = ".contracts/workflow/phase-state.ncl",
              contract_type = 'workflow,
              depends_on = [],
              source = 'static,
            },
            {
              path = ".contracts/workflow/generation-complete.ncl",
              contract_type = 'workflow,
              depends_on = [".contracts/workflow/phase-state.ncl"],
              source = 'static,
            },
            {
              path = ".contracts/workflow/spec-complete.ncl",
              contract_type = 'workflow,
              depends_on = [
                ".contracts/workflow/phase-state.ncl",
                ".contracts/schema/requirements.ncl",
                ".contracts/schema/design.ncl",
                ".contracts/schema/assertions.ncl",
              ],
              source = 'static,
            },
            {
              path = ".contracts/workflow/impl-complete.ncl",
              contract_type = 'workflow,
              depends_on = [
                ".contracts/workflow/phase-state.ncl",
                ".contracts/workflow/spec-complete.ncl",
              ],
              source = 'static,
            },
            {
              path = ".contracts/workflow/transition-rules.ncl",
              contract_type = 'workflow,
              depends_on = [
                ".contracts/workflow/generation-complete.ncl",
                ".contracts/workflow/spec-complete.ncl",
                ".contracts/workflow/impl-complete.ncl",
              ],
              source = 'static,
            },
          ],
          scripts = [],
          docs = [],
        },

        validation = {
          files_exist = [],
          files_not_empty = [],
          contracts_valid = [
            ".contracts/meta-system/workflow.ncl",
            ".contracts/meta-system/phase-generation.ncl",
            ".contracts/workflow/phase-state.ncl",
            ".contracts/workflow/generation-complete.ncl",
            ".contracts/workflow/spec-complete.ncl",
            ".contracts/workflow/impl-complete.ncl",
            ".contracts/workflow/transition-rules.ncl",
          ],
          scripts_executable = [],
          content_matches = [],
          custom_validators = ["tools/validators/validate-workflow-contracts.nu"],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S4",
            step_P1_S4_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S5",
          on_failure = 'retry,
          max_retries = 3,
        },
      },

      # ============== P1.S5: Create Validation Scripts ==============
      {
        id = "P1.S5",
        name = "create_validation_scripts",
        description = "Create Nushell/Bash validation and hook scripts",
        order = 5,

        dependencies = {
          previous_steps = ["P1.S4"],
          required_contracts = [
            ".contracts/schema/scope-directory.ncl",
            ".contracts/workflow/phase-state.ncl",
          ],
        },

        artifacts = {
          directories = [],
          files = [],
          contracts = [
            {
              path = ".contracts/schema/scope-directory-runtime.ncl",
              contract_type = 'schema,
              depends_on = [".contracts/schema/scope-directory.ncl"],
              source = 'static,
            },
          ],
          scripts = [
            {
              path = "tools/validate-with-nickel.nu",
              language = 'nushell,
              purpose = "Runtime Nickel validation helpers",
              makes_system_changes = false,
            },
            {
              path = "tools/phase-manager.nu",
              language = 'nushell,
              purpose = "Phase state management commands",
              makes_system_changes = true,
            },
            {
              path = "tools/workflow-engine.nu",
              language = 'nushell,
              purpose = "Workflow execution engine",
              makes_system_changes = true,
            },
            {
              path = "hooks/scripts-nu/validate-scope-nickel.nu",
              language = 'nushell,
              purpose = "Hook: Validate scope structure with Nickel",
              makes_system_changes = false,
            },
            {
              path = "hooks/scripts/validate-scope-nickel.sh",
              language = 'bash,
              purpose = "Hook: Validate scope structure with Nickel (Bash)",
              makes_system_changes = false,
            },
          ],
          docs = [
            {
              path = "docs/NICKEL-RUNTIME.md",
              doc_type = 'guide,
              is_template = false,
              filled_by = 'generator,
            },
            {
              path = "docs/WORKFLOW-CONTRACTS.md",
              doc_type = 'guide,
              is_template = false,
              filled_by = 'generator,
            },
          ],
        },

        validation = {
          files_exist = [
            "tools/validate-with-nickel.nu",
            "tools/phase-manager.nu",
            "tools/workflow-engine.nu",
            "hooks/scripts-nu/validate-scope-nickel.nu",
          ],
          files_not_empty = [
            "tools/validate-with-nickel.nu",
            "tools/phase-manager.nu",
            "tools/workflow-engine.nu",
          ],
          contracts_valid = [
            ".contracts/schema/scope-directory-runtime.ncl",
          ],
          scripts_executable = [
            "hooks/scripts-nu/validate-scope-nickel.nu",
            "hooks/scripts/validate-scope-nickel.sh",
          ],
          content_matches = [],
          custom_validators = [],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S5",
            step_P1_S5_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S6",
          on_failure = 'retry,
          max_retries = 3,
        },
      },

      # ============== P1.S6: Initialize Phase State ==============
      {
        id = "P1.S6",
        name = "init_phase_state",
        description = "Create initial .kiro/state.json",
        order = 6,

        dependencies = {
          previous_steps = ["P1.S5"],
          required_contracts = [".contracts/workflow/phase-state.ncl"],
          required_files = ["tools/phase-manager.nu"],
        },

        artifacts = {
          directories = [],
          files = [
            {
              path = ".kiro/state.json",
              content_source = 'generated,
              generator_script = "tools/phase-manager.nu init-state",
              validation_contract = ".contracts/workflow/phase-state.ncl",
              is_executable = false,
            },
          ],
          contracts = [],
          scripts = [],
          docs = [],
        },

        validation = {
          files_exist = [".kiro/state.json"],
          files_not_empty = [".kiro/state.json"],
          contracts_valid = [],
          scripts_executable = [],
          content_matches = [
            {
              file = ".kiro/state.json",
              check_type = 'json_valid,
              pattern = "",
              should_match = true,
            },
          ],
          custom_validators = ["tools/phase-manager.nu validate-state"],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S6",
            step_P1_S6_complete = true,
          },
        },

        next_step = {
          on_success = "P1.S7",
          on_failure = 'retry,
          max_retries = 3,
        },
      },

      # ============== P1.S7: Validate Complete Generation ==============
      {
        id = "P1.S7",
        name = "validate_generation_complete",
        description = "Validate all generation artifacts and contracts",
        order = 7,

        dependencies = {
          previous_steps = ["P1.S1", "P1.S2", "P1.S3", "P1.S4", "P1.S5", "P1.S6"],
          required_files = [
            "CLAUDE.md",
            ".kiro-scope/requirements.md",
            ".kiro-scope/design.md",
            ".kiro/state.json",
          ],
          required_contracts = [
            ".contracts/schema/scope-directory-runtime.ncl",
            ".contracts/workflow/generation-complete.ncl",
          ],
        },

        artifacts = {
          directories = [],
          files = [],
          contracts = [],
          scripts = [],
          docs = [],
        },

        validation = {
          files_exist = [],
          files_not_empty = [],
          contracts_valid = [],
          scripts_executable = [],
          content_matches = [],
          custom_validators = [
            "tools/validators/validate-generation-complete.nu",
            "nickel eval .contracts/workflow/generation-complete.ncl",
          ],
        },

        state_updates = {
          set_values = {
            current_step = "P1.S7",
            current_phase = "generation",
            generation_complete = true,
            can_advance_to_pre_implementation = true,
          },
          append_to_history = {
            phase = "generation",
            completed_at = "ISO8601_TIMESTAMP",
          },
        },

        next_step = {
          on_success = null,
          on_failure = 'halt,
          max_retries = 3,
        },
      },
    ],

    exit_conditions = {
      all_steps_complete = true,
      validation_passes = [
        ".contracts/workflow/generation-complete.ncl",
        "tools/validators/validate-generation-complete.nu",
      ],
      blocking_issues_resolved = true,
    },
  },
}
