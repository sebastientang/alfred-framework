# Alfred Framework

A framework for building self-improving AI executive assistants with Claude Code.

## What This Is

Alfred Framework is a structured methodology for turning Claude Code into an executive assistant that manages your pipeline, enforces accountability, detects your avoidance patterns, and improves itself over time. It's not a library — it's a set of behavioral rules, reusable skills, auto-activating agents, and self-optimization systems that make Claude Code operate as a strategic partner rather than a chatbot.

This framework was extracted from a production system that manages a freelance consulting business: daily briefings, pipeline tracking, outreach drafting, proposal generation, meeting prep, and weekly reviews — all with dual logging to both CRM and local files.

## Key Concepts

### Rules (the brain)
Three files define how your assistant thinks:
- **`behavior.md`** — 19 behavioral rules covering priority enforcement, brutal honesty, pattern recognition, decision forcing, avoidance detection, session management, and context capture
- **`voice.md`** — Communication style: brevity over completeness, specifics over generalities, deadlines over intentions
- **`self-optimization.md`** — 10 systems for continuous improvement: component creation (3-time rule), template evolution, relationship decay detection, time allocation analysis, stale data detection, and context window management

### Skills (user-invoked workflows)
Multi-step procedures triggered by `/skill-name`. Each skill is a self-contained markdown file with numbered steps. Examples: `/briefing`, `/proposal`, `/deep-research`, `/ship-gate`.

### Agents (auto-activating experts)
Domain specialists that activate when context matches — no explicit trigger needed. Examples: `astro-site-builder` activates when creating Astro components, `article-reviewer` activates when editing blog posts.

### Templates (structured output)
Markdown templates for recurring outputs (briefings, proposals, reviews). The assistant fills the template — the user reviews and acts.

### Self-Optimization
The system improves itself:
- **3-Time Rule** — after doing the same task 3 times manually, propose creating a skill/agent
- **Template Evolution** — rotating weekly feedback questions → template updates after 4 data points
- **Outreach Intelligence** — after 15+ entries, recommend angles, channels, and timing
- **Time Allocation Analysis** — track category drift, escalate when priorities are misaligned
- **Relationship Decay** — compute reactivation scores, surface overdue contacts
- **Stale Data Detection** — flag tracking files past freshness thresholds

## Quick Start

1. Copy `framework/` into your project's `.claude/` directory:
```bash
cp -r framework/rules/ .claude/rules/
cp -r framework/conventions/ .claude/conventions/
cp -r framework/templates/ templates/
```

2. Create your `CLAUDE.md` using `examples/freelance-consultant/CLAUDE.md` as a starting point. Customize:
   - Your context (who you are, what matters)
   - Your top priority
   - Your trigger table (what commands you want)
   - Your decision framework

3. Create your first skill by copying an example from `examples/freelance-consultant/skills/` and adapting it.

4. Start a Claude Code session. The assistant will read your rules and operate accordingly.

## Project Structure

```
framework/
├── rules/
│   ├── behavior.md          # 19 behavioral rules
│   ├── voice.md             # Communication style
│   └── self-optimization.md # 10 self-improvement systems
├── conventions/
│   └── skill-agent-conventions.md  # How to author skills + agents
├── templates/               # Output templates
└── structure.md             # How to organize your project

examples/
└── freelance-consultant/    # Complete working example
    ├── CLAUDE.md            # Example project instructions
    ├── skills/              # 5 example skills
    ├── agents/              # 3 example agents
    └── templates/           # Example templates

docs/
└── getting-started.md       # Setup guide
```

## Examples Included

### Skills
| Skill | What it does |
|-------|-------------|
| `scaffold-astro` | Scaffolds an Astro 5.x + Tailwind v4 project |
| `deep-research` | Researches any topic via Perplexity API with smart model selection |
| `system-health` | Dashboard for file freshness, optimization status, accountability |
| `brand-voice-check` | Two-pass content validation (regex + AI tone review) |
| `ship-gate` | Release readiness review with 4 parallel audit agents |

### Agents
| Agent | When it activates |
|-------|-------------------|
| `astro-site-builder` | Creating Astro pages, components, or layouts |
| `content-pipeline-builder` | Setting up automated content generation |
| `article-reviewer` | Reviewing blog articles for quality and voice |

## Philosophy

**Rules over prompts.** A well-defined behavioral rule ("If the user asks to work on something that's not their top priority, checkpoint them") produces better results than a vague instruction ("be helpful and keep the user focused"). Rules are testable, debuggable, and composable.

**Skills over memory.** Instead of hoping the AI remembers your preferred workflow, encode it as a numbered procedure. Skills are deterministic — they run the same way every time, across sessions.

**Self-optimization over manual tuning.** The system proposes its own improvements. After 3 repeated tasks → suggests a new skill. After 15 outreach entries → recommends the best-performing angle. After 2 weeks of priority drift → escalates. You approve or reject — the system doesn't change itself without permission.

**Load on demand.** Not every file needs to be in context every session. Define a trigger-to-file mapping in CLAUDE.md so the assistant loads what it needs, when it needs it. This is how you scale to 30+ reference files without blowing the context window.

**Track everything, archive aggressively.** Dual-log to both structured systems (CRM) and local markdown. Archive processed entries monthly. Never archive wins.

## Production Stats

This framework runs a production executive assistant with:
- 34 skills across business operations, content, development, and decision-making
- 8 auto-activating agents for domain expertise
- 10 self-optimization systems
- Daily briefings pulling from CRM, email, calendar, and local files
- Weekly reviews with time allocation analysis and accountability checks

## License

MIT — see [LICENSE](LICENSE).
