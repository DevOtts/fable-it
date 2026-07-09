# fable-it v3.0.0 — STATUS

Branch: release/v3.0.0-safe-parallel @ fa432c4. Vocabulary: NOT-STARTED · IN-PROGRESS · IMPLEMENTED-NOT-VERIFIED · VERIFIED.

| item | status | evidence |
|---|---|---|
| G-INTERLOCK gate | VERIFIED | fresh-context verifier CONFIRMED T30+T31 (delivery/v3/VERIFICATION.md) |
| G-WORKTREE gate | VERIFIED | verifier CONFIRMED T32+T33 (VERIFICATION.md) |
| G-INTEGRATE gate | VERIFIED | verifier CONFIRMED T34+T35 (VERIFICATION.md) |
| references/parallel-safety.md (RUNLOCK schema, worktree recipe, reclaim, integration) | VERIFIED | file present, 4.0K; referenced by all 3 gates + /launch + /iterate |
| /launch + /iterate fan-out reference the protocol | VERIFIED | grep confirms pointer added at both fan-out steps |
| version → 3.0.0 (plugin.json, marketplace ×2, root SKILL) | VERIFIED | t20-release lint: "plugin.json 3.0.0 / marketplace.json 3.0.0" |
| CHANGELOG [3.0.0] enumerates the 3 gates | VERIFIED | CHANGELOG.md top section, dated 2026-07-08 |
| v2 consistency lints (integration gate — no regression) | VERIFIED | tests/lints/run-all.sh: all 9 lint files PASS |
| 6 goldens T30–T35 pass their binding rules (fresh-context walk) | VERIFIED | 6/6 CONFIRMED 2026-07-08 (VERIFICATION.md) |

DoD = all 6 goldens CONFIRMED by the fresh-context verifier. **MET 2026-07-08.** v3.0.0 ready to merge→main + tag.
