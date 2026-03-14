# Project Structure

How to organize a Claude Code executive assistant project.

## Directory Layout

```
your-project/
├── CLAUDE.md                    # Project instructions (Claude reads this first)
├── CLAUDE.local.md              # Personal overrides (gitignored)
├── .claude/
│   ├── rules/
│   │   ├── behavior.md          # Behavioral rules (identity, priorities, patterns)
│   │   ├── voice.md             # Communication style rules
│   │   └── self-optimization.md # How the system improves itself
│   ├── skills/                  # User-invoked workflows
│   │   └── {name}/SKILL.md
│   └── agents/                  # Auto-activating domain experts
│       └── {name}/AGENT.md
├── references/                  # Stable reference docs (loaded on demand)
│   ├── contacts.md
│   ├── frameworks.md
│   └── expertise/               # Deep research output
├── templates/                   # Output templates for briefings, proposals, etc.
├── tracking/                    # Session logs, outreach logs, wins (gitignored)
├── memory/                      # Persistent memory files
├── daily/                       # Daily briefing outputs (gitignored)
├── decisions/                   # Decision log
├── goals/                       # Quarterly goals
└── leads/                       # Per-lead materials (gitignored)
    └── {slug}/                  # Meeting prep, proposals, notes per lead
```

## What Goes Where

### CLAUDE.md (always loaded)
The entry point. Keep it under 300 lines. Contains:
- Context summary (who you are, what matters)
- Top priority (one sentence)
- Trigger routing table (user says X → assistant does Y)
- Auto-behaviors list
- Decision framework
- Links to rules, skills, agents

### Rules (always loaded)
Define HOW the assistant thinks. Three files:
- `behavior.md` — what it prioritizes, how it tracks, when it nags
- `voice.md` — how it communicates
- `self-optimization.md` — how it improves itself

### Skills (loaded when invoked)
Multi-step workflows triggered by the user via `/skill-name`. Each skill is a self-contained SKILL.md with numbered steps.

### Agents (loaded when context matches)
Domain experts that auto-activate based on file patterns or conversation context. Advisory by default — they analyze and report, not auto-fix.

### References (loaded on demand)
Stable documents that don't change often: contacts, frameworks, brand guidelines, expertise files. CLAUDE.md specifies which triggers load which files.

### Templates (loaded when filling)
Output format definitions for recurring outputs (briefings, proposals, reviews). The assistant fills the template, not the user.

### Tracking (gitignored, append-only)
Session logs, outreach logs, fitness tracking, learning ledger, wins. These are the system's memory of what happened.

### Memory (persistent)
Cross-session knowledge: knowledge graph, patterns, contact insights. Loaded when relevant, not every session.

## Load-on-Demand Pattern

The key to context window efficiency: CLAUDE.md defines a trigger-to-file mapping.

```markdown
| Trigger | Read These |
|---------|-----------|
| briefing | BUSINESS.md, PERSONAL.md, goals/quarterly.md |
| proposal | Brand_Bible.md, BUSINESS.md |
| outreach | Brand_Bible.md, references/contacts.md |
| meeting prep | contacts.md, + memory/patterns.md |
```

This prevents loading 50 files every session. The assistant reads what it needs, when it needs it.

## Gitignore Strategy

Sensitive and ephemeral files stay local:
- `tracking/` — session logs, outreach details
- `memory/` — personal knowledge graph
- `daily/` — briefing outputs
- `leads/` — per-lead proposals, notes
- `*.local.md` — personal overrides
- `.env*` — API keys

Framework files (rules, skills, agents, templates) are committed and versioned.
