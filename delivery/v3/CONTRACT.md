# fable-it v3 — CONTRACT (Safe Parallel Execution)

Version: **v1.1 — amended 2026-07-08** (v1.0 FROZEN 2026-07-08; amendments in Changelog)
Spec: `docs/04-v3-safe-parallel-spec.md` · Epics/tests: `delivery/v3/epics-fable-it-v3.md` · Goldens: `delivery/v3/goldens/`

## 1. Vocabulary (canonical)

- **RUNLOCK** — `.taskstate/RUNLOCK`, JSON `{owner, host, pid, startedAt, heartbeat}`; one live holder per working tree.
- **Mutating agent** — a delegated worker that Writes/Edits/creates files in the repo. **Read-only agent** — reads/searches only.
- **Worktree lane** — a `git worktree` + `agent/<lane>` branch off the run base, owned by exactly one mutating agent.
- **Live lock** — heartbeat < 10 min AND owner reachable; else **stale** (reclaimable, with a logged note).
- **Integration gate** — the merged-tree acceptance check (build + lockfile + declared test/lint shape), distinct from the existence check.

## 2. Interface (the three gates — additive to v2's catalog)

- **G-INTERLOCK**: acquire RUNLOCK at run start + before mutating fan-out; a live lock held by another owner → BLOCK/wait, never co-mutate; stale → reclaim + log; release on stop.
- **G-WORKTREE**: parallel mutating agents each get their own worktree lane; coordinator merges back sequentially; read-only fan-out may share; no subagent runs `git merge`/`checkout`/`reset` in a shared tree.
- **G-INTEGRATE**: after merge-back, accept a slice only if the merged tree passes integration — not on "output exists" alone; integration-broken slice is reopened.

## 3. Definition of SHIPPED

- All 6 goldens (T30–T35) PASS when a fresh-context verifier walks each against the shipped root `SKILL.md` + `plugins/fable-it/skills/fable-it/SKILL.md` + `plugins/fable-it/skills/references/parallel-safety.md`.
- Root `SKILL.md` and the plugin conductor carry the three gates substantively (degraded mode is operational, not aspirational — checkable by gate-name diff).
- `/launch` + `/iterate` reference `parallel-safety.md` at their fan-out steps.
- Version bumped to **3.0.0** across `plugins/fable-it/.claude-plugin/plugin.json`, root `SKILL.md` frontmatter, plugin `SKILL.md` frontmatter, and marketplace (parity); CHANGELOG has a dated `## [3.0.0]` section enumerating G-INTERLOCK/G-WORKTREE/G-INTEGRATE.
- Existing v2 goldens (T1–T23) and lints remain green (no regression).

## 4. Status vocabulary (binding, W4-style)

NOT-STARTED · IN-PROGRESS · IMPLEMENTED-NOT-VERIFIED · VERIFIED (a golden is VERIFIED only after a fresh-context walk confirms its pass rule).

## 5. RUN-POLICY

- Coordinator = session model (Opus 4.8 now); tiers resolve at execution time — no hardcoded model ids in artifacts.
- **This build dogfoods the feature**: disjoint implementation lanes run as subagents in isolated `git worktree`s; the coordinator merges back sequentially and runs the integration gate (v2 goldens + lints) after each merge. Subagents never run git in a shared tree.
- Repo boundary: fable-it repo only.

## Changelog

- v1.0 — 2026-07-08 — frozen. Scope: G-INTERLOCK + G-WORKTREE + G-INTEGRATE. Amendments land here (v1.0 → v1.1 …).
- v1.1 — 2026-07-08 — amendment (ships as **3.0.1**), from the post-release Fable 5 review. G-INTERLOCK mechanics tightened, gates unchanged: (a) RUNLOCK acquisition is **atomic** (exclusive-create; the read-then-check-then-write TOCTOU race is forbidden); (b) heartbeat refresh is **time-based (2–3 min)**, not phase-boundary-only, so a long phase can't make a live run look stale; (c) reclaim requires the owner **not provably alive** (same-host pid check overrides an aged heartbeat); (d) G-WORKTREE: leftover `agent/<lane>` branches from a crashed run are cleaned up with a logged note before dispatch; (e) scope note: the lock is per working tree — separate clones coordinate at the remote, not via RUNLOCK.
