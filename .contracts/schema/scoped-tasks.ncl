# Scoped Tasks Document Schema
#
# Defines the structure for scoped-tasks.md files which contain
# tasks decomposed from master .kiro/spec/tasks.md.

let ids = import "../validation/assertion-ids.ncl" in
let trace = import "../validation/traceability.ncl" in

{
  # A single scoped task
  ScopedTask = {
    id | ids.TaskId | doc "Task ID (e.g., AUTH-001)",

    # Traceability to master specs
    parent_requirement | String | doc "Parent requirement ID (e.g., REQ-002)",
    parent_design | String | doc "Parent design ID (e.g., DES-003)",
    decomposed_from | String | default = ".kiro/spec/tasks.md" | doc "Source specification file",

    # Task definition
    description | String | doc "What needs to be implemented",
    acceptance_criteria | Array String | doc "High-level assertions (decomposed into detailed assertions.md)",

    # Dependencies and planning
    dependencies | Array ids.TaskId | default = [] | doc "Other tasks this depends on",
    estimated_effort | String | optional | doc "Time estimate (e.g., '3 hours')",

    # Status tracking
    status | std.enum.TagOrString | [| 'pending, 'in_progress, 'completed, 'blocked |]
      | default = 'pending
      | doc "Current task status",
  },

  # Frontmatter for scoped-tasks.md
  ScopedTasksFrontmatter = {
    decomposed_from | String | default = ".kiro/spec/tasks.md" | doc "Source file path",
    parent_tasks | Array ids.TaskId | doc "Master task IDs this scope implements",
    module | String | doc "Module name (e.g., 'auth', 'api')",
    scope_path | String | optional | doc "File system path to this scope",
  },

  # Complete scoped-tasks.md document
  ScopedTasksDocument = {
    frontmatter | ScopedTasksFrontmatter | doc "YAML frontmatter metadata",
    tasks | Array ScopedTask | doc "List of scoped tasks",
  },

  # Validate that all tasks reference the same decomposed_from source
  validate_source_consistency = fun doc =>
    if std.record.has_field "frontmatter" doc && std.record.has_field "tasks" doc then
      let source = doc.frontmatter.decomposed_from in
      std.array.all (fun task =>
        task.decomposed_from == source
      ) doc.tasks
    else
      true,

  # Check that frontmatter parent_tasks matches task IDs in document
  validate_parent_tasks = fun doc =>
    if std.record.has_field "frontmatter" doc && std.record.has_field "tasks" doc then
      let declared_parents = doc.frontmatter.parent_tasks in
      let actual_ids = std.array.map (fun t => t.id) doc.tasks in
      # All declared parents should appear in tasks
      std.array.all (fun pid =>
        std.array.any (fun tid => tid == pid) actual_ids
      ) declared_parents
    else
      true,

  # Find tasks with unresolved dependencies
  find_tasks_with_missing_deps = fun doc =>
    if std.record.has_field "tasks" doc then
      let all_task_ids = std.array.map (fun t => t.id) doc.tasks in
      std.array.filter (fun task =>
        # Check if any dependency is not in the task list
        std.array.any (fun dep =>
          not (std.array.any (fun tid => tid == dep) all_task_ids)
        ) task.dependencies
      ) doc.tasks
    else
      [],

  # Get tasks with no dependencies (can be started immediately)
  find_ready_tasks = fun doc =>
    if std.record.has_field "tasks" doc then
      std.array.filter (fun task =>
        std.array.length task.dependencies == 0 && task.status == 'pending
      ) doc.tasks
    else
      [],

  # Calculate critical path (tasks that must be done sequentially)
  # This is a simplified version - real critical path needs topological sort
  find_critical_path = fun doc =>
    if std.record.has_field "tasks" doc then
      let max_depth = fun task depth visited =>
        if std.array.any (fun v => v == task.id) visited then
          depth  # Cycle detection
        else
          let new_visited = std.array.prepend task.id visited in
          let dep_depths = std.array.map (fun dep_id =>
            let dep_task = std.array.find (fun t => t.id == dep_id) doc.tasks in
            if dep_task != null then
              max_depth dep_task (depth + 1) new_visited
            else
              depth
          ) task.dependencies in
          if std.array.length dep_depths > 0 then
            std.array.fold_right (fun a b => if a > b then a else b) depth dep_depths
          else
            depth
      in
      std.array.map (fun task => {
        task = task.id,
        depth = max_depth task 0 [],
      }) doc.tasks
    else
      [],
}
