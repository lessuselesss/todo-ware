#import "@preview/fletcher:0.5.8": *

#set document(title: "Kiro Workflow Timeline")
#set page(paper: "a4", margin: 1.5cm)

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Workflow Timeline]
]

= Project Timeline

#v(1em)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 2pt,
  spacing: (20mm, 10mm),
  {
    // Timeline nodes
    node((0, 0), [*Phase 1:\ Generation*\ \ _Minutes to Hours_], fill: blue.lighten(80%), corner-radius: 5pt, shape: rect, width: 35mm, height: 20mm)

    node((0, 1), [Scaffold structure\ Create contracts\ Generate validation], width: 35mm, height: 15mm, stroke: none, fill: none)

    edge((0, 0), (1, 0), "-", stroke: 3pt)

    node((1, 0), [*Phase 2:\ Pre-Implementation*\ \ _Hours to Days_], fill: green.lighten(80%), corner-radius: 5pt, shape: rect, width: 35mm, height: 20mm)

    node((1, 1), [Write specs\ Auto-generate contracts\ Define requirements], width: 35mm, height: 15mm, stroke: none, fill: none)

    edge((1, 0), (2, 0), "-", stroke: 3pt)

    node((2, 0), [*Phase 3:\ Implementation*\ \ _Days to Weeks_], fill: orange.lighten(80%), corner-radius: 5pt, shape: rect, width: 35mm, height: 20mm)

    node((2, 1), [TDD cycle\ Contract validation\ Working implementation], width: 35mm, height: 15mm, stroke: none, fill: none)
  }
)

#v(1em)

== Detailed Phase Breakdown

*Phase 1: Generation* (Short duration)
- Output: Complete project skeleton ready for specification

*Phase 2: Pre-Implementation* (Medium duration)
- Output: Complete specifications with generated contracts

*Phase 3: Implementation* (Long duration)
- Output: Working, tested, contract-validated implementation
