# Missing Implementation: Meta-System Workflow Contracts

## Context

This document captures the architectural vision that was developed but not yet implemented in the todo-ware project. The conversation continued from a previous session and evolved into a comprehensive meta-system design using Nickel contracts to formally define the kiro methodology itself.

## Current State of Repository

The repository currently contains:

### ✅ Existing Implementation
- **Nickel Contracts** (`.contracts/schema/`, `.contracts/validation/`)
  - `scope-directory.ncl` - Scope structure schema
  - `scope-directory-runtime.ncl` - Runtime validation for scopes
  - `assertions.ncl` - TDD assertions schema
  - `scoped-tasks.ncl` - Scoped tasks schema
  - `claude-md.ncl` - CLAUDE.md schema
  - `context.ncl` - Context documentation schema
  - Validation contracts for assertion IDs, markdown, traceability

- **Nushell Tools** (`tools/`, `hooks/scripts-nu/`)
  - `kiro.nu` - Main kiro command interface
  - `validate-with-nickel.nu` - Nickel runtime validation helpers
  - Various hook scripts for validation

- **Documentation** (`docs/`)
  - `NICKEL-RUNTIME.md` - Runtime validation guide
  - `CONTRACTS.md` - Contract documentation
  - `HOOKS.md` - Hook system documentation
  - `NUSHELL.md` - Nushell usage guide

- **Infrastructure**
  - `flake.nix` - Nix development environment
  - Claude Code plugin configuration
  - MCP server integration

### ❌ Missing: Meta-System Workflow Contracts

The key missing piece is the **formal specification of the kiro workflow itself** as executable Nickel contracts.

---

## The Vision: Meta-System Workflow Architecture

### Core Concept

Instead of having implicit workflow logic scattered across scripts, define **the workflow itself as Nickel contracts** that:

1. **Define every phase** (Generation, Pre-Implementation, Implementation)
2. **Define every step** within each phase (P1.S1, P1.S2, ..., P3.Sn)
3. **Specify what artifacts** are created at each step
4. **Declare dependencies** between steps (explicit DAG)
5. **Define validation** that must pass before advancing
6. **Are validated at runtime** - the system validates itself

This creates a **self-defining, self-executing, self-validating workflow system**.

---

## The Three Phases

### Phase 1: Generation (kiro-scaffold plugin)
**Purpose**: Create project skeleton with contracts and validation infrastructure

**Steps** (P1.S1 → P1.S7):
- P1.S1: Initialize base directory structure
- P1.S2: Create CLAUDE.md
- P1.S3: Create spec templates (requirements.md, design.md, tasks.md, etc.)
- P1.S4: Generate workflow contracts
- P1.S5: Create validation scripts (Nushell/Bash)
- P1.S6: Initialize phase state (`.kiro/state.json`)
- P1.S7: Validate complete generation

**Exit Conditions**:
- All directory structure exists
- All spec templates created
- All schema contracts valid
- Workflow contracts in place
- Validation scripts executable

### Phase 2: Pre-Implementation (Skeleton → Complete Spec)
**Purpose**: Fill specs and auto-generate type/validator contracts

**Steps** (P2.S1 → P2.S8):
- P2.S1: Fill `requirements.md`
- P2.S2: Fill `design.md` (types, architecture)
- P2.S3: Parse `design.md`, generate `.contracts/types/*.ncl`
- P2.S4: Define `tasks.md`
- P2.S5: Define `scoped-tasks.md`
- P2.S6: Write `assertions.md`
- P2.S7: Parse `assertions.md`, generate `.contracts/validators/*.ncl`
- P2.S8: Validate complete specification

**Exit Conditions**:
- No TODO markers in specs
- All types extracted and contracts generated
- All tasks have assertions
- All assertions have validators
- Spec consistency validated
- All generated contracts syntactically valid

### Phase 3: Implementation (Spec → Working Code)
**Purpose**: TDD cycle - write tests, implement code, validate against contracts

**Steps** (P3.S1 → P3.Sn - repeating cycle):
- P3.S1: Write test for assertion
- P3.S2: Run test (RED)
- P3.S3: Write minimal implementation
- P3.S4: Run test (GREEN)
- P3.S5: Refactor
- P3.S6: Validate against contracts
- P3.S7: Mark task complete
- P3.S8: Repeat for next assertion

**Exit Conditions**:
- All tests passing
- All assertions validated
- All contracts satisfied
- All tasks marked complete
- Test coverage complete
- Runtime validators pass

---

## Missing Contract Files

### 1. Master Workflow Contracts (`.contracts/meta-system/`)

#### `workflow.ncl` - Core Type Definitions
```nickel
{
  Workflow = {
    version | String,
    phases | Array Phase,
    global_artifacts | Array Artifact,
  },

  Phase = {
    id | String,  # P1, P2, P3
    name | String,  # generation, pre_implementation, implementation
    description | String,
    steps | Array Step,
    entry_conditions | {...},
    exit_conditions | {...},
  },

  Step = {
    id | String,  # P1.S1, P1.S2, etc.
    name | String,
    description | String,
    order | Number,
    dependencies | {
      previous_steps | Array String,
      required_files | Array String,
      required_contracts | Array String,
      required_state | Record | optional,
    },
    artifacts | {
      files | Array FileArtifact,
      directories | Array DirectoryArtifact,
      contracts | Array ContractArtifact,
      scripts | Array ScriptArtifact,
      docs | Array DocArtifact,
    },
    validation | {
      files_exist | Array String,
      files_not_empty | Array String,
      contracts_valid | Array String,
      scripts_executable | Array String,
      content_matches | Array ContentCheck,
      custom_validators | Array String,
    },
    state_updates | {...},
    next_step | {
      on_success | String | Null,
      on_failure | [| 'retry, 'skip, 'halt, 'fallback_step |],
      max_retries | Number,
    },
  },

  # Artifact types: FileArtifact, DirectoryArtifact, ContractArtifact, etc.
}
```

#### `phase-generation.ncl` - Phase 1 Complete Definition
Concrete step-by-step definition of what gets created during generation:
- Every step fully specified
- All artifacts declared
- All dependencies explicit
- All validations defined

#### `phase-pre-implementation.ncl` - Phase 2 Complete Definition
Spec filling and contract auto-generation workflow.

#### `phase-implementation.ncl` - Phase 3 Complete Definition
TDD cycle workflow with contract validation.

#### `artifact-specs.ncl` - Artifact Templates
Detailed specifications for each artifact type.

#### `dependency-graph.ncl` - DAG Definition
Explicit dependency relationships between all steps.

### 2. Workflow Execution Engine (`tools/`)

#### `workflow-engine.nu` - Core Execution Logic
```nushell
export def execute-workflow [] {
  # Read master workflow contracts
  # Determine current step from state
  # Check dependencies
  # Create artifacts
  # Validate step completion
  # Update state
  # Determine next step
}

export def check-dependencies [step: record, state: record] -> bool
export def create-artifacts [artifacts: record]
export def validate-step [step: record] -> record
export def advance-to-next-step []
```

Key functions:
- `execute-workflow` - Main execution loop
- `check-dependencies` - Validate step can run
- `create-artifacts` - Declaratively create files/contracts/scripts
- `validate-step` - Check step completion criteria
- `determine-next-step` - Workflow navigation

### 3. Phase State Management (`tools/state/`)

#### `init-state.nu` - Initialize State
Creates `.kiro/state.json` with initial phase state.

#### `update-state.nu` - Update After Each Step
Updates state after successful step completion.

#### `read-state.nu` - Display Current State
Reads and displays current phase/step status.

#### `validate-state.nu` - Validate State Contract
Ensures `.kiro/state.json` conforms to `.contracts/workflow/phase-state.ncl`.

### 4. Contract Auto-Generators (`tools/parsers/`, `tools/generators/`)

#### Parsers
- `parse-design.nu` - Extract types from design.md
- `parse-assertions.nu` - Extract validators from assertions.md

#### Generators
- `generate-type-contract.nu` - Create `.contracts/types/*.ncl`
- `generate-validator-contract.nu` - Create `.contracts/validators/*.ncl`

### 5. Enhanced Workflow Contracts (`.contracts/workflow/`)

#### `phase-state.ncl` - State Schema (ENHANCE EXISTING)
Current state tracking schema needs enhancement for step-level tracking.

```nickel
{
  PhaseState = {
    current_phase | [| 'generation, 'pre_implementation, 'implementation, 'complete |],
    current_step | String,  # e.g., "P1.S3", "P2.S5"
    started_at | String,
    last_updated | String,

    phase_history | Array {
      phase | String,
      completed_at | String,
    },

    validation_status | {
      generation | PhaseValidation,
      pre_implementation | PhaseValidation,
      implementation | PhaseValidation,
    },

    can_advance | Bool,
    blocking_issues | Array String,
  },
}
```

#### `generation-complete.ncl` - Phase 1 Validator
Validates all generation artifacts exist and are valid.

#### `spec-complete.ncl` - Phase 2 Validator
Validates specs are filled, contracts generated, consistency maintained.

#### `impl-complete.ncl` - Phase 3 Validator
Validates tests pass, contracts satisfied, tasks complete.

#### `transition-rules.ncl` - Phase Transition Logic
Rules for advancing between phases (gate checks).

### 6. Agent Commands (`.claude/commands/` or `commands/`)

New slash commands for workflow navigation:

- `/kiro-status` - Show current phase, step, progress
- `/kiro-current-step` - Display current step details
- `/kiro-validate-step` - Validate current step completion
- `/kiro-next-step` - Advance to next step (with validation)
- `/kiro-advance` - Advance to next phase (with gate check)
- `/kiro-blockers` - Show blocking issues preventing advancement
- `/kiro-report` - Full workflow report across all phases
- `/kiro-generate-contracts` - Trigger contract auto-generation

---

## Visual Documentation (Typst)

### Missing Typst Documents (`docs/`)

#### `workflow-architecture.typ` - Hierarchical Flowcharts
Using fletcher package for diagrams:
- Three-phase overview flowchart
- Per-phase detailed step flowcharts
- Contract dependency graphs
- Artifact creation flows
- Validation flow diagrams
- Decision trees (on failure/success)

#### `workflow-sequence.typ` - Sequence Diagrams
Using chronos package:
- Normal step execution sequence (Agent → Engine → Nickel → State)
- Phase transition sequence (Gate checks)
- Contract auto-generation sequence
- Crash recovery sequence
- TDD cycle sequence

#### `workflow-timeline.typ` - Gantt Charts
Using timeliney package:
- Full workflow timeline across all phases
- Per-phase step breakdowns with durations
- Dependencies and critical path
- Validation gates on timeline

#### `contract-hierarchy.typ` - Contract Structure
Hierarchical diagrams showing:
- All contract files and their relationships
- Import/dependency visualization
- Contract types and purposes

#### Typst Build Infrastructure
- Update `flake.nix` with Typst, typix, and required packages
- Add build script to compile all `.typ` → PDFs
- Include fletcher, chronos, timeliney packages

---

## Key Innovations

### 1. Workflow as Contract
The methodology itself is formally specified in Nickel contracts. This means:
- **Verifiable**: Can prove workflow is being followed
- **Auditable**: Every step documented
- **Reproducible**: Same inputs → same outputs
- **Evolvable**: Update contracts to update methodology

### 2. Self-Validation at Every Step
After each step, the system validates itself against master contracts:
```bash
create-artifacts P1.S3
validate-step P1.S3  # Checks files exist, contracts valid, etc.
if validation.valid { advance-to P1.S4 }
```

### 3. Dependency DAG is Explicit
Dependencies declared in contracts, not implicit in code:
```nickel
dependencies = {
  previous_steps = ["P1.S2", "P1.S3"],
  required_files = ["CLAUDE.md", ".kiro-scope/design.md"],
  required_contracts = [".contracts/schema/design.ncl"],
}
```

### 4. Artifacts are Declaratively Specified
Instead of imperative scripts, we declare what should exist:
```nickel
artifacts = {
  contracts = [
    {
      path = ".contracts/workflow/phase-state.ncl",
      contract_type = 'workflow,
      source = 'static,
    },
  ],
}
```
The engine reads this and creates the artifacts.

### 5. State Tracking is Contractual
`.kiro/state.json` validated against `.contracts/workflow/phase-state.ncl`:
```bash
nickel eval --validate .contracts/workflow/phase-state.ncl < .kiro/state.json
```

### 6. Crash Recovery is Automatic
On restart:
1. Read `.kiro/state.json` (validated against contract)
2. Load workflow contract
3. Find current step from state
4. Check dependencies
5. Resume execution

**No handoff document needed** - state + master contracts = complete picture.

### 7. Phase Transitions are Gates
Cannot advance until exit conditions met:
```nickel
exit_conditions = {
  all_steps_complete = true,
  validation_passes = [".contracts/workflow/generation-complete.ncl"],
  blocking_issues_resolved = true,
}
```

---

## Validation Layers

### Layer 1: Data Validation (✅ Currently Implemented)
- Validates data structure and content
- Example: `scope-directory-runtime.ncl` validates filesystem structure
- Status: Working

### Layer 2: Workflow Validation (❌ Missing)
- Validates phase completeness and transitions
- Example: "Can we advance to implementation phase?"
- Status: Needs implementation

### Layer 3: Process Validation (❌ Missing)
- Validates methodology adherence
- Example: "Are we following TDD? Is design-first being followed?"
- Status: Needs implementation

---

## When Validation Happens

### 1. Write-Time (Hooks - Lightweight)
**Current**: Basic file/scope validation
**Missing**: Step-level validation integration

### 2. Phase-Transition Time (Gates - Strict) ⚠️ MISSING
**Purpose**: Ensure phase completeness before advancing
**Trigger**: `/kiro-advance` command
**Checks**: Run phase-specific completeness validator
**Blocking**: Must pass to advance

### 3. Build-Time (Nix Checks - Comprehensive)
**Current**: Contract validation
**Missing**: Workflow-level checks

### 4. Runtime (Execution - Safety)
**Current**: Contract enforcement on data
**Missing**: Step execution validation

---

## Self-Recovery Protocol ⚠️ MISSING

**On Crash/Restart**:
1. Read `.kiro/state.json`
2. Display status to agent:
   ```
   📍 Current Phase: Pre-Implementation (65% complete)
   ⏱️  Last updated: 2 hours ago

   🚧 Blocking Issues:
   - design.md missing type definitions for Auth module
   - No assertions found for TASK-003

   ✓ Completed: Generation phase
   ⏳ In Progress: Spec completion
   ⏸️  Not Started: Implementation
   ```
3. Agent runs `/kiro-status` for detailed view
4. Agent continues work from current state

---

## Implementation Priority

### Priority 1: Core Workflow Contracts ⭐️⭐️⭐️
**Files**:
- `.contracts/meta-system/workflow.ncl`
- `.contracts/meta-system/phase-generation.ncl`
- `.contracts/meta-system/phase-pre-implementation.ncl`
- `.contracts/meta-system/phase-implementation.ncl`
- `.contracts/meta-system/artifact-specs.ncl`
- `.contracts/meta-system/dependency-graph.ncl`

**Validation**: Can define and validate workflow structure

### Priority 2: Workflow Execution Engine ⭐️⭐️⭐️
**Files**:
- `tools/workflow-engine.nu`
- `tools/state/init-state.nu`
- `tools/state/update-state.nu`
- `tools/state/read-state.nu`

**Validation**: Can execute steps based on contracts

### Priority 3: Phase State Management ⭐️⭐️
**Files**:
- `.contracts/workflow/phase-state.ncl` (enhance)
- `.contracts/workflow/generation-complete.ncl`
- `.contracts/workflow/spec-complete.ncl`
- `.contracts/workflow/impl-complete.ncl`
- `.contracts/workflow/transition-rules.ncl`

**Validation**: Can track phases and validate transitions

### Priority 4: Auto-Generation System ⭐️⭐️
**Files**:
- `tools/parsers/parse-design.nu`
- `tools/parsers/parse-assertions.nu`
- `tools/generators/generate-type-contract.nu`
- `tools/generators/generate-validator-contract.nu`

**Validation**: Can auto-generate contracts from specs

### Priority 5: Agent Commands ⭐️
**Files**:
- `commands/kiro-status.md`
- `commands/kiro-advance.md`
- `commands/kiro-validate-step.md`
- `commands/kiro-blockers.md`
- `commands/kiro-report.md`

**Validation**: Agent can navigate workflow

### Priority 6: Visual Documentation ⭐️
**Files**:
- `docs/workflow-architecture.typ`
- `docs/workflow-sequence.typ`
- `docs/workflow-timeline.typ`
- `docs/contract-hierarchy.typ`
- Update `flake.nix` with Typst support

**Validation**: Visual understanding of system

---

## Critical Design Principles

1. **Self-Documenting**: State file + kiro specs + workflow contracts = complete picture
2. **Fail-Fast at Gates**: Cannot advance with blocking issues
3. **Permissive During Dev**: Warnings don't stop work
4. **Auto-Recovery**: Crash-safe via state persistence
5. **Contract-First**: Contracts generated before code
6. **Progressive Validation**: Lightweight → Comprehensive as you advance
7. **Declarative Artifacts**: Specify what should exist, not how to create
8. **Explicit Dependencies**: DAG declared in contracts
9. **Runtime Validated**: System validates itself continuously

---

## Example Workflow Contract (Phase 1, Step 1)

```nickel
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
      { path = "." },
      { path = ".kiro" },
      { path = ".kiro-scope" },
      { path = ".contracts" },
      { path = ".contracts/meta-system" },
      { path = ".contracts/schema" },
      { path = ".contracts/workflow" },
      { path = "hooks" },
      { path = "hooks/scripts" },
      { path = "hooks/scripts-nu" },
      { path = "tools" },
      { path = "docs" },
    ],
    files = [
      {
        path = ".gitignore",
        content_source = 'template,
        template_path = "templates/gitignore.template",
      },
      {
        path = "README.md",
        content_source = 'template,
        template_path = "templates/README.template.md",
      },
    ],
  },

  validation = {
    files_exist = [".gitignore", "README.md"],
    files_not_empty = [".gitignore"],
    contracts_valid = [],
    scripts_executable = [],
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
  },
}
```

---

## Partial Implementation Already Created

During this session, I created:

**File**: `/home/lessuseless/Projects/todo-ware/.contracts/meta-system/workflow.ncl`

This file contains the master type definitions for the workflow contract system, but it's in the local working directory, not in the actual GitHub repository.

The file defines:
- `Workflow` type
- `Phase` type
- `Step` type
- All artifact types (`FileArtifact`, `DirectoryArtifact`, `ContractArtifact`, `ScriptArtifact`, `DocArtifact`)
- `ContentCheck` type

This is the foundational contract schema that all other workflow contracts would build upon.

---

## Next Steps to Implement

1. **Merge the workflow.ncl file** from local directory to repo
2. **Create phase-specific contracts** (generation, pre-implementation, implementation)
3. **Implement workflow-engine.nu** to read and execute contracts
4. **Enhance phase-state.ncl** for step-level tracking
5. **Create phase validators** (generation-complete.ncl, etc.)
6. **Build auto-generation pipeline** for types and validators
7. **Add agent commands** for workflow navigation
8. **Create Typst visual documentation**

---

## Benefits of This Architecture

### For Agents
- **Clear instructions**: Workflow contract tells exactly what to do
- **Self-recovery**: Can resume from any point
- **Validation feedback**: Know immediately if step succeeded
- **Blocking issues**: Clear list of what prevents advancement

### For Users
- **Transparency**: See exactly where project is in workflow
- **Predictability**: Know what will happen next
- **Quality**: Validation gates ensure completeness
- **Debugging**: State + contracts show full picture

### For Methodology
- **Formalized**: Kiro methodology is now executable specification
- **Verifiable**: Can prove methodology was followed
- **Evolvable**: Update contracts to improve methodology
- **Teachable**: Contracts serve as formal documentation

---

## Conclusion

The existing todo-ware implementation has excellent foundations:
- Runtime Nickel validation ✅
- Scope/spec contracts ✅
- Nushell tools ✅
- Hook system ✅

What's missing is the **meta-layer** - using Nickel contracts to define the workflow itself, making the entire kiro methodology a formal, executable, self-validating system.

This meta-system would transform todo-ware from a collection of tools into a complete, self-aware development methodology that can guide agents through the entire software development lifecycle with mathematical precision.

---

## References

### Existing Documentation
- `docs/NICKEL-RUNTIME.md` - Runtime validation patterns
- `docs/CONTRACTS.md` - Current contract usage
- `.contracts/schema/scope-directory-runtime.ncl` - Example runtime validator

### New Documentation Needed
- `docs/WORKFLOW-CONTRACTS.md` - Meta-system guide
- `docs/PHASE-SYSTEM.md` - Three-phase methodology
- `docs/AGENT-COMMANDS.md` - Workflow navigation commands

### Visual Documentation (Typst)
- Architecture flowcharts (fletcher)
- Sequence diagrams (chronos)
- Timeline Gantt charts (timeliney)
- Contract hierarchy diagrams

---

## Metadata

- **Document Created**: 2025-10-26
- **Context**: Continued session implementing meta-system workflow contracts
- **Status**: Architectural design complete, implementation not started
- **Priority**: High - This is the next major evolution of todo-ware
- **Complexity**: High - Requires coordination across contracts, execution engine, state management, and visual documentation
