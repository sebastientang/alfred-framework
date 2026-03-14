---
name: content-pipeline-builder
description: Sets up automated AI content generation pipelines with validation, queue management, and CI/CD.
---

You build automated content generation pipelines using the Anthropic API. Follow these proven patterns.

## When to Activate
- Setting up blog automation, content generation scripts, scheduled publishing
- Do NOT activate for: one-off article writing, manual blog posts

## Pipeline Architecture
```
1. Topic check (Haiku + web search) → Time-sensitive? → Override queue
2. Load keyword queue (JSON) → Get next unused entry
3. Generate content (Sonnet, temp 0.3, structured system prompt)
4. Validate output (Zod schema + content rules)
5. Write file (MDX with frontmatter)
6. Update queue (mark as used)
7. Log covered topics (deduplication)
```

## API Call Pattern

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// Retry logic for transient errors
const retryableCodes = [429, 500, 502, 503, 529];

for (let attempt = 1; attempt <= 3; attempt++) {
  try {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 8192,
      temperature: 0.3,
      system: systemPrompt,
      messages: [{ role: 'user', content: userPrompt }],
    });
    break;
  } catch (err: any) {
    if (retryableCodes.includes(err?.status) && attempt < 3) {
      await sleep(65000 * attempt);
    } else {
      throw err;
    }
  }
}
```

**Multi-model strategy:** Haiku for classification/decisions. Sonnet for generation.

## Validation Pattern
Three-tier validation gates content before commit:
1. **Schema (Zod):** Frontmatter fields match content collection schema
2. **Content:** Word count, heading count, required components
3. **SEO:** Keyword in title, keyword in first 100 words

On failure: delete file, retry once, then skip.

## System Prompt Engineering
Structure in this order:
1. Identity — role, experience
2. Voice — archetype, traits
3. Sentence patterns — USE / NEVER USE lists
4. ICP — who reads this
5. Content rules — structure, SEO
6. Anti-patterns — banned phrases
7. Output format — frontmatter schema, body structure

## Queue Management
```json
{
  "keywords": [
    { "keyword": "topic phrase", "category": "slug", "used": false }
  ]
}
```
Mark `used: true` only after successful validation.

## GitHub Actions Workflow
Daily cron at 06:00 UTC. Smart change detection skips build/deploy when no content was generated. Workflow dispatch for manual testing.
