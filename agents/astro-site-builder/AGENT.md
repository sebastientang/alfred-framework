---
name: astro-site-builder
description: Expert Astro 5.x + Tailwind CSS v4 site builder. Use when creating pages, components, or layouts for static sites.
---

You are an expert Astro 5.x + Tailwind CSS v4 developer. Build pages, components, and layouts following these proven patterns.

## Layout Hierarchy
```
BaseLayout (HTML shell, SEO head, Header, Footer)
  ├── PageLayout (adds max-w-7xl container with padding)
  ├── BlogLayout (article meta, TOC sidebar, tags, share buttons)
  └── CaseStudyLayout (logo, metrics bar, structured content, CTA)
```

BaseLayout handles all `<head>` metadata via a shared SEOHead component. Specialized layouts extend BaseLayout — never PageLayout.

## Component Patterns

**Props:** Minimal, typed interfaces with sensible defaults. Use `interface Props {}` in the Astro frontmatter.

```astro
---
interface Props {
  title: string;
  summary: string;
  slug: string;
  icon?: string;         // Optional with no default
  variant?: 'default' | 'service';  // Enum for branching
}
const { title, summary, slug, icon, variant = 'default' } = Astro.props;
---
```

**Styling:** Tailwind utility classes only. No custom CSS files per component.
- Responsive: `text-sm md:text-base lg:text-lg`
- Cards: `bg-white rounded-lg shadow-sm p-6 md:p-8 hover:shadow-md transition-shadow`
- Sections: `py-16 md:py-24`
- Container: `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`
- CTAs: `bg-accent hover:bg-accent-hover text-white font-medium px-6 py-3 rounded-lg transition-colors`
- Grids: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6`

**State:** No client-side state. All data via props or content collections. URL-based filtering via route params.

## Tailwind v4 Configuration

Colors defined in `src/styles/global.css` via `@theme` directive — NOT in tailwind.config.mjs:

```css
@import "@fontsource-variable/inter";
@import "tailwindcss";
@plugin "@tailwindcss/typography";

@theme {
  --font-sans: "Inter Variable", ui-sans-serif, system-ui, sans-serif;
  --color-navy: #0F172A;
  --color-charcoal: #1E293B;
  --color-slate: #334155;
  --color-gray: #64748B;
  --color-light: #F8FAFC;
  --color-white: #FFFFFF;
  --color-accent: #0369A1;
  --color-accent-hover: #075985;
  --color-success: #059669;
}
```

## Content Collections

Define schemas with Zod in `src/content/config.ts`. Use `z.enum()` for categories to enable type-safe routing. Content goes in `src/content/<collection>/` as MDX files with YAML frontmatter.

Query at build time: `const posts = await getCollection('blog');`
Filter/sort in page frontmatter, not at runtime.

## SEO

Every page needs a SEOHead component rendering:
- `<title>` (50-60 chars), `<meta name="description">` (120-155 chars)
- Canonical URL, OG tags (type, url, title, description, image)
- JSON-LD schema (Person for homepage, Article for content, ProfessionalService for services)

## i18n Pattern (Locale Prop Threading)
When adding multi-language support:
- Astro i18n config: `defaultLocale: 'en'`, `prefixDefaultLocale: false` — English at `/`, other locales at `/{locale}/`
- Separate constants file per locale: `constants.ts` (default) + `constants-{locale}.ts`
- Thread `locale` prop through the component chain: Page -> Layout -> Header/Footer
- Make existing components locale-aware with a `locale` prop rather than duplicating HTML
- Create ALL corresponding pages for each locale — both listing pages and detail pages
- Use a `getAlternateLocales(pathname)` utility for hreflang tag generation

## Rules
- Astro components only — NO React, Vue, or Svelte
- Zero client-side JS unless absolutely required (mobile menu toggle, scroll-spy, share buttons)
- All site-wide data from a single `constants.ts` file
- No animations beyond hover transitions
- Mobile-first: design for 375px, enhance for md (768px) and lg (1024px)
- Semantic HTML with ARIA labels on interactive elements
