# Assertion ID Validation
#
# Defines and validates the kiro assertion ID convention:
# - Task IDs: MODULE-### (e.g., AUTH-001)
# - Assertion IDs: TASK-###--A# with DOUBLE-DASH separator (e.g., AUTH-001--A3)
#
# The double-dash separator is critical for unambiguous parsing and ensures
# clear distinction between task ID and assertion number.

{
  # Task ID pattern: MODULE-###
  # Examples: AUTH-001, API-042, DATA-003
  TaskId = std.contract.from_predicate (fun value =>
    if std.is_string value then
      std.string.is_match "^[A-Z]+-[0-9]{3}$" value
    else
      false
  ) | doc m%"
    A valid task ID in the format MODULE-### where:
    - MODULE is uppercase letters (e.g., AUTH, API, DATA)
    - ### is a 3-digit number (e.g., 001, 042, 999)

    Examples:
      - AUTH-001 ✓
      - API-042 ✓
      - DATA-003 ✓
      - auth-001 ✗ (lowercase module)
      - AUTH-1 ✗ (not 3 digits)
      - AUTH-1000 ✗ (too many digits)
  "%,

  # Assertion ID pattern: TASK-###--A# (DOUBLE-DASH!)
  # Examples: AUTH-001--A1, API-042--A15
  AssertionId = std.contract.from_predicate (fun value =>
    if std.is_string value then
      std.string.is_match "^[A-Z]+-[0-9]{3}--A[0-9]+$" value
    else
      false
  ) | doc m%"
    A valid assertion ID in the format TASK-###--A# where:
    - TASK-### follows TaskId format
    - -- is a DOUBLE-DASH separator (critical for parsing!)
    - A# is assertion number (e.g., A1, A5, A12)

    Examples:
      - AUTH-001--A1 ✓
      - API-042--A15 ✓
      - DATA-003--A7 ✓
      - AUTH-001-A1 ✗ (single dash)
      - AUTH-001_A1 ✗ (underscore)
      - auth-001--a1 ✗ (lowercase)
  "%,

  # Parse task ID from assertion ID
  # Example: "AUTH-001--A3" → "AUTH-001"
  task_id_from_assertion = fun assertion_id =>
    let parts = std.string.split "--" assertion_id in
    std.array.at 0 parts,

  # Parse assertion number from assertion ID
  # Example: "AUTH-001--A3" → "A3"
  assertion_number = fun assertion_id =>
    let parts = std.string.split "--" assertion_id in
    std.array.at 1 parts,

  # Parse assertion ID into structured components
  # Example: "AUTH-001--A3" → { task: "AUTH-001", assertion: "A3", full: "AUTH-001--A3" }
  parse_assertion_id = fun assertion_id => {
    task = task_id_from_assertion assertion_id,
    assertion = assertion_number assertion_id,
    full = assertion_id,
  },

  # Validate that an assertion ID matches its parent task
  # Example: assertion_matches_task "AUTH-001--A3" "AUTH-001" → true
  assertion_matches_task = fun assertion_id task_id =>
    std.string.starts_with assertion_id (task_id ++ "--"),

  # Generate assertion ID from task and number
  # Example: make_assertion_id "AUTH-001" 3 → "AUTH-001--A3"
  make_assertion_id = fun task_id assertion_num =>
    task_id ++ "--A" ++ std.string.from_number assertion_num,
}
