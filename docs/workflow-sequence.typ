#import "@preview/chronos:0.2.1": *

#set document(title: "Kiro Workflow Sequence")
#set page(paper: "a4", margin: 1.5cm)

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Workflow Sequence Diagrams]
]

= Step Execution Sequence

Normal step execution follows this pattern:

#diagram({
  _par("Agent", display-name: "Agent")
  _par("Engine", display-name: "Engine")
  _par("Nickel", display-name: "Nickel")
  _par("State", display-name: "State")

  _seq("Agent", "Engine", comment: "Request step execution")
  _seq("Engine", "Nickel", comment: "Validate against contracts")
  _seq("Nickel", "Engine", comment: "Validation result", dashed: true)
  _seq("Engine", "State", comment: "Update phase state")
  _seq("State", "Engine", comment: "Confirm update", dashed: true)
  _seq("Engine", "Agent", comment: "Success", dashed: true)
})

This ensures every step is validated before state updates occur.
