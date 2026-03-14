---
name: wrap-project
description: Survey the current project, extract cross-project patterns, create/update global resources, consolidate project memory, organize root files, and rewrite project CLAUDE.md for maintenance.
user-invokable: true
---

Perform a comprehensive wrap-up of the current project. Survey its structure, review work history, organize loose files, extract patterns worth preserving as global resources, and rewrite the project CLAUDE.md to reflect current state.

## Step 1: Survey the project

Examine the project to understand its full scope:

- Read `package.json` for dependencies, scripts, and project metadata
- Read key config files: `tsconfig.json`, `astro.config.*`, `tailwind.config.*`, `.eslintrc*`, `.prettierrc*`, `wrangler.*`
- Use Glob to map the source directory structure (`src/**/*`)
- Identify the tech stack, frameworks, and conventions used

## Step 2: Review git history

```bash
git log --oneline -50
```

```bash
git log --pretty=format: --name-only -50 | sort | uniq -c | sort -rn | head -20
```

Identify: what was built, what was refactored, what broke repeatedly, what patterns emerged across commits.

## Step 3: Organize project root

Identify non-config, non-source files at the project root and move them to a `docs/` directory for better discoverability.

Read `~/.claude/references/root-file-rules.md` for the full classification rules, move procedure, and guardrails. Follow those rules exactly.

## Step 4: Read all existing resources

Read each of these files to understand what already exists globally (skip any that don't exist):

- `~/.claude/CLAUDE.md` — global preferences
- `~/.claude/settings.json` — hooks configuration
- The project memory file at `~/.claude/projects/{encoded-path}/memory/MEMORY.md`
- Any files in `~/.claude/memory/` — global topic reference files

Also inventory existing skills and agents:

```bash
ls ~/.claude/skills/
ls ~/.claude/agents/
```

## Step 5: Identify cross-project patterns

Compare what you found in the project (Steps 1–2) against what already exists globally (Step 4). Look for:

1. **Tech stack patterns** — Build configurations, dependency choices, or tooling setups that appear across projects and could be standardized in CLAUDE.md or a new skill.
2. **Code conventions** — Naming patterns, file organization, error handling approaches, or testing strategies worth globalizing.
3. **Debugging insights** — Recurring issues (build failures, config gotchas, API quirks) that should be documented to save time in future projects.
4. **Workflow patterns** — Multi-step processes (deploy, test, migrate, generate) that were manual but could become skills.
5. **Domain expertise** — Bodies of knowledge (framework patterns, API usage, architecture decisions) substantial enough to warrant an agent.
6. **Automated checks** — Validations or transformations that were done manually but should be hooks.

Apply the same filters:
- Must be recurring (not a one-off fix for this project)
- Must not already exist in global resources
- Must be specific and actionable

## Step 6: Extract Claude Code & VS Code settings

Review tooling configuration from the project and promote useful patterns to global resources.

### Claude Code settings

Read these files if they exist (skip missing ones):
- Project `.claude/settings.json`
- Project `.claude/settings.local.json`
- Parent directory `.claude/settings.json` and `.claude/settings.local.json`

Compare against `~/.claude/settings.json` (global). Look for:

- **`env` variables** that improve the Claude Code experience (e.g., extended context, output limits, experimental features) → promote to `~/.claude/settings.json` `"env"` key if not already present
- **`hooks`** that worked well in this project and would benefit all projects → promote to `~/.claude/settings.json` `"hooks"` key
- **Permission allowlist patterns** — useful `"permissions.allow"` entries that are project-agnostic (e.g., common build tools, git operations, node scripts) → document in `~/.claude/memory/claude-code-settings.md` as a reference for future project setup

When promoting env vars or hooks to global settings, always preserve existing keys — merge, don't overwrite.

### VS Code settings

Read these files if they exist in the project (skip missing ones):
- `.vscode/settings.json`
- `.vscode/extensions.json`
- `.vscode/launch.json`
- `.vscode/tasks.json`

VS Code settings are workspace-specific — do NOT copy them to a global location. Instead, extract the **patterns** worth replicating:

- **Editor conventions** — format on save, rulers, bracket guides, per-language formatter overrides
- **Language mappings** — Emmet and Tailwind CSS include languages for framework-specific files (e.g., `"astro": "html"`)
- **Extension recommendations** — which extensions worked for this tech stack
- **Launch configurations** — dev server commands, debug setups
- **File associations** — custom file type mappings

Save findings to `~/.claude/memory/vscode-settings.md`:
- Organize by tech stack (e.g., "Astro + Tailwind v4" section)
- Include the actual JSON snippets so they can be copy-pasted into future `.vscode/` setups
- Note which extensions are recommended for which frameworks
- If this file already exists, merge new patterns — don't duplicate existing entries

Link from `~/.claude/CLAUDE.md` if not already linked: `- VS Code workspace patterns — see [VS Code settings reference](memory/vscode-settings.md)`

## Step 7: Assessment gate

If no patterns survive the filter in Step 5, print:

```
## Project Wrap-up Summary
No new cross-project patterns identified — existing resources are up to date.
```

Then skip to Step 10 (consolidate memory), Step 11 (rewrite CLAUDE.md), and Step 12 (summary).

## Step 8: Apply global resource changes

For each pattern worth globalizing, apply changes following these rules:

**CLAUDE.md** (`~/.claude/CLAUDE.md`):
- Add to existing sections when the pattern fits
- Create new `##` sections for genuinely new domains
- Never remove existing entries — only add or refine
- Keep each entry as a single-line bullet

**New skills** (`~/.claude/skills/{name}/SKILL.md`):
- Frontmatter: `name`, `description`, `user-invokable: true`, `argument-hint` (if applicable)
- Body: `## Step N: Title` format with bash commands and file contents
- Must have at least 3 meaningful steps (not padding)
- Include a verification step at the end

**New agents** (`~/.claude/agents/{name}/AGENT.md`):
- Frontmatter: `name`, `description` (activation trigger + purpose)
- Body: identity statement, patterns with code examples, rules, anti-patterns
- Extract real code snippets from the project as examples

**Hooks** (`~/.claude/settings.json`):
- Add to `"hooks"` key under the appropriate event (create `"hooks"` key if absent, preserving existing `"env"` key)
- Specify event, matcher (if applicable), and handler type (`command`, `prompt`, or `agent`)
- Prefer simple, testable hooks

**Topic files** (`~/.claude/memory/{topic}.md`):
- For detailed references too long for CLAUDE.md
- Create `~/.claude/memory/` directory if it doesn't exist
- Link from CLAUDE.md: `- See [topic details](memory/{topic}.md)`

## Step 9: Update CLAUDE.md tables

If any new skills or agents were created in Step 8, update the tables in `~/.claude/CLAUDE.md`:

**Skills table** — add a row matching this exact format:
```
| `/skill-name [argument]` | One-sentence description |
```

**Agents table** — add a row matching this exact format:
```
| `agent-name` | When it activates | What it does |
```

**File locations** — add a line inside the existing code block, matching this format (align the `←` arrows with existing entries):
```
~/.claude/skills/skill-name/SKILL.md                   ← skill-name skill
~/.claude/agents/agent-name/AGENT.md                   ← agent-name agent
```

## Step 10: Consolidate project memory

Rewrite the project `MEMORY.md` to be a clean, stable reference:

1. **Keep:** Tech stack facts, key file paths, recurring gotchas, integration details, deployment info
2. **Remove:** Session-specific notes ("currently debugging X"), resolved issues, temporary workarounds that were replaced
3. **Promote:** If a project-specific pattern became a global resource in Step 8, replace the detailed entry with a brief note: `- [Pattern name] — promoted to global (see ~/.claude/CLAUDE.md)`
4. **Organize:** Ensure sections are logically ordered and clearly labeled
5. **Trim:** Stay under 200 lines. Prefer linking to global resources over duplicating content

## Step 11: Rewrite project CLAUDE.md

Replace the project CLAUDE.md with a version that reflects the project's history and current state — not its original build spec.

### Archive the original

Check if `docs/original-build-spec.md` already exists. If not:

1. Copy the current project `CLAUDE.md` to `docs/original-build-spec.md` (create `docs/` if it wasn't created in Step 3)
2. Add a header to the archived file: `# Original Build Spec\n\n> Archived by /wrap-project on {date}. See project CLAUDE.md for current state.\n\n---\n`

If `docs/original-build-spec.md` already exists, skip the archive — the original has already been preserved.

### Gather source material

The new CLAUDE.md must be synthesized from data already collected — do NOT invent content:

- **Step 1 data:** `package.json` dependencies, config files, directory structure, tech stack
- **Step 2 data:** git history — what was built, major refactors, evolution of the project
- **Project MEMORY.md:** current conventions, design system, deployment details, i18n architecture
- **Existing project CLAUDE.md:** project identity, voice profile, content rules (carry forward what's still accurate)
- **`src/utils/constants.ts`** (and locale variants): site metadata, services, categories
- **`src/styles/global.css`**: current color tokens, font declarations
- **`.github/workflows/`**: current automation setup

Read `~/.claude/references/claude-md-template.md` for the full section template and guardrails. Follow those rules exactly.

## Step 12: Print summary

Print a final summary:

```
## Project Wrap-up Summary

### Project: [name]
Tech stack: [brief description]
Commits reviewed: [N]

### File Organization
- Moved [N] files to `docs/` ([list filenames])
- Updated [N] references
- OR: Project root was already clean

### Global Resources Updated
- `~/.claude/CLAUDE.md` — [what was added]

### Global Resources Created
- `~/.claude/skills/{name}/SKILL.md` — [purpose]
- `~/.claude/agents/{name}/AGENT.md` — [purpose]

### Project Memory
- Consolidated from [N] entries to [N] entries
- Promoted [N] patterns to global resources
- Removed [N] stale entries

### Project CLAUDE.md
- Archived original to `docs/original-build-spec.md`
- Rewrote CLAUDE.md: [N] lines → [N] lines
- Key updates: [list major changes]
- OR: CLAUDE.md was already current — no rewrite needed

### No Changes Needed
- [list any categories where nothing was warranted]
```

### Rules
- Only promote patterns to global that are confirmed across multiple interactions or clearly universal
- Don't create skills for workflows unique to this one project
- Keep everything concise and scannable
- A new skill must have at least 3 meaningful steps to justify its existence
- A new agent must represent a coherent domain, not a single tip
- Never remove existing entries from CLAUDE.md — only add or refine
- Never delete project files — only move or reorganize them
