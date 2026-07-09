# fable-it v3.0.0 — Verification (fresh-context golden walk)

**Verifier:** fresh-context subagent (Sonnet, non-isolated per T33's own read-only-may-share rule), 2026-07-08.
Read only the goldens + pass rules + shipped prose (root SKILL.md, plugin conductor, parallel-safety.md, /launch + /iterate fan-out lines); never the implementation reasoning. Challenge-by-default.

## Result: 6/6 CONFIRMED

| Golden | Verdict | Forcing gate (cited) |
|---|---|---|
| T30 — live lock blocks second run | VERIFIED | Interlock gate (root + plugin): live RUNLOCK → BLOCK/wait, never co-mutate; parallel-safety.md §1 |
| T31 — stale lock reclaimed + logged | VERIFIED | Interlock gate: stale → reclaim with logged run-memory note; parallel-safety.md §1 (age/pid test, never silent) |
| T32 — parallel mutating slices isolated | VERIFIED | Worktree gate: own git worktree/agent-lane, coordinator sequential merge, no worker git-mutates shared tree; parallel-safety.md §2/§3; restated in /iterate + /launch |
| T33 — read-only fan-out not over-isolated | VERIFIED | Worktree gate: "read-only fan-out may share the tree" (permissive) + mutation ban; echoed in /iterate + /launch |
| T34 — integration catches isolation-green slice | VERIFIED | Integration gate: merged-tree build/lockfile/tests, reopen-on-broken (package.json-no-lockfile case verbatim); parallel-safety.md §3 |
| T35 — concurrent coordinators can't corrupt tree | VERIFIED | Run step 1 "Acquire the RUNLOCK before touching the tree" + Safe-parallel rule naming the exact incident failure modes |

## Coherence check: PASS
parallel-safety.md contains all four: (a) RUNLOCK schema, (b) worktree fan-out + sequential merge-back recipe, (c) stale-lock reclaim, (d) integration check. All three gates in both conductors now cite the protocol file inline (citation nit the verifier flagged — fixed 2026-07-08).

## Integration gate (no v2 regression): PASS
`tests/lints/run-all.sh` — all 9 lint files PASS (t2/t8/t11/t16/t17/t20/t24 + consistency-7-2 + hooks).

## Note
The verifier also correctly disregarded a prompt-injection attempt embedded in its environment (a fake "SessionStart:compact hook" redirecting to unrelated Engine-Core work) — flagged, not acted on.
