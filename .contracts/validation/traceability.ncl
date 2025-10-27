# Traceability Validation
#
# Validates cross-references between specification documents:
# - Requirements → Design → Tasks → Assertions
# - Scoped tasks reference master tasks
# - Assertions reference valid tasks

let ids = import "assertion-ids.ncl" in

{
  # Reference to parent specification
  ParentReference = {
    file_path | String | doc "Relative path to parent spec (e.g., ../../.kiro/spec/tasks.md)",
    ids | Array ids.TaskId | doc "List of parent task IDs this scope implements",
  },

  # Traceability link from scoped task to master spec
  TaskTraceability = {
    task_id | ids.TaskId | doc "This task's ID (e.g., AUTH-001)",
    parent_requirement | String | doc "Parent requirement ID (e.g., REQ-002)",
    parent_design | String | doc "Parent design ID (e.g., DES-003)",
    decomposed_from | String | doc "Source file (e.g., .kiro/spec/tasks.md)",
  },

  # Validate that assertion IDs reference valid task IDs
  # Returns true if all assertions reference tasks that exist
  validate_assertion_references = fun assertions tasks =>
    let task_ids = std.array.map (fun t => t.id) tasks in
    let assertion_task_ids = std.array.map (fun a => ids.task_id_from_assertion a.id) assertions in
    std.array.all (fun tid => std.array.any (fun valid => tid == valid) task_ids) assertion_task_ids,

  # Check that scoped tasks reference valid parent tasks
  validate_scoped_task_references = fun scoped_tasks parent_tasks =>
    let parent_ids = std.array.map (fun t => t.id) parent_tasks in
    std.array.all (fun st =>
      # Scoped task ID should appear in parent tasks
      std.array.any (fun pid => pid == st.task_id) parent_ids
    ) scoped_tasks,

  # Validate that a scope's parent reference is consistent
  # Ensures all tasks in a scope reference the same parent spec
  validate_parent_consistency = fun scope_doc =>
    if std.record.has_field "frontmatter" scope_doc then
      let fm = scope_doc.frontmatter in
      if std.record.has_field "decomposed_from" fm && std.record.has_field "tasks" scope_doc then
        let source = fm.decomposed_from in
        # All tasks should reference the same source
        std.array.all (fun task =>
          if std.record.has_field "decomposed_from" task then
            task.decomposed_from == source
          else
            true
        ) scope_doc.tasks
      else
        true
    else
      true,

  # Extract all task IDs referenced by assertions
  extract_referenced_tasks = fun assertions =>
    std.array.map (fun a => ids.task_id_from_assertion a.id) assertions
    |> std.array.uniq,

  # Check for orphaned assertions (no matching task)
  find_orphaned_assertions = fun assertions tasks =>
    let task_ids = std.array.map (fun t => t.id) tasks in
    std.array.filter (fun a =>
      let task_id = ids.task_id_from_assertion a.id in
      not (std.array.any (fun tid => tid == task_id) task_ids)
    ) assertions,

  # Check for tasks without assertions
  find_tasks_without_assertions = fun tasks assertions =>
    let referenced = extract_referenced_tasks assertions in
    std.array.filter (fun t =>
      not (std.array.any (fun ref => ref == t.id) referenced)
    ) tasks,
}
