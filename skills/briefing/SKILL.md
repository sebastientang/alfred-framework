---
name: briefing
description: "Daily morning briefing — pulls live data from Command Center, reads tracking files, re-ranks tasks with personal context, selects the frog, and fills the briefing template. Use this skill when the user says 'briefing', 'morning briefing', 'daily plan', 'start my day', 'what should I focus on today', or asks for a daily planning session. Also use when the user wants to see today's priorities, pipeline status combined with task planning, or asks for 'the frog'. Do NOT use for weekly reviews, debriefs, or simple status questions."
user-invokable: true
---

# /briefing — Daily Morning Workflow

Execute these steps in order. Complete in <3,000 output tokens. Template fill, not prose.

## Step 1: Live Data Pull
Call these MCP tools in parallel:
- `cc_snapshot_full` (refreshOura: true) — single-call batch: pipeline leads, today's tasks, new jobs (top 10), recent touches, touch stats, wellness, content, revenue, scrapers, cron. Replaces separate cc_snapshot + cc_task_today + cc_job_list calls.
- `gmail_search_messages` q: "is:unread -category:promotions -category:social" (max 10)
- `gmail_list_drafts` (max 5)
- `gcal_list_events` timeMin: today 00:00, timeMax: tomorrow 23:59, timeZone: "[YOUR_TIMEZONE]"
- `gcal_find_my_free_time` calendarIds: ["primary"], today 09:30 to 16:00 (19:00 on Wed), timeZone: "[YOUR_TIMEZONE]", minDuration: 30

**Data mapping from cc_snapshot_full response:**
- Pipeline stats + full lead list → `response.pipeline.stats` + `response.pipeline.leads`
- Today's tasks (raw) → `response.tasks.today`
- Task stats → `response.tasks.stats`
- New job opportunities (top 10) → `response.jobs.new`
- Job stats → `response.jobs.stats`
- Recent touches → `response.touches.recent`
- Touch stats → `response.touches.stats`
- Wellness/[HEALTH_TRACKER] → `response.wellness`
- Content/blog → `response.content`
- Revenue → `response.revenue`
- Scrapers → `response.scrapers`
- Cron → `response.cron`

Steps 1, 1.1, 2, 3, and 4 are all independent — execute in parallel.
Step 5 depends on Steps 3+4 results.

## Step 1.1: Email Triage
Using Gmail results from Step 1, categorize each email:
- **Action Required:** needs a reply or decision from [USER]
- **Pipeline-Relevant:** from recruiters, leads, or contacts in contacts.md
- **FYI:** newsletters, notifications, confirmations (suppress from output)

Present only Action Required and Pipeline-Relevant emails (max 5 total combined).
Flag unsent drafts older than 24h.
Pass results to Step 10 for the Inbox Triage section (placed BEFORE Revenue Action in output).

## Step 1.5: Mobile Notes Pickup
Fetch pending notes from the mobile Worker and consume them:

1. Read `~/.alfred-mobile-token`. If missing, skip this step.
2. GET `https://[YOUR_MOBILE_WORKER_URL]/api/pending-notes` with header `X-Notify-Token: <token>`.
3. If notes exist, display them grouped by category (BUSINESS/PERSONAL/NOTE).
4. Route each note to the right file:
   - Notes starting with `DEBRIEF:` → parse and append to `tracking/leads-notes.md` under the matching lead/stage section
   - Notes starting with `OUTREACH:` → append to `tracking/outreach-log.md`
   - Notes starting with `WIN:` → append to `tracking/wins.md`
   - Notes starting with `GYM:` → append to `tracking/fitness.md` with date and notes. Update session-state.md nag_gym counter.
   - Notes starting with `CERT:` → append to `tracking/certifications.md` with module, minutes, and date. Update session-state.md nag_cert.
   - Notes starting with `DESKTOP:` → do NOT route to a file. Display as "Desktop requests" section in briefing output for immediate attention.
   - Notes starting with `INCOME:` → append to `tracking/context-updates.md` with "[BUSINESS] Revenue event" prefix.
   - Notes starting with `CROSS:` → append to BOTH `tracking/context-updates.md` AND `memory/knowledge-graph.md` (under Constraints or Life Events as appropriate)
   - Notes where BOTH business AND personal keywords match (even without CROSS prefix) → treat as CROSS: route to both `tracking/context-updates.md` AND `memory/knowledge-graph.md`
   - All other notes → append to `tracking/context-updates.md` with timestamp and category
5. DELETE consumed keys by POSTing `{ "keys": [...] }` to the `/api/pending-notes` endpoint (DELETE method).
6. Report: "Synced X mobile notes."

## Step 1.6: Pipeline Cross-Reference for New Notes
After routing mobile notes (Step 1.5), cross-reference newly routed BUSINESS notes against active pipeline deals:

1. Get active deals: use pipeline data already pulled in Step 1 (`cc_snapshot` includes pipeline stages)
2. For each new BUSINESS note routed in Step 1.5, check if it mentions a lead name, company name, or deal keyword from the active pipeline
3. If match found AND note contains an actionable verb (study, research, draft, contact, prepare, build, send, follow up, check):
   - Call `cc_task_create` with lead_id, title extracted from note, category=revenue, scheduled_date=today
   - Call `cc_pipeline_update` with updated next_action
   - Report: "Auto-created task: [title] linked to [lead name]"
4. If match found but no clear action verb: flag in briefing output: "Note references [lead name] but no clear action extracted. Review: [note text]"

## Step 2: Session Continuity
Read `tracking/session-state.md` for carry-forward items from last session.

## Step 3: Local Tracking Files
Read these files (last 10 entries where applicable):
- `tracking/outreach-log.md` (last 10 entries)
- `tracking/wins.md` (last 3 entries)
- `tracking/admin-tasks.md`
- `tracking/certifications.md`
- `tracking/fitness.md` (if exists)
- `tracking/leads-notes.md`

## Step 4: Objectives
Read `goals/quarterly.md` for current quarter targets.

## Step 5: Context Files
Read `BUSINESS.md` and `PERSONAL.md` for personal context needed for re-ranking.
Do NOT load Brand_Bible_Appendix.md, frameworks.md, or cc-alfred-split.md.

## Step 5.5: Life Events Check
Read `memory/knowledge-graph.md` Life Events Calendar section. Surface any events within 30 days: "Upcoming: [event] in [N] days — [action needed]." If no upcoming events, skip silently.

## Step 5.7: Deal Retrospective Check
Check `cc_pipeline_stats` or `cc_pipeline_list` for any deals that moved to won or lost since last briefing. Cross-reference with `tracking/deal-retros.md`. If a won/lost deal has no retro entry, prompt: "Deal [name] moved to [won/lost] without a retrospective. Run the 5 questions now?"

## Step 5.8: Weekly Experiment Check
If `tracking/session-state.md` has a `## Weekly Experiment` section, surface it: "Weekly experiment: [description]. Success metric: [metric]. Check progress today."

## Step 6: Monday Nag List
If today is Monday, check these (per behavior.md rule #10):
- Language study this week ([STUDY_APP]) — if zero for 7+ days, nag
- Gym sessions (from fitness.md) — if below 4, call it out
- [YOUR_BUSINESS_ENTITY] closure progress (from admin-tasks.md) — if stale 2+ weeks, escalate with consequence
- Outreach volume (from outreach-log.md past 7 days) — if < 5, flag

If first Monday of month, add:
- "Monthly context refresh due"
- Review alfred-meta.md for pending optimization proposals

### Prescriptive Nag Actions
When a nag fires, do NOT just report the number. Inject a specific action with time slot into Today's Plan (Step 10):

| Nag | Instead of | Inject into Today's Plan |
|-----|-----------|--------------------------|
| Outreach < 5 | "Outreach: 3/5" | "Outreach: 3/5. Slot 2 messages in 9:30-10:00. Targets: [name1], [name2] from contacts.md" |
| Gym = 0 | "Gym: 0 sessions" | "Gym: 0. Block 12:00-13:30 for gym" |
| Language = 0 this week | "0 language lessons" | "10-min [STUDY_APP] in 15:00-15:15 slot" |
| [YOUR_BUSINESS_ENTITY] stale > 14d | "[YOUR_BUSINESS_ENTITY]: no progress" | "[YOUR_BUSINESS_ENTITY]: 30-min admin block in 14:30-15:00. Specific next step: [from admin-tasks.md]" |

Nag items become rows in the Today's Plan schedule, not a separate section. Use contacts.md and calendar free slots to pick specific targets and times.

## Step 7: Task Re-Ranking
Apply the Eisenhower + Revenue Filter:
1. Is it directly revenue-generating? → Deep Work block (9:30-12:00)
2. Will skipping it cause loss within 7 days? → Execution block (12:30-14:30)
3. Does it compound over time? → Schedule 30 min minimum
4. Everything else → Backlog

Factor in: today's schedule, energy ([HEALTH_TRACKER] if available, else ask), family commitments, pipeline urgency.
Select the frog (highest-impact revenue task).

### Platform Check Injection (2x/week)
Check day of week. If today is one of the 2 platform-check days this week, inject a 20-min "Platform check ([PLATFORM])" task into the Light Work block (14:30-16:00).
- Day selection: pick 2 non-consecutive days from Tue-Fri. Prefer days with the most free Light Work time (from calendar data). Default: Tue+Thu if calendar is unavailable.
- If not a platform day, skip silently.

### CV Tailoring Injection (conditional)
After processing `cc_job_list` results from Step 1, check for high-match opportunities:
- Any job with AI score >= 7, OR
- Session-state.md carry-forward mentioning "apply to [job]" or a bookmarked job

If a qualifying job exists: inject a 60-90 min "CV tailoring for [Company/Role]" task into the next available Deep Work slot (9:30-12:00). Flag it prominently in the schedule.
If no qualifying job: skip silently.

## Step 8: Relationship Decay Check
Check contacts.md Last Contact dates:
- Warm network contacts >30 days → flag for reactivation
- Active leads >7 days with no outreach → flag as going cold
- Recruiters >14 days → flag for check-in

For each flagged contact: recommend angle + channel + one-sentence talking point.
Pass top 2-3 reactivation contacts to Step 10 for integration into the unified schedule (do NOT output a separate table).

## Step 9: Wellness Check
If [HEALTH_TRACKER] readiness is in cc_snapshot:
- Below 50 → recommend light day
- Below 30 → gym-only day
Adjust task recommendations accordingly.

## Step 9.5: Sustainability Check
Compute sustainability indicators per frameworks.md. Use icons for status:
- **Physical:** Count gym sessions in fitness.md for past 7 days → green (3+) / yellow (1-2) / red (0)
- **Decision fatigue:** Count pending (unresolved) decisions in decisions/log.md → green (<3) / yellow (3-5) / red (5+)
- **Admin debt:** Count overdue items in admin-tasks.md (14+ days past deadline) → green (0) / yellow (1-2) / red (3+)
- **Isolation:** Check contacts.md for non-work social interactions in past 30 days → green (<14d) / yellow (14-30d) / red (30d+)
- **Sleep:** Use [HEALTH_TRACKER] readiness from cc_snapshot if available → green (>70) / yellow (50-70) / red (<50)

Merge Wellness (Step 9) and Sustainability into one "Health" table in the template output.

If any red: include specific intervention and time slot.
If 2+ red: reduce daily priorities from 3 to 2 and state why.
If 3+ red for 7+ days: recommend personal maintenance as priority #1 for the day.

## Step 10: Fill Template
Fill `templates/briefing.md` structure with all data assembled above. Write the filled briefing to `daily/briefing-YYYY-MM-DD.md` AND display it in the conversation.

**Section order:** Inbox Triage → Revenue Action → Pipeline (actionable only) → Today's Plan → Carry-Forward → Health → Jobs → Content → System → Nag List (Monday)

**Pipeline filtering:** Show only contacted, responded, qualifying, proposed, negotiating stages. Identified only if >7 days with no outreach. Won/Lost/Dormant excluded — Won revenue shown as totals only. Use status icons for pipeline health. Each lead gets a "next action" note.

**Unified schedule ("Today's Plan"):** Merge calendar events, frog, re-ranked tasks, reactivation contacts from Step 8, platform check (if platform day), AND CV tailoring (if qualifying job) into one time-slotted table. Slot reactivations into Light Work blocks (14:30-16:00), or first 30 min of the day if pipeline is Critical. Each reactivation row: "Reactivate [Name] via [channel]" with type "reactivation" and why "[N]d overdue, angle [N]". Platform check goes in Light Work (20 min). CV tailoring goes in Deep Work (60-90 min) with the job title and score noted.
- Deep Work: 9:30-12:00
- Lunch break: 12:00-13:00 (no gym) or 12:00-13:30 (gym day). Always block this — never schedule tasks during lunch.
- Gym is closed Mondays. On Monday briefings: use 12:00-13:00 lunch (no gym), suppress all gym mentions from Health, Nag List, and schedule. Gym nag only appears Tue-Fri.
- Execution: after lunch to 14:30
- Light Work: 14:30-16:00
- Wednesday Deep Build: 16:00-19:00

**Health section:** Merge Wellness (Step 9) + Sustainability (Step 9.5) into one compact table with status icons per row.

## Step 11: Persist Stale Contacts
Write the top 3 coldest contacts from Step 8 to `tracking/session-state.md` under `## Stale Contacts`:
- Format: `- [Name] ([category]) — [N]d, angle [N]`
- If no contacts are stale, write `- none`
