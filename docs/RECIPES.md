# Recipes

A Recipe is a project's own conventions — architecture notes, naming rules, what never to do,
what tests actually matter — written for the coder worker to read. It's the same idea as a
project's own `AGENTS.md`, except it lives outside the repo entirely, so it's yours alone and
never shows up in a diff, a PR, or a teammate's clone.

## Where it lives

```
~/.bosun/recipes/<repo-name>/AGENTS.md
```

`<repo-name>` is the project's own directory name (the primary checkout, not any worktree
worktrunk creates for a worker).

## How it reaches a worker

Bosun registers a worktrunk `post-start` hook globally (in `~/.config/worktrunk/config.toml`,
never inside the project) that runs on every new worktree:

```sh
sh ~/.bosun/hooks/worktree-setup.sh <repo> <worktree_path>
```

It copies `~/.bosun/recipes/<repo>/AGENTS.md` into the freshly created worktree as `AGENTS.md`,
if one exists. The coder's standing instructions (`~/.bosun/brain/POLICY.md`) tell it to read
that file for conventions before doing anything else. A matching `pre-remove` hook deletes the
copy before the worktree is torn down, so nothing lingers.

If no Recipe exists for a project yet, nothing is copied — the worker just proceeds without
project-specific conventions, same as if Bosun weren't managing worktrees at all.

## Writing one

There's no required format — write it exactly like you'd write a project's own `AGENTS.md`.
A worked example:

```markdown
# your-project conventions

## Architecture
- API routes live in `src/routes/`, one file per resource.
- Business logic never lives in a route handler — put it in `src/services/`.

## Testing
- `npm test` runs the full suite; `npm run test:unit` is faster for iteration.
- Every new route needs at least one integration test in `tests/integration/`.

## Never do
- Never touch `src/legacy/` — it's frozen pending a rewrite, changes there get reverted.
- Never add a new npm dependency without checking with the team first.
```

Create the directory and file by hand:

```sh
mkdir -p ~/.bosun/recipes/your-project
$EDITOR ~/.bosun/recipes/your-project/AGENTS.md
```

There's no `bosun` subcommand for this deliberately — it's a plain file you maintain over
time, the same way you'd maintain notes for yourself.
