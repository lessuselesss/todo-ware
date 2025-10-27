# CLAUDE.md Document Schema
#
# Defines the structure for CLAUDE.md files which contain implementation
# workflow details and current status for a module.

let ids = import "../validation/assertion-ids.ncl" in

{
  # Required sections for CLAUDE.md
  RequiredSections = [
    "Workflow",
    "Current Status",
    "Key Decisions",
  ],

  # Workflow step
  WorkflowStep = {
    step_number | Number | doc "Step order (1, 2, 3...)",
    description | String | doc "What to do in this step",
    reference | String | optional | doc "Reference to .kiro-scope/ file (e.g., 'scoped-tasks.md', 'assertions.md')",
  },

  # Task status entry
  TaskStatus = {
    task_id | ids.TaskId | doc "Task identifier",
    status | std.enum.TagOrString | [| 'completed, 'in_progress, 'pending, 'blocked |]
      | doc "Current status",
    notes | String | optional | doc "Additional context",
  },

  # Key decision record (similar to ADR)
  KeyDecision = {
    title | String | doc "Short decision title",
    description | String | doc "What was decided and why",
    date | String | optional | doc "When decision was made (YYYY-MM-DD)",
    impact | String | optional | doc "Impact on implementation",
  },

  # Frontmatter for CLAUDE.md
  ClaudeMdFrontmatter = {
    module_name | String | doc "Module name (matches context.md)",
    scope_path | String | doc "File system path (e.g., 'src/auth')",
    last_updated | String | optional | doc "Last update date (YYYY-MM-DD)",
  },

  # Complete CLAUDE.md document
  ClaudeMdDocument = {
    frontmatter | ClaudeMdFrontmatter | doc "YAML frontmatter metadata",

    # Workflow section
    workflow | {
      description | String | doc "Overview of implementation workflow",
      steps | Array WorkflowStep | doc "Ordered workflow steps",
      kiro_scope_reference | String | default = ".kiro-scope/" | doc "Path to scoped specs",
    },

    # Current status section
    current_status | {
      summary | String | doc "High-level status summary",
      tasks | Array TaskStatus | doc "Status of each task",
      next_steps | Array String | default = [] | doc "What to do next",
    },

    # Key decisions section
    key_decisions | Array KeyDecision | default = [] | doc "Important implementation decisions",

    # Optional sections
    notes | String | optional | doc "Additional implementation notes",
    troubleshooting | String | optional | doc "Common issues and solutions",
  },

  # Validate workflow references .kiro-scope/
  validate_workflow_references = fun doc =>
    if std.record.has_field "workflow" doc then
      std.record.has_field "kiro_scope_reference" doc.workflow
    else
      false,

  # Check if any tasks are in progress
  has_active_tasks = fun doc =>
    if std.record.has_field "current_status" doc then
      std.array.any (fun task =>
        task.status == 'in_progress
      ) doc.current_status.tasks
    else
      false,

  # Get completion percentage
  completion_percentage = fun doc =>
    if std.record.has_field "current_status" doc then
      let tasks = doc.current_status.tasks in
      let total = std.array.length tasks in
      if total > 0 then
        let completed = std.array.filter (fun t => t.status == 'completed) tasks
          |> std.array.length
        in
        (completed * 100) / total
      else
        0
    else
      0,

  # Find blocked tasks
  find_blocked_tasks = fun doc =>
    if std.record.has_field "current_status" doc then
      std.array.filter (fun task =>
        task.status == 'blocked
      ) doc.current_status.tasks
    else
      [],

  # Get next task to work on (first pending task)
  get_next_task = fun doc =>
    if std.record.has_field "current_status" doc then
      std.array.find (fun task =>
        task.status == 'pending
      ) doc.current_status.tasks
    else
      null,
}
