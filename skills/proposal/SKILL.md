---
name: proposal
description: "Generate a business proposal for a specific client or lead. Use this skill when the user says 'draft proposal for [name]', 'proposal for [name]', 'write a proposal', 'prepare a proposal', or wants to create a scoped consulting/freelance proposal with pricing, deliverables, and timeline. Pulls CRM context, applies rate tiers, uses challenge-led format. Do NOT use for outreach messages, rate analysis, SOW templates, LinkedIn posts, or general document writing."
argument-hint: "[target]"
user-invokable: true
---

# /proposal [target] — Proposal Generation

Execute these steps in order. Complete in <3,000 output tokens. Challenge-led format, not credentials-first.

## Step 1: Resolve Target & Pull CRM Data
Call these MCP tools in parallel:
- `cc_pipeline_get` (by lead_id) — deal history, stage, estimated value
- `cc_touch_list` (by lead_id, limit=10) — interaction history, stated needs

## Step 2: Context Assembly
Read these files:
- `tracking/leads-notes.md` — stated needs, pain points, objections, specific requirements
- `Brand_Bible_Appendix.md` — rate tiers, messaging angles, value propositions
- Apply `frameworks.md` — client delivery scope structure

## Step 3: Rate Recommendation
Based on:
- ICP segment and company size
- Scope complexity and duration
- Competitive pressure signals from touch history
- Current pipeline health (from session state)

Recommend: target rate, floor rate, concession options (scope reduction, payment terms, longer commitment).

## Step 4: Fill Template
Fill `templates/proposal.md`:

```
# Proposal: [Company Name]
Date: [YYYY-MM-DD]
Prepared for: [Contact Name], [Title]

## The Challenge
[Start with THEIR problem, not our credentials. 2-3 sentences describing the business challenge we've identified from discovery calls and notes.]

## Why It Matters
[Quantify the cost of inaction. Reference similar situations at named clients where possible.]

## Approach
[3-5 phases or workstreams. Each with:]
- Phase N: [Name]
  - Deliverables: [specific outputs]
  - Duration: [weeks]
  - Key activities: [2-3 bullets]

## Why [USER]
[2-3 proof points — named clients, specific outcomes, relevant certifications. No generic claims.]
- [Client] — [what was done] — [measurable result]

## Investment
- Rate: [target] EUR/day
- Estimated duration: [N] days over [N] weeks
- Total: [amount] EUR (excl. VAT)
- Payment terms: [monthly / milestone]

## Next Steps
1. [Specific action with date]
2. [Follow-up milestone]

---
Rate guidance (internal, do not share):
- Target: [rate] | Floor: [rate]
- Concessions available: [list]
- Pipeline context: [health status]
```

## Step 5: Voice Check
Verify proposal follows Brand Bible voice rules:
- No banned words (24-word list)
- Evidence over assertion
- Challenge-led structure (problem first, not credentials)
- Calm authority, no urgency manufacturing
