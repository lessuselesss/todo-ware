#import "@preview/fletcher:0.5.8": *

#set document(title: "Kiro Workflow Architecture")
#set page(paper: "a4", margin: 1.5cm)

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Workflow Architecture]
]

= Three-Phase Overview

#diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  {
    node((0, 0), [*Phase 1:\ Generation*], fill: blue.lighten(80%), corner-radius: 5pt, shape: rect)
    edge((0, 0), (0, 1), "-", stroke: 2pt)
    node((0, 1), [*Phase 2:\ Pre-Implementation*], fill: green.lighten(80%), corner-radius: 5pt, shape: rect)
    edge((0, 1), (0, 2), "-", stroke: 2pt)
    node((0, 2), [*Phase 3:\ Implementation*], fill: orange.lighten(80%), corner-radius: 5pt, shape: rect)
  }
)

== Phase Descriptions

*Phase 1: Generation*
- Scaffold project structure
- Create contracts
- Generate validation infrastructure

*Phase 2: Pre-Implementation*
- Complete specifications
- Auto-generate contracts
- Define requirements and design

*Phase 3: Implementation*
- TDD cycle
- Contract validation
- Working implementation

Each phase has explicit entry and exit conditions validated by Nickel contracts.
