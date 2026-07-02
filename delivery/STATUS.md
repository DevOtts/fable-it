# fable-it v2 — live board

Updated: 2026-07-02 (build complete — all epics merged to main, v2.0.0)

| Epic | Branch | Wave | Status | Test contract | PR |
|---|---|---|---|---|---|
| E1 Conductor v2 | `epic/E1-conductor-gates` | 0 | **verified** | 7/7 (T1,T2,T3,T4[REAL],T5,T6,T23) | #5 |
| E5 CDP dedup + guards | `epic/E5-cdp-core` | 0 | **verified** | 3/3 (T17,T18,T19) | #6 |
| E2 Verifier | `epic/E2-verifier` | 1 | **verified** | 3/3 (T7,T8,T9[REAL]) | #7 |
| E3 Launch unattended | `epic/E3-launch-unattended` | 1 | **verified** | 4/4 (T10,T11,T12,T24) | #8 |
| E4 Loops upgrades | `epic/E4-loops` | 1 | **verified** | 4/4 (T13,T14,T15,T16) | #9 |
| E7 Hardened hooks | `epic/E7-hooks` | 1 | **verified** | 2/2 suites (T21,T22 — all cases green) | #10 |
| E6 Portable + release | `epic/E6-portable-release` | 2 | **verified** | 3/3 (T20a,T20b,T20c) | #11 |

**26/26 test-contract cases pass.** Evidence per case: run ledger (`.taskstate/evidence.md`
during the build) quoted in the final report at `.fable-it-reports/report.md`.

Notes:
- Tabletop goldens registered in `delivery/goldens/` BEFORE each epic's implementation;
  judged by fresh-context agents (challenge-by-default), never the implementer.
- `[REAL]` cases ran live: T4 on a Sonnet 5 session (conductor executed a 3-criterion
  DoD end-to-end; all 4 `.taskstate/` files on disk, model+posture declared at Step 0);
  T9 on an Opus 4.8 session (verifier confirmed the genuine row, challenged the
  fabricated one, no false positive).
- Lints scripted at `tests/lints/` (`run-all.sh` = full suite incl. CONTRACT §7.2
  consistency lint); E7 unit tests at `plugins/fable-it/hooks/tests/run-tests.sh`.

Rules (kept for the record): wave N starts only when wave N−1 epics touching shared
files are merged (E1→E2 same file; E5→E4 both touch full-qa). Status values:
backlog · in-progress · implemented · verified (=contract 100%) · blocked.
