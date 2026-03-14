---
name: audit-project
description: Comprehensive project audit across 11 domains (structure, config, content, SEO, security, build, links, accessibility, performance, pipeline, live site) — auto-fixes issues and reports what needs manual attention. Use this skill when the user says "audit project", "project audit", "check project health", or "audit this repo". Do NOT use for code review, PR review, release reviews (use /ship-gate), or system health checks (use /system-health).
user-invokable: true
---

Run a comprehensive audit of the current project. For every issue found, fix it immediately if possible. Only flag issues that require human judgment as manual action items. At the end, commit all fixes and produce a structured report.

Read `~/.claude/CLAUDE.md` first — it defines the coding standards, conventions, and patterns to audit against. Also read the project's CLAUDE.md if it exists.

Track three lists as you work:
- **fixed**: issues you found and resolved
- **manual**: issues that need human judgment
- **passed**: checks that passed cleanly

## Step 1: Structure & Architecture

Scan the project directory structure using Glob and Read.

**Check:**
- Required directories exist: `src/`, `src/layouts/`, `src/components/`, `src/pages/`, `src/styles/`, `src/utils/`, `public/`
- Layout hierarchy follows convention: BaseLayout (HTML shell) → PageLayout (container) → specialized layouts (Blog, CaseStudy, etc.)
- Components organized by domain: `layout/`, `home/`, `blog/`, `shared/`, `case-studies/`, `services/`
- No source code (.ts, .astro, .tsx) in `public/` — only static assets
- No orphan components (imported nowhere — grep for the component name across all files)

**Fix:** Create missing directories. Move misplaced files. Remove orphan files after confirming they're truly unused.

## Step 2: Configuration Consistency

Read all config files: `astro.config.*`, `tsconfig.json`, `tailwind.config.*`, `package.json`, `.gitignore`, `.prettierrc`.

**Check:**
- `astro.config.*`: `site` URL is set (not placeholder), integrations include sitemap and mdx, vite plugin for tailwind configured
- `tsconfig.json`: extends `astro/tsconfigs/strict` (strict mode)
- Tailwind colors defined via `@theme` directive in `src/styles/global.css`, NOT in `tailwind.config.*`
- `package.json`: has `dev`, `build`, `preview` scripts; no duplicate dependencies between `dependencies` and `devDependencies`
- `.gitignore`: includes `.env*`, `dist/`, `.astro/`, `node_modules/`, `.wrangler/`
- `.prettierrc`: exists

**Fix:** Add missing `.gitignore` entries. Move colors from tailwind.config to global.css `@theme` block. Add missing package.json scripts. Fix tsconfig extends if wrong.

## Step 3: Content & Frontmatter Validation

Read `src/content/config.ts` to understand the Zod schemas. Then read every MDX file in `src/content/` and validate frontmatter against the schema.

**Check for blog posts:**
- title: 30–60 characters
- description: 120–155 characters
- pubDate: valid date, not in the future
- category: matches one of the defined enum values
- tags: array of 2–5 strings
- keyword: present, appears in the title, appears in the first 100 words of the body
- Body: 1000–2200 words
- H2 headings: at least 3
- CTABlock: import statement present AND component used in body
- draft: if `true`, should not be in production (flag for review)
- Filename: no date prefix (should be `{slug}.mdx`, not `YYYY-MM-DD-{slug}.mdx`)

**Check for case studies:**
- All required fields populated: title, client, logo, industry, services, duration, headline, metrics, order
- Logo path points to an existing file in `public/`
- Order values are unique (no duplicates)
- Metrics array has at least 1 entry

**Fix:** Adjust title/description length. Add missing CTABlock import. Fix keyword placement if missing from first 100 words. Correct frontmatter field types. Remove date prefixes from filenames (update any internal references too).

## Step 4: SEO & GEO

Read `public/robots.txt`, `public/llms.txt`, `src/components/shared/SEOHead.astro`, `src/pages/rss.xml.ts`, and `astro.config.*`.

**Check:**
- `robots.txt`: explicitly allows AI crawlers (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, anthropic-ai, ChatGPT-User, CCBot)
- `robots.txt`: references sitemap URL
- `llms.txt`: exists, contains site description, services, and key page URLs
- Sitemap: `@astrojs/sitemap` in astro.config integrations
- RSS: `rss.xml.ts` exists in `src/pages/`, generates feed with all published articles
- SEOHead component includes: `<title>`, `<meta name="description">`, canonical URL, OG tags (type, url, title, description, image), Twitter card tags
- JSON-LD schemas present: Person (homepage), Article (blog posts with datePublished, dateModified, speakable, BreadcrumbList), ProfessionalService (services page)
- Citation meta tags on articles: `citation_title`, `citation_author`, `citation_publication_date`, `citation_journal_title`
- Every page passes SEOHead a title (50–60 chars) and description (120–155 chars)
- Blog URLs are dateless: `/blog/{slug}/` (no date segments)

**Fix:** Add missing crawler rules to robots.txt. Create llms.txt if missing. Add missing JSON-LD schemas. Add missing citation meta tags. Add missing OG tags. Fix sitemap reference.

## Step 5: Security

Scan all source files for security issues.

**Check:**
- No hardcoded secrets: grep for patterns like `sk-ant-`, `sk-`, `api_key`, `apiKey`, `API_KEY`, `token`, `secret`, `password`, `Bearer ` followed by actual values (not env var references)
- `.env*` patterns in `.gitignore`
- No `.env` files accidentally committed (check git status)
- GitHub Actions workflows: secrets referenced as `${{ secrets.NAME }}`, never echoed to logs
- No `eval()` calls in source
- No unsafe `innerHTML` or `set:html` without sanitization on user-controllable data
- All external URLs use HTTPS (not HTTP) — grep for `http://` excluding localhost
- No open redirect patterns (dynamic redirects based on query params)

**Fix:** Remove hardcoded secrets and replace with env var references. Add missing `.gitignore` entries. Upgrade `http://` URLs to `https://`. Remove unsafe `eval()` calls.

## Step 6: Build & Deploy

Run the actual build and inspect workflow files.

```bash
npm run build
```

**Check:**
- Build completes without errors
- All GitHub Actions workflow files (`.github/workflows/*.yml`) are valid YAML
- Deploy workflow: triggers on push to main, skips bot commits (`github.actor != 'github-actions[bot]'`)
- Daily article workflow (if exists): has cron schedule, concurrency group, change detection (`git diff --staged --quiet`), keyword queue alert
- Watchdog workflow (if exists): timing offset from main cron (at least 2 hours later)
- All workflows reference secrets correctly (no hardcoded values)
- Workflow steps use pinned action versions (e.g., `actions/checkout@v4`, not `@main`)

**Fix:** Fix build errors (missing dependencies, type errors, config issues). Fix YAML syntax errors. Pin unpinned action versions. Add missing bot-commit skip condition.

## Step 7: Links & References

Scan all Astro pages, components, layouts, and MDX content for internal links and references.

**Check:**
- Every internal link (`href="/..."`) points to a page that exists in `src/pages/`
- Every image `src` attribute points to a file that exists in `public/` or `src/`
- Every frontmatter `logo` or `image` path resolves to an existing file
- Every `import` statement resolves to an existing module
- Constants: `NAV_ITEMS` href values match actual pages, `CLIENT_LOGOS` paths match actual files in `public/`
- MDX content: internal links to `/blog/{slug}` or `/case-studies/{slug}` point to existing content files
- No links to pages that were renamed or deleted

**Fix:** Correct broken internal link paths. Fix image references. Update constants with correct paths. Remove dead links from MDX content.

## Step 8: Accessibility & Semantic HTML

Read all layout files, page files, and component files.

**Check:**
- Semantic elements used appropriately: `<nav>` for navigation, `<main>` for main content (exactly one per page), `<article>` for blog/case study content, `<section>` for logical sections, `<footer>` for footer
- Every `<img>` has a non-empty `alt` attribute
- Every icon-only button has `aria-label`
- Navigation has `aria-label` (e.g., "Main navigation")
- Mobile menu has appropriate ARIA: `aria-expanded`, `aria-controls`, role
- Exactly one `<h1>` per page
- Heading hierarchy: no skipped levels (e.g., h1 → h3 without h2)
- Interactive elements are focusable and keyboard-accessible
- Skip-to-content link (nice-to-have)

**Fix:** Add missing `alt` attributes (derive from filename/context — use descriptive text like "L'Occitane logo" for logos, not just "logo"). Add missing `aria-label` attributes. Fix heading hierarchy by adjusting heading levels. Add `<main>` wrapper if missing.

## Step 9: Performance

Scan for performance issues.

**Check:**
- No unnecessary client-side JavaScript: check for `<script>` tags and `client:*` Astro directives (only allow where truly needed — e.g., interactive TOC, share buttons, mobile menu)
- Fonts self-hosted via `@fontsource-variable` (grep for Google Fonts CDN URLs — `fonts.googleapis.com`, `fonts.gstatic.com`)
- `sharp` in dependencies (image optimization)
- No unused dependencies: for each dependency in package.json, grep for its import/require across source files
- Large files in `public/`: flag anything > 500KB
- No inline `<style>` blocks that duplicate Tailwind utilities

**Fix:** Remove Google Fonts CDN references and ensure `@fontsource-variable` is used. Remove unused dependencies from package.json. Remove redundant inline styles.

## Step 10: Content Pipeline Health

Only run this step if `scripts/generate-article.ts` exists.

**Check:**
- `scripts/keyword-queue.json`: exists, has valid JSON structure, count unused keywords (flag if < 7)
- `scripts/covered-news.json`: exists, has valid JSON, no entries older than 30 days
- `scripts/validate-frontmatter.ts`: exists, validates all fields from the Zod schema in `src/content/config.ts`
- `scripts/prompts/system-prompt.md`: exists, contains identity section, voice section, content rules, anti-patterns
- `generate-article.ts`: retry logic uses correct status codes `[429, 500, 502, 503, 529]`, backoff is `65000 * attempt`
- `generate-article.ts`: uses Haiku for news check, Sonnet for generation
- `generate-article.ts`: escapes MDX curly braces, auto-injects CTABlock import

**Fix:** Prune stale entries (> 30 days) from covered-news.json. Fix incorrect retry status codes. Fix incorrect backoff timing. Add missing validation checks to validate-frontmatter.ts.

## Step 11: Live Site Health

Only run this step if `astro.config.*` has a `site` URL defined (not a placeholder like `https://REPLACE_WITH_DOMAIN`). Read the config to extract the production URL.

This domain checks the **deployed site**, not the source code. Use WebFetch to probe key URLs.

**Check:**
- Homepage (`/`) — loads successfully, contains expected content (site title, navigation)
- Sitemap (`/sitemap-index.xml`) — exists, is valid XML, contains page entries
- RSS feed (`/rss.xml`) — exists, contains the most recent blog article
- robots.txt (`/robots.txt`) — exists, includes AI crawler allow rules
- llms.txt (`/llms.txt`) — exists, contains site description and services
- Key pages (`/blog/`, `/services/`, `/case-studies/`, `/contact/`) — all return valid content
- Latest blog post — derive URL from most recent article in `src/content/blog/`, fetch it, confirm it loads
- 404 handling (`/this-page-does-not-exist-audit-check`) — returns custom 404 page, not a generic error

For each URL, use WebFetch with a simple prompt: "Does this page load correctly? Is the content present and well-formed? Return YES or NO with details."

**Fix:** Nothing — live site issues are symptoms of source code or deployment problems already addressed in Steps 1–10. All failures here are flagged as manual action items.

**Flag as manual:**
- Any URL returning an error or empty content
- RSS feed missing the latest article
- Sitemap missing expected pages
- 404 page not rendering the custom template
- robots.txt or llms.txt missing from deployed site despite existing in `public/`

## Step 12: Final build verification

If any files were modified during the audit, run the build again to confirm all fixes are valid:

```bash
npm run build
```

If the build fails after fixes, investigate and resolve the new errors before proceeding.

## Step 13: Commit and push

If any files were modified during the audit:

```bash
git add -A
git commit -m "audit: fix [brief summary of what was fixed]"
git push
```

If no files were modified, skip this step.

## Step 14: Print report

Print the final audit report:

```
## Audit Report: [project-name]
Date: [today's date]
Domains checked: 11

### Fixed (N issues)
- [DOMAIN] Description of what was found and fixed — file:line

### Manual action required (N items)
- [DOMAIN] Description of what needs human attention — file:line

### Passed (N checks)
- [DOMAIN] What was checked and passed
```

If the fixed list is empty, print "No issues found — project is clean."
If the manual list is empty, print "No manual action items."

### Rules
- Fix everything you can. Only flag as manual if it genuinely requires human judgment (choosing alt text for ambiguous images, deciding whether to remove a page, adding new keyword queue entries).
- Never delete content files (blog posts, case studies) without explicit confirmation — flag as manual instead.
- Never modify the meaning of content — only fix structural/technical issues.
- When fixing frontmatter, preserve the author's intent (e.g., don't rewrite their title, just adjust length if needed).
- When adding alt text, derive it from context (filename, surrounding text, component purpose) — never use generic text like "image" or "photo".
- Run the build twice if you made fixes — once to identify issues, once to confirm fixes work.
- Adapt checks to the project's tech stack. Skip domains that don't apply (e.g., skip pipeline checks if no generation scripts exist, skip case study checks if no case studies collection exists).
