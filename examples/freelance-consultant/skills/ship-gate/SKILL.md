---
name: ship-gate
description: Release readiness review — 4 parallel agents (Secret Hunter, Documentation Judge, Dependency Auditor, First Impression Tester). Ship/Hold/Fix-First verdict.
user-invokable: true
---

# Ship Gate — Release Readiness Review

## When to Use
- Before any public release (open source, npm publish, public repo)
- NOT for internal tools or private repos

## Process

### Step 1: Load Context
Read in parallel:
- Project manifest (package.json or equivalent)
- README.md
- .gitignore
- LICENSE
- CHANGELOG.md (if exists)

### Step 2: Spawn 4 Agents in Parallel
Each agent receives the project name, file listing, and key file contents.

1. **Secret Hunter** — scans for leaked secrets, personal data, API keys
2. **Documentation Judge** — evaluates README quality, LICENSE, CONTRIBUTING
3. **Dependency Auditor** — checks deps health, licenses, vulnerabilities
4. **First Impression Tester** — simulates clone-install-run as a new user

Each returns a structured brief (200-400 words).

### Step 3: Synthesize Verdict
- **Ship** — zero blockers, warnings are cosmetic
- **Fix-First** — blockers exist but fixable in < 4 hours
- **Hold** — fundamental issues that need rethinking

### Step 4: Present

```
## Ship Gate: [PROJECT]

**Verdict:** [Ship / Hold / Fix-First]
**Blockers:** [count]
**Warnings:** [count]

### Secret Scan
[findings]

### Documentation
[score 1-10, key issues]

### Dependencies
[license issues, vulnerabilities, abandoned deps]

### First Impression
[time-to-first-result, missing steps]

### Release Checklist
- [ ] Secrets clean
- [ ] Docs complete
- [ ] Deps audited
- [ ] Clone-to-run works
- [ ] LICENSE present

### Fix-First Items (if applicable)
1. [item — estimated fix time]
```

### Step 5: Log Result
Append to release log with date, project, verdict, blocker/warning counts.
