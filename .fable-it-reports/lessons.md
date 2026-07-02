# Cross-run lessons — fable-it on this repo (read at Step 0 of future runs)

## From the v2 build run (2026-07-02)
- Subagents cannot write report files — the harness refuses with "return findings as text". Any conductor run executed *as* a subagent must deliver its report in its final message; plan pass-conditions accordingly.
- Register tabletop goldens BEFORE implementing and judge with fresh-context agents: the T10 judge caught a residual interactive phrase in launch §4.3 the implementer missed, and the final-report verifier caught a VERIFIED row (DoD-6) with no ledger entry. The fresh-eyes layer pays for itself every run.
- Lint scripts must count rule *statements*, not mentions — pointers like "per the state location rule" are deferrals, not restatements (t11 initially over-counted).
- `[REAL]` model-specific cases can be run genuinely via Agent(model=sonnet|opus) with the skill text + fixtures in a scratch dir; disclose the subagent-session scope in the report.
- gh pr merge + immediate `git pull` can race; verify merge state with `gh pr view <n> --json state` before trusting the local log.
- Scratchpad `find` output aggregates and hides dotfiles — verify hidden dirs with `ls -la`.
- Keep every VERIFIED-adjacent sentence in skill files within 2 lines of an evidence/ledger mention — the T2 co-occurrence lint enforces it and it reads better anyway.
