# fable-it v3 — enhancement spec: Safe Parallel Execution

**2026-07-08 · builds on the v3-research dogfood findings (EC-B8 parallel-program
interlock, EC-C8 workspace-quiesce, EC-G5 per-slice integration) and a firsthand
incident: during this program a second session co-mutating one repo's `.git`
corrupted the tree (detached HEADs, reverted files, a mid-work merge conflict).**

## 0. Locked decisions (Gate, 2026-07-08, owner: Fernando)

| # | Decision | Locked answer |
|---|---|---|
| D1 | v3 scope | **Safe parallel execution only** — the three gates below. Packaging/loader self-test (EC-D7) deferred. |
| D2 | Build method | **Subagents in isolated worktrees** — dogfood the feature: the v3 build itself runs disjoint lanes in `git worktree`-isolated agents, merged back sequentially. |
| D3 | Repo boundary | This session operates **only** in the fable-it repo. Sibling repos may have live owners. |

## 1. Vision

fable-it v2 made a *single* autonomous run honest and checkable. But a v2 run that
fans out parallel mutating agents — or that shares a repo with another session —
has **no gate protecting the working tree itself**. The delegation gate checks that
a worker's *output exists*; it does not check that two workers aren't writing the
same `.git`, nor that a merged slice actually *integrates*.

The research proved this abstractly (EC-B8/C8/G5); this program proved it concretely
— two coordinators on one `plan-it/.git` produced repeated corruption that cost hours.

One sentence: **v3 makes parallel and multi-session execution safe by construction —
one writer per working tree, isolation for mutating fan-out, and integration (not just
existence) as the acceptance bar.**

Governing principle (extends v2's three): **the working tree is shared state; treat
concurrent writes to it exactly like concurrent writes to a database — serialize or
isolate, never hope.**

## 2. The three gates (added to the conductor's gates catalog)

### G-INTERLOCK — quiesce preflight (EC-B8/C8)
- **Trigger:** run start, and before spawning any parallel *mutating* agent.
- **Test:** is another live run/agent/session already operating on this working tree?
  Evidence: a `.taskstate/RUNLOCK` held by a live owner (pid + heartbeat < 10 min old),
  another agent's in-flight git operation, or a dirty index mid-merge (`.git/MERGE_HEAD`).
- **Action:** acquire a `RUNLOCK` (owner id, host, started-at, heartbeat) at run start;
  if one is already held live → do **not** co-mutate — report BLOCKED ("another run
  owns this tree: <owner>") or wait for release. Release on completion and on the
  stop-hook. A stale lock (dead owner / heartbeat expired) may be reclaimed with a
  logged note.

### G-WORKTREE — isolation for parallel mutating agents (EC-B8)
- **Trigger:** before fanning out parallel agents that **write/edit** files.
- **Test:** does every mutating agent have its **own** working tree, or are ≥2 sharing one?
- **Action:** each parallel mutating agent runs in its **own `git worktree`** on its own
  `agent/<lane>` branch off the run base; the **coordinator alone** merges branches back,
  **sequentially**, running G-INTEGRATE after each. Read-only fan-out (research, search,
  audits) may share the tree. **No subagent runs `git merge`/`checkout`/`reset` in a
  shared tree** — that is the coordinator's job, one lane at a time. Worktrees auto-clean
  when unchanged.

### G-INTEGRATE — per-slice integration acceptance (EC-G5)
- **Trigger:** after a slice/worktree merges back, before the wave is accepted.
- **Test:** does the **merged** tree pass an integration check — builds, lockfile present
  and consistent, the project's declared test/lint shape green — not merely "the agent's
  output file exists"?
- **Action:** run the integration check on the merged result; a slice that is green in
  isolation but breaks integration (the canonical case: a `package.json` added with no
  lockfile → CI break) is **reopened, not accepted**. This promotes the delegation gate
  from *exists* to *integrates*.

## 3. Changes per component

- **Conductor `SKILL.md` (root, host-agnostic) + `plugins/fable-it/skills/fable-it/SKILL.md`
  (mirror):** add the three gates to the gates catalog; add an "acquire RUNLOCK / release
  on stop" line to the run steps; extend the delegation gate to reference G-INTEGRATE.
- **New reference `plugins/fable-it/skills/references/parallel-safety.md`:** the operational
  protocol — RUNLOCK file schema, the worktree fan-out/merge-back recipe (create worktree →
  agent works in it → coordinator merges sequentially → G-INTEGRATE), the read-only-may-share
  rule, and the stale-lock reclaim rule. Skills point at this file; no divergent copies.
- **`/launch` + `/iterate` (where fan-out happens):** the parallel-dispatch step references
  parallel-safety.md; mutating fan-out uses worktrees; the merge-back + integration check is
  the coordinator's, not the workers'.
- **Optional hardened hook (Claude Code only, fail-open):** a `SessionStart`/preflight hook
  that writes+checks the RUNLOCK, and a stop-hook that releases it — mirrors v2's fail-open,
  one-line-disable hook style. Prose gate is the baseline on all hosts.

## 4. Success measures (binding — the goldens in `delivery/v3/goldens/`)

The Test Contract is tabletop goldens (v2's mechanism): scenario → expected transcript →
binding pass rule. DoD = every golden's pass rule holds when walked against the shipped
skill prose by a fresh-context verifier. See `delivery/v3/epics-fable-it-v3.md`.

## 5. Out of scope (explicit)

- Packaging/loader self-test (EC-D7) — deferred to a later version.
- Distributed locking across machines — the RUNLOCK is single-host (the fable-it use case).
- Automatic conflict *resolution* on merge-back — the coordinator resolves; the gate only
  guarantees isolation + sequential merge + integration, not auto-merge.
