---
name: deep-research
description: "Research any domain/topic via Perplexity API with smart model selection. Produces structured reference files in references/expertise/."
user-invokable: true
argument-hint: "[topic or domain]"
---

Research "$ARGUMENTS" using Perplexity API with smart model selection, then assemble a structured reference file.

## Step 1: Setup

Check that `$PERPLEXITY_API_KEY` is set:
```bash
if [ -z "$PERPLEXITY_API_KEY" ]; then echo "MISSING: export PERPLEXITY_API_KEY=your-key"; exit 1; fi
```

Create the expertise directory if needed:
```bash
mkdir -p references/expertise
```

Normalize the argument to a file-safe slug.

### Model Selection

| Research Type | Model | When to Use |
|---|---|---|
| Quick fact check | `sonar` | Simple factual question |
| Focused domain scan | `sonar-pro` | Thorough search on a focused topic |
| Analysis / comparison | `sonar-reasoning-pro` | Need reasoning, not just facts |
| Full expertise deep dive | `sonar-deep-research` | Building a comprehensive reference file |

**Auto-select logic:**
1. "quick search", "fact check" → `sonar`
2. "compare", "analyze", "pros and cons" → `sonar-reasoning-pro`
3. "scan", "overview" → `sonar-pro`
4. Default `/deep-research` → `sonar-deep-research`

Present the selected model. Allow override.

## Step 2: Research

### Context Rules
Set a single functional sentence as context — what the user needs to evaluate or decide. This goes in the user prompt because Perplexity's search engine only processes user messages.

- 1 sentence max, decision-relevant framing only
- NO personal details (name, location, job title)
- If no useful context exists, omit entirely

### Perplexity API Best Practices
- System prompt controls style/tone ONLY — search engine does NOT process it
- User prompt drives the search — put all specificity there
- Be specific: "Explain recent advances in X for Y" >> "Tell me about X"

### Call the API
Use your Perplexity search script or direct API call with the selected model. Structure the system prompt to request: Overview, Key Sections, Quick Reference table, Pitfalls table.

## Step 3: Assemble + Present

Write to `references/expertise/$SLUG.md`:

```markdown
# [TOPIC] — Expert Reference

> Auto-generated via /deep-research on [DATE]. Model: [MODEL].

[Structured content from API response]

## Sources
[Citations with URLs]
```

Present to the user:
- File created path
- Model used and why
- Key sections covered
- Key frameworks discovered
- Suggest: "Review the file, then create an agent if this domain warrants one."
