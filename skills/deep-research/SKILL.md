---
name: deep-research
description: "Perplexity research on any domain/topic — project-agnostic, adapts context dynamically from the session. Auto-select model: sonar (quick), sonar-pro (focused), sonar-reasoning-pro (analysis), sonar-deep-research (full expertise). Produces structured reference files in references/expertise/. Also suggest when: user researches unfamiliar domain, meeting prep reveals knowledge gaps, proposal needs domain expertise, job review surfaces unknown tech."
user-invokable: true
argument-hint: "[topic or domain]"
---

Research "$ARGUMENTS" using Perplexity API with smart model selection, then assemble a structured reference file.

## Step 1: Setup

Check that `$PERPLEXITY_API_KEY` is set:

```bash
if [ -z "$PERPLEXITY_API_KEY" ]; then echo "MISSING: export PERPLEXITY_API_KEY=your-key in ~/.zshrc"; exit 1; fi
echo "API key found."
```

Create the expertise directory if needed:

```bash
mkdir -p references/expertise
```

Normalize the argument to a file-safe slug (lowercase, spaces/underscores to hyphens, strip non-alphanum):

```bash
SLUG=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9-]//g')
echo "Slug: $SLUG"
```

If `references/expertise/$SLUG.md` already exists, ask the user: overwrite or pick a different topic.

### Model Selection

Select the Perplexity model based on context:

| Research Type | Model | When to Use |
|---|---|---|
| Quick fact check | `sonar` | Simple factual question, need fast answer |
| Focused domain scan | `sonar-pro` | Thorough search on a focused topic, not full deep dive |
| Analysis / comparison | `sonar-reasoning-pro` | Need reasoning, not just facts (e.g., "compare X vs Y") |
| Full expertise deep dive | `sonar-deep-research` | Building a reference file, comprehensive domain knowledge |

**Auto-select logic:**
1. If user said "quick search", "quick check", or "fact check" → `sonar`
2. If user said "compare", "analyze", "which is better", "pros and cons" → `sonar-reasoning-pro`
3. If user said "scan", "overview", "summary" → `sonar-pro`
4. If invoked via `/deep-research` with no qualifier → `sonar-deep-research`
5. If output target is a reference file → `sonar-deep-research`

Present the selected model to the user: "Using [model] for this research. Change? (sonar / sonar-pro / sonar-reasoning-pro / sonar-deep-research)"

Proceed after confirmation or 5 seconds.

## Step 2: Research

### Context Rules

Set `CONTEXT` to a single functional sentence — what the user needs to evaluate or decide. This goes in the **user prompt** (not system prompt) because Perplexity's search engine only processes user messages.

- 1 sentence max, decision-relevant framing only
- NO personal details (name, location, job title, tool names)
- Example good: `"Evaluating for autonomous multi-business automation on self-hosted VPS"`
- Example bad: `"[NAME] is a freelance Solution Architect in [CITY] building an executive assistant system..."`
- If no useful context exists, omit `CONTEXT` entirely

### Perplexity API Best Practices (from official docs)

- **System prompt controls style/tone/language ONLY** — Sonar's search engine does NOT process it
- **User prompt drives the search** — put all search-relevant context and specificity there
- Be specific and contextual in user prompts: "Explain recent advances in X for Y" >> "Tell me about X"
- `sonar-deep-research` supports `--reasoning-effort`: low | medium (default) | high
- Keep system prompts concise — long system prompts waste tokens without improving search

### Call the API

```bash
# CONTEXT should be set by Claude before this block runs (1 sentence max, functional only).
# If unset, research runs without contextual framing.

# System prompt: style/format ONLY (short, <500 chars). No context, no search guidance.
SYSTEM_PROMPT="You are a research analyst. Structure output in clear markdown with:
## Overview (2-3 sentences)
## Key Sections (3-6 logical sections with specifics, frameworks, anti-patterns)
## Quick Reference (table: Situation | Approach | Key Move)
## Pitfalls (table: # | Mistake | Why It Fails)
Be specific and practical. Named frameworks where they apply. No generic advice."

# User prompt: all search-relevant content goes HERE — this drives the actual web search.
USER_QUERY="Research \"$ARGUMENTS\" comprehensively. Cover all key aspects, frameworks, techniques, and pitfalls.$([ -n \"$CONTEXT\" ] && echo " Context: $CONTEXT")"

# Add --reasoning-effort for deep-research model
EFFORT_FLAG=""
if [ "$MODEL" = "sonar-deep-research" ]; then
  EFFORT_FLAG="--reasoning-effort high"
fi

python3 ~/.claude/scripts/perplexity-search.py \
  "$USER_QUERY" \
  "$MODEL" \
  "$RECENCY" \
  --system "$SYSTEM_PROMPT" \
  $EFFORT_FLAG
```

For time-sensitive topics, set `RECENCY` to a date string like "2025-01-01" before calling.

## Step 3: Assemble + Present

Parse the API response. Structure into `references/expertise/$SLUG.md`:

```markdown
# [TOPIC] — Expert Reference

> Auto-generated via /deep-research on [DATE]. Model: [MODEL_USED].
> $([ -n "$CONTEXT" ] && echo "Context: $CONTEXT" || echo "General research — no project-specific context.")

[API response content, already structured by the system prompt]

## Sources
[Citations from API response, numbered list with URLs]
```

If the API response doesn't perfectly match the expected structure (possible with sonar/sonar-pro), reformat it to match. The `sonar-deep-research` model will produce the most comprehensive output.

Write the file. Do NOT add it to git yet — the user should review first.

Present to the user:
- File created: `references/expertise/$SLUG.md`
- Model used and why
- Key sections covered (list)
- Key frameworks discovered (top 5)
- Suggest: "Review the file, then run `/generate-expert-agent $SLUG` to create an auto-activating agent."
