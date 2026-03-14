---
name: weekly-review
description: Weekly review — pulls stats from all Command Center domains, reads local tracking files, identifies patterns, runs retrospective, includes Alfred self-assessment, and fills the weekly review template.
user-invokable: true
---

# /weekly-review — Friday Review Workflow

Execute these steps in order. Complete in <4,000 output tokens. Template fill, not prose.

## Step 1: Live Stats Pull
Call these MCP tools in parallel:
- `cc_pipeline_stats` — pipeline movement and conversion
- `cc_task_stats` — task completion rates
- `cc_job_stats` — opportunity flow
- `cc_content_stats` — publishing cadence
- `cc_touch_stats` — outreach volume and response rates

Steps 1, 1.5, 2, 3, and 4 are independent — execute all in parallel.
Step 5 depends on all prior steps.

## Step 1.5: Micro-Refresh of Context Updates
Read `tracking/context-updates.md`. For each entry NOT prefixed with `[APPLIED]`:
- If tagged `[BUSINESS]` AND affects active pipeline leads or rate decisions → apply immediately to BUSINESS.md
- Mark processed entries with `[APPLIED]` prefix
- Leave `[PERSONAL]` and non-urgent `[BUSINESS]` entries for monthly full refresh

This ensures critical business context doesn't wait 30 days.

## Step 2: Session Continuity
Read `tracking/session-state.md` for current state.
If a `## Weekly Experiment` section exists, check: was the experiment run? What was the result?

## Step 3: Local Tracking Files
Read these files:
- `tracking/outreach-log.md` — full log for pattern analysis
- `tracking/leads-notes.md` — deal context
- `tracking/wins.md` — recent wins
- `tracking/admin-tasks.md` — overdue admin
- `tracking/certifications.md` — study progress
- `tracking/fitness.md` — gym accountability
- `tracking/alfred-meta.md` — time allocation and self-optimization notes
- `tracking/learning-ledger.md` — learning velocity data
- `tracking/deal-retros.md` — recent deal retrospectives

## Step 4: Business Context
Read `BUSINESS.md` for targets and current state.
Read `memory/patterns.md` for existing patterns.

## Step 5: Compute Metrics
From MCP stats + local files, calculate:
- Pipeline movement: new leads, stage changes, wins/losses this week
- Outreach conversion: messages sent vs responses vs meetings booked
- Time allocation: % revenue-direct vs other (from alfred-meta.md session logs). **Filter out lines containing `[WEEKEND]` before computing percentages** — weekend sessions are excluded from drift analysis. Report weekend activity separately: "Weekend: Xh [category], Yh [category]" (informational, no escalation).
- Content performance: posts published, engagement if available
- Task completion rate: done vs created this week

## Step 6: Pattern Analysis
Identify and surface:
- Stall stages: where leads are stuck longest
- Angle effectiveness: which outreach angles (1-8) get responses
- Channel conversion: LinkedIn vs email vs WhatsApp performance
- Time allocation drift: is revenue-direct time >= 40%? If not for 2+ weeks, escalate.
- Recurring postponements: tasks that keep getting pushed

After analysis, extract new energy/avoidance/relationship patterns to `memory/patterns.md` under the matching section. Review existing patterns in that file for staleness — remove any that no longer hold.

## Step 7: Outreach Intelligence
If outreach-log has 15+ entries (per self-optimization.md §3):
- Recommend highest-converting angle per target type
- Suggest optimal send day/time from response data
- Flag angles with 0% response rate after 5+ attempts

## Step 8: KEEP/DROP/TRY Retrospective
Replace freeform "Patterns Noticed" with structured inspect-and-adapt:

```
## Retrospective
1. KEEP: [one thing that worked this week — with evidence from stats]
2. DROP: [one thing that didn't work — with evidence, and what replaces it]
3. TRY: [one experiment for next week — specific, measurable, time-boxed]
```

Rules:
- KEEP must cite a specific stat or outcome (e.g., "Angle 7 got 2/3 responses")
- DROP must include what replaces it (never just "stop doing X")
- TRY must be testable in one week with a clear success metric

Write the TRY item to `tracking/session-state.md` under `## Weekly Experiment` (3 lines max: experiment, success metric, deadline).

Write the DROP and TRY items to `tracking/learning-ledger.md`:
- DROP → `SOURCE: weekly-review | LEARNING: [what didn't work] | ACTION: [replacement] | STATUS: applied`
- TRY → `SOURCE: weekly-review | LEARNING: [hypothesis] | ACTION: [experiment] | STATUS: pending`

## Step 9: Learning Velocity
Compute from `tracking/learning-ledger.md`:
- Count entries with STATUS=`applied` from the past 7 days
- Count entries with STATUS=`pending`
- Identify top recurring theme (group by SOURCE)

```
## Learning Velocity
- This week: [N] learnings applied (vs [N] last week)
- Pending: [N] not yet acted on
- Top recurring theme: [category]
```

Healthy: 2-4/week. Below 2 = not learning. Above 5 = early-stage or systemic issues.

## Step 9.5: Session Analytics

Read `~/.claude/session-log.jsonl`. Filter entries from the last 7 days (by `date` field).

Compute:
- **Total sessions** this week
- **Sessions by project** (group by `cwd`, show project name not full path)
- **Average duration** (from `duration_ms`, format as minutes)
- **Longest session** (project + duration)

Add to the review output:
```
## Session Analytics (last 7 days)
- Total sessions: [N]
- By project: [project1]: [N], [project2]: [N], ...
- Avg duration: [N] min
- Longest: [project] ([N] min)
```

If `~/.claude/session-log.jsonl` doesn't exist or has no entries for the period, skip this section silently.

## Step 10: Rotating Template Feedback Question
Ask ONE question per week on a 4-week cycle. Determine week number: `(ISO week number) mod 4`.

| Week mod 4 | Question |
|------------|----------|
| 0 | "Any briefing section you consistently skip?" |
| 1 | "Any info you wish the briefing included?" |
| 2 | "Any weekly review section that doesn't add value?" |
| 3 | "Any repeated manual step that should be automated?" |

Log the answer (even "no") to `tracking/alfred-meta.md` under Template Observations.
After 4 data points in Template Observations, propose a concrete template change.

## Step 11: Alfred Self-Assessment
Per self-optimization.md §9, append to output:
```
## Alfred Performance
- Skills created this week: [count]
- Template changes proposed: [count]
- Patterns surfaced that led to action: [count]
- Stale files flagged: [count]
- Avoidance detections triggered: [count]
- Items auto-logged: [count]
- Optimization proposals pending: [list]
```

## Step 12: Fill Template
Fill `templates/weekly-review.md` with all data assembled above.
Include the Retrospective, Learning Velocity, and template feedback question in the output.
Include specific adjustment recommendations for next week.
