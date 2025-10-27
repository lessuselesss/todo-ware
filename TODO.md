# TODO: Kiro-Scaffold Phase 1 Implementation

**Status:** Phase 1 is fully specified but non-executable due to missing contracts and tools
**Goal:** Make Phase 1 (Generation) executable end-to-end
**Success Metric:** `/kiro-new my-project` completes all 7 steps successfully

---

## CRITICAL PATH: Stage 1 - Make Phase 1 Executable

These tasks MUST be completed to enable Phase 1 execution. They are ordered by dependency.

### Group A: Schema Contracts (Unblocks P1.S3)

- [ ] **TODO-001**: Create `.contracts/schema/requirements.ncl`
  - **Blocks:** P1.S3, P1.S4
  - **Purpose:** Validate requirements.md structure (REQ-001 format)
  - **Required fields:** RequirementsFrontmatter, Requirement, RequirementsDocument
  - **Validation:** REQ-\d{3} ID format, no duplicates, valid derived_from refs
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Schema Contracts #1"

- [ ] **TODO-002**: Create `.contracts/schema/design.ncl`
  - **Blocks:** P1.S3, P1.S4
  - **Purpose:** Validate design.md structure (DES-001 format)
  - **Required fields:** DesignFrontmatter, DesignElement, TypeDefinition, DesignDocument
  - **Validation:** DES-\d{3} ID format, valid requirement_refs
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Schema Contracts #2"

- [ ] **TODO-003**: Create `.contracts/schema/tasks.ncl`
  - **Blocks:** P1.S3, P1.S4
  - **Purpose:** Validate tasks.md structure (AUTH-001 format)
  - **Required fields:** TasksFrontmatter, Task, TasksDocument
  - **Validation:** [A-Z]+-\d{3} ID format, valid refs, no circular dependencies
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Schema Contracts #3"

### Group B: Workflow State Contracts (Unblocks P1.S4, P1.S6, P1.S7)

- [ ] **TODO-004**: Create `.contracts/workflow/phase-state.ncl`
  - **Blocks:** P1.S4, P1.S6 (generator), P1.S6 (validator)
  - **Purpose:** Validate .kiro/state.json structure
  - **Required fields:** PhaseState with step tracking, phase flags, transition guards
  - **Validation:** Phase/step alignment, completion consistency
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Workflow Contracts #4"

- [ ] **TODO-005**: Create `.contracts/workflow/generation-complete.ncl`
  - **Blocks:** P1.S4, P1.S7
  - **Purpose:** Validate Phase 1 exit conditions
  - **Required checks:** All directories exist, all specs exist, all contracts valid, state valid
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Workflow Contracts #5"

### Group C: Additional Workflow Contracts (Referenced but not blocking P1)

- [ ] **TODO-006**: Create `.contracts/workflow/spec-complete.ncl`
  - **Blocks:** P1.S4 (referenced in artifacts)
  - **Purpose:** Validate Phase 2 exit conditions
  - **Required checks:** Requirements/design/tasks complete, full traceability
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Workflow Contracts #6"

- [ ] **TODO-007**: Create `.contracts/workflow/impl-complete.ncl`
  - **Blocks:** P1.S4 (referenced in artifacts)
  - **Purpose:** Validate Phase 3 exit conditions
  - **Required checks:** All assertions green, all tests passing, contracts valid
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Workflow Contracts #7"

- [ ] **TODO-008**: Create `.contracts/workflow/transition-rules.ncl`
  - **Blocks:** P1.S4 (referenced in artifacts)
  - **Purpose:** Define valid phase transitions and guards
  - **Required functions:** can_transition, guard conditions for each transition
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Workflow Contracts #8"

### Group D: Nushell Validation Tools (Unblocks P1.S5, P1.S6)

- [ ] **TODO-009**: Create `tools/validate-with-nickel.nu`
  - **Blocks:** P1.S5 (artifacts), P1.S5 (validation)
  - **Purpose:** Runtime Nickel validation wrapper functions
  - **Required exports:**
    - `validate-json`: Validate JSON against contract
    - `validate-markdown-frontmatter`: Extract and validate YAML frontmatter
    - `typecheck-contract`: Type-check Nickel contract
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Nushell Tools #9"

- [ ] **TODO-010**: Create `tools/phase-manager.nu`
  - **Blocks:** P1.S5 (artifacts), P1.S6 (generator), P1.S6 (validator)
  - **Purpose:** Phase state management for .kiro/state.json
  - **Required exports:**
    - `init-state`: Create initial state.json
    - `complete-step`: Mark step as complete
    - `validate-state`: Validate state against contract
    - `get-current-phase`, `get-current-step`: State queries
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Nushell Tools #10"

- [ ] **TODO-011**: Create `tools/workflow-engine.nu`
  - **Blocks:** P1.S5 (artifacts)
  - **Purpose:** Workflow step execution engine
  - **Required exports:**
    - `execute-step`: Execute single workflow step
    - `execute-phase`: Execute entire phase
    - `load-step-definition`: Load step from phase contract
    - `validate-step`: Run step validation
  - **See:** `.kiro-scope/phase-1-gaps.md` section "Nushell Tools #11"

- [ ] **TODO-012**: Create `hooks/scripts-nu/validate-scope-nickel.nu`
  - **Blocks:** P1.S5 (artifacts)
  - **Purpose:** Pre-commit hook for scope structure validation
  - **Integration:** Called by Claude Code hooks on Write/Edit

- [ ] **TODO-013**: Create `hooks/scripts/validate-scope-nickel.sh`
  - **Blocks:** P1.S5 (validation, scripts_executable)
  - **Purpose:** Bash version of scope validation hook
  - **Note:** Parallel implementation to Nushell version

### Group E: Phase 1 Validators (Unblocks P1.S7)

- [ ] **TODO-014**: Create `tools/validators/validate-generation-complete.nu`
  - **Blocks:** P1.S7 (custom validator)
  - **Purpose:** Execute all Phase 1 exit validation checks
  - **Checks:**
    - All directories exist
    - All spec templates exist and valid
    - All schema contracts exist and valid
    - All workflow contracts exist and valid
    - Validation scripts exist and executable
    - State file exists and valid
  - **Output:** Success/failure with detailed error messages

### Group F: Template Files (Required for artifact generation)

- [ ] **TODO-015**: Create `templates/gitignore.template`
  - **Used by:** P1.S1 (creates .gitignore)
  - **Content:** Standard gitignore for kiro projects

- [ ] **TODO-016**: Create `templates/README.template.md`
  - **Used by:** P1.S1 (creates README.md)
  - **Content:** Project README with placeholders

- [ ] **TODO-017**: Create template for `.kiro-scope/requirements.md`
  - **Used by:** P1.S3
  - **Content:** Empty requirements template with frontmatter

- [ ] **TODO-018**: Create template for `.kiro-scope/design.md`
  - **Used by:** P1.S3
  - **Content:** Empty design template with frontmatter

- [ ] **TODO-019**: Create template for `.kiro-scope/tasks.md`
  - **Used by:** P1.S3
  - **Content:** Empty tasks template with frontmatter

- [ ] **TODO-020**: Create template for `.kiro-scope/scoped-tasks.md`
  - **Used by:** P1.S3
  - **Content:** Scoped tasks template with frontmatter

- [ ] **TODO-021**: Create template for `.kiro-scope/assertions.md`
  - **Used by:** P1.S3
  - **Content:** Assertions template with TDD structure

- [ ] **TODO-022**: Create template for `.kiro-scope/context.md`
  - **Used by:** P1.S3
  - **Content:** Context template with 7 required sections

### Group G: Generator Scripts (Required for artifact generation)

- [ ] **TODO-023**: Create `tools/generators/generate-claude-md.nu`
  - **Used by:** P1.S2 (generates CLAUDE.md)
  - **Input:** Project metadata
  - **Output:** CLAUDE.md with project-specific guidance

---

## STAGE 2: Complete Meta-System (Enables Phase 2 & 3)

These tasks complete the three-phase workflow specification.

- [ ] **TODO-024**: Create `.contracts/meta-system/phase-pre-implementation.ncl`
  - **Purpose:** Define all Phase 2 steps (P2.S1 through P2.S8)
  - **Structure:** Similar to phase-generation.ncl
  - **Steps:** Fill requirements, write design, decompose tasks, generate type contracts, etc.

- [ ] **TODO-025**: Create `.contracts/meta-system/phase-implementation.ncl`
  - **Purpose:** Define all Phase 3 steps (P3.S1 through P3.Sn)
  - **Structure:** TDD cycle steps
  - **Steps:** Write assertions (RED), implement (GREEN), refactor, validate

- [ ] **TODO-026**: Create `.contracts/meta-system/artifact-specs.ncl`
  - **Purpose:** Define artifact type specifications
  - **Note:** May already be partially defined in workflow.ncl

- [ ] **TODO-027**: Create `.contracts/meta-system/dependency-graph.ncl`
  - **Purpose:** DAG definitions for artifact dependencies

---

## STAGE 3: Plugin Component Validation (Completeness)

These enable full validation of all plugin components.

- [ ] **TODO-028**: Create `.contracts/plugin/skill.ncl`
  - **Purpose:** Validate SKILL.md structure in skills directories
  - **Fields:** Skill metadata, triggers, workflow steps

- [ ] **TODO-029**: Create `.contracts/plugin/hook.ncl`
  - **Purpose:** Validate hooks.json structure
  - **Fields:** Hook matchers, scripts, timeout, event types

- [ ] **TODO-030**: Create `.contracts/plugin/mcp-server.ncl`
  - **Purpose:** Validate .mcp.json structure
  - **Fields:** Server configurations, commands, environment

---

## STAGE 4: Project Initialization (Enhanced UX)

These enable better project creation experience.

- [ ] **TODO-031**: Create `.contracts/plugin/project-definition.ncl`
  - **Purpose:** Define project metadata schema
  - **Fields:** name, description, language, framework, dependencies, mode

- [ ] **TODO-032**: Create `.contracts/plugin/prompts.ncl`
  - **Purpose:** Define interactive Q&A prompt schema
  - **Fields:** Prompt type, question, choices, validation, conditional prompts

- [ ] **TODO-033**: Implement Q&A agent for interactive mode
  - **Integration:** Use AskUserQuestion tool in /kiro-new command
  - **Flow:** Ask questions defined in prompts.ncl

- [ ] **TODO-034**: Implement inference strategy for headless mode
  - **Purpose:** Infer requirements from project description
  - **Method:** Use LLM to extract requirements when --mode=headless

---

## STAGE 5: Documentation and Testing

- [ ] **TODO-035**: Create `docs/NICKEL-RUNTIME.md`
  - **Content:** Guide for runtime Nickel validation
  - **Audience:** Plugin developers

- [ ] **TODO-036**: Create `docs/WORKFLOW-CONTRACTS.md`
  - **Content:** Guide for workflow contract structure
  - **Audience:** Plugin developers extending phases

- [ ] **TODO-037**: Create test suite for Phase 1 execution
  - **Tests:**
    - P1.S1: Directory creation
    - P1.S2: CLAUDE.md generation and validation
    - P1.S3: Spec template creation and validation
    - P1.S4: Workflow contract generation
    - P1.S5: Nushell script creation
    - P1.S6: State initialization
    - P1.S7: Complete validation
  - **Integration:** Run via `nu -c "use tests/test-phase1.nu; run-all-tests"`

- [ ] **TODO-038**: Update README.md with Phase 1 execution instructions
  - **Sections:**
    - How to run `/kiro-new`
    - Understanding phase state
    - Troubleshooting failed steps

---

## DEPENDENCIES AND ORDERING

### Critical Path for Phase 1 Execution:

```
TODO-001, TODO-002, TODO-003 (Schema contracts)
  ↓
TODO-004, TODO-005 (Workflow state contracts)
  ↓
TODO-009, TODO-010, TODO-011 (Nushell tools)
  ↓
TODO-014 (P1.S7 validator)
  ↓
TODO-015 through TODO-023 (Templates and generators)
  ↓
Phase 1 is EXECUTABLE
```

### Parallel Work Streams:

**Stream 1: Contracts**
- TODO-001 → TODO-002 → TODO-003
- TODO-004 → TODO-005
- TODO-006, TODO-007, TODO-008 (can be done in parallel)

**Stream 2: Tools**
- TODO-009 (depends on TODO-004)
- TODO-010 (depends on TODO-004)
- TODO-011 (depends on TODO-009, TODO-010)
- TODO-012, TODO-013 (can be done in parallel)
- TODO-014 (depends on TODO-005, TODO-011)

**Stream 3: Templates**
- TODO-015 through TODO-022 (can all be done in parallel)
- TODO-023 (depends on nothing, can start immediately)

---

## ACCEPTANCE CRITERIA

### For Stage 1 Completion:

**Phase 1 Must Execute Successfully:**

```bash
# 1. Create new kiro project
/kiro-new test-project --description="Test project for Phase 1"

# 2. All 7 steps complete
# Expected state.json:
{
  "current_phase": "generation",
  "current_step": "P1.S7",
  "generation_complete": true,
  "step_P1_S1_complete": true,
  "step_P1_S2_complete": true,
  "step_P1_S3_complete": true,
  "step_P1_S4_complete": true,
  "step_P1_S5_complete": true,
  "step_P1_S6_complete": true,
  "step_P1_S7_complete": true,
  "can_advance_to_pre_implementation": true
}

# 3. All contracts validate
nickel typecheck .contracts/**/*.ncl  # All pass

# 4. All generated files validate
nu -c "use tools/validators/validate-generation-complete.nu; validate"  # Success

# 5. Phase state is valid
nu -c "use tools/phase-manager.nu; validate-state"  # Success
```

**Required File Structure:**

```
test-project/
├── .kiro/
│   └── state.json                          ✅ Valid against phase-state.ncl
├── .kiro-scope/
│   ├── requirements.md                     ✅ Template created
│   ├── design.md                           ✅ Template created
│   ├── tasks.md                            ✅ Template created
│   ├── scoped-tasks.md                     ✅ Template created
│   ├── assertions.md                       ✅ Template created
│   └── context.md                          ✅ Template created
├── .contracts/
│   ├── meta-system/
│   │   ├── workflow.ncl                    ✅ Exists
│   │   └── phase-generation.ncl            ✅ Exists
│   ├── schema/
│   │   ├── requirements.ncl                ✅ Created by TODO-001
│   │   ├── design.ncl                      ✅ Created by TODO-002
│   │   ├── tasks.ncl                       ✅ Created by TODO-003
│   │   ├── scoped-tasks.ncl                ✅ Exists
│   │   ├── assertions.ncl                  ✅ Exists
│   │   ├── context.ncl                     ✅ Exists
│   │   └── scope-directory-runtime.ncl     ✅ Exists
│   └── workflow/
│       ├── phase-state.ncl                 ✅ Created by TODO-004
│       ├── generation-complete.ncl         ✅ Created by TODO-005
│       ├── spec-complete.ncl               ✅ Created by TODO-006
│       ├── impl-complete.ncl               ✅ Created by TODO-007
│       └── transition-rules.ncl            ✅ Created by TODO-008
├── tools/
│   ├── validate-with-nickel.nu             ✅ Created by TODO-009
│   ├── phase-manager.nu                    ✅ Created by TODO-010
│   ├── workflow-engine.nu                  ✅ Created by TODO-011
│   ├── generators/
│   │   └── generate-claude-md.nu           ✅ Created by TODO-023
│   └── validators/
│       └── validate-generation-complete.nu ✅ Created by TODO-014
├── hooks/
│   ├── scripts/
│   │   └── validate-scope-nickel.sh        ✅ Created by TODO-013
│   └── scripts-nu/
│       └── validate-scope-nickel.nu        ✅ Created by TODO-012
├── CLAUDE.md                               ✅ Generated by P1.S2
├── README.md                               ✅ Created from template
└── .gitignore                              ✅ Created from template
```

---

## ESTIMATED EFFORT

**Stage 1 (Critical Path):**
- Schema contracts (TODO-001 to TODO-003): **4-6 hours**
- Workflow contracts (TODO-004 to TODO-008): **4-6 hours**
- Nushell tools (TODO-009 to TODO-014): **8-12 hours**
- Templates (TODO-015 to TODO-022): **2-3 hours**
- Generators (TODO-023): **1-2 hours**
- **Total Stage 1: 19-29 hours**

**Stage 2:** 6-10 hours
**Stage 3:** 3-5 hours
**Stage 4:** 6-10 hours
**Stage 5:** 4-6 hours

**Total Project: 38-60 hours**

---

## NOTES

- **Existing tools/kiro.nu** has 20+ validation functions that can be reused
- **Existing contracts** for assertions, context, scoped-tasks are complete
- **Phase-generation.ncl** is a complete specification - just needs implementation
- **Focus on Stage 1 first** - this unblocks everything else

---

## REFERENCES

- **Phase 1 Specification:** `.contracts/meta-system/phase-generation.ncl` (lines 1-666)
- **Detailed Gap Analysis:** `.kiro-scope/phase-1-gaps.md`
- **Workflow Types:** `.contracts/meta-system/workflow.ncl`
- **Existing Validation:** `tools/kiro.nu`
- **Plugin Structure:** `CLAUDE.md` (root repository guide)
