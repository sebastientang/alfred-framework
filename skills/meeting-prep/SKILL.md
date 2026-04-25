---
name: meeting-prep
description: "Prepare for an upcoming meeting, call, or interview with a specific contact. Use this skill when the user says 'meeting prep [name]', 'prep for call with [name]', 'prepare for meeting with [name]', 'help me prepare for the interview', 'I have a call tomorrow with [name]', or wants to get ready for any scheduled interaction. Pulls CRM history, cross-references contacts, checks prior email and calendar history, generates discovery questions and talking points. Do NOT use for post-meeting debriefs, outreach drafting, general research, or scheduling."
argument-hint: "[target]"
user-invokable: true
---

# /meeting-prep [target] — Meeting Preparation

Execute these steps in order. Complete in <2,500 output tokens. Template fill, not prose.

## Step 1: Resolve Target & Pull CRM Data
Call these MCP tools in parallel:
- Parse `[target]` — match against contacts.md or pipeline leads
- `cc_pipeline_get` (by lead_id if found) — full deal history, stage, value
- `cc_touch_list` (by lead_id, limit=10) — all interaction history
- `gmail_search_messages` q: "from:TARGET_EMAIL OR to:TARGET_EMAIL" (max 20) — prior email exchanges
- `gcal_list_events` q: "TARGET_NAME or COMPANY" (last 90 days) — past/future meetings
  - Summarize: last email exchange, past meetings, topics discussed
  - Feed into discovery question generation (Step 4)

If target not found in CRM, check `references/contacts.md` for offline contacts.

## Step 2: Context Assembly
Read these files (only the sections relevant to the target):
- `references/contacts.md` — mutual connections, relationship context, last contact date
- `tracking/leads-notes.md` — deal notes, stated needs, objections raised
- `Brand_Bible_Appendix.md` — outreach angles, ICP match, objection handling

## Step 3: Strategic Analysis
Apply frameworks:
- **Pipeline velocity** (frameworks.md): What stage is this deal at? What's the expected velocity for this stage? Is it ahead or behind?
- **Rate/negotiation** (frameworks.md): What rate tier fits this client? What's the floor? What concessions are available?

Assess:
- ICP segment match (direct client, agency, training, recruiter)
- Decision-maker vs influencer
- Known pain points and priorities
- Competitive landscape (other providers in play?)

## Step 4: Generate Discovery Questions
Create 5-7 tailored discovery questions based on:
- What we know (don't ask what we already have)
- What we need to advance to next stage
- Pain points we suspect but haven't confirmed
- Budget/timeline signals to probe

## Step 5: Fill Template
Fill `templates/meeting-prep.md`:

```
# Meeting Prep: [Name] @ [Company]
Date: [YYYY-MM-DD]

## Context
- Stage: [current stage] | Days in stage: [N]
- Last touch: [date] via [channel] — [summary]
- ICP: [segment] | Rate tier: [tier]

## Relationship Map
- [Mutual connections from contacts.md]
- [Decision-maker / influencer / champion]

## Known Pain Points
- [From leads-notes.md and touch history]

## Discovery Questions
1. [Tailored question]
2. ...

## Talking Points
- [Proof points relevant to their pain]
- [Client name drops that resonate with their industry]

## Desired Outcome
- [What stage advancement we're targeting]
- [Specific next step to propose]

## Rate Guidance
- Target: [rate] | Floor: [rate] | Concessions: [list]
```
