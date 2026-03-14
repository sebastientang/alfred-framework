---
name: refresh-keyword-queue
description: Generate new SEO keyword candidates for the content pipeline queue, validate against existing articles, and create in Command Center D1 via MCP.
user-invokable: true
argument-hint: "[count] [language:en|fr]"
---

Generate new keyword candidates for the content pipeline queue. If a count was specified ($ARGUMENTS), generate that many total keywords distributed across categories. Otherwise, generate enough to bring each category to at least 5 unused keywords. Language defaults to 'en' unless specified (e.g., "10 language:fr").

## Step 1: Read existing context

Get current keyword state from Command Center:

1. Call `cc_content_stats` to see current keyword counts by category and language
2. Call `cc_keyword_list` with `used=false` and `language` filter (e.g., `language: "en"`) to see existing unused keywords

Also read blog context:

- `src/content/config.ts` in the blog project — blog category enum (the valid categories)
- `scripts/prompts/system-prompt.md` in the blog project — ICP definition, voice profile, content rules

Scan existing blog articles to extract existing titles and keywords (to avoid overlap).

## Step 2: Count unused keywords per category

Using `cc_content_stats` data, show the current state:

```
Category                    Unused (EN)  Unused (FR)  Target
[category-1]                N            N            5
[category-2]                N            N            5
[category-3]                N            N            5
[category-4]                N            N            5
[category-5]                N            N            5
```

If a specific count was provided via $ARGUMENTS, distribute that count proportionally across categories that are below target. Otherwise, calculate how many are needed to reach 5 unused per category for the target language.

## Step 3: Generate keyword candidates

For each category that needs keywords, generate candidates following these rules:

**Format:**
- 3-6 words per keyword phrase
- Domain-specific terminology (use current product names from system-prompt.md)
- Long-tail SEO style: specific enough to rank, broad enough to write 1000-2200 words about
- Match the existing keyword style in the queue
- For non-EN keywords: use natural phrasing, not literal translations of EN keywords

**ICP alignment** (from system-prompt.md):
- Match the ICP definitions in your content pipeline configuration

**Deduplication — do NOT generate keywords that:**
- Already exist in D1 keyword_queue (used or unused, any language)
- Are too similar to existing keywords (>70% word overlap)
- Match existing article titles or keywords from frontmatter
- Are generic or not actionable

**Category guidance:**
- Follow the category definitions in your blog's content configuration

## Step 4: Validate candidates

For each generated keyword:

1. **Uniqueness check** — confirm it doesn't overlap with any existing keyword or article title
2. **Category fit** — confirm the keyword belongs to the assigned category
3. **Specificity check** — reject keywords that are too broad or too narrow
4. **Write-ability check** — confirm you could write a 1000-2200 word article with 3+ H2 sections on this topic

Discard any keyword that fails validation. Generate replacements if needed to hit the target count.

## Step 5: Create keywords in Command Center

For each validated keyword, call `cc_keyword_create`:

```
keyword: "the keyword phrase"
category: "category-slug"
language: "en" or "fr"
```

Create them one by one. The tool returns the created keyword with its D1 ID.

## Step 6: Print summary

```
## Keyword Queue Refresh

### Added
- [category-1]: N new keywords (LANG)
- [category-2]: N new keywords (LANG)
- [category-3]: N new keywords (LANG)

### Queue Health
- Total keywords: N (N used, N unused)
- EN: N unused | FR: N unused
- Weeks of runway: ~N weeks (at ~3 articles/week)

### New Keywords
1. "keyword phrase" (category, lang)
2. "keyword phrase" (category, lang)
...
```

### Rules
- Never modify existing keywords in the queue (don't change `used` status, don't rename)
- Prefer keywords that solve a specific ICP problem over general educational content
- Avoid time-sensitive keywords that will expire — those are handled by the news-reactive pipeline
- Each keyword should be unique enough to generate a distinct article — no near-duplicates
- JSON files in the blog project are now legacy — all keyword operations go through Command Center D1
