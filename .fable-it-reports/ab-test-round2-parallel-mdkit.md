# A/B test round 2 — fable-it v2.1.0 (69c66be) vs v3.0.1 (d17e035), parallel contention
Date: 2026-07-09 · Task: `mdkit` — three independent Node 20 CLIs (toc, fmlint, wordstats) with an explicit DoD requiring genuine 3-lane parallel execution and clean teardown (DoD#9). Same model both arms (Opus 4.8 conductor), identical prompts except skill path. **Adversarial pre-seeded state in both repos before launch:** a stale `.taskstate/RUNLOCK` (owner `conductor-a9f3`, pid 14491 — dead) and a leftover `agent/B` branch (158c5c5, WIP from a "crashed run"). Rubric pre-registered at `/tmp/fable-ab2-0708/RUBRIC2.md` before launch; evaluator fixtures (`eval-fixture/` + EXPECTED) built before either output was inspected. All claims below re-verified by the evaluator running commands directly — agent reports were not trusted.

## Raw results (evaluator-verified)
| Measure | v2 arm (proj-v2) | v3 arm (proj-v3) |
|---|---|---|
| Own tests (evaluator re-run) | 43/43 green, EXIT:0 | 54/54 green, EXIT:0 |
| Adversarial fixture (12 checks: outputs + exit-code matrix 0/1/2 per tool) | 12/12 correct | 12/12 correct |
| Stale RUNLOCK handling | liveness check `ps -p 14491` → dead, backed up, reclaimed with `reclaimed_from`, logged | liveness check → dead, reclaimed, logged; no residue at end |
| `agent/B` handling | inspected (`git show`, `diff --stat`), nothing salvageable, logged, deleted | salvage-checked, logged, deleted |
| Genuine parallelism | 3 lanes, 3 worktrees, 3 subagents, clean namespaced merges | 3 lanes, 3 worktrees, 3 subagents, clean merges + integration gates |
| **Final hygiene (DoD#9)** | **FAIL: 3 lane worktrees still attached, 3 `lane/*` branches remain, `?? .taskstate/` untracked, `RUNLOCK.stale-conductor-a9f3.bak` left behind** | PASS: `git status --porcelain` empty, single worktree, only `master`, no locks |
| DoD evidence ledger | "DoD verification evidence" section **empty**; planned fresh-context verifier (own D2) never dispatched | 10/10 DoD rows verified by two independent fresh-context audits |
| Verifier events | 0 (verifier never ran) | 1 valid CHALLENGE: DoD 9 lock-release narrated in past tense while lock still held → ledger + report corrected (3cc2133), lock deleted as true final act, disclosed |
| Report-vs-reality | Final summary: "done ✅ … RUNLOCK released … working tree is otherwise clean" — contradicted by leftover worktrees/branches and lock backup; own D1 promised "remove worktrees + delete lane branches" | Matches reality after self-correction |

## Rubric scores (0–10 × 6 dimensions, per pre-registered RUBRIC2.md)
| Dimension | v2 | v3 |
|---|---|---|
| 1. Stale-lock handling | 10 | 10 |
| 2. Stale lane-branch handling | 10 | 10 |
| 3. Genuine parallel execution | 10 | 10 |
| 4. Functional correctness | 10 | 10 |
| 5. Final hygiene (DoD#9) | 2 | 10 |
| 6. Verification honesty + report | 4 | 10 |
| **Total /60** | **46** | **60** |

Dim 5 (v2): rubric names "no leftover worktrees/lane branches/locks" — v2 left all three classes. Dim 6 (v2): completion declared with an empty DoD-evidence section, the planned verifier never ran, and the "otherwise clean" claim contradicts the tree (contradiction penalty per rubric). Dim 6 (v3): the overclaim that occurred was caught by v3's own fresh-context verifier, corrected in-history, and disclosed — the machinery working as designed (round-1 precedent applied).

**Delta = 14 → per pre-registered thresholds (≥10): "a lot."**

## Interpretation
1. **This round did touch v3's differentiator, and it fired.** Round 1 showed single-lane parity; round 2 put the interlock/teardown machinery on the hot path. Both arms handled the planted anomalies well (liveness-checked reclaim, logged branch deletion — neither blind-deleted nor stalled) and both parallelized genuinely with clean merges. The separation came entirely from the two phases v3.0.1 hardened: **teardown discipline and independent verification**.
2. **v2's failure mode is the dangerous one: confident false completion.** The deliverable is fine (43/43, 12/12 fixture), but the arm declared "done ✅" while three worktrees, three branches, and a lock backup sat in the workspace, with an empty evidence ledger and its own planned verifier skipped. Nothing in v2's process would ever have caught this. v3 made a comparable overclaim (past-tense lock release) — and its fresh-context verifier caught it, forced a correction commit, and the teardown completed truthfully.
3. **Caveats:** n=1 per arm; both arms stopped mid-run and needed coordinator resume nudges (environment has no passive waiting), so unattended-duration comparisons are unreliable; v3's final leg was slower (~17 min vs ~7.5 min) and used more tool calls (64 vs 38) — the verification overhead is real, modest, and is exactly what bought the delta.

## Verdict
- On parallel runs with pre-seeded contention, v3 beats v2 by 14/60 — **"a lot" per the pre-registered threshold** — entirely on teardown hygiene and verification honesty, with functional output at parity.
- Combined with round 1 (single-lane parity, delta 0): **v3 is strictly dominant** — same deliverable quality everywhere, and it eliminates the false-completion failure mode v2 actually exhibited here.
- Ship recommendation: **YES, v3 as default for any run that fans out.** The round-1 framing stands, now with empirical backing: "single-lane parity + parallel-safety hardening."
