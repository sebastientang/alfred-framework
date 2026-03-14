---
name: scaffold-astro
description: Scaffold a new Astro 5.x + Tailwind CSS v4 project with established component patterns, layout hierarchy, and configuration.
user-invokable: true
argument-hint: "[project-name]"
---

Create a new Astro project named $ARGUMENTS with the following structure and patterns:

## Step 1: Initialize project
```bash
npm create astro@latest $ARGUMENTS -- --template minimal
cd $ARGUMENTS
```

## Step 2: Install dependencies
```bash
npx astro add sitemap mdx
npm install @tailwindcss/vite @tailwindcss/typography tailwindcss astro-icon sharp @fontsource-variable/inter
```

## Step 3: Configuration files

**astro.config.mjs:**
```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import mdx from '@astrojs/mdx';

export default defineConfig({
  site: 'https://REPLACE_WITH_DOMAIN',
  vite: { plugins: [tailwindcss()] },
  integrations: [sitemap(), mdx()],
  markdown: { shikiConfig: { theme: 'github-dark' } },
});
```

**tsconfig.json:** Ensure strict mode is enabled (extends `astro/tsconfigs/strict`).

## Step 4: Create `src/styles/global.css`
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

Customize the accent color for the new project's brand.

## Step 5: Create layouts
- `src/layouts/BaseLayout.astro` — HTML shell with SEOHead, Header, `<main>` slot, Footer
- `src/layouts/PageLayout.astro` — Wraps BaseLayout, adds container div

## Step 6: Create shared components
- `src/components/shared/SEOHead.astro` — Meta tags, OG tags, JSON-LD
- `src/components/layout/Header.astro` — Sticky nav, mobile menu toggle
- `src/components/layout/Footer.astro` — Nav links, copyright
- `src/components/layout/MobileMenu.astro` — Slide-out panel

## Step 7: Create utilities
- `src/utils/constants.ts` — SITE config, NAV_ITEMS
- `src/utils/helpers.ts` — formatDate, calculateReadingTime, generateSlug

## Step 8: Create starter pages
- `src/pages/index.astro` — Homepage
- `src/pages/404.astro` — Custom 404

## Step 9: Verify
```bash
npm run dev    # Should see homepage at localhost:4321
npm run build  # Should complete with zero errors
```
