---
name: closeout
description: Session closeout — updates session-state.md, logs to alfred-meta.md, commits and pushes all changes. Use this skill when the user says "done", "closing", "that's it", "/closeout", "wrap up the session", or "end session". Do NOT use for /wrap-project, /wrap-conversation, or mid-session status checks.
user-invokable: true
---

# /closeout — Session End Procedure

Execute these steps in order. Keep output to 3-5 carry-forward bullets max.

## Step 1: Check Uncommitted Work
Run `git status` to see if there are uncommitted changes.

## Step 1.5: Dual Logging Audit
Before updating session state, verify CRM sync for this session:
1. Review the conversation for any leads discussed, contacts shared, or outreach performed
2. For each lead mentioned:
   - Check if it exists in CC (`cc_pipeline_list`) — if not, create it via `cc_pipeline_create`
   - Check if the interaction was logged via `cc_touch_create` — if not, log it
3. For new contacts shared (LinkedIn screenshots, conversation summaries):
   - Ensure pipeline entry exists in CC for any qualifying/active lead
   - Log the touch that surfaced the information
4. Report: "CC sync: [N] pipeline entries verified, [N] touches logged."
If nothing was discussed that needs CRM logging, skip with: "CC sync: no CRM-relevant interactions this session."

## Step 2: Update Session State
Write `tracking/session-state.md` (max 24 lines):
- Carry-Forward: 3-5 bullets of what needs attention next session
  - Check nag thresholds and inject flags into Carry-Forward bullets:
    - If session outreach = 0 AND weekly < 3 → add "Outreach behind: [N] this week (target: 5)"
    - If gym = 0 this week → add "Gym: 0 sessions this week"
    - If cert study gap > 7 days → add "Cert study gap: [N] days"
- Pipeline: health status (Critical/Thin/Healthy) + hottest lead
- Nag Counters: cert study days since last, gym sessions this week, outreach count this week
- Pending Decisions: any unresolved decisions from this session
- Stale Contacts: preserve from previous session-state if no briefing ran this session; otherwise use briefing's Step 11 output

## Step 3: Log to Alfred Meta
Append to `tracking/alfred-meta.md`:
- Date
- Approximate session duration
- Primary category: revenue-direct | pipeline-building | content | admin | building | personal | other
- Whether priority #1 was addressed (yes/no)
- Any self-optimization observations (patterns noticed, skill candidates, template issues)

## Step 3.5: Learning Ledger
If any correction or adjustment was made during this session (visible in conversation or logged in alfred-meta.md Corrections Received):
- Append to `tracking/learning-ledger.md`:
  `[DATE] SOURCE: closeout | LEARNING: [what was corrected] | ACTION: [how behavior changed] | STATUS: applied`
- Only log meaningful corrections that change future behavior — not typo fixes or one-off clarifications

## Step 3.6: Knowledge Capture
If any cross-domain observation surfaced this session (personal fact affected a business decision or vice versa), append to `memory/knowledge-graph.md` under the appropriate section (Constraints, Life Events, Decision Precedents, or Learned Preferences). If behavioral patterns were noticed (energy, avoidance, relationship dynamics), append to `memory/patterns.md` under the matching section.

## Step 3.8: Automation Opportunity Scan

Review what was done this session. For each significant task, ask:
1. Could this run without me present? (cron, event-trigger, or always-on)
2. Could this run on a VPS with shell access + API keys?
3. Does it need Claude Code-specific tooling (Edit tool, plan mode, LSP, IDE)?

If answers are yes, yes, no — log it to `tracking/automation-study.md`.

For each opportunity, capture:
- Task name and category
- Why automation could handle it (what makes it automatable)
- Autonomy level: full / supervised / hybrid
- Rough estimate of monthly time savings if automated
- Any blockers or risks (security, quality, cost)

Skip trivial items (<5 min/month savings). Focus on patterns that repeat.
Do NOT log tasks that genuinely need Claude Code's dev tooling (multi-file refactoring, complex debugging, site building) — those stay with Claude Code.

## Step 4: Present Carry-Forward
Show the user the 3-5 carry-forward bullets. Flag any pending decisions.

## Step 4.5: Sync to Mobile
After updating session-state.md, push state to the mobile Worker. Read `~/.alfred-mobile-token` for the NOTIFY_TOKEN. If the file doesn't exist, skip this step and note: "Mobile sync skipped — no token configured."

1. **Session sync** — Run the sync script:
```bash
NOTIFY_TOKEN=$(cat ~/.alfred-mobile-token 2>/dev/null) && python3 alfred-mobile/scripts/sync-to-mobile.py tracking/session-state.md "$NOTIFY_TOKEN"
```

2. **Push notification** — Smart notification (only fires when something changed):
```bash
NOTIFY_TOKEN=$(cat ~/.alfred-mobile-token 2>/dev/null) && python3 alfred-mobile/scripts/notify-mobile.py tracking/session-state.md "$NOTIFY_TOKEN" --previous-state ~/.alfred-session-cache.json
```

## Step 5: Commit and Push
```bash
git add -A && git commit -m "session: [YYYY-MM-DD] [2-3 word summary]" && git push
```

Then stop. Do not continue the conversation after pushing.
