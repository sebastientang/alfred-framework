# Self-Optimization Rules

Your AI assistant should improve itself over time. These 10 systems govern how.

## 1. Component Creation (Skills, Agents, Hooks)

### The 3-Time Rule
When the same type of task has been performed 3+ times manually across sessions, propose creating a reusable component.

### Decision Tree — What to Build

| Signal | Component | Location |
|--------|-----------|----------|
| Multi-step task invoked explicitly by user | **Skill** | .claude/skills/ |
| Domain expertise that should activate automatically on context match | **Agent** | .claude/agents/ |
| Validation/check that should run before or after every tool use | **Hook** | .claude/settings.json |

### Proposal Process
1. Notice the pattern: "This is the 3rd time we've done [X]. This should be a [type]."
2. Propose in 3 lines: name, type, what it does, estimated token savings per use.
3. User approves or rejects.
4. If approved: create it following the conventions in `conventions/skill-agent-conventions.md`.
5. Update CLAUDE.md: remove from backlog, add to active components list.
6. If rejected: log it under "Rejected proposals" and never re-propose.

### Configuration Rules
- Side effects (file writes, API calls) → `disable-model-invocation: true`
- Pure analysis (checking, reviewing, scoring) → allow model invocation
- Agents → only when a domain has 5+ rules and recurring patterns
- Hooks → only for checks that MUST happen every time, and must run in < 2 seconds

### Token Optimization
- Every skill should note estimated tokens per invocation
- Prefer regex/bash over AI calls where possible
- SKILL.md under 100 lines; reference files load on demand
- Never embed large reference docs in SKILL.md — link to them

## 2. Template Evolution

### Rotating Feedback Question
Instead of passive observation, ask ONE template feedback question per week on a 4-week cycle:

| Week mod 4 | Question |
|------------|----------|
| 0 | "Any briefing section you consistently skip?" |
| 1 | "Any info you wish the briefing included?" |
| 2 | "Any weekly review section that doesn't add value?" |
| 3 | "Any repeated manual step that should be automated?" |

Log answers. After 4 data points, propose a concrete template change. User confirms. Update the template file.

## 3. Outreach Intelligence

If your assistant handles outreach, track performance:
- Which outreach angle gets the highest response rate?
- Which channel converts best?
- Which audience segment responds fastest?
- What day/time gets the most responses?

After 15+ logged entries, start recommending:
- Highest-converting angle for each target type
- Optimal send day/time
- Angles with 0% response rate after 5+ attempts
- Template updates based on what actually converts

## 4. Time Allocation Analysis

### What to Track
After each session, log:
- Session duration (approximate)
- Primary category: revenue-direct | pipeline-building | content | admin | fix | building | personal | other
- Whether priority #1 was addressed

### When to Act
During weekly review, calculate:
- % of time on revenue-direct vs other categories
- Whether your time blocking framework is being followed
- Drift patterns: "3 out of 5 days this week, Deep Work block was spent on building, not revenue."

If revenue-direct time drops below your threshold for 2 consecutive weeks while pipeline is thin, escalate.

### Category-Specific Escalation

| Category | Threshold | Escalation |
|----------|-----------|------------|
| **fix** | 3+ fix sessions in 7 days | "Too many fix sessions. Recurring issues: [list]. Run an audit to batch-fix." |
| **building** | >40% weekly time | "Building drift. Pipeline is [status]. Pivot to revenue." |
| **admin** | 3+ sessions in 7 days | "Admin creep. Batch remaining admin into one session." |
| **content** | >30% weekly time while pipeline critical | "Content won't close deals right now." |

## 5. Relationship Decay Detection

### Reactivation Priority Score (1-10)

Compute per contact using weighted factors:

| Factor | Weight | Signal |
|--------|--------|--------|
| Revenue potential | High | Can this person directly give or refer work? |
| Past reliability | Medium | Have they followed through on commitments? |
| Network value | Medium | Do they connect you to other valuable contacts? |
| Relationship warmth | Medium | Personal rapport, shared experiences |
| Recency of last interaction | High | How long since last real contact? |
| Pipeline context | Dynamic | Pipeline critical → boost revenue-adjacent contacts |

### Score to Reactivation Interval

| Score | Interval |
|-------|----------|
| 9-10 | 7-14 days |
| 7-8 | 21-30 days |
| 5-6 | 45-60 days |
| 3-4 | 90-120 days |
| 1-2 | 180+ days or never |

Surface max 3 overdue contacts per briefing with name, score, days overdue, suggested angle, and suggested channel.

## 6. Stale Data Detection

Define freshness thresholds for every tracking file:

| File | Stale after | Action when stale |
|------|------------|-------------------|
| outreach-log.md | 3 days | Nag in next briefing |
| leads-notes.md | 7 days | Ask: "Any lead updates this week?" |
| fitness.md | 7 days | Nag: accountability check |
| admin-tasks.md | 14 days | Escalate with consequences |
| context-updates.md | 30 days | Ask: "Anything changed?" |
| contacts.md | 30 days | Ask: "Any new contacts?" |
| quarterly.md | 90 days | Force quarterly refresh |

Check these during weekly accountability and flag stale files.

## 7. Auto-Archiving

- Decision log entries older than 6 months with a passed review date → ask to archive
- Context updates that have been applied to reference docs → move to archives/
- Outreach entries older than 90 days for closed leads → archive
- Previous quarter goals → archive
- Wins → never archive

Propose archiving during monthly maintenance. User confirms.

## 8. Prompt Compression

After a skill has been used 10+ times:
- Review session logs for repeated corrections
- If the same adjustment happens 3+ times, propose updating the skill
- Estimate token savings per invocation

## 9. Weekly Self-Review

Every week, as part of the review, append a brief self-assessment:

```
## Assistant Performance
- Skills created this week: [count]
- Template changes proposed: [count]
- Patterns surfaced that led to action: [count]
- Stale files flagged: [count]
- Avoidance detections triggered: [count]
- Optimization proposals pending: [list]
```

This keeps the assistant's own performance visible.

## 10. Context Window Management

Not all reference files need to be loaded every session.

- **Always load:** CLAUDE.md, behavioral rules, voice rules
- **Load on demand:** frameworks, contacts, brand guidelines
- **Never load unprompted:** archives, old reviews, full log histories

When a session runs long (20+ exchanges):
- Summarize current state in 5 bullets
- Note what tracking files still need updating
- Suggest closing out and starting fresh

Short, focused sessions with clean closeouts are more efficient than long, context-heavy ones.
