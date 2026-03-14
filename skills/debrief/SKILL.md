---
name: debrief
description: "Post-interaction debrief — captures what happened in a call, meeting, or conversation and logs it to CRM. Use this skill when the user says 'debrief', 'just had a call with [name]', 'met with [name]', 'interview went...', 'spoke to [name]', 'talked to [name]', 'call went...', 'just finished a meeting', or describes a recently completed interaction with a contact. Runs 5 rapid questions, updates CRM stage with confirmation, dual logs, and sets next action with deadline. Do NOT use for meeting prep (before a meeting), outreach drafting, scheduling, or general status questions."
user-invokable: true
---

# /debrief — Post-Interaction Debrief

Execute these steps in order. Complete in <800 output tokens. Conversational first, then logging.

## Step 1: Rapid Questions
Ask all 5 at once. Wait for answers before proceeding.
1. Who did you talk to?
2. What was discussed?
3. What's their actual pain?
4. What's the agreed next step?
5. Gut feeling (1-5)?

## Step 2: CRM Stage Update
Based on answers, propose a stage change if warranted:
- Show: "Moving [lead] from [old stage] to [new stage]. Confirm?"
- Wait for explicit confirmation per behavior.md rule #14
- Call `cc_pipeline_update` only after confirmation

## Step 3: Dual Logging
Execute in parallel (no confirmation needed):
- `cc_touch_create` — log the interaction with type, channel, and summary
- Update `tracking/leads-notes.md` — qualitative notes (pain points, personality, blockers)
- Update `references/contacts.md` — set Last Contact date to today

## Step 4: Wins
If gut feeling >= 4 or a positive outcome emerged (meeting booked, proposal requested, verbal interest):
- Log to `tracking/wins.md` with date and one-line summary

## Step 4.5: Gmail/Calendar Augmentation
- If interaction was via email → `gmail_search_messages` + `gmail_read_thread` for exact context, use for CRM logging accuracy
- If follow-up meeting agreed → `gcal_find_my_free_time` for proposed timeframe, offer to `gcal_create_event` with attendees, Meet link, and description

## Step 5: Next Action
Suggest one specific next action with a calendar date deadline.
Format: "[Action] by [day, date]."

## Step 6: Learning Capture
If any insight from this debrief changes future approach (e.g., "this angle didn't land", "need to prep differently for this ICP"):
- Append to `tracking/learning-ledger.md`:
  `[DATE] SOURCE: debrief | LEARNING: [insight] | ACTION: [what changes] | STATUS: applied`
- Skip if the debrief was routine with no new learnings.
