#import "@preview/fletcher:0.4.5" as fletcher: diagram, node, edge
#import "@preview/treet:0.1.1": *

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Contract Hierarchy]
  #v(0.5em)
  #text(size: 12pt)[Structure and Relationships of Nickel Contracts]
  #v(0.5em)
  #text(size: 10pt, style: "italic")[todo-ware - Contract Organization]
]

#pagebreak()

#outline()

#pagebreak()

= Overview

The kiro system uses Nickel contracts organized into five categories:

1. *Meta-System Contracts*: Define the workflow itself
2. *Workflow Contracts*: Track and validate phases
3. *Schema Contracts*: Define data structures
4. *Type Contracts*: Define domain entities (auto-generated)
5. *Validator Contracts*: Define runtime validations (auto-generated)

#pagebreak()

= Complete Project Structure

== Full Directory Tree

#figure(
  tree-list(
    root: "project/",
    fill: (color: blue)
  )[
    - .kiro/
      - state.json #text(fill: red, size: 9pt)[Workflow state tracking]
    - .kiro-scope/
      - requirements.md #text(fill: blue, size: 9pt)[User requirements]
      - design.md #text(fill: blue, size: 9pt)[Architecture & types]
      - tasks.md #text(fill: blue, size: 9pt)[Task list]
      - scoped-tasks.md #text(fill: blue, size: 9pt)[Tasks by scope]
      - assertions.md #text(fill: blue, size: 9pt)[TDD assertions]
      - context.md #text(fill: blue, size: 9pt)[Additional context]
    - .contracts/
      - meta-system/ #text(fill: orange, size: 9pt)[Workflow definition]
      - workflow/ #text(fill: green, size: 9pt)[Phase validation]
      - schema/ #text(fill: purple, size: 9pt)[Data structure contracts]
      - types/ #text(fill: orange, style: "italic", size: 9pt)[AUTO-GENERATED from design.md]
      - validators/ #text(fill: red, style: "italic", size: 9pt)[AUTO-GENERATED from assertions.md]
    - tools/
      - workflow-engine.nu #text(fill: teal, size: 9pt)[Execute workflow]
      - phase-manager.nu #text(fill: teal, size: 9pt)[Manage state]
      - validate-with-nickel.nu #text(fill: teal, size: 9pt)[Runtime validation]
      - parsers/
        - parse-design.nu #text(fill: orange, size: 9pt)[Extract types]
        - parse-assertions.nu #text(fill: orange, size: 9pt)[Extract validators]
      - generators/
        - generate-type-contract.nu #text(fill: orange, size: 9pt)[Create type contracts]
        - generate-validator-contract.nu #text(fill: orange, size: 9pt)[Create validators]
      - state/
        - init-state.nu
        - update-state.nu
        - read-state.nu
      - validators/
        - validate-generation-complete.nu
    - hooks/
      - scripts-nu/
        - validate-scope-nickel.nu
        - validate-contracts.nu
      - scripts/
        - validate-scope-nickel.sh
    - docs/
      - NICKEL-RUNTIME.md
      - WORKFLOW-CONTRACTS.md
      - workflow-architecture.typ #text(fill: purple, size: 9pt)[This doc!]
    - src/ #text(fill: gray, style: "italic", size: 9pt)[Your implementation code]
    - tests/ #text(fill: gray, style: "italic", size: 9pt)[Your test files]
    - CLAUDE.md #text(fill: blue, size: 9pt)[Repository guidance]
    - README.md
    - flake.nix #text(fill: green, size: 9pt)[Nix dev environment]
  ],
  caption: [Complete generated project structure]
)

#pagebreak()

= Complete Contract Hierarchy

#figure(
  diagram(
    spacing: (20mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1pt,

    node((2, 0), [*.contracts/*], shape: rect, fill: rgb("#e0e0e0"), width: 25mm, height: 12mm),

    // Meta-system branch
    edge((2, 0), (0, 1), "->"),
    node((0, 1), [*meta-system/*], shape: rect, fill: rgb("#ffe082"), width: 25mm),

    edge("->"),
    node((0, 2), [workflow.ncl], shape: rect, fill: rgb("#fff9c4"), width: 22mm),
    edge((0, 1), (0, 3), "->"),
    node((0, 3), [phase-generation.ncl], shape: rect, fill: rgb("#fff9c4"), width: 22mm),
    edge((0, 1), (0, 4), "->"),
    node((0, 4), [phase-pre-impl.ncl], shape: rect, fill: rgb("#fff9c4"), width: 22mm),
    edge((0, 1), (0, 5), "->"),
    node((0, 5), [phase-impl.ncl], shape: rect, fill: rgb("#fff9c4"), width: 22mm),

    // Workflow branch
    edge((2, 0), (1.3, 1), "->"),
    node((1.3, 1), [*workflow/*], shape: rect, fill: rgb("#c8e6c9"), width: 23mm),

    edge("->"),
    node((1.3, 2), [phase-state.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),
    edge((1.3, 1), (1.3, 3), "->"),
    node((1.3, 3), [generation-complete.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),
    edge((1.3, 1), (1.3, 4), "->"),
    node((1.3, 4), [spec-complete.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),
    edge((1.3, 1), (1.3, 5), "->"),
    node((1.3, 5), [impl-complete.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),
    edge((1.3, 1), (1.3, 6), "->"),
    node((1.3, 6), [transition-rules.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),

    // Schema branch
    edge((2, 0), (2.6, 1), "->"),
    node((2.6, 1), [*schema/*], shape: rect, fill: rgb("#bbdefb"), width: 20mm),

    edge("->"),
    node((2.6, 2), [claude-md.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),
    edge((2.6, 1), (2.6, 3), "->"),
    node((2.6, 3), [scope-directory.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),
    edge((2.6, 1), (2.6, 4), "->"),
    node((2.6, 4), [scope-dir-runtime.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),
    edge((2.6, 1), (2.6, 5), "->"),
    node((2.6, 5), [assertions.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),
    edge((2.6, 1), (2.6, 6), "->"),
    node((2.6, 6), [scoped-tasks.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),

    // Types branch (auto-generated)
    edge((2, 0), (3.6, 1), "->"),
    node((3.6, 1), [*types/*\ _(auto)_], shape: rect, fill: rgb("#ffcc80"), width: 20mm),

    edge("->"),
    node((3.6, 2), [user.ncl], shape: rect, fill: rgb("#ffe0b2"), width: 16mm),
    edge((3.6, 1), (3.6, 3), "->"),
    node((3.6, 3), [session.ncl], shape: rect, fill: rgb("#ffe0b2"), width: 16mm),
    edge((3.6, 1), (3.6, 4), "->"),
    node((3.6, 4), [auth.ncl], shape: rect, fill: rgb("#ffe0b2"), width: 16mm),
    edge((3.6, 1), (3.6, 5), "->"),
    node((3.6, 5), [...], shape: rect, fill: rgb("#ffe0b2"), width: 16mm),

    // Validators branch (auto-generated)
    edge((2, 0), (4.6, 1), "->"),
    node((4.6, 1), [*validators/*\ _(auto)_], shape: rect, fill: rgb("#ef9a9a"), width: 22mm),

    edge("->"),
    node((4.6, 2), [TASK-001--A1.ncl], shape: rect, fill: rgb("#ffcdd2"), width: 20mm),
    edge((4.6, 1), (4.6, 3), "->"),
    node((4.6, 3), [TASK-001--A2.ncl], shape: rect, fill: rgb("#ffcdd2"), width: 20mm),
    edge((4.6, 1), (4.6, 4), "->"),
    node((4.6, 4), [TASK-002--A1.ncl], shape: rect, fill: rgb("#ffcdd2"), width: 20mm),
    edge((4.6, 1), (4.6, 5), "->"),
    node((4.6, 5), [...], shape: rect, fill: rgb("#ffcdd2"), width: 20mm),
  ),
  caption: [Complete `.contracts/` directory hierarchy]
)

#pagebreak()

= Contract Dependencies

== Import Relationships

#figure(
  diagram(
    spacing: (25mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    // Base contracts
    node((1, 0), [workflow.ncl], shape: rect, fill: rgb("#ffe082")),

    // Imports workflow.ncl
    edge((1, 0), (0, 1), "->", label: "imports"),
    node((0, 1), [phase-generation.ncl], shape: rect, fill: rgb("#fff9c4")),

    edge((1, 0), (1, 1), "->", label: "imports"),
    node((1, 1), [phase-pre-impl.ncl], shape: rect, fill: rgb("#fff9c4")),

    edge((1, 0), (2, 1), "->", label: "imports"),
    node((2, 1), [phase-impl.ncl], shape: rect, fill: rgb("#fff9c4")),

    // phase-state.ncl is independent
    node((0, 3), [phase-state.ncl], shape: rect, fill: rgb("#c8e6c9")),

    // Other workflow contracts import phase-state
    edge((0, 3), (0, 4), "->", label: "imports"),
    node((0, 4), [generation-complete.ncl], shape: rect, fill: rgb("#e8f5e9")),

    edge((0, 3), (1, 4), "->", label: "imports"),
    node((1, 4), [spec-complete.ncl], shape: rect, fill: rgb("#e8f5e9")),

    edge((0, 3), (2, 4), "->", label: "imports"),
    node((2, 4), [impl-complete.ncl], shape: rect, fill: rgb("#e8f5e9")),

    // transition-rules imports all completeness contracts
    edge((0, 4), (1, 5), "->", label: "imports"),
    edge((1, 4), (1, 5), "->", label: "imports"),
    edge((2, 4), (1, 5), "->", label: "imports"),
    node((1, 5), [transition-rules.ncl], shape: rect, fill: rgb("#e8f5e9")),

    // Schema contracts
    node((3.5, 3), [scope-directory.ncl], shape: rect, fill: rgb("#bbdefb")),

    edge("->", label: "imports"),
    node((3.5, 4), [scope-dir-runtime.ncl], shape: rect, fill: rgb("#e3f2fd")),

    // Auto-generated contracts have no imports
    node((5, 3), [types/*.ncl], shape: rect, fill: rgb("#ffcc80")),
    node((5, 4), [validators/*.ncl], shape: rect, fill: rgb("#ef9a9a")),
  ),
  caption: [Contract import dependencies]
)

#pagebreak()

= Contract Types by Purpose

== Categorization

#figure(
  diagram(
    spacing: (22mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((2, 0), [*Contract Purpose*], shape: fletcher.shapes.hexagon, fill: rgb("#e0e0e0"), width: 28mm),

    // Type 1: Normative (defines methodology)
    edge((2, 0), (0, 1), "->"),
    node((0, 1), [*Normative*], shape: rect, fill: rgb("#ffe082"), width: 22mm),
    edge("->"),
    node((0, 2), [Defines the\ methodology], width: 22mm),
    edge("->"),
    node((0, 3), [workflow.ncl\ phase-*.ncl], shape: rect, fill: rgb("#fff9c4"), width: 22mm),

    // Type 2: Validating (checks compliance)
    edge((2, 0), (1.3, 1), "->"),
    node((1.3, 1), [*Validating*], shape: rect, fill: rgb("#c8e6c9"), width: 22mm),
    edge("->"),
    node((1.3, 2), [Checks\ compliance], width: 22mm),
    edge("->"),
    node((1.3, 3), [*-complete.ncl\ transition-rules.ncl], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),

    // Type 3: Structural (data shape)
    edge((2, 0), (2.6, 1), "->"),
    node((2.6, 1), [*Structural*], shape: rect, fill: rgb("#bbdefb"), width: 22mm),
    edge("->"),
    node((2.6, 2), [Defines data\ structures], width: 22mm),
    edge("->"),
    node((2.6, 3), [schema/*.ncl\ types/*.ncl], shape: rect, fill: rgb("#e3f2fd"), width: 22mm),

    // Type 4: Runtime (validates execution)
    edge((2, 0), (4, 1), "->"),
    node((4, 1), [*Runtime*], shape: rect, fill: rgb("#ef9a9a"), width: 22mm),
    edge("->"),
    node((4, 2), [Validates at\ execution], width: 22mm),
    edge("->"),
    node((4, 3), [scope-dir-runtime.ncl\ validators/*.ncl], shape: rect, fill: rgb("#ffcdd2"), width: 22mm),
  ),
  caption: [Contract types by purpose]
)

#pagebreak()

= Contract Creation Flow

== Static vs Auto-Generated

#figure(
  diagram(
    spacing: (25mm, 12mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    // Static contracts (Phase 1)
    node((0, 0), [*Phase 1*\ Generation], shape: rect, fill: rgb("#c8e6c9"), width: 22mm),

    edge("->", label: "creates"),
    node((0, 1), [meta-system/*.ncl], shape: rect, fill: rgb("#ffe082"), width: 22mm),

    edge((0, 0), (0, 2), "->", label: "creates"),
    node((0, 2), [workflow/*.ncl], shape: rect, fill: rgb("#c8e6c9"), width: 22mm),

    edge((0, 0), (0, 3), "->", label: "creates"),
    node((0, 3), [schema/*.ncl], shape: rect, fill: rgb("#bbdefb"), width: 22mm),

    // Auto-generated contracts (Phase 2)
    node((2, 0), [*Phase 2*\ Pre-Implementation], shape: rect, fill: rgb("#bbdefb"), width: 25mm),

    edge("->", label: "user fills"),
    node((2, 1), [design.md], shape: rect, fill: rgb("#e3f2fd"), width: 18mm),

    edge("->", label: "parse"),
    node((2, 2), [Parser], shape: fletcher.shapes.hexagon, fill: rgb("#fff9c4"), width: 16mm),

    edge("->", label: "generate"),
    node((2, 3), [types/*.ncl], shape: rect, fill: rgb("#ffcc80"), width: 18mm),

    // Assertion auto-gen
    edge((2, 0), (3.5, 1), "->", label: "user writes"),
    node((3.5, 1), [assertions.md], shape: rect, fill: rgb("#e3f2fd"), width: 20mm),

    edge("->", label: "parse"),
    node((3.5, 2), [Parser], shape: fletcher.shapes.hexagon, fill: rgb("#fff9c4"), width: 16mm),

    edge("->", label: "generate"),
    node((3.5, 3), [validators/*.ncl], shape: rect, fill: rgb("#ef9a9a"), width: 20mm),
  ),
  caption: [How contracts are created across phases]
)

#pagebreak()

= Contract Validation Layers

== Three-Layer Validation System

#figure(
  diagram(
    spacing: (18mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    node((1, 0), [*System*], shape: fletcher.shapes.hexagon, fill: rgb("#e3f2fd"), width: 18mm),

    // Layer 1: Data Validation
    edge("->"),
    node((1, 1), [*Layer 1*\ Data Validation], shape: rect, fill: rgb("#bbdefb"), width: 25mm),

    edge("->"),
    node((0, 2), [Schema\ Contracts], shape: rect, fill: rgb("#e3f2fd"), width: 20mm),
    edge((1, 1), (2, 2), "->"),
    node((2, 2), [Type\ Contracts], shape: rect, fill: rgb("#ffe0b2"), width: 18mm),

    edge((0, 2), (0, 3), "->", label: "validate"),
    node((0, 3), [File structure\ JSON/YAML format], width: 20mm),

    edge((2, 2), (2, 3), "->", label: "validate"),
    node((2, 3), [Domain entities\ Field types], width: 18mm),

    // Layer 2: Workflow Validation
    edge((1, 1), (1, 4), "->"),
    node((1, 4), [*Layer 2*\ Workflow Validation], shape: rect, fill: rgb("#c8e6c9"), width: 25mm),

    edge("->"),
    node((1, 5), [Workflow\ Contracts], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),

    edge("->", label: "validate"),
    node((1, 6), [Phase completeness\ Transition readiness], width: 22mm),

    // Layer 3: Process Validation
    edge((1, 4), (1, 7), "->"),
    node((1, 7), [*Layer 3*\ Process Validation], shape: rect, fill: rgb("#ffe082"), width: 25mm),

    edge("->"),
    node((1, 8), [Meta-System\ Contracts], shape: rect, fill: rgb("#fff9c4"), width: 23mm),

    edge("->", label: "validate"),
    node((1, 9), [Methodology adherence\ Step execution correctness], width: 23mm),
  ),
  caption: [Three layers of contract validation]
)

#pagebreak()

= Contract File Organization

== Physical Directory Structure

#figure(
  tree-list(
    root: ".contracts/",
    fill: (color: yellow)
  )[
    - meta-system/ #text(fill: gray, style: "italic")[Layer 3: Process validation]
      - workflow.ncl #text(fill: gray, size: 9pt)[Core type definitions]
      - phase-generation.ncl #text(fill: gray, size: 9pt)[P1 step-by-step]
      - phase-pre-implementation.ncl #text(fill: gray, size: 9pt)[P2 step-by-step]
      - phase-implementation.ncl #text(fill: gray, size: 9pt)[P3 step-by-step]
    - workflow/ #text(fill: gray, style: "italic")[Layer 2: Workflow validation]
      - phase-state.ncl #text(fill: gray, size: 9pt)[State tracking schema]
      - generation-complete.ncl #text(fill: gray, size: 9pt)[P1 exit validator]
      - spec-complete.ncl #text(fill: gray, size: 9pt)[P2 exit validator]
      - impl-complete.ncl #text(fill: gray, size: 9pt)[P3 exit validator]
      - transition-rules.ncl #text(fill: gray, size: 9pt)[Phase transition logic]
    - schema/ #text(fill: gray, style: "italic")[Layer 1: Data validation (static)]
      - claude-md.ncl #text(fill: gray, size: 9pt)[CLAUDE.md structure]
      - scope-directory.ncl #text(fill: gray, size: 9pt)[Scope structure]
      - scope-directory-runtime.ncl #text(fill: gray, size: 9pt)[Runtime validation]
      - assertions.ncl #text(fill: gray, size: 9pt)[Assertion format]
      - scoped-tasks.ncl #text(fill: gray, size: 9pt)[Scoped tasks format]
      - context.ncl #text(fill: gray, size: 9pt)[Context documentation]
    - types/ #text(fill: gray, style: "italic")[Layer 1: Data validation (auto-generated)]
      - user.ncl #text(fill: orange, size: 9pt)[User entity - AUTO]
      - session.ncl #text(fill: orange, size: 9pt)[Session entity - AUTO]
      - auth.ncl #text(fill: orange, size: 9pt)[Auth entity - AUTO]
      - ... #text(fill: orange, size: 9pt)[Generated from design.md]
    - validators/ #text(fill: gray, style: "italic")[Layer 1: Runtime validation (auto-generated)]
      - TASK-001--A1.ncl #text(fill: red, size: 9pt)[Assertion validator - AUTO]
      - TASK-001--A2.ncl #text(fill: red, size: 9pt)[AUTO]
      - TASK-002--A1.ncl #text(fill: red, size: 9pt)[AUTO]
      - ... #text(fill: red, size: 9pt)[Generated from assertions.md]
  ],
  caption: [Complete `.contracts/` directory structure using tree visualization]
)

#pagebreak()

= Contract Lifecycle

== Creation, Validation, Evolution

#figure(
  diagram(
    spacing: (20mm, 10mm),
    node-stroke: 1pt,
    edge-stroke: 1.5pt,

    // Creation
    node((0, 0), [*Created*], shape: fletcher.shapes.pill, fill: rgb("#c8e6c9")),

    edge("->"),
    node((0, 1), [Static\ (hand-written)], shape: rect, fill: rgb("#e8f5e9"), width: 22mm),

    edge((0, 0), (1.3, 1), "->"),
    node((1.3, 1), [Auto-generated\ (from specs)], shape: rect, fill: rgb("#ffe0b2"), width: 22mm),

    // Validation
    edge((0, 1), (0, 2), "->"),
    edge((1.3, 1), (1.3, 2), "->"),
    node((0.65, 2), [*Validated*], shape: fletcher.shapes.pill, fill: rgb("#fff9c4")),

    edge("->"),
    node((0.65, 3), [nickel typecheck], shape: rect, fill: rgb("#fff9c4"), width: 20mm),

    edge("->"),
    node((0.65, 4), [nickel eval --validate], shape: rect, fill: rgb("#fff9c4"), width: 20mm),

    // Usage
    edge("->"),
    node((0.65, 5), [*Used*], shape: fletcher.shapes.pill, fill: rgb("#bbdefb")),

    edge("->"),
    node((0.65, 6), [Workflow engine\ reads contracts], shape: rect, fill: rgb("#e3f2fd"), width: 22mm),

    edge("->"),
    node((0.65, 7), [System validates\ against contracts], shape: rect, fill: rgb("#e3f2fd"), width: 22mm),

    // Evolution
    edge("->"),
    node((0.65, 8), [*Evolved*], shape: fletcher.shapes.pill, fill: rgb("#ffe082")),

    edge("->"),
    node((0.65, 9), [Updated as\ methodology evolves], shape: rect, fill: rgb("#fff9c4"), width: 22mm),
  ),
  caption: [Contract lifecycle from creation to evolution]
)

#pagebreak()

= Summary

== Contract System Architecture

=== Five Categories

1. *Meta-System* (`meta-system/`): Defines the kiro workflow itself
   - Core type definitions
   - Phase step-by-step specifications
   - Normative contracts (source of truth for methodology)

2. *Workflow* (`workflow/`): Tracks and validates workflow execution
   - Phase state schema
   - Completeness validators
   - Transition rules
   - Validating contracts (check compliance)

3. *Schema* (`schema/`): Defines project structure and data formats
   - File structure contracts
   - Document format contracts
   - Static contracts (hand-written)

4. *Types* (`types/`): Domain entity definitions
   - Auto-generated from `design.md`
   - Structural contracts (data shape)
   - One contract per entity

5. *Validators* (`validators/`): Runtime assertion validators
   - Auto-generated from `assertions.md`
   - Runtime contracts (execution validation)
   - One contract per assertion

=== Key Relationships

- Meta-system contracts are independent (define methodology)
- Workflow contracts import phase-state
- Schema contracts may import each other
- Type contracts are independent (from parsing)
- Validator contracts are independent (from parsing)

=== Creation Timeline

- *Phase 1*: Create all static contracts (meta-system, workflow, schema)
- *Phase 2*: Auto-generate types and validators from specs
- *Phase 3*: Validate implementation against all contracts

=== Benefits

- *Organization*: Clear categorization and structure
- *Traceability*: Know where every contract lives
- *Maintainability*: Easy to update and evolve
- *Auto-Generation*: Types and validators created automatically
- *Validation*: Three-layer validation system

## Next Steps

With the contract hierarchy visualized:

1. Implement the missing contracts according to this structure
2. Build the parsers to auto-generate types and validators
3. Create the workflow engine to read and execute contracts
4. Set up validation tooling for all three layers
