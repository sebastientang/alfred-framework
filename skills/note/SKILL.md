---
name: note
description: Frictionless context capture — appends a timestamped fact to tracking/context-updates.md with zero output.
user-invokable: true
---

# /note — Micro Context Capture

One-shot append. No confirmation. No output. Just log and continue.

## Behavior
1. Accept free-text input after `/note`
2. Auto-detect category from keywords:
   - BUSINESS: lead, rate, client, pipeline, contract, company, revenue, project, invoice, freelance
   - PERSONAL: family, health, spouse, kids, gym, apartment, visa, school
   - Default if ambiguous: BUSINESS
3. Infer SECTION from context (e.g., "Pipeline", "Tools", "Family", "Finances", "Health")
4. Append one line to `tracking/context-updates.md`:
   ```
   [YYYY-MM-DD] [BUSINESS/PERSONAL] [SECTION] UPDATE: [text as provided]
   ```
5. If the note category is BUSINESS and contains a name or company that matches an active pipeline deal (from session context if available):
   - Also call `cc_task_create` with lead_id, title derived from note text, category=revenue, scheduled_date=today
   - Also call `cc_pipeline_update` to set next_action from the note
   - Still return nothing to the user — the task creation is silent
   - If pipeline context is not available in the current session (e.g., no briefing data loaded), skip this step — the next briefing's Step 1.6 will catch it
6. Return nothing. Resume whatever was happening before the /note invocation.

## Token Budget
< 100 output tokens. This is a fire-and-forget operation.
