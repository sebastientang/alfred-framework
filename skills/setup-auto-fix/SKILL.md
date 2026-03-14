---
name: setup-auto-fix
description: Generates GitHub Actions workflows for autonomous CI auto-fix using Claude Code — auto-detects workflows, build commands, and tech stack for any repo.
user-invokable: true
---

Generate GitHub Actions workflow files that automatically detect CI failures, use Claude Code to analyze and fix the code, merge the fix PR, and optionally re-trigger failed cron jobs. Everything is auto-detected from the current project — no arguments needed.

## Step 1: Detect project context

Scan the project to detect three things: existing workflows, build commands, and tech stack.

### 1a. Existing workflows

Read all `.github/workflows/*.yml` files. For each, extract:
- The `name:` field (exact string — needed for `workflow_run.workflows[]`)
- Whether it's the **deploy workflow**: has `push: branches: [main]` trigger
- Whether it's a **cron workflow**: has `schedule:` trigger AND `workflow_dispatch` with an `inputs` key

Store:
- `DEPLOY_WORKFLOW_NAME` — the `name:` of the deploy workflow (e.g., "Deploy to Cloudflare Pages")
- `CRON_WORKFLOW_NAME` — the `name:` of the cron workflow, if any (e.g., "Scheduled Cron Jobs")
- `CRON_FILENAME` — the filename of the cron workflow (e.g., "cron.yml")
- `CRON_DISPATCH_KEY` — the `workflow_dispatch` input key name (e.g., "trigger")
- `HAS_CRON` — boolean

If no deploy workflow is found, stop and tell the user: "No deploy workflow found in `.github/workflows/`. This skill requires an existing CI/CD workflow that triggers on push to main."

### 1b. Build commands

Detect the package manager and build/check commands:

| Indicator | Package manager | Build command |
|-----------|----------------|---------------|
| `bun.lockb` exists | bun | `bun install && bun run build && bun run check` |
| `package-lock.json` or `package.json` exists | npm | `npm ci && npm run build && npm run check` |
| `pnpm-lock.yaml` exists | pnpm | `pnpm install && pnpm run build && pnpm run check` |
| `yarn.lock` exists | yarn | `yarn install && yarn run build && yarn run check` |
| `pyproject.toml` or `requirements.txt` exists | pip | `pip install -e '.[dev]' && pytest && mypy .` |
| `go.mod` exists | go | `go build ./... && go test ./...` |
| `Cargo.toml` exists | cargo | `cargo build && cargo test` |

For Node.js projects, also check `package.json` scripts — if there's no `check` script, omit `&& npm run check` from the command.

Store as `BUILD_COMMAND`.

### 1c. Tech stack description

Build a bullet-point list for the Claude prompt's "Project Context" section:

1. **First**, read `CLAUDE.md` in the project root — if it has a tech stack section, extract the key technologies from it
2. **Fallback**: if no CLAUDE.md or no tech stack section, infer from config files:
   - `package.json` dependencies — framework (SvelteKit, Next.js, Astro, etc.), language (TypeScript if `typescript` in deps or `tsconfig.json` exists)
   - `tsconfig.json` — "TypeScript strict mode" if `strict: true`
   - CSS framework from deps (Tailwind, etc.)
   - Database/ORM from deps (Drizzle, Prisma, etc.)
3. **Always append** as the last bullet: `- Read CLAUDE.md for full conventions`

Store as `TECH_STACK_BULLETS` (a multi-line string of `- Item` lines).

Print a summary of everything detected before proceeding.

## Step 2: Check for existing auto-fix.yml

Check if `.github/workflows/auto-fix.yml` already exists.

- If it exists, warn: "auto-fix.yml already exists. It will be overwritten."
- If `.github/workflows/retrigger-cron.yml` exists and `HAS_CRON` is true, also warn about overwriting.
- If `.github/workflows/retrigger-cron.yml` exists but `HAS_CRON` is false, warn: "Existing retrigger-cron.yml found but no cron workflow detected — it will NOT be overwritten (delete manually if unwanted)."

Proceed regardless — the user invoked this skill intentionally.

## Step 3: Generate auto-fix.yml

Read the appropriate YAML template from this skill's references directory:
- If `HAS_CRON` is true: Read `references/auto-fix-with-cron.yml` (includes cron trigger detection and `[auto-fix:cron:<name>]` tagging)
- If `HAS_CRON` is false: Read `references/auto-fix-no-cron.yml` (deploy-only, simpler context step)

Write the template content to `.github/workflows/auto-fix.yml` after applying substitutions (see below).

### Substitution rules

Replace all `{PLACEHOLDER}` tokens with the detected values from Step 1. These are **literal substitutions** in the YAML string, not template variables:

- `{DEPLOY_WORKFLOW_NAME}` — exact `name:` from the deploy workflow
- `{CRON_WORKFLOW_NAME}` — exact `name:` from the cron workflow
- `{BUILD_COMMAND}` — detected build command
- `{TECH_STACK_BULLETS}` — multi-line bullet list with 12-space indentation (to align within the YAML `prompt: |` block)

### Security rules for generated YAML

- Every `${{ }}` expression used inside a `run:` block MUST be passed through `env:` first — never inline `${{ }}` directly in shell scripts (injection risk)
- The only exception: `${{ }}` inside `with:` blocks (GitHub Actions evaluates these safely)
- `${{ secrets.* }}` references are always safe in `env:` mappings
- `${{ steps.*.outputs.* }}` in `with:` blocks is safe
- `${{ env.* }}` in `with: prompt:` is safe (used for FAILURE_LOG)

## Step 4: Conditionally generate retrigger-cron.yml

**Only if `HAS_CRON` is true.** Otherwise skip this step.

Read `references/retrigger-cron.yml`. Apply substitutions:
- `{DEPLOY_WORKFLOW_NAME}` — exact `name:` from the deploy workflow
- `{CRON_FILENAME}` — filename of the cron workflow
- `{CRON_DISPATCH_KEY}` — the `workflow_dispatch` input key name

Write to `.github/workflows/retrigger-cron.yml`.

## Step 5: Validate YAML

Validate both generated files with Python's YAML parser:

```bash
python3 -c "
import yaml, sys
for f in sys.argv[1:]:
    try:
        with open(f) as fh:
            yaml.safe_load(fh)
        print(f'OK: {f}')
    except Exception as e:
        print(f'FAIL: {f} — {e}')
        sys.exit(1)
" .github/workflows/auto-fix.yml .github/workflows/retrigger-cron.yml
```

(Only include `retrigger-cron.yml` in the validation if it was generated.)

If validation fails, fix the YAML and re-validate.

## Step 6: Print prerequisites and summary

Print the following to the user:

```
## Auto-Fix Setup Complete

### Generated Files
- .github/workflows/auto-fix.yml
- .github/workflows/retrigger-cron.yml  (only if cron detected)

### Detected Configuration
- Deploy workflow: "{DEPLOY_WORKFLOW_NAME}"
- Cron workflow: "{CRON_WORKFLOW_NAME}" (or "none detected")
- Build command: `{BUILD_COMMAND}`
- Tech stack: {count} items detected

### Prerequisites (do these before pushing)

1. **ANTHROPIC_API_KEY** — add as a GitHub repo secret
   Settings > Secrets and variables > Actions > New repository secret

2. **Claude GitHub App** — install on this repo
   https://github.com/apps/claude

3. **Workflow permissions** — verify these are enabled
   Settings > Actions > General > Workflow permissions:
   - "Read and write permissions" (checked)
   - "Allow GitHub Actions to create and approve pull requests" (checked)

### How It Works
1. Your deploy workflow (or cron) fails
2. `auto-fix.yml` triggers, fetches failure logs
3. Claude Code analyzes logs and creates a fix PR
4. The PR is auto-merged with a `[auto-fix]` tag
5. The merge triggers your deploy workflow again
6. Loop prevention: if the fix also fails, it stops (no infinite loop)
7. If a cron job was fixed, `retrigger-cron.yml` re-runs it after successful deploy (only if HAS_CRON)

Commit and push when ready.
```
