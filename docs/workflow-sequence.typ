#import "@preview/chronos:0.2.0": *

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 20pt, weight: "bold")[Kiro Meta-System Sequence Diagrams]
  #v(0.5em)
  #text(size: 12pt)[Interaction Flows Between Components]
  #v(0.5em)
  #text(size: 10pt, style: "italic")[todo-ware - Workflow Execution Sequences]
]

#pagebreak()

#outline()

#pagebreak()

= Overview

These sequence diagrams show the interactions between:
- *Agent*: Claude or other AI agent
- *User*: Human developer
- *Engine*: Workflow execution engine
- *Contracts*: Nickel contract system
- *State*: `.kiro/state.json` file
- *Filesystem*: Project files and artifacts

#pagebreak()

= Normal Step Execution

== Agent Executes a Workflow Step

#figure(
  diagram({
    import chronos: *

    _seq("Agent", "Engine", "Contracts", "State", "Filesystem")

    _alt("Step Execution", {
      _seq("Agent", "Engine", comment: [Request: Execute next step])
      _seq("Engine", "State", comment: [Read current state])
      _seq("State", "Engine", comment: [Return: phase=P1, step=P1.S3])
      _seq("Engine", "Contracts", comment: [Load: phase-generation.ncl])
      _seq("Contracts", "Engine", comment: [Return: Step P1.S3 definition])

      _grp("Check Dependencies", {
        _seq("Engine", "Filesystem", comment: [Check: CLAUDE.md exists?])
        _seq("Filesystem", "Engine", comment: [✓ exists])
        _seq("Engine", "Contracts", comment: [Validate: claude-md.ncl])
        _seq("Contracts", "Engine", comment: [✓ valid])
      })

      _alt("Dependencies Met", {
        _grp("Create Artifacts", {
          _seq("Engine", "Filesystem", comment: [Create: spec templates])
          _seq("Filesystem", "Engine", comment: [✓ created])
          _seq("Engine", "Filesystem", comment: [Copy: schema contracts])
          _seq("Filesystem", "Engine", comment: [✓ copied])
        })

        _grp("Validate Step", {
          _seq("Engine", "Filesystem", comment: [Check: files exist?])
          _seq("Filesystem", "Engine", comment: [✓ all exist])
          _seq("Engine", "Contracts", comment: [Validate: all contracts])
          _seq("Contracts", "Engine", comment: [✓ all valid])
        })

        _grp("Update State", {
          _seq("Engine", "State", comment: [Set: step_P1_S3_complete=true])
          _seq("Engine", "State", comment: [Set: current_step=P1.S3])
          _seq("State", "Engine", comment: [✓ updated])
        })

        _seq("Engine", "Agent", comment: [Success: Step P1.S3 complete])
      }, else: {
        _seq("Engine", "Agent", comment: [Error: Dependencies not met])
      })
    })
  }),
  caption: [Normal workflow step execution]
)

#pagebreak()

= Phase Transition (Gate Check)

== Agent Attempts to Advance to Next Phase

#figure(
  diagram({
    import chronos: *

    _seq("Agent", "Engine", "Contracts", "State")

    _seq("Agent", "Engine", comment: [`/kiro-advance` command])
    _seq("Engine", "State", comment: [Read current state])
    _seq("State", "Engine", comment: [phase=generation, all steps complete])

    _grp("Check Exit Conditions", {
      _seq("Engine", "Contracts", comment: [Load: generation-complete.ncl])
      _seq("Contracts", "Engine", comment: [Validator loaded])

      _seq("Engine", "Contracts", comment: [Validate: all artifacts exist?])
      _seq("Contracts", "Engine", comment: [Check result])

      _seq("Engine", "Contracts", comment: [Validate: all contracts valid?])
      _seq("Contracts", "Engine", comment: [Check result])

      _seq("Engine", "Contracts", comment: [Validate: no blocking issues?])
      _seq("Contracts", "Engine", comment: [Check result])
    })

    _alt("Exit Conditions Met", {
      _grp("Advance Phase", {
        _seq("Engine", "State", comment: [Set: current_phase=pre_implementation])
        _seq("Engine", "State", comment: [Append: phase_history])
        _seq("Engine", "State", comment: [Set: generation_complete=true])
        _seq("State", "Engine", comment: [✓ updated])
      })

      _seq("Engine", "Agent", comment: [✓ Advanced to Phase 2])
    }, else: {
      _seq("Engine", "State", comment: [Get: blocking_issues])
      _seq("State", "Engine", comment: [Return: [issue1, issue2]])
      _seq("Engine", "Agent", comment: [✗ Cannot advance\nBlocking issues: ...])
    })
  }),
  caption: [Phase transition with validation gate]
)

#pagebreak()

= Contract Auto-Generation

== Parse Spec and Generate Contracts

#figure(
  diagram({
    import chronos: *

    _seq("Agent", "Parser", "Generator", "Contracts", "Filesystem")

    _seq("Agent", "Parser", comment: [Parse design.md])
    _seq("Parser", "Filesystem", comment: [Read: .kiro-scope/design.md])
    _seq("Filesystem", "Parser", comment: [Return: file content])

    _grp("Extract Types", {
      _seq("Parser", "Parser", comment: [Find: ## Types section])
      _seq("Parser", "Parser", comment: [Extract: User, Session, etc.])
      _seq("Parser", "Parser", comment: [Parse: field types, constraints])
    })

    _seq("Parser", "Generator", comment: [Types: [User, Session, ...]  ])

    _loop("For each type", {
      _seq("Generator", "Generator", comment: [Build Nickel contract])
      _seq("Generator", "Filesystem", comment: [Write: .contracts/types/user.ncl])
      _seq("Filesystem", "Generator", comment: [✓ written])

      _seq("Generator", "Contracts", comment: [Validate: user.ncl])
      _seq("Contracts", "Generator", comment: [✓ valid])
    })

    _seq("Generator", "Agent", comment: [✓ Generated 3 type contracts])
  }),
  caption: [Contract auto-generation from specs]
)

#pagebreak()

= Crash Recovery

== System Restarts and Resumes

#figure(
  diagram({
    import chronos: *

    _seq("System", "Engine", "State", "Contracts", "Agent")

    _seq("System", "Engine", comment: [*RESTART*])

    _grp("Recover State", {
      _seq("Engine", "State", comment: [Read: .kiro/state.json])
      _seq("State", "Engine", comment: [phase=P2, step=P2.S5, ...])

      _seq("Engine", "Contracts", comment: [Load: workflow contracts])
      _seq("Contracts", "Engine", comment: [Return: workflow definition])

      _seq("Engine", "Contracts", comment: [Get: step P2.S5 definition])
      _seq("Contracts", "Engine", comment: [Return: dependencies, artifacts, ...])
    })

    _grp("Display Status", {
      _seq("Engine", "Agent", comment: [📍 Current: Phase 2, Step P2.S5])
      _seq("Engine", "Agent", comment: [⏱️ Last updated: 2h ago])
      _seq("Engine", "Agent", comment: [✓ Completed: P1, P2.S1-S4])
      _seq("Engine", "Agent", comment: [⏳ In Progress: P2.S5])
      _seq("Engine", "Agent", comment: [🚧 Blocking: design.md missing Auth types])
    })

    _seq("Agent", "Engine", comment: [Acknowledge - continuing work])

    _note(over: "Agent", pos: right, [Agent resumes\ from exact point\ of interruption])
  }),
  caption: [Automatic crash recovery via state]
)

#pagebreak()

= TDD Cycle

== Write Test → RED → Implement → GREEN

#figure(
  diagram({
    import chronos: *

    _seq("Agent", "Filesystem", "TestRunner", "Contracts")

    _grp("RED Phase", {
      _seq("Agent", "Filesystem", comment: [Write: test_auth_login.py])
      _seq("Filesystem", "Agent", comment: [✓ test written])

      _seq("Agent", "TestRunner", comment: [Run: pytest])
      _seq("TestRunner", "Filesystem", comment: [Load: test_auth_login.py])
      _seq("Filesystem", "TestRunner", comment: [Test code])
      _seq("TestRunner", "Filesystem", comment: [Import: auth module])
      _seq("Filesystem", "TestRunner", comment: [❌ ModuleNotFoundError])
      _seq("TestRunner", "Agent", comment: [*RED* - Test failed as expected])
    })

    _grp("GREEN Phase", {
      _seq("Agent", "Filesystem", comment: [Write: auth.py (minimal)])
      _seq("Filesystem", "Agent", comment: [✓ implementation written])

      _seq("Agent", "TestRunner", comment: [Run: pytest])
      _seq("TestRunner", "Filesystem", comment: [Load: auth.py])
      _seq("Filesystem", "TestRunner", comment: [Code loaded])
      _seq("TestRunner", "TestRunner", comment: [Execute test])
      _seq("TestRunner", "Agent", comment: [*GREEN* - Test passed])
    })

    _grp("Validate Against Contracts", {
      _seq("Agent", "Contracts", comment: [Validate: AUTH-001--A1 contract])
      _seq("Contracts", "Filesystem", comment: [Check: auth.py behavior])
      _seq("Filesystem", "Contracts", comment: [Return: execution result])
      _seq("Contracts", "Agent", comment: [✓ Contract satisfied])
    })

    _seq("Agent", "Agent", comment: [✓ Task complete - move to next assertion])
  }),
  caption: [TDD cycle with contract validation]
)

#pagebreak()

= Agent Command Execution

== User Invokes `/kiro-status`

#figure(
  diagram({
    import chronos: *

    _seq("User", "Agent", "Engine", "State", "Contracts")

    _seq("User", "Agent", comment: [`/kiro-status`])
    _seq("Agent", "Engine", comment: [Get workflow status])

    _grp("Gather Status Information", {
      _seq("Engine", "State", comment: [Read state])
      _seq("State", "Engine", comment: [Current phase/step, history, ...])

      _seq("Engine", "Contracts", comment: [Load current phase contract])
      _seq("Contracts", "Engine", comment: [Phase definition])

      _seq("Engine", "Contracts", comment: [Load validation contracts])
      _seq("Contracts", "Engine", comment: [Validators])

      _loop("For each phase", {
        _seq("Engine", "Contracts", comment: [Check completion status])
        _seq("Contracts", "Engine", comment: [Complete/In Progress/Not Started])
      })

      _seq("Engine", "State", comment: [Get blocking issues])
      _seq("State", "Engine", comment: [List of issues])
    })

    _grp("Format Report", {
      _seq("Engine", "Agent", comment: [Report: formatted status])
      _seq("Agent", "User", comment: [
        📍 *Phase 2: Pre-Implementation* (65% complete)\
        \
        *Progress:*\
        ✓ Phase 1: Generation\
        ⏳ Phase 2: Pre-Implementation\
        \ \ ✓ P2.S1-S4 complete\
        \ \ ⏳ P2.S5 in progress\
        \ \ ⏸️ P2.S6-S8 pending\
        ⏸️ Phase 3: Implementation\
        \
        *Blocking Issues:*\
        🚧 design.md missing Auth module types\
        🚧 No assertions for TASK-003\
        \
        *Can Advance:* No - resolve blocking issues first
      ])
    })
  }),
  caption: [Agent command execution showing workflow status]
)

#pagebreak()

= Validation Failure Handling

== Step Validation Fails with Retry Policy

#figure(
  diagram({
    import chronos: *

    _seq("Engine", "Validator", "State", "Agent")

    _seq("Engine", "Validator", comment: [Validate step artifacts])
    _seq("Validator", "Validator", comment: [Check: files exist])
    _seq("Validator", "Validator", comment: [Check: contracts valid])
    _seq("Validator", "Engine", comment: [❌ Validation failed:\ncontracts/types/user.ncl syntax error])

    _grp("Check Retry Policy", {
      _seq("Engine", "State", comment: [Get: retry_count for step])
      _seq("State", "Engine", comment: [Return: attempt=1, max=3])

      _alt("Can Retry", {
        _seq("Engine", "State", comment: [Increment: retry_count])
        _seq("Engine", "Agent", comment: [⚠️ Step failed, retrying (1/3):\nFix: user.ncl syntax error])

        _seq("Agent", "Agent", comment: [Fix the issue])
        _seq("Agent", "Engine", comment: [Retry step execution])

        _note(over: "Engine", pos: right, [Loop back to\ step execution])
      }, else: {
        _seq("Engine", "State", comment: [Set: step_failed=true])
        _seq("Engine", "Agent", comment: [❌ Step failed after 3 attempts\n*HALT* - Manual intervention required])

        _note(over: "Agent", pos: right, [Workflow halted\ until issue resolved])
      })
    })
  }),
  caption: [Validation failure with retry handling]
)

#pagebreak()

= Multi-Agent Handoff

== Agent A Starts, Agent B Continues

#figure(
  diagram({
    import chronos: *

    _seq("Agent A", "Engine", "State", "Agent B")

    _grp("Agent A Works", {
      _seq("Agent A", "Engine", comment: [Execute: P2.S1-S4])
      _seq("Engine", "State", comment: [Update: progress])
      _seq("Engine", "Agent A", comment: [✓ P2.S4 complete])

      _note(over: "Agent A", pos: right, [*CRASH* or\ session ends])
    })

    _gap()

    _grp("Agent B Starts", {
      _seq("Agent B", "Engine", comment: [*NEW SESSION*])

      _seq("Engine", "State", comment: [Read state])
      _seq("State", "Engine", comment: [phase=P2, step=P2.S4, ...])

      _seq("Engine", "Agent B", comment: [
        📍 Resuming from:\
        Phase 2, Step P2.S4\
        \
        ✓ Completed: P1, P2.S1-S4\
        ⏳ Next: P2.S5 (Define scoped-tasks.md)
      ])

      _seq("Agent B", "Engine", comment: [Acknowledge - continuing])
      _seq("Agent B", "Engine", comment: [Execute: P2.S5])
      _seq("Engine", "State", comment: [Update: progress])
    })

    _note(over: "Agent B", pos: right, [Seamless handoff\ No context loss])
  }),
  caption: [Multi-agent handoff via state file]
)

#pagebreak()

= Summary

== Interaction Patterns

The sequence diagrams show key interaction patterns:

=== 1. Normal Execution
- Agent → Engine → Contracts → State → Filesystem
- Validate dependencies before execution
- Create artifacts declaratively
- Validate after creation
- Update state on success

=== 2. Gate Checks
- Load validation contracts
- Check all exit conditions
- Block or advance based on results
- Update phase history

=== 3. Auto-Generation
- Parse specs systematically
- Generate contracts programmatically
- Validate generated contracts
- Report results to agent

=== 4. Crash Recovery
- Read state on startup
- Load workflow contracts
- Display current position
- Agent continues seamlessly

=== 5. TDD Cycle
- Write test (RED)
- Implement (GREEN)
- Validate against contracts
- Move to next assertion

=== 6. Failure Handling
- Check retry policy
- Attempt retry if allowed
- Halt if max retries exceeded
- Report clear error messages

== Benefits

- *Clear Communication*: Every interaction documented
- *Error Handling*: Explicit failure paths
- *Stateless Agents*: Everything in state + contracts
- *Debuggability*: Can trace any interaction
- *Reliability*: Recovery from any failure point
