# Parallel dev lifecycle — design + kickoff note

Orientation for a FRESH session that will build a parallel agentic development
lifecycle as a Claude Code plugin in its OWN new repo
(`/Users/macbook/Workspace/Devotts/parallel-lifecycle/`, public as
`github.com/DevOtts/parallel-lifecycle`), listed in the existing `devotts`
marketplace via an external source. Read this first. It is both the design
(co-developed in the prior session) and the handoff context that design alone
does not carry.

## What you're building (one line)

A layered substrate that gives every git worktree its own isolated, disposable
environment (app port, ephemeral Chrome/CDP, per-stack database) behind a single
contract file, so N Claude sessions build features in parallel end-to-end without
colliding, and converge cleanly back to main.

## Why this exists (the bottleneck it kills)

Fernando runs many Claude Code sessions in parallel, one per worktree. Today they
collide on port 3000, on the database, and on the single real Chrome at `:9222`.
A `worktree-test-isolation` skill + two hooks were written to fix this but were
never connected: the hooks are not installed or registered, and the orchestrator
skills (`/launch`, `/full-qa`, `/iterate`, `/fable-it`) hardcode port 3000 and
`:9222` instead of reading the contract. So isolation never happens
automatically, and `/fable-it` routing UI work through `/full-qa` serializes
every parallel run on the one real browser. That is the bottleneck.

## The architecture (layers, one contract between them)

Do not build a mega-skill. Demote isolation from a peer skill to a substrate, so
there is nothing left to reconcile. Four layers:

| Layer | Owns | Form |
|---|---|---|
| 0. Provisioning | ports, ephemeral Chrome, per-worktree DB, lifecycle | hooks (deterministic, zero model discretion) |
| 1. Contract | `.env.worktree`: `APP_PORT`, `CDP_URL`, `DATABASE_URL`, branch/PR identity | one file, the thin waist |
| 2. Capabilities | run the app, `/iterate`, `/full-qa` | skills made contract-aware (read the contract, never hardcode) |
| 3. Orchestration | goal→DoD, decomposition, fleet/merge-state | `/fable-it`, `/launch` |

The load-bearing idea: `/full-qa` stops knowing about worktrees. It reads
`$CDP_URL` and `$PORT` from the contract and is done. It no longer overlaps with
the isolation logic, because it contains none. Same for `/iterate` and app-run.
Single responsibility per skill, one shared contract, no duplicated environment
assumptions.

`worktree-test-isolation` as a standalone skill mostly dissolves: its hooks
become Layer 0, its `.env.worktree` becomes Layer 1, its prose rules (model
selection, storageState auth, flock serialization for the real `:9222` browser)
fold into the capability skills as the rules they follow.

## Packaging + naming (decided)

`/fable-it` is branded narrowly and well: "make Opus behave like Fable, hand it a
goal and a DoD, sleep, wake to an honest report. Behavior transfers." The
substrate is broader than that. A single non-autonomous session benefits from
worktree isolation; `/launch` benefits; a human driving `/iterate` benefits. So
the substrate is a layer BELOW fable-it, not a feature of it. Burying it inside
the fable-it plugin would couple a general capability to one specific workflow,
which is the same layering mistake (isolation-as-peer) one level up.

Decision (Fernando, this session): parallel-lifecycle ships as its OWN public
repo `github.com/DevOtts/parallel-lifecycle` so it can be promoted with its own
README/stars (the way fable-it was), and is listed in the SAME `devotts`
marketplace via an external source. Confirmed against the Claude Code docs: a
marketplace.json entry can point at a different repo with
`"source": { "source": "github", "repo": "DevOtts/parallel-lifecycle" }`
(optionally pinned with `ref`/`sha`; subdir variant uses `git-subdir` + `path`).
The repo can also carry its own `marketplace.json` and be dual-listed with no
conflict. fable-it stays the conductor and gets a v0.2 that sits on top, now a
cross-repo dependency (documented; plugins already degrade gracefully when a
delegate is absent). The plugin in its repo is canonical; regenerate (or symlink)
the loose `~/.claude/skills` copies from it to kill the loose-vs-plugin drift
found this session.

Name (locked): **parallel-lifecycle**. Plain over clever on purpose. It names the
exact problem being solved (parallel feature development across its full
lifecycle), which is also good for skill matching: Claude routes to skills by
name + description, so a descriptive name triggers more reliably than a
metaphor. Plugin = `parallel-lifecycle` in the `devotts` marketplace; the
headline skill carries the same name.

Marketplace-host decision (recommended, do after Phase 1): the `devotts`
marketplace manifest currently sits inside the `fable-it` repo, so today users
add it with `/plugin marketplace add DevOtts/fable-it`. As the marketplace goes
multi-plugin and public, that is a confusing story. Recommended: create a thin
`github.com/DevOtts/devotts` index repo that holds only `marketplace.json` (plus
a landing README listing every DevOtts plugin) and references each plugin by
external github source. Then users add `DevOtts/devotts` once and install any
plugin by name; each plugin keeps its own promo repo. Interim with zero new
infra: leave the manifest in the fable-it repo and add the parallel-lifecycle
entry there. This is wiring, not a blocker for building the plugin.

End-user install (target state):
```
/plugin marketplace add DevOtts/devotts
/plugin install parallel-lifecycle@devotts
```

## Database isolation (detection-first, generic)

There is no fixed engine. The substrate is generic, so the stack is whatever the
target project uses. First run scans the codebase (a subagent that detects web
framework, DB engine(s), services, how the app reads its connection string),
writes a cached **stack profile** (e.g. `.wt/stack.json`), and confirms with the
user. The bootstrap then provisions DB isolation according to that profile. Never
hardcode Postgres or Mongo.

Default isolation model: one shared DB server, one database per worktree
(logical isolation, near-zero cost, scales to many parallel worktrees). Escalate
to a container per worktree only when a branch changes the engine/version/
extensions or needs process-level isolation. Schema-per-worktree is rejected
(fragile if any query hardcodes `public.`).

Per-engine "copy the current local data" mechanism:
- Postgres: `CREATE DATABASE wt_<slug> TEMPLATE <local_db>` (near-instant
  copy-on-write clone). For a clean slate, `TEMPLATE template0` then migrate +
  seed.
- MongoDB: no templates. Either `mongodump` the local db once and
  `mongorestore --nsFrom=app.* --nsTo=wt_<slug>.*` per worktree (copies current
  data), or name the db `wt_<slug>` and run the project seed script (clean
  slate; Mongo creates the db lazily).

Two design rules that make it work end-to-end:
1. Decouple the lifecycle clocks. Ephemeral, cheap-to-rebuild resources (Chrome,
   port) live on the SESSION clock (create on SessionStart, kill on SessionEnd).
   The DB lives on the BRANCH clock (create once at provision, drop only on
   worktree-remove / merge). Dropping the DB on SessionEnd would nuke seed data
   every time the laptop closes and risk dropping mid-run.
2. Split create vs seed. The Layer 0 hook creates the empty namespaced db and
   writes `DATABASE_URL` into `.env.worktree`. The project's `init.sh` (which
   `/launch` already generates) sources that and runs migrate + seed against
   `$DATABASE_URL`. Migrations are project-specific and stay out of the global
   hook.

Scaling caveat to handle, not ignore: N parallel apps + test runners against one
Postgres can exhaust `max_connections` (default 100). Cap each app's pool, raise
`max_connections`, or front with pgbouncer. Real ceiling near 15 parallel. Mongo
does not have this particular wall. Sanitize `<slug>` to a safe identifier
(lowercase, non-alnum → `_`, truncate to the engine's db-name limit).

## First concrete slice (do this first)

Close the loop on a single worktree before touching any orchestrator:
1. Install + register the two hooks (`worktree-bootstrap.sh`,
   `worktree-teardown.sh`) into `~/.claude/hooks/` and `~/.claude/settings.json`
   (SessionStart/SessionEnd), MERGED into the existing hooks block, not
   replacing it. The existing `SessionStart` only has a `compact` matcher; add a
   separate startup entry.
2. Make `/full-qa` read `${CDP_URL:-http://localhost:9222}` and `$PORT` from
   `.env.worktree` in preflight, keeping `:9222` only as the explicit model-3
   fallback for the real authenticated browser.
3. Prove two parallel worktrees get different `APP_PORT`/`CDP_PORT`, two separate
   Chromes, and that `/full-qa` drives the worktree Chrome, not `:9222`.

Do NOT start by merging the three skills into one, and do NOT keep editing the
loose skill copies as the source of truth once the plugin exists.

## Suggested phase order

1. Scaffold the parallel-lifecycle plugin in its OWN new repo (plugin at repo
   root + its own marketplace.json) + hooks installed and registered (Layer 0 +
   Layer 1). Prove isolation on one worktree, then two. Defer wiring the entry
   into the `devotts` marketplace until after review.
2. Stack-detection subagent + cached stack profile + DB provisioning per profile
   (Postgres database-per-worktree first since Engine-Core is Postgres; Mongo
   path second).
3. Make capability skills contract-aware: `/full-qa` (`$CDP_URL`/`$PORT`),
   app-run, `/iterate`. Regenerate loose copies from the plugin.
4. fable-it v0.2: assume the substrate, route browser work through `$CDP_URL`,
   add the worktree preflight before its Step 5 cycles. Declare the dependency.
5. Fleet / merge-state tracking (the original "Pain 1": which branches to merge/
   deploy). Layer 3 responsibility, design later. Borrow from loop-engineering
   here (see "Related prior art").

Stop for review after Phase 1.

## Related prior art: loop-engineering (orthogonal, borrow 3 things)

Cobus Greyling's `loop-engineering` (and companion `goal-engineering`) was
researched this session. Verdict: orthogonal, keep both. It is the recurring-work
SCHEDULER tier that sits ABOVE the conductor ("design loops that prompt your
agents instead of prompting them yourself"). It explicitly ASSUMES worktree
isolation exists and ships none (no port/DB/browser/CDP isolation), which is
exactly the floor parallel-lifecycle builds. Their `post-merge-cleanup` pattern
is a downstream consumer of our converge-to-main. So position
parallel-lifecycle as "the isolated worktree loop-engineering assumes exists,"
not as a competitor. Note Fernando already has `/loop` and `/schedule` skills
covering part of that scheduler tier.

Three concrete borrows (not a merge):
1. Per-worktree run-log + token-cost line + a "readiness" score (their
   loop-audit / loop-cost CLIs) attached to the Phase 5 fleet/merge-state
   tracker.
2. Explicit goal lifecycle states from goal-engineering — `complete` / `blocked`
   / `paused` — adopted by fable-it's DoD conductor (maps onto its existing
   VERIFIED / IMPLEMENTED-NOT-VERIFIED / BLOCKED states).
3. The "loop" as the named unit of recurring work running on top of N worktrees.
   This is the orchestration tier above the contract file, and where `/loop` /
   `/schedule` plug in.

## Where the code lives

- New repo to create: `/Users/macbook/Workspace/Devotts/parallel-lifecycle/`
  (becomes public `github.com/DevOtts/parallel-lifecycle`, the plugin's promo
  home). `git init`; plugin at the REPO ROOT (`.claude-plugin/plugin.json`,
  `hooks/`, `skills/`, `README`), plus its own `.claude-plugin/marketplace.json`
  for direct discovery. Copy this kickoff note into its `docs/`.
- Marketplace host: the `devotts` marketplace manifest currently lives at
  `/Users/macbook/Workspace/Devotts/fable-it/.claude-plugin/marketplace.json`. It
  gains an external-source entry pointing at the parallel-lifecycle repo (see
  Packaging). The fable-it repo (`main`, clean) is otherwise untouched until v0.2.
- Existing isolation assets to harvest:
  `~/.claude/skills/worktree-test-isolation/` (`SKILL.md`, `worktree-bootstrap.sh`,
  `worktree-teardown.sh`, `connect.py`, `INSTALL.md`).
- Active (drifted) capability skills: `~/.claude/skills/{launch,full-qa,iterate,
  fable-it,chrome-cdp-control}/SKILL.md`. Plugin copies under
  `~/.claude/plugins/marketplaces/devotts/plugins/fable-it/skills/`.
- Prior-session brief: `/Users/macbook/Downloads/SESSION-CONTEXT.md` (records the
  settled decisions: deterministic ports not auto-increment; model 1 ephemeral
  Chrome vs model 3 serialized real Chrome; hook-vs-skill split by determinism;
  SessionStart hook event).

## The locked decisions (each with its why)

1. Layered substrate, not a mega-skill — dissolves the skill overlap instead of
   merging it; keeps single responsibility.
2. `.env.worktree` is the single source of truth — the thin waist; nothing above
   re-derives ports/CDP/DB.
3. Own public repo for the substrate, listed in the `devotts` marketplace via an
   external github source; fable-it stays the conductor on top — fable-it's brand
   is narrow (overnight DoD delivery); the substrate has a broader audience and
   its own promo repo; avoids coupling. Cross-repo dependency, documented.
4. Plugin is canonical, loose `~/.claude/skills` copies are generated — kills the
   loose-vs-plugin drift found this session.
5. Deterministic ports via hook, judgment via skill — port allocation in a skill
   is prose the model can skip; that was the original non-determinism bug.
6. DB isolation is detection-first and generic — no fixed engine; scan + confirm
   per project, cache a stack profile.
7. Default DB model = one server, one database per worktree — cheapest, scales;
   container-per-worktree is the escalation only.
8. Decouple lifecycle clocks — Chrome/port on the session clock, DB on the branch
   clock.
9. Real `:9222` Chrome stays owned by `chrome-cdp-control`, serialized via flock
   — never used as the default app-testing browser.

## How to run + test (this session's setup)

- Verify a worktree provisions: from inside a linked worktree,
  `bash ~/.claude/hooks/worktree-bootstrap.sh` then `cat .env.worktree`, then
  `set -a; source .env.worktree; set +a`.
- Two parallel worktrees must show different `APP_PORT`/`CDP_PORT`/`DB_PORT` and
  two separate Chrome processes (`ps aux | grep remote-debugging-port`).
- CDP smoke test: `python3 ~/.claude/skills/worktree-test-isolation/connect.py`
  after the app is up. It reads `CDP_URL` from `.env.worktree`.
- Playwright dependency: `pip3 install playwright && python3 -m playwright install
  chromium`.
- Engine-Core is the first real consumer (Postgres; services via
  `brain-scripts/start-services.sh`, backend `:3101` / frontend `:3100` per the
  current global SessionStart hook). Use it to validate the Postgres DB-per-
  worktree path.

## Gotchas to carry forward (bit us this session)

- The hooks were never installed. `~/.claude/hooks/` has no worktree scripts and
  `settings.json` does not reference them. Installing is step one or nothing else
  matters.
- The global `~/.claude/settings.json` already has `Notification`, a
  `compact`-matched `SessionStart`, a `Stop` prompt scoped to Engine-Core, and a
  `PreToolUse` Bash hook (`rtk hook claude`). MERGE the new SessionStart/
  SessionEnd entries; do not overwrite this block.
- `/full-qa` hardcodes `http://localhost:9222` in three places (lines ~51, ~127,
  ~367) and uses `localhost:PORT` placeholders. That is the actual collision.
- Loose vs plugin skills have already drifted (`full-qa`, `launch` differ). Edit
  the wrong copy and the fix will not load in real work repos (loose copies load
  there; the plugin is project-scoped to this repo only).
- The bootstrap launches Chrome `--headless=new` (toggle `WT_HEADED=1`). Fine for
  `/full-qa` screenshots.
- DB teardown must NOT run on SessionEnd. Only on worktree-remove.

## Handoff state

- Nothing built yet. Architecture and decisions are locked (this note).
- Name locked: `parallel-lifecycle` (plugin + headline skill), in its own public
  repo, listed in the `devotts` marketplace via external github source.
- Minor open (after Phase 1, wiring only): where the `devotts` marketplace
  manifest lives — recommended a thin `DevOtts/devotts` index repo; interim is to
  keep it in the fable-it repo. Does not block the build.
- This kickoff note currently lives in the fable-it repo; the new session should
  copy it into the new repo's `docs/`.
- Open work: everything in the phase order above, starting at Phase 1.
