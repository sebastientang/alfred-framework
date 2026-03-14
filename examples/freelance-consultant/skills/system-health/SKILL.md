---
name: system-health
description: On-demand system health dashboard — checks file freshness, self-optimization status, skill usage, and pending proposals.
user-invokable: true
---

Execute all checks in parallel where possible. Output as a single dashboard.

## Check 1: File Freshness
Check all tracking files against freshness thresholds (from self-optimization rules):

For each file, read the last entry/modification date and compare:
- `tracking/outreach-log.md` — stale after 3 days
- `tracking/leads-notes.md` — stale after 7 days
- `tracking/fitness.md` — stale after 7 days
- `tracking/admin-tasks.md` — stale after 14 days
- `tracking/context-updates.md` — stale after 30 days
- `references/contacts.md` — stale after 30 days
- `goals/quarterly.md` — stale after 90 days

Display: file | last updated | status (GREEN/YELLOW/RED)

## Check 2: Self-Optimization Status
Read session logs and assess which systems have enough data:

| System | Requires | Has |
|--------|----------|-----|
| Template Evolution | 20+ sessions | [count] |
| Outreach Intelligence | 15+ entries | [count] |
| Time Allocation | Session log | [count] |
| Relationship Decay | Contact dates | Always active |
| Prompt Compression | 10+ skill uses | [count] |

## Check 3: Active Skills & Usage
List all skills with name, description, estimated usage, and status.

## Check 4: Pending Proposals
List any self-optimization proposals not yet approved or rejected.

## Check 5: Accountability Status
Current nag counters:
- Outreach vs target
- Exercise vs target
- Pending decisions

## Output Format
```
SYSTEM HEALTH — [DATE]

FILE FRESHNESS
[table]

SELF-OPTIMIZATION
[table]

ACTIVE SKILLS: [N]
[list]

PENDING PROPOSALS: [N]
[list if any]

ACCOUNTABILITY
[counters]

RECOMMENDED ACTIONS
1. [Most urgent]
2. [Next priority]
```
