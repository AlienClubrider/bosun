# Bosun

Bosun is a first mate brain for [dot-agent-deck](https://agent-deck.devopstoolkit.ai). It is
not a fork, not a replacement, and not a TUI of its own — it's a small config template and a
couple of install/init scripts that configure dot-agent-deck's orchestrator/worker model to
behave like a first mate: it delegates your requests to a worker, isolates that worker's
changes in their own git worktree, and self-validates before ever bothering you with a
`work-done` signal. Nothing Bosun writes ever gets committed to your project.

## Prerequisites

- [dot-agent-deck](https://agent-deck.devopstoolkit.ai) — install it yourself first via its
  own installer (`brew tap vfarcic/tap && brew install dot-agent-deck`). Bosun configures it;
  it doesn't install it.
- [worktrunk](https://worktrunk.dev) (`wt`) — dot-agent-deck runs every role in the same
  directory with no built-in worktree isolation, so Bosun uses worktrunk to give each worker
  its own disposable worktree (`brew install worktrunk`).

## Install (Mac + Linux)

```sh
curl -fsSL https://raw.githubusercontent.com/AlienClubrider/bosun/main/install.sh | bash
```

## Quick start

```sh
cd your-project
bosun init
dot-agent-deck
```

Talk to your first mate in the orchestrator pane. Ask it to fix a bug or build a feature, and
it delegates the work to a free coder in the pool, each in its own isolated worktree; ask it a
planning question, and it answers you directly instead of delegating.

## How it works

- **Orchestrator / worker model.** dot-agent-deck's native `[[orchestrations]]` config defines
  one orchestrator role (the first mate) and worker roles: a pool of coders (`coder-1`,
  `coder-2`, ... — 4 by default, `bosun init --coder-pool-size N` to change it) plus one
  `scout`. The orchestrator delegates with `dot-agent-deck delegate --to <role> --task "..."`;
  a worker signals completion with `dot-agent-deck work-done`.
- **Why a pool.** dot-agent-deck's roles are static — each one is exactly one pane, fixed in
  the config, with no way to spin up more at runtime. A pool of coders is how independent
  features actually run in parallel instead of queueing behind a single coder; the
  orchestrator tracks which ones are free itself and serializes anything that would touch the
  same files.
- **Coder vs scout.** `coder` changes things — implements, fixes, refactors — and its
  deliverable is a committed change in its own worktree. `scout` only investigates — reproduces
  a bug, researches an approach, audits something — and its deliverable is a written report
  back to the orchestrator; it never edits a file or opens a PR. The orchestrator decides which
  one fits your request.
- **Isolation.** Since dot-agent-deck doesn't isolate workers into their own worktrees, the
  coder role's standing instructions have it create one itself via `wt switch -c` before
  touching any file.
- **Self-validation.** Before signaling done, the coder runs your project's
  [no-mistakes config](docs/NO-MISTAKES.md) and fixes what it finds, up to three attempts,
  before ever surfacing a failure to you.
- **Nothing committed.** `bosun init` generates `.dot-agent-deck.toml` in your project root and
  adds it to `.git/info/exclude` — never `.gitignore`, never a commit, invisible to your team.

## Configuring your first mate

Two things live globally, outside any project repo, and you edit them by hand over time:

- `~/.bosun/recipes/<repo-name>/AGENTS.md` — see [docs/RECIPES.md](docs/RECIPES.md).
- `~/.bosun/no-mistakes/<repo-name>.yaml` — see [docs/NO-MISTAKES.md](docs/NO-MISTAKES.md).

To change what the orchestrator or coder actually do, edit `~/.bosun/brain/FIRSTMATE.md` or
`~/.bosun/brain/POLICY.md` directly — changes apply the next time you run `bosun init`.

## Uninstall

```sh
rm -rf ~/.bosun
rm -f /usr/local/bin/bosun ~/.local/bin/bosun
```

Also remove the `[post-start]` / `[pre-remove]` `bosun-recipe` entries from
`~/.config/worktrunk/config.toml` if you added them by hand.

## More

- [docs/SETUP.md](docs/SETUP.md) — detailed walkthrough
- [docs/RECIPES.md](docs/RECIPES.md) — per-project conventions
- [docs/NO-MISTAKES.md](docs/NO-MISTAKES.md) — the validation gate
