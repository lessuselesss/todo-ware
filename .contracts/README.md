# Kiro Nickel Contracts

This directory contains Nickel contracts that formally define the kiro.dev methodology for spec-driven development.

## Purpose

These contracts serve three purposes:

1. **Specification** - Define what constitutes valid kiro structures
2. **Validation** - Enable automated checking via Nushell and nickel
3. **Documentation** - Provide canonical reference for the methodology

## Organization

```
.contracts/
├── validation/          # Reusable validation predicates
│   ├── assertion-ids.ncl    # Task/assertion ID patterns (TASK-###--A#)
│   ├── markdown.ncl         # Markdown document structure
│   └── traceability.ncl     # Cross-reference validation
├── schema/              # Generated project structure
│   ├── assertions.ncl       # TDD assertions format
│   ├── scoped-tasks.ncl     # Decomposed tasks format
│   ├── context.ncl          # Module context format
│   ├── claude-md.ncl        # CLAUDE.md workflow format
│   └── scope-directory.ncl  # Directory structure invariant
└── plugin/              # Plugin self-specification
    ├── command.ncl          # Command file format
    └── agent.ncl            # Agent file format
```

## Key Conventions

### Assertion IDs (CRITICAL!)

**Format:** `TASK-###--A#` with **DOUBLE-DASH** separator

Examples:
- ✓ `AUTH-001--A3` (correct)
- ✗ `AUTH-001-A3` (wrong - single dash)
- ✗ `AUTH-001_A3` (wrong - underscore)

The double-dash is essential for unambiguous parsing.

### Structural Invariant

**Any directory containing source files MUST have:**
1. `CLAUDE.md` - Implementation workflow
2. `.kiro-scope/` directory with:
   - `scoped-tasks.md`
   - `assertions.md`
   - `context.md`

## Usage

### Validation

```bash
# Validate assertion ID
nickel eval .contracts/validation/assertion-ids.ncl << 'EOF'
"AUTH-001--A3" | AssertionId
EOF

# Validate via Nushell (recommended)
nu -c "use tools/kiro.nu *; validate-assertion-id 'AUTH-001--A3'"
nu -c "use tools/kiro.nu *; validate-scope-full 'src/auth'"
```

### Generation

Commands read contracts to know what to generate:

```nickel
# Get required structure
let scope = import ".contracts/schema/scope-directory.ncl" in
scope.generate_structure_spec "auth"
```

### Documentation

See [docs/CONTRACTS.md](../docs/CONTRACTS.md) for:
- Complete contract reference
- Usage examples
- Best practices
- Troubleshooting

## Integration Points

### Nushell Scripts

`tools/kiro.nu` provides contract-aware validation:
- `validate-assertion-id` - Check ID format
- `validate-scope-structure` - Check directory layout
- `validate-scope-full` - Complete validation
- `find-scoped-directories` - Find all scopes

### Commands

`/kiro-scope` uses contracts to:
1. Generate valid scope structure
2. Validate assertion IDs
3. Check frontmatter fields
4. Verify required sections

### Hooks

Workflow hooks reference contracts:
- `hooks/validate-spec.sh` - Spec completeness
- `hooks/validate-tests.sh` - Test existence
- `hooks/validate-contracts.sh` - Nickel type-checking

## Development

### Adding New Contracts

1. Create contract file in appropriate directory
2. Follow existing patterns (use imports for reuse)
3. Add validation functions
4. Document in `docs/CONTRACTS.md`
5. Update Nushell scripts if needed
6. Add examples

### Testing Contracts

```bash
# Syntax check
nickel typecheck .contracts/validation/assertion-ids.ncl

# Validate example
echo '"AUTH-001--A3"' | nickel eval --validate .contracts/validation/assertion-ids.ncl
```

## Version History

- **v1.0.0** (2025-10-26): Initial contract definitions
  - Core validation contracts
  - Schema contracts for generated projects
  - Plugin self-specification

## See Also

- [docs/CONTRACTS.md](../docs/CONTRACTS.md) - Complete documentation
- [Nickel Language](https://nickel-lang.org/)
- [kiro.dev Methodology](https://kiro.dev/)
