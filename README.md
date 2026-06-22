<div align="center">

<h1>/fable-it</h1>

<h3>
  <strong>Make Opus behave like Fable</strong>
</h3>

<p>
  Hand Claude a goal and a numbered Definition of Done.<br>
  <strong>Go to sleep. Wake up to an honest report.</strong>
</p>

<p>
  <em>Behavior transfers. That's what makes overnight jobs survivable.</em>
</p>


<a href="#how-it-works">
  <img src="assets/fable-it-header.gif" alt="fable-it process flow — goal, DoD, autonomous run, honest report" width="100%">
</a>

<p>
  <a href="#install"><img src="https://img.shields.io/badge/Quick%20Start-Install-blue?style=for-the-badge" alt="Quick Start"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License: MIT"></a>
  <a href="https://claude.ai/code"><img src="https://img.shields.io/badge/Works%20with-Claude%20Code-orange?style=for-the-badge&logo=anthropic" alt="Works with Claude Code"></a>
  <a href="https://claude.ai/code"><img src="https://img.shields.io/badge/runs%20on-Opus-blueviolet?style=for-the-badge" alt="Runs on Opus"></a>
  <a href="https://github.com/DevOtts"><img src="https://img.shields.io/badge/author-DevOtts-181717?style=for-the-badge&logo=github" alt="Author: DevOtts"></a>
</p>


<p>
  <a href="#install">Install</a>
  &nbsp;·&nbsp;
  <a href="#the-honest-claim">The honest claim</a>
  &nbsp;·&nbsp;
  <a href="#how-it-works">How it works</a>
  &nbsp;·&nbsp;
  <a href="#whats-bundled">What's bundled</a>
  &nbsp;·&nbsp;
  <a href="#what-the-report-looks-like">The report</a>
</p>


> [!NOTE]
> **Optimized for long tasks** — research, browser tasks and mainly **vibe coding**.

<br>
</div>

When you watch Fable run a long, multi-step task, the thing that stands out isn't raw cleverness. It's that it **holds the thread**: it doesn't contradict a decision it made an hour ago, it tests its own work before claiming it's done, it reports honestly when it couldn't verify something, and it doesn't wander off building things you never asked for.

That's *behavior*, not IQ — and behavior transfers. fable-it packs those behaviors into a single Claude Code skill, so Opus runs long, unattended jobs the way Fable does.

## The honest claim

It does **not** turn Opus into Fable, and anyone who tells you a skill can do that is selling something. It makes Opus **behave** like Fable on long work — which is most of what you actually felt when you used Fable.

| Ports to Opus ✓ | Stays with Fable ✕ |
|---|---|
| Coherence across a long run, holding early constraints | Raw reasoning ceiling on genuinely hard problems |
| Self-verification before declaring a step done | One-shotting a complex system from a thin prompt |
| Honest, evidence-backed progress reporting | The deepest long-context retention quality |
| Autonomous-turn discipline, no needless pausing | Anything that comes from the weights, not the prompt |
| Restraint — doing the job, not inventing scope | |

The line is real. But the part that ports over is the part that makes overnight jobs survivable: your Opus runs them far more like Fable than it did yesterday.

## Install

```sh
# 1. Register the marketplace
/plugin marketplace add DevOtts/fable-it

# 2. Install the plugin (plugin-name@marketplace-name)
/plugin install fable-it@devotts
```

The marketplace name `devotts` comes from the `name` field in [marketplace.json](.claude-plugin/marketplace.json).

Alternatively, install via the skills CLI:

```sh
npx skills add DevOtts/fable-it
```

## How it works

You hand fable-it a **goal** and a **numbered Definition of Done**. It does the rest — unattended.

```
Goal: Ship the Shopify → Postgres sync for the analytics dashboard.

DoD:
1. Shopify orders sync to postgres.orders with correct schema
2. Incremental sync works (only new orders since last run)
3. Dashboard /analytics page shows real data, not mocks
4. All three pass in the QA report
```

fable-it is a **conductor, not a replacement**. If you already run Claude Code with skills like `/launch`, `/iterate`, `/full-qa` and `/chrome-cdp-control`, it routes each piece of work to the right one at the right moment — and never pastes a worse copy of their logic. Improve `/iterate`, and fable-it inherits the improvement.

![fable-it process flow diagram](assets/fable-it-flow.png)


On top of routing, it enforces the layer that otherwise gets hand-written into every overnight prompt:

- **Autonomous posture** — keeps moving instead of stopping to ask permission, clamped by two counter-rules: don't fake confidence, don't gold-plate. Irreversible actions still need prior authorization.
- **Pre-grounding gate** — reads the real source of truth (the actual schema, the real endpoint) *before* writing a line of code, so hour-3 work doesn't drift from hour-1 reality.
- **Three coherence guardrails** that stop long, parallel runs from quietly falling out of sync:
  1. **Shared decision contract** — parallel agents read and write one shared file for every cross-cutting decision, so a renderer is never built for schema A while a connector saves schema B.
  2. **Cross-session interface file** — when this run assumes work another session is still building, it writes the contract both sides agree on instead of guessing.
  3. **Honest per-criterion status** — every DoD item gets a state with evidence: `VERIFIED`, `IMPLEMENTED-NOT-VERIFIED`, or `BLOCKED`. No green result is ever reported off a mock or an assumption.

The coherence problem on long jobs isn't raw capability — it's decisions made in hour 1 contradicting work done in hour 3. The guardrails exist for exactly that.

## Use

You don't have to type a command — the skill **auto-activates** when you describe a goal-to-DoD delivery:

> *"work autonomously until done"* · *"I'm going to bed, finish this"* · *"run to DoD"* · *"green light, take decisions"* · or a goal followed by numbered acceptance criteria.

To invoke it explicitly (plugin skills are namespaced by the plugin name):

```
/fable-it:fable-it Build the Shopify multi-store connector.
  DoD:
  1. Backfill shows all records in connector-logs
  2. Pooling enabled in UI, records appear in logs
  3. New interactions visible on the timeline page
  4. ShopifyRenderer shows details for a clicked item
```

Only two things are required: the **goal** and a **numbered DoD**. Everything else has a sensible default — credentials, tooling inferred from the DoD, parallelism, report location. It's built to run unattended: a long silence means it's working, not stuck.

## What's bundled

| Skill | Role |
|-------|------|
| `fable-it` | The conductor — owns posture, guardrails, and the final report |
| `launch` | Mission control: environment inventory, approach selection, agent topology |
| `iterate` | Diagnosis → fix → test → evaluate cycles |
| `full-qa` | Autonomous QA suite: reads a test plan, runs CDP + iterate, produces a pass/fail report |
| `chrome-cdp-control` | Step-by-step control of your real, logged-in Chrome via Playwright over CDP |

Because the skills it delegates to ship inside the plugin, there are no missing dependencies. And if a delegated skill is absent in some environment, fable-it **degrades gracefully** — it runs that phase inline and notes the absence in its report, rather than failing.

## What the report looks like

```
# Fable-it Report — Shopify → Postgres analytics sync
Run window: 02:14 → 05:47  |  Approach: single session

## DoD status
| # | Criterion                          | Status                    | Evidence              |
|---|------------------------------------|---------------------------|-----------------------|
| 1 | Orders sync with correct schema    | VERIFIED                  | 1,847 rows, schema ✓  |
| 2 | Incremental sync works             | VERIFIED                  | delta query confirmed |
| 3 | Dashboard shows real data          | IMPLEMENTED-NOT-VERIFIED  | service was down      |
| 4 | All three pass in QA report        | BLOCKED                   | depends on #3         |

## Recommended next actions
- Restart the dashboard service and re-run /full-qa for criterion 3
```

`VERIFIED` means real data, a real endpoint, real evidence — never a mock dressed up as a pass.

## Status

Honest, like the skill itself: this has been tabletop-tested against real prompts, not yet hammered end-to-end in every environment. Validate the plugin locally before relying on it:

```sh
claude plugin validate ./plugins/fable-it
claude plugin validate .
```

## Security considerations

- **No secrets are required to install or run the skill.** You supply credentials only for the specific job you ask it to do.
- It reads `.full.credentials` and `.env` **locally only** — these are never transmitted anywhere and are not committed.
- Browser automation uses **your own Chrome** via the Chrome DevTools Protocol (CDP) on a local port, reusing your existing logged-in session. fable-it does not store or exfiltrate your cookies or session.
- Any credential created during a run (e.g. an admin token, a registry login) is **isolated in a dedicated credentials artifact** with rotation notes — never buried inside the prose report.
- Irreversible actions (dropping tables, force-push, destructive migrations on shared/prod state) always require explicit prior authorization; autonomy covers reversible work only.

## License

MIT — see [LICENSE](LICENSE) and [plugin.json](plugins/fable-it/.claude-plugin/plugin.json). Use it, fork it, ship with it.

---

Thank you for contribution:
- [andre2654](https://github.com/andre2654)
- [mBidarra](https://github.com/mBidarra)
- [her0 Studio](https://github.com/her0-studio/)

---

_Built by [DevOtts](https://github.com/DevOtts)._