---
name: deploy-cloudflare
description: Build and deploy the current project to Cloudflare Pages via wrangler.
user-invokable: true
argument-hint: "[project-name]"
---

Deploy to Cloudflare Pages:

1. Build the project:
```bash
npm run build
```

2. Deploy the `dist/` directory:
```bash
npx wrangler pages deploy dist --project-name=$ARGUMENTS
```

**Prerequisites:**
- `CLOUDFLARE_API_TOKEN` environment variable must be set
- `CLOUDFLARE_ACCOUNT_ID` environment variable must be set
- The Cloudflare Pages project must already exist (create at dash.cloudflare.com if not)

**For CI/CD setup**, add these as GitHub repository secrets and use in a workflow:
```yaml
- name: Deploy to Cloudflare Pages
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
  run: npx wrangler pages deploy dist --project-name=$ARGUMENTS
```
