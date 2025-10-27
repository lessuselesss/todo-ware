# Assertions Document Schema
#
# Defines the structure for assertions.md files that follow RED-to-GREEN TDD methodology.
# Each assertion represents a test case with three phases: RED, GREEN, REFACTOR.

let ids = import "../validation/assertion-ids.ncl" in
let md = import "../validation/markdown.ncl" in

{
  # TDD Phase: RED
  # Write a failing test that defines expected behavior
  RedPhase = {
    test_code | String | doc "The failing test code",
    expected_failure | String | doc "Description of why/how the test should fail",
    explanation | String | optional | doc "Why we're testing this behavior",
  },

  # TDD Phase: GREEN
  # Minimal implementation to make the test pass
  GreenPhase = {
    implementation | String | doc "Description of minimal code to pass test",
    test_passes | Bool | default = true | doc "Confirmation that test now passes",
  },

  # TDD Phase: REFACTOR (optional)
  # Improve code while keeping tests green
  RefactorPhase = {
    improvements | String | doc "Code improvements made",
    tests_still_pass | Bool | default = true | doc "Confirmation tests still pass",
  },

  # Single assertion with TDD phases
  Assertion = {
    id | ids.AssertionId | doc "Assertion ID (e.g., AUTH-001--A3)",
    task_id | ids.TaskId | doc "Parent task ID extracted from assertion ID",
    description | String | doc "What this assertion tests",

    red | RedPhase | doc "RED phase: Write failing test",
    green | GreenPhase | doc "GREEN phase: Minimal implementation",
    refactor | RefactorPhase | optional | doc "REFACTOR phase: Optional improvements",
  },

  # Frontmatter for assertions.md
  AssertionsFrontmatter = {
    parent_task | ids.TaskId | optional | doc "Primary task this file covers",
    methodology | String | default = "RED-to-GREEN" | doc "TDD methodology",
    description | String | optional | doc "Overview of what's being tested",
  },

  # Complete assertions.md document
  AssertionsDocument = {
    frontmatter | AssertionsFrontmatter | doc "YAML frontmatter metadata",
    assertions | Array Assertion | doc "List of TDD assertions",
  },

  # Validate assertion IDs match their task_id field
  validate_assertion_ids = fun assertions =>
    std.array.all (fun a =>
      ids.task_id_from_assertion a.id == a.task_id
    ) assertions,

  # Group assertions by task
  group_by_task = fun assertions =>
    let tasks = std.array.map (fun a => a.task_id) assertions
      |> std.array.uniq
    in
    std.array.map (fun task_id => {
      task = task_id,
      assertions = std.array.filter (fun a => a.task_id == task_id) assertions,
    }) tasks,

  # Count assertions per task
  count_assertions = fun assertions task_id =>
    std.array.filter (fun a => a.task_id == task_id) assertions
    |> std.array.length,

  # Check if all assertions have completed all phases
  all_phases_complete = fun assertions =>
    std.array.all (fun a =>
      std.record.has_field "red" a &&
      std.record.has_field "green" a
    ) assertions,
}
