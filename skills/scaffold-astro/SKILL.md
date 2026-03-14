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

Customize the accent color for the new project's brand. Keep navy/charcoal/slate/gray as the neutral scale.

## Step 5: Create layouts
- `src/layouts/BaseLayout.astro` — HTML shell with `<head>` (imports global.css, renders SEOHead), `<body>` with Header, `<main>` slot, Footer
- `src/layouts/PageLayout.astro` — Wraps BaseLayout, adds `<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 md:py-24">` container

## Step 6: Create shared components
- `src/components/shared/SEOHead.astro` — Props: title, description, canonical?, ogImage?, ogType?. Renders meta tags, OG tags, JSON-LD
- `src/components/layout/Header.astro` — Sticky nav, logo/site name, desktop nav links, mobile menu toggle, CTA button
- `src/components/layout/Footer.astro` — Nav links, contact info, copyright year
- `src/components/layout/MobileMenu.astro` — Slide-out panel with overlay, Escape key close

## Step 7: Create utilities
- `src/utils/constants.ts` — Export SITE (title, description, url, author), NAV_ITEMS array
- `src/utils/helpers.ts` — Export formatDate(date), calculateReadingTime(content), generateSlug(title)

## Step 8: Create starter pages
- `src/pages/index.astro` — Homepage using PageLayout
- `src/pages/404.astro` — Custom 404 with navigation links

## Step 9: Create public assets
- `public/robots.txt` — Allow all crawlers, reference sitemap

## Step 10: Create VS Code workspace configuration

Check if `~/.claude/memory/vscode-settings.md` exists. If it contains Astro + Tailwind v4 patterns, use those. Otherwise, use these defaults:

**`.vscode/extensions.json`:**
```json
{
  "recommendations": [
    "astro-build.astro-vscode",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode"
  ]
}
```

**`.vscode/settings.json`:**
```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.rulers": [100],
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "emmet.includeLanguages": { "astro": "html" },
  "tailwindCSS.includeLanguages": { "astro": "html" },
  "files.associations": { "*.astro": "astro" },
  "[astro]": { "editor.defaultFormatter": "astro-build.astro-vscode" },
  "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[json]": { "editor.defaultFormatter": "esbenp.prettier-vscode" }
}
```

**`.vscode/launch.json`:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "command": "./node_modules/.bin/astro dev",
      "name": "Development server",
      "request": "launch",
      "type": "node-terminal"
    }
  ]
}
```

## Step 11: Verify
```bash
npm run dev
# Open localhost:4321 — should see homepage with header/footer
npm run build
# Should complete with zero errors
```
