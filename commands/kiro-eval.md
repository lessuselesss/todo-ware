---
name: kiro-eval
description: Evaluate project against kiro.dev standards and generate quality report
aliases: [eval, validate, audit]
---

# Evaluate Kiro Project Standards

Evaluates your kiro-scaffolded project against standards and best practices, generating a comprehensive quality report with actionable recommendations.

## Usage

```
/kiro-eval [--report=terminal|markdown|html] [--output=<file>]
```

## Arguments

- `--report`: Report format
  - `terminal`: Display in terminal (default)
  - `markdown`: Generate markdown file
  - `html`: Generate interactive HTML dashboard
- `--output`: Output file path (for markdown/html formats)

## Examples

**Quick terminal evaluation:**
```
/kiro-eval
```

**Generate markdown report:**
```
/kiro-eval --report=markdown --output=QUALITY_REPORT.md
```

**Generate HTML dashboard:**
```
/kiro-eval --report=html --output=quality-dashboard.html
```

## Evaluation Dimensions

### 1. Generated Project Quality (70% weight)

#### Structure Compliance
- ✓ All required directories present
- ✓ CLAUDE.md at root and in scopes
- ✓ .aidocs/ with kiro, typix, nickel docs
- ✓ .kiro/ structure correct
- ✓ .contracts/ mirrors repository

#### Spec Completeness
- Master specs present (requirements, design, tasks)
- Scoped specs properly decomposed
- Traceability maintained
- Spec format compliance

#### Contract Alignment (Target: 80%+ coverage)
- Nickel contracts exist for all modules
- Contracts mirror code structure
- Type definitions complete
- All contracts type-check successfully

#### TDD Setup
- Test harness configured
- Assertions defined before implementation
- RED-to-GREEN workflow documented
- Test coverage metrics

### 2. Skill Correctness (20% weight)

#### Documentation Quality
- CLAUDE.md completeness
- .aidocs/ documentation freshness
- Scoped documentation accuracy
- README files present

#### Integration Health
- Typix/nix flake validity
- Nickel language setup
- Git repository health
- Development environment reproducibility

### 3. Workflow Effectiveness (10% weight)

#### Process Metrics
- Time from scaffold to implementation
- Spec compliance rate
- Test coverage trend
- Contract coverage growth

#### Developer Experience
- Setup complexity
- Documentation clarity
- Tooling integration
- Workflow smoothness

## Quality Score

The evaluation produces an overall quality score (0-100):

- **90-100**: Excellent - Exceeds kiro.dev standards
- **70-89**: Good - Meets standards with minor improvements needed
- **50-69**: Fair - Significant improvements recommended
- **Below 50**: Needs attention - Review scaffold and workflow

## Report Contents

The generated report includes:

### Executive Summary
- Overall quality score
- Key findings
- Critical issues
- Top recommendations

### Detailed Metrics
- Structure compliance checklist
- Spec completeness analysis
- Contract coverage report
- TDD workflow status

### Validation Results
- Golden file testing results
- Schema validation output
- Nickel contract type-checking
- Property-based test results

### Trend Analysis (if available)
- Quality score over time
- Coverage improvements
- Spec compliance trends
- Workflow metrics

### Actionable Recommendations
Prioritized list of improvements with:
- Issue description
- Impact level
- Effort estimate
- Implementation guidance

## Integration with CI/CD

You can run evaluations in CI/CD pipelines:

```yaml
# .github/workflows/kiro-eval.yml
name: Kiro Quality Check
on: [pull_request]
jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Kiro Evaluation
        run: |
          claude /kiro-eval --report=markdown --output=quality-report.md
      - name: Check Quality Threshold
        run: |
          # Fail if score below 70
          score=$(grep "Overall Score" quality-report.md | grep -oP '\d+')
          if [ $score -lt 70 ]; then exit 1; fi
```

## Success Criteria

A well-scaffolded kiro project should achieve:
- ✓ 85%+ contract coverage
- ✓ 100% spec file completeness
- ✓ Overall quality score ≥70
- ✓ All nickel contracts type-check successfully
- ✓ TDD workflow documented and followed
- ✓ No critical structure violations

## Continuous Improvement

Use evaluation results to:
- Track quality improvements over time
- Identify workflow bottlenecks
- Validate scaffold improvements
- Maintain standards compliance
- Guide refactoring priorities

## See Also

- `/kiro-new` - Create new kiro project
- `/kiro-spec` - Update spec files
- `/kiro-scope` - Create scoped area
