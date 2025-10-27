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
