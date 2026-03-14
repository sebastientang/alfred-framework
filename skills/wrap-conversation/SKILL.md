---
name: wrap-conversation
description: Reflect on the current conversation, extract learnings, and create/update global resources (CLAUDE.md, memory, skills, agents, hooks).
user-invokable: true
argument-hint: "[focus-area]"
---

Reflect on everything discussed in this conversation and extract learnings worth preserving. If a focus area was specified ($ARGUMENTS), prioritize that domain. Otherwise, review all topics comprehensively.

## Step 1: Read existing global resources

Read each of these files to understand what already exists (skip any that don't exist):

- `~/.claude/CLAUDE.md` — global preferences
- `~/.claude/settings.json` — hooks configuration
- The project memory file for the current working directory at `~/.claude/projects/{encoded-path}/memory/MEMORY.md`
- Any files in `~/.claude/memory/` — global topic reference files

Also list existing skills and agents:

```bash
ls ~/.claude/skills/
ls ~/.claude/agents/
```

## Step 2: Extract and categorize learnings

Review the full conversation context. Identify items in these categories:

1. **Global preference** — A coding standard, tool preference, workflow rule, or API pattern that applies across all projects. Target: `~/.claude/CLAUDE.md` (add to the appropriate existing section, or create a new `##` section if none fits).
2. **Project learning** — A fact, gotcha, pattern, or convention specific to this project. Target: project `MEMORY.md`.
3. **Repeatable workflow** — A multi-step task that was performed and is likely to recur in future conversations (at least 3 steps, not a one-off). Target: new skill at `~/.claude/skills/{name}/SKILL.md`.
4. **Domain expertise** — A coherent body of knowledge with rules, patterns, and code examples that Claude should apply automatically when working in that domain. Target: new agent at `~/.claude/agents/{name}/AGENT.md`.
5. **Automated check** — A validation or transformation that should run automatically before/after tool use or at session boundaries. Target: hook entry in `~/.claude/settings.json`.
6. **Detailed topic reference** — A learning too detailed for CLAUDE.md but worth preserving globally. Target: `~/.claude/memory/{topic}.md` (link from CLAUDE.md).

For each finding, assess:
- **Category** (1–6 above)
- **Content** (the specific learning, pattern, or rule)
- **Rationale** (why this is worth preserving — must be a recurring pattern, not a one-off)
- **Dedup check** (does this already exist in the target file?)

Discard anything that:
- Was a one-off debugging step unlikely to recur
- Is already captured in an existing resource
- Is too vague to be actionable (e.g., "TypeScript is useful")

## Step 3: Assessment gate

If no findings survive the filter in Step 2, print:

```
## Wrap-up Summary
No new learnings identified — existing resources are up to date.
```

Then stop. Do not make any file changes.

## Step 4: Apply changes

For each surviving finding, apply it to the appropriate target:

**CLAUDE.md updates** (`~/.claude/CLAUDE.md`):
- Add new bullet points to the appropriate existing section
- If no section fits, add a new `## Section Name` following the existing style
- Never remove or rewrite existing entries — only add or refine wording
- Keep entries as single-line bullets (no multi-line paragraphs)

**Project MEMORY.md updates** (`~/.claude/projects/{encoded-path}/memory/MEMORY.md`):
- Add entries under the appropriate `##` section
- Create a new section if needed
- Remove any session-specific entries that are no longer relevant (e.g., "currently debugging X")
- Stay under 200 lines total

**New skill creation** (`~/.claude/skills/{name}/SKILL.md`):
- Must include frontmatter: `name`, `description`, `user-invokable: true`, `argument-hint` (if applicable)
- Body uses `## Step N: Title` format with bash commands and file contents
- Reference `$ARGUMENTS` for any user-provided parameters
- Include a verification step at the end

**New agent creation** (`~/.claude/agents/{name}/AGENT.md`):
- Must include frontmatter: `name`, `description` (activation trigger + purpose)
- Body starts with an identity statement ("You are an expert...")
- Include sections for patterns, rules, code examples, and anti-patterns
- Reference specific file paths and conventions

**Hook addition** (`~/.claude/settings.json`):
- Add to the `"hooks"` key (create it if absent, preserving existing `"env"` key)
- Specify the event (PreToolUse, PostToolUse, Stop, SessionEnd, etc.) and handler
- Hook types: `command` (shell script), `prompt` (lightweight LLM check), `agent` (subagent with tools)
- Prefer simple, testable hooks — avoid complex scripts

**Detailed topic file** (`~/.claude/memory/{topic}.md`):
- Create the `~/.claude/memory/` directory if it doesn't exist
- Write a focused reference document
- Add a link from CLAUDE.md: `- See [topic details](memory/{topic}.md)`

## Step 5: Update CLAUDE.md tables

If any new skills or agents were created in Step 4, update the tables in `~/.claude/CLAUDE.md`:

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

## Step 6: Print summary

Print a clear summary of everything that was done:

```
## Wrap-up Summary

### Updated
- `~/.claude/CLAUDE.md` — added [description]
- `project MEMORY.md` — added [description]

### Created
- `~/.claude/skills/new-skill/SKILL.md` — [description]
- `~/.claude/agents/new-agent/AGENT.md` — [description]

### No changes
- [list categories where nothing was warranted]
```

### Rules
- Never remove existing entries from CLAUDE.md — only add or refine
- Don't create skills/agents for one-off tasks — only for patterns that will recur across conversations
- Prefer updating existing files over creating new ones
- Keep CLAUDE.md concise — link to `~/.claude/memory/` files for detailed notes
- A new skill must have at least 3 meaningful steps to justify its existence
- A new agent must represent a coherent domain with rules and patterns, not a single tip
