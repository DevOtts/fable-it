# Fable-it Report — Build fable-it v2 per the frozen delivery package (postures → gates, evidence ledger, verifier, model-adaptive, v2.0.0)

Run window: 2026-07-02 ~18:30 → ~19:20 UTC   |   Model: Fable 5 (claude-fable-5), posture row "Fable 5" (contract-minimum re-grounding; verifier still run)   |   Approach: single conductor thread + subagents for fresh-context judging and [REAL] live runs

## DoD status

| # | Criterion | Status | Evidence (from the ledger) / Blocker |
|---|-----------|--------|--------------------------------------|
| 1 | All 7 epics implemented on their branches and merged to main | VERIFIED | `gh pr list --state merged`: PRs #5 (E1), #6 (E5), #7 (E2), #8 (E3), #9 (E4), #10 (E7), #11 (E6) all MERGED 2026-07-02, waves W0→W1→W2 in order |
| 2 | 26-case test contract passes 100% (goldens fresh-context judged vs registered transcripts; grep-lints scripted green; E7 unit green; [REAL] live or honest) | VERIFIED | 13 goldens (T1,T3,T5,T6,T7,T10,T12,T13,T14,T15,T18,T19,T23) judged "VERDICT: PASS" by fresh-context agents vs transcripts registered in `delivery/goldens/` before implementation; 8 grep-lints scripted in `tests/lints/` all PASS; T21/T22 unit suites "ALL HOOK TESTS PASS"; T4 [REAL] ran live on a Sonnet 5 session (Step 0 declared "Detected model — Sonnet 5. Applied posture row…", all 4 `.taskstate/` files verified on disk by the conductor); T9 [REAL] ran live on an Opus 4.8 session ("CONFIRM row 1… CHALLENGE row 2 — there is NO ledger entry", no false positive) |
| 3 | Consistency lint clean per CONTRACT §7.2 | VERIFIED | `./tests/lints/consistency-7-2.sh` → "ok(§7.2-1) CDP core single-sourced / ok(§7.2-2) no interactive gate reachable unattended / ok(§7.2-3) one verdict source / ok(§7.2-4) no stale v1-only claim — CONSISTENCY §7.2 PASS" |
| 4 | Root SKILL.md gate coverage = conductor catalog (CONTRACT §7.3) | VERIFIED | `./tests/lints/t20-release.sh` T20a section diff: all 5 gates with trigger+test+action, 4 run-state files, claim rule, degraded verifier present in root; mechanics region host-agnostic (zero Claude-Code-only terms) |
| 5 | README rebranded + SOURCES linking research 01/02; plugin.json at 2.0.0 | VERIFIED | T20b: tagline "Make your model behave like Fable" in README + root SKILL.md, no stale v1 tagline, Sonnet 5 + Opus 4.8 badges, SOURCES links `docs/research/01-fable5-vs-opus.md` + `02-gap-analysis.md`, corrected prompt-induced row; T20c: plugin.json + marketplace.json `"version": "2.0.0"` with Sonnet 5 + Opus descriptions |
| 6 | delivery/STATUS.md reflects final per-epic status; final report in .fable-it-reports/ with per-criterion evidence | VERIFIED | Ledger DoD-6: `grep -n "| E" delivery/STATUS.md` → all 7 epic rows **verified** with contract counts and PR #5–#11, header "26/26 test-contract cases pass"; `ls .fable-it-reports/report.md` → exists (7.2K) |

## Verifier audit (Step 7)
A fresh-context verifier (agent ac38ff61990857347, reading only the DoD, this report, and the evidence ledger) returned **5 CONFIRM, 1 CHALLENGE**: row 6 was flagged for lacking a ledger entry ("no `### DoD-6` entry… either append a DoD-6 ledger entry with observed output or downgrade the row"). Reconciled per the rule: the real check was run (`grep` of STATUS.md rows + `ls` of this file) and appended to the ledger as DoD-6; the row's evidence cell now cites it. No unresolved disagreements.

## Could not be verified (and why)
- Nothing. Both `[REAL]` cases had reachable live targets this session (Sonnet 5 and Opus 4.8 subagent sessions inside Claude Code), so no criterion fell to IMPLEMENTED-NOT-VERIFIED. Scope note for the reader: T4/T9 ran as live Agent-tool sessions on the target models executing the real skill text against real disk state — not standalone terminal sessions. The runs, models, and artifacts are real; if you want a belt-and-suspenders check, re-run T4 in a plain `claude --model sonnet` terminal session.

## No silent caps
- Golden judging used one fresh-context judge per case (the epics doc specifies "a fresh-context agent", singular) — not a multi-judge panel.
- `[REAL]` coverage: T4 exercised Sonnet 5, T9 exercised Opus 4.8 — each case on one target model, as the contract's setups specify; no case was run on both models.
- Nothing else was skipped, sampled, or bounded: all 26 cases executed, all lints run repo-wide.

## Delegation & cost
| Packet | Model tier | Why |
|---|---|---|
| All skill rewrites (E1–E7) | Top (session model, Fable 5, single thread) | Decision-coupled judgment work sharing the CONTRACT vocabulary — coherence rule says one thread |
| 13 golden judges | Top (inherit, Fable 5) | Verifier-class packets — never-downgrade rule |
| T4 [REAL] runner | Sonnet 5 (mid) | The test case itself specifies the target model |
| T9 [REAL] verifier | Opus 4.8 (top) | [REAL] target model; verifier never downgraded |
| Final report verifier | Top (inherit, Fable 5) | Never-downgrade rule |

## What changed
- `plugins/fable-it/skills/fable-it/SKILL.md` — rewritten: 5-gate catalog, run-state contract, model-adaptive Step 0, delegation routing, unified report v2, verifier Step 7 (E1+E2)
- `plugins/fable-it/skills/references/cdp-core.md` — new: single-source CDP mechanics, CDP_URL/APP_URL resolution, route guard (E5)
- `plugins/fable-it/skills/chrome-cdp-control/SKILL.md`, `.../full-qa/SKILL.md` — consume the core; route guard; full-qa loop-until-dry, no-silent-caps, feeder verdict (E5+E4)
- `plugins/fable-it/skills/launch/SKILL.md` — invocation modes (unattended), routing-rule team templates, D9 single statement, no-refactor + pass-requires-evidence snippets (E3)
- `plugins/fable-it/skills/iterate/SKILL.md` — delegation gate, adversarial verify, ledger appends, feeder + no-silent-caps (E4)
- `plugins/fable-it/hooks/` — new: turn-end-gate.py, evidence-lint.py, README (opt-in snippet, dod.md convention), tests (E7)
- Root `SKILL.md` (v2 degraded mechanics), `README.md` (rebrand + SOURCES), `plugin.json`/`marketplace.json` → 2.0.0 (E6)
- `delivery/goldens/` (13 registered transcripts), `tests/lints/` (9 scripts incl. §7.2 + run-all), `delivery/STATUS.md`

## Decisions made (from decisions.md)
- B1: sequential execution in one thread for skill rewrites (decision-coupled); subagents only for judging and [REAL] runs
- B2/B3/B4: goldens at `delivery/goldens/` registered pre-implementation; lints at `tests/lints/`; hook tests at `plugins/fable-it/hooks/tests/`
- B7: CDP core path = `plugins/fable-it/skills/references/cdp-core.md`
- B9: hardened-mode DoD state convention = `.taskstate/dod.md` checkbox list (additive; documented in hooks/README.md)
- B10: hooks opt-in snippet documented in `plugins/fable-it/hooks/README.md`; root README links it (file-ownership respect)

## Surprises / risks found
- Subagent harness refuses report-file writes from spawned agents ("return findings as text") — the T4 runner delivered its report as text instead of `.fable-it-reports/report.md`. Harmless for T4's pass conditions, but worth knowing: conductor runs executed *as subagents* can't write report artifacts.
- The T10 judge caught a residual interactive phrase in launch §4.3 ("If the user confirms…") — fixed before merge; judges earn their keep.
- `find` on the scratchpad displayed an aggregated format that hid dotfiles — verify hidden dirs with `ls -la`, not `find` output eyeballing.

## Recommended next actions
- Optionally re-run T4 in a standalone `claude --model sonnet` terminal session for belt-and-suspenders [REAL] coverage (see scope note above).
- Consider enabling hardened mode in this repo's own `.claude/settings.json` (snippet in `plugins/fable-it/hooks/README.md`) so future fable-it runs here are mechanically gated.
- G2.4 (field-guide PDF regeneration) remains deferred by decision — the PDF still shows v1 content; regenerate when convenient.
- Tag a `v2.0.0` GitHub release if you want the marketplace pin to a release rather than main.
