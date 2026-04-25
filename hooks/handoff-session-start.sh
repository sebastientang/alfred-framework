#!/bin/bash
# Injects .claude/PLAN.md if a handoff is pending in the current project.
# Pending = .claude/PLAN.pending marker file exists in cwd.
# Consumes the marker (deletes it) so subsequent fresh sessions skip injection.

set -e

cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
plan_file="$cwd/.claude/PLAN.md"
pending_marker="$cwd/.claude/PLAN.pending"

# No pending handoff in this project, skip silently
[ -f "$pending_marker" ] || exit 0

# Marker without file is corrupted state, clear and skip
if [ ! -f "$plan_file" ]; then
  rm -f "$pending_marker"
  exit 0
fi

# Emit content to be injected at session start
echo "<user-prompt-submit-hook>"
echo "Resuming from /handoff. Read this baton before responding to the user."
echo ""
cat "$plan_file"
echo ""
echo "</user-prompt-submit-hook>"

# Consume the marker so the next fresh session does not re-inject
rm -f "$pending_marker"
