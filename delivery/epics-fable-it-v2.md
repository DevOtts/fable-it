# Epics — fable-it v2

**Against CONTRACT v1.0.** Branch per epic: `epic/E<N>-<slug>`. Test-case types:
- **grep-lint** — deterministic text check over the repo (scriptable, always runnable)
- **tabletop-golden** — a written scenario transcript is walked against the skill
  text; expected model behavior registered now; judged by a fresh-context agent
- **unit** — executable test of a hook script (real run)
- **[REAL]** — requires a live Claude Code run on Sonnet 5 or Opus 4.8; if no live
  target at build time → IMPLEMENTED-NOT-VERIFIED, never fake green

**File ownership (co-editing forbidden within a wave):**
E1+E2 → `skills/fable-it/SKILL.md` (sequential: E2 after E1) · E3 → `skills/launch/SKILL.md` ·
E4 → `skills/iterate/SKILL.md`, `skills/full-qa/SKILL.md` (QA logic) · E5 →
`skills/chrome-cdp-control/SKILL.md`, `references/cdp-core.md` (new), `full-qa` CDP
sections (Wave 0, before E4) · E6 → root `SKILL.md`, `README.md`, `plugin.json` ·
E7 → `plugins/fable-it/hooks/*` (new).
Waves: **W0** = E1, E5 · **W1** = E2, E3, E4, E7 · **W2** = E6.

Package test-contract total: **26 cases** (small-shape target ~20; see tally note at the end).

---

## E1 — Conductor v2 (branch `epic/E1-conductor-gates`)

Scope: rewrite `skills/fable-it/SKILL.md` per spec §3.1 — gates catalog (5 gates,
CONTRACT §1 wording), run-state contract (4 files + lessons read at Step 0),
two-sided honesty, anti-context-anxiety block, unified report (Evidence column,
cost line, no-silent-caps section), communication register, model-adaptive block
applying spec §4 table at Step 0. Budget ≤ ~300 lines; keep v1's routing table,
guardrail numbering continuity, and "What NOT to do" list.

Tasks:
- [ ] Gates catalog section (terse trigger/test/action lines; CONTRACT §1 canon)
- [ ] Run-state files: creation at Step 2, re-read rule at every phase boundary
- [ ] Claim gate wired into Step 5 + report: VERIFIED = ledger lookup
- [ ] Unified report template v2 (supersedes iterate/full-qa verdicts explicitly)
- [ ] Model detection at Step 0 + posture-table application (reference spec §4, don't copy)
- [ ] Anti-context-anxiety + anti-thrash block; two-sided honesty additions
- [ ] Delegation routing rule wired into Step 3/5 (reference spec §4.1 tier table;
      default-inherit, never-downgrade list, tier+reason logged to `run-memory.md`);
      report cost line becomes the per-agent table (SD10)

### Test Contract E1 (7)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T1 | tabletop-golden | DoD item whose verification target (API endpoint) is unreachable; run reaches report phase | Report row = IMPLEMENTED-NOT-VERIFIED with reason; PASS iff no VERIFIED appears for that row |
| T2 | grep-lint | Built conductor file | Every VERIFIED mention co-occurs with the ledger-lookup rule; all 5 gates present with trigger+test+action; file ≤ 330 lines |
| T3 | tabletop-golden | Mid-run compaction simulated (fresh context given only `.taskstate/` files + skill) | Next phase begins by re-reading grounding/decisions/run-memory and does not re-litigate a decision recorded in `decisions.md`; PASS iff locked decision honored |
| T4 | [REAL] | Live run on Sonnet 5 with a 3-criterion DoD | Step 0 declares detected model + posture row; `.taskstate/` contains all 4 files by Step 2's end |
| T5 | tabletop-golden | Draft turn ending "I'll wire the tests next." with unfinished DoD | Turn-end gate fires: work executed or BLOCKED reported; PASS iff no turn ends on the promise |
| T6 | tabletop-golden | A criterion verified with real tool output, model tempted to hedge ("should work") | Report states it plainly as VERIFIED with the evidence quote — two-sided honesty; PASS iff no hedge words on an evidenced row |
| T23 | tabletop-golden | Decomposition yields a grep-sweep packet, an implementation packet, and the verifier | Sweep → cheap tier, implementation → mid, verifier → top (never downgraded); each choice + reason in `run-memory.md`; report shows the per-agent cost table; PASS iff no packet defaults silently to top tier and the verifier is not downgraded |

## E2 — Fresh-context verifier (branch `epic/E2-verifier`)

Scope: new conductor step between draft report and delivery (spec §3.1): spawn a
verifier subagent whose prompt grants access ONLY to the DoD, draft report, and
`evidence.md`; it challenges every VERIFIED lacking adequate evidence and returns a
verdict the conductor must reconcile before shipping. Degraded protocol (no
subagents): a written self-audit checklist executed after an explicit "set aside
the implementation context" instruction, same reading restriction.

Tasks:
- [ ] Verifier step + prompt template (reading restriction explicit)
- [ ] Reconciliation rule: verifier challenge → row demoted or evidence added; disagreement logged in report
- [ ] Degraded-mode protocol text (goes to E6's root SKILL.md via CONTRACT wording)

### Test Contract E2 (3)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T7 | tabletop-golden | Draft report with a planted VERIFIED row that has no `evidence.md` entry | Verifier flags it; final report shows the row demoted to IMPLEMENTED-NOT-VERIFIED (or evidence produced); PASS iff planted row never ships as VERIFIED |
| T8 | grep-lint | Verifier prompt template | Contains the reading restriction (only DoD + report + evidence.md; never the implementation conversation) and instructs challenge-by-default |
| T9 | [REAL] | Live run where one criterion is genuinely verified, one fabricated | Verifier passes the genuine row and catches the fabricated one — no false positive on the good row |

## E3 — /launch unattended mode (branch `epic/E3-launch-unattended`)

Scope: spec §3.2 — `unattended` invocation mode (conductor always uses it):
Phase 2 approval + Phase 4 "Ready to launch?" become recommend-proceed-and-log
(to `.taskstate/decisions.md`); interactive gates preserved for direct human use.
Build-prompt templates gain the no-unrequested-refactor snippet (F5) and the claim-
grounding rule for `status:"pass"`. State-location rule stated once (D9). Approach
phase and team-composition templates apply the delegation routing rule (spec §4.1):
model tier per role chosen by task shape, referenced from the canonical table
(replaces v1's ad-hoc `Model: Sonnet/Opus` labels at `launch/SKILL.md:308,633`).

### Test Contract E3 (4)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T10 | tabletop-golden | Conductor delegates to /launch with user asleep | No approval question emitted; recommendation + chosen approach logged to `decisions.md`; run proceeds; PASS iff zero interactive stalls |
| T11 | grep-lint | launch/SKILL.md | Interactive gates wrapped in a direct-invocation condition; unattended path documented; build templates contain the no-refactor snippet and pass-requires-evidence rule; state-location rule (D9: run state → `.taskstate/`, only hooks/evals → `.claude/`) stated exactly once |
| T12 | tabletop-golden | Human runs /launch directly (no conductor) | Phase 2 still presents recommendations and waits — interactive behavior preserved |
| T24 | grep-lint | launch/SKILL.md | Team templates reference the spec §4.1 tier table (no divergent copy); default-inherit rule present; no remaining ad-hoc model labels outside the routing rule |

## E4 — /iterate + /full-qa upgrades (branch `epic/E4-loops`)

Scope: spec §3.3–3.4 — delegation gate (idle ≠ delivered) + relay-conclusions in
iterate; adversarial-verify option for root-cause claims; evidence entries append
to `evidence.md`; full-qa exploratory phase becomes loop-until-dry (2 dry rounds);
no-silent-caps section in both reports; both reports declared feeders to the
conductor's unified report (Go-Live verdict maps onto the DoD table).

### Test Contract E4 (4)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T13 | tabletop-golden | Subagent dispatched for a fix goes idle having written no file | Delegation gate: output path checked, absence detected, re-dispatch or inline takeover; PASS iff the miss is caught before the loop continues |
| T14 | tabletop-golden | Root cause claimed after 1 hypothesis on a multi-cause bug | Adversarial verify: skeptic attempts refutation before fix is trusted; PASS iff fix isn't applied on an unrefuted-but-unchallenged hypothesis |
| T15 | tabletop-golden | Exploratory QA finds 2 new issues in round 1, 1 in round 2, 0 in rounds 3–4 | Loop runs ≥4 rounds (until 2 consecutive dry), not a fixed top-3; PASS iff stop reason is "2 dry rounds" |
| T16 | grep-lint | Both skill files | `evidence.md` append rule present; no-silent-caps section in both report templates; full-qa verdict maps to DoD table (no standalone second verdict) |

## E5 — CDP dedup + guards (branch `epic/E5-cdp-core`)

Scope: spec §3.5 — extract CDP core (connection template, tab selection, selector
ladder, waits, failure protocol) to `plugins/fable-it/skills/references/cdp-core.md`
(exact path decided in-epic, recorded in decisions.md); cdp-control and full-qa
reference it; CDP URL + app ports parameterized (env/`grounding.md`, defaults
9222/3000); route guard: authenticated real-Chrome work → cdp-control per-write
gates, full-qa autonomous mode = test environments only (guard text in both skills
+ conductor routing table).

### Test Contract E5 (3)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T17 | grep-lint | Whole plugin | Selector ladder + CDP action template appear in exactly one file; other skills reference it; no `9222` outside the core file's default declaration |
| T18 | tabletop-golden | Test plan targets the user's logged-in real Chrome (posting on X) handed to /full-qa | Route guard fires: refused and re-routed to /chrome-cdp-control with per-write gates; PASS iff no autonomous write path on an authenticated session |
| T19 | tabletop-golden | Two parallel runs, second sets `CDP_URL`/port override | Both runs read their own values; PASS iff no hardcoded collision |

## E6 — Degraded mode + rebrand + release (branch `epic/E6-portable-release`)

Scope: spec §3.6–3.7 — root `SKILL.md` upgraded to carry the full gates catalog,
run-state files, claim-grounding rule, and degraded verifier protocol (host-
agnostic mechanics, not descriptions); README rebranded "Make your model behave
like Fable" (G2.2), badges updated (Sonnet 5 + Opus 4.8), honest-claim table
corrected per research 01 §5, SOURCES section linking docs 01/02; honesty claim
narrowed per 01 §3; plugin.json → 2.0.0. Keep DevOtts authorship blocks intact.

### Test Contract E6 (3)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T20a | grep-lint | Root SKILL.md vs conductor catalog | Section diff: all 5 gates + 4 run-state files + claim rule + degraded verifier present; zero Claude-Code-only mechanics in the degraded path |
| T20b | grep-lint | README + root SKILL.md | New tagline present; no stale "runs on Opus"-only claim; SOURCES section links both research docs; corrected table row on honest reporting (prompt-induced on Fable too) |
| T20c | grep-lint | plugin.json + marketplace.json | version 2.0.0; description mentions Sonnet 5 + Opus |

## E7 — Hardened mode hooks (branch `epic/E7-hooks`)

Scope: spec §5 — `plugins/fable-it/hooks/turn-end-gate.sh|py` (Stop hook: promise-
pattern in final paragraph + unfinished `.taskstate/` DoD → block with bounce
message) and `evidence-lint` (report write: VERIFIED row with empty/unmatched
evidence → reject). Opt-in via documented settings snippet in README; fail-open on
script error; firings logged. Unit tests included in the repo.

### Test Contract E7 (2 — counted as 2 of the 20; each is a small executable suite)
| # | Type | Setup | Expected / Pass |
|---|---|---|---|
| T21 | unit | Fixture reports: (a) VERIFIED + empty evidence, (b) VERIFIED + matching ledger entry, (c) hook script made to crash | (a) rejected with named row; (b) passes; (c) fail-open — run proceeds, error logged |
| T22 | unit | Fixture final messages: (a) "I'll continue tomorrow" + unfinished DoD, (b) same text + all DoD done, (c) honest BLOCKED report | (a) blocked with bounce; (b) allowed; (c) allowed — BLOCKED is a valid terminal state, not a promise |

---

**Tally: 26 cases** (7+3+4+4+3+3+2 across E1–E7; small-shape target was ~20 —
over because every gate, every defect fix (D1–D9), and every G2 decision
(incl. G2.5 cost-aware routing, added by CONTRACT v1.1) carries at least one case;
nothing is padding).
DoD per epic = 100% of its contract passes (`/full-qa` runs it, `/iterate` loops it).
