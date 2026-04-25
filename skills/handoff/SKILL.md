---
name: handoff
description: Use when the user says "handoff", "session handoff", "wrap up session", "hand off", "handoff summary", or wants a structured end-of-session summary before clearing context. Produces a lean handoff baton (≤40 lines) covering active focus, pick-up pointer, open items, live state, decisions, verification, open questions, and key files. Writes the baton to .claude/PLAN.md plus a .claude/PLAN.pending marker so a SessionStart hook auto-injects it on the next session in this cwd. Different from /closeout — this is for dev work pre-`/clear`, not a business or ops session that needs file writes and commits.
---

# Session Handoff

Produce a repeatable end-of-session baton so the user can `/clear` and the next agent can resume in this cwd without re-reading anything else first.

This is a **context-handoff artifact**, not a status report. The audience is a future instance of you, not a stakeholder. The baton is current-work only, no project vision, no completed-phase history, no multi-session log.

## When to invoke

User says: "handoff", "session handoff", "wrap up session", "hand off", "handoff summary", "let's wrap up", "summarize before I clear", or any near-equivalent. Also invoke proactively if the user says they're about to `/clear` without having run it yet.

## /handoff vs /closeout

- **`/handoff`** = dev work pre-`/clear`. Chat summary plus a lean handoff baton always written to `.claude/PLAN.md` (overwriting prior content) and a `.claude/PLAN.pending` marker. The user-level SessionStart hook auto-injects the baton on the next session in this cwd, then deletes the marker. No commit. No persistent tracking-file writes. No memory writes.
- **`/closeout`** = business or ops session end. Writes session state, commits, pushes.

If the session was a dev session on a code project, use `/handoff`. If it was a business or planning session that updates persistent tracking files, use `/closeout`.

## How to produce the baton

1. **Review the full conversation**, not just the last few turns. Handoffs miss things when they only summarize recent context.
2. **Pull state from these sources (in order):**
   - Plan files referenced this session (check `~/.claude/plans/` or project-local plan files if a plan was mentioned).
   - TodoWrite / TaskList state, any in-progress or pending tasks.
   - Background processes you started with `run_in_background`, shell IDs are load-bearing for the next agent.
   - Files created or modified this session, you know what you touched, don't grep to re-discover.
   - Memory files written or updated (`~/.claude/projects/<project>/memory/`).
   - Unresolved questions, things you asked the user that never got a clear answer, or things the user asked that got deflected.
3. **Do NOT audit the filesystem.** This is synthesis of what happened in THIS session. No `git log`, no broad `Glob` sweeps. If you didn't touch it this session, it doesn't belong here.
4. **Write the handoff baton.**
   - Always write to `.claude/PLAN.md` in the current working directory. Create the directory if missing.
   - Always overwrite. Never append. Never preserve old content.
   - Use the lean schema below: ≤40 lines, sections in fixed order, "none" for empty sections.
   - Immediately after writing PLAN.md, run `touch .claude/PLAN.pending`. The user-level SessionStart hook reads this marker, injects PLAN.md into the next session, and deletes the marker. Without the marker the hook does nothing.
   - One-off fix exception: if the session was a single-file tweak with no open items, no live state, no deferrals, ask once: "Tiny session, skip the baton? (y/n)". On yes, skip both PLAN.md and the marker.
5. **Produce the output in chat.** The chat output is identical to the PLAN.md content you just wrote. The user reads it once before `/clear`, the hook injects it on the next session. Do not update memory. PLAN.md plus its marker are the only files this skill writes.

## Hard rules

1. **PLAN.md and chat are the same artifact.** Write the baton to `.claude/PLAN.md`, then echo it in chat. No separate summary, no extra retrospective. Do not write any other file. Do not update memory.
2. **Never invent state.** If a section has nothing to report, write "none", do not omit the section. Structure stability is what the SessionStart hook reader relies on.
3. **Absolute paths always.** The next agent may have a different working directory.
4. **Trust the hook for the next session.** Once PLAN.md is written and `.claude/PLAN.pending` is created, do NOT instruct the next agent to read PLAN.md in chat. The hook injects it automatically. The chat copy is for the user's review before `/clear`.
5. **Voice rules: no em dashes for emphasis, no exclamation marks, no emojis, no hype.** Terse and concrete, paths, commands, shell IDs, decisions. Match the tone of a seasoned engineer handing off at end-of-shift.
6. **Background process IDs are critical.** If you started any `run_in_background` shells, their IDs must appear in "Live state" with the kill command, the next agent cannot find them otherwise.
7. **Comma not em dash.** When separating clauses in bullet lines, use a comma or colon. Never `—`.

## Anti-patterns, do not do these

- Summarizing the last 3 turns and calling it a handoff.
- Listing files by relative path.
- Skipping the "Live state" section because "nothing is running", write "none" instead.
- Writing the handoff to `~/.claude/handoffs/` or any file other than `.claude/PLAN.md`.
- Adding a "what went well / what went poorly" retrospective. This isn't a retro.
- Recommending next steps beyond the single "Pick up here" line. The next agent decides from the baton, you just hand off.
- Appending to PLAN.md instead of overwriting. PLAN.md is not a journal.
- Writing more than 40 lines to PLAN.md. If you need more space, the content is wrong, not the cap.
- Forgetting `touch .claude/PLAN.pending` after the write. Without the marker, the SessionStart hook will not inject and the next session boots blind.

## PLAN.md schema

Fixed layout. Same sections every time, in this order. Always overwritten on /handoff, never appended. The chat output uses this exact same structure.

```md
# HANDOFF — <project name> — <YYYY-MM-DD HH:MM>

## Active focus
<1-3 lines: what we are working on right now and why it matters>

## Pick up here
<1-2 lines: single most likely first action for the fresh agent>

## Open items
- <item>, <specific next action>
- ...

## Live state
- Background processes: <shell IDs + kill command>, or "none"
- Dev servers / ports: <url + port>, or "none"
- Open branches / worktrees: <paths>, or "none"

## Decisions from this session
- <only if next session needs them, max 3>

## Verification
- `<command>`, expected outcome

## Open questions
- <question>, <blocker context>

## Key files
- `<absolute path>`, <why this is worth reading after the baton>
```

### Hard caps

- Total file ≤40 lines.
- Open items ≤5 bullets.
- Decisions ≤3 bullets, only those affecting NEXT session.
- Key files ≤4 bullets, absolute paths only.
- Every section present. Write "none" if empty.

### What NOT to put in PLAN.md

- North Star or project vision (lives elsewhere or in the user's head).
- Completed phases or sub-items (project journal, not handoff content).
- Multi-session log entries (only THIS session's handoff matters, the file is overwritten each /handoff).
- Active deferrals beyond what is actually being deferred to next session.

## Companion hook

This skill expects a SessionStart hook to be installed at `~/.claude/hooks/handoff-session-start.sh`. The hook reads `.claude/PLAN.pending` in the session's cwd, injects `.claude/PLAN.md` if the marker is present, and deletes the marker. See `hooks/handoff-session-start.sh` in this repo for the script and `hooks/README.md` for installation instructions. Without the hook installed, the skill still writes the baton but the next session must read it manually.
