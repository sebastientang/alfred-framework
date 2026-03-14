---
name: generate-expert-agent
description: Generate an expert agent from a deep-research reference file. Creates AGENT.md with auto-activation triggers.
user-invokable: true
argument-hint: "[domain-slug]"
---

Generate an auto-activating expert agent from the reference file produced by `/deep-research` for domain "$ARGUMENTS".

## Step 1: Validate

Check that the reference file exists:

```bash
ls references/expertise/$ARGUMENTS.md
```

If not found, list available files in `references/expertise/` and ask the user to pick one or run `/deep-research` first.

## Step 2: Read Reference File

Read `references/expertise/$ARGUMENTS.md` in full. Extract:
- The domain name from the H1 title
- All sub-domain names (H3 headings under "Sub-Domains")
- The Quick Reference table
- The top 3-5 most actionable frameworks (those with step-by-step instructions)

## Step 3: Generate AGENT.md

Create `~/.claude/agents/$ARGUMENTS-expert/AGENT.md` (create the directory if needed).

The agent file must follow this structure (30-50 lines target):

```markdown
---
name: $ARGUMENTS-expert
description: Auto-activates when [DOMAIN] topics arise. Applies researched frameworks from references/expertise/$ARGUMENTS.md.
---

You are an expert in [DOMAIN], specialized for a freelance [YOUR_ROLE] selling to [YOUR_MARKET] and enterprises from [YOUR_CITY].

## When to Activate
- [3-5 trigger contexts derived from sub-domain names]
- Examples: "when discussing [sub-domain 1]", "when preparing [sub-domain 2]", "when reviewing [sub-domain 3]"

## Do NOT Activate For
- [2-3 explicit exclusions to prevent overlap with existing agents]
- General Salesforce technical questions (not this agent's scope)
- Content creation for blog/LinkedIn (handled by article-reviewer, linkedin-post skill)

## Reference Documents
1. `references/expertise/$ARGUMENTS.md` — full framework details, templates, and anti-patterns

## Quick Framework
- **[Framework 1]:** [1-line actionable summary]
- **[Framework 2]:** [1-line actionable summary]
- **[Framework 3]:** [1-line actionable summary]
- [up to 5 total]

## Rules
- Always apply French business culture norms from the reference file
- Rate floor: [YOUR_RATE] minimum (never suggest lower)
- Freelance context: no team, no manager — solo consultant positioning
- When recommending a framework, cite the specific section in the reference file
- If a technique conflicts with Brand_Bible_Appendix.md voice rules, voice rules win
```

Adjust the content based on what was actually found in the reference file. The exclusions must not overlap with existing agents (astro-site-builder, content-pipeline-builder, article-reviewer).

## Step 4: Update CLAUDE.md Files

### Global CLAUDE.md (`~/.claude/CLAUDE.md`)

Add to the **Agents table**:
```
| `$ARGUMENTS-expert` | [Trigger description from "When to Activate"] | Applies [DOMAIN] frameworks from researched reference file |
```

Add to **File locations**:
```
~/.claude/agents/$ARGUMENTS-expert/AGENT.md        ← [domain] expert agent
```

### Project CLAUDE.md (`~/Alfred/CLAUDE.md`)

Add to **Active components** list (under "Active components (created by Alfred):"):
```
- $ARGUMENTS-expert agent — auto-activates on [domain] topics, applies frameworks from references/expertise/$ARGUMENTS.md
```

## Step 5: Present

Show the user:
- Agent file created: `~/.claude/agents/$ARGUMENTS-expert/AGENT.md`
- Trigger contexts (when it will activate)
- Exclusions (when it won't)
- Quick frameworks included
- Both CLAUDE.md files updated

Remind: "Start a new session to test auto-activation. Discuss a [DOMAIN] topic and verify the agent applies the right frameworks."
