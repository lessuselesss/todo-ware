#import "@preview/timeliney:0.0.1": *

#set page(paper: "a4", margin: 1.5cm, flipped: true)
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Meta-System Timeline]
  #v(0.5em)
  #text(size: 12pt)[Gantt Charts for Workflow Phases]
  #v(0.5em)
  #text(size: 10pt, style: "italic")[todo-ware - Project Timeline Visualization]
]

#pagebreak()

#outline()

#pagebreak()

= Overview

These Gantt charts show the temporal flow of the three-phase workflow, including:
- Duration of each step
- Dependencies between steps
- Parallel vs sequential execution
- Validation gates
- Critical path through the workflow

#pagebreak()

= Full Workflow Timeline

== All Three Phases

#timeline(
  show-grid: true,
  {
    headerline(
      group(([*Phase 1: Generation*], 7)),
      group(([*Phase 2: Pre-Implementation*], 8)),
      group(([*Phase 3: Implementation*], 12))
    )

    headerline(
      group(..range(7).map(n => [S#(n + 1)])),
      group(..range(8).map(n => [S#(n + 1)])),
      group(([TDD], 12))
    )

    taskgroup(title: [*Phase 1 Steps*], {
      task("P1.S1: Init Structure", (0, 1), style: (stroke: 2pt + green))
      task("P1.S2: CLAUDE.md", (1, 2), style: (stroke: 2pt + green))
      task("P1.S3: Spec Templates", (2, 3), style: (stroke: 2pt + green))
      task("P1.S4: Workflow Contracts", (3, 4), style: (stroke: 2pt + green))
      task("P1.S5: Validation Scripts", (4, 5), style: (stroke: 2pt + green))
      task("P1.S6: Init State", (5, 6), style: (stroke: 2pt + green))
      task("P1.S7: Validate Complete", (6, 7), style: (stroke: 2pt + green))
    })

    milestone(
      at: 7,
      style: (stroke: (dash: "dashed"), fill: yellow),
      align(center, [
        *Gate:*\
        Generation\
        Complete?
      ])
    )

    taskgroup(title: [*Phase 2 Steps*], {
      task("P2.S1: Fill requirements.md", (7, 8), style: (stroke: 2pt + blue))
      task("P2.S2: Fill design.md", (8, 9), style: (stroke: 2pt + blue))
      task("P2.S3: Generate Type Contracts", (9, 10), style: (stroke: 2pt + orange))
      task("P2.S4: Define tasks.md", (10, 11), style: (stroke: 2pt + blue))
      task("P2.S5: Define scoped-tasks.md", (11, 12), style: (stroke: 2pt + blue))
      task("P2.S6: Write assertions.md", (12, 13), style: (stroke: 2pt + blue))
      task("P2.S7: Generate Validators", (13, 14), style: (stroke: 2pt + orange))
      task("P2.S8: Validate Spec Complete", (14, 15), style: (stroke: 2pt + blue))
    })

    milestone(
      at: 15,
      style: (stroke: (dash: "dashed"), fill: yellow),
      align(center, [
        *Gate:*\
        Spec\
        Complete?
      ])
    )

    taskgroup(title: [*Phase 3 TDD Cycles*], {
      task("TDD: Auth Module", (15, 17), style: (stroke: 2pt + red))
      task("TDD: User Module", (17, 19), style: (stroke: 2pt + red))
      task("TDD: API Endpoints", (19, 21), style: (stroke: 2pt + red))
      task("TDD: Database Layer", (21, 23), style: (stroke: 2pt + red))
      task("TDD: Integration Tests", (23, 25), style: (stroke: 2pt + red))
      task("P3: Final Validation", (25, 27), style: (stroke: 2pt + red))
    })

    milestone(
      at: 27,
      style: (stroke: (dash: "dashed"), fill: yellow),
      align(center, [
        *Gate:*\
        Impl\
        Complete?
      ])
    )
  }
)

#v(1em)

*Legend:*
- #text(fill: green)[■] Phase 1 (Generation) - Sequential steps
- #text(fill: blue)[■] Phase 2 (Pre-Implementation) - User fills specs
- #text(fill: orange)[■] Phase 2 - Auto-generation steps
- #text(fill: red)[■] Phase 3 (Implementation) - TDD cycles
- #text(fill: yellow)[◆] Validation gates

#pagebreak()

= Phase 1 Detailed Timeline

== Generation Phase Step-by-Step

#timeline(
  show-grid: true,
  {
    headerline(..range(7).map(n => [Step #(n + 1)]))

    taskgroup(title: [*Directory Setup*], {
      task("Create .kiro/", (0, 1), style: (stroke: 2pt + green))
      task("Create .contracts/", (0, 1), style: (stroke: 2pt + green.lighten(20%)))
      task("Create tools/", (0, 1), style: (stroke: 2pt + green.lighten(40%)))
      task("Create docs/", (0, 1), style: (stroke: 2pt + green.lighten(60%)))
    })

    taskgroup(title: [*Documentation*], {
      task("CLAUDE.md", (1, 2), style: (stroke: 2pt + blue))
      task(".gitignore", (1, 2), style: (stroke: 2pt + blue.lighten(30%)))
      task("README.md", (1, 2), style: (stroke: 2pt + blue.lighten(60%)))
    })

    taskgroup(title: [*Spec Templates*], {
      task("requirements.md", (2, 3), style: (stroke: 2pt + purple))
      task("design.md", (2, 3), style: (stroke: 2pt + purple.lighten(20%)))
      task("tasks.md", (2, 3), style: (stroke: 2pt + purple.lighten(40%)))
      task("assertions.md", (2, 3), style: (stroke: 2pt + purple.lighten(60%)))
    })

    taskgroup(title: [*Contracts*], {
      task("meta-system/*.ncl", (3, 4), style: (stroke: 2pt + orange))
      task("schema/*.ncl", (3, 4), style: (stroke: 2pt + orange.lighten(20%)))
      task("workflow/*.ncl", (3, 4), style: (stroke: 2pt + orange.lighten(40%)))
    })

    taskgroup(title: [*Scripts*], {
      task("validate-with-nickel.nu", (4, 5), style: (stroke: 2pt + teal))
      task("phase-manager.nu", (4, 5), style: (stroke: 2pt + teal.lighten(20%)))
      task("workflow-engine.nu", (4, 5), style: (stroke: 2pt + teal.lighten(40%)))
      task("hooks/*.nu", (4, 5), style: (stroke: 2pt + teal.lighten(60%)))
    })

    taskgroup(title: [*State*], {
      task("Initialize .kiro/state.json", (5, 6), style: (stroke: 2pt + maroon))
    })

    taskgroup(title: [*Validation*], {
      task("Run all validators", (6, 7), style: (stroke: 2pt + red))
      task("Check contracts", (6, 7), style: (stroke: 2pt + red.lighten(30%)))
      task("Verify state", (6, 7), style: (stroke: 2pt + red.lighten(60%)))
    })
  }
)

#v(1em)

*Total Duration:* ~5-10 minutes (automated)

*Critical Path:* All steps are sequential

#pagebreak()

= Phase 2 Detailed Timeline

== Pre-Implementation with Auto-Generation

#timeline(
  show-grid: true,
  {
    headerline(..range(8).map(n => [Step #(n + 1)]))

    taskgroup(title: [*Requirements*], {
      task("Write requirements", (0, 1), style: (stroke: 2pt + blue))
      task("Define acceptance criteria", (0, 1), style: (stroke: 2pt + blue.lighten(30%)))
    })

    taskgroup(title: [*Design*], {
      task("Define architecture", (1, 2), style: (stroke: 2pt + purple))
      task("Define types", (1, 2), style: (stroke: 2pt + purple.lighten(20%)))
      task("Define interfaces", (1, 2), style: (stroke: 2pt + purple.lighten(40%)))
    })

    taskgroup(title: [*Auto-Gen Types*], {
      task("Parse design.md", (2, 2.5), style: (stroke: 2pt + orange))
      task("Generate contracts", (2.5, 3), style: (stroke: 2pt + orange.lighten(30%)))
    })

    taskgroup(title: [*Tasks*], {
      task("List all tasks", (3, 4), style: (stroke: 2pt + green))
    })

    taskgroup(title: [*Scoped Tasks*], {
      task("Break down by scope", (4, 5), style: (stroke: 2pt + green.lighten(30%)))
    })

    taskgroup(title: [*Assertions*], {
      task("Write TDD assertions", (5, 6), style: (stroke: 2pt + red))
      task("Link to tasks", (5, 6), style: (stroke: 2pt + red.lighten(30%)))
    })

    taskgroup(title: [*Auto-Gen Validators*], {
      task("Parse assertions.md", (6, 6.5), style: (stroke: 2pt + orange))
      task("Generate validators", (6.5, 7), style: (stroke: 2pt + orange.lighten(30%)))
    })

    taskgroup(title: [*Validation*], {
      task("Check completeness", (7, 8), style: (stroke: 2pt + maroon))
      task("Verify consistency", (7, 8), style: (stroke: 2pt + maroon.lighten(30%)))
    })
  }
)

#v(1em)

*Total Duration:* 2-8 hours (human-in-loop)

*Auto-Generation Steps:* P2.S3, P2.S7 (highlighted in orange)

*Critical Path:* Must complete specs before auto-generation

#pagebreak()

= Phase 3 TDD Cycles

== Implementation with Test-Driven Development

#timeline(
  show-grid: true,
  {
    headerline(
      group(([*Auth*], 4)),
      group(([*User*], 4)),
      group(([*API*], 4))
    )

    taskgroup(title: [*Auth Module*], {
      task("Write test: login", (0, 0.5), style: (stroke: 2pt + red))
      task("RED", (0.5, 1), style: (stroke: 2pt + red, fill: red.lighten(80%)))
      task("Implement: login", (1, 1.5), style: (stroke: 2pt + green))
      task("GREEN", (1.5, 2), style: (stroke: 2pt + green, fill: green.lighten(80%)))
      task("Refactor", (2, 2.5), style: (stroke: 2pt + blue))
      task("Write test: logout", (2.5, 3), style: (stroke: 2pt + red))
      task("RED→GREEN", (3, 3.5), style: (stroke: 2pt + orange))
      task("Write test: refresh", (3.5, 4), style: (stroke: 2pt + red))
    })

    taskgroup(title: [*User Module*], {
      task("Write test: create", (4, 4.5), style: (stroke: 2pt + red))
      task("RED→GREEN", (4.5, 5.5), style: (stroke: 2pt + orange))
      task("Write test: update", (5.5, 6), style: (stroke: 2pt + red))
      task("RED→GREEN", (6, 7), style: (stroke: 2pt + orange))
      task("Write test: delete", (7, 7.5), style: (stroke: 2pt + red))
      task("RED→GREEN", (7.5, 8), style: (stroke: 2pt + orange))
    })

    taskgroup(title: [*API Endpoints*], {
      task("Write test: GET /users", (8, 8.5), style: (stroke: 2pt + red))
      task("RED→GREEN", (8.5, 9.5), style: (stroke: 2pt + orange))
      task("Write test: POST /users", (9.5, 10), style: (stroke: 2pt + red))
      task("RED→GREEN", (10, 11), style: (stroke: 2pt + orange))
      task("Integration tests", (11, 12), style: (stroke: 2pt + purple))
    })

    // Contract validation points
    milestone(at: 2, style: (stroke: (dash: "dashed")), [✓ Contract])
    milestone(at: 4, style: (stroke: (dash: "dashed")), [✓ Contract])
    milestone(at: 8, style: (stroke: (dash: "dashed")), [✓ Contract])
    milestone(at: 12, style: (stroke: (dash: "dashed")), [✓ All])
  }
)

#v(1em)

*Total Duration:* 1-4 weeks (varies by project size)

*TDD Pattern:* Write test → RED → Implement → GREEN → Refactor → Repeat

*Contract Validation:* After each module completion

#pagebreak()

= Dependencies and Critical Path

== What Blocks What

#timeline(
  show-grid: true,
  {
    headerline(
      group(([*P1*], 7)),
      group(([*P2*], 8)),
      group(([*P3*], 6))
    )

    taskgroup(title: [*Critical Path*], {
      task("P1: Generation", (0, 7), style: (stroke: 3pt + red))
      task("P2: Specs", (7, 15), style: (stroke: 3pt + red))
      task("P3: Implementation", (15, 21), style: (stroke: 3pt + red))
    })

    taskgroup(title: [*Blockers*], {
      task("P1 blocks P2", (7, 7), style: (stroke: 0pt, fill: red))
      task("P2 blocks P3", (15, 15), style: (stroke: 0pt, fill: red))
    })

    taskgroup(title: [*Parallel Work Possible*], {
      // In P2, some steps can overlap
      task("Docs (parallel)", (7, 15), style: (stroke: 1pt + blue.lighten(50%), fill: blue.lighten(90%)))
      // In P3, different modules can be built in parallel (if independent)
      task("Independent modules", (15, 21), style: (stroke: 1pt + green.lighten(50%), fill: green.lighten(90%)))
    })
  }
)

#v(1em)

*Key Insights:*

1. *Phase 1 must complete* before Phase 2 can start
2. *Phase 2 specs must be filled* before Phase 3 can start
3. Within phases, some parallelization possible:
   - P1: All sequential (automated)
   - P2: Documentation can be written in parallel with spec filling
   - P3: Independent modules can be implemented in parallel

#pagebreak()

= Validation Gates Timeline

== When Validations Occur

#timeline(
  show-grid: true,
  {
    headerline(..range(1, 22).map(n => [#n]))

    taskgroup(title: [*Write-Time Validation*], {
      // Continuous validation during work
      task("Hooks check on save", (0, 21), style: (stroke: 1pt + blue.lighten(50%), fill: blue.lighten(90%)))
    })

    taskgroup(title: [*Step Validation*], {
      // Each step validates on completion
      task("P1.S1 validates", (1, 1), style: (stroke: 0pt, fill: yellow))
      task("P1.S2 validates", (2, 2), style: (stroke: 0pt, fill: yellow))
      task("P1.S3 validates", (3, 3), style: (stroke: 0pt, fill: yellow))
      task("P1.S4 validates", (4, 4), style: (stroke: 0pt, fill: yellow))
      task("P1.S5 validates", (5, 5), style: (stroke: 0pt, fill: yellow))
      task("P1.S6 validates", (6, 6), style: (stroke: 0pt, fill: yellow))
    })

    taskgroup(title: [*Gate Validation*], {
      // Phase gates (comprehensive)
      task("P1 Gate Check", (7, 7), style: (stroke: 3pt + red, fill: red.lighten(80%)))
      task("P2 Gate Check", (15, 15), style: (stroke: 3pt + red, fill: red.lighten(80%)))
      task("P3 Gate Check", (21, 21), style: (stroke: 3pt + red, fill: red.lighten(80%)))
    })

    taskgroup(title: [*Build-Time Validation*], {
      // CI/CD checks
      task("nix flake check", (7, 7), style: (stroke: 2pt + green.lighten(50%)))
      task("nix flake check", (15, 15), style: (stroke: 2pt + green.lighten(50%)))
      task("nix flake check", (21, 21), style: (stroke: 2pt + green.lighten(50%)))
    })
  }
)

#v(1em)

*Validation Layers:*

1. *Write-Time* (Continuous): Hooks check files on save - non-blocking warnings
2. *Step Validation* (Each step): Validate artifacts after step - blocks advancement
3. *Gate Validation* (Phase boundaries): Comprehensive check - must pass to advance
4. *Build-Time* (CI/CD): Full validation including tests - deployment gate

#pagebreak()

= Summary

== Timeline Insights

=== Phase Durations

- *Phase 1 (Generation):* 5-10 minutes (fully automated)
- *Phase 2 (Pre-Implementation):* 2-8 hours (human fills specs, auto-generates contracts)
- *Phase 3 (Implementation):* 1-4 weeks (varies by project complexity)

=== Critical Observations

1. *Fast Start*: Generation is quick and automated
2. *Spec Investment*: Phase 2 requires thoughtful design work
3. *Contract Leverage*: Auto-generated contracts save implementation time
4. *TDD Cycles*: Short RED-GREEN cycles maintain momentum
5. *Validation Gates*: Prevent advancement until quality met

=== Parallelization Opportunities

- Phase 1: Sequential (but fast)
- Phase 2: Some parallel work (docs, research)
- Phase 3: Module independence enables parallelization

=== Bottlenecks

- P1→P2 gate: Must have skeleton first
- P2→P3 gate: Must have complete specs + contracts
- P3 validation: All tests must pass

== Next Steps

With timing visualized, we can:

1. Estimate project timelines accurately
2. Identify optimization opportunities
3. Plan agent work allocation
4. Set realistic milestones
5. Track actual vs. planned progress
