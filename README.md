# fable-it

**Hand Claude a goal and a numbered Definition of Done. Go to sleep. Wake up to a report.**

fable-it is a Claude Code plugin that turns Claude into an autonomous overnight delivery engine. It conducts your existing build tools — `/launch`, `/iterate`, `/full-qa`, `/chrome-cdp-control` — enforces a pre-grounding gate, three coherence guardrails, and leaves an honest per-criterion status report instead of a faked green one.

> **fable it. ship it.**
> Claude should work while you sleep, not ask permission.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Works with Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-orange?logo=anthropic)](https://claude.ai/code)
[![Plugin](https://img.shields.io/badge/type-plugin-blueviolet)](https://github.com/DevOtts/fable-it)
[![Author: DevOtts](https://img.shields.io/badge/author-DevOtts-181717?logo=github)](https://github.com/DevOtts)

[Quick Start](#install) · [How it works](#how-it-works) · [Skills bundled](#whats-bundled) · [Invocation](#invocation) · [License](#license)

---

## Install

```sh
# 1. Register this marketplace
/plugin marketplace add DevOtts/fable-it

# 2. Install the plugin
/plugin install fable-it@devotts
```

---

## How it works

You hand fable-it a **goal** and a **numbered Definition of Done**. It does the rest.

```
Goal: Ship the Shopify → Postgres sync for the analytics dashboard.

DoD:
1. Shopify orders sync to postgres.orders with correct schema
2. Incremental sync works (only new orders since last run)
3. Dashboard /analytics page shows real data, not mocks
4. All three pass in the QA report
```

fable-it then runs **six steps** unattended:

| Step | What happens |
|------|-------------|
| **0 — Lock the DoD** | Restructures vague criteria into individually testable items |
| **1 — Autonomous posture** | Proceeds without asking; never takes irreversible actions without prior authorization |
| **2 — Pre-grounding gate** | Reads the real source of truth before writing a line of code |
| **3 — Approach** | Delegates environment setup and agent topology to `/launch` |
| **4 — Guardrails** | Shared decision contract · interface file · honest status per criterion |
| **5 — Cycles** | Routes each DoD item to `/iterate`, `/full-qa`, or `/chrome-cdp-control` by shape |
| **6 — Report** | VERIFIED / IMPLEMENTED-NOT-VERIFIED / BLOCKED — with evidence, never assumptions |

The coherence problem on long overnight jobs is not raw capability — it is decisions made in hour 1 contradicting work done in hour 3. The guardrails exist for that.

---

## Invocation

fable-it **auto-activates** from context. You do not need to type a command. It fires when you describe a goal-to-DoD delivery:

> *"I'm going to bed, finish this"*
> *"green light, take decisions"*
> *"run to DoD"*
> *"work autonomously until done"*
> *a goal + numbered acceptance criteria*

To invoke it explicitly (namespaced by the Claude Code plugin system):

```
/fable-it:fable-it

Goal: <your goal>

DoD:
1. ...
2. ...
```

Only `goal` and `DoD` are required. Paths, credentials, scope fence, and registry all have defaults.

---

## What's bundled

| Skill | Role |
|-------|------|
| `fable-it` | The orchestrator — owns posture, guardrails, and the final report |
| `launch` | Mission control: environment inventory, approach selection, agent topology |
| `iterate` | Diagnosis → fix → test → evaluate cycles |
| `full-qa` | Autonomous QA suite: reads a test plan, runs CDP + iterate, produces a pass/fail report |
| `chrome-cdp-control` | Step-by-step control of the user's real Chrome via Playwright over CDP |

fable-it is a conductor, not a monolith. It calls these skills by name. If one is missing, it degrades and runs that phase inline — it notes which skill was absent in the final report.

---

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

VERIFIED means real data, real endpoint, real evidence. Never a mock dressed up as a pass.

---

## License

MIT — see [`plugins/fable-it/.claude-plugin/plugin.json`](plugins/fable-it/.claude-plugin/plugin.json).

---

_Built by [DevOtts](https://github.com/DevOtts)._
