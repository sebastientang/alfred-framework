# Hooks

Bash scripts that the Claude Code harness fires on lifecycle events. These are companions to skills in this framework, not replacements for them.

## Installation

1. Copy the scripts you want into `~/.claude/hooks/`:
   ```bash
   cp hooks/*.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/*.sh
   ```

2. Wire each hook into `~/.claude/settings.json` under the `hooks` object. Append, do not overwrite, the existing matching event array.

## handoff-session-start.sh

**Pairs with:** `skills/handoff`

**What it does.** On SessionStart, checks for `.claude/PLAN.pending` in the current working directory. If the marker exists, reads `.claude/PLAN.md` and emits its contents wrapped in a `<user-prompt-submit-hook>` envelope so the new session sees the handoff baton before its first response. The marker is then deleted, so subsequent fresh sessions in the same cwd are not re-injected.

**Why a marker file?** The SessionStart hook fires on every session in every project. Without the marker gate, the file would get injected on unrelated sessions whenever a stale `.claude/PLAN.md` happens to be in cwd. The marker is set only when `/handoff` writes the baton, so injection is scoped to true handoff resumptions.

**settings.json entry:**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/handoff-session-start.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

If you already have a `SessionStart` array, append the new entry instead of overwriting.

**Verification:**

```bash
# 1. Without marker, hook is silent
cd /tmp && CLAUDE_PROJECT_DIR=/tmp ~/.claude/hooks/handoff-session-start.sh
# (no output, exit 0)

# 2. With marker, hook injects + consumes
mkdir -p /tmp/test/.claude
echo "# HANDOFF\n## Active focus\nverify hook" > /tmp/test/.claude/PLAN.md
touch /tmp/test/.claude/PLAN.pending
CLAUDE_PROJECT_DIR=/tmp/test ~/.claude/hooks/handoff-session-start.sh
# Outputs the wrapped envelope, marker is gone after

# 3. Second run after consume is silent
CLAUDE_PROJECT_DIR=/tmp/test ~/.claude/hooks/handoff-session-start.sh
# (no output, exit 0)
```
