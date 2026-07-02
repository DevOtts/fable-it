# fable-it v2 — CONTRACT (frozen v1.0 · 2026-07-02 · amended v1.1)

The law for the v2 build. Every epic writes *to* this contract. Cross-cutting
discoveries fold back here as dated amendments (v1.0 → v1.1 …), never as local
improvisation.

## 1. Canonical vocabulary

| Term | Meaning | Single source |
|---|---|---|
| **Gate** | trigger + test + action, checked at a decision point (never a standing exhortation) | conductor gates catalog (E1) |
| **Turn-end gate** | before ending a turn: last paragraph a plan/question/promise? → do the work now or report BLOCKED | catalog |
| **Claim gate** | before reporting a criterion: is there an `evidence.md` entry with a tool result from this session? → else IMPLEMENTED-NOT-VERIFIED | catalog |
| **State-change gate** | before a state-changing command: does evidence support *this specific action*? | catalog |
| **Phase-boundary gate** | entering any phase: re-read `grounding.md`, `decisions.md`, `run-memory.md` | catalog |
| **Delegation gate** | after any subagent/team: verify output exists on disk, non-empty — idle ≠ delivered | catalog |
| **Verifier** | fresh-context auditor that reads ONLY DoD + draft report + `evidence.md` (never the implementation conversation) | E2 |
| **Hardened mode** | optional Claude Code hooks layer (turn-end + evidence lint), fail-open, opt-in | E7 |
| **Delegation routing rule** | each subagent/team packet routed to a model tier by task shape (cheap/mid/top); default = inherit when unsure; never downgrade verifier or contract-writing packets; choice + reason logged; spend disclosed in report | spec §4.1 (F17, G2.5) — v1.1 |

## 2. Status enum (unchanged from v1, now mechanically derived)

`VERIFIED` · `IMPLEMENTED-NOT-VERIFIED` · `BLOCKED`
- VERIFIED **requires** a same-session tool-result entry in `evidence.md`.
- A `[REAL]` criterion with an unreachable target is IMPLEMENTED-NOT-VERIFIED —
  never VERIFIED on a mock. (v1 Guardrail 3, retained verbatim.)

## 3. Run-state artifact canon

All run state lives in `.taskstate/` (never `.claude/`, which is reserved for
hooks/evals that must live there):

| File | Role |
|---|---|
| `.taskstate/grounding.md` | grounding statement + per-DoD verification paths + reachability |
| `.taskstate/decisions.md` | shared decision contract (v1 Guardrail 1 format) |
| `.taskstate/evidence.md` | evidence ledger: criterion · timestamp · command · quoted output · verdict |
| `.taskstate/run-memory.md` | failed approaches, env quirks, rationale, surprises |
| `.fable-it-reports/lessons.md` | cross-run roll-up, read at Step 0 of future runs (G2.3) |
| `.fable-it-reports/report.md` | the unified final report (single verdict source) |

## 4. Reference IDs

- **F1–F16** — Fable 5 advantages: `docs/research/01-fable5-vs-opus.md` §2.
- **D1–D9** — v1 structural defects: `docs/research/02-gap-analysis.md` §2.
- **G2.1–G2.4** — locked human decisions: `docs/03-enhancement-spec.md` §0.

## 5. Repo & branch map

Single repo `DevOtts/fable-it`. One branch per epic: `epic/E<N>-<slug>` off `main`,
PR back to `main`. Files owned per epic (disjoint — see epics doc §ownership).
Plugin version bumps to **2.0.0** in `plugins/fable-it/.claude-plugin/plugin.json`
as part of E6.

## 6. Model-adaptive posture canon (G2 target: Sonnet 5 + Opus 4.8)

The table in `docs/03-enhancement-spec.md` §4 is canonical. Skills reference it;
no skill embeds a divergent copy.

## 7. Definition of "shipped"

1. All 7 epics merged; every epic's Test Contract passes 100% (`[REAL]` cases
   verified in a live Claude Code session, or reported IMPLEMENTED-NOT-VERIFIED
   honestly — never fake green).
2. Consistency lint clean: no duplicated CDP core text; no `/launch` interactive
   gate reachable from an unattended conductor run; one report verdict; grep
   finds no stale "Make Opus behave like Fable" claim outside history/changelog.
3. Root `SKILL.md` gate coverage = conductor catalog (section diff).
4. README links research docs 01/02 as the evidence for the ports/stays table.

## 8. Changelog

- v1.0 (2026-07-02) — frozen at Gate G3.
- v1.1 (2026-07-02) — added Delegation routing rule (§1) per user decision G2.5:
  cost-aware model-tier selection for subagents/teams (F17, spec §4.1). Touches
  E1 (conductor delegation gate + report cost table) and E3 (launch approach
  phase + team templates). Test contract grows to 26 cases (T23, T24).
