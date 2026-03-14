---
name: outreach-intelligence
description: Analyze outreach patterns from 15+ entries — response rates by angle, best channels per ICP, timing optimization, zero-conversion flags.
user-invokable: true
---

# /outreach-intelligence — Data-Driven Outreach Analysis

Requires 15+ entries in `tracking/outreach-log.md`. If fewer entries exist, report count and exit.

## Step 1: Data Collection
Read in parallel:
- `tracking/outreach-log.md` — all entries
- `references/contacts.md` — ICP segments, relationship types
- Call `cc_touch_stats` — structured touch data from CRM

## Step 2: Angle Analysis
Parse outreach log for angle usage (angles 1-8 per self-optimization.md):

| Angle | Name | Sent | Responded | Rate |
|-------|------|------|-----------|------|
| 1 | Technical skills gap | N | N | N% |
| 2 | Platform foundation | N | N | N% |
| 3 | Former colleague | N | N | N% |
| 4 | Former client reactivation | N | N | N% |
| 5 | Failed implementation rescue | N | N | N% |
| 6 | Training center pitch | N | N | N% |
| 7 | Warm touch | N | N | N% |
| 8 | Custom | N | N | N% |

Flag any angle with 0% response rate after 5+ attempts.

## Step 3: Channel Analysis
Break down by channel (LinkedIn, email, WhatsApp, phone):

| Channel | Sent | Responded | Rate | Best for |
|---------|------|-----------|------|----------|
| LinkedIn | N | N | N% | [ICP segment] |
| Email | N | N | N% | [ICP segment] |
| WhatsApp | N | N | N% | [ICP segment] |
| Phone | N | N | N% | [ICP segment] |

## Step 4: ICP Segment Analysis
Break down by target type:

| Segment | Sent | Responded | Rate | Best Angle |
|---------|------|-----------|------|------------|
| ESN/SI | N | N | N% | [angle] |
| Direct client | N | N | N% | [angle] |
| Training center | N | N | N% | [angle] |
| Recruiter | N | N | N% | [angle] |

## Step 5: Timing Analysis
If enough data:
- Best day of week for responses
- Best time of day for sends
- Average response time by channel

## Step 6: Recommendations
Based on the data:
1. **Top converting angle** for each ICP segment
2. **Optimal channel** per target type
3. **Dead angles** to stop using (0% after 5+ attempts)
4. **Suggested send timing** based on response patterns
5. **Brand Bible updates** — any template changes suggested by conversion data

## Output Format
```
OUTREACH INTELLIGENCE — [YYYY-MM-DD]
Data: [N] entries analyzed

ANGLE PERFORMANCE
[table]

CHANNEL PERFORMANCE
[table]

ICP SEGMENT PERFORMANCE
[table]

DEAD ANGLES (stop using)
- [angle N: reason]

RECOMMENDATIONS
1. [Actionable recommendation]
2. [Actionable recommendation]
3. [Actionable recommendation]

BRAND BIBLE UPDATES SUGGESTED
- [If any template changes warranted]
```
