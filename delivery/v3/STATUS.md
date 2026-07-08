# fable-it v3.0.0 — STATUS

Branch: release/v3.0.0-safe-parallel @ fa432c4. Vocabulary: NOT-STARTED · IN-PROGRESS · IMPLEMENTED-NOT-VERIFIED · VERIFIED.

| item | status | evidence |
|---|---|---|
| G-INTERLOCK gate (root + plugin conductor + parallel-safety.md) | IMPLEMENTED-NOT-VERIFIED | shipped in SKILL.md + plugin conductor; golden walk pending (T30/T31) |
| G-WORKTREE gate | IMPLEMENTED-NOT-VERIFIED | shipped; golden walk pending (T32/T33) |
| G-INTEGRATE gate | IMPLEMENTED-NOT-VERIFIED | shipped; golden walk pending (T34/T35) |
| references/parallel-safety.md (RUNLOCK schema, worktree recipe, reclaim, integration) | VERIFIED | file present, 4.0K; referenced by all 3 gates + /launch + /iterate |
| /launch + /iterate fan-out reference the protocol | VERIFIED | grep confirms pointer added at both fan-out steps |
| version → 3.0.0 (plugin.json, marketplace ×2, root SKILL) | VERIFIED | t20-release lint: "plugin.json 3.0.0 / marketplace.json 3.0.0" |
| CHANGELOG [3.0.0] enumerates the 3 gates | VERIFIED | CHANGELOG.md top section, dated 2026-07-08 |
| v2 consistency lints (integration gate — no regression) | VERIFIED | tests/lints/run-all.sh: all 9 lint files PASS |
| 6 goldens T30–T35 pass their binding rules (fresh-context walk) | IN-PROGRESS | fresh-context verifier dispatched (non-isolated, per T33); verdict pending |

DoD = all 6 goldens CONFIRMED by the fresh-context verifier. IMPLEMENTED-NOT-VERIFIED ships nothing.
