---
name: arch-review
description: Architecture decision review — 4-agent team (Pragmatist, Scale Thinker, DX Advocate, Debt Accountant) with inter-agent dialogue via TeamCreate. Main Claude synthesizes. Cross-project technical decision review with Cynefin classification. Use this skill when the user says "architecture review [topic]", "tech review [topic]", "review the architecture", or "technical decision review". Do NOT use for code review, release reviews (use /ship-gate), or general decisions (use /council).
user-invokable: true
---

# Architecture Review Board — Technical Decision Review

## When to Use
- Before major technical decisions (framework choice, architecture pattern, migration)
- Triggered by "architecture review [topic]" or "tech review [topic]"
- Cross-project — works on any codebase, not just Alfred
- NOT for code review (use code-reviewer agent) or project audit (use /audit-project)

## Inputs
The skill receives from Alfred:
- **Topic:** the technical decision being evaluated
- **Options:** 2-3 options under consideration (if known)
- **Project context:** what project this affects, current stack
- **Constraints:** from knowledge-graph.md if in Alfred, or stated by user

## Process

### Step 1: Load Context
Read these files (parallel, gracefully handle missing):
- Project config files (package.json, tsconfig.json, wrangler.toml, astro.config.mjs — whatever exists)
- `memory/knowledge-graph.md` — Constraints section — skip if not in Alfred
- `decisions/log.md` — scan for related past architecture decisions — skip if not in Alfred
- Any file relevant to the specific decision (existing implementation, migration target docs)

### Step 2: Create Team
1. Call `TeamCreate` with name "arch-review" and description of the technical decision.
2. Read all 4 persona files from `~/.claude/skills/arch-review/personas/`:
   - `pragmatist.md`
   - `scale-thinker.md`
   - `dx-advocate.md`
   - `debt-accountant.md`

### Step 3: Spawn 4 Named Teammates
Spawn 4 agents in parallel using the Agent tool with `team_name: "arch-review"` and unique `name` for each:

1. **Pragmatist** (name: "pragmatist") — YAGNI enforcer, simplest option advocate
2. **Scale Thinker** (name: "scale-thinker") — architectural ceiling and lock-in analysis
3. **DX Advocate** (name: "dx-advocate") — daily workflow and maintainability impact
4. **Debt Accountant** (name: "debt-accountant") — technical debt quantification

Each agent prompt includes:
- Their persona instructions (full content from persona file)
- The decision topic, all options, and current stack
- Relevant constraints and past decisions
- Instruction to post their initial brief (200-400 words) via `SendMessage` to the team

### Step 4: Inter-Agent Dialogue
After all 4 agents post their initial briefs:

Each agent reads the other briefs and posts a **rebuttal round** (100-200 words):
- **Pragmatist** → responds to Scale Thinker — is the scaling concern real or hypothetical?
- **Scale Thinker** → responds to Pragmatist — does the simple option create an architectural ceiling?
- **DX Advocate** → responds to Debt Accountant — is the debt actually felt daily, or just theoretical?
- **Debt Accountant** → responds to DX Advocate — does the "nice DX" option hide compounding costs?

Agents should use `SendMessage` to address specific peers by name.

### Step 5: Main Claude Synthesizes
Main Claude receives all messages automatically. Main Claude has full session context (project history, prior decisions, real-world constraints) that agents lack — use it.

Classify using Cynefin:
- **Clear** — cause-effect obvious, best practice exists → just decide
- **Complicated** — cause-effect discoverable with expertise → analyze then decide
- **Complex** — cause-effect only visible in retrospect → probe-sense-respond, run experiments
- **Chaotic** — no cause-effect relationship → act first, then assess

### Step 6: Present Recommendation
Display in this format:

```
## Architecture Review: [TOPIC]

**Recommendation:** [what to do]
**Confidence:** [X]%
**Cynefin classification:** [Clear / Complicated / Complex / Chaotic]

### Pragmatist View
[simplest option, YAGNI flags, time estimate]

### Scale Perspective
[architectural ceiling, lock-in risks, migration difficulty]

### Developer Experience
[daily workflow impact, learning curve, debuggability, solo dev context]

### Debt Analysis
[debt per option, interest rate, migration cost, lock-in severity]

### Key Rebuttals
[1-2 most impactful exchanges from the rebuttal round]

### Synthesis
**Top 3 trade-offs:**
1. [trade-off]
2. [trade-off]
3. [trade-off]

**Migration path:** [if choosing recommended option, how to get there]

**Review date:** [when to reassess this decision]

**If Complex:** Recommended experiment: [time-boxed experiment to reduce uncertainty]
```

### Step 7: Shutdown Team
Send `shutdown_request` to all 4 agents via SendMessage after presenting the recommendation.

### Step 8: Log Decision
After the user confirms or makes a decision, log to `decisions/log.md` (if in Alfred project):

```
[DATE] DECISION: [what]
ARCH-REVIEW: yes
CYNEFIN: [classification]
REASONING: [from synthesis]
OPTIONS CONSIDERED: [list]
DEBT CREATED: [from Debt Accountant — what debt this introduces]
MIGRATION PATH: [how to change course if needed]
CONFIDENCE: [X]%
REVIEW DATE: [when to reassess]
```

Also update `memory/knowledge-graph.md` Decision Precedents section per behavior.md Rule #18 (if in Alfred project).

If NOT in Alfred project, present the decision log format and let the user handle logging.

## Token Budget
- 4 agents initial briefs: ~2K input + ~500 output each = ~10K
- 4 agents rebuttals: ~3K input + ~200 output each = ~13K
- Main Claude synthesis: ~2K (no extra agent)
- Total: ~15K tokens per Architecture Review session
- Expected frequency: 2-4x/month (varies with project work)
