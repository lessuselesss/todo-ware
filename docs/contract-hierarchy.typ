#import "@preview/fletcher:0.5.8": *

#set document(title: "Kiro Contract Hierarchy")
#set page(paper: "a4", margin: 1.5cm)

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Contract Hierarchy]
]

= Contract Structure

#v(1em)

#diagram(
  node-stroke: 1pt,
  spacing: (15mm, 8mm),
  {
    // Root
    node((1, 0), [`.contracts/`], fill: gray.lighten(70%), corner-radius: 3pt, width: 25mm)

    // Main categories
    edge((1, 0), (0, 1), "-", stroke: 1.5pt)
    node((0, 1), [`meta-system/`], fill: blue.lighten(80%), corner-radius: 3pt, width: 25mm)

    edge((1, 0), (1, 1), "-", stroke: 1.5pt)
    node((1, 1), [`schema/`], fill: green.lighten(80%), corner-radius: 3pt, width: 25mm)

    edge((1, 0), (2, 1), "-", stroke: 1.5pt)
    node((2, 1), [`validation/`], fill: orange.lighten(80%), corner-radius: 3pt, width: 25mm)

    // Meta-system children
    edge((0, 1), (0, 2), "-")
    node((0, 2), [workflow.ncl], shape: rect, width: 22mm, height: 8mm)

    edge((0, 1), (0, 3), "-")
    node((0, 3), [artifact-specs.ncl], shape: rect, width: 22mm, height: 8mm)

    // Schema children
    edge((1, 1), (1, 2), "-")
    node((1, 2), [scope-directory.ncl], shape: rect, width: 22mm, height: 8mm)

    edge((1, 1), (1, 3), "-")
    node((1, 3), [assertions.ncl], shape: rect, width: 22mm, height: 8mm)

    edge((1, 1), (1, 4), "-")
    node((1, 4), [scoped-tasks.ncl], shape: rect, width: 22mm, height: 8mm)

    // Validation children
    edge((2, 1), (2, 2), "-")
    node((2, 2), [assertion-ids.ncl], shape: rect, width: 22mm, height: 8mm)

    edge((2, 1), (2, 3), "-")
    node((2, 3), [markdown.ncl], shape: rect, width: 22mm, height: 8mm)

    edge((2, 1), (2, 4), "-")
    node((2, 4), [traceability.ncl], shape: rect, width: 22mm, height: 8mm)
  }
)

#v(1em)

== Contract Categories

*Meta-System Contracts* - Master workflow and artifact definitions
- workflow.ncl: Three-phase workflow type definitions
- artifact-specs.ncl: Artifact type specifications and DAG definitions

*Schema Contracts* - Project structure and content schemas
- scope-directory.ncl: Validates `.kiro-scope/` directory structure
- assertions.ncl: TDD assertion schemas with RED-GREEN-REFACTOR phases
- scoped-tasks.ncl: Task decomposition and traceability schemas

*Validation Contracts* - Format and consistency validation
- assertion-ids.ncl: ID format validation (`TASK-###--A#` with double-dash)
- markdown.ncl: Markdown structure and YAML frontmatter validation
- traceability.ncl: Cross-file reference validation for requirement chains
