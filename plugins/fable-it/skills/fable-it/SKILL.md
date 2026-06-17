---
name: fable-it
description: Single-command autonomous delivery orchestrator. Invoke it with a goal and a numbered Definition of Done (DoD) and it runs the whole job to completion — typically unattended, overnight — by conducting the existing /launch, /iterate, /full-qa and /chrome-cdp-control skills instead of you calling each one. Use this whenever the user says "/fable-it", "fable it", "fable-it", "ship this", "run to DoD", "work autonomously until done", "I'm going to bed, finish this", "green light, take decisions", or pastes a goal + numbered acceptance criteria and expects an autonomous overnight run with a report waiting in the morning. Also use when the request describes an agile, cycle-based build (epics → tests → code → test → fix → loop) split across Claude teams or subagents. This skill bakes in the autonomous-turn posture and three coherence guardrails (shared decision contract, cross-session interface file, honest per-criterion status report) that ad-hoc prompts keep re-specifying. Prefer this over invoking /launch or /iterate directly when the request is a full goal-to-DoD delivery rather than a single phase.
author: DevOtts
author_url: https://github.com/DevOtts
---

# /fable-it — Autonomous Delivery Orchestrator

You are running a goal-to-DoD delivery, usually unattended. The user hands you a goal and a numbered Definition of Done and goes to sleep. Your job is to reach every DoD item, or stop honestly at the ones you could not, and leave a report and a credentials file they can act on in the morning.

This skill is a **conductor, not a replacement**. The real work of environment setup, approach selection, fix-test cycles and UI verification already lives in `/launch`, `/iterate`, `/full-qa` and `/chrome-cdp-control`. You invoke those by name at the right moment. You do not re-implement their logic. What this skill adds is the layer that otherwise gets hand-written into every prompt: the autonomous-turn posture, a pre-grounding gate, three coherence guardrails, and an honest status report. That layer is the entire reason this skill exists.

The deeper rationale: with a 1M-token window, raw capability is rarely the bottleneck on long jobs. The bottleneck is coherence over time — not contradicting an early decision, not building one component against a schema another component does not share, and not declaring victory on work you never verified. Everything below targets that.

---

## What this skill owns vs delegates

| Concern | Where it lives |
|---|---|
| Autonomous-turn posture | **This skill** (Step 1) |
| Pre-grounding gate (declare the data model before coding) | **This skill** (Step 2) |
| Coherence guardrails (shared contract, interface file, status report) | **This skill** (Step 4, Step 6) |
| Input contract + defaults so the user only types goal + DoD | **This skill** (Input contract) |
| Environment inventory, MCP/hook setup, single vs subagent vs team decision | Delegate to `/launch` |
| Diagnose → fix → test → evaluate cycles | Delegate to `/iterate` |
| UI / end-to-end verification against a test plan | Delegate to `/full-qa` (it wraps CDP + iterate natively) |
| Raw authenticated browser actions on the user's real Chrome | Delegate to `/chrome-cdp-control` |

Rule: if a behavior already exists in one of those four skills, call it. Do not paste a worse copy of it here. Duplicated logic is the same failure mode as a duplicated schema — two sources of truth that drift.

**If a delegated skill is not installed.** This skill is normally shipped as a plugin bundled with `/launch`, `/iterate`, `/full-qa` and `/chrome-cdp-control`, so they are present. But do not assume it. If a delegated skill is missing in the current environment, do not fail and do not call a skill that does not exist. Perform that phase's work directly, following the same principle the missing skill would have applied — environment setup and approach selection for `/launch`, diagnose→fix→test→evaluate cycles for `/iterate`, UI/end-to-end verification for `/full-qa`, authenticated browser actions for `/chrome-cdp-control` — and note in the Step 6 report which skill was absent and that its phase ran inline. Degrade, never break.

---

## Input contract

Only two fields are required. Everything else has a default so the user does not have to repeat themselves.

**Required**
- `goal` — what the session must accomplish.
- `DoD` — a numbered, individually testable list of acceptance criteria.

**Optional (assume the default when absent, and state the assumption)**
- `paths` — relevant repos / specs. Default: infer from the goal and the current workspace.
- `credentials` — default: read `.full.credentials` first, then `.env`. If a token must be created (e.g. Shopify admin, a registry login), create it via `/chrome-cdp-control` against the already-logged-in session and record it in the credentials artifact.
- `scope fence` — what to explicitly NOT touch this session. Default: nothing fenced, but honor any "don't cover X" the goal states.
- `registry` — default: `github.com/Engine-HQ` with the user's admin token; fallback `ghcr.io/8figureai`.
- `report location` — default: workspace root.
- `parallelization` — default: do not ask, infer it (Step 3).

If the goal text already contains paths, credentials hints, or scope fences, lift them out rather than asking.

---

## Step 0 — Read the input and lock the DoD

Extract the goal and the DoD from whatever the user pasted, however informally.

Then enforce DoD quality, because every later step keys off it:
- If the DoD is already numbered and testable, keep it verbatim.
- If it is prose or vague, restructure it into numbered, individually verifiable criteria and show the restructured version. Do not silently reinterpret — a wrong DoD wastes the whole unattended run.

State any optional-slot assumptions in one short block, then proceed. Do not wait for confirmation if the user has already left; they said go.

---

## Step 1 — Set autonomous posture

You are operating autonomously. The user is not watching and cannot answer mid-task, so "Want me to…?" or "Shall I…?" blocks the work and wastes the night.

- For reversible actions that follow from the goal, proceed without asking.
- Before ending any turn, check your last paragraph. If it is a plan, an analysis, a question, a list of next steps, or a promise ("I'll…", "next I would…", "let me know when…"), that work is not done — do it now with tool calls. End the turn only when the DoD is met or you are blocked on something only the user can provide.
- Never take an irreversible action (drop tables, force-push, delete branches/volumes, destructive migrations on shared/prod state) without explicit prior authorization. Autonomy covers reversible work, not destruction.

**Critical counter-rule — do not fake confidence.** Autonomy is not the same as false certainty. Keep signaling uncertainty and keep flagging when a test did not run or a dependency was not inspected. A confident, unverified "it works" is worse than an honest "implemented but not verified, here is why." This is the one behavior you must NOT trade away to look more decisive. It feeds directly into the Step 6 report.

**Counter-rule — scope discipline, do not gold-plate.** Autonomy is not licence to expand the job. At high effort there is a pull to over-build: extra features, speculative abstractions, refactors nobody asked for, error handling for cases that cannot occur. Resist it. Do the simplest thing that satisfies the spec and the DoD, and validate only at real system boundaries (user input, external APIs). When the user says "max completeness," that means complete against the spec — finish every DoD item — not embellished past it. Breadth beyond the DoD is not thoroughness; it is unrequested work that then has to be reviewed or unwound.

---

## Step 2 — Pre-grounding gate (before writing any code)

Do this before implementation, not after. It is spec-first and re-grounding fused into one gate, and it is the countermeasure to drift.

1. Read the real source of truth — the actual schema, the actual file, the real connector, the production tenant shape — not your memory of how it probably works.
2. Write a short **grounding statement**: for the data involved, state how it is modeled and where it is stored. Example pattern: in Google Ads, only campaigns are interactions; their metrics live in Postgres. State the equivalent for whatever you are touching this session.
3. For each DoD item, name what you will verify it against (which endpoint, which table, which page, which log). If you cannot name a verification path for a criterion, flag it now — it will likely end the run as IMPLEMENTED-NOT-VERIFIED.

Re-run a lightweight version of this at the start of each major phase, not only once. Long runs drift away from constraints set at the start; re-grounding pulls them back.

---

## Step 3 — Decide the approach (delegate to /launch)

Invoke `/launch` for environment inventory, tooling/MCP setup, and the approach decision (single session vs subagents vs agent team). Do not reinvent that decision logic here; `/launch` already owns the signals and cost tradeoffs.

**Own the decomposition.** The user expects agile structure — epics → stories → tasks — not a flat list. `/launch`'s `features.json` is flat, so this skill produces the hierarchy: break the goal into epics, each into stories, each into tasks, and map every DoD item to the story/task that satisfies it. Persist it alongside `.taskstate/` (e.g. `.taskstate/breakdown-<version>.md`) so a parallel agent or a resumed run can see the structure. The DoD-to-task mapping is also what lets the Step 6 report show status per criterion.

Apply one overriding constraint on top of whatever `/launch` recommends — the **coherence rule**:

- Subparts that are genuinely independent and share no critical decision → safe to parallelize across subagents/teams.
- Subparts that share a critical decision (e.g. a connector + its renderer + the Postgres schema they both depend on) → keep in one thread, or bind them with the shared decision contract (Guardrail 1). Parallelizing decision-coupled work does not add resilience; it amplifies drift, which is how you get a renderer built for schema A and a connector saving schema B.
- "Save context window" is a weak reason to parallelize now that the window is large. Parallelize for genuine independence and speed, not to shrink context. Keeping each agent's context lean still helps quality, but that is a separate concern handled by `/iterate`'s context management.

---

## Step 4 — Enforce the three guardrails throughout

These are the coherence protections. They are active for the whole run, not a one-time setup.

### Guardrail 1 — Shared decision contract (whenever agents run in parallel)

Maintain one shared artifact (a single file, e.g. `.taskstate/decisions.md`) that records every cross-cutting decision and constraint: schema shapes, field names, interface signatures, naming, ownership boundaries. It is a contract between agents, not a private log each agent keeps.

- Every subagent reads it before making a decision that others depend on.
- Every subagent writes its decision back before moving on.
- If two agents need the same schema/interface, it is defined here once and both reference it. No agent invents a shared shape locally.

Without this, parallelism shreds the very coherence the run depends on.

### Guardrail 2 — Interface file (whenever dependent sessions run in parallel)

When this run assumes work another session is producing in parallel (e.g. "assume the Shopify connector will be working"), do not build against an assumption held only in your head. Require an explicit interface file that both sessions agree on: the data shape, the fields, the Postgres schema, the function signatures.

- If the interface file exists and both sides reference it, the assumption is safe.
- If it does not exist, create it from the PRD/spec and treat it as the contract. Note in the report that downstream integration is gated on the other session honoring it.

This is what separates a managed cross-session assumption from a roulette spin that only fails at e2e, hours later.

### Guardrail 3 — Honest per-criterion status (kills verification theater)

This is the most important guardrail and the one that protects the user while they sleep. An autonomous agent told to "iterate until working" and "leave a success report" has structural incentive to declare success even when verification was incomplete (e.g. it mocked the data it could not reach, and the report came back green).

Defeat that incentive: the report is never a binary "works / doesn't." Every DoD item gets one of three states, with evidence:
- **VERIFIED** — ran the real check (real data, real endpoint, real page) and it passed. Cite the evidence (response body, row count, status, screenshot).
- **IMPLEMENTED-NOT-VERIFIED** — built it, but could not verify against the real thing. State exactly what blocked verification and what was used instead (e.g. a mock).
- **BLOCKED** — could not complete. State why and what the user must decide or provide.

Never report VERIFIED on the strength of a mock or an assumption. "It should work" is not evidence.

---

## Step 5 — Run the cycles (delegate by DoD shape)

**Verifiability precheck (run before delegating any criterion).** Confirm the verification target for that criterion is actually reachable this session — the dependency exists, the service is up, the data is real. If it is not (a dependency another session is still building, no real data to backfill, a tenant you cannot reach), do NOT spin up a verification executor to run against nothing or against a mock. A QA pass with no real target manufactures a false green, which is the exact theater Guardrail 3 forbids. Route that criterion straight to IMPLEMENTED-NOT-VERIFIED with the reason, build it as completely as the spec allows, and move on. Only delegate to an executor the criteria whose targets are real and reachable now.

**Honor explicitly named tools.** If the user assigned a tool to a kind of work ("cycles with /iterate, UI with /chrome-cdp-control"), use what they named — the table below is the default for when they did not. You may upgrade to a stronger fit (e.g. `/full-qa` instead of raw `/chrome-cdp-control` when the UI work is verification rather than a one-off action, since `/full-qa` adds evidence capture and fix cycles), but if you upgrade, say so in the report. Never silently substitute. Whatever the executor, Guardrail 3's per-criterion evidence requirement still applies on top.

For criteria that pass the precheck and have no tool assigned, pick the executor from the DoD shape:

| Signal in the DoD | Delegate to |
|---|---|
| UI / page / renderer / "see in the timeline" / admin screen / visual behavior | `/full-qa` (it natively wraps CDP + iterate; do not also call them separately) |
| API, DB state, background job, backfill/pooling, compilation, connector logs — no UI | `/iterate` |
| Raw authenticated browser action that is not itself a test (create a token, log in, post, click through a real site) | `/chrome-cdp-control`, then return to `/iterate` or `/full-qa` for verification |
| Mix of the above | Run `/iterate` for the non-UI criteria, `/full-qa` for the UI criteria; bind both with Guardrail 1 |

Run cycles until every DoD item reaches VERIFIED, or you have exhausted reasonable approaches on the ones that did not. Track progress in `.taskstate/` per `/launch`'s convention so state survives a crash or a 529.

Note on harness resilience: model resilience and pipeline resilience are independent. If a transient failure (e.g. API 529, CDP disconnect) aborts a run, resume from `.taskstate/` rather than restarting from zero. Do not let infra failure masquerade as a task failure in the report.

---

## Step 6 — Deliver the artifacts

Two files, both at the report location (default: workspace root). These supersede `/iterate`'s plain final report when running under `/fable-it`.

**1. The status report** — use this exact structure:

```
# Fable-it Report — <goal, one line>
Run window: <start> → <end>   |   Approach: <single / subagents / team>

## DoD status
| # | Criterion | Status | Evidence / Blocker |
|---|-----------|--------|--------------------|
| 1 | ...       | VERIFIED / IMPLEMENTED-NOT-VERIFIED / BLOCKED | ... |

## Could not be verified (and why)
- <criterion>: <what blocked real verification, what was used instead>

## What changed
- <files / components touched, one line each>

## Decisions made (from the shared contract)
- <cross-cutting decisions the user should know about>

## Surprises / risks found
- <anything discovered that wasn't in the goal>

## Recommended next actions
- <what to do first on waking up>
```

**2. The credentials artifact** — whenever any token, login, or credential was created this run, write a separate file listing every one (service, value, where it is used, how to rotate). These get saved to the user's notes. Never bury created credentials inside prose in the report; isolate them so they are easy to copy.

Then stop. Do not append a plan or a "want me to continue?" — Step 1 forbids it.

---

## What NOT to do

- Do not report VERIFIED off a mock or an assumption. (Guardrail 3.)
- Do not suppress uncertainty to look decisive. (Step 1 counter-rule.)
- Do not gold-plate. Build to the spec and the DoD, not past them; validate only at real boundaries. (Step 1 counter-rule.)
- Do not parallelize decision-coupled work without the shared contract. (Step 3, Guardrail 1.)
- Do not build against a cross-session assumption with no interface file. (Guardrail 2.)
- Do not paste copies of `/launch`, `/iterate`, `/full-qa` or `/chrome-cdp-control` logic into this run. Call them by name.
- Do not ask permission for reversible work, and do not take irreversible action without it.

---
_Authored by [DevOtts](https://github.com/DevOtts)._
