---
name: brand-voice-check
description: "Use when someone asks to check brand voice, validate content tone, review copy before publishing, or run a voice quality gate on any text."
disable-model-invocation: true
argument-hint: <text or file path>
user-invokable: true
---

## What This Skill Does

Validates any AI-generated content against Brand Bible voice rules before publishing. Works on any format: LinkedIn posts, outreach emails, proposals, website copy, training materials, case studies.

Two-pass system: regex for hard matches (free), AI for nuanced tone review (only when needed).

## Reference File

Voice rules are in [voice-rules.md](voice-rules.md). Read that file before running any checks. It contains:
- Brand voice patterns (MUST USE)
- Forbidden phrases by category — English AND French (HARD FAIL)
- Tone definition
- Content tier thresholds

## Steps

### Step 1: Receive Content

If `<text or file path>` is a file path (ends in `.md`, `.mdx`, `.txt`, or contains `/`):
- Read the file and use its contents as the content to check.

Otherwise:
- Treat `<text or file path>` as the content to check directly.

If no argument is provided, ask the user to paste content or provide a file path.

### Step 2: Strip Excluded Zones

Before scanning, remove these sections from the content (they are deliberate examples, not real voice):
- **Blockquotes**: Lines starting with `>` or content inside `<blockquote>` tags
- **Code blocks**: Fenced (```) or indented (4+ spaces) code blocks
- **Contrast examples**: Lines prefixed with `Before:`, `Bad example:`, or `Don't:`

Keep the original content intact for line references in the output. Only use the stripped version for scanning.

### Step 3: Detect Language

Auto-detect whether the content is English or French. Use common word frequency (le, la, de, les, des, est, une, pour, dans, avec → French). Default to English if ambiguous.

Apply the matching forbidden phrase set from voice-rules.md. Both English and French rulesets are available — use the one matching the detected language.

### Step 4: Count Words and Assign Tier

Count words in the stripped content. Assign tier:

| Tier | Word Count | What Gets Checked |
|------|-----------|-------------------|
| **Short** | < 500 | Forbidden phrases + exclamation marks + hedging + tone |
| **Medium** | 500 - 1500 | All above + at least 1 brand voice pattern + proof points on claims |
| **Long** | 1500+ | All above + 2+ brand voice patterns + every claim backed + no generic filler |

Display the tier and word count at the top of the output.

### Step 5: Pass 1 — Regex Scan (Zero Cost)

Run these checks deterministically. No AI calls.

**5a. Forbidden phrase scan**
Scan for every phrase listed in voice-rules.md under "Forbidden Phrases" (English or French, based on detected language). Match case-insensitively. For each match, record:
- The full line containing the match
- The specific forbidden phrase found
- A mechanical replacement:
  - Filler openers → delete the sentence or replace with a direct assertion
  - Hedging ("I think", "perhaps", "je pense que") → remove the hedge, state directly
  - Buzzwords ("leverage", "utilize") → replace with plain English/French ("use" / "utiliser")
  - False candor ("genuinely", "honestly", "sincerement") → delete the word, let the statement stand on its own
  - Exclamation marks → replace with period

**5b. Exclamation mark scan**
Find every `!` in the content. Each one is a hard fail.

**5c. Hedging language scan**
Scan for these terms (case-insensitive):

English: "I think", "perhaps", "it might be", "it could potentially", "I would argue that", "in my humble opinion", "genuinely", "honestly", "straightforward"

French: "je pense que", "peut-etre", "il se pourrait que", "on pourrait envisager", "il me semble que", "a mon humble avis", "sincerement", "honnetement", "en toute transparence", "pour etre tout a fait franc"

**5d. Brand voice pattern count** (medium and long tiers only)
Look for structural markers of the 5 brand voice patterns:
- "The problem isn't" / "The problem is" (EN) or "Le probleme n'est pas" / "Le probleme, c'est" (FR)
- "I've seen this pattern at" (EN) or "J'ai vu ce schema chez" (FR)
- "There are three ways" / "Only one of them survives" (EN) or "Il y a trois approches" (FR)
- "Most architects" / "That works until" (EN) or "La plupart des architectes" / "Ca fonctionne jusqu'a" (FR)
- Direct "[Assertion]. Here's why." (EN) or "[Assertion]. Voici pourquoi." (FR)

Count how many distinct patterns appear. Record which ones are missing.

**5e. Early exit check**
Count total hard fails from 5a + 5b + 5c. If 3 or more:
- Output all hard fails with mechanical rewrites
- Print: **"3+ hard fails found. Fix these first, then run `/brand-voice-check` again for a full tone review."**
- STOP. Do not proceed to Pass 2.

### Step 6: Pass 2 — AI Tone Review

Only runs if Pass 1 found fewer than 3 hard fails.

Use AI judgment to evaluate:

**6a. Tone drift detection**
Flag any sentence that reads like marketing copy rather than calm, authoritative analysis. Look for:
- Urgency manufacturing ("Don't miss out", "Act now", "Time is running out" / "Ne manquez pas", "Il est urgent de")
- Hype language (superlatives without evidence, breathless enthusiasm)
- Generic inspiration ("Transform your business", "Take it to the next level" / "Transformez votre entreprise")
- Passive corporate voice ("It has been determined that..." / "Il a ete determine que...")

**6b. Semantic equivalents**
Catch rephrased versions of forbidden phrases that regex missed. For example:
- "In the current [domain] ecosystem..." (variant of "In today's rapidly evolving...")
- "might want to consider" (variant of hedging)
- "optimal" used as filler (variant of buzzword padding)

**6c. Proof point quality** (medium and long tiers only)
For every claim or assertion, check if it's backed by:
- A specific client name → PASS
- A specific metric or number → PASS
- A specific outcome → PASS
- "A major client" / "significant results" / vague attribution → WARNING (insert `[CLIENT/METRIC]` placeholder in rewrite)
- Nothing at all → WARNING

**6d. Missing brand voice patterns** (medium and long tiers only)
If the content doesn't meet the tier's pattern requirement (1 for medium, 2 for long), flag as WARNING with a suggestion of where a pattern could be naturally inserted.

**6e. Generate rewrites**
For every issue found in Pass 1 AND Pass 2, provide:
```
LINE: [original line]
ISSUE: [what's wrong — hard fail or warning, and why]
REWRITE: [rewritten version in brand voice]
```

Rewrites must follow the tone definition: direct assertion, specific evidence, no hedging, calm authority. For missing proof points, use `[CLIENT/METRIC]` placeholder.

### Step 7: Output Verdict

Format the full output as:

```
## Brand Voice Check

**Content:** [first 10 words...] | **Words:** [count] | **Tier:** [Short/Medium/Long] | **Language:** [EN/FR]

---

### VERDICT: [PASS / FAIL / PASS WITH WARNINGS]

**Hard fails:** [count]
**Warnings:** [count]

---

### Issues

[For each issue, in order of appearance:]

**[FAIL/WARNING]** Line [N]:
> [original line]
[explanation of what's wrong]
**Rewrite:** [rewritten version]

---

### Summary

[One paragraph: what's working well + what needs fixing. If PASS, confirm the content is publish-ready.]
```

If the content passes with zero issues: output VERDICT: PASS and a one-line confirmation. No need for the full template.

## Filtering Rules

Output quality over output volume. Apply these filters before presenting results:

- **Binary issues (banned words, exclamation marks, hedging phrases) — always report.** These are regex-matched hard fails with no ambiguity.
- **Tone/style issues (Pass 2) — flag only if clearly wrong, not if borderline.** If you're unsure whether a sentence is "marketing copy" or just enthusiastic, skip it. False positives erode trust in the check.
- **Consolidation:** If the same issue appears 3+ times (e.g., "hedging language" on lines 4, 7, 12, 19), report once with count: "Hedging language found 4 times (lines 4, 7, 12, 19). Example: [worst instance]. Rewrite: [fix]."
- **Sort order:** Critical (banned words) → High (hard fails: exclamation marks, hedging) → Low (style suggestions, missing patterns). Present in this order.
- **No nitpicking:** Do not flag sentence rhythm, paragraph length, or subjective style preferences. Only flag what the voice rules explicitly define as wrong.

## Notes

- This skill checks content. It does not generate content.
- Rewrites are suggestions, not final copy. The user fills in `[CLIENT/METRIC]` placeholders.
- The 3+ hard fail early exit is a cost optimization. It does NOT mean 1-2 hard fails are acceptable — any hard fail = FAIL verdict.
- Do not soften the verdict. If it fails, say FAIL. The user wants honest gatekeeping, not encouragement.
- "genuinely", "honestly", and "straightforward" are false-candor markers — they signal the writer is compensating for lack of substance. Delete them; let the statement stand alone.
- "optimize" and "ecosystem" are context-dependent: acceptable when describing a specific technical action, forbidden when used as generic filler. AI Pass 2 handles this distinction.
