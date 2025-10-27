---
project: kiro-scaffold
phase: Generation (Phase 1)
status: specification
last_updated: 2025-10-27
---

# Phase 1 Implementation Gaps and Specification

## Executive Summary

The kiro-scaffold plugin has a **complete Phase 1 specification** in `.contracts/meta-system/phase-generation.ncl` that defines all 7 steps (P1.S1 through P1.S7). However, **16 referenced contracts and tools do not exist**, making Phase 1 non-executable.

This document provides the complete implementation plan to make Phase 1 functional.

## Current State Analysis

### What Exists ✅

**Meta-System Contracts (2 files):**
- `.contracts/meta-system/workflow.ncl` - Core type definitions
- `.contracts/meta-system/phase-generation.ncl` - **Complete Phase 1 specification**

**Schema Contracts (6 files):**
- `.contracts/schema/assertions.ncl` ✅
- `.contracts/schema/claude-md.ncl` ✅
- `.contracts/schema/context.ncl` ✅
- `.contracts/schema/scope-directory.ncl` ✅
- `.contracts/schema/scope-directory-runtime.ncl` ✅
- `.contracts/schema/scoped-tasks.ncl` ✅

**Validation Contracts (3 files):**
- `.contracts/validation/assertion-ids.ncl` ✅
- `.contracts/validation/markdown.ncl` ✅
- `.contracts/validation/traceability.ncl` ✅

**Plugin Contracts (2 files):**
- `.contracts/plugin/command.ncl` ✅
- `.contracts/plugin/agent.ncl` ✅

**Nushell Tools:**
- `tools/kiro.nu` - 20+ validation functions ✅

### Blocking Gaps ❌

Phase 1 **cannot execute** because these referenced components don't exist:

## Priority 1: Schema Contracts (Blocking P1.S3)

P1.S3 references these schema contracts (lines 180-215 in phase-generation.ncl):

### 1. `.contracts/schema/requirements.ncl`

**Referenced in:**
- P1.S3 artifacts (line 181)
- P1.S4 dependencies (line 308-309)
- P1.S4 validation (line 363)

**Purpose:** Validate structure of `.kiro-scope/requirements.md` and `.kiro/spec/requirements.md`

**Required fields:**
```nickel
{
  RequirementsFrontmatter = {
    project | String,
    version | String,
    last_updated | String | optional,
  },

  Requirement = {
    id | String,  # REQ-001, REQ-002 format
    title | String,
    description | String,
    priority | [| 'critical, 'high, 'medium, 'low |],
    status | [| 'proposed, 'accepted, 'implemented, 'rejected |],
    acceptance_criteria | Array String | optional,
    derived_from | String | optional,  # Parent requirement reference
  },

  RequirementsDocument = {
    frontmatter | RequirementsFrontmatter,
    requirements | Array Requirement,
  },

  # Validation function
  validate_requirements = fun doc =>
    # Check all requirement IDs match REQ-\d{3} pattern
    # Check no duplicate IDs
    # Check all derived_from references exist
    doc.requirements |> Array.all (fun r =>
      String.is_match "REQ-\\d{3}" r.id
    ),
}
```

**Template it validates:** `.kiro-scope/requirements.md`

**Example structure:**
```markdown
---
project: my-project
version: 0.1.0
last_updated: 2025-10-27
---

# Requirements

## REQ-001: User Authentication
**Priority:** critical
**Status:** proposed
**Description:** Users must be able to authenticate via OAuth2

**Acceptance Criteria:**
- [ ] Support GitHub OAuth
- [ ] Support Google OAuth
- [ ] Secure token storage

## REQ-002: Data Persistence
**Priority:** high
**Status:** proposed
**Derived From:** REQ-001
```

### 2. `.contracts/schema/design.ncl`

**Referenced in:**
- P1.S3 artifacts (line 187)
- P1.S4 dependencies (line 309)
- P1.S4 validation (line 364)

**Purpose:** Validate structure of `.kiro-scope/design.md` and `.kiro/spec/design.md`

**Required fields:**
```nickel
{
  DesignFrontmatter = {
    project | String,
    version | String,
    last_updated | String | optional,
  },

  DesignElement = {
    id | String,  # DES-001, DES-002 format
    title | String,
    description | String,
    requirement_refs | Array String,  # [REQ-001, REQ-002]
    architecture_component | String | optional,
    interfaces | Array String | optional,
  },

  TypeDefinition = {
    name | String,
    kind | [| 'record, 'enum, 'alias, 'newtype |],
    fields | {_: String} | optional,  # Field name -> type description
    variants | Array String | optional,  # For enums
    description | String | optional,
  },

  DesignDocument = {
    frontmatter | DesignFrontmatter,
    design_elements | Array DesignElement,
    types | Array TypeDefinition | optional,
    architecture_notes | String | optional,
  },

  validate_design = fun doc =>
    # Check all design IDs match DES-\d{3}
    # Check all requirement_refs exist in requirements.md
    # Check no orphaned design elements
    doc.design_elements |> Array.all (fun d =>
      String.is_match "DES-\\d{3}" d.id
    ),
}
```

**Template it validates:** `.kiro-scope/design.md`

**Example structure:**
```markdown
---
project: my-project
version: 0.1.0
---

# Design

## DES-001: OAuth Flow Architecture
**Requirement Refs:** REQ-001
**Component:** Authentication Service

### Description
Implement standard OAuth 2.0 authorization code flow.

### Interfaces
- `POST /auth/oauth/callback`
- `GET /auth/oauth/authorize`

## Type Definitions

### User
**Kind:** record
**Fields:**
- `id: UUID` - Unique user identifier
- `provider: String` - OAuth provider (github, google)
- `access_token: String` - Encrypted OAuth token
```

### 3. `.contracts/schema/tasks.ncl`

**Referenced in:**
- P1.S3 artifacts (line 193)
- P1.S4 dependencies (line 310)

**Purpose:** Validate structure of `.kiro-scope/tasks.md` and `.kiro/spec/tasks.md`

**Required fields:**
```nickel
{
  TasksFrontmatter = {
    project | String,
    version | String,
  },

  Task = {
    id | String,  # AUTH-001, DB-002 format (module prefix + number)
    title | String,
    description | String,
    requirement_refs | Array String,  # [REQ-001]
    design_refs | Array String,  # [DES-001, DES-002]
    estimated_effort | String | optional,  # "2h", "1d", "1w"
    dependencies | Array String | default = [],  # Other task IDs
    assignee | String | optional,
    status | [| 'todo, 'in_progress, 'blocked, 'done |] | default = 'todo,
  },

  TasksDocument = {
    frontmatter | TasksFrontmatter,
    tasks | Array Task,
  },

  validate_tasks = fun doc =>
    # Check all task IDs match [A-Z]+-\d{3}
    # Check all requirement_refs exist
    # Check all design_refs exist
    # Check no circular dependencies
    # Check dependencies reference existing tasks
    doc.tasks |> Array.all (fun t =>
      String.is_match "[A-Z]+-\\d{3}" t.id
    ),
}
```

**Template it validates:** `.kiro-scope/tasks.md`

**Example structure:**
```markdown
---
project: my-project
version: 0.1.0
---

# Tasks

## AUTH-001: Implement OAuth callback handler
**Requirement Refs:** REQ-001
**Design Refs:** DES-001
**Estimated Effort:** 4h
**Status:** todo

### Description
Create POST endpoint that handles OAuth provider callbacks, exchanges authorization code for access token, and creates user session.

**Dependencies:**
- DB-001 (User model)

**Acceptance:**
- Can exchange code for token
- Creates database user record
- Returns session cookie
```

## Priority 2: Workflow Contracts (Blocking P1.S4, P1.S6, P1.S7)

P1.S4 references these workflow contracts (lines 347-387):

### 4. `.contracts/workflow/phase-state.ncl`

**Referenced in:**
- P1.S4 artifacts (line 347)
- P1.S5 dependencies (line 435)
- P1.S6 dependencies (line 544)
- P1.S6 validation contract (line 555)

**Purpose:** Validate `.kiro/state.json` structure for phase/step tracking

**Required fields:**
```nickel
{
  PhaseState = {
    current_phase | [| 'generation, 'pre_implementation, 'implementation, 'complete |],
    current_step | String,  # P1.S1, P2.S3, P3.S5, etc.
    started_at | String,  # ISO8601 timestamp
    last_updated | String,  # ISO8601 timestamp

    # Step completion tracking
    step_P1_S1_complete | Bool | default = false,
    step_P1_S2_complete | Bool | default = false,
    step_P1_S3_complete | Bool | default = false,
    step_P1_S4_complete | Bool | default = false,
    step_P1_S5_complete | Bool | default = false,
    step_P1_S6_complete | Bool | default = false,
    step_P1_S7_complete | Bool | default = false,

    # Phase completion flags
    generation_complete | Bool | default = false,
    pre_implementation_complete | Bool | default = false,
    implementation_complete | Bool | default = false,

    # Transition guards
    can_advance_to_pre_implementation | Bool | default = false,
    can_advance_to_implementation | Bool | default = false,

    # Phase completion history
    phase_history | Array {
      phase | String,
      completed_at | String,
    } | default = [],

    # Blocking issues
    blocking_issues | Array String | default = [],
  },

  # Initial state
  initial_state = {
    current_phase = 'generation,
    current_step = "P1.S1",
    started_at = "ISO8601_TIMESTAMP",
    last_updated = "ISO8601_TIMESTAMP",
    step_P1_S1_complete = false,
    generation_complete = false,
    can_advance_to_pre_implementation = false,
    phase_history = [],
    blocking_issues = [],
  },

  validate_state = fun state =>
    # Current step must match current phase
    # If generation_complete is true, all P1 steps must be complete
    # can_advance flags must align with completion states
    if state.generation_complete then
      state.step_P1_S1_complete &&
      state.step_P1_S2_complete &&
      state.step_P1_S3_complete &&
      state.step_P1_S4_complete &&
      state.step_P1_S5_complete &&
      state.step_P1_S6_complete &&
      state.step_P1_S7_complete
    else true,
}
```

**File it validates:** `.kiro/state.json`

**Example JSON:**
```json
{
  "current_phase": "generation",
  "current_step": "P1.S3",
  "started_at": "2025-10-27T12:00:00Z",
  "last_updated": "2025-10-27T12:15:00Z",
  "step_P1_S1_complete": true,
  "step_P1_S2_complete": true,
  "step_P1_S3_complete": false,
  "generation_complete": false,
  "can_advance_to_pre_implementation": false,
  "phase_history": [],
  "blocking_issues": []
}
```

### 5. `.contracts/workflow/generation-complete.ncl`

**Referenced in:**
- P1.S4 artifacts (line 353)
- P1.S7 dependencies (line 611)
- P1.S7 custom validator (line 631)

**Purpose:** Validate all Phase 1 exit conditions are met

**Required logic:**
```nickel
{
  import phase_state = ".contracts/workflow/phase-state.ncl" in

  GenerationCompleteChecks = {
    # Directory structure
    all_directories_exist | Bool,
    required_dirs = [
      ".kiro",
      ".kiro-scope",
      ".contracts",
      ".contracts/meta-system",
      ".contracts/schema",
      ".contracts/workflow",
      "hooks",
      "tools",
    ],

    # Spec templates
    all_spec_templates_exist | Bool,
    required_specs = [
      ".kiro-scope/requirements.md",
      ".kiro-scope/design.md",
      ".kiro-scope/tasks.md",
      ".kiro-scope/scoped-tasks.md",
      ".kiro-scope/assertions.md",
      ".kiro-scope/context.md",
    ],

    # Schema contracts
    all_schema_contracts_valid | Bool,
    required_schemas = [
      ".contracts/schema/requirements.ncl",
      ".contracts/schema/design.ncl",
      ".contracts/schema/tasks.ncl",
      ".contracts/schema/scoped-tasks.ncl",
      ".contracts/schema/assertions.ncl",
      ".contracts/schema/context.ncl",
      ".contracts/schema/scope-directory-runtime.ncl",
    ],

    # Workflow contracts
    all_workflow_contracts_exist | Bool,
    required_workflows = [
      ".contracts/workflow/phase-state.ncl",
      ".contracts/workflow/generation-complete.ncl",
    ],

    # Validation scripts
    validation_scripts_exist | Bool,
    required_scripts = [
      "tools/validate-with-nickel.nu",
      "tools/phase-manager.nu",
      "tools/workflow-engine.nu",
    ],

    # State file
    state_file_valid | Bool,
    state_path = ".kiro/state.json",
  },

  # Main validation function
  validate_generation_complete = fun checks =>
    checks.all_directories_exist &&
    checks.all_spec_templates_exist &&
    checks.all_schema_contracts_valid &&
    checks.all_workflow_contracts_exist &&
    checks.validation_scripts_exist &&
    checks.state_file_valid,

  # Exit condition
  can_advance_to_phase_2 = fun state checks =>
    state.generation_complete &&
    validate_generation_complete checks,
}
```

### 6. `.contracts/workflow/spec-complete.ncl`

**Referenced in:**
- P1.S4 artifacts (line 359)

**Purpose:** Validate all Phase 2 (Pre-Implementation) exit conditions

**Required logic:**
```nickel
{
  SpecCompleteChecks = {
    # Requirements
    requirements_complete | Bool,
    all_requirements_accepted_or_rejected | Bool,
    requirements_have_designs | Bool,

    # Design
    design_complete | Bool,
    all_designs_have_tasks | Bool,
    type_definitions_complete | Bool,

    # Tasks
    tasks_complete | Bool,
    all_tasks_have_assertions | Bool,
    task_dependencies_valid | Bool,

    # Traceability
    full_traceability_chain | Bool,  # REQ -> DES -> TASK -> ASSERTION
    no_orphaned_elements | Bool,
  },

  validate_spec_complete = fun checks =>
    checks.requirements_complete &&
    checks.design_complete &&
    checks.tasks_complete &&
    checks.full_traceability_chain &&
    checks.no_orphaned_elements,
}
```

### 7. `.contracts/workflow/impl-complete.ncl`

**Referenced in:**
- P1.S4 artifacts (line 370)

**Purpose:** Validate all Phase 3 (Implementation) exit conditions

**Required logic:**
```nickel
{
  ImplCompleteChecks = {
    # All assertions pass
    all_assertions_green | Bool,
    no_red_phase_assertions | Bool,

    # Code coverage
    all_tasks_implemented | Bool,
    all_tests_passing | Bool,

    # Contract validation
    all_runtime_contracts_pass | Bool,

    # Documentation
    all_context_md_complete | Bool,
    all_scoped_tasks_implemented | Bool,
  },

  validate_impl_complete = fun checks =>
    checks.all_assertions_green &&
    checks.all_tasks_implemented &&
    checks.all_tests_passing &&
    checks.all_runtime_contracts_pass &&
    checks.all_context_md_complete,
}
```

### 8. `.contracts/workflow/transition-rules.ncl`

**Referenced in:**
- P1.S4 artifacts (line 379)

**Purpose:** Define valid phase transitions and guard conditions

**Required logic:**
```nickel
{
  TransitionRules = {
    from_generation_to_pre_impl = {
      guard = fun state =>
        state.generation_complete &&
        state.can_advance_to_pre_implementation,
      actions = [
        "Set current_phase = 'pre_implementation",
        "Set current_step = 'P2.S1",
        "Append to phase_history",
      ],
    },

    from_pre_impl_to_impl = {
      guard = fun state =>
        state.pre_implementation_complete &&
        state.can_advance_to_implementation,
      actions = [
        "Set current_phase = 'implementation",
        "Set current_step = 'P3.S1",
        "Append to phase_history",
      ],
    },

    from_impl_to_complete = {
      guard = fun state =>
        state.implementation_complete,
      actions = [
        "Set current_phase = 'complete",
        "Append to phase_history",
      ],
    },
  },

  can_transition = fun state from_phase to_phase =>
    match (from_phase, to_phase) {
      ('generation, 'pre_implementation) =>
        TransitionRules.from_generation_to_pre_impl.guard state,
      ('pre_implementation, 'implementation) =>
        TransitionRules.from_pre_impl_to_impl.guard state,
      ('implementation, 'complete) =>
        TransitionRules.from_impl_to_complete.guard state,
      _ => false
    },
}
```

## Priority 3: Nushell Tools (Blocking P1.S5, P1.S6)

P1.S5 and P1.S6 reference these Nushell scripts:

### 9. `tools/validate-with-nickel.nu`

**Referenced in:**
- P1.S5 artifacts (line 452)
- P1.S5 validation (line 500, 506)

**Purpose:** Wrapper functions for runtime Nickel validation

**Required exports:**
```nushell
# Validate JSON file against Nickel contract
export def validate-json [
  json_path: string,
  contract_path: string
] {
  let json_content = open $json_path
  let validation_result = (
    $json_content
    | to json
    | nickel eval --validate $contract_path
  )

  if ($validation_result | is-empty) {
    {success: true, file: $json_path, contract: $contract_path}
  } else {
    {success: false, file: $json_path, contract: $contract_path, error: $validation_result}
  }
}

# Validate Markdown frontmatter against contract
export def validate-markdown-frontmatter [
  md_path: string,
  contract_path: string
] {
  # Extract YAML frontmatter
  let frontmatter = (
    open $md_path
    | lines
    | skip 1
    | take until {|line| $line == "---"}
    | str join "\n"
  )

  # Convert to JSON and validate
  let json_frontmatter = ($frontmatter | from yaml | to json)
  echo $json_frontmatter | nickel eval --validate $contract_path
}

# Type-check Nickel contract
export def typecheck-contract [
  contract_path: string
] {
  nickel typecheck $contract_path
}
```

### 10. `tools/phase-manager.nu`

**Referenced in:**
- P1.S5 artifacts (line 459)
- P1.S6 generator script (line 554)
- P1.S6 custom validator (line 577)

**Purpose:** Manage phase state in `.kiro/state.json`

**Required exports:**
```nushell
# Initialize state.json
export def init-state [] {
  let initial_state = {
    current_phase: "generation",
    current_step: "P1.S1",
    started_at: (date now | format date "%Y-%m-%dT%H:%M:%SZ"),
    last_updated: (date now | format date "%Y-%m-%dT%H:%M:%SZ"),
    step_P1_S1_complete: false,
    step_P1_S2_complete: false,
    step_P1_S3_complete: false,
    step_P1_S4_complete: false,
    step_P1_S5_complete: false,
    step_P1_S6_complete: false,
    step_P1_S7_complete: false,
    generation_complete: false,
    can_advance_to_pre_implementation: false,
    phase_history: [],
    blocking_issues: []
  }

  mkdir .kiro
  $initial_state | save -f .kiro/state.json
}

# Mark step as complete
export def complete-step [step_id: string] {
  let state = (open .kiro/state.json)
  let updated_state = (
    $state
    | upsert $"step_($step_id)_complete" true
    | upsert last_updated (date now | format date "%Y-%m-%dT%H:%M:%SZ")
  )
  $updated_state | save -f .kiro/state.json
}

# Validate state against contract
export def validate-state [] {
  use validate-with-nickel.nu validate-json
  validate-json .kiro/state.json .contracts/workflow/phase-state.ncl
}

# Get current phase/step
export def get-current-phase [] {
  open .kiro/state.json | get current_phase
}

export def get-current-step [] {
  open .kiro/state.json | get current_step
}
```

### 11. `tools/workflow-engine.nu`

**Referenced in:**
- P1.S5 artifacts (line 465)

**Purpose:** Execute workflow steps defined in phase contracts

**Required exports:**
```nushell
# Execute a single workflow step
export def execute-step [
  phase: string,
  step_id: string
] {
  # Load step definition from phase contract
  let step_def = (load-step-definition $phase $step_id)

  # Check dependencies
  if not (check-dependencies $step_def) {
    error make {msg: "Step dependencies not met"}
  }

  # Create artifacts
  create-directories $step_def.artifacts.directories
  create-files $step_def.artifacts.files
  create-contracts $step_def.artifacts.contracts

  # Run validation
  let validation_result = (validate-step $step_def)

  if $validation_result.success {
    # Update state
    use phase-manager.nu complete-step
    complete-step $step_id

    {success: true, step: $step_id, next: $step_def.next_step.on_success}
  } else {
    {success: false, step: $step_id, errors: $validation_result.errors}
  }
}

# Execute entire phase
export def execute-phase [phase: string] {
  let steps = (load-phase-steps $phase)

  for step in $steps {
    let result = (execute-step $phase $step.id)

    if not $result.success {
      error make {msg: $"Step ($step.id) failed: ($result.errors)"}
    }
  }
}
```

### 12. `hooks/scripts-nu/validate-scope-nickel.nu`

**Referenced in:**
- P1.S5 artifacts (line 470)

**Purpose:** Pre-commit hook to validate scope structure

### 13. `tools/validators/validate-generation-complete.nu`

**Referenced in:**
- P1.S7 custom validators (line 630)

**Purpose:** Execute all P1.S7 validation checks

## Priority 4: Missing Meta-System Contracts

### 14. `.contracts/meta-system/phase-pre-implementation.ncl`

**Referenced in:**
- P1.S4 artifacts (line 335)

**Purpose:** Define all steps for Phase 2 (P2.S1 through P2.S8)

**Structure:** Similar to phase-generation.ncl but for Pre-Implementation phase

### 15. `.contracts/meta-system/phase-implementation.ncl`

**Referenced in:**
- P1.S4 artifacts (line 341)

**Purpose:** Define all steps for Phase 3 (P3.S1 through P3.Sn)

## Priority 5: Plugin Component Contracts (Non-Blocking)

These aren't blocking Phase 1 but are needed for complete plugin validation:

### 16. `.contracts/plugin/skill.ncl`

**Purpose:** Validate SKILL.md structure in skills directories

### 17. `.contracts/plugin/hook.ncl`

**Purpose:** Validate hooks.json structure

### 18. `.contracts/plugin/mcp-server.ncl`

**Purpose:** Validate .mcp.json structure

## Priority 6: Project Initialization Contracts

These are needed for `/kiro-new` command but not blocking Phase 1:

### 19. `.contracts/plugin/project-definition.ncl`

**Purpose:** Define project metadata (name, description, language, etc.)

### 20. `.contracts/plugin/prompts.ncl`

**Purpose:** Define interactive Q&A prompts for project initialization

## Implementation Roadmap

### Stage 1: Make Phase 1 Executable (Highest Priority)

**Goal:** Enable P1.S1 through P1.S7 to run successfully

**Tasks:**
1. Create `.contracts/schema/requirements.ncl` (REQ-001 → REQ-nnn format)
2. Create `.contracts/schema/design.ncl` (DES-001 → DES-nnn format)
3. Create `.contracts/schema/tasks.ncl` (MODULE-001 → MODULE-nnn format)
4. Create `.contracts/workflow/phase-state.ncl` (state.json validation)
5. Create `.contracts/workflow/generation-complete.ncl` (P1 exit validator)
6. Create `tools/validate-with-nickel.nu` (runtime validation helpers)
7. Create `tools/phase-manager.nu` (state management)
8. Create `tools/workflow-engine.nu` (step execution)
9. Create `tools/validators/validate-generation-complete.nu` (P1.S7 validator)

**Acceptance Criteria:**
- Can execute `/kiro-new my-project` successfully
- All 7 Phase 1 steps complete without errors
- `.kiro/state.json` shows `generation_complete: true`
- All generated files validate against their contracts

### Stage 2: Phase 2 & 3 Specifications

**Goal:** Complete meta-system contracts for all phases

**Tasks:**
1. Create `.contracts/meta-system/phase-pre-implementation.ncl` (8 steps)
2. Create `.contracts/meta-system/phase-implementation.ncl` (TDD cycle)
3. Create `.contracts/workflow/spec-complete.ncl` (P2 exit validator)
4. Create `.contracts/workflow/impl-complete.ncl` (P3 exit validator)
5. Create `.contracts/workflow/transition-rules.ncl` (phase transitions)

### Stage 3: Plugin Component Validation

**Goal:** Validate all plugin components

**Tasks:**
1. Create `.contracts/plugin/skill.ncl`
2. Create `.contracts/plugin/hook.ncl`
3. Create `.contracts/plugin/mcp-server.ncl`
4. Add validation to `/plugin validate` command

### Stage 4: Project Initialization

**Goal:** Enable interactive and headless project creation

**Tasks:**
1. Create `.contracts/plugin/project-definition.ncl`
2. Create `.contracts/plugin/prompts.ncl`
3. Implement Q&A agent for interactive mode
4. Implement inference strategy for headless mode

## Next Steps

**Immediate Actions:**
1. Start with Stage 1, Task 1: Create `.contracts/schema/requirements.ncl`
2. Follow with tasks 2-3 (design.ncl, tasks.ncl) to unblock P1.S3
3. Create workflow contracts (tasks 4-5) to unblock P1.S4, P1.S6, P1.S7
4. Implement Nushell tools (tasks 6-9) to enable execution

**Success Metric:** Phase 1 can execute end-to-end without errors

## Appendix: Full Dependency Graph

```
Phase 1 Execution Flow:

P1.S1: Initialize Base Structure
  └─> Creates directories

P1.S2: Create CLAUDE.md
  └─> Requires: P1.S1 complete
  └─> Validates against: .contracts/schema/claude-md.ncl ✅

P1.S3: Create Spec Templates
  └─> Requires: P1.S2 complete
  └─> BLOCKS ON:
      - .contracts/schema/requirements.ncl ❌
      - .contracts/schema/design.ncl ❌
      - .contracts/schema/tasks.ncl ❌

P1.S4: Generate Workflow Contracts
  └─> Requires: P1.S3 complete
  └─> BLOCKS ON:
      - .contracts/workflow/phase-state.ncl ❌
      - .contracts/workflow/generation-complete.ncl ❌
      - .contracts/workflow/spec-complete.ncl ❌
      - .contracts/workflow/impl-complete.ncl ❌
      - .contracts/workflow/transition-rules.ncl ❌

P1.S5: Create Validation Scripts
  └─> Requires: P1.S4 complete
  └─> BLOCKS ON:
      - tools/validate-with-nickel.nu ❌
      - tools/phase-manager.nu ❌
      - tools/workflow-engine.nu ❌

P1.S6: Initialize Phase State
  └─> Requires: P1.S5 complete, tools/phase-manager.nu
  └─> BLOCKS ON:
      - .contracts/workflow/phase-state.ncl ❌
      - tools/phase-manager.nu ❌

P1.S7: Validate Complete Generation
  └─> Requires: ALL previous steps
  └─> BLOCKS ON:
      - .contracts/workflow/generation-complete.ncl ❌
      - tools/validators/validate-generation-complete.nu ❌
```

## Summary

**Total Missing Components:** 20
- **Schema Contracts:** 3 (requirements, design, tasks)
- **Workflow Contracts:** 5 (phase-state, generation-complete, spec-complete, impl-complete, transition-rules)
- **Meta-System Contracts:** 4 (phase-pre-implementation, phase-implementation, artifact-specs, dependency-graph)
- **Nushell Tools:** 4 (validate-with-nickel, phase-manager, workflow-engine, validators)
- **Plugin Contracts:** 3 (skill, hook, mcp-server)
- **Project Contracts:** 2 (project-definition, prompts)

**Critical Path to Phase 1 Execution:**
1. Schema contracts (3) → Unblocks P1.S3
2. Workflow contracts (2) → Unblocks P1.S4, P1.S6, P1.S7
3. Nushell tools (4) → Enables execution

**Priority Order:**
- Stage 1 (9 tasks) → **BLOCKING** Phase 1 execution
- Stage 2 (5 tasks) → Required for Phases 2 & 3
- Stage 3 (3 tasks) → Plugin validation completeness
- Stage 4 (2 tasks) → Project initialization enhancement
