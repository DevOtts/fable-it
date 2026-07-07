# fable-it v2 — enhancement spec

**2026-07-02 · builds on `research/01-fable5-vs-opus.md` (advantages F1–F16) and
`research/02-gap-analysis.md` (gaps, defects D1–D9, priority tiers)**

## 0. Locked decisions (Gate G2, 2026-07-02, owner: Fernando)

| # | Decision | Locked answer |
|---|---|---|
| G2.1 | Hooks-based hardened mode | **YES** — optional, opt-in, easy to disable; 2–3 small hook scripts for Claude Code (turn-end gate + report evidence lint). Prose gates remain the baseline on all hosts |
| G2.2 | Rebrand | **YES** — "Make your model behave like Fable"; model-adaptive framing, Sonnet 5 + Opus badges, honest-claim table corrected and linked to the research docs |
| G2.3 | Memory scope | **Per-run + cross-run** — `.taskstate/run-memory.md` during the run, rolled up into `.fable-it-reports/lessons.md` read at Step 0 of future runs on the same project |
| G2.4 | Field-guide PDF | **Deferred** — out of v2 scope (separate design task); v2 only corrects README/SKILL text |
| G2.5 | Cost-aware delegation routing (added post-freeze 2026-07-02, owner: Fernando) | **YES** — when splitting into subagents/teams, route each work packet to a model tier by task shape instead of running everything on the top model; see §4.1 (F17) |

## 1. Vision

fable-it v1 encoded the *postures* of a Fable-class run, reconstructed secondhand.
v2 encodes the **contract** — captured firsthand from a live Fable 5 session and
cross-checked against Anthropic's own "Prompting Claude Fable 5" guide, which
publishes the snippets and their measured effects.

One sentence: **v2 turns fable-it from a set of postures into a set of checkable
gates with disk-backed state, adapted per model.** Tagline direction: from
"Make Opus behave like Fable" to "Make *your model* behave like Fable" —
model-adaptive for Sonnet 5 and Opus 4.8.

The three governing principles (research doc 01 §4):
1. **Gates, not vibes** — every load-bearing behavior gets a trigger and a test.
2. **Externalize what Fable holds in its head** — disk artifacts + mandatory
   re-reads replace trained retention.
3. **Verify with fresh eyes** — a fresh-context verifier, not self-critique, is the
   honesty mechanism.

## 2. The run-state contract (new, cross-cutting)

Every fable-it run maintains four files in `.taskstate/` (all compaction-proof,
all re-read at every phase boundary):

| File | Contents | Written | Read |
|---|---|---|---|
| `grounding.md` | The grounding statement: how data is modeled, where stored, per-DoD-item verification path + reachability | Step 2 (pre-grounding); refreshed each phase | Every phase start (mandatory) |
| `decisions.md` | Shared decision contract (v1's Guardrail 1, unchanged format) | any cross-cutting decision | before any subagent decides |
| `evidence.md` | **The evidence ledger**: one entry per DoD criterion per verification attempt — timestamp, tool command run, observed output (quoted), verdict | every verification | report phase + verifier |
| `run-memory.md` | Failed approaches (so they're not retried), env quirks, decision rationale, surprises | when learned | phase starts; next runs read `.fable-it-reports/lessons.md` roll-up |

**The claim-grounding gate (F2 — Anthropic-measured):** a criterion may be reported
VERIFIED **only if `evidence.md` contains a tool result from this session** backing
it. No ledger entry → the status is IMPLEMENTED-NOT-VERIFIED, mechanically. This
converts Guardrail 3 from self-policing into a lookup.

## 3. Changes per component

### 3.1 Conductor (`skills/fable-it/SKILL.md`)

- **Gates catalog** replaces posture prose. Each gate = trigger + test + action:
  - *Turn-end gate* (F3): before ending any turn — is the last paragraph a plan,
    question, or promise? → do that work now.
  - *Claim gate* (F2): before writing any status — is there a ledger entry with a
    tool result from this session? → else IMPLEMENTED-NOT-VERIFIED.
  - *State-change gate* (F12): before any state-changing command — does the evidence
    support *this specific action*, or does the signal merely pattern-match a known
    failure?
  - *Phase-boundary gate* (F8): entering any phase — re-read `grounding.md`,
    `decisions.md`, `run-memory.md` before acting.
  - *Delegation gate* (F9): after any subagent/team completes — verify its output
    exists on disk and is non-empty; idle ≠ delivered.
- **Two-sided honesty** (F4): add the missing half — verified results are stated
  plainly, no hedging; plus look-before-overwrite and approval-doesn't-carry rules.
- **Anti-context-anxiety block** (F8): "long context is survivable; state lives on
  disk; do not wrap up early, do not re-derive established facts, do not re-litigate
  locked decisions; recommend, don't survey."
- **Verifier phase** (F6, new Step): after the draft report, a **fresh-context
  verifier** audits it — reads ONLY the DoD, the report, and `evidence.md` (never
  the implementation conversation), and challenges every VERIFIED without adequate
  evidence. Claude Code: a subagent. Degraded hosts: a scripted self-audit protocol
  with the same reading restriction stated.
- **Model-adaptive block** (D1, new): detect/declare the running model at Step 0;
  apply the per-model posture table (§4).
- **Unified report** (D6): one canonical format (v1 conductor's, extended with an
  Evidence column sourced from the ledger, a cost/pacing line (F13), and a
  no-silent-caps section: anything skipped, sampled, or bounded is listed (F10)).
  `/iterate` and `/full-qa` reports become *feeder* formats explicitly.
- **Communication register** (F11): report writing rules — lead with the outcome;
  complete sentences; no invented codenames/arrow-chains; written for a teammate
  waking up.

### 3.2 `/launch`

- **Non-interactive mode** (D2): when invoked by the conductor (or flagged
  `unattended`), Phase 2 approval and the Phase 4 "Ready to launch?" become
  recommend-and-proceed with the decision logged to `decisions.md`. Interactive
  gates remain for direct human invocation.
- Build-prompt templates gain the no-unrequested-refactor snippet (F5) and the
  claim-grounding rule for feature `status:"pass"` transitions.
- Resolve D9: all run state under `.taskstate/`, `.claude/` only for hooks/evals
  that must live there; stated once as a rule.

### 3.3 `/iterate`

- Delegation gate (idle ≠ delivered) + relay-conclusions discipline (F9).
- **Adversarial verify** option (F10): for a claimed root cause, spawn a skeptic
  prompted to *refute* it before the fix is trusted (v1's competing-hypotheses
  pattern, promoted from launch's appendix into the loop).
- Evidence entries append to `evidence.md` (not just the final report).

### 3.4 `/full-qa`

- **Loop-until-dry** exploratory phase (F10): keep generating exploratory tests
  until 2 consecutive rounds surface nothing new, instead of fixed "top 3-5".
- **No-silent-caps**: the report lists every test skipped/bounded and why.
- Report feeds the conductor's unified report; Go-Live verdict maps onto the DoD
  table instead of standing alone (D6).
- Ports/CDP URL parameterized (D4): read from env/`grounding.md`, defaulting to
  `localhost:9222`/3000.

### 3.5 `/chrome-cdp-control` + CDP dedup

- **Single source of truth** (D3): extract the CDP core (connection template,
  tab-selection, selector ladder, wait strategy, failure protocol) to a shared
  reference the plugin skills point at; `full-qa` keeps only its QA-specific loop.
- **Route guard** (D5): a hard rule in both skills — authenticated real-Chrome
  session work routes to `/chrome-cdp-control` with per-write gates; `/full-qa`'s
  autonomous mode is for test environments only. The conductor's routing table
  states the guard.
- Parameterized CDP URL (D4).

### 3.6 Root `SKILL.md` (degraded/portable mode)

- Upgrade from descriptions to **mechanics** (D8): the degraded mode carries the
  full gates catalog, the four run-state files, the claim-grounding rule, and the
  self-audit verifier protocol — all host-agnostic prose. This is what Codex/Cursor
  users actually run; it must be operational, not aspirational.

### 3.7 README + sources (D7)

- Cite the research: link `docs/research/01` + `02` as the evidence behind the
  ports/stays table; correct the table per research 01 §5 (honest reporting is
  prompt-induced on Fable too — the best news for the skill).
- Rebrand for model-adaptivity (pending G2 decision on wording).
- Narrow the honesty claim per research 01 §3 (suppresses fabricated status/refs;
  does not make a model "more honest" in general).

## 4. The model-adaptive posture table (D1)

> **Canonical home moved (v2.1, 2026-07-05):** the posture table now lives at
> [`plugins/fable-it/skills/references/model-tiers.md`](../plugins/fable-it/skills/references/model-tiers.md) §1
> so it **ships with the plugin** — this doc does not, and skills that referenced
> it here resolved nothing on installed hosts (the v2.1 gap fix). Skills reference
> the plugin file; no divergent copies. This section keeps the design rationale
> only: detected at Step 0 (harness self-identification; fall back to the kickoff
> prompt's declaration; else strictest posture), applied as deltas on the shared
> contract, because the three runner models fail differently — Sonnet drifts
> without re-grounding, Opus over-builds at high effort, Fable self-verifies well.

### 4.1 Cost-aware delegation routing (F17, G2.5)

> **Canonical home moved (v2.1):** the tier table and routing gates live at
> [`plugins/fable-it/skills/references/model-tiers.md`](../plugins/fable-it/skills/references/model-tiers.md) §2–3.
> Rationale kept here: packets route to cheap/mid/top tiers **by task shape**
> rather than defaulting to the session model, because top-tier prices on
> mechanical packets buy nothing. v2.1 added routing gate 3, **escalate on
> struggle, don't pre-pay**: a lower-tier packet that fails its contract after
> one corrected re-dispatch (or thrashes) is re-run one tier up, with the
> escalation logged and disclosed — the escalation path is what makes
> cheap-by-default safe. The conductor is whatever model the user chose; "top
> tier" means the session model, never a hardcoded name.

## 5. Hardened mode (G2.1 — in scope)

Optional, opt-in enforcement layer for Claude Code only (`hooks/` inside the
plugin, wired via a documented settings snippet the user adds deliberately):

- **Turn-end hook** (Stop hook): blocks ending a turn whose final message's last
  paragraph is a promise/plan pattern ("I'll …", "Next I will …", "Let me know
  when …") while `.taskstate/` shows unfinished DoD criteria. Bounce message tells
  the model to execute the promise or report BLOCKED.
- **Evidence lint hook**: when the final report file is written, rejects any DoD
  row marked VERIFIED whose evidence cell is empty or has no matching entry in
  `.taskstate/evidence.md`.
- Both hooks: fail-open on script error (never brick a run), one-line disable,
  and clearly logged when they fire.

## 6. Out of scope for v2 (explicit)

- Claiming parity with Fable on ceiling/first-shot/retention (F15/F16) — the honest
  table stays, now cited.
- Field-guide PDF regeneration (G2.4 — deferred; design asset, separate task).

## 7. Success measures

1. **The test contract** (authored in the epics; binding): scenario-based goldens
   exercising each gate — e.g., a run with an unreachable verification target MUST
   produce IMPLEMENTED-NOT-VERIFIED, never VERIFIED; a report claim without a
   ledger entry MUST be caught by the verifier.
2. Zero contradictions between skills after D2/D3/D5/D6 fixes (lint: grep for the
   known conflict pairs).
3. Degraded-mode completeness: every gate present in root `SKILL.md` (checkable by
   section diff against the conductor's catalog).
