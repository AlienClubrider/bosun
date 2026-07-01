#!/bin/sh
# Bosun worktrunk post-start hook.
# Copies this project's global Recipe (if one exists) into a freshly created
# worker worktree, so conventions are visible without ever being committed.
#
# Registered as a worktrunk *user* hook (~/.config/worktrunk/config.toml),
# never a project hook, so it stays invisible to the rest of the team.
#
# Usage: worktree-setup.sh <repo> <worktree_path>
set -eu

REPO="$1"
WORKTREE_PATH="$2"
RECIPE="$HOME/.bosun/recipes/$REPO/AGENTS.md"

if [ -f "$RECIPE" ]; then
  cp "$RECIPE" "$WORKTREE_PATH/AGENTS.md"
fi
