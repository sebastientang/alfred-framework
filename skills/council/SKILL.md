---
name: council
description: Adversarial decision debate — 4-agent team (Proposer, Challenger, Steelmanner, Pre-Mortem) with inter-agent dialogue via TeamCreate. Main Claude synthesizes. Produces structured recommendation with confidence %, risks, and validation gates. Use this skill when the user says "debate this", "stress-test this", "decision: [topic]" (Sleep-On-It class), or "adversarial review". Auto-invoked when a decision is classified as Sleep-On-It (irreversible, >1K downside). Do NOT use for simple 5-Minute decisions, proposal stress-tests (use /war-room), or architecture reviews (use /arch-review).
user-invokable: true
---

# The Council — Decision Quality Debate

## When to Use
- Auto-invoked by Alfred when a decision is classified as **Sleep-On-It** (irreversible, >1K downside, >1 week of work) per frameworks.md section 5
- Manually invoked with "debate this" or "stress-test this" on any decision
- NOT for 5-Minute Rule decisions (reversible, <500 downside)

## Inputs
The skill receives from Alfred:
- **Topic:** The decision being made
- **Options:** 2-3 options with initial trade-offs
- **Preferred option:** Which way [USER] is leaning (if known)
- **Context:** Constraints and precedents from knowledge-graph.md, relevant decisions/log.md entries

## Process

### Step 1: Load Context
Read these files (parallel):
- `memory/knowledge-graph.md` — Constraints + Decision Precedents sections
- `decisions/log.md` — scan for similar past decisions (keyword match on topic)
- Any domain-specific file relevant to the decision (e.g., BUSINESS.md for financial, PERSONAL.md for life decisions)

### Step 2: Create Team
1. Call `TeamCreate` with name "council" and description of the decision topic.
2. Read all 4 persona files from `~/.claude/skills/council/personas/`:
   - `proposer.md`
   - `challenger.md`
   - `steelmanner.md`
   - `pre-mortem.md`

### Step 3: Spawn 4 Named Teammates
Spawn 4 agents in parallel using the Agent tool with `team_name: "council"` and unique `name` for each:

1. **Proposer** (name: "proposer") — builds the case FOR the preferred option
2. **Challenger** (name: "challenger") — attacks the preferred option
3. **Steelmanner** (name: "steelmanner") — advocates for the option [USER] is leaning AWAY from
4. **Pre-Mortem** (name: "pre-mortem") — narrates the failure story

Each agent prompt includes:
- Their persona instructions (full content from persona file)
- The decision topic, all options, preferred option, and constraints
- Similar past decisions from decisions/log.md
- Instruction to post their initial brief (200-400 words) via `SendMessage` to the team

### Step 4: Inter-Agent Dialogue
After all 4 agents post their initial briefs:

Each agent reads the other briefs (received via SendMessage) and posts a **rebuttal round** (100-200 words):
- **Proposer** → responds to the Challenger's strongest attack
- **Challenger** → responds to the Proposer's weakest acknowledged point — is it actually weak, or is it fatal?
- **Steelmanner** → responds to the Pre-Mortem — does the failure story apply equally to the rejected option?
- **Pre-Mortem** → responds to the Proposer's assumptions — which ones appear in the failure cascade?

Agents should use `SendMessage` to address specific peers by name.

### Step 5: Main Claude Synthesizes
Main Claude receives all messages automatically (initial briefs + rebuttals). Main Claude has full session context that agents lack — use it.

Synthesize using Cynefin classification:
- **Clear** — cause-effect obvious → just decide
- **Complicated** — cause-effect discoverable → analyze then decide
- **Complex** — cause-effect only visible in retrospect → probe-sense-respond
- **Chaotic** — no cause-effect → act first, assess later

### Step 6: Present to [USER]
Display in this format:

```
## Council Recommendation: [TOPIC]

**Recommendation:** [what to do]
**Confidence:** [X]%
**Decision type:** [Cynefin classification]

### The Case For (Proposer)
[2-3 key points from Proposer brief]

### Vulnerabilities Found (Challenger)
[2-3 key risks from Challenger brief]

### Best Case for [Rejected Option] (Steelmanner)
[2-3 strongest arguments for the path not taken]

### Failure Story (Pre-Mortem)
[The narrative — how it fails, when, why]

### Key Rebuttals
[1-2 most impactful exchanges from the rebuttal round]

### Synthesis
**Top 3 risks to monitor:**
1. [risk]
2. [risk]
3. [risk]

**Strongest counter-argument:** [from Challenger or Steelmanner]

**Validation gates** (how to know this is working):
- [gate 1 — measurable, time-bound]
- [gate 2]
- [gate 3]

**Assumptions that must hold:**
- [from Proposer — survived Challenger scrutiny]
```

### Step 7: Shutdown Team
Send `shutdown_request` to all 4 agents via SendMessage after presenting the verdict.

### Step 8: Log Decision
After [USER] confirms the decision, log to `decisions/log.md` using enhanced format:

```
[DATE] DECISION: [what]
COUNCIL: yes
REASONING: [from synthesis]
ASSUMPTIONS: [from Proposer — what must be true]
KEY RISKS: [from Challenger + Pre-Mortem — top 3]
STEELMAN REJECTED: [from Steelmanner — best case for path not taken]
CONFIDENCE: [X]%
ALTERNATIVES REJECTED: [options not chosen and why]
REVERSIBLE: no
REVIEW DATE: [typically 2-4 weeks out]
```

Also update `memory/knowledge-graph.md` Decision Precedents section per behavior.md Rule #18.

## Token Budget
- 4 agents initial briefs: ~2K input + ~500 output each = ~10K
- 4 agents rebuttals: ~3K input + ~200 output each = ~13K
- Main Claude synthesis: ~2K (no extra agent)
- Total: ~15K tokens per Council session
- Expected frequency: 1-2x/month
