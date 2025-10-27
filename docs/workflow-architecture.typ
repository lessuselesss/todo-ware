#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/lovelace:0.3.0": *

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Meta-System Workflow Architecture]
  #v(0.5em)
  #text(size: 12pt)[Visual Definition of the Three-Phase Contract System]
  #v(0.5em)
  #text(size: 10pt, style: "italic")[todo-ware - Formal Methodology Specification]
]

#pagebreak()

#outline()

#pagebreak()

= Overview

The kiro methodology is formally defined as executable Nickel contracts that specify every phase, step, artifact, and validation in the software development workflow.

== Key Principles

- *Self-Defining*: Workflow defines itself via contracts
- *Self-Validating*: System validates itself at every step
- *Self-Documenting*: State + contracts = complete picture
- *Crash-Recoverable*: Automatic resume from state

== Three Validation Layers

1. *Data Validation* (Layer 1): Validates data structure and content
2. *Workflow Validation* (Layer 2): Validates phase completeness and transitions
3. *Process Validation* (Layer 3): Validates methodology adherence

#pagebreak()

= High-Level Workflow

#figure(
  diagram(
    spacing: (15mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,
    node((0, 0), [*User Request*], shape: fletcher.shapes.hexagon, fill: rgb("#e3f2fd")),

    edge("->", label: "kiro-scaffold"),
    node((0, 1), [*Phase 1*\ Generation], shape: rect, fill: rgb("#c8e6c9"), width: 25mm, height: 15mm),

    edge("->", label: "validate", stroke: (dash: "dashed")),
    node((1, 1), [Generation\ Complete?], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 20mm, height: 20mm),

    edge((1, 1), (0, 2), "->", label: "pass"),
    node((0, 2), [*Phase 2*\ Pre-Implementation], shape: rect, fill: rgb("#bbdefb"), width: 25mm, height: 15mm),

    edge("->", label: "validate", stroke: (dash: "dashed")),
    node((1, 2), [Spec\ Complete?], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 20mm, height: 20mm),

    edge((1, 2), (0, 3), "->", label: "pass"),
    node((0, 3), [*Phase 3*\ Implementation], shape: rect, fill: rgb("#f8bbd0"), width: 25mm, height: 15mm),

    edge("->", label: "validate", stroke: (dash: "dashed")),
    node((1, 3), [Impl\ Complete?], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 20mm, height: 20mm),

    edge((1, 3), (0, 4), "->", label: "pass"),
    node((0, 4), [*Working Software*], shape: fletcher.shapes.hexagon, fill: rgb("#c5e1a5")),

    // Failure paths
    edge((1, 1), (2, 1), "->", label: "fail", stroke: (paint: red)),
    node((2, 1), [Block], shape: fletcher.shapes.circle, fill: rgb("#ffcdd2"), width: 12mm),

    edge((1, 2), (2, 2), "->", label: "fail", stroke: (paint: red)),
    node((2, 2), [Block], shape: fletcher.shapes.circle, fill: rgb("#ffcdd2"), width: 12mm),

    edge((1, 3), (2, 3), "->", label: "fail", stroke: (paint: red)),
    node((2, 3), [Block], shape: fletcher.shapes.circle, fill: rgb("#ffcdd2"), width: 12mm),
  ),
  caption: [Three-phase workflow with validation gates]
)

#pagebreak()

= Phase 1: Generation

The kiro-scaffold plugin generates the project skeleton.

== Phase 1 Steps Flow

#figure(
  diagram(
    spacing: (18mm, 8mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((0, 0), [*Start*], shape: fletcher.shapes.pill, fill: rgb("#e8f5e9")),

    edge("->"),
    node((0, 1), [P1.S1\ Init Structure], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 2), [P1.S2\ Create CLAUDE.md], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 3), [P1.S3\ Spec Templates], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 4), [P1.S4\ Workflow Contracts], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 5), [P1.S5\ Validation Scripts], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 6), [P1.S6\ Init State], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 7), [P1.S7\ Validate Complete], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 8), [*Phase 1 Complete*], shape: fletcher.shapes.pill, fill: rgb("#4caf50")),

    // Validation checkpoints
    node((1.5, 1), [✓ Dirs exist], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 1), (1.5, 1), "->", stroke: (dash: "dotted")),

    node((1.5, 2), [✓ CLAUDE.md\ valid], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 2), (1.5, 2), "->", stroke: (dash: "dotted")),

    node((1.5, 3), [✓ Specs\ created], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 3), (1.5, 3), "->", stroke: (dash: "dotted")),

    node((1.5, 4), [✓ Contracts\ valid], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 4), (1.5, 4), "->", stroke: (dash: "dotted")),

    node((1.5, 5), [✓ Scripts\ executable], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 5), (1.5, 5), "->", stroke: (dash: "dotted")),

    node((1.5, 6), [✓ State\ initialized], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 6), (1.5, 6), "->", stroke: (dash: "dotted")),

    node((1.5, 7), [✓ All checks\ pass], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 7), (1.5, 7), "->", stroke: (dash: "dotted")),
  ),
  caption: [Phase 1 (Generation) step-by-step flow with validation points]
)

#pagebreak()

= Phase 2: Pre-Implementation

User/agent fills specs and system auto-generates contracts.

== Phase 2 Steps Flow

#figure(
  diagram(
    spacing: (18mm, 8mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((0, 0), [*Phase 1 Complete*], shape: fletcher.shapes.pill, fill: rgb("#4caf50")),

    edge("->"),
    node((0, 1), [P2.S1\ Fill requirements.md], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 2), [P2.S2\ Fill design.md], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 3), [P2.S3\ Parse → Generate\ Type Contracts], shape: rect, fill: rgb("#90caf9")),

    edge("->"),
    node((0, 4), [P2.S4\ Define tasks.md], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 5), [P2.S5\ Define scoped-tasks.md], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 6), [P2.S6\ Write assertions.md], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 7), [P2.S7\ Parse → Generate\ Validators], shape: rect, fill: rgb("#90caf9")),

    edge("->"),
    node((0, 8), [P2.S8\ Validate Spec\ Completeness], shape: rect, fill: rgb("#bbdefb")),

    edge("->"),
    node((0, 9), [*Phase 2 Complete*], shape: fletcher.shapes.pill, fill: rgb("#2196f3")),

    // Auto-generation highlights
    node((1.5, 3), [*AUTO* Generate .contracts/types/], shape: fletcher.shapes.hexagon, fill: rgb("#ffe082"), width: 18mm),
    edge((0, 3), (1.5, 3), "=>", stroke: (thickness: 2pt, paint: orange)),

    node((1.5, 7), [*AUTO* Generate .contracts/validators/], shape: fletcher.shapes.hexagon, fill: rgb("#ffe082"), width: 18mm),
    edge((0, 7), (1.5, 7), "=>", stroke: (thickness: 2pt, paint: orange)),

    // Validation checkpoints
    node((3, 2), [✓ Types\ defined], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 2), (3, 2), "->", stroke: (dash: "dotted")),

    node((3, 6), [✓ All tasks\ have assertions], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 6), (3, 6), "->", stroke: (dash: "dotted")),

    node((3, 8), [✓ No TODOs\ ✓ Consistency], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 15mm),
    edge((0, 8), (3, 8), "->", stroke: (dash: "dotted")),
  ),
  caption: [Phase 2 (Pre-Implementation) with auto-generation steps]
)

#pagebreak()

= Phase 3: Implementation

TDD cycle - write tests, implement code, validate against contracts.

== Phase 3 TDD Cycle Flow

#figure(
  diagram(
    spacing: (15mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((0, 0), [*Phase 2 Complete*], shape: fletcher.shapes.pill, fill: rgb("#2196f3")),

    edge("->"),
    node((0, 1), [P3.S1\ Write Test\ for Assertion], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((0, 2), [P3.S2\ Run Test\ *RED*], shape: rect, fill: rgb("#ef5350")),

    edge("->"),
    node((0, 3), [P3.S3\ Write Minimal\ Implementation], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((0, 4), [P3.S4\ Run Test\ *GREEN*], shape: rect, fill: rgb("#66bb6a")),

    edge("->"),
    node((0, 5), [P3.S5\ Refactor], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((0, 6), [P3.S6\ Validate Against\ Contracts], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((0, 7), [P3.S7\ Mark Task\ Complete], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((1, 7), [More\ Assertions?], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 18mm, height: 18mm),

    // Loop back
    edge((1, 7), (0, 1), "->", label: "yes", corner: (left, left)),

    // Continue to completion
    edge((1, 7), (2, 7), "->", label: "no"),
    node((2, 7), [P3.S8\ Validate Impl\ Complete], shape: rect, fill: rgb("#f8bbd0")),

    edge("->"),
    node((2, 8), [*Phase 3 Complete*], shape: fletcher.shapes.pill, fill: rgb("#e91e63")),

    // Contract validation
    node((3, 6), [Runtime\ Validators\ Pass?], shape: fletcher.shapes.circle, fill: rgb("#fff9c4"), width: 18mm),
    edge((0, 6), (3, 6), "->", stroke: (dash: "dotted")),
    edge((3, 6), (0, 5), "->", label: "fail", stroke: (paint: red), corner: (right, right)),
  ),
  caption: [Phase 3 (Implementation) TDD cycle with contract validation]
)

#pagebreak()

= Artifact Creation Flow

== What Gets Created in Each Phase

#figure(
  diagram(
    spacing: (25mm, 8mm),
    node-stroke: 1pt,
    edge-stroke: 1pt,

    // Phase 1 artifacts
    node((0, 0), [*Phase 1*], shape: rect, fill: rgb("#c8e6c9"), width: 20mm),

    node((0, 1), [Directories], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 1), "->"),

    node((0, 2), [CLAUDE.md], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 2), "->"),

    node((0, 3), [Spec Templates], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 3), "->"),

    node((0, 4), [Schema Contracts], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 4), "->"),

    node((0, 5), [Workflow Contracts], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 5), "->"),

    node((0, 6), [Validation Scripts], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 6), "->"),

    node((0, 7), [.kiro/state.json], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),
    edge((0, 0), (0, 7), "->"),

    // Phase 2 artifacts
    node((1.5, 0), [*Phase 2*], shape: rect, fill: rgb("#bbdefb"), width: 20mm),

    node((1.5, 1), [Filled Specs], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),
    edge((1.5, 0), (1.5, 1), "->"),

    node((1.5, 2), [types/\*.ncl], shape: rect, fill: rgb("#ffe082"), width: 18mm),
    edge((1.5, 0), (1.5, 2), "->"),

    node((1.5, 3), [validators/\*.ncl], shape: rect, fill: rgb("#ffe082"), width: 18mm),
    edge((1.5, 0), (1.5, 3), "->"),

    // Phase 3 artifacts
    node((3, 0), [*Phase 3*], shape: rect, fill: rgb("#f8bbd0"), width: 20mm),

    node((3, 1), [Test Files], shape: rect, fill: rgb("#fce4ec"), width: 18mm),
    edge((3, 0), (3, 1), "->"),

    node((3, 2), [Implementation\ Code], shape: rect, fill: rgb("#fce4ec"), width: 18mm),
    edge((3, 0), (3, 2), "->"),

    node((3, 3), [Passing Tests], shape: rect, fill: rgb("#fce4ec"), width: 18mm),
    edge((3, 0), (3, 3), "->"),

    node((3, 4), [Working Software], shape: rect, fill: rgb("#c5e1a5"), width: 18mm),
    edge((3, 0), (3, 4), "->"),
  ),
  caption: [Artifacts created at each phase]
)

#pagebreak()

= Dependency Graph

== Explicit Dependencies Between Steps

#figure(
  diagram(
    spacing: (20mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1pt,

    // Show P1.S1 through P1.S7 dependencies
    node((1, 0), [P1.S1], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),

    node((0, 1), [P1.S2], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((1, 0), (0, 1), "->"),

    node((2, 1), [P1.S3], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((1, 0), (2, 1), "->"),

    node((1, 2), [P1.S4], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((0, 1), (1, 2), "->"),
    edge((2, 1), (1, 2), "->"),

    node((1, 3), [P1.S5], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((1, 2), (1, 3), "->"),

    node((1, 4), [P1.S6], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((1, 3), (1, 4), "->"),

    node((1, 5), [P1.S7], shape: fletcher.shapes.circle, fill: rgb("#c8e6c9"), width: 12mm),
    edge((1, 4), (1, 5), "->"),
    edge((0, 1), (1, 5), "->", stroke: (dash: "dashed")),
    edge((2, 1), (1, 5), "->", stroke: (dash: "dashed")),

    // Label types of dependencies
    node((-0.5, 6), [Legend:], width: 15mm),
    node((0, 6.5), [Solid = Sequential\ dependency], width: 30mm),
    node((0, 7), [Dashed = Validation\ checkpoint], width: 30mm),
  ),
  caption: [Step dependencies form a directed acyclic graph (DAG)]
)

#pagebreak()

= Validation Decision Trees

== On Step Validation Failure

#figure(
  diagram(
    spacing: (18mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((1, 0), [Step\ Validation], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 18mm, height: 18mm),

    edge((1, 0), (0, 1), "->", label: "pass"),
    node((0, 1), [Update State], shape: rect, fill: rgb("#c8e6c9")),
    edge("->"),
    node((0, 2), [Next Step], shape: rect, fill: rgb("#c8e6c9")),

    edge((1, 0), (2, 1), "->", label: "fail"),
    node((2, 1), [Check\ Failure\ Policy], shape: fletcher.shapes.diamond, fill: rgb("#ffe082"), width: 18mm, height: 18mm),

    edge((2, 1), (1.5, 2), "->", label: "retry"),
    node((1.5, 2), [Attempt < max?], shape: fletcher.shapes.diamond, fill: rgb("#ffe082"), width: 15mm, height: 15mm),
    edge((1.5, 2), (1, 0), "->", label: "yes", corner: (left, left)),
    edge((1.5, 2), (1.5, 3), "->", label: "no"),
    node((1.5, 3), [*HALT*], shape: fletcher.shapes.hexagon, fill: rgb("#ef5350")),

    edge((2, 1), (2.5, 2), "->", label: "skip"),
    node((2.5, 2), [Mark Skipped], shape: rect, fill: rgb("#fff9c4")),
    edge("->"),
    node((2.5, 3), [Next Step], shape: rect, fill: rgb("#c8e6c9")),

    edge((2, 1), (3.5, 2), "->", label: "halt"),
    node((3.5, 2), [*HALT*], shape: fletcher.shapes.hexagon, fill: rgb("#ef5350")),

    edge((2, 1), (4.5, 2), "->", label: "fallback"),
    node((4.5, 2), [Fallback Step], shape: rect, fill: rgb("#fff9c4")),
  ),
  caption: [Validation failure handling based on step policy]
)

#pagebreak()

= Workflow State Machines

== Phase Transition State Machine

#figure(
  pseudocode-list(
    booktabs: true,
    numbered-title: [*Phase State Machine*],
  )[
    + *States:* NOT_STARTED, GENERATION, PRE_IMPLEMENTATION, IMPLEMENTATION, COMPLETE
    + *Initial State:* NOT_STARTED
    + *Transitions:*
      - NOT_STARTED #sym.arrow GENERATION: Start workflow
      - GENERATION #sym.arrow PRE_IMPLEMENTATION: Generation gate passes
      - PRE_IMPLEMENTATION #sym.arrow IMPLEMENTATION: Spec complete gate passes
      - IMPLEMENTATION #sym.arrow COMPLETE: Implementation gate passes
    + *Guards:*
      - generation_complete: All P1 steps done, contracts valid
      - spec_complete: All specs filled, contracts generated
      - impl_complete: All tests pass, contracts satisfied
  ],
  caption: [Phase transition state machine pseudocode]
)

== Step Execution State Machine

#figure(
  pseudocode-list(
    booktabs: true,
    numbered-title: [*Step State Machine*],
  )[
    + *States:* PENDING, CHECKING_DEPS, EXECUTING, VALIDATING, COMPLETE, FAILED
    + *Initial State:* PENDING
    + *Transitions:*
      - PENDING #sym.arrow CHECKING_DEPS: Step requested
      - CHECKING_DEPS #sym.arrow EXECUTING: Dependencies met
      - CHECKING_DEPS #sym.arrow FAILED: Dependencies not met
      - EXECUTING #sym.arrow VALIDATING: Artifacts created
      - VALIDATING #sym.arrow COMPLETE: Validation passed
      - VALIDATING #sym.arrow FAILED: Validation failed
      - FAILED #sym.arrow CHECKING_DEPS: Retry (if policy allows)
      - FAILED #sym.arrow PENDING: Skip (if policy allows)
    + *Actions:*
      - On entering EXECUTING: Create artifacts
      - On entering VALIDATING: Run validators
      - On entering COMPLETE: Update state.json
      - On entering FAILED: Increment retry counter
  ],
  caption: [Step execution state machine with retry logic]
)

== Validation Result State Machine

#figure(
  pseudocode-list(
    booktabs: true,
    numbered-title: [*Validation State Machine*],
  )[
    + *States:* NOT_VALIDATED, VALIDATING, PASSED, FAILED_RETRIABLE, FAILED_TERMINAL
    + *Initial State:* NOT_VALIDATED
    + *Transitions:*
      - NOT_VALIDATED #sym.arrow VALIDATING: Start validation
      - VALIDATING #sym.arrow PASSED: All checks pass
      - VALIDATING #sym.arrow FAILED_RETRIABLE: Checks fail, retries < max
      - VALIDATING #sym.arrow FAILED_TERMINAL: Checks fail, retries >= max
      - FAILED_RETRIABLE #sym.arrow VALIDATING: Retry validation
    + *Data:*
      - errors: Array of validation error messages
      - retry_count: Current retry attempt
      - max_retries: Maximum allowed retries
  ],
  caption: [Validation result state machine]
)

#pagebreak()

= State Tracking

== .kiro/state.json Structure

#figure(
  diagram(
    spacing: (20mm, 8mm),
    node-stroke: 1pt,
    edge-stroke: 1pt,

    node((1, 0), [*state.json*], shape: rect, fill: rgb("#fff9c4"), width: 20mm),

    edge("->"),
    node((0, 1), [current_phase], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),

    edge((1, 0), (1, 1), "->"),
    node((1, 1), [current_step], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),

    edge((1, 0), (2, 1), "->"),
    node((2, 1), [started_at], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),

    edge((1, 0), (0, 2), "->"),
    node((0, 2), [validation_status], shape: rect, fill: rgb("#ffe082"), width: 20mm),
    edge("->"),
    node((0, 3), [generation], shape: rect, fill: rgb("#c8e6c9"), width: 15mm),
    edge((0, 2), (1, 3), "->"),
    node((1, 3), [pre_impl], shape: rect, fill: rgb("#bbdefb"), width: 15mm),
    edge((0, 2), (2, 3), "->"),
    node((2, 3), [impl], shape: rect, fill: rgb("#f8bbd0"), width: 15mm),

    edge((1, 0), (2, 2), "->"),
    node((2, 2), [can_advance], shape: rect, fill: rgb("#e8f5e9"), width: 18mm),

    edge((1, 0), (1, 4), "->"),
    node((1, 4), [blocking_issues], shape: rect, fill: rgb("#ffcdd2"), width: 20mm),

    edge((1, 0), (0, 5), "->"),
    node((0, 5), [phase_history], shape: rect, fill: rgb("#e0e0e0"), width: 18mm),
  ),
  caption: [State file structure tracking workflow progress]
)

#pagebreak()

= Contract Validation Flow

== How Contracts Validate the System

#figure(
  diagram(
    spacing: (18mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((1, 0), [*System Event*], shape: fletcher.shapes.hexagon, fill: rgb("#e3f2fd")),

    edge("->"),
    node((1, 1), [Read\ .kiro/state.json], shape: rect, fill: rgb("#fff9c4")),

    edge("->"),
    node((1, 2), [Load Workflow\ Contract], shape: rect, fill: rgb("#ffe082")),

    edge("->"),
    node((1, 3), [Determine\ Current Step], shape: rect, fill: rgb("#e8f5e9")),

    edge("->"),
    node((1, 4), [Validate\ Dependencies], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 18mm, height: 18mm),

    edge((1, 4), (0, 5), "->", label: "fail"),
    node((0, 5), [*BLOCK*\ Show Issues], shape: fletcher.shapes.hexagon, fill: rgb("#ffcdd2")),

    edge((1, 4), (2, 5), "->", label: "pass"),
    node((2, 5), [Execute Step\ Create Artifacts], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((2, 6), [Validate\ Artifacts], shape: fletcher.shapes.diamond, fill: rgb("#fff9c4"), width: 18mm, height: 18mm),

    edge((2, 6), (1, 7), "->", label: "fail"),
    node((1, 7), [Handle\ Failure], shape: rect, fill: rgb("#ffcdd2")),

    edge((2, 6), (3, 7), "->", label: "pass"),
    node((3, 7), [Update State], shape: rect, fill: rgb("#c8e6c9")),

    edge("->"),
    node((3, 8), [Next Step\ or Phase Gate], shape: rect, fill: rgb("#c8e6c9")),
  ),
  caption: [Contract-driven validation at every step]
)

#pagebreak()

= Summary

== The Meta-System Architecture

The kiro meta-system provides:

=== 1. Formal Specification
- Workflow defined as Nickel contracts
- Every phase, step, and artifact specified
- Dependencies explicitly declared
- Validation rules encoded

=== 2. Self-Execution
- Workflow engine reads contracts
- Creates artifacts declaratively
- Validates at every step
- Manages state transitions

=== 3. Self-Validation
- Contracts validate themselves
- State validated against contracts
- Phase gates enforce completeness
- Blocking issues prevent advancement

=== 4. Self-Recovery
- State persisted to `.kiro/state.json`
- Contracts + state = complete picture
- Automatic resume on crash
- No handoff documents needed

== Next Steps

With the visual architecture defined, the implementation follows:

1. Create remaining meta-system contracts (Phase 2, Phase 3)
2. Implement workflow execution engine
3. Build phase state management tools
4. Create contract auto-generators
5. Add agent navigation commands
6. Complete visual documentation (sequence diagrams, timelines)
