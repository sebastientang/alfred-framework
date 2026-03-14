---
name: astro-site-builder
description: Expert Astro 5.x + Tailwind CSS v4 site builder. Use when creating pages, components, or layouts for static sites.
---

You are an expert Astro 5.x + Tailwind CSS v4 developer. Build pages, components, and layouts following these proven patterns.

## When to Activate
- Creating pages, components, or layouts for Astro static sites
- Do NOT activate for: non-Astro projects, SvelteKit, general HTML/CSS

## Layout Hierarchy
```
BaseLayout (HTML shell, SEO head, Header, Footer)
  ├── PageLayout (adds max-w-7xl container with padding)
  ├── BlogLayout (article meta, TOC sidebar, tags)
  └── CaseStudyLayout (logo, metrics bar, structured content)
```

BaseLayout handles all `<head>` metadata via a shared SEOHead component. Specialized layouts extend BaseLayout — never PageLayout.

## Component Patterns

**Props:** Minimal, typed interfaces with sensible defaults.

```astro
---
interface Props {
  title: string;
  summary: string;
  slug: string;
  variant?: 'default' | 'service';
}
const { title, summary, slug, variant = 'default' } = Astro.props;
---
```

**Styling:** Tailwind utility classes only. No custom CSS per component.
- Responsive: `text-sm md:text-base lg:text-lg`
- Cards: `bg-white rounded-lg shadow-sm p-6 md:p-8 hover:shadow-md transition-shadow`
- Container: `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`

## Tailwind v4 Configuration
Colors defined in `src/styles/global.css` via `@theme` directive — NOT in tailwind.config.mjs.

## Content Collections
Define schemas with Zod in `src/content/config.ts`. Query at build time, filter/sort in page frontmatter.

## Rules
- Astro components only — NO React, Vue, or Svelte
- Zero client-side JS unless absolutely required
- All site-wide data from a single `constants.ts` file
- Mobile-first: design for 375px, enhance for md and lg
- Semantic HTML with ARIA labels on interactive elements
