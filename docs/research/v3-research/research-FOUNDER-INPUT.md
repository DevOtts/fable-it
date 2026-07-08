# Founder input (Fernando) — mandated v3 directions

Context: given after reviewing the week of v2 usage. Test-case creation during the plan
phase is rated one of the best things in the current version — "This locks the DoD and
gives a way more clear picture of what really matters." Keep it and deepen it with the
two additions below. These are DIRECTIVES, not candidates: they must appear in the v3
backlog (merged with the related analyst ECs, ranked at the top of the Test Contract theme).

## FD-1: Project test-convention discovery, persisted in CLAUDE.md
Before authoring Test Contract cases:
1. Read the target project's CLAUDE.md for instructions on how the project handles its
   e2e tests, unit tests, and test-cases.
2. If CLAUDE.md says nothing about testing → plan-it has never mapped this project:
   fan out a subagent to research the codebase + project documentation to identify the
   testing setup (frameworks, runners, conventions, QA process).
3. If the subagent cannot identify it → ask the user whether the project has a QA
   process in place.
4. Whatever the answer (yes OR no), REGISTER the knowledge in that project's CLAUDE.md
   so the next plan-it run knows what to do without re-discovery.

Rationale: "This is vital so our test suite can be as close as possible to the project
we are working on."

Related analyst evidence to merge with: EC-D3 (env smoke-probe before contract
authoring), EC-C7 (infra-prerequisite existence check — ESLint assumed but absent),
EC-G4 (runnability column — no pytest in exec env), EC-H2 (workspace-obligation
manifest discovered via CLAUDE.md/hooks), EC-B* execution-environment preflight.

## FD-2: Explicit user review of Test Contract cases at the gate
Today the user only receives the KICKOFF and the test-cases are never explicitly
surfaced for review (neither in the file flow nor in chat). Change: make the proposed
Test Contract cases an explicit, pushed review step — show the cases and actively push
the user to review/edit them before freeze.

Rationale: "the user is the best one to give us what kind of test we cover that will
really prove that everything was accomplished. From his inputs, we will get a much more
clear picture of what is the real goal and DoD that he is looking for."

Related analyst evidence to merge with: EC-C1 (dark-channel: 62/62 green yet visually
unacceptable — user's quality bar never captured as cases), EC-F3 (user-facing wave
exit proofs), EC-E6 (trust invariants only surfaced via client feedback video),
EC-A* (DoD churned twice post-freeze on user corrections).
