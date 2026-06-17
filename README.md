# fable-it — a Claude Code plugin

Make Opus behave like Fable on long, hands-off jobs. Hand it a goal and a numbered
Definition of Done; it runs the whole thing to completion — conducting your build
tools, holding coherence across the run, and leaving an honest report instead of a
faked green one.

This repository is a **Claude Code plugin marketplace** containing one plugin,
`fable-it`, which bundles the orchestrator and the skills it delegates to.

## Install

```sh
# 1. register this marketplace
/plugin marketplace add DevOtts/fable-it

# 2. install the plugin (plugin-name@marketplace-name)
/plugin install fable-it@devotts
```

Replace `DevOtts/fable-it` with the actual `owner/repo` once published. The
marketplace name `devotts` comes from the `name` field in
`.claude-plugin/marketplace.json`.

## Use

You do not have to type a command. The skill auto-activates when you describe a
goal-to-DoD delivery ("work autonomously until done", "I'm going to bed, finish
this", "run to DoD", or a goal followed by numbered acceptance criteria). To invoke
it explicitly, plugin skills are namespaced by the plugin name:

```
/fable-it:fable-it  <goal>
  DoD:
  1. ...
  2. ...
```

Only the goal and a numbered DoD are required. Everything else has a default.

## What's inside

```
.claude-plugin/
  marketplace.json              # marketplace manifest (name, owner, plugins)
plugins/
  fable-it/
    .claude-plugin/
      plugin.json               # plugin manifest (name, version, author, license)
    skills/
      fable-it/SKILL.md         # the orchestrator (this is the whole point)
      launch/                   # ← drop your reviewed skill here
      iterate/                  # ← drop your reviewed skill here
      full-qa/                  # ← drop your reviewed skill here
      chrome-cdp-control/       # ← drop your reviewed skill here
    README.md
README.md
```

The four delegated skills are **not** included in this scaffold. Add your own,
reviewed for anything machine-specific or private, into their folders (see the
PLACEHOLDER.md in each). If a delegated skill is absent, `fable-it` degrades and
runs that phase inline rather than failing.

## Before you publish

- Fill in the real repository URL in `plugin.json` (`homepage`, `repository`).
- Add the four delegated skills, or remove them and rely on inline degradation.
- Validate locally: `claude plugin validate ./plugins/fable-it` and
  `claude plugin validate .` for the marketplace.
- Note: explicit invocation is namespaced as `/fable-it:fable-it`. Auto-activation
  by description does not require the slash and is the recommended path.

## License

MIT — see the plugin manifest.
