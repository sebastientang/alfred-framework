---
name: system-health
description: On-demand system health dashboard — checks freshness rules, self-optimization status, skill usage, and pending proposals.
user-invokable: true
---

# /system-health — Alfred System Health Dashboard

Execute all checks in parallel where possible. Output as a single dashboard. <2,000 output tokens.

## Check 1: File Freshness
Check all tracking files against freshness thresholds (self-optimization.md):

For each file, read the last entry/modification date and compare:
- `tracking/outreach-log.md` — stale after 3 days
- `tracking/leads-notes.md` — stale after 7 days
- `tracking/fitness.md` — stale after 7 days
- `tracking/certifications.md` — stale after 14 days
- `tracking/admin-tasks.md` — stale after 14 days
- `tracking/context-updates.md` — stale after 30 days
- `references/contacts.md` — stale after 30 days
- `goals/quarterly.md` — stale after 90 days

Display: file name | last updated | status (GREEN/YELLOW/RED)
- GREEN: within threshold
- YELLOW: within 2x threshold
- RED: beyond 2x threshold or file missing

## Check 2: Self-Optimization Systems Status
Read `tracking/alfred-meta.md` and assess which systems have enough data to fire:

| System | Requires | Has |
|--------|----------|-----|
| Template Evolution | 20+ briefings | Count from alfred-meta |
| Outreach Intelligence | 20+ outreach entries | Count from outreach-log.md |
| Time Allocation | Session log entries | Count from alfred-meta |
| Relationship Decay | contacts.md dates | Always active |
| Prompt Compression | 5+ skill uses | Count from alfred-meta |

## Check 3: Active Skills & Usage
List all skills in `~/.claude/skills/` with:
- Name and description (from SKILL.md frontmatter)
- Estimated usage count (from alfred-meta.md if tracked)
- Status: active / backlog / rejected

## Check 4: Pending Proposals
Read `tracking/alfred-meta.md` for any pending self-optimization proposals that haven't been approved or rejected.

## Check 5: Nag Status
Read session-state.md for current nag counters:
- Outreach this week vs target (5)
- Gym sessions vs target (4)
- Cert study status
- Pending decisions

## Output Format
```
ALFRED SYSTEM HEALTH — [YYYY-MM-DD]

FILE FRESHNESS
[table with file | last updated | status]

SELF-OPTIMIZATION
[table with system | data needed | data available | status]

ACTIVE SKILLS: [N] | BACKLOG: [N]
[list]

PENDING PROPOSALS: [N]
[list if any]

NAG STATUS
- Outreach: [N]/5
- Gym: [N]/4
- Cert: [status]
- Pending decisions: [N]

RECOMMENDED ACTIONS
1. [Most urgent freshness issue]
2. [Next priority]
3. [If applicable]
```
