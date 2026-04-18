---
name: content-pipeline-builder
description: Sets up automated AI content generation pipelines with validation, queue management, and CI/CD. Use for blog automation, content systems, or scheduled generation tasks.
---

You build automated content generation pipelines using the Anthropic API. Follow these proven patterns extracted from a production system.

## Pipeline Architecture

```
1. News/topic check (Haiku + web search) → Time-sensitive? → Override queue
2. Load keyword/topic queue (JSON) → Get next unused entry
3. Generate content (Sonnet, temp 0.3, structured system prompt)
4. Validate output (Zod schema + content rules)
5. Write file (MDX with frontmatter)
6. Update queue (mark keyword as used)
7. Log covered topics (deduplication for future runs)
```

## API Call Pattern

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// Retry logic for transient errors
const maxRetries = 3;
const retryableCodes = [429, 500, 502, 503, 529];

for (let attempt = 1; attempt <= maxRetries; attempt++) {
  try {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 8192,
      temperature: 0.3,
      system: systemPrompt,
      messages: [{ role: 'user', content: userPrompt }],
    });
    break;
  } catch (err: any) {
    if (retryableCodes.includes(err?.status) && attempt < maxRetries) {
      await sleep(65000 * attempt); // Exponential backoff
    } else {
      throw err;
    }
  }
}
```

**Multi-model strategy:** Use Haiku for lightweight decisions (news detection, classification). Use Sonnet for heavy generation (articles, reports). This optimizes cost without sacrificing quality.

## Validation Pattern

Three-tier validation gates content before commit:

1. **Schema validation (Zod):** Frontmatter fields match content collection schema — title length, description length, category enum, tag count
2. **Content validation:** Word count (stripped of markdown/code), heading count, required component presence
3. **SEO validation:** Keyword in title, keyword in first 100 words, keyword in frontmatter

```typescript
interface ValidationResult {
  valid: boolean;
  errors: string[];
}

// On failure: delete generated file, retry once, then skip
// On success: proceed to commit
```

## System Prompt Engineering

Structure the system prompt in this order:

1. **Identity** — Who is the writer? Role, experience, expertise
2. **Voice** — Archetype, core traits (directness, reasoning style, authority)
3. **Sentence patterns** — Explicit USE / NEVER USE lists
4. **ICP** — Who reads this content? What do they need?
5. **Content rules** — Structure, linking, technical depth, SEO
6. **Anti-patterns** — Explicit list of banned phrases and patterns
7. **Terminology reference** — Static reference (do NOT use web search for verification — it's expensive and adds ~$0.30/call in accumulated context tokens)
8. **Output format** — Frontmatter schema, body structure, component imports

## Queue Management

```json
{
  "keywords": [
    { "keyword": "topic phrase here", "category": "category-slug", "used": false },
    { "keyword": "another topic", "category": "category-slug", "used": true }
  ]
}
```

Mark entries `used: true` only after successful validation. On generation failure, leave unused for retry next day.

## News Deduplication

Track covered topics with angle to prevent duplicate articles:

```json
{
  "covered": [
    { "topic": "...", "angle": "...", "date": "2026-02-11", "slug": "..." }
  ]
}
```

Prune entries older than 30 days. Same topic is OK if the angle is genuinely different.

## GitHub Actions Workflow

```yaml
on:
  schedule:
    - cron: '0 6 * * *'    # Daily at 06:00 UTC
  workflow_dispatch:         # Manual trigger for testing

permissions:
  contents: write

jobs:
  generate:
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: |
          git config user.name "Article Bot"
          git config user.email "bot@example.com"
      - env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: npx tsx scripts/generate-article.ts
      - id: commit
        run: |
          git add src/content/blog/ scripts/keyword-queue.json scripts/covered-news.json
          if git diff --staged --quiet; then
            echo "has_changes=false" >> $GITHUB_OUTPUT
          else
            git commit -m "Daily article: $(date +%Y-%m-%d)"
            git push
            echo "has_changes=true" >> $GITHUB_OUTPUT
          fi
      - if: steps.commit.outputs.has_changes == 'true'
        run: npm run build
      - if: steps.commit.outputs.has_changes == 'true'
        run: npx wrangler pages deploy dist --project-name=your-project
```

Key pattern: smart change detection skips build/deploy when no content was generated.

## MDX Safety

Auto-inject missing imports and escape curly braces in prose to prevent MDX parse errors:

```typescript
// Escape { and } in body text (outside code blocks, inline code, and JSX components)
function escapeMdxBraces(content: string): string {
  // Split frontmatter from body, only process body
  // Preserve: code blocks, inline code, JSX self-closing tags
  // Escape: bare { → {"{'}"}, bare } → {"'}'}"}
}
```
