# SHARED-CONTEXT — fable-it v2 planning run (2026-07-02)

Read this before doing any research work. All streams write to
`docs/research/_streams/` and cite evidence (URL or file:line).

## The demand (user's own words, condensed)

> fable-it is a plugin that enhances by a lot the quality of our development with
> the Opus model, but we did it from papers that explain how Fable works, not using
> Fable itself. This research is to deeply understand and explain what makes
> Fable 5 so much better than Opus, and create a plan on what we need to enhance in
> fable-it to push it to behave as better as Fable does — but using Sonnet 5 or the
> latest Opus version.

## Locked scope (Gate G1, 2026-07-02, owner: Fernando)

- Size M. Deliverables: research doc → gap analysis → enhancement spec → 1 PRD +
  epics with binding test contracts → /fable-it handoff.
- Target models: **model-adaptive** — tune for BOTH Sonnet 5 and Opus 4.8, with
  per-model guardrail differences where they exist.

## The repo under study

`/Users/macbook/Workspace/Devotts/fable-it` — a Claude Code plugin (also a
standalone SKILL.md for 70+ agent tools) bundling 5 skills:

| Skill | Path | Lines |
|---|---|---|
| fable-it (conductor) | `plugins/fable-it/skills/fable-it/SKILL.md` | 214 |
| launch | `plugins/fable-it/skills/launch/SKILL.md` | 745 |
| iterate | `plugins/fable-it/skills/iterate/SKILL.md` | 177 |
| full-qa | `plugins/fable-it/skills/full-qa/SKILL.md` | 394 |
| chrome-cdp-control | `plugins/fable-it/skills/chrome-cdp-control/SKILL.md` | 291 |
| root SKILL.md (standalone/degraded mode) | `SKILL.md` | 74 |

Also: `README.md` (the "honest claim" ports/doesn't-port table),
`fable-it-field-guide.pdf` (the papers the plugin was derived from),
`docs/parallel-lifecycle-KICKOFF.md`, `.fable-it-reports/report.md`.

## Research streams

- **A — Public record** (agent): what Anthropic + credible community sources say
  Fable 5 / Claude 5 / Mythos-class improves over Opus. Cite URLs. Separate
  documented behavior from marketing.
- **B — Plugin audit** (agent): catalog every behavior/guardrail the plugin
  encodes, with file:line; extract from the field-guide PDF which papers/claims
  it was built from.
- **C — Live introspection** (main thread only): the Fable 5 harness behavioral
  contract as directly observed from inside a live Fable 5 session.

## Posture

Be criterious and skeptical. Cite everything. Contradictions between streams get
adjudicated in synthesis, not averaged. Marketing language is not evidence.
