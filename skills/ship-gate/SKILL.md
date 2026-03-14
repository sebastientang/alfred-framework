---
name: ship-gate
description: Release readiness review — 4 parallel agents (Secret Hunter, Documentation Judge, Dependency Auditor, First Impression Tester). Main Claude synthesizes. Ship/Hold/Fix-First verdict for pre-release audit. Use this skill when the user says "ship gate [project]", "release review [project]", "ready to ship?", or "pre-release check". Do NOT use for code review, PR review, architecture reviews (use /arch-review), or proposal stress-testing (use /war-room).
user-invokable: true
---

# Ship Gate — Release Readiness Review

## When to Use
- Before any public release (open source, npm publish, GitHub public repo)
- Triggered by "ship gate [project]" or "release review [project]"
- NOT for internal tools or private repos (use /audit-project instead)

## Inputs
The skill receives from Alfred:
- **Project:** path or name of the project to review
- **Release type:** initial release, major version, patch
- **Context:** open-source strategy stage from references/open-source-strategy.md

## Process

### Step 1: Load Context
Read these files (parallel):
- `references/open-source-strategy.md` — current stage and checklist
- Project's `package.json` (or equivalent manifest)
- Project's `README.md`
- Project's `.gitignore`
- Project's `LICENSE`
- Project's `CHANGELOG.md` (if exists)
- Project's `CONTRIBUTING.md` (if exists)

### Step 2: Read Persona Files
Read all 4 persona files from `~/.claude/skills/ship-gate/personas/`:
- `secret-hunter.md`
- `documentation-judge.md`
- `dependency-auditor.md`
- `first-impression-tester.md`

### Step 3: Spawn 4 Agents in Parallel
Use the Agent tool to spawn 4 independent agents simultaneously in a single message. No team, no inter-agent communication — these are coverage dimensions, not a debate.

Each agent receives:
- The project name and release type
- Full file listing of the project (from glob)
- Key file contents loaded in Step 1
- Their persona instructions (full content from persona file)

Agents to spawn in parallel:
1. **Secret Hunter** — scans for leaked secrets, personal data, API keys
2. **Documentation Judge** — evaluates docs quality, README, LICENSE, CONTRIBUTING
3. **Dependency Auditor** — checks deps health, licenses, vulnerabilities, pinning
4. **First Impression Tester** — simulates clone-install-run as a new user

Each agent returns a structured brief (200-400 words).

### Step 4: Main Claude Synthesizes
Main Claude receives all 4 briefs. Determine verdict based on:
- **Ship** — zero blockers, warnings are cosmetic only
- **Fix-First** — blockers exist but are fixable in < 4 hours
- **Hold** — fundamental issues that need rethinking

### Step 5: Present Verdict
Display in this format:

```
## Ship Gate: [PROJECT]

**Verdict:** [Ship / Hold / Fix-First]
**Release type:** [initial / major / patch]
**Blockers:** [count]
**Warnings:** [count]

### Secret Scan (Secret Hunter)
[findings — BLOCKER/WARNING/INFO items]

### Documentation (Documentation Judge)
[score 1-10, key issues]

### Dependencies (Dependency Auditor)
[findings — license issues, vulnerabilities, abandoned deps]

### First Impression (First Impression Tester)
[time-to-first-result, missing steps, platform issues]

### Release Checklist
- [ ] or [x] per item — secrets clean, docs complete, deps audited, clone-to-run works, LICENSE present, CHANGELOG updated

### Verdict Reasoning
[2-3 sentences explaining the verdict]

### Fix-First Items (if verdict != Ship)
1. [item — estimated fix time]
2. [item — estimated fix time]
**Estimated total fix time:** [X hours]
```

### Step 6: Log Result
After presenting, append to `tracking/release-log.md`:

```
[DATE] PROJECT: [name] | VERDICT: [Ship/Hold/Fix-First] | BLOCKERS: [count] | WARNINGS: [count] | RELEASE TYPE: [type]
```

If verdict is Ship, confirm the release can proceed.
If verdict is Fix-First, list blockers and offer to re-run after fixes.
If verdict is Hold, explain why and do not proceed.

## Token Budget
- 4 parallel agents: ~2K input + ~500 output each = ~10K
- Main Claude synthesis: ~1K (no extra agent)
- Total: ~11K tokens per Ship Gate session
- Expected frequency: ~4x/year
