---
name: setup-content-pipeline
description: Set up automated AI blog article generation with Anthropic API, validation, keyword queue, and GitHub Actions daily cron.
user-invokable: true
argument-hint: "[voice-description]"
---

Set up an automated content generation pipeline for this project. The voice/persona description is: $ARGUMENTS

## Step 1: Install dependencies
```bash
npm install -D @anthropic-ai/sdk tsx
```

## Step 2: Create `scripts/generate-article.ts`

Build the generation script with:
- Anthropic SDK client initialization from `process.env.ANTHROPIC_API_KEY`
- News check function using Haiku 4.5 + web_search tool (time-sensitive topic detection)
- Keyword queue loader from `scripts/keyword-queue.json`
- Article generation using Sonnet 4.5, temperature 0.3 (NO web search — use static terminology reference instead)
- Retry logic: 3 attempts, retryable status codes [429, 500, 502, 503, 529], wait 65s * attempt
- MDX brace escaping function (prevents parse errors from bare { } in prose)
- Auto-inject CTABlock import if missing
- Validation via imported `validateArticle()` function
- On success: write MDX file, update keyword queue
- On failure: delete file, retry once, then exit

## Step 3: Create `scripts/validate-frontmatter.ts`

Build validation matching the content collection schema:
- Parse YAML frontmatter from MDX file
- Validate against Zod schema (title length, description length, category enum, tag count)
- Check word count (strip markdown/code/HTML, count words) — target: 1000-2200
- Check H2 heading count (minimum 3)
- Check keyword in first 100 words
- Check CTABlock component and import presence
- Return `{ valid: boolean, errors: string[] }`

## Step 4: Create `scripts/keyword-queue.json`

Populate with 25-30 keywords organized by content category:
```json
{
  "keywords": [
    { "keyword": "topic keyword phrase", "category": "category-slug", "used": false }
  ]
}
```

Ask the user for their content categories and target topics if not clear from the voice description.

## Step 5: Create `scripts/covered-news.json`

Initialize the deduplication log:
```json
{ "covered": [] }
```

## Step 6: Create `scripts/prompts/system-prompt.md`

Build the system prompt based on the voice description ($ARGUMENTS):

1. **Identity block** — Who is the writer? Background, expertise, years of experience
2. **Voice definition** — Archetype, core traits (3-6), sentence patterns (USE / NEVER USE)
3. **ICP** — Who reads this content? 2-3 personas
4. **Content rules** — Technical depth expectations, linking strategy, SEO requirements
5. **Mandatory structure** — Hook → Problem → Solution → Pitfalls → Takeaways → CTA
6. **Anti-patterns** — Explicit list of banned phrases and patterns
7. **Terminology reference** — Static reference for domain-specific terms (no web search)
8. **Frontmatter requirements** — Exact YAML schema with constraints
9. **Output format** — MDX with import statement, component at end

## Step 7: Create `.github/workflows/daily-article.yml`

```yaml
name: Daily Article Generation

on:
  schedule:
    - cron: '0 6 * * *'  # 06:00 UTC — adjust as needed
  workflow_dispatch:

permissions:
  contents: write

jobs:
  generate:
    runs-on: ubuntu-latest
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
```

Add deployment step based on the project's hosting (Cloudflare Pages, Vercel, Netlify, etc.).

## Step 8: Remind user

Print these setup instructions:
1. Add `ANTHROPIC_API_KEY` to GitHub repository secrets (Settings → Secrets → Actions)
2. If deploying from workflow, also add hosting provider credentials
3. Test with manual trigger: Actions → Daily Article Generation → Run workflow
4. Monitor first few runs to verify article quality and validation pass rate
