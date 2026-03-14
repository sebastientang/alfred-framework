---
name: brand-voice-check
description: Validates content against brand voice rules — regex + AI two-pass system with tier-aware checking.
disable-model-invocation: true
argument-hint: "<text or file path>"
user-invokable: true
---

## What This Skill Does
Validates any AI-generated content against brand voice rules before publishing. Two-pass system: regex for hard matches (free), AI for nuanced tone review (only when needed).

## Reference File
Voice rules should be defined in a `voice-rules.md` file. Read that file before running checks.

## Steps

### Step 1: Receive Content
If the argument is a file path → read the file. Otherwise → use as content directly. If no argument → ask the user to paste content.

### Step 2: Strip Excluded Zones
Remove from scanning: blockquotes, code blocks, contrast examples (lines prefixed with "Before:", "Bad example:", "Don't:"). Keep original intact for line references.

### Step 3: Detect Language
Auto-detect English or French. Apply the matching forbidden phrase set.

### Step 4: Count Words and Assign Tier

| Tier | Word Count | What Gets Checked |
|------|-----------|-------------------|
| **Short** | < 500 | Forbidden phrases + exclamation marks + hedging + tone |
| **Medium** | 500-1500 | All above + brand voice patterns + proof points |
| **Long** | 1500+ | All above + every claim backed + no generic filler |

### Step 5: Pass 1 — Regex Scan (Zero Cost)

**5a.** Scan for every forbidden phrase (case-insensitive). Record matches with replacements.

**5b.** Find every `!` — each is a hard fail.

**5c.** Scan for hedging language: "I think", "perhaps", "it might be", etc.

**5d.** Count brand voice pattern markers (medium and long tiers only).

**5e.** If 3+ hard fails → output all with rewrites, stop. "Fix these first, then run again."

### Step 6: Pass 2 — AI Tone Review
Only runs if Pass 1 found fewer than 3 hard fails.

**6a.** Flag sentences that read like marketing copy rather than calm analysis.
**6b.** Catch rephrased versions of forbidden phrases.
**6c.** Check proof point quality (medium/long tiers).
**6d.** Flag missing brand voice patterns.
**6e.** Generate rewrites for all issues.

### Step 7: Output Verdict

```
## Brand Voice Check

**Content:** [first 10 words...] | **Words:** [count] | **Tier:** [tier] | **Language:** [lang]

### VERDICT: [PASS / FAIL / PASS WITH WARNINGS]

**Hard fails:** [count]
**Warnings:** [count]

### Issues
[For each: FAIL/WARNING, line, original, explanation, rewrite]

### Summary
[What's working + what needs fixing]
```

## Filtering Rules
- Binary issues (banned words, exclamation marks) — always report
- Tone issues — flag only if clearly wrong, not if borderline
- Consolidate: same issue 3+ times → report once with count
- Sort: Critical → High → Low
- No nitpicking on style preferences
