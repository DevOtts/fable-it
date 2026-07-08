# fable-it v3 — epics: Safe Parallel Execution

Law: `delivery/v3/CONTRACT.md` (frozen). Spec: `docs/04-v3-safe-parallel-spec.md`.
Test mechanism: **tabletop-golden** — a written scenario transcript walked against
the shipped skill prose by a fresh-context verifier; PASS iff the binding pass rule
holds. Goldens live in `delivery/v3/goldens/`.

Status vocabulary: NOT-STARTED · IN-PROGRESS · IMPLEMENTED-NOT-VERIFIED · VERIFIED.

---

## Epic V3-E1 — G-INTERLOCK (quiesce preflight)

Scope: conductor gates catalog + run-step (acquire/release RUNLOCK) + parallel-safety.md
(RUNLOCK schema + stale-lock reclaim) + optional hardened preflight/stop hook.
Files: root `SKILL.md`, `plugins/fable-it/skills/fable-it/SKILL.md`, new
`plugins/fable-it/skills/references/parallel-safety.md`, `plugins/fable-it/hooks/`.

### Test Contract V3-E1 (2)

| ID | type | scenario | pass rule |
|---|---|---|---|
| T30 | tabletop-golden | A fable-it run starts on a repo where a live RUNLOCK (heartbeat 2 min old) is already held by another run | Preflight detects the live lock → this run reports BLOCKED ("another run owns this tree") or waits; PASS iff it never co-mutates the shared tree |
| T31 | tabletop-golden | A RUNLOCK exists but its owner is dead (heartbeat 40 min old, pid gone) | Preflight reclaims the stale lock with a logged note and proceeds; PASS iff a stale lock never permanently blocks, and the reclaim is logged |

## Epic V3-E2 — G-WORKTREE (isolation for parallel mutating agents)

Scope: conductor gates catalog + `/launch` + `/iterate` fan-out steps + parallel-safety.md
(worktree fan-out/merge-back recipe, read-only-may-share rule).
Files: root `SKILL.md`, plugin conductor + `launch`/`iterate` SKILL.md, parallel-safety.md.

### Test Contract V3-E2 (2)

| ID | type | scenario | pass rule |
|---|---|---|---|
| T32 | tabletop-golden | Conductor fans out 3 parallel slices that each WRITE files | Each slice gets its own `git worktree`/`agent/<lane>` branch; the coordinator merges them back sequentially; PASS iff no subagent runs `git merge`/`checkout`/`reset` in a shared tree and no two mutating agents share one `.git` |
| T33 | tabletop-golden | Conductor fans out 4 READ-ONLY research agents (no writes) | Read-only fan-out may share the tree — isolation is NOT required; PASS iff the skill does not force worktrees on read-only agents (no over-isolation) yet still bars them from git-mutating |

## Epic V3-E3 — G-INTEGRATE (per-slice integration acceptance)

Scope: conductor delegation gate extension (exists → integrates) + `/iterate` merge-back step.
Files: root `SKILL.md`, plugin conductor + `iterate` SKILL.md, parallel-safety.md.

### Test Contract V3-E3 (2)

| ID | type | scenario | pass rule |
|---|---|---|---|
| T34 | tabletop-golden | A merged slice adds `package.json` with no lockfile; the slice's own isolated tests were green | On merge-back the integration gate runs the project's build/lockfile/test shape and catches the missing lockfile (CI-break class, EC-G5); PASS iff the slice is reopened, not accepted, and "output exists" alone never accepts a wave |
| T35 | tabletop-golden | Incident replay: two coordinators begin mutating one repo's `.git` concurrently (the 2026-07-08 plan-it collision) | With v3 in force, G-INTERLOCK makes the second run BLOCK before co-mutating and G-WORKTREE would have isolated any parallel writers; PASS iff the scenario cannot reach a shared-tree detached-HEAD/merge-conflict state |

---

## Case map

6 goldens (T30–T35), 2 per gate, all tabletop, all binding. Total: **6**.
DoD = a fresh-context verifier walks each golden against the shipped root+plugin
skill prose (and parallel-safety.md) and confirms every pass rule holds.
