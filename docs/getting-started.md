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

## Step 2: Copy Skills and Agents

Copy all skills and agents, or pick the ones you need:

```bash
# Copy everything
cp -r path/to/alfred-framework/skills/ .claude/skills/
cp -r path/to/alfred-framework/agents/ .claude/agents/

# Or pick individually
cp -r path/to/alfred-framework/skills/briefing/ .claude/skills/briefing/
cp -r path/to/alfred-framework/skills/proposal/ .claude/skills/proposal/
cp -r path/to/alfred-framework/agents/deal-closing-expert/ .claude/agents/deal-closing-expert/
```

## Step 3: Create Your CLAUDE.md

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

## Step 4: Replace Placeholders

Skills use `[PLACEHOLDER]` values for personal data. Find and replace:

| Placeholder | Replace with | Example |
|-------------|-------------|---------|
| `[YOUR_RATE]` | Your daily rate | `600 EUR/day` |
| `[YOUR_CITY]` | Your location | `Paris` |
| `[YOUR_TIMEZONE]` | Your timezone | `Europe/Paris` |
| `[YOUR_ROLE]` | Your professional role | `Data Engineer` |
| `[YOUR_MARKET]` | Your target market | `French SIs` |
| `[BURN_RATE]` | Monthly expenses | `2300 EUR/month` |
| `[HEALTH_TRACKER]` | Your wearable | `Oura`, `Whoop`, `Apple Watch` |
| `[STUDY_APP]` | Your learning app | `Duolingo`, `Lingodeer` |
| `[PLATFORM]` | Freelance platforms | `Malt`, `Upwork` |

## Step 5: Create Tracking Files

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

## Step 6: Start a Session

```bash
claude
```

Your assistant will read `CLAUDE.md` and the linked rules. Try:
- Type `?` to see the action menu
- Type `/briefing` to run your first morning briefing
- Type `/system-health` to check the system status
- Ask it to draft an outreach message — it will follow the voice rules

## Recommended Starting Set

If you're not sure which skills to start with, here's a minimal productive set:

| Skill | Why |
|-------|-----|
| `briefing` | Daily planning with priority enforcement |
| `debrief` | Capture outcomes after every interaction |
| `outreach` | Consistent outreach with voice rules |
| `closeout` | Clean session endings with carry-forward |
| `system-health` | Keep the system honest |

Add more as you hit the 3-time rule — when you do something 3 times manually, it's time for a skill.

## What's Next

- **Add more skills** as you notice repeated workflows (the 3-time rule)
- **Create agents** when a domain has 5+ rules and recurring patterns
- **Customize templates** based on what output formats you actually use
- **Enable self-optimization** by logging sessions in `tracking/` — the system will start detecting patterns and proposing improvements after a few weeks of data

## Tips

- Keep CLAUDE.md under 300 lines — link to detail files, don't inline them
- Use the load-on-demand pattern: define which triggers load which files
- Start simple: 3 rules, 5 skills, 0 agents. Add complexity as you use the system.
- Review the assistant's self-optimization proposals weekly — they're often good ideas
- Short, focused sessions with clean closeouts beat long marathon sessions
