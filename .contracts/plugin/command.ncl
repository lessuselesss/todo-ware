# Command File Schema
#
# Defines the structure for Claude Code command files (commands/*.md)
# These files define slash commands available in the kiro-scaffold plugin.

let md = import "../validation/markdown.ncl" in

{
  # Command frontmatter (YAML)
  CommandFrontmatter = {
    name | String | doc "Command name (without slash, e.g., 'kiro-scope')",
    description | String | doc "Short description of what the command does",
    aliases | Array String | default = [] | doc "Alternative names for this command",

    # Optional metadata
    category | String | optional | doc "Command category (e.g., 'scaffolding', 'validation')",
    version | String | optional | doc "Command version",
  },

  # Command argument
  CommandArgument = {
    name | String | doc "Argument name",
    description | String | doc "What this argument does",
    required | Bool | default = true | doc "Is this argument required?",
    type | std.enum.TagOrString | [| 'string, 'number, 'boolean, 'path |]
      | default = 'string
      | doc "Argument type",
    default | String | optional | doc "Default value if not provided",
  },

  # Command flag (optional argument)
  CommandFlag = {
    name | String | doc "Flag name (without --, e.g., 'from-task')",
    description | String | doc "What this flag does",
    type | std.enum.TagOrString | [| 'string, 'number, 'boolean, 'path |]
      | default = 'string
      | doc "Flag value type",
    default | String | optional | doc "Default value if flag not provided",
  },

  # Usage example
  CommandExample = {
    description | String | doc "What this example demonstrates",
    command | String | doc "Example command invocation",
    explanation | String | optional | doc "Additional context about example",
  },

  # Required sections for command documentation
  RequiredSections = [
    "Usage",
    "Arguments",
    "Examples",
    "What Gets Created",  # For commands that create files/dirs
  ],

  # Complete command.md document
  CommandDocument = {
    frontmatter | CommandFrontmatter | doc "YAML frontmatter",

    # Command documentation sections
    description_full | String | doc "Detailed description of what command does",

    usage | {
      syntax | String | doc "Command syntax (e.g., '/kiro-scope <path> [flags]')",
      notes | String | optional | doc "Usage notes or best practices",
    },

    arguments | Array CommandArgument | default = [] | doc "Positional arguments",
    flags | Array CommandFlag | default = [] | doc "Optional flags",

    examples | Array CommandExample | doc "Usage examples (minimum 2)",

    # For commands that create/modify files
    output | {
      description | String | doc "What files/directories are created",
      structure | String | optional | doc "File structure diagram",
    } | optional,

    # Additional sections
    notes | String | optional | doc "Important notes, caveats, warnings",
    see_also | Array String | default = [] | doc "Related commands or docs",
  },

  # Validate command has required sections
  validate_required_sections = fun doc =>
    std.record.has_field "usage" doc &&
    std.record.has_field "examples" doc,

  # Validate examples are sufficient (at least 2)
  validate_examples = fun doc =>
    if std.record.has_field "examples" doc then
      std.array.length doc.examples >= 2
    else
      false,

  # Check if command creates files (has output section)
  creates_files = fun doc =>
    std.record.has_field "output" doc,

  # List all argument names (for validation)
  list_argument_names = fun doc =>
    if std.record.has_field "arguments" doc then
      std.array.map (fun arg => arg.name) doc.arguments
    else
      [],

  # List all flag names (for validation)
  list_flag_names = fun doc =>
    if std.record.has_field "flags" doc then
      std.array.map (fun flag => flag.name) doc.flags
    else
      [],

  # Generate usage string from document
  generate_usage = fun doc =>
    let cmd_name = doc.frontmatter.name in
    let args = list_argument_names doc in
    let flags = list_flag_names doc in
    let arg_str = std.array.fold_right (fun a b => a ++ " " ++ b) "" (std.array.map (fun a => "<" ++ a ++ ">") args) in
    let flag_str = if std.array.length flags > 0 then " [flags]" else "" in
    "/" ++ cmd_name ++ arg_str ++ flag_str,
}
