---
name: quarterly-retro
description: Quarterly retrospective — goal scorecard, learning ledger analysis, pipeline evolution, time audit, system complexity check, STOP/START/CONTINUE decisions, new quarterly goals.
user-invokable: true
---

# /quarterly-retro — Quarterly Retrospective

Triggered: last Friday of quarter or "quarterly review". ~20 minutes. Structured, data-driven.

## Step 1: Goal Scorecard
Read `goals/quarterly.md`. For each goal:
- Status: HIT / PARTIAL / MISSED
- Evidence: specific metric, outcome, or artifact
- If MISSED: root cause in one sentence

Present as a table. Calculate hit rate: `[HIT count] / [total goals]`.

## Step 2: Learning Ledger Analysis
Read `tracking/learning-ledger.md`. Compute:
- Total entries this quarter
- Count by SOURCE (closeout, weekly-review, debrief, deal-retro, briefing)
- Count by STATUS (applied, pending, rejected)
- Top 3 learnings by impact (applied entries that changed a recurring behavior)
- Learning velocity trend: weekly averages across the quarter

Present summary table + top 3 impact learnings with before/after.

## Step 3: Pipeline Evolution
Call `cc_pipeline_stats` + `cc_pipeline_list` for quarterly view:
- Deals entered, advanced, won, lost
- Deal velocity: average days per stage transition
- Revenue closed vs target
- Win rate by angle, channel, ICP segment
- Rate trend: average discussed rate trajectory

Cross-reference with `tracking/deal-retros.md` for qualitative patterns.

## Step 4: Time Allocation Audit
Read `tracking/alfred-meta.md` SESSION entries for the quarter. Calculate:
- % per category (revenue-direct, pipeline-building, content, admin, fix, building, personal)
- Trend: did revenue-direct % improve, decline, or stay flat?
- Compare against 40% revenue-direct target
- Count fix sessions and identify recurring root causes
- Count building sessions and assess ROI (did built tools get used?)

## Step 5: System Complexity Check
Count lines in key system files:
- `.claude/rules/behavior.md`
- `CLAUDE.md`
- `.claude/rules/self-optimization.md`

If total line count grew >20% from quarter start, flag for simplification.
Check: any rules that never triggered? Any skills never used? Propose pruning.

## Step 6: Three Decisions
Based on all data above, propose:

```
## Quarterly Decisions
1. STOP: [one thing to stop doing — with evidence it didn't work]
2. START: [one new practice to adopt — with expected impact]
3. CONTINUE: [one thing working well — with evidence to keep it]
```

Each must be specific and actionable, not vague.

## Step 7: Write New Quarterly Goals
Using the retrospective data:
1. Archive current `goals/quarterly.md` to `archives/goals-YYYY-Q[N].md`
2. Draft new quarterly goals informed by:
   - What was MISSED last quarter (carry forward or drop?)
   - Pipeline trajectory and revenue needs
   - Learning patterns (what's the biggest leverage point?)
   - System health (any structural debt?)
3. Each goal: measurable, time-boxed, with a lead indicator (not just outcome)
4. Max 5 goals. Revenue goal is always #1.
5. Present for user's review before writing.

## Step 8: Output
Write to `daily/quarterly-retro-YYYY-Q[N].md`.
Update `tracking/session-state.md` with key carry-forward items.
Log to `tracking/learning-ledger.md`: any insights from the retro itself.
