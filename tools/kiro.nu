# Kiro Nushell Utility Library
# Reusable functions for spec-driven development workflows

# ============================================================================
# SPEC VALIDATION FUNCTIONS
# ============================================================================

# Check if a spec file has meaningful content (>3 non-empty, non-header lines)
export def validate-spec-file [file: path] {
  if not ($file | path exists) {
    return {status: "missing", file: $file, lines: 0}
  }

  let content_lines = (
    open $file
    | lines
    | where {|line|
        let trimmed = ($line | str trim)
        $trimmed != "" and not ($trimmed | str starts-with "#")
      }
    | length
  )

  if $content_lines < 3 {
    {status: "incomplete", file: $file, lines: $content_lines}
  } else {
    {status: "ok", file: $file, lines: $content_lines}
  }
}

# Check all three required spec files
export def check-all-specs [] {
  let spec_dir = ".kiro/spec"
  let required = ["requirements.md", "design.md", "tasks.md"]

  if not ($spec_dir | path exists) {
    return {
      valid: false,
      message: $"($spec_dir) directory does not exist",
      missing: $required,
      incomplete: []
    }
  }

  let results = ($required | each {|file|
    validate-spec-file $"($spec_dir)/($file)"
  })

  let missing = ($results | where status == "missing" | get file | each {|f| $f | path basename})
  let incomplete = ($results | where status == "incomplete" | get file | each {|f| $f | path basename})

  {
    valid: (($missing | length) == 0 and ($incomplete | length) == 0),
    missing: $missing,
    incomplete: $incomplete,
    details: $results
  }
}

# Get list of incomplete or missing spec files
export def get-incomplete-specs [] {
  let check = (check-all-specs)

  if $check.valid {
    []
  } else {
    [
      ...(if ($check.missing | length) > 0 {
        $check.missing | each {|f| {file: $f, reason: "missing"}}
      } else { [] }),
      ...(if ($check.incomplete | length) > 0 {
        $check.incomplete | each {|f| {file: $f, reason: "incomplete"}}
      } else { [] })
    ]
  }
}

# ============================================================================
# MARKDOWN PARSING FUNCTIONS
# ============================================================================

# Extract YAML frontmatter from markdown file
export def parse-frontmatter [file: path] {
  if not ($file | path exists) {
    return null
  }

  let content = (open $file | lines)

  # Check if starts with ---
  if ($content | first) != "---" {
    return null
  }

  # Find closing ---
  let frontmatter_lines = (
    $content
    | skip 1
    | take until {|line| $line == "---"}
  )

  if ($frontmatter_lines | length) == 0 {
    return null
  }

  # Parse as YAML
  try {
    $frontmatter_lines | str join "\n" | from yaml
  } catch {
    null
  }
}

# Get markdown sections by heading level
export def get-markdown-sections [file: path, --level: int = 1] {
  if not ($file | path exists) {
    return []
  }

  let heading_prefix = ("#" | str repeat $level) + " "

  open $file
  | lines
  | where {|line| $line | str starts-with $heading_prefix}
  | each {|line| $line | str replace $heading_prefix ""}
}

# Extract code blocks from markdown
export def extract-code-blocks [file: path, --language: string = ""] {
  if not ($file | path exists) {
    return []
  }

  let lines = (open $file | lines)
  mut blocks = []
  mut in_block = false
  mut current_block = []
  mut current_lang = ""

  for line in $lines {
    if ($line | str starts-with "```") {
      if $in_block {
        # End of block
        $blocks = ($blocks | append {
          language: $current_lang,
          code: ($current_block | str join "\n")
        })
        $in_block = false
        $current_block = []
        $current_lang = ""
      } else {
        # Start of block
        $in_block = true
        $current_lang = ($line | str replace "```" "" | str trim)
      }
    } else if $in_block {
      $current_block = ($current_block | append $line)
    }
  }

  if $language == "" {
    $blocks
  } else {
    $blocks | where language == $language
  }
}

# Count meaningful lines (non-empty, non-comment)
export def count-meaningful-lines [file: path] {
  if not ($file | path exists) {
    return 0
  }

  open $file
  | lines
  | where {|line|
      let trimmed = ($line | str trim)
      $trimmed != "" and not ($trimmed | str starts-with "#")
    }
  | length
}

# ============================================================================
# CONTRACT COVERAGE FUNCTIONS
# ============================================================================

# List all nickel contract files
export def list-contracts [] {
  if not (".contracts" | path exists) {
    return []
  }

  glob .contracts/**/*.ncl
  | each {|f|
      $f | str replace ".contracts/" "" | str replace ".ncl" ""
    }
}

# List all source files
export def list-sources [--extensions: list<string> = ["js", "ts", "py", "rs"]] {
  if not ("src" | path exists) {
    return []
  }

  let patterns = ($extensions | each {|ext| $"src/**/*.($ext)"})

  $patterns
  | each {|pattern| glob $pattern}
  | flatten
  | each {|f| $f | str replace "src/" "" | path parse | get stem}
  | uniq
}

# Check contract coverage
export def check-contract-coverage [] {
  let contracts = (list-contracts)
  let sources = (list-sources)

  let covered = ($sources | where {|s| $s in $contracts})
  let missing = ($sources | where {|s| not ($s in $contracts)})

  {
    total: ($sources | length),
    covered: ($covered | length),
    coverage_percent: (if ($sources | length) > 0 {
      (($covered | length) / ($sources | length) * 100) | math round
    } else {
      0
    }),
    missing_contracts: $missing
  }
}

# Find sources without contracts
export def find-missing-contracts [] {
  let coverage = (check-contract-coverage)
  $coverage.missing_contracts
}

# ============================================================================
# TEST COVERAGE FUNCTIONS
# ============================================================================

# Find test file for an implementation file
export def find-test-file [impl_file: path] {
  let dir = ($impl_file | path dirname)
  let filename = ($impl_file | path basename)
  let stem = ($filename | path parse | get stem)
  let ext = ($filename | path parse | get extension)

  # Test patterns to check
  let patterns = [
    $"($dir)/($stem).test.($ext)",
    $"($dir)/($stem).spec.($ext)",
    $"($dir)/__tests__/($stem).test.($ext)",
    $"($dir)/__tests__/($stem).spec.($ext)",
    ($"($dir)/($stem).test.($ext)" | str replace "src/" "tests/"),
    ($"($dir)/($stem).spec.($ext)" | str replace "src/" "tests/")
  ]

  let found = ($patterns | where {|p| $p | path exists} | first)

  if ($found | is-empty) {
    null
  } else {
    $found
  }
}

# Check if test file exists for implementation
export def check-test-exists [impl_file: path] {
  (find-test-file $impl_file) != null
}

# Validate test file has actual test content
export def validate-test-content [test_file: path] {
  if not ($test_file | path exists) {
    return {valid: false, reason: "file not found"}
  }

  let content_lines = (
    open $test_file
    | lines
    | where {|line|
        let trimmed = ($line | str trim)
        $trimmed != ""
        and not ($trimmed | str starts-with "#")
        and not ($trimmed | str starts-with "//")
        and not ($trimmed | str starts-with "import")
        and not ($trimmed | str starts-with "require")
      }
    | length
  )

  if $content_lines < 5 {
    {valid: false, reason: "insufficient test content", lines: $content_lines}
  } else {
    {valid: true, lines: $content_lines}
  }
}

# ============================================================================
# DOCUMENTATION SYNC FUNCTIONS
# ============================================================================

# Get file age in seconds
export def get-file-age [file: path] {
  if not ($file | path exists) {
    return 999999
  }

  let modified = (ls $file | get modified | first)
  let now = (date now)

  ($now - $modified) / 1sec | into int
}

# Check if documentation is stale
export def check-docs-stale [--threshold: int = 3600] {
  let claude_age = (get-file-age "CLAUDE.md")
  let readme_age = (get-file-age "README.md")

  {
    claude_stale: $claude_age > $threshold,
    readme_stale: $readme_age > $threshold,
    claude_age_hours: ($claude_age / 3600 | math round),
    readme_age_hours: ($readme_age / 3600 | math round)
  }
}

# List files modified in last N hours
export def list-recent-changes [hours: int = 24] {
  let threshold_seconds = $hours * 3600

  glob **/*
  | where {|f| ($f | path exists) and ($f | path type) == "file"}
  | each {|f| {
      file: $f,
      age: (get-file-age $f)
    }}
  | where age < $threshold_seconds
  | sort-by age
}

# ============================================================================
# REPORT GENERATION FUNCTIONS
# ============================================================================

# Generate quality report
export def generate-quality-report [] {
  let spec_check = (check-all-specs)
  let contract_coverage = (check-contract-coverage)
  let docs_check = (check-docs-stale)

  {
    timestamp: (date now | format date "%Y-%m-%d %H:%M:%S"),
    specifications: {
      valid: $spec_check.valid,
      missing: $spec_check.missing,
      incomplete: $spec_check.incomplete
    },
    contracts: {
      total_sources: $contract_coverage.total,
      covered: $contract_coverage.covered,
      coverage_percent: $contract_coverage.coverage_percent,
      missing_count: ($contract_coverage.missing_contracts | length)
    },
    documentation: {
      claude_stale: $docs_check.claude_stale,
      readme_stale: $docs_check.readme_stale,
      claude_age_hours: $docs_check.claude_age_hours,
      readme_age_hours: $docs_check.readme_age_hours
    }
  }
}

# Format data as markdown table
export def format-as-table [] {
  to md
}

# Generate TODO list from missing items
export def generate-todo-list [] {
  mut todos = []

  # Check specs
  let spec_issues = (get-incomplete-specs)
  if ($spec_issues | length) > 0 {
    $todos = ($todos | append "## Specifications")
    for issue in $spec_issues {
      $todos = ($todos | append $"- [ ] ($issue.reason | str capitalize) spec file: ($issue.file)")
    }
    $todos = ($todos | append "")
  }

  # Check contracts
  let missing_contracts = (find-missing-contracts)
  if ($missing_contracts | length) > 0 {
    $todos = ($todos | append "## Contracts")
    for source in $missing_contracts {
      $todos = ($todos | append $"- [ ] Create contract for: ($source)")
    }
    $todos = ($todos | append "")
  }

  # Check docs
  let docs_stale = (check-docs-stale)
  if $docs_stale.claude_stale or $docs_stale.readme_stale {
    $todos = ($todos | append "## Documentation")
    if $docs_stale.claude_stale {
      $todos = ($todos | append $"- [ ] Update CLAUDE.md (($docs_stale.claude_age_hours) hours old)")
    }
    if $docs_stale.readme_stale {
      $todos = ($todos | append $"- [ ] Update README.md (($docs_stale.readme_age_hours) hours old)")
    }
    $todos = ($todos | append "")
  }

  if ($todos | length) == 0 {
    ["✅ All quality checks passed!"]
  } else {
    (["# Kiro Quality TODO List", ""] | append $todos)
  }
}

# ============================================================================
# NICKEL CONTRACT VALIDATION FUNCTIONS
# ============================================================================

# Validate assertion ID format using nickel contract
export def validate-assertion-id [id: string] {
  try {
    # Use nickel to validate the ID pattern
    let contract = ".contracts/validation/assertion-ids.ncl"

    if not ($contract | path exists) {
      return {valid: false, reason: "contract file not found"}
    }

    # Check pattern manually (nickel validation would require eval)
    let pattern = '^[A-Z]+-[0-9]{3}--A[0-9]+$'
    let matches = ($id | str contains --regex $pattern)

    if $matches {
      {valid: true, id: $id}
    } else {
      {valid: false, reason: "does not match TASK-###--A# pattern", id: $id}
    }
  } catch {
    {valid: false, reason: "validation error", id: $id}
  }
}

# Parse assertion ID into components (task + assertion number)
export def parse-assertion-id [id: string] {
  let parts = ($id | split row "--")

  if ($parts | length) != 2 {
    return null
  }

  {
    task: ($parts | get 0),
    assertion: ($parts | get 1),
    full: $id
  }
}

# Validate task ID format
export def validate-task-id [id: string] {
  let pattern = '^[A-Z]+-[0-9]{3}$'
  let matches = ($id | str contains --regex $pattern)

  if $matches {
    {valid: true, id: $id}
  } else {
    {valid: false, reason: "does not match MODULE-### pattern", id: $id}
  }
}

# Extract task ID from assertion ID
export def task-id-from-assertion [assertion_id: string] {
  let parsed = (parse-assertion-id $assertion_id)

  if $parsed == null {
    null
  } else {
    $parsed.task
  }
}

# Check if assertion ID matches a task ID
export def assertion-matches-task [assertion_id: string, task_id: string] {
  let parsed = (parse-assertion-id $assertion_id)

  if $parsed == null {
    false
  } else {
    $parsed.task == $task_id
  }
}

# Validate scope directory structure according to contracts
export def validate-scope-structure [path: string] {
  let has_claude_md = ($"($path)/CLAUDE.md" | path exists)
  let has_kiro_scope = ($"($path)/.kiro-scope" | path exists)

  if not $has_claude_md {
    return {
      valid: false,
      reason: "CLAUDE.md not found in parent directory",
      path: $path
    }
  }

  if not $has_kiro_scope {
    return {
      valid: false,
      reason: ".kiro-scope/ directory not found",
      path: $path
    }
  }

  # Check required files in .kiro-scope/
  let required_files = [
    "scoped-tasks.md",
    "assertions.md",
    "context.md"
  ]

  let missing = ($required_files | where {|f|
    not ($"($path)/.kiro-scope/($f)" | path exists)
  })

  if ($missing | length) > 0 {
    return {
      valid: false,
      reason: "missing required files in .kiro-scope/",
      missing_files: $missing,
      path: $path
    }
  }

  {
    valid: true,
    path: $path,
    has_contracts: ($"($path)/.kiro-scope/contracts" | path exists)
  }
}

# Find all scoped directories in project
export def find-scoped-directories [] {
  glob **/.kiro-scope
  | each {|scope_dir|
      let parent = ($scope_dir | path dirname)
      validate-scope-structure $parent
    }
}

# Validate assertions.md file structure
export def validate-assertions-file [file: path] {
  if not ($file | path exists) {
    return {valid: false, reason: "file not found"}
  }

  # Parse frontmatter
  let fm = (parse-frontmatter $file)

  if $fm == null {
    return {valid: false, reason: "missing or invalid frontmatter"}
  }

  # Check for required frontmatter fields
  if not ("parent_task" in ($fm | columns)) {
    return {valid: false, reason: "frontmatter missing 'parent_task' field"}
  }

  # Extract assertion IDs from content
  let content = (open $file | lines | str join "\n")

  # Look for assertion ID patterns (AUTH-001--A1, etc)
  let assertion_pattern = '[A-Z]+-[0-9]{3}--A[0-9]+'

  {
    valid: true,
    frontmatter: $fm,
    file: $file
  }
}

# Validate scoped-tasks.md file structure
export def validate-scoped-tasks-file [file: path] {
  if not ($file | path exists) {
    return {valid: false, reason: "file not found"}
  }

  let fm = (parse-frontmatter $file)

  if $fm == null {
    return {valid: false, reason: "missing or invalid frontmatter"}
  }

  # Check required frontmatter fields
  let required = ["decomposed_from", "parent_tasks", "module"]
  let missing = ($required | where {|field| not ($field in ($fm | columns))})

  if ($missing | length) > 0 {
    return {
      valid: false,
      reason: "frontmatter missing required fields",
      missing_fields: $missing
    }
  }

  {
    valid: true,
    frontmatter: $fm,
    file: $file
  }
}

# Validate context.md file structure
export def validate-context-file [file: path] {
  if not ($file | path exists) {
    return {valid: false, reason: "file not found"}
  }

  # Check for required sections
  let required_sections = [
    "Purpose",
    "Position in Architecture",
    "Dependencies",
    "Dependents",
    "Key Interfaces",
    "Design Decisions",
    "Testing Strategy"
  ]

  let sections = (get-markdown-sections $file --level 2)
  let missing = ($required_sections | where {|req| not ($req in $sections)})

  if ($missing | length) > 0 {
    return {
      valid: false,
      reason: "missing required sections",
      missing_sections: $missing
    }
  }

  {
    valid: true,
    sections: $sections,
    file: $file
  }
}

# Validate entire scope directory
export def validate-scope-full [path: string] {
  let structure = (validate-scope-structure $path)

  if not $structure.valid {
    return $structure
  }

  # Validate each required file
  let assertions = (validate-assertions-file $"($path)/.kiro-scope/assertions.md")
  let tasks = (validate-scoped-tasks-file $"($path)/.kiro-scope/scoped-tasks.md")
  let context = (validate-context-file $"($path)/.kiro-scope/context.md")

  let all_valid = $assertions.valid and $tasks.valid and $context.valid

  {
    valid: $all_valid,
    path: $path,
    structure: $structure,
    assertions: $assertions,
    tasks: $tasks,
    context: $context
  }
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Check if we're in a kiro project
export def is-kiro-project [] {
  ".kiro" | path exists
}

# Get project root (find .kiro directory)
export def get-project-root [] {
  mut current = (pwd)

  loop {
    if ($"($current)/.kiro" | path exists) {
      return $current
    }

    let parent = ($current | path dirname)
    if $parent == $current {
      return null
    }
    $current = $parent
  }
}
