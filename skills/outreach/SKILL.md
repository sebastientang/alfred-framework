---
name: outreach
description: "Draft outreach message to a specific contact or lead. Use this skill when the user says 'draft outreach to [name]', 'outreach to [name]', 'reach out to [name]', 'message [name]', 'contact [name]', 'send a message to [name]', or wants to write a cold or warm outreach message to a specific person. Resolves the contact from CRM, selects the best outreach angle, drafts in brand voice, and logs after send. Do NOT use for 'reactivate [name]' (different flow), general writing, email drafts without a target contact, or outreach analytics."
argument-hint: "[target]"
user-invokable: true
---

# /outreach — Draft Outreach Workflow

Execute these steps in order. Complete in <1,200 output tokens. Draft quality over speed.

## Step 1: Resolve Target
Look up [target] in `references/contacts.md`.
- If ESN/SI company → also load `references/contacts-archive.md` for full company contact list
- If not found → ask user to clarify before proceeding

## Step 2: Route — Warm, Cold, or Reactivation

Before pulling CRM data, classify the target using `references/contacts.md`:

| Condition | Path | Eligible Angles |
|-----------|------|-----------------|
| In contacts.md, Last Contact < 30 days | **WARM** | 3 (former colleague), 4 (former client), 7 (warm touch) |
| In contacts.md, Last Contact >= 30 days | **REACTIVATION** | 3, 4, 7 — with reactivation framing (value-add, not pitch) |
| NOT in contacts.md | **COLD** | 1 (technical skills gap), 2 (platform foundation), 5 (rescue), 6 (training), 8 (custom) |

This routing replaces the manual "warm or cold?" question. Skip to Step 3 with the eligible angle set already narrowed.

Override: If user specifies an angle, use it regardless of path.

## Step 3: Context Pull
Execute all MCP calls in parallel:
- `cc_pipeline_get` (by lead name/company) — full pipeline history
- `cc_touch_list` (filtered by lead_id) — past interactions and last message
- `cc_touch_stats` — angle performance data for this ICP type
- `gmail_search_messages` q: "from:TARGET_EMAIL OR to:TARGET_EMAIL" (max 10) — prior email threads
  - If prior threads exist → surface last topic and time gap, adjust angle selection

## Step 4: Angle Selection
From the eligible angles (narrowed by Step 2), pick the highest-converting using touch_stats.
If <20 total entries in touch_stats, use path defaults:
- WARM: Angle 7 (warm touch) unless former colleague (3) or former client (4) is a better fit
- REACTIVATION: Angle 4 (former client) or 3 (former colleague) with reactivation framing
- COLD: ESN/SI → Angle 1, Direct client → Angle 5, Training center → Angle 6

Override if user specifies an angle.

## Step 5: Draft
Fill `templates/outreach.md`:
- Apply Brand_Bible_Appendix.md voice rules
- French default for LinkedIn/email to French market. English for international.
- Include: hook (first line), proof point, soft CTA
- Run against 24 banned words list

Present draft for review. Wait for send confirmation.

## Step 6: Post-Send Logging
After explicit "sent" / "done" / confirmation:
- `cc_touch_create` — log with angle number, channel, summary
- Update `references/contacts.md` — Last Contact date to today
- Append to `tracking/outreach-log.md` — date, target, angle, channel, notes
- If channel is email and send confirmed → `gmail_create_draft` with the content (use threadId if replying to existing thread)
