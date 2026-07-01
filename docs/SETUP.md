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

Run it in a terminal with no flags and it asks which agent to use, showing the default so
you actually see the choice instead of it silently picking one for you:

```
Agent command to run for each role [claude --permission-mode bypassPermissions]:
```

Press enter to accept the default, or type something else — `opencode`, `claude --model
opus`, whatever you run. Set it non-interactively instead with `--agent <cmd>` (all roles) or
per role:

```sh
bosun init --agent "opencode --model gpt-4o"
bosun init --orchestrator-cmd "claude --model opus" --coder-cmd "claude --model sonnet"
```

By default there are 4 coder roles (`coder-1`..`coder-4`) so independent features can run in
parallel — dot-agent-deck has no way to spin up more at runtime, so this pool is fixed at
`bosun init` time. Change the count with `--coder-pool-size`:

```sh
bosun init --coder-pool-size 6
```

dot-agent-deck's own new-pane form has a Command field, but it's ignored for orchestration
tabs — each role's pane always launches with the command fixed in `.dot-agent-deck.toml`
(that's dot-agent-deck's own design, not something Bosun can change). So the agent choice
happens once, here, at `bosun init` time — not at launch time in the TUI.

**Why `bypassPermissions` by default.** Workers run unattended in their own disposable
worktree — nobody's watching that pane to answer a permission prompt, and there's no way for
the orchestrator to answer one on a worker's behalf (they're separate processes; dot-agent-deck
only relays explicit `work-done` signals, not tool-approval dialogs). Without it, a coder can
sit forever waiting on a question nobody will ever see. The worktree isolation plus
`POLICY.md`'s own "never merge, never push, nothing outside the worktree" rules are the actual
safety net instead of an interactive prompt. If you want a role to ask before acting, override
its command without that flag (e.g. `--orchestrator-cmd claude` for just the pane you're
watching directly).

Re-running `bosun init` after editing `~/.bosun/brain/FIRSTMATE.md` or `POLICY.md` regenerates
the project config with your changes — it's safe to re-run any time.

## 4. Launch

```sh
dot-agent-deck
```

Open a pane on the project directory, press `Ctrl+n`, and pick the `bosun` orchestration as
the mode. The orchestrator pane starts active; `coder-1`..`coder-N` and `scout` role cards
appear in the sidebar, all idle until delegated to. Talk to the orchestrator like you would a
colleague — it decides for itself whether to answer you directly, delegate to a coder, or
delegate to scout.

## Check status any time

```sh
bosun status
```

```
Bosun: active in /home/you/code/your-project
no-mistakes config: none for 'your-project' — using defaults
```
