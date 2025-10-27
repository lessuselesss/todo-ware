# Markdown Document Validation
#
# Defines contracts for markdown document structure including:
# - YAML frontmatter
# - Heading hierarchy
# - Required sections
# - Code blocks

{
  # YAML frontmatter contract
  # Must be valid YAML enclosed in --- delimiters
  Frontmatter = {
    _ | doc "YAML frontmatter metadata at the top of markdown file",
  },

  # Markdown heading levels (1-6)
  HeadingLevel = std.contract.from_predicate (fun level =>
    std.is_number level && level >= 1 && level <= 6
  ) | doc "Heading level between 1 and 6 (H1 through H6)",

  # Markdown section structure
  Section = {
    level | HeadingLevel,
    title | String,
    content | String,
    subsections | Array Section | optional,
  },

  # Code block with optional language
  CodeBlock = {
    language | String | optional,
    content | String,
  },

  # Markdown document structure
  MarkdownDocument = {
    frontmatter | Frontmatter | optional | doc "Optional YAML frontmatter",
    sections | Array Section | doc "Document sections by heading",

    # Optional metadata
    title | String | optional,
    description | String | optional,
  },

  # Validate frontmatter contains required fields
  has_frontmatter_fields = fun doc required_fields =>
    if std.record.has_field "frontmatter" doc then
      let fm = doc.frontmatter in
      std.array.all (fun field => std.record.has_field field fm) required_fields
    else
      false,

  # Validate document has required sections (by title)
  has_sections = fun doc required_sections =>
    let section_titles = std.array.map (fun s => s.title) doc.sections in
    std.array.all (fun req => std.array.any (fun title => title == req) section_titles) required_sections,

  # Check maximum heading level depth
  max_heading_level = fun sections =>
    let levels = std.array.map (fun s => s.level) sections in
    std.array.fold_right (fun a b => if a > b then a else b) 1 levels,

  # Validate heading hierarchy (no skipped levels)
  # H1 → H2 → H3 is valid
  # H1 → H3 is invalid (skips H2)
  validate_heading_hierarchy = fun sections =>
    let validate_level = fun section parent_level =>
      let current_level = section.level in
      let valid_child = current_level <= parent_level + 1 in
      let children_valid =
        if std.record.has_field "subsections" section then
          std.array.all (fun sub => validate_level sub current_level) section.subsections
        else
          true
      in
      valid_child && children_valid
    in
    std.array.all (fun s => validate_level s 0) sections,
}
