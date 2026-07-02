# PRD — fable-it v2: from postures to gates

**2026-07-02 · against CONTRACT v1.0 · spec: `docs/03-enhancement-spec.md`**

## 1. Summary

fable-it v1 made Opus *behave* like Fable by encoding postures reconstructed from
secondhand descriptions. v2 upgrades it with the contract captured firsthand from a
live Fable 5 session and validated against Anthropic's "Prompting Claude Fable 5"
guide: **checkable gates instead of standing exhortations, disk-backed run state
instead of assumed retention, a fresh-context verifier instead of self-critique,
and a model-adaptive posture for Sonnet 5 and Opus 4.8.**

## 2. Problem & goals

Problems (evidence: `docs/research/02-gap-analysis.md`):
- The most load-bearing behaviors (honest status, turn-end discipline) are
  self-policed prose — exactly what decays on weaker models over long runs (D-audit §10).
- `/launch`'s interactive gates stall the unattended runs the conductor promises (D2).
- Zero model-adaptive logic despite two target models (D1).
- No memory scaffold despite it being the strongest quantified win in the record
  (F7: 3x on a Fable-class model).
- Structural drift: triplicated CDP logic (D3), hardcoded ports (D4), three report
  formats (D6), unguarded manual-vs-autonomous browser boundary (D5).

Goals:
1. Every load-bearing behavior becomes a **gate** (trigger + test + action).
2. All run state survives compaction on disk and is re-read at phase boundaries.
3. VERIFIED is a **lookup**, not a vibe: no ledger entry → not VERIFIED.
4. A fresh-context verifier audits every report before it ships.
5. Model-adaptive posture table applied at Step 0 (Sonnet 5 / Opus 4.8 / Fable 5).
6. Unattended runs never stall on an interactive sub-skill gate.
7. Optional hardened mode (hooks) mechanically enforces gates on Claude Code.
8. Structural defects D3–D6, D9 fixed; claims sourced (D7); degraded mode
   operational (D8).
9. Delegation is cost-aware: work packets routed to model tiers by task shape,
   choices logged, spend disclosed in the report (F17, G2.5 — CONTRACT v1.1).

Non-goals: parity with Fable's ceiling/first-shot/retention (honest table stays,
now cited); field-guide PDF regeneration (G2.4).

## 3. Users & jobs

- **Fernando / any dev** launching overnight `/fable-it` runs on Sonnet 5 or
  Opus 4.8 — wants a survivable run and a trustworthy morning report.
- **Non-Claude-Code users** (Cursor, Codex, Copilot) via root `SKILL.md` — must get
  operational mechanics, not aspirational prose.
- **Maestro conductors** dispatching fable-it as the build engine of `/plan-it`
  packages.

## 4. Solution design — numbered decisions

| # | Decision | Rationale / cite |
|---|---|---|
| SD1 | Gates catalog (5 gates, CONTRACT §1) replaces posture prose in the conductor | gates survive weak-model drift; F2's snippet is Anthropic-measured (`01` §2) |
| SD2 | Four run-state files + lessons roll-up (CONTRACT §3) | externalize-what-Fable-holds principle (`01` §4.2); G2.3 |
| SD3 | Verifier = fresh-context subagent; degraded protocol on other hosts, same reading restriction | "fresh-context verifiers outperform self-critique" (guide, class a); reuses launch's dormant eval-runner pattern (`launch/SKILL.md:435-473`) |
| SD4 | `/launch` gains `unattended` mode: recommend-and-proceed, decisions logged | D2; conductor invokes it always-unattended |
| SD5 | Model-adaptive deltas, not forks: one contract + a posture table applied at Step 0 | keeps single source of truth; D1 |
| SD6 | CDP core extracted to one shared reference; skills point at it | D3; conductor's own anti-duplication rule `fable-it/SKILL.md:31` |
| SD7 | One report format (conductor's), extended with Evidence column, cost line, no-silent-caps section; iterate/full-qa feed it | D6, F10, F13 |
| SD8 | Hooks ship in `plugins/fable-it/hooks/`, opt-in via documented settings snippet, fail-open | G2.1 |
| SD9 | Rebrand "Make your model behave like Fable"; README cites research docs; honesty claim narrowed per `01` §3 | G2.2, D7 |
| SD10 | Cost-aware delegation routing: canonical tier table in spec §4.1, referenced (never copied) by conductor + launch; default-inherit rule; never-downgrade list; per-agent cost table in the report | F17, G2.5; mirrors the Fable 5 harness's own delegation guidance (CONTRACT v1.1) |

## 5. Epics

| ID | Epic | Tier | Deps |
|---|---|---|---|
| E1 | Conductor v2: gates catalog + run-state contract + unified report + model-adaptive block | 1 | — |
| E2 | Fresh-context verifier phase (+ degraded protocol) | 1 | E1 |
| E3 | `/launch` unattended mode + prompt upgrades + state-location fix | 1 | E1 |
| E4 | `/iterate` + `/full-qa`: delegation gate, adversarial verify, loop-until-dry, no-silent-caps, report feeders | 2 | E1 |
| E5 | CDP dedup + port parameterization + route guard | 3 | — |
| E6 | Root SKILL.md degraded upgrade + README rebrand + sources + v2.0.0 | 3 | E1, E2 |
| E7 | Hardened mode hooks | 2 | E1 |

Full scope + test contracts: `delivery/epics-fable-it-v2.md`.

## 6. Acceptance criteria (program level)

= CONTRACT §7 "Definition of shipped" (all epic test contracts 100%, consistency
lint clean, degraded-mode coverage diff clean, README sourced).

## 7. Risks

| Risk | Mitigation |
|---|---|
| Skill-file bloat: gates + tables could overflow the conductor and get skimmed by the model | budget: conductor ≤ ~300 lines; catalog is terse trigger/test/action lines; details live in referenced files |
| Hooks misfire and block legitimate stops | fail-open on error, opt-in, one-line disable, logged firings; unit tests in E7's contract |
| Test contract is mostly `[REAL]` (needs live runs) | tabletop transcript goldens where possible; `[REAL]` cases honestly IMPLEMENTED-NOT-VERIFIED if no live session available at build time |
| Model self-identification unreliable on some hosts | fall back to kickoff-prompt declaration; default = strictest (Sonnet) posture |
| Over-fitting to today's Fable prompt (it will change) | research docs versioned + dated; SOURCES section makes re-derivation cheap |

## 8. Repo/branch plan

Per CONTRACT §5: `epic/E<N>-<slug>` branches, PRs to `main`, disjoint file
ownership (epics doc). Suggested waves: Wave 0 = E1+E5 (disjoint), Wave 1 =
E2+E3+E4+E7, Wave 2 = E6 (consumes everything).
