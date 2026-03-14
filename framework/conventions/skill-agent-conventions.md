# Skill & Agent Authoring Conventions

Stable patterns for creating Claude Code skills and agents.

## Skill Format (`~/.claude/skills/{name}/SKILL.md`)

### Frontmatter (required)
```yaml
---
name: skill-name
description: One-sentence description of what the skill does.
user-invokable: true
argument-hint: "[parameter]"  # optional — shown in autocomplete
---
```

- `user-invokable` (note the **k**, not `user-invocable`) — makes the skill available via `/skill-name` in the input box
- `argument-hint` — only include if the skill accepts a parameter; user input is available as `$ARGUMENTS`

### Body structure
```markdown
One-sentence task description. Reference $ARGUMENTS if applicable.

## Step 1: Title
[Instructions, bash commands, file contents]

## Step 2: Title
...

## Step N: Verify / Print summary
[Final verification or summary output]
```

### Conventions
- Steps are numbered sequentially: `## Step N: Title`
- Bash commands in fenced code blocks
- File contents use `**filename:**` followed by a fenced code block
- Always end with a verification or summary step
- Include `git add`, `git commit`, `git push` in the final step if the skill modifies project files
- Reference project-specific paths relatively (e.g., `src/content/blog/`), not absolutely

## Agent Format (`~/.claude/agents/{name}/AGENT.md`)

### Frontmatter (required)
```yaml
---
name: agent-name
description: When it activates + what it does in one sentence.
---
```

### Body structure
```markdown
Identity statement: "You are an expert [role] for [context]."

## When to Activate
- [Trigger conditions — file patterns, user requests, task types]
- Do NOT activate for: [exclusions]

## Reference Documents
1. [File paths the agent should read before acting]

## [Domain-Specific Checklist / Rules]
### 1. Check Name
**Check:** [What to look for]
**Report:** [How to report findings]

## Output Format
[Template for structured output]

## What NOT to Do
[Anti-patterns, duplicated checks to skip]

## Tools to Use
[Which tools are appropriate — Read, Grep, Glob, Edit, etc.]
```

### Conventions
- Agents are read-only by default — they review and report, not auto-fix (unless the user asks)
- Clear separation from existing validators (don't duplicate automated checks)
- Graduated severity levels: CRITICAL / WARNING / SUGGESTION
- Include concrete examples (good vs. bad) for each check
- Reference specific file paths for context documents

## Registration in CLAUDE.md

After creating a skill or agent, update your project's `CLAUDE.md`:

1. **Skills table** — add row: `| /skill-name [arg] | Description |`
2. **Agents table** — add row: `| agent-name | When it activates | What it does |`

## Design Principles

- **Skills** = user-invoked multi-step workflows (explicit trigger, modifies files)
- **Agents** = auto-activating domain experts (implicit trigger, advisory by default)
- **Hooks** = automated checks on tool use events (transparent, pass/fail)
- Prefer updating existing tools over creating new ones
- A skill needs 3+ meaningful steps; an agent needs a coherent domain with rules and patterns
