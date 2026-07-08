# parallel-safety — the operational protocol for safe parallel & multi-session execution

Referenced by the conductor's **interlock**, **worktree**, and **integration** gates
(v3, CONTRACT §2). This is the mechanics; the gates are the triggers. Host-agnostic;
the optional Claude Code hook is noted at the end.

Governing idea: **the working tree is shared state.** Two agents writing one `.git`
corrupt it — detached HEADs, files reverting under you, a merge conflict landing
mid-work. Treat concurrent writers like concurrent writers to a database: **serialize
or isolate, never hope.**

---

## 1. RUNLOCK — one writer per working tree (interlock gate)

`.taskstate/RUNLOCK` (JSON), one live holder per tree:

```json
{ "owner": "<run/session id>", "host": "<hostname>", "pid": 12345,
  "startedAt": "<ISO8601>", "heartbeat": "<ISO8601, refreshed each phase>" }
```

- **Acquire** at run start (Step 1) and refresh `heartbeat` at every phase boundary.
- **Live** = `heartbeat` age < 10 min. Before acquiring, read any existing RUNLOCK:
  - held live by another owner → **do not co-mutate.** Report BLOCKED
    ("another run owns this tree: <owner> on <host>, pid <pid>") or wait for release,
    per the run's autonomy setting.
  - **stale** (heartbeat age ≥ 10 min, or pid not running on this host) → reclaim it,
    writing a `run-memory.md` note: `reclaimed stale RUNLOCK from <owner> (heartbeat <age>)`.
    Never a silent takeover.
- **Release** on completion and on the stop-hook (delete the file). A crash leaves a
  stale lock, which the next run reclaims — so a crash never permanently blocks.
- Also treat a pre-existing `.git/MERGE_HEAD` (an unfinished merge) as "tree busy":
  resolve or abort it before starting, never start work on top of it.

## 2. Worktree isolation — one tree per mutating agent (worktree gate)

When fanning out agents that **write/edit files**:

```
base=$(git branch --show-current)                      # the run base
for lane in A B C; do
  git worktree add -b agent/$lane .fable-it/wt/$lane "$base"   # isolated tree + branch
done
# dispatch one mutating agent per worktree; its cwd is .fable-it/wt/<lane>.
# each agent works ONLY inside its worktree and NEVER runs git merge/checkout/reset.
```

- **Read-only** fan-out (research, search, audit — no repo writes) **may share** the
  main tree; do not pay worktree overhead for it. It still never mutates git.
- **Merge-back is coordinator-only and sequential** (§3) — workers never merge.
- Prefer the harness's native isolation when available (e.g. an agent runner's
  `isolation: worktree` option) — same guarantee, auto-cleaned when unchanged.
- Clean up: `git worktree remove .fable-it/wt/<lane>` after merge; `git worktree prune`.

## 3. Sequential merge-back + integration acceptance (integration gate)

The coordinator, alone, one lane at a time:

```
for lane in A B C; do
  git merge --no-ff agent/$lane          # resolve any conflict HERE, in the base
  <integration check>                    # build + lockfile + declared tests/lints
  #   green  → accept the lane, continue
  #   broken → REOPEN the lane (do not accept the wave); fix or re-dispatch
done
```

- The **integration check** is the project's real shape: it builds, a lockfile is
  present and consistent (the canonical miss: a `package.json` added with no lockfile
  → CI break), and the declared tests/lints pass on the **merged** tree.
- Acceptance is **integration, not existence**: the delegation gate confirms a worker's
  output exists; this gate confirms the *merged* result works. A slice green in its own
  worktree but broken after merge is reopened — never accepted on existence alone.

## 4. Optional hardened hook (Claude Code only, fail-open)

- **Preflight** (SessionStart/run-start): write+check the RUNLOCK per §1; refuse to
  proceed on a live foreign lock.
- **Stop hook**: release the RUNLOCK.
- Both fail-open on script error (never brick a run) and carry a one-line disable, in
  the v2 hook style. The prose gates above are the baseline on every host.

---
_Authored by [DevOtts](https://github.com/DevOtts)._
