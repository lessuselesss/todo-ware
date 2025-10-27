# Context Document Schema
#
# Defines the structure for context.md files which explain how a module
# fits into the overall project architecture.

let md = import "../validation/markdown.ncl" in

{
  # Required sections for context.md
  RequiredSections = [
    "Purpose",
    "Position in Architecture",
    "Dependencies",
    "Dependents",
    "Key Interfaces",
    "Design Decisions",
    "Testing Strategy",
  ],

  # Module dependencies
  ModuleDependency = {
    module | String | doc "Module or file being depended upon",
    reason | String | doc "Why this dependency exists",
    type | std.enum.TagOrString | [| 'internal, 'external, 'stdlib |]
      | doc "Dependency type",
  },

  # Module dependents (what depends on this module)
  ModuleDependent = {
    module | String | doc "Module or file that depends on this",
    usage | String | doc "How they use this module",
  },

  # Interface definition (exports)
  InterfaceExport = {
    name | String | doc "Function, class, or symbol name",
    signature | String | doc "Type signature or interface",
    description | String | doc "What it does",
  },

  # Interface definition (imports)
  InterfaceImport = {
    name | String | doc "Imported symbol",
    from_module | String | doc "Source module",
    description | String | doc "Why we import this",
  },

  # Design decision record
  DesignDecision = {
    decision | String | doc "What was decided",
    rationale | String | doc "Why this decision was made",
    alternatives | String | optional | doc "Other options considered",
    tradeoffs | String | optional | doc "Tradeoffs of this decision",
  },

  # Testing strategy
  TestingStrategy = {
    unit_tests | String | doc "Unit testing approach",
    integration_tests | String | doc "Integration testing approach",
    e2e_tests | String | optional | doc "End-to-end testing approach",
    coverage_target | Number | default = 80 | doc "Target code coverage percentage",
  },

  # Frontmatter for context.md
  ContextFrontmatter = {
    module_name | String | doc "Name of this module (e.g., 'auth')",
    scope_path | String | doc "File system path (e.g., 'src/auth')",
    parent_spec | String | optional | doc "Reference to master spec",
  },

  # Complete context.md document
  ContextDocument = {
    frontmatter | ContextFrontmatter | doc "YAML frontmatter metadata",

    # Required sections (as structured data)
    purpose | String | doc "What this module does and why it exists",
    architecture | String | doc "How this module fits in the overall system (ASCII diagram encouraged)",

    dependencies | {
      internal | Array ModuleDependency | default = [] | doc "Internal project dependencies",
      external | Array ModuleDependency | default = [] | doc "External library dependencies",
      stdlib | Array ModuleDependency | default = [] | doc "Standard library dependencies",
    },

    dependents | Array ModuleDependent | default = [] | doc "What depends on this module",

    interfaces | {
      exports | Array InterfaceExport | default = [] | doc "What this module exports",
      imports | Array InterfaceImport | default = [] | doc "What this module imports",
    },

    design_decisions | Array DesignDecision | default = [] | doc "Key design decisions",

    testing_strategy | TestingStrategy | doc "How to test this module",
  },

  # Validate that context has all required sections
  validate_required_sections = fun doc =>
    std.record.has_field "purpose" doc &&
    std.record.has_field "architecture" doc &&
    std.record.has_field "dependencies" doc &&
    std.record.has_field "dependents" doc &&
    std.record.has_field "interfaces" doc &&
    std.record.has_field "design_decisions" doc &&
    std.record.has_field "testing_strategy" doc,

  # Check if module has external dependencies
  has_external_deps = fun doc =>
    if std.record.has_field "dependencies" doc then
      std.array.length doc.dependencies.external > 0
    else
      false,

  # List all exported interface names
  list_exports = fun doc =>
    if std.record.has_field "interfaces" doc then
      std.array.map (fun exp => exp.name) doc.interfaces.exports
    else
      [],

  # Check coverage target is reasonable (50-100%)
  validate_coverage_target = fun doc =>
    if std.record.has_field "testing_strategy" doc then
      let target = doc.testing_strategy.coverage_target in
      target >= 50 && target <= 100
    else
      true,
}
