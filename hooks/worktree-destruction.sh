#!/bin/sh
# Bosun worktrunk pre-remove hook.
# Removes the Recipe copy this worktree received on creation, so nothing
# Bosun-specific lingers once the worktree is gone.
#
# Registered as a worktrunk *user* hook (~/.config/worktrunk/config.toml),
# never a project hook, so it stays invisible to the rest of the team.
#
# Usage: worktree-destruction.sh <worktree_path>
set -eu

WORKTREE_PATH="$1"

if [ -f "$WORKTREE_PATH/AGENTS.md" ]; then
  rm "$WORKTREE_PATH/AGENTS.md"
fi
