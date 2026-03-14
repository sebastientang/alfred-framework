---
name: war-room
description: Proposal stress-test — 4-agent team (Buyer's Advocate, Competitor Shadow, Scope Realist, Pricing Challenger) with inter-agent dialogue via TeamCreate. Main Claude synthesizes. Send/Revise/Rethink verdict. Use this skill when the user says "war room [proposal]", "stress-test proposal", "stress-test the proposal", or wants to validate a proposal before sending. Do NOT use for general decisions (use /council), architecture reviews (use /arch-review), or release reviews (use /ship-gate).
user-invokable: true
---

# War Room — Proposal Stress-Test

## When to Use
- After /proposal generates a draft, before sending to the client
- Triggered by "war room [proposal]" or "stress-test proposal"
- For strategic deals where the proposal quality matters (not routine quotes)
- NOT for generating proposals (use /proposal for that)

## Prerequisite
A proposal draft must exist. If no proposal has been drafted in the current session or in `leads/[slug]/`, suggest running /proposal first.

## Inputs
The skill receives from Alfred:
- **Proposal draft:** the full text of the proposal to stress-test
- **Target:** company name, contact, context
- **Deal context:** pipeline stage, prior interactions, rate discussed

## Process

### Step 1: Load Context
Read these files (parallel):
- `Brand_Bible_Appendix.md` — rates, ICPs, objection handling, voice rules
- `BUSINESS.md` — current financial state, constraints
- `memory/knowledge-graph.md` — Constraints section (cash flow, payment terms, hardware)
- Proposal draft (from session or `leads/[slug]/`)
- `leads/[slug]/` — any prior materials (meeting prep, call notes)
- `references/contacts.md` — contact details and history

### Step 2: Create Team
1. Call `TeamCreate` with name "war-room" and description of the proposal being stress-tested.
2. Read all 4 persona files from `~/.claude/skills/war-room/personas/`:
   - `buyers-advocate.md`
   - `competitor-shadow.md`
   - `scope-realist.md`
   - `pricing-challenger.md`

### Step 3: Spawn 4 Named Teammates
Spawn 4 agents in parallel using the Agent tool with `team_name: "war-room"` and unique `name` for each:

1. **Buyer's Advocate** (name: "buyers-advocate") — reads the proposal as the client would
2. **Competitor Shadow** (name: "competitor-shadow") — builds counter-proposals from SI/freelancer/offshore
3. **Scope Realist** (name: "scope-realist") — checks deliverability against real constraints
4. **Pricing Challenger** (name: "pricing-challenger") — stress-tests the pricing strategy

Each agent prompt includes:
- Their persona instructions (full content from persona file)
- The full proposal text
- Target company and contact details
- Deal context (stage, rate, prior interactions)
- Relevant constraints from knowledge-graph.md and BUSINESS.md
- Instruction to post their initial brief (200-400 words) via `SendMessage` to the team

### Step 4: Inter-Agent Dialogue
After all 4 agents post their initial briefs:

Each agent reads the other briefs and posts a **rebuttal round** (100-200 words):
- **Buyer's Advocate** → responds to Pricing Challenger — is the price the real hesitation, or is it something else?
- **Competitor Shadow** → responds to Scope Realist — which constraint is the competitor's biggest advantage?
- **Scope Realist** → responds to Buyer's Advocate — are the hesitation points actually scope issues in disguise?
- **Pricing Challenger** → responds to Competitor Shadow — how does the competitor's price change the value equation?

Agents should use `SendMessage` to address specific peers by name.

### Step 5: Main Claude Synthesizes
Main Claude receives all messages automatically. Main Claude has full session context (proposal history, relationship dynamics, pipeline urgency) that agents lack — use it.

Determine verdict:
- **Send** — proposal is strong, objections are manageable
- **Revise** — specific sections need improvement, core is sound
- **Rethink** — fundamental issues with approach, re-run /proposal

### Step 6: Present Verdict
Display in this format:

```
## War Room: [TARGET] Proposal

**Verdict:** [Send / Revise / Rethink]
**Confidence:** [X]%
**Strongest objection:** [one sentence]
**Pre-emptive answer:** [one sentence]

### Client Perspective (Buyer's Advocate)
[problem fit score, clarity issues, hesitation points]

### Competitive Landscape (Competitor Shadow)
[3 competitor counter-proposals, vulnerability points, unique advantages]

### Deliverability Check (Scope Realist)
[deliverability score, timeline reality, constraint conflicts]

### Pricing Analysis (Pricing Challenger)
[rate assessment, too-high/too-low risk, packaging recommendation]

### Key Rebuttals
[1-2 most impactful exchanges from the rebuttal round]

### Synthesis
**Specific revisions needed:** (if Revise)
1. [revision — why]
2. [revision — why]

**What's working well:** [1-2 strongest elements]

**If they say no, it'll be because:** [one sentence]
```

### Step 7: Shutdown Team
Send `shutdown_request` to all 4 agents via SendMessage after presenting the verdict.

### Step 8: Log Result
After presenting, append a war room summary to `tracking/leads-notes.md` under the relevant lead's section:

```
[DATE] WAR ROOM: [verdict] (confidence: X%)
Strongest objection: [X]
Key revision: [X]
```

If verdict is Send — confirm ready to submit.
If verdict is Revise — present specific edits, offer to re-run after revisions.
If verdict is Rethink — explain fundamental issues, suggest re-running /proposal with adjusted parameters.

## Token Budget
- 4 agents initial briefs: ~2K input + ~500 output each = ~10K
- 4 agents rebuttals: ~3K input + ~200 output each = ~13K
- Main Claude synthesis: ~2K (no extra agent)
- Total: ~15K tokens per War Room session
- Expected frequency: 1-2x/month (strategic deals only)
