# Getting Started

Set up your own AI executive assistant in 5 minutes.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A project directory where you want the assistant to operate

## Step 1: Copy the Framework

```bash
# From your project root
mkdir -p .claude/rules .claude/conventions templates

# Copy the core rules
cp path/to/alfred-framework/framework/rules/*.md .claude/rules/
cp path/to/alfred-framework/framework/conventions/*.md .claude/conventions/
cp path/to/alfred-framework/framework/templates/*.md templates/
```

## Step 2: Create Your CLAUDE.md

Copy the example and customize it:

```bash
cp path/to/alfred-framework/examples/freelance-consultant/CLAUDE.md ./CLAUDE.md
```

Edit `CLAUDE.md` to define:

1. **Your context** — who you are, what you do, what tools you use
2. **Your top priority** — one sentence, the filter for all decisions
3. **Your triggers** — what commands you want (briefing, tasks, debrief, etc.)
4. **Your decision framework** — how to prioritize when everything feels urgent
5. **Links to your rules** — point to `.claude/rules/behavior.md`, `voice.md`, `self-optimization.md`

## Step 3: Create Tracking Files

```bash
mkdir -p tracking goals decisions memory

# Minimal starter files
echo "# Outreach Log" > tracking/outreach-log.md
echo "# Wins" > tracking/wins.md
echo "# Context Updates" > tracking/context-updates.md
echo "# Session State" > tracking/session-state.md
echo "# Q1 Goals" > goals/quarterly.md
echo "# Decisions" > decisions/log.md
```

Add these to `.gitignore` if they contain sensitive data:
```
tracking/
memory/
leads/
daily/
*.local.md
```

## Step 4: Create Your First Skill

Skills live in `.claude/skills/{name}/SKILL.md`. Start with something simple:

```bash
mkdir -p .claude/skills/morning-plan
```

Create `.claude/skills/morning-plan/SKILL.md`:

```markdown
---
name: morning-plan
description: Quick morning plan with top 3 priorities
user-invokable: true
---

Generate a morning plan for today.

## Step 1: Read Context
Read tracking/session-state.md for carry-forward items.
Read goals/quarterly.md for current priorities.

## Step 2: Generate Plan
Based on the context, create a prioritized plan:
1. The Frog (hardest, most impactful task)
2. Second priority
3. Third priority

Include time estimates and recommended order.

## Step 3: Present
Output as a clean, scannable list. End with:
"Ready to start with #1?"
```

## Step 5: Start a Session

```bash
claude
```

Your assistant will read `CLAUDE.md` and the linked rules. Try:
- Type `?` to see the action menu
- Type `/morning-plan` to run your first skill
- Ask it to draft an outreach message — it will follow the voice rules

## What's Next

- **Add more skills** as you notice repeated workflows (the 3-time rule)
- **Create agents** when a domain has 5+ rules and recurring patterns
- **Customize templates** based on what output formats you actually use
- **Enable self-optimization** by logging sessions in `tracking/` — the system will start detecting patterns and proposing improvements after a few weeks of data

## Tips

- Keep CLAUDE.md under 300 lines — link to detail files, don't inline them
- Use the load-on-demand pattern: define which triggers load which files
- Start simple: 3 rules, 1 skill, 0 agents. Add complexity as you use the system.
- Review the assistant's self-optimization proposals weekly — they're often good ideas
- Short, focused sessions with clean closeouts beat long marathon sessions
