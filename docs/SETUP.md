# Setup

## 1. Install prerequisites

Bosun configures two tools it doesn't own the install of — install both yourself first:

```sh
brew tap vfarcic/tap && brew install dot-agent-deck
brew install worktrunk
```

## 2. Install Bosun

```sh
curl -fsSL https://raw.githubusercontent.com/AlienClubrider/bosun/main/install.sh | bash
```

Expected output:

```
==> Checking prerequisites
==> Installing Bosun brain to /home/you/.bosun
==> Installing the bosun CLI
==> Registering worktree Recipe hooks with worktrunk
    wrote /home/you/.config/worktrunk/config.toml

Bosun is installed.

Next: cd into any project and run:

  bosun init

Then launch dot-agent-deck as usual.
```

This creates:

```
~/.bosun/
├── brain/
│   ├── dot-agent-deck.toml   the role-wiring template
│   ├── FIRSTMATE.md          orchestrator's standing instructions
│   └── POLICY.md             coder's standing instructions
├── hooks/
│   ├── worktree-setup.sh
│   └── worktree-destruction.sh
├── recipes/                  empty until you add one — see RECIPES.md
└── no-mistakes/              empty until you add one — see NO-MISTAKES.md
```

If `~/.config/worktrunk/config.toml` already existed with its own hooks, the installer won't
touch it — it prints the two lines to add by hand instead of risking a broken merge of your
existing config.

## 3. Activate Bosun in a project

```sh
cd ~/code/your-project
bosun init
```

Expected output:

```
Bosun is active in this project. Run `dot-agent-deck` to start.
```

This writes `.dot-agent-deck.toml` to the project root and adds it to
`.git/info/exclude` — check `git status`, it shows nothing new.

By default all three roles (orchestrator, coder, scout) run on `claude`. Override per role:

```sh
bosun init --orchestrator-cmd "claude --model opus" --coder-cmd "claude --model sonnet"
```

Re-running `bosun init` after editing `~/.bosun/brain/FIRSTMATE.md` or `POLICY.md` regenerates
the project config with your changes — it's safe to re-run any time.

## 4. Launch

```sh
dot-agent-deck
```

Open a pane on the project directory, press `Ctrl+n`, and pick the `bosun` orchestration as
the mode. The orchestrator pane starts active; `coder` and `scout` role cards appear in the
sidebar. Talk to the orchestrator like you would a colleague — it decides for itself whether
to answer you directly or delegate.

## Check status any time

```sh
bosun status
```

```
Bosun: active in /home/you/code/your-project
no-mistakes config: none for 'your-project' — using defaults
```
