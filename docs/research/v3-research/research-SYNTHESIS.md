# plan-it v3 — Consolidated Research Synthesis

**Inputs:** research-BRIEF.md, findings A–H (15 PLAN→EXECUTION pairs, 69 enhancement candidates EC-A1…EC-H8), research-FOUNDER-INPUT.md (FD-1, FD-2 — mandated).
**Grade distribution:** 1×A, 7×A-, 4×B+, 2×B, 1×B-. The freeze/contract core works; losses concentrate in *environment ground truth, handoffs, and the user's real DoD*.

---

## 1. Scoreboard

| # | Pair | Grade | One-line reason (verbatim from findings) |
|---|------|-------|------------------------------------------|
| 1 | done-airtable-database-plan → airtable-database-execution (A) | **A-** | "execution consumed the package verbatim (CONTRACT cited, canonical test IDs driven, KICKOFF Phase-0 honored), but infra ground truth (RabbitMQ/Redis) was wrong until the user corrected it, and the contract needed a v1.3 build-time amendment" |
| 2 | anm-process-plan → anm-process-execution (A) | **B-** | "the package was coherent and rich, but the DoD churned twice *after* freeze on user corrections (video DoD, tool reuse), the pasted launch prompt arrived corrupted in the exec session, and that exec session built **nothing** (read docs, stopped, user pivoted to `/shopify-forge`)" |
| 3 | brain-docs-refactor-plan → brain-docs-refactor-execution + all-to-main-cleanup (B) | **A-** | "execution followed the frozen package near-verbatim with zero mid-run redirects on scope; misses were environmental (plugins absent in the target subscription config, dirty brain-docs repo, stale memory pointer) and git-policy (push scope ambiguity), not spec" |
| 4 | brand-docs-bible-plan → brand-bible-execution (B) | **B** | "the 26-case Test Contract + evidence-ledger machinery worked superbly (25/26 VERIFIED, fresh-eyes verifier zero challenges), but the plan's scope ended at local verify: prod deploy exposed a multi-tenant credential-architecture miss (env-var R2 creds vs shared Docker image → per-org Integrations rewire), test-auth was unplanned, and a plan-time-known gap (INV-2 no regression test) shipped" |
| 5 | done-dark-channel-plan (+ it-7 re-plan) → dark-channel-exec-pt1 (+ it-7 build) (C) | **B** | "execution followed the frozen package near-verbatim and Test Contracts caught real defects, but a full iteration of rework (v2 'quality editor') was needed because the plan never pinned the visual-quality NFR, and stale anchors + missing env facts leaked into both builds" |
| 6 | db-organization-plan → db-organization-execution (C) | **A-** | "a 13-epic/184-case package executed essentially as frozen with the safety ladder holding; the failures that surfaced were research-accuracy errors (stream-C) and infra-existence assumptions, not plan-structure gaps" |
| 7 | e2e-unit-tests-plan → done-e2e-unit-tests-execution (D) | **B+** | "plan artifacts (frozen CONTRACT, gate-check, per-epic Test Contracts) demonstrably drove an honest 7-epic ship, but the handoff broke across subscriptions and pre-grounding trusted a wrong claim about existing tests" |
| 8 | fable-v2-plan (fable-enhance-by-fable) → fable-v2-execution (D) | **A-** | "the frozen delivery package (KICKOFF read-order + CONTRACT v1.1 + 26-case contract) was consumed verbatim and the build shipped v2.0.0 with 26/26 evidence-backed in ~50 min…; only a packaging-time YAML bug and contract-size churn escaped planning" |
| 9 | full-praxya-plan → done-full-praxya-imp-pt1 (E) | **A-** | "execution consumed the package in the mandated order and the frozen CONTRACT + binding Test Contracts held end-to-end; docked for missed deploy-path/ops facts and zero provision for session-close bookkeeping and subagent lifecycle" |
| 10 | full-praxya-pt2-plan → full-praxya-exec-pt2 (E) | **B+ / A** | "**B+ for the pt1 package as executed in W2–W6** (contracts and the wave-kickoff fold held, but product-trust invariants and UI-state semantics were never planned, causing post-ship feedback rework) / **A for pt2-plan itself** — a model verify-then-extend re-plan that plan-it v3 should productize" |
| 11 | done-mcp-tparty-plan → mcp-tparty-execution (F) | **B+** | "thorough 6-stream discovery + frozen CONTRACT v1.1 carried cleanly into execution, but a gap the plan's own research flagged (composer 'installed MCPs' listing) resurfaced as the user-blocking failure, and [REAL] runtime verification was under-provisioned" |
| 12 | migrate-master-admin-plan → migrate-master-admin-execute-loudr + -claudott (F) | **A-** | "exceptional package (21-case/14-[REAL] contract, statechart, gate-check.mjs, live-cross-checked epics) that execution cited constantly; docked for a frozen-contract semantic error shipped live (§2 `connectors_brain_api_url`), an unprocured credential gate (devotts Vercel token), and a missed CORS/origin surface" |
| 13 | observability-feedback-plan → observability-feedback-execution + pt3-exec + done-observability-beacon (G) | **B+** | "the full plan-it run's artifacts (frozen contract, 20-case Test Contract, KICKOFF+launch prompt) demonstrably steered execution, but every cross-session handoff carried at least one broken path, stale claim, or unrunnable test precondition that execution had to repair" |
| 14 | smart-composer-plan → smart-composer-exec (H) | **A-** | "execution followed the package epic-by-epic with zero doc-location confusion; grade capped by one unplanned performance workstream (Redis search cache) and hook-driven bookkeeping the plan never mentioned" |
| 15 | plan-it-foundation → plan-it-execution (dogfood) (H) | **A** | "the dogfood run (plan-it planning its own v2) shipped 26/26 contract-green with the lint catching a real spec defect; only gap: it planned a hook mechanism whose harness support was unverified, forcing a descope" |

---

## 2. What v2 demonstrably gets right (keep, do not touch)

Ranked by independent pairs citing it:

1. **Plan-phase Test Contracts / [REAL]-typed cases as binding DoD** — cited in 13/15 pairs (all except the anm no-build session and the roadmap analysis). **Founder's top-rated v2 feature**: *"This locks the DoD and gives a way more clear picture of what really matters"* (research-FOUNDER-INPUT.md). Strongest evidence: C — "`[REAL]`-typed contract cases are the single highest-value plan artifact: they caught 7 integration defects in it5 and 2 more in it7 that unit-green suites missed"; B — "Test Contract machinery is the crown jewel to keep: typed cases, [REAL] tags forcing early live smokes, evidence ledger with VERIFIED-only-with-evidence"; H — "'done' never accepted without them."
2. **Freeze mechanism / package consumed verbatim** — all 15 pairs; even the B/B- runs followed the frozen package. C: "Both executions followed their frozen packages near-verbatim (waves, branches, read-order, STATUS boards) — the freeze mechanism works." F: worst failures were "*faithful execution of plan errors*" — i.e., the freeze transmits perfectly; garbage-in is the residual risk.
3. **`gate-check.mjs` deterministic lint** — 5 pairs (airtable, e2e, fable, master-admin, smart-composer/dogfood). A: "demonstrably worked: caught wrong test-ID grammar, `[REAL]`-in-ID-cell miscounts, and wrong folder layout"; H/dogfood: "the lint catching a real spec defect" and "gate-check caught a genuine planning defect ('Count: 20' vs 21 rows)."
4. **File-based KICKOFF read-order handoff** — 5 pairs. G: "EXEC 1 rebuilt full state from files with zero user questions"; H: "exec never asked where anything was"; D (fable): "cleanest observed run — KICKOFF verbatim prompt + CONTRACT v1.1 + 26-case pre-registered contract → v2.0.0 … zero mid-run redirects."
5. **Evidence ledgers + honest status ladder + fresh-context verifiers** — 4 pairs (B, D, F, G). G: "Honest VERIFIED / IMPLEMENTED-NOT-VERIFIED / BLOCKED ladder propagated plan→exec and kept 'done' honest at hard human gates"; B: "25/26 VERIFIED, fresh-eyes verifier zero challenges." D explicitly asks to promote fresh-context verification to an invariant (EC-D9).
6. **Dated CONTRACT amendments + decisions.md ledger** — 3 pairs. E: "the frozen CONTRACT with dated amendments (v1.0→v1.3) and the shared `decisions.md` ledger are the most-cited artifacts across both exec sessions."
7. **Coordinator polices done-claims** — 3 pairs. C: "Done-claims were policed well (E4-1 reopened at 9/12; T-E2.1-08 held, not fake-greened) — keep coordinator-verifies-contract as law"; E: "tests are the verdict, not agent claims."
8. **Single batched decision gate** — 3 pairs' keep-lists (D, H, E: "human friction was low and mostly by design (G2 gate)").
9. **Plan-time model tiering when present** — 2 pairs. H: "Model tiering decided at plan time … transferred cleanly and worked"; B: "shipped per frozen CONTRACT with prescribed model tiering."
10. **Pre-grounding scope cuts & durable per-slice research files** — G: "Pre-grounding wins cited by execution: PSA zero-LLM scope cut, `otlp_auth` cred de-risk, W3 zero schema change" and "durable per-slice research files made the plan crash-safe through the mid-gate session death."
11. **Auto-sizing + closeout artifacts** — H keep-list: "_RESIDUE.md closeout notes, fail-open guard hooks, batched decision gates, auto-sizing that skipped squad ceremony for a 1,177-line repo."

---

## 3. Failure themes (all 69 ECs + FD-1/FD-2 clustered)

### T1 — Environment ground truth: plans verify code, not runtime *(includes FD-1, FOUNDER-MANDATED)*
- **Pairs hit:** 12 (airtable, anm, brain-docs, brand-bible, dark-channel, db-org, e2e, praxya, mcp-tparty, master-admin, observability, smart-composer + dogfood).
- **Severity — worst incident:** EC-A1 (airtable): "plan grounded 4 repos but mislabeled live infra (RabbitMQ 'dead code', Redis 'net-new'); user had to correct with the VPS address (USER [22]), forcing CONTRACT v1.2 + a 6-file doc sweep." Runner-up: EC-D3 "exit-125 port conflict from stale `qa-e6-mongo`/`qa-e6-redis` start commands"; EC-C7 "E2-1 spec'd a lint rule assuming ESLint infra that 'does not exist anywhere in brain-api-core'."
- **Merged v3 mechanism — "Runtime Reality Probe + persisted test conventions":** pre-grounding gains an *executable* discovery stream that (a) probes deployed infra (services, ports, connection strings, env endpoints) and emits a verified ENV-FACTS manifest; (b) inventories tools/skills/plugins on the *execution* machine, not just PATH heuristics; (c) spikes any harness mechanism the plan depends on before locking it in; (d) **FD-1**: before authoring Test Contract cases, read the target project's CLAUDE.md for e2e/unit-test conventions → if absent, subagent-research codebase+docs → if still unknown, ask the user whether a QA process exists → register the answer in that project's CLAUDE.md either way, so future runs skip re-discovery ("so our test suite can be as close as possible to the project we are working on").
- **Source ECs:** FD-1, EC-A1, EC-A5, EC-B1, EC-C2, EC-C7, EC-D3, EC-G4 (runnability), EC-H2, EC-H5, EC-E1 (probe half), EC-F2.

### T2 — Credentials & access never procured at plan time
- **Pairs hit:** 5 (brand-bible, mcp-tparty, master-admin, praxya, observability).
- **Severity:** F TL;DR: "Credentials were the #1 recurring blocker (devotts Vercel token, dashboard-only Supabase envs, VPS Mongo auth) — all knowable at plan time, none procured." EC-B6: "auth was un-mintable (unknown passwords, bootstrap-admin…)."
- **Merged v3 mechanism — "Credential procurement gate at G2":** every [REAL] case and deploy step declares the creds it consumes; the batched gate presents a procurement checklist; anything unprocured freezes as GATED-with-owner (never silently assumed). Generalizes B's ad-hoc `delivery/CREDENTIALS-NEEDED.md`.
- **Source ECs:** EC-F5, EC-B6, plus praxya credentials-file win (E) and G's "prod credential access" interventions.

### T3 — Cross-session handoff & resume fragility
- **Pairs hit:** 9 (anm, brain-docs, dark-channel, e2e, mcp-tparty, master-admin, observability, praxya, smart-composer).
- **Severity:** G verdict: "every cross-session handoff carried at least one broken path, stale claim, or unrunnable test precondition." Worst single: D — "`/read-chat \"e2e-unit-tests-plan\"` fuzzy-matched the wrong session (`db-organization-plan`)"; A — launch prompt "mojibake-corrupted and truncated (`Â§3`, 'current+to-ontinuing')" and the exec "built **nothing**"; G2 — "usage-limit + model switch mid-Gate-G3 produced an inferred approval from 'continue' and a task-list reset."
- **Merged v3 mechanism — "Self-contained handoff manifest + resume protocol":** one file-based, subscription-portable HANDOFF manifest (absolute linted paths — EC-G1; repo baseline snapshot: branch/SHA/dirty-state — EC-C5; no pasted blobs, launch prompt lives on disk — EC-A7); STATUS.md carries a RESUME block / "next actions" cursor updated at each transition (EC-F8, EC-D5); gates become resume-proof (explicit approval token, never inferred from "continue" — EC-G2); memory pointers are statechart-owned and updated on state.json transitions, not hand-written (EC-B3); session-close obligations (stop-hook files) are declared in the package (EC-E2); and plan-it tracks execution-liveness so a package that was never built gets flagged (EC-A9).
- **Source ECs:** EC-D1, EC-G1, EC-G2, EC-A7, EC-A9, EC-B3, EC-C5, EC-D5, EC-F8, EC-E2.

### T4 — Stale/unverified claims frozen into the package
- **Pairs hit:** 7 (dark-channel, db-org, e2e, mcp-tparty, master-admin, observability, brain-docs, smart-composer).
- **Severity:** EC-G3: "inherited kickoff asserted PR #282 = 'P1 only' (actually P1+P2+P3)" → "merging = surprise full prod deploy." EC-F6: "CONTRACT §2 misdefined `connectors_brain_api_url`" → shipped live. F TL;DR: "Flagged gaps died in research docs — mcp-tparty's user-blocking composer gap was literally written in stream-C's plan-time report."
- **Merged v3 mechanism — "Claims ledger with disposition-at-freeze":** every load-bearing claim in the package carries a source anchor (SHA-stamped file:line — EC-C3, auto re-ground task when stale); claims that gate work are double-sourced (EC-C6) or verified live during pre-grounding (EC-D2, EC-G3); config-key semantics must cite the consuming code (EC-F6); research-stream *flagged gaps* enter a gap ledger that must be dispositioned (fix/waive/case-ify) before freeze (EC-F1); volatile facts get an auto-generated "RE-VERIFY before writing" list (EC-B4); pre-existing defects are snapshotted so exec doesn't litigate ownership (EC-H3); derived artifacts (README/docs) get a drift check (EC-H8).
- **Source ECs:** EC-F1, EC-G3, EC-D2, EC-C3, EC-C6, EC-F6, EC-B4, EC-H3, EC-H8.

### T5 — The user's real DoD/quality bar never captured as cases *(includes FD-2, FOUNDER-MANDATED)*
- **Pairs hit:** 7 (dark-channel, anm, brand-bible, praxya ×2, mcp-tparty, smart-composer).
- **Severity:** EC-C1: "it5 was 62/62 green yet visually unacceptable (text-only content zone, leaked 'Brief —' headers), costing a full" re-plan+rebuild iteration. EC-E6: Radar's "silent `fixtures.ts` fake-data fallback (VID-R7)" only surfaced via a client feedback video. EC-A6: "G2 never asked 'is the deliverable the *script* or the *produced MP4*?'; user enhanced the DoD after freeze."
- **Merged v3 mechanism — "Pushed user review of Test Contract cases + richer case taxonomy":** **FD-2**: the proposed cases are surfaced explicitly (chat + file) and the user is actively pushed to review/edit them *before* freeze — "the user is the best one to give us what kind of test we cover that will really prove that everything was accomplished." The taxonomy the review presents gains: negative/trust-invariant cases (EC-E6), outcome-phrased E2E cases instead of widget mechanics (EC-B9), measured-NFR-baseline cases (EC-H1: "5s @ search" was never benchmarked), interaction-state semantics at the decision gate (EC-E8), [HUMAN]-typed perceptual cases with an async close protocol (EC-C1, EC-C4), user-facing wave exit proofs so "wave green" means the *user's* smoke test passes (EC-F3), and a deliverable-form question in the batched gate (EC-A6).
- **Source ECs:** FD-2, EC-C1, EC-C4, EC-A6, EC-B9, EC-E6, EC-E8, EC-F3, EC-H1.

### T6 — Contract & package mechanical hygiene (lint too late, tallies hand-edited)
- **Pairs hit:** 6 (airtable, anm, e2e, fable, dark-channel, smart-composer).
- **Severity:** EC-A2: "squads invented `T-<EID>-NN` IDs and put `[REAL]` inside the ID cell; conductor perl-rewrote 16 files." EC-D6: "package test-contract total hand-edited 20→24→26." EC-A8: the ANM non-code run "had no `gate-check.mjs`-equivalent; test-case counts were verified by ad-hoc grep."
- **Merged v3 mechanism — "Lint at write-time, everywhere":** squad prompts embed the exact ID grammar + table format and each squad runs `gate-check.mjs handoff` on its own files before reporting done (EC-A2, EC-H6); tallies are derived, never edited (EC-D6); the canonical folder tree is scaffolded at freeze and validated on first write (EC-A3); a format-agnostic lint profile covers non-code packages (EC-A8); contract lifecycle rules: contract must grow with scope (EC-H7), hotfixes must add regression cases (EC-E4), each case gets a planned persistence/graduation class — only "~13% of the 184 db-refactor cases persist as regression cover" (EC-C10).
- **Source ECs:** EC-A2, EC-A3, EC-A8, EC-D6, EC-H6, EC-H7, EC-E4, EC-C10.

### T7 — Plan scope ends at "local verify": deploy/rollout/ops missing
- **Pairs hit:** 5 (brand-bible, praxya, master-admin, mcp-tparty, e2e/fable via release-epic asks).
- **Severity:** B verdict: "prod deploy exposed a multi-tenant credential-architecture miss (env-var R2 creds vs shared Docker image → per-org Integrations rewire)." EC-F7: "`ALLOWED_ORIGINS` missed all" browser origins — "migrations owe behavior parity, not just URL replacement." EC-E1: "admin-ui build is manual (`workflow_dispatch`)", k8s-not-Vercel — discovered the hard way.
- **Merged v3 mechanism — "Deployment reality as a first-class design doc":** live-grounding captures deploy topology (EC-E1); rollout/tenancy design is a mandatory artifact when the program touches prod (EC-B5); endpoint migrations get a consumer-origin/CORS matrix (EC-F7); runbooks receive the same live cross-check as epics (F: "E4-runbook's phantom `dist/` rsync"); the scope gate offers a pre-sized optional "release & comms" epic (EC-D8); epics touching live fleets get a time-boxed ops-salvage budget (EC-E5).
- **Source ECs:** EC-B5, EC-E1, EC-F7, EC-D8, EC-E5.

### T8 — Run governance re-specified by hand every session
- **Pairs hit:** 6 (dark-channel, db-org, e2e, praxya, brain-docs, smart-composer).
- **Severity:** EC-E3: "12 idle 'zombie' builders held RAM; tiering only became decision D17 after Fernando asked." EC-B8: "mcp-tparty's squash-merge to origin/main silently staled the CB branches; only the user's manual warning" saved it. EC-B2: "push scope was never pinned; user said 'push the 3 local commits' but main held 7 entangled with another program's."
- **Merged v3 mechanism — "RUN-POLICY block frozen into the package":** KICKOFF/CONTRACT carries a machine-readable block with model-tier routing table per epic (EC-D4, EC-C9 — "Fernando re-types the same run-policy … every session"), autonomy/HITL consent, subagent lifecycle + reap rules (EC-E3), git push scope (EC-B2), parallel-program interlock + workspace-quiesce preflight (EC-B8, EC-C8), and a mid-flight demand-intake rule so W4–W6-style asks are absorbed via governed amendments, not retroactive decisions (EC-E9).
- **Source ECs:** EC-C9, EC-D4, EC-E3, EC-B2, EC-B8, EC-C8, EC-E9.

### T9 — Post-freeze change management is convention, not mechanism
- **Pairs hit:** 4 (airtable, brand-bible, fable, praxya).
- **Severity:** EC-B7: "the plan's own handoff lint flagged 'INV-2 … has no regression test' yet the package froze" anyway — and the gap shipped.
- **Merged v3 mechanism — "Freeze governance":** known-gaps block freeze until dispositioned (EC-B7); CONTRACT ships an AMENDMENTS section + rule ("build-time fact corrections go here, architecture changes need re-gate") with expected state recorded in `.plan-it/state.json` so `plan-it --audit` can diff plan vs as-built (EC-A4); statuses IMPLEMENTED-NOT-VERIFIED and BLOCKED become first-class machine states, not coordinator improvisation (EC-F4).
- **Source ECs:** EC-A4, EC-B7, EC-F4 (+ EC-H7/EC-E4 lifecycle rules from T6).

### T10 — Fan-out agent output reliability
- **Pairs hit:** 5 (airtable/anm, praxya, observability, smart-composer, master-admin).
- **Severity:** EC-H4: "research agents idled with no payload and had to be individually polled ('Please send me (main) your complete structured…')." EC-G5: "subagent slices passed 'done' but failed integration: lockfile-less `package.json` broke CI (#299)."
- **Merged v3 mechanism — "Agent I/O protocol":** mandate write-to-disk + content-bearing final message with coordinator verification (EC-H4; A's "idle ≠ delivered" file watchers, a cited win); machine-checked wave-kickoff fold instead of TaskOutput-by-name plumbing (EC-E10); per-workstream integration acceptance checks at slice boundaries (EC-G5); fresh-context verification promoted to invariant (EC-D9); plugin/packaging work always gets a loader test case — the unquoted-YAML `description:` bug "silently strips **all** skill metadata" (EC-D7).
- **Source ECs:** EC-H4, EC-E10, EC-G5, EC-D9, EC-D7.

---

## 4. Ranked v3 backlog

| Rank | Proposed feature | Source ECs | Pairs | Effort | Pipeline phase |
|------|-----------------|-----------|-------|--------|----------------|
| 1 | **FD-1 (FOUNDER-MANDATED):** Project test-convention discovery persisted in CLAUDE.md (read → research → ask → register) | FD-1, EC-D3, EC-C7, EC-G4, EC-H2, EC-B1 | 12 | M | pre-grounding / discovery fan-out |
| 2 | **FD-2 (FOUNDER-MANDATED):** Pushed user review/edit of proposed Test Contract cases before freeze (chat + file) | FD-2, EC-C1, EC-F3, EC-E6, EC-A6 | 7 | S | batched decision gate |
| 3 | Runtime Reality Probe → verified ENV-FACTS manifest (infra, ports, creds-existence, tool inventory, harness spikes) | EC-A1, EC-C2, EC-B1, EC-A5, EC-H5, EC-F2, EC-E1 | 12 | M | pre-grounding |
| 4 | Self-contained handoff manifest: linted absolute paths, file-based launch, repo baseline snapshot, subscription-portable | EC-D1, EC-G1, EC-A7, EC-C5 | 9 | M | handoff / package emit |
| 5 | Resume protocol: RESUME cursor in STATUS.md, resume-proof gates (explicit approval token), statechart-owned memory pointers, execution-liveness tracking | EC-F8, EC-G2, EC-D5, EC-B3, EC-A9, EC-E2 | 8 | M | handoff + statechart runtime |
| 6 | Claims ledger: SHA anchors, double-sourced gating claims, gap-ledger disposition at freeze, config-keys cite consuming code | EC-F1, EC-G3, EC-D2, EC-C3, EC-C6, EC-F6, EC-B4, EC-H3 | 7 | M | pre-grounding + backboneFreeze |
| 7 | Case taxonomy upgrade behind FD-2: trust/negative invariants, outcome-phrased E2E, measured-NFR baselines, [HUMAN] perceptual cases, wave exit proofs | EC-E6, EC-B9, EC-H1, EC-E8, EC-C4, EC-F3 | 7 | M | epic authoring (Test Contract) |
| 8 | RUN-POLICY block frozen into package (model tiers, autonomy/HITL, git scope, interlock/quiesce, reap rules, demand intake) | EC-C9, EC-D4, EC-E3, EC-B2, EC-B8, EC-C8, EC-E9 | 6 | S | backboneFreeze / KICKOFF |
| 9 | Write-time lint everywhere: squad self-lint with embedded grammar, derived tallies, scaffolded canonical layout, non-code lint profile | EC-A2, EC-A3, EC-A8, EC-D6, EC-H6 | 6 | S | parallelPlanning |
| 10 | Credential procurement gate at G2 (checklist; unprocured ⇒ GATED-with-owner) | EC-F5, EC-B6 | 5 | S | batched decision gate |
| 11 | Deployment/rollout design doc + CORS/origin matrix + live-checked runbooks + optional release&comms epic | EC-B5, EC-E1, EC-F7, EC-D8 | 5 | M | design docs / scope gate |
| 12 | Agent I/O protocol: write-to-disk mandate, machine-checked fold, per-slice integration acceptance, fresh-context verify invariant | EC-H4, EC-E10, EC-G5, EC-D9 | 5 | S | parallelPlanning + runtime |

**Long tail (one-liners):** freeze governance — known-gap blocker + AMENDMENTS section + `plan-it --audit` (EC-B7, EC-A4); IMPLEMENTED-NOT-VERIFIED/BLOCKED as machine states (EC-F4); contract-growth rule (EC-H7); hotfix-adds-regression-case rule (EC-E4); per-case persistence/CI-graduation class (EC-C10); loader test case for plugin/packaging work (EC-D7); ops-salvage time-box (EC-E5); derived-artifact drift check (EC-H8); auto re-ground task for stale anchors (EC-C3 runtime half); deliverable-form question in G2 (EC-A6, subsumed by FD-2).

---

## 5. New capabilities (v2 has no phase for these)

1. **Re-plan / verify-then-extend mode** (EC-E7; also EC-C, dark-channel it-7). Motivation: full-praxya-pt2-plan was graded **A** as "a model verify-then-extend re-plan that plan-it v3 should productize" — "structured finding schema, audits vs findings, centerpiece live verification, trust-fixes-first wave split, deterministic resumable plan-it state" (E TL;DR). Dark-channel needed an unproductized re-plan (CONTRACT v2.1) after 62/62-green-but-unacceptable output (C).
2. **Status-reconciliation pre-phase + analysis-only mode** (EC-H, roadmap session): "implementation docs lag reality (~85%-done items still 'planned'); v3 needs a status-reconciliation pre-phase and an analysis-only mode" (H TL;DR).
3. **Resume manifests & crash/limit recovery** (EC-F8, EC-D5, EC-G2): session-limit deaths, compactions, and model switches are normal events — v2 has no runtime phase that owns them ("loudr's limit-death left 'e1-builder finished but output NOT yet reviewed' recoverable only via hand-pasted log", F).
4. **RUN-POLICY governance block** (EC-C9, EC-D4, EC-E3): run behavior (tiering, autonomy, HITL, quiesce) is currently re-typed by the user every session — no phase emits it.
5. **`plan-it --audit` (plan-vs-as-built diff)** (EC-A4): post-execution reconciliation of CONTRACT amendments against `.plan-it/state.json`.
6. **Execution-liveness follow-through** (EC-A9): plan ends "ready for /fable-it" and goes blind; the ANM exec "built **nothing**" and nothing noticed.
7. **Session-close bookkeeping contract** (EC-E2, EC-H2): stop-hook obligations (`.taskstate/features-v3.json`, `progress-v3.md`) blocked execs; the package should declare them.
8. **Contract graduation to a QA/CI stack** (EC-C10): a post-build phase deciding which contract cases persist as regression cover (today "improvised post-hoc on user request").

---

## 6. TL;DR

- The core loop is validated: 8/15 pairs at A/A-, every execution followed its frozen package — "the freeze mechanism works" (C). Do not touch: freeze + gate-check, Test Contracts, evidence ledgers, KICKOFF read-order, batched gate, fresh-context verifiers.
- Plan-phase test-case creation is the founder's top-rated v2 feature ("locks the DoD") — v3 deepens it with two **mandated** directives: FD-1 (test-convention discovery persisted in CLAUDE.md) and FD-2 (pushed user review of cases before freeze).
- The #1 systemic failure (12 pairs): plans verify *code* but not *runtime* — infra facts, tools, test runners, and harness capabilities are assumed, then corrected mid-build by the user (EC-A1 worst case).
- The #2 failure (9 pairs): cross-session handoff/resume — corrupted pasted prompts, wrong-session fuzzy matches, stale pointers, non-resume-proof gates; G found a defect in *every* handoff.
- Green ≠ done when the user's quality bar isn't in the contract: dark-channel's 62/62-green-yet-unacceptable output cost a full rebuild iteration — FD-2 + negative/trust/NFR case taxonomy is the fix.
- Claims that gate work must be verified and flagged gaps dispositioned at freeze — mcp-tparty's user-blocking failure "was literally written in stream-C's plan-time report" (F).
- Credentials were the #1 recurring *blocker* class (F) — all knowable at plan time; add a procurement gate at G2.
- Plans must extend past local verify: deploy topology, tenancy, CORS/origin surfaces, and runbooks caused the worst prod surprises (B, F).
- Freeze the run governance the user currently re-types every session (tiers, autonomy, git scope, interlock) into the package itself.
- Two new modes are proven by field use and should be productized: re-plan/verify-then-extend (praxya pt2-plan, graded A) and status-reconciliation/analysis-only (H).

---
*Every grade, quote, and incident above traces to research-findings-[A–H].md or research-FOUNDER-INPUT.md; EC IDs are the analysts' own.*
