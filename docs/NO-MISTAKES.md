# no-mistakes

Before a coder worker ever signals `work-done`, it runs a validation gate — tests, lint,
whatever you tell it to — and fixes what it finds, up to three attempts, before you ever see a
failure. This is what lets you trust a `work-done` signal without re-checking everything
yourself every time.

## Where it lives

```
~/.bosun/no-mistakes/<repo-name>.yaml
```

Same pattern as [Recipes](RECIPES.md): global, outside the repo, yours to tune per project
over time. If no config exists for a project, the coder falls back to no-mistakes' own
defaults.

## Example config

```yaml
test:
  command: npm test
lint:
  command: npm run lint
ignore:
  - "*.min.js"
  - "dist/"
  - "node_modules/"
auto_fix:
  max_attempts: 3
```

## The self-correction loop

The coder's standing instructions (`~/.bosun/brain/POLICY.md`) encode this sequence before
every `work-done`:

1. Resolve `~/.bosun/no-mistakes/<repo-name>.yaml` (or defaults if absent).
2. Run `no-mistakes --config <path>`.
3. If it fails: fix the issues, re-run, repeat — up to 3 attempts total.
4. Still failing after 3 attempts → signal done anyway, but flag it plainly:
   `"Validation failed 3x — needs human review."` The orchestrator relays this to you as an
   actual failure, never as a clean done.
5. If it passes → signal done with a summary noting validation passed.

## Progression model

Tune the config as trust in a project grows:

- **New project** — a loose config. The self-fix loop catches the obvious stuff; you still
  skim `work-done` summaries closely.
- **Mature project** — a tighter config (more lint rules, stricter coverage). Fewer failed
  attempts, less back-and-forth.
- **Fully trusted** — you stop re-checking validated work at all; a clean `work-done` is enough
  on its own.

Create and edit it by hand, same as a Recipe:

```sh
mkdir -p ~/.bosun/no-mistakes
$EDITOR ~/.bosun/no-mistakes/your-project.yaml
```
