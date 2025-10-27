# Agent File Schema
#
# Defines the structure for Claude Code agent files (agents/*.md)
# These files define specialized AI agents in the kiro-scaffold plugin.

let md = import "../validation/markdown.ncl" in

{
  # Agent frontmatter (YAML)
  AgentFrontmatter = {
    description | String | doc "Short description of agent's purpose",
    capabilities | Array String | doc "List of agent capabilities/skills",

    # Optional metadata
    category | String | optional | doc "Agent category (e.g., 'architecture', 'testing')",
    version | String | optional | doc "Agent version",
    model_preference | String | optional | doc "Preferred model (e.g., 'claude-3-opus')",
  },

  # When to invoke this agent
  InvocationTrigger = {
    condition | String | doc "Condition that should trigger this agent",
    keywords | Array String | default = [] | doc "Keywords that suggest using this agent",
    example | String | optional | doc "Example user message that would trigger this agent",
  },

  # Agent capability description
  Capability = {
    name | String | doc "Capability name",
    description | String | doc "What this capability enables",
    example | String | optional | doc "Example of capability in action",
  },

  # Required sections for agent documentation
  RequiredSections = [
    "Role and Expertise",
    "When to Invoke This Agent",
    "Capabilities",
    "Workflow",
    "Output Format",
  ],

  # Agent workflow step
  WorkflowStep = {
    step | Number | doc "Step number in workflow",
    title | String | doc "Step title",
    description | String | doc "What happens in this step",
    tools | Array String | default = [] | doc "Tools used in this step",
  },

  # Output format specification
  OutputFormat = {
    type | std.enum.TagOrString | [| 'markdown, 'json, 'structured_data, 'files |]
      | doc "Type of output produced",
    description | String | doc "Description of output format",
    example | String | optional | doc "Example output",
  },

  # Complete agent.md document
  AgentDocument = {
    frontmatter | AgentFrontmatter | doc "YAML frontmatter",

    # Agent documentation sections
    role | String | doc "Agent's role and area of expertise",

    invocation | {
      when | String | doc "When Claude should invoke this agent",
      triggers | Array InvocationTrigger | doc "Specific trigger conditions",
    },

    capabilities | Array Capability | doc "Detailed capabilities (from frontmatter list)",

    workflow | {
      description | String | doc "Overview of agent's workflow",
      steps | Array WorkflowStep | doc "Ordered workflow steps",
    },

    output_format | OutputFormat | doc "What the agent produces",

    # Optional sections
    examples | Array String | default = [] | doc "Example interactions",
    best_practices | String | optional | doc "Best practices for using this agent",
    limitations | String | optional | doc "Known limitations or constraints",
    see_also | Array String | default = [] | doc "Related agents or commands",
  },

  # Validate agent has required sections
  validate_required_sections = fun doc =>
    std.record.has_field "role" doc &&
    std.record.has_field "invocation" doc &&
    std.record.has_field "capabilities" doc &&
    std.record.has_field "workflow" doc &&
    std.record.has_field "output_format" doc,

  # Check capabilities match frontmatter
  validate_capabilities_match = fun doc =>
    if std.record.has_field "frontmatter" doc && std.record.has_field "capabilities" doc then
      let fm_caps = doc.frontmatter.capabilities in
      let doc_caps = std.array.map (fun c => c.name) doc.capabilities in
      std.array.length fm_caps == std.array.length doc_caps
    else
      false,

  # List all tools used by agent
  list_tools_used = fun doc =>
    if std.record.has_field "workflow" doc then
      std.array.fold_right
        (fun step acc => std.array.concat step.tools acc)
        []
        doc.workflow.steps
      |> std.array.uniq
    else
      [],

  # Count workflow steps
  count_workflow_steps = fun doc =>
    if std.record.has_field "workflow" doc then
      std.array.length doc.workflow.steps
    else
      0,

  # Get agent name from capabilities
  infer_agent_name = fun doc =>
    if std.record.has_field "frontmatter" doc then
      # Extract from description or infer from capabilities
      let desc = doc.frontmatter.description in
      std.string.split " " desc
      |> std.array.at 0
    else
      "Unknown",
}
