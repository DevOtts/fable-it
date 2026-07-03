# Changelog

All notable changes to fable-it are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/).

## [2.0.0] — 2026-07-02

**"Make your model behave like Fable"** — v2 rebuilds the plugin from postures into
checkable gates, built from firsthand Fable 5 research (live harness introspection +
Anthropic's "Prompting Claude Fable 5" guide) instead of secondhand descriptions.
Evidence for every design decision: [`docs/research/01-fable5-vs-opus.md`](docs/research/01-fable5-vs-opus.md)
and [`docs/research/02-gap-analysis.md`](docs/research/02-gap-analysis.md).
Shipped against a 26-case binding test contract ([`delivery/STATUS.md`](delivery/STATUS.md)).

### Added
- **5-gate catalog** in the conductor, replacing posture prose: turn-end, claim,
  state-change, phase-boundary, and delegation gates — each a trigger + test + action
  checked at a decision point (PR #5).
- **Run-state contract**: four compaction-proof files in `.taskstate/`
  (`grounding.md`, `decisions.md`, `evidence.md`, `run-memory.md`) re-read at every
  phase boundary, plus cross-run memory in `.fable-it-reports/lessons.md` (PR #5).
- **Evidence ledger — VERIFIED is a lookup, not a vibe**: a criterion may only be
  reported VERIFIED if `evidence.md` holds a passing tool result from the session
  (the Anthropic-measured claim-grounding rule) (PR #5).
- **Fresh-context verifier step**: before delivery, a verifier that reads ONLY the
  DoD, the draft report, and the evidence ledger challenges every under-evidenced
  VERIFIED row; challenged rows get real evidence or a demotion. Degraded self-audit
  protocol for hosts without subagents (PR #7).
- **Model-adaptive posture** applied at Step 0 for Sonnet 5, Opus 4.8, and Fable 5
  (re-grounding cadence, gate verbosity, over-engineering suppressors) (PR #5).
- **Cost-aware delegation routing**: work packets routed to model tiers by task shape
  (cheap/mid/top), default-inherit when unsure, the verifier never downgraded, every
  choice logged and disclosed in a per-agent cost table (PRs #5, #8).
- **`/launch` unattended mode**: conductor-invoked runs recommend, log to
  `decisions.md`, and proceed — zero interactive stalls; direct human runs keep their
  approval gates (PR #8).
- **Loop upgrades**: delegation gate (idle ≠ delivered), adversarial verify before
  trusting a root cause, loop-until-dry exploratory QA (2 consecutive dry rounds),
  no-silent-caps sections in every report (PR #9).
- **Hardened mode (opt-in, fail-open)**: Claude Code hooks that mechanically block
  promise-endings (`turn-end-gate.py`) and evidence-free VERIFIED rows
  (`evidence-lint.py`), with unit tests and a documented settings snippet
  ([`plugins/fable-it/hooks/README.md`](plugins/fable-it/hooks/README.md)) (PR #10).
- **Shared CDP core** (`plugins/fable-it/skills/references/cdp-core.md`): connection
  template, tab selection, selector ladder, waits, and failure protocol in exactly one
  file; endpoints parameterized (`CDP_URL`/`APP_URL`) so parallel runs can't collide (PR #6).
- **Test infrastructure**: registered tabletop goldens (`delivery/goldens/`), scripted
  lints (`tests/lints/run-all.sh`), hook unit tests.

### Changed
- **Rebrand**: "Make Opus behave like Fable" → **"Make your model behave like Fable"**;
  badges and descriptions now name Sonnet 5 + Opus 4.8.
- **One report verdict**: `/iterate` and `/full-qa` reports are feeders into the
  conductor's unified report (Evidence column, per-agent cost table, no-silent-caps);
  full-qa's Go-Live verdict maps onto the DoD table instead of standing alone (PRs #5, #9).
- **Root `SKILL.md` (portable mode)** upgraded from descriptions to operational,
  host-agnostic mechanics: the full gates catalog, run-state files, claim rule, and
  degraded verifier protocol — what Cursor/Codex/Copilot users actually run (PR #11).
- **Honest claim narrowed and sourced**: evidence-grounded status reporting suppresses
  the failure modes that bite overnight runs — it does not make a model "more honest"
  in general; the ports/stays table now cites the research and corrects one row
  (honest reporting is prompt-induced on Fable too) (PR #11).
- **Route guard hardened**: authenticated real-Chrome work goes only to
  `/chrome-cdp-control` per-write gates; `/full-qa` autonomous mode is for test
  environments only (PR #6).
- State-location rule stated once: run state lives in `.taskstate/`; `.claude/` is
  reserved for hooks/evals (PR #8).

### Security
- No autonomous write path on authenticated browser sessions, ever (route guard, PR #6).
- Hardened-mode hooks are opt-in, fail-open, logged, and one-line disableable (PR #10).

## [0.1.0] — 2026-06-22

Initial release: the fable-it conductor (autonomous posture, pre-grounding gate,
three coherence guardrails, honest per-criterion report) bundled with `/launch`,
`/iterate`, `/full-qa` and `/chrome-cdp-control`; multi-platform install via the
root `SKILL.md`.

[2.0.0]: https://github.com/DevOtts/fable-it/releases/tag/v2.0.0
[0.1.0]: https://github.com/DevOtts/fable-it/commits/cb1b17a
