# Contributing to Kiro Scaffold Plugin

Thank you for your interest in contributing to the Kiro Scaffold plugin! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions. We're building tools to help developers, let's make the community welcoming too.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Your bug might already be reported
2. **Create detailed report** including:
   - Plugin version
   - Claude Code version
   - Operating system
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs or screenshots

### Suggesting Features

1. **Check discussions** - Feature might be planned or discussed
2. **Open feature request** with:
   - Clear use case description
   - Expected behavior
   - Why this improves the plugin
   - Example workflows

### Contributing Code

#### Development Setup

1. **Fork and clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/kiro-scaffold.git
   cd kiro-scaffold
   ```

2. **Create local marketplace**:
   ```bash
   mkdir -p ~/claude-plugins/marketplaces/dev
   cd ~/claude-plugins/marketplaces/dev
   ```

3. **Create development marketplace.json**:
   ```json
   {
     "name": "dev-plugins",
     "plugins": {
       "kiro-scaffold-dev": {
         "source": "path:/path/to/your/kiro-scaffold"
       }
     }
   }
   ```

4. **Install for testing**:
   ```bash
   claude
   /plugin marketplace add ~/claude-plugins/marketplaces/dev
   /plugin install kiro-scaffold-dev@dev-plugins
   ```

5. **Make changes** - Edit plugin files

6. **Test changes**:
   ```bash
   # Reload plugin
   /plugin uninstall kiro-scaffold-dev
   /plugin install kiro-scaffold-dev@dev-plugins
   
   # Test your changes
   /kiro-new test-project
   ```

#### Plugin Structure Guidelines

```
kiro-scaffold/
├── .claude-plugin/
│   └── plugin.json          # Metadata ONLY
├── commands/                 # Slash commands (at root!)
│   └── *.md                 # Command definitions
├── agents/                   # Specialized agents (at root!)
│   └── *.md                 # Agent descriptions
├── skills/                   # Autonomous skills (at root!)
│   └── */SKILL.md           # Skill definitions
├── hooks/                    # Event handlers (optional)
│   └── hooks.json
├── .mcp.json                # MCP servers (optional)
├── README.md
├── CHANGELOG.md
├── LICENSE
└── CONTRIBUTING.md
```

**Important**: Directories must be at plugin root, NOT inside `.claude-plugin/`!

#### Code Style

**Markdown Files (Commands, Agents, Skills)**:

```markdown
---
frontmatter: values
required: fields
---

# Main Title

Clear, concise description.

## Subsection

Well-organized content.

### Examples

```bash
# Clear examples
/command --flag=value
```
```

**JSON Files**:

```json
{
  "properly": "formatted",
  "indented": "with 2 spaces",
  "consistent": "style"
}
```

#### Writing Commands

Commands should:
- Have clear `name` and `description` in frontmatter
- Include `aliases` if appropriate
- Provide usage examples
- Document all arguments/flags
- Explain what gets created/modified
- Include "See Also" references

Template:
```markdown
---
name: command-name
description: What this command does
aliases: [alt-name]
---

# Command Title

Brief description of purpose and behavior.

## Usage

```
/command-name <required> [--optional=value]
```

## Arguments

- `required`: Description
- `--optional`: Description (default: value)

## Examples

```
/command-name example-input
```

## What It Does

1. Step one
2. Step two
3. Step three

## See Also

- `/other-command` - Related functionality
```

#### Writing Agents

Agents should:
- Define clear capabilities
- Explain when to invoke them
- Provide conversation flow examples
- Follow agent principles
- Include integration points

Template:
```markdown
---
description: What this agent specializes in
capabilities: ["cap1", "cap2", "cap3"]
---

# Agent Name

## Role and Expertise

What this agent is good at.

## When to Invoke This Agent

Claude should invoke when:
- Trigger 1
- Trigger 2
- Context clue

## Capabilities

### 1. Capability Name

Description and examples.

## Agent Principles

1. Principle one
2. Principle two

## See Also

- Related agents
```

#### Writing Skills

Skills should:
- Define clear activation triggers
- Explain autonomous behavior
- Provide activation examples
- Include quality checks

Template:
```markdown
---
name: skill-name
description: |
  When and how this skill auto-activates
---

# Skill Name

## What This Skill Does

Clear explanation.

## When It Activates

**Direct triggers:**
- "explicit phrase"

**Implicit triggers:**
- Context clues

## How It Works

### Phase 1: Detection
### Phase 2: Action
### Phase 3: Validation

## Examples

Show real activation scenarios.
```

### Testing Your Contributions

Before submitting:

1. **Test commands**:
   ```bash
   /your-command --all-flags
   ```

2. **Test agent invocation**:
   - Verify triggers work
   - Check conversation flow
   - Validate outputs

3. **Test skill activation**:
   - Use trigger phrases
   - Verify autonomous behavior
   - Check quality of results

4. **Run full workflow**:
   ```bash
   /kiro-new test-project --mode=headless --description="Test project for validation"
   cd test-project
   /kiro-eval
   ```

5. **Check documentation**:
   - All links work
   - Examples are accurate
   - Instructions are clear

### Submitting Pull Requests

1. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make focused commits**:
   ```bash
   git commit -m "Add: Brief description of what was added"
   git commit -m "Fix: Brief description of what was fixed"
   ```

3. **Update CHANGELOG.md**:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - Your new feature [#PR_NUMBER]
   ```

4. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **PR Description** should include:
   - What was changed and why
   - How to test the changes
   - Screenshots/examples if applicable
   - Related issues (Fixes #123)

### PR Review Process

1. **Automated checks** (when CI is set up):
   - Plugin loads successfully
   - Commands are discoverable
   - Agents are properly formatted

2. **Manual review**:
   - Code quality
   - Documentation clarity
   - Test coverage
   - User experience

3. **Feedback incorporation**:
   - Address reviewer comments
   - Make requested changes
   - Update PR description if scope changes

4. **Approval and merge**:
   - Squash and merge preferred
   - Clear commit message
   - CHANGELOG updated

## Areas for Contribution

### High Priority

- [ ] Additional language support (Go, Rust, Java, etc.)
- [ ] More testing frameworks (Jest, Pytest, RSpec, etc.)
- [ ] Enhanced contract templates
- [ ] Better error messages
- [ ] Performance improvements

### Medium Priority

- [ ] Visual specification editor
- [ ] Team collaboration features
- [ ] Migration tools for existing projects
- [ ] Integration with project management tools
- [ ] Additional evaluation metrics

### Nice to Have

- [ ] VSCode extension
- [ ] Specification versioning
- [ ] Contract testing tools
- [ ] Documentation generation
- [ ] Dependency analysis

## Development Resources

### Understanding Claude Code Plugins

- [Plugin documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)

### Understanding Kiro.dev

- [kiro.dev documentation](https://kiro.dev/docs/)
- [Spec-driven methodology](https://kiro.dev/docs/spec)
- [Steering documentation](https://kiro.dev/docs/steering)

### Understanding Tools

- [Nickel language](https://nickel-lang.org/)
- [Nix package manager](https://nixos.org/)
- [typix documentation](https://github.com/typix/typix)

## Questions?

- **GitHub Issues**: For bugs and features
- **GitHub Discussions**: For questions and ideas
- **Discord**: [Claude Developers Discord](https://discord.gg/claude-dev)

## Recognition

Contributors will be:
- Listed in README acknowledgments
- Credited in CHANGELOG
- Given attribution in relevant files

Thank you for helping make spec-driven development more accessible! 🎉
