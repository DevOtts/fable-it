# Gap analysis — fable-it v1 vs the Fable 5 advantage catalog

**fable-it v2 research doc · 2026-07-02**

Crosses the advantage catalog (`01-fable5-vs-opus.md` §2, IDs F1–F16) against the
full plugin audit (`_streams/B-plugin-audit.md`, IDs C/L/I/Q/X). Verdicts:
**ENCODED** (v1 already has it) · **PARTIAL** (posture present, enforcement or
coverage missing) · **MISSING** · **N/A** (weights-only — nothing to encode except
honesty about it).

## 1. Advantage-by-advantage verdict

| Fable advantage | v1 status | Evidence in v1 | The gap |
|---|---|---|---|
| F2 Claim-grounded honest reporting | **PARTIAL** | Guardrail 3 (`fable-it/SKILL.md:132-141`), verifiability precheck (`:147`), iterate's "'It should work' is not evidence" (`iterate/SKILL.md:60-77`) | The *posture* matches Anthropic's measured mitigation almost exactly — but there is **no mechanical check**: no per-criterion evidence ledger on disk, no rule that a VERIFIED claim must cite a tool result *from this session*, no verifier that audits the report. Pure self-policing (audit §10.1) |
| F3 Autonomous posture + last-paragraph check | **PARTIAL** | C9–C11 (`fable-it/SKILL.md:71-77`) — near-verbatim match to the guide's snippet | Self-policed only (audit §10.7). Worse: **`/launch` contradicts it** — two interactive approval gates (`launch/SKILL.md:94`, `:672-681`) that would stall an unattended run (audit §8.6) |
| F4 Two-sided honesty | **PARTIAL** | "Don't fake confidence" (`fable-it/SKILL.md:77`) covers the no-fake-green half | The "state it plainly when verified" half is absent — v1 reports can over-hedge; look-before-delete and approval-doesn't-carry rules exist only in cdp-control's write gate, not generally |
| F5 Scope discipline | **ENCODED** | "Do not gold-plate" (`fable-it/SKILL.md:79`), iterate's minimal-fix rule (`iterate/SKILL.md:50-56`), cdp-control's when-NOT-to-use | Adequate. Minor: no explicit no-unrequested-refactor line in launch's build prompts |
| F6 Fresh-context verifier subagents | **MISSING** (near-miss) | `/launch`'s external eval runner (`launch/SKILL.md:435-473`) is exactly this pattern — "Do NOT read any source code" | The conductor **never wires it in** as the honesty gate (audit §10.1). Nothing verifies the final report; self-critique is the only check. This is v2's highest-leverage addition — Anthropic says fresh-context verifiers beat self-critique, and v1 already owns the pattern unused |
| F7 Memory system | **MISSING** | Only `.taskstate/` progress files (crash recovery, not memory) | No lessons file, no per-run memory of failed approaches/decisions rationale/env quirks; the 3x-payoff scaffold (strongest quantified result in the record) has no counterpart |
| F8 No-panic context management | **PARTIAL** | Re-ground each phase (C17), iterate's summarize-after-3-cycles (`iterate/SKILL.md:126-132`), SessionStart compact hook (`launch/SKILL.md:509`) | Grounding statement is **unpersisted** (audit §10.2) — evaporates at compaction; C17 has no trigger (§10.4); no anti-context-anxiety text ("you don't need to wrap up early"); anti-thrash rules (don't re-derive/re-litigate) absent |
| F9 Subagent orchestration discipline | **PARTIAL** | Routing table (C27), subagent strategy + prompt checklist (I8–I9), coherence rule on parallelization (C20) | No "verify delegated output on disk — idle ≠ delivered" rule; no relay-conclusions discipline; no async/long-lived-subagent guidance |
| F10 Multi-agent quality patterns | **MISSING** | Competing-investigators bug pattern (`launch/SKILL.md:723-743`) is the lone example | No adversarial verify, no loop-until-dry, no completeness critic, no **no-silent-caps** disclosure rule anywhere |
| F11 Communication contract | **PARTIAL** | Report templates fix *structure* (C30, I12, Q18) | Register rules missing (lead-with-outcome, readable-over-concise, no invented codenames). Also **three competing report formats** with no reconciliation (audit §8.4) |
| F12 Evidence-before-state-change | **PARTIAL** | Irreversible-action bars exist (C11, Q19, X7) | Those are *category* bans (never drop tables). The Fable gate is different: for *permitted* state changes, check the evidence supports that specific action — absent everywhere |
| F13 Economic pacing / budgets | **MISSING** | Cost bands at approach-selection time only (`launch/SKILL.md:98-121`) | No run-time budget awareness, no cadence heuristics for watch loops, no cost disclosure in the report (relevant: Fable-class pricing makes overnight runs expensive) |
| F1/F8 retention (weights half) | **N/A** | README's honest table | Correct to not encode; v2 compensates via F7 + F8 scaffolds |
| F15/F16 ceiling & first-shot | **N/A** | README's honest table | Correct; keep the honest claim, now with citations |

## 2. Structural defects in v1 (independent of the catalog)

From the audit (§8, §10) — these must be fixed for the F-gaps to matter:

| # | Defect | Cite | Why it blocks v2 |
|---|---|---|---|
| D1 | **Zero model-adaptive logic** — model appears only as a team-role label | `launch/SKILL.md:308,633` | The v2 goal is Sonnet 5 + Opus 4.8 tuning; there is no place to hang per-model behavior today |
| D2 | `/launch` interactive gates vs conductor's unattended posture | `launch/SKILL.md:94,672-681` vs `fable-it/SKILL.md:65,71` | An overnight run stalls at delegation. Needs a non-interactive mode the conductor invokes |
| D3 | CDP logic triplicated and already drifted | `chrome-cdp-control:110-254`, `full-qa:119-178,361-391`; drift confirmed `parallel-lifecycle-KICKOFF.md:275` | Violates the conductor's own anti-duplication rule (C3); every future CDP fix lands 3x or drifts |
| D4 | Hardcoded `localhost:9222` / port 3000 | `full-qa:51,127,367`, `cdp-control:24,88,231` | Blocks parallel runs (KICKOFF's confirmed collision point); nothing reads a contract/env |
| D5 | Manual-loop vs autonomous-QA boundary is subtle, unguarded | `cdp-control:16,168` vs `full-qa:294-312` | An authenticated real-Chrome task routed to `/full-qa` loses the per-write gate — a real safety hole |
| D6 | Three final-report formats, no reconciliation | `fable-it:170-195`, `iterate:144-164`, `full-qa:256-290` | A delegated run can surface two verdicts; the honest report needs one source of truth |
| D7 | Unsourced premise — field guide cites zero papers; ports/stays table is asserted, never evidenced | PDF pp.1–8; `README.md:241` ("tabletop-tested") | Fixed by this research: docs 01/02 ARE the citations. README/guide should link them |
| D8 | Degraded (root SKILL.md) mode carries descriptions, not mechanics | `SKILL.md:22-29` (audit §6) | Non-Claude-Code hosts get aspirational prose; v2's gates must be host-agnostic text, not Claude-Code-only hooks |
| D9 | `.taskstate/` vs `.claude/` mixed guidance inside launch | `launch/SKILL.md:69` vs `:437,461,477` | Inconsistent state location undermines the externalize-state principle |

## 3. Priority ranking (impact x evidence x effort)

**Tier 1 — the run-quality core (do first):**
1. **Evidence ledger + claim-grounding gate** (F2, F4, D6): per-criterion
   `.taskstate/evidence.md`; VERIFIED requires a cited tool result from this session;
   one unified report format that consumes the ledger. *Anthropic-measured effect.*
2. **Fresh-context verifier** (F6): a verifier subagent (or degraded-mode
   self-verification protocol with a fresh-eyes checklist) audits the report against
   the ledger before it ships. v1's dormant eval-runner pattern, finally wired in.
3. **Persist the grounding + decisions + lessons** (F7, F8, D9): grounding statement
   to disk; run-memory file (failed approaches, env quirks, decision rationale);
   mandatory re-read at phase boundaries; anti-context-anxiety text.
4. **Non-interactive `/launch` mode** (D2) — unblocks the whole unattended premise.

**Tier 2 — the model-adaptive layer (the v2 headline):**
5. **Model detection + per-model posture** (D1): detect/declare the running model;
   Sonnet 5 gets tighter gates and more frequent re-grounding; Opus 4.8 gets the
   over-engineering suppressors (F5 snippets); both get the same contract format.
6. **Orchestration discipline pack** (F9, F10): idle ≠ delivered verification,
   relay-conclusions, adversarial verify for bug claims, loop-until-dry for QA
   sweeps, no-silent-caps in every report.

**Tier 3 — hygiene and hardening:**
7. Deduplicate CDP (D3) + parameterize ports (D4) + hard route-guard for
   authenticated Chrome (D5).
8. Communication register rules in the unified report (F11); evidence-before-
   state-change gate text (F12); pacing/cost heuristics + cost line in report (F13).
9. Source the claims (D7): SOURCES section linking docs 01/02; correct the README's
   honest-claim table per 01 §5; refresh the field guide when convenient.
