#!/bin/sh
# Bosun installer — Mac + Linux.
#
#   curl -fsSL https://raw.githubusercontent.com/AlienClubrider/bosun/main/install.sh | bash
#
# Installs the Bosun "brain" (a dot-agent-deck config template) and the
# `bosun` CLI globally. Does not install dot-agent-deck or worktrunk — those
# are separate tools you own the install of; this script only checks for
# them and points you at their own installers.
set -eu

BOSUN_HOME="$HOME/.bosun"
WT_USER_CONFIG="$HOME/.config/worktrunk/config.toml"

case "$(uname -s)" in
  Darwin|Linux) ;;
  *)
    echo "error: Bosun supports macOS and Linux only (detected: $(uname -s))" >&2
    exit 1
    ;;
esac

echo "==> Checking prerequisites"

if ! command -v dot-agent-deck >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: dot-agent-deck is not installed.

Bosun configures dot-agent-deck; it doesn't install it. Install it yourself first:

  brew tap vfarcic/tap && brew install dot-agent-deck

Then re-run this installer.
EOF
  exit 1
fi

if ! command -v wt >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: worktrunk (wt) is not installed.

Bosun uses worktrunk to isolate each worker in its own git worktree, since
dot-agent-deck does not do this itself. Install it yourself first:

  brew install worktrunk

(See https://worktrunk.dev if you're not on Homebrew.) Then re-run this installer.
EOF
  exit 1
fi

echo "==> Fetching Bosun"

# A one-line `curl | bash` only ever has this script itself in hand — not the
# rest of the repo — so fetch a fresh copy of it into a temp dir rather than
# assuming brain/ and hooks/ sit next to us on disk.
if command -v git >/dev/null 2>&1; then
  BOSUN_SRC="$(mktemp -d)"
  trap 'rm -rf "$BOSUN_SRC"' EXIT
  git clone --depth 1 -q https://github.com/AlienClubrider/bosun.git "$BOSUN_SRC" || {
    echo "error: failed to clone https://github.com/AlienClubrider/bosun.git" >&2
    exit 1
  }
else
  echo "error: git is required to install Bosun" >&2
  exit 1
fi

echo "==> Installing Bosun brain to $BOSUN_HOME"

mkdir -p "$BOSUN_HOME"
rm -rf "$BOSUN_HOME/brain" "$BOSUN_HOME/hooks"
cp -R "$BOSUN_SRC/brain" "$BOSUN_HOME/brain"
cp -R "$BOSUN_SRC/hooks" "$BOSUN_HOME/hooks"
chmod +x "$BOSUN_HOME"/hooks/*.sh
mkdir -p "$BOSUN_HOME/recipes" "$BOSUN_HOME/no-mistakes"

echo "==> Installing the bosun CLI"

if [ -w /usr/local/bin ]; then
  INSTALL_BIN=/usr/local/bin/bosun
else
  mkdir -p "$HOME/.local/bin"
  INSTALL_BIN="$HOME/.local/bin/bosun"
fi
cp "$BOSUN_SRC/bosun" "$INSTALL_BIN"
chmod +x "$INSTALL_BIN"

case ":$PATH:" in
  *":$(dirname "$INSTALL_BIN"):"*) ;;
  *)
    echo "warning: $(dirname "$INSTALL_BIN") is not on your PATH — add it to your shell profile." >&2
    ;;
esac

echo "==> Registering worktree Recipe hooks with worktrunk"

if [ -f "$WT_USER_CONFIG" ] && grep -q "bosun-recipe" "$WT_USER_CONFIG" 2>/dev/null; then
  echo "    already registered, skipping"
elif [ -f "$WT_USER_CONFIG" ]; then
  cat >&2 <<EOF
warning: $WT_USER_CONFIG already exists and Bosun didn't find its hooks in it.
Add these lines by hand to avoid clobbering your existing config:

[post-start]
bosun-recipe = "sh $BOSUN_HOME/hooks/worktree-setup.sh {{ repo }} {{ worktree_path }}"

[pre-remove]
bosun-recipe = "sh $BOSUN_HOME/hooks/worktree-destruction.sh {{ worktree_path }}"
EOF
else
  mkdir -p "$(dirname "$WT_USER_CONFIG")"
  cat > "$WT_USER_CONFIG" <<EOF
[post-start]
bosun-recipe = "sh $BOSUN_HOME/hooks/worktree-setup.sh {{ repo }} {{ worktree_path }}"

[pre-remove]
bosun-recipe = "sh $BOSUN_HOME/hooks/worktree-destruction.sh {{ worktree_path }}"
EOF
  echo "    wrote $WT_USER_CONFIG"
fi

cat <<'EOF'

Bosun is installed.

Next: cd into any project and run:

  bosun init

Then launch dot-agent-deck as usual.
EOF
