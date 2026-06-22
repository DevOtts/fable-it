---
name: fable-it
description: Autonomous goal-to-DoD delivery orchestrator for Claude Code. Hand it a goal and a numbered Definition of Done and it runs the whole job to completion — typically unattended — conducting launch, iterate, full-qa and chrome-cdp-control with an autonomous posture, a pre-grounding gate, three coherence guardrails, and an honest per-criterion report.
version: 0.1.0
license: MIT
author: DevOtts
author_url: https://github.com/DevOtts
homepage: https://github.com/DevOtts/fable-it
repository: https://github.com/DevOtts/fable-it
metadata:
  platforms: [claude-code, cursor, openclaw, mcp, openai]
  category: Agents & Orchestration
keywords: [autonomous, orchestrator, agents, definition-of-done, workflow, claude-code]
---

# fable-it — Autonomous Delivery Orchestrator

fable-it is a single-command autonomous delivery orchestrator. You hand it a **goal** and a **numbered Definition of Done (DoD)** and it runs the whole job to completion — typically unattended, overnight — leaving an honest report and a credentials file you can act on in the morning.

It is a **conductor, not a replacement**. The real work of environment setup, approach selection, fix-test cycles and UI verification already lives in the bundled `/launch`, `/iterate`, `/full-qa` and `/chrome-cdp-control` skills. fable-it invokes those by name at the right moment instead of re-implementing their logic. What it adds is the layer that otherwise gets hand-written into every overnight prompt:

- **Autonomous posture** — keeps moving instead of pausing to ask permission, clamped by two counter-rules: don't fake confidence, don't gold-plate. Irreversible actions still require prior authorization.
- **Pre-grounding gate** — reads the real source of truth (the actual schema, the real endpoint) *before* writing a line of code, so hour-3 work doesn't drift from hour-1 reality.
- **Three coherence guardrails**:
  1. **Shared decision contract** — parallel agents read and write one shared file for every cross-cutting decision, so a renderer is never built for schema A while a connector saves schema B.
  2. **Cross-session interface file** — when a run assumes work another session is still building, it writes the contract both sides agree on instead of guessing.
  3. **Honest per-criterion status** — every DoD item gets a state with evidence: `VERIFIED`, `IMPLEMENTED-NOT-VERIFIED`, or `BLOCKED`. No green result is ever reported off a mock or an assumption.

The bottleneck on long jobs is rarely raw capability — it's coherence over time. Everything above targets that.

## Install

**Claude Code plugin (recommended)** — installs fable-it together with the four skills it conducts:

```sh
# 1. Register the marketplace
/plugin marketplace add DevOtts/fable-it

# 2. Install the plugin (plugin-name@marketplace-name)
/plugin install fable-it@devotts
```

**Via the skills CLI:**

```sh
npx skills add DevOtts/fable-it
```

## Getting started

Give fable-it a goal and a numbered DoD. Everything else has a sensible default — credentials, tooling inferred from the DoD, parallelism, report location.

```
/fable-it Ship the Shopify → Postgres sync for the analytics dashboard.

DoD:
1. Shopify orders sync to postgres.orders with the correct schema
2. Incremental sync works (only new orders since last run)
3. Dashboard /analytics page shows real data, not mocks
4. All three pass in the QA report
```

It auto-activates on phrases like *"work autonomously until done"*, *"run to DoD"*, *"I'm going to bed, finish this"*, or a goal followed by numbered acceptance criteria. A long silence means it's working, not stuck. When it finishes, you get a per-criterion status report and — if any credential was created during the run — a separate credentials artifact.

## Security considerations

- **No secrets are required to install or run the skill.** You supply credentials only for the specific job you ask it to do.
- It reads `.full.credentials` and `.env` **locally only** — these are never transmitted anywhere and are not committed.
- Browser automation uses **your own Chrome** via the Chrome DevTools Protocol (CDP) on a local port, reusing your existing logged-in session. fable-it does not store or exfiltrate your cookies or session.
- Any credential created during a run (e.g. an admin token, a registry login) is **isolated in a dedicated credentials artifact** with rotation notes — never buried inside the prose report.
- Irreversible actions (dropping tables, force-push, destructive migrations on shared/prod state) always require explicit prior authorization; autonomy covers reversible work only.

---
_Authored by [DevOtts](https://github.com/DevOtts)._
