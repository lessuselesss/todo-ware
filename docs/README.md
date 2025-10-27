# Kiro Meta-System Visual Documentation

This directory contains comprehensive visual documentation of the kiro meta-system workflow architecture, created using Typst.

## Documents

### 1. `workflow-architecture.typ`
**Hierarchical flowcharts and state machines using fletcher + lovelace**

Visualizes:
- Three-phase workflow overview
- Phase 1 (Generation) step-by-step flow
- Phase 2 (Pre-Implementation) with auto-generation
- Phase 3 (Implementation) TDD cycles
- Artifact creation flows
- Dependency graphs (DAG)
- Validation decision trees
- **State machines** for phase transitions, step execution, and validation results

### 2. `workflow-sequence.typ`
**Sequence diagrams using chronos**

Visualizes:
- Normal step execution sequence
- Phase transition (gate check) sequence
- Contract auto-generation sequence
- Crash recovery sequence
- TDD cycle sequence
- Agent command execution (`/kiro-status`)
- Validation failure handling
- Multi-agent handoff

### 3. `workflow-timeline.typ`
**Gantt charts using timeliney**

Visualizes:
- Full workflow timeline (all three phases)
- Phase 1 detailed timeline
- Phase 2 detailed timeline with auto-generation
- Phase 3 TDD cycles
- Dependencies and critical path
- Validation gates timeline

### 4. `contract-hierarchy.typ`
**Contract structure and relationships using fletcher + treet**

Visualizes:
- Complete project structure (full directory tree)
- Complete `.contracts/` hierarchy
- Contract import dependencies
- Contract types by purpose
- Contract creation flow (static vs auto-generated)
- Three-layer validation system
- Contract lifecycle

## Building PDFs

### Using Nix (Recommended)

The project includes a `flake.nix` with Typst + all required packages:

```bash
# Enter development environment
nix develop

# Build all PDFs
build-typst-docs

# Watch and rebuild on changes
watch-typst-docs
```

This creates PDFs in `docs/pdf/`:
- `workflow-architecture.pdf`
- `workflow-sequence.pdf`
- `workflow-timeline.pdf`
- `contract-hierarchy.pdf`

### Using Typst Directly

If you have Typst installed:

```bash
cd docs

# Compile individual documents
typst compile workflow-architecture.typ
typst compile workflow-sequence.typ
typst compile workflow-timeline.typ
typst compile contract-hierarchy.typ

# Watch mode
typst watch workflow-architecture.typ
```

### Using Nix Run (No Shell)

```bash
nix run .#build-typst-docs
```

## Required Typst Packages

These are automatically available in the Nix environment:

- `@preview/fletcher:0.5.1` - Flowchart diagrams
- `@preview/lovelace:0.3.0` - State machine pseudocode
- `@preview/chronos:0.2.0` - Sequence diagrams
- `@preview/timeliney:0.1.1` - Gantt charts
- `@preview/treet:0.1.1` - Tree/directory structure visualization

## Purpose

These visual documents serve multiple purposes:

1. **Design Documentation**: Define the meta-system architecture before implementation
2. **Implementation Guide**: Provide clear visual reference during coding
3. **Onboarding**: Help new contributors/agents understand the system quickly
4. **Communication**: Share the architecture with stakeholders
5. **Specification**: Formal visual specification of the kiro methodology

## Relationship to MISSING.md

`MISSING.md` (in project root) contains the textual description of the meta-system architecture. These Typst documents provide the **visual representation** of that architecture.

Together they form:
- **MISSING.md**: What needs to be built (textual, comprehensive)
- **docs/*.typ**: How it works (visual, diagram-based)

## Next Steps

After reviewing these visual documents:

1. **Approve the architecture** - Ensure the visual design is correct
2. **Implement the contracts** - Build `.contracts/meta-system/` based on these diagrams
3. **Build the execution engine** - Implement `tools/workflow-engine.nu` based on sequences
4. **Create state management** - Build `tools/phase-manager.nu` based on state machines
5. **Test the system** - Verify implementation matches the visual specification

## Notes

- All diagrams are created programmatically (no raster images)
- PDFs are vector-based and scale perfectly
- Source `.typ` files can be version-controlled and diffed
- Easy to update diagrams as architecture evolves
