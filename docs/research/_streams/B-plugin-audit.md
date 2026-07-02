# Stream B — Plugin Audit: What fable-it Currently Encodes

Full behavior catalog of the fable-it plugin as of 2026-07-02. Every entry cites
`file:line`. Paths are relative to `/Users/macbook/Workspace/Devotts/fable-it/`.

Category tags: `[coherence]` `[verification]` `[honesty]` `[autonomy]` `[scope]`
`[orchestration]` `[context]` `[recovery]` `[model-adaptive]` `[other]`.

Files audited (all read in full):
- `plugins/fable-it/skills/fable-it/SKILL.md` (214 lines) — the conductor
- `plugins/fable-it/skills/launch/SKILL.md` (745 lines)
- `plugins/fable-it/skills/iterate/SKILL.md` (177 lines)
- `plugins/fable-it/skills/full-qa/SKILL.md` (394 lines)
- `plugins/fable-it/skills/chrome-cdp-control/SKILL.md` (291 lines)
- `SKILL.md` (root portable/degraded, 74 lines)
- `README.md` (298 lines) + `plugins/fable-it/README.md` (10 lines)
- `fable-it-field-guide.pdf` (8 pages)
- `docs/parallel-lifecycle-KICKOFF.md`, `.fable-it-reports/report.md`

---

## 1. Behavior catalog — the conductor (`skills/fable-it/SKILL.md`)

### Coherence-over-time thesis
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C1 | Stated core thesis: with a 1M window, raw capability is rarely the bottleneck; **coherence over time** is — not contradicting an early decision, not building against a schema another component doesn't share, not declaring victory on unverified work. Everything targets that. | `fable-it/SKILL.md:14` | `[coherence]` |
| C2 | Conductor-not-replacement rule: the real work lives in the four delegated skills; this skill only adds posture + pre-grounding gate + guardrails + report. | `fable-it/SKILL.md:12`, `:18-33` | `[orchestration]` |
| C3 | Anti-duplication rule: "if a behavior already exists in one of those four skills, call it. Do not paste a worse copy… Duplicated logic is the same failure mode as a duplicated schema — two sources of truth that drift." | `fable-it/SKILL.md:31` | `[coherence]` `[orchestration]` |
| C4 | Graceful degradation: if a delegated skill is missing, perform that phase inline following the same principle, and note the absence in the report. "Degrade, never break." | `fable-it/SKILL.md:33` | `[recovery]` `[orchestration]` |

### Input contract & DoD gate
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C5 | Only two required inputs (`goal`, `DoD`); everything else defaults so the user doesn't repeat themselves. State assumptions, don't ask. | `fable-it/SKILL.md:38-53`, `:65` | `[autonomy]` `[other]` |
| C6 | Default credentials source: `.full.credentials` then `.env`; create missing tokens via `/chrome-cdp-control` and record them. | `fable-it/SKILL.md:47` | `[other]` |
| C7 | Default report location `.fable-it-reports/` at workspace root; create if missing. | `fable-it/SKILL.md:50`, `:168` | `[other]` |
| C8 | DoD-quality gate: if DoD is numbered+testable keep verbatim; if vague, restructure into numbered individually-verifiable criteria and show it. "Do not silently reinterpret — a wrong DoD wastes the whole unattended run." | `fable-it/SKILL.md:61-64` | `[verification]` `[coherence]` |

### Autonomous posture (Step 1)
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C9 | Autonomous-turn posture: user isn't watching; "Want me to…?" blocks the work. Reversible actions → proceed. | `fable-it/SKILL.md:71-73` | `[autonomy]` |
| C10 | Last-paragraph check: if the turn ends on a plan/question/promise ("I'll…"), that work isn't done — do it now. End only when DoD met or blocked on the user. | `fable-it/SKILL.md:74` | `[autonomy]` |
| C11 | Irreversible-action bar: never drop tables / force-push / delete branches / destructive migrations on shared/prod without explicit prior authorization. | `fable-it/SKILL.md:75` | `[autonomy]` `[recovery]` |
| C12 | Counter-rule "do not fake confidence": keep signaling uncertainty, keep flagging tests that didn't run. "A confident, unverified 'it works' is worse than an honest 'implemented but not verified.'" Named the one behavior never to trade away. | `fable-it/SKILL.md:77` | `[honesty]` `[verification]` |
| C13 | Counter-rule "scope discipline, do not gold-plate": at high effort resist extra features/abstractions/refactors/unneeded error handling. "Max completeness" = complete against the spec, not past it. Validate only at real boundaries (user input, external APIs). | `fable-it/SKILL.md:79` | `[scope]` |

### Pre-grounding gate (Step 2)
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C14 | Read the real source of truth (actual schema/file/connector/tenant), not memory, before implementation. | `fable-it/SKILL.md:87` | `[coherence]` `[verification]` |
| C15 | Write a short **grounding statement**: how the data is modeled and where it's stored. | `fable-it/SKILL.md:88` | `[coherence]` |
| C16 | For each DoD item, name the verification path (endpoint/table/page/log); if none can be named, flag it as likely IMPLEMENTED-NOT-VERIFIED now. | `fable-it/SKILL.md:89` | `[verification]` `[honesty]` |
| C17 | Re-run a lightweight grounding at the start of each major phase (drift countermeasure). | `fable-it/SKILL.md:91` | `[coherence]` `[context]` |

### Approach & decomposition (Step 3)
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C18 | Delegate approach decision (single/subagents/team) to `/launch`; don't reinvent. | `fable-it/SKILL.md:97` | `[orchestration]` |
| C19 | Own the decomposition: build epics → stories → tasks hierarchy (because `/launch`'s `features.json` is flat), map every DoD item to a task, persist to `.taskstate/breakdown-<version>.md`. | `fable-it/SKILL.md:99` | `[orchestration]` `[context]` |
| C20 | **Coherence rule** on parallelization: independent + no shared decision → safe to parallelize; decision-coupled → keep in one thread or bind with Guardrail 1. "Parallelizing decision-coupled work… amplifies drift." | `fable-it/SKILL.md:101-104` | `[coherence]` `[orchestration]` |
| C21 | "Save context window" is a weak reason to parallelize now that the window is large; parallelize for genuine independence/speed, not to shrink context. | `fable-it/SKILL.md:105` | `[context]` `[orchestration]` |

### The three guardrails (Step 4)
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C22 | **Guardrail 1 — shared decision contract**: one file (`.taskstate/decisions.md`) records every cross-cutting decision (schema, field names, interfaces, naming, ownership); every subagent reads before deciding and writes after; shared shapes defined once. | `fable-it/SKILL.md:113-121` | `[coherence]` `[orchestration]` |
| C23 | **Guardrail 2 — interface file**: when a run assumes another session's work, require an explicit agreed interface file; if absent, create it from the PRD/spec and note downstream integration is gated on the other session honoring it. | `fable-it/SKILL.md:123-130` | `[coherence]` `[recovery]` |
| C24 | **Guardrail 3 — honest per-criterion status**: names the structural incentive to fake green; every DoD item gets VERIFIED / IMPLEMENTED-NOT-VERIFIED / BLOCKED with evidence. "Never report VERIFIED on the strength of a mock or an assumption." | `fable-it/SKILL.md:132-141` | `[honesty]` `[verification]` |

### Cycle execution (Step 5)
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C25 | **Verifiability precheck**: confirm the verification target is reachable this session before delegating a criterion; if not, route straight to IMPLEMENTED-NOT-VERIFIED — do NOT spin up an executor against a mock. "A QA pass with no real target manufactures a false green." | `fable-it/SKILL.md:147` | `[honesty]` `[verification]` |
| C26 | Honor explicitly named tools; may upgrade to a stronger fit but must say so — "Never silently substitute." | `fable-it/SKILL.md:149` | `[orchestration]` `[honesty]` |
| C27 | DoD-shape → executor routing table (UI → `/full-qa`; API/DB/job → `/iterate`; raw browser action → `/chrome-cdp-control`; mix → both bound by Guardrail 1). | `fable-it/SKILL.md:151-158` | `[orchestration]` |
| C28 | Track progress in `.taskstate/` per `/launch` convention so state survives a crash or 529. | `fable-it/SKILL.md:160` | `[recovery]` `[context]` |
| C29 | Harness resilience: model resilience and pipeline resilience are independent; on transient failure (529, CDP disconnect) resume from `.taskstate/`, don't restart from zero; don't let infra failure masquerade as task failure in the report. | `fable-it/SKILL.md:162` | `[recovery]` `[honesty]` |

### Deliverables (Step 6) + prohibitions
| # | Behavior | Cite | Tags |
|---|---|---|---|
| C30 | Status report with a fixed template (DoD status table, "could not be verified", what changed, decisions, surprises/risks, next actions). | `fable-it/SKILL.md:170-195` | `[honesty]` |
| C31 | Separate credentials artifact for any token/login/credential created (service, value, use, rotation); never buried in prose. | `fable-it/SKILL.md:197` | `[other]` |
| C32 | Stop cleanly — no appended plan or "want me to continue?" (Step 1 forbids). | `fable-it/SKILL.md:199` | `[autonomy]` |
| C33 | Consolidated "What NOT to do" list restating the guardrails/counter-rules. | `fable-it/SKILL.md:203-211` | `[honesty]` `[scope]` `[coherence]` |

---

## 2. Behavior catalog — `/launch` (`skills/launch/SKILL.md`)

| # | Behavior | Cite | Tags |
|---|---|---|---|
| L1 | 4-phase structure: ANALYZE (read-only) → RECOMMEND (waits for approval) → SETUP → LAUNCH. | `launch/SKILL.md:10`, `:18-20`, `:92-94` | `[orchestration]` |
| L2 | Task classification table (spec/build/fix/refactor/research). | `launch/SKILL.md:30-39` | `[orchestration]` |
| L3 | Complexity assessment checklist (feature count, files, repo boundaries, UI, external APIs, multi-stakeholder). | `launch/SKILL.md:40-49` | `[orchestration]` |
| L4 | Environment inventory: fixed set of CHECK probes for MCPs, hooks, skills, taskstate, init.sh, stack files, Playwright, git hooks, CLAUDE.md, evals. | `launch/SKILL.md:51-88` | `[orchestration]` `[context]` |
| L5 | **`.taskstate/` not `.claude/` rule** — `.claude/` triggers extra VS Code permission prompts; version files per project. Repeated 3×. | `launch/SKILL.md:69`, `:366`, `:385` | `[context]` `[other]` |
| L6 | Approach decision logic with cost bands: single (<5 features, sequential, $0.50-5), sub-agents (independent, $1-8), team (5+ features, needs QA, $5-20). | `launch/SKILL.md:98-121` | `[orchestration]` |
| L7 | Team requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. | `launch/SKILL.md:121` | `[orchestration]` `[model-adaptive]` |
| L8 | Team-composition suggestions per task type (Spec Writer+UX+Reviewer, Backend+Frontend+QA+Reviewer, competing investigators for bugs). | `launch/SKILL.md:123-132` | `[orchestration]` |
| L9 | Proactive tooling recommendations as decision trees: Stitch MCP (mockups), Playwright MCP (UI testing on mobile 375x667 / desktop 1280x720), digital-twin mocks for external APIs, NotebookLM, pre-commit hooks, LangSmith observability, domain skills. | `launch/SKILL.md:134-282` | `[orchestration]` `[verification]` |
| L10 | Digital-twin mocks for external APIs so agents test without hitting real APIs/rate limits/prod data. | `launch/SKILL.md:194-202` | `[verification]` `[other]` |
| L11 | Quality-gate hook recommendations table: Stop (verify tests before stop), TaskCompleted (Playwright evidence for UI), PostToolUse format, Notification, SessionStart compact re-inject. | `launch/SKILL.md:284-295` | `[verification]` `[context]` `[recovery]` |
| L12 | `features.json` schema: all features start `status:"fail"`; 10-50 features; dependency chains; each has a test criterion. | `launch/SKILL.md:334-366` | `[verification]` `[orchestration]` |
| L13 | `progress.md` session-log artifact. | `launch/SKILL.md:368-386` | `[context]` |
| L14 | `init.sh` auto-detected setup with health-poll loop for the dev server. | `launch/SKILL.md:387-433` | `[recovery]` `[verification]` |
| L15 | **External eval runner** in a separate session: QA evaluator reads scenarios, tests via Playwright, "Do NOT read any source code. Only interact with the app through the browser." | `launch/SKILL.md:435-473` | `[verification]` `[honesty]` |
| L16 | Hooks config: Stop hook prompt checks taskstate updated + committed; Notification desktop alert; SessionStart compact re-injects absolute-path context reminder. | `launch/SKILL.md:475-518` | `[context]` `[recovery]` `[verification]` |
| L17 | SessionStart hook must use **absolute paths** so it works regardless of cwd. | `launch/SKILL.md:518` | `[context]` `[recovery]` |
| L18 | Pre-flight checklist before LAUNCH (valid features.json, progress.md, executable init.sh, evals, hooks, CLAUDE.md, MCPs, clean git). | `launch/SKILL.md:579-595` | `[verification]` |
| L19 | CLAUDE.md rule: "Do NOT mark a feature as 'pass' without verification"; commit after each feature. | `launch/SKILL.md:564-577` | `[verification]` `[honesty]` |
| L20 | Launch-prompt templates for sub-agents / teams / single session; team rule "Only update features.json to 'pass' when QA confirms". | `launch/SKILL.md:601-670` | `[orchestration]` `[verification]` |
| L21 | Model assignment appears in team composition (Model: Sonnet/Opus per role). | `launch/SKILL.md:308-310`, `:633` | `[model-adaptive]` `[orchestration]` |
| L22 | Appendix worked patterns: batch PRD gen, full-app team build, adversarial competing-hypotheses bug fix. | `launch/SKILL.md:692-743` | `[orchestration]` |

---

## 3. Behavior catalog — `/iterate` (`skills/iterate/SKILL.md`)

| # | Behavior | Cite | Tags |
|---|---|---|---|
| I1 | Core principle: diagnose before fixing, test after fixing, repeat until criteria met or approaches exhausted. | `iterate/SKILL.md:12` | `[verification]` |
| I2 | Capture acceptance criteria up front; ask ONE question only if unclear, else infer and state them. | `iterate/SKILL.md:18-22` | `[autonomy]` `[verification]` |
| I3 | 4-phase loop DIAGNOSE → FIX → TEST → EVALUATE with fixed output blocks. | `iterate/SKILL.md:29-92` | `[verification]` |
| I4 | DIAGNOSE: identify the specific failing component, form a hypothesis, verify with one targeted check before acting. | `iterate/SKILL.md:31-46` | `[verification]` |
| I5 | FIX: minimal correct fix only; no refactor/features/cleanup; prefer reversible, call out destructive/shared-state changes. | `iterate/SKILL.md:50-56` | `[scope]` `[autonomy]` |
| I6 | TEST: evidence-based verification-method table by task type; "'It should work' is not evidence." | `iterate/SKILL.md:60-77` | `[verification]` `[honesty]` |
| I7 | EVALUATE: PASS/FAIL/PARTIAL with evidence + next action. | `iterate/SKILL.md:78-92` | `[verification]` |
| I8 | Subagent strategy table: Explore for breadth (>5 files), general-purpose for wide fixes/parallel tests, Plan for approach. "Subagents for breadth, keep yourself for depth." | `iterate/SKILL.md:96-123`, `:173` | `[orchestration]` `[context]` |
| I9 | Subagent prompt-quality checklist (what's tried, specific task, return format, relevant paths). | `iterate/SKILL.md:116-123` | `[orchestration]` |
| I10 | Context management: after 3+ cycles summarize a COMPLETED block; hand full context to subagents; save state to temp file near context limits. | `iterate/SKILL.md:126-132` | `[context]` |
| I11 | Stopping conditions: criteria met (show evidence) / blocked by ambiguity / exhausted 3+ distinct root causes / destructive action needs confirmation. | `iterate/SKILL.md:134-142` | `[autonomy]` `[recovery]` |
| I12 | Final report format (status, achieved w/ evidence, fixed, issues found, remaining). | `iterate/SKILL.md:144-164` | `[honesty]` `[verification]` |

---

## 4. Behavior catalog — `/full-qa` (`skills/full-qa/SKILL.md`)

| # | Behavior | Cite | Tags |
|---|---|---|---|
| Q1 | Self-contained: incorporates CDP + iterate natively; do not invoke those skills separately. | `full-qa/SKILL.md:12` | `[orchestration]` |
| Q2 | Step 0 ingest test plan (file path / inline / ask ONE question); extract URLs, creds, cases, setup, stack; infer defaults + state assumptions if missing. | `full-qa/SKILL.md:16-32` | `[verification]` `[autonomy]` |
| Q3 | Phase 1 PREFLIGHT: health-check every service, fix what's down silently before proceeding. | `full-qa/SKILL.md:36-83` | `[verification]` `[recovery]` |
| Q4 | **Chrome CDP hardcoded to `localhost:9222`** in preflight; exact relaunch instructions on failure. | `full-qa/SKILL.md:51-64` | `[other]` `[recovery]` |
| Q5 | Playwright auto-install fallback. | `full-qa/SKILL.md:67-70` | `[recovery]` |
| Q6 | Phase 2 setup/clean-slate; destructive setup (DROP/DELETE/reset) needs a "yes" unless plan says "clean slate required". | `full-qa/SKILL.md:86-100` | `[autonomy]` |
| Q7 | Phase 3 per-test loop: announce → execute → evaluate → PASS/FAIL; on FAIL enter bug-fix cycle immediately (unless plan says collect-all-first). | `full-qa/SKILL.md:104-112` | `[verification]` |
| Q8 | Browser 5-step CDP loop (screenshot → decide → one action → screenshot → repeat); find tab by URL fragment, never `pages[0]`. | `full-qa/SKILL.md:119-142`, `:361-391` | `[verification]` `[other]` |
| Q9 | Selector priority ladder (ARIA → label/placeholder → text → data-testid → coordinate); never auto-generated CSS classes. | `full-qa/SKILL.md:152-158` | `[other]` |
| Q10 | Wait strategy prefers explicit waits over sleep. | `full-qa/SKILL.md:159-164` | `[other]` |
| Q11 | Tab-list-first; never close an unauthorized tab. | `full-qa/SKILL.md:165-171` | `[other]` `[autonomy]` |
| Q12 | Browser failure protocol: one more screenshot, one alt selector, FAIL after 2 attempts; never loop click→fail >twice. | `full-qa/SKILL.md:173-178` | `[recovery]` |
| Q13 | Destructive-action gate: writes beyond the test env need confirmation; localhost writes don't. | `full-qa/SKILL.md:180-181`, `:294-312` | `[autonomy]` |
| Q14 | Phase 4 bug-fix cycle = iterate loop (diagnose/fix/test/evaluate) with Explore subagent for >3-file traces. | `full-qa/SKILL.md:185-222` | `[verification]` `[orchestration]` |
| Q15 | Escalation rules: after 3 distinct diagnosis attempts, or product decision, or destructive migration → escalate. | `full-qa/SKILL.md:224-228` | `[recovery]` `[autonomy]` |
| Q16 | **Regression check**: after a fix, re-run previously-PASS tests touching the same component. "A fix that breaks something else is worse than a known failure." | `full-qa/SKILL.md:229-230` | `[verification]` |
| Q17 | Phase 5 exploratory tests: spawn Explore subagent to find untested bug-prone paths, implement top 3-5. | `full-qa/SKILL.md:234-252` | `[verification]` `[orchestration]` |
| Q18 | Phase 6 final report: metrics, results table, bugs-fixed table, deferred, **Go-Live READY/NOT READY** verdict. | `full-qa/SKILL.md:256-290` | `[honesty]` `[verification]` |
| Q19 | Autonomy rules: proceed on localhost tests/reads/screenshots/fixes/restarts; stop before non-localhost writes, DROP/DELETE, git push, shared-schema migrations, pkill, external-account actions. "Maximum autonomy: fix bugs without asking." | `full-qa/SKILL.md:294-312` | `[autonomy]` |
| Q20 | Stack command cheat-sheet (Supabase/Postgres, Next.js, NestJS, FastAPI, Django/Rails/Laravel, CDP template). | `full-qa/SKILL.md:316-391` | `[other]` |

---

## 5. Behavior catalog — `/chrome-cdp-control` (`skills/chrome-cdp-control/SKILL.md`)

| # | Behavior | Cite | Tags |
|---|---|---|---|
| X1 | Manual loop, not automation: one action / one screenshot / one decision; "If you find yourself writing a `for` loop over actions, stop." | `chrome-cdp-control/SKILL.md:14-16`, `:266` | `[autonomy]` `[other]` |
| X2 | Preflight CDP at `localhost:9222`; on failure stop + give relaunch command; do not start Chrome yourself (user controls which profile is exposed). | `chrome-cdp-control/SKILL.md:20-39` | `[recovery]` `[autonomy]` |
| X3 | Statelessness: each bash command is a fresh CDP connection; re-import, re-connect, re-resolve tab + element every time. | `chrome-cdp-control/SKILL.md:62-73` | `[context]` `[other]` |
| X4 | Never trust `pages[0]`; list tabs and match by URL substring. | `chrome-cdp-control/SKILL.md:75-108` | `[other]` |
| X5 | Selector strategy ladder (same as full-qa); forbidden auto-generated classes; inspect via `aria_snapshot()` when unsure. | `chrome-cdp-control/SKILL.md:110-130` | `[other]` |
| X6 | Waits: earn the wait, don't sleep blindly. | `chrome-cdp-control/SKILL.md:132-144` | `[other]` |
| X7 | **Mandatory destructive-action gate**: post/reply/DM/like/follow/delete/submit/close-tab/logout/pay/upload/any logged-in write → STOP, summarize, wait for "go". "Even if the user said yes to a similar action earlier, re-confirm for each new write." | `chrome-cdp-control/SKILL.md:146-168` | `[autonomy]` |
| X8 | Failure protocol: one more screenshot, one alt selector, then STOP + report options; never loop >twice. CAPTCHA/login-wall/modal handling; never solve CAPTCHAs. | `chrome-cdp-control/SKILL.md:172-191` | `[recovery]` |
| X9 | Clipboard pasting for long/special text (macOS), with foreground-window caveat. | `chrome-cdp-control/SKILL.md:194-204` | `[other]` |
| X10 | Action log: append audit line per action to `~/.chrome-automation-actions.log`. | `chrome-cdp-control/SKILL.md:208-216` | `[honesty]` `[other]` |
| X11 | Canonical action template + hard-rules list (never for-loop, ~20-action check-in cap, never solve CAPTCHAs, never close unauthorized tabs, never retry >twice, never skip the gate, always screenshot before/after, always re-resolve). | `chrome-cdp-control/SKILL.md:220-277` | `[autonomy]` `[other]` |
| X12 | "When NOT to use" boundary (public fetch → web_fetch; bulk scrape → headless script; API exists → use API). | `chrome-cdp-control/SKILL.md:280-288` | `[scope]` |

---

## 6. Behavior catalog — root portable `SKILL.md` (degraded mode)

The root `SKILL.md` (74 lines) is a **condensed restatement** of the conductor plus
install/security prose — it is not an independent behavior set. Notable points:
- Declares the same posture / pre-grounding gate / three guardrails / honest report
  in summary form (`SKILL.md:22-29`). `[coherence]` `[honesty]` `[autonomy]`
- Portability metadata claims platforms `[claude-code, cursor, openclaw, mcp, openai]`
  (`SKILL.md:11`). `[other]`
- Security posture: no secrets to install; `.full.credentials`/`.env` read locally
  only; CDP uses the user's own Chrome; created creds isolated; irreversible actions
  need authorization (`SKILL.md:65-72`). `[other]` `[autonomy]`
- **Structural weakness**: the degraded mode carries the *descriptions* of the
  guardrails but none of the operational detail (no `.taskstate/decisions.md`
  mechanics, no verifiability precheck, no routing table). On any non-Claude-Code
  host the behavior is aspirational prose, not an enforced procedure.

---

## 7. What the README claims does NOT port (the honest-claim table)

From `README.md:59-67` and mirrored in `SKILL.md`/field-guide p.03:

| Ports to Opus ✓ | Stays with Fable ✕ |
|---|---|
| Coherence across a long run, holding early constraints | Raw reasoning ceiling on genuinely hard problems |
| Self-verification before declaring a step done | One-shotting a complex system from a thin prompt |
| Honest, evidence-backed progress reporting | The deepest long-context retention quality |
| Autonomous-turn discipline, no needless pausing | Anything that comes from the weights, not the prompt |
| Restraint — doing the job, not inventing scope | — |

README explicitly disclaims: "It does **not** turn Opus into Fable, and anyone who
tells you a skill can do that is selling something" (`README.md:57`). The field guide
repeats this framing (p.02, p.03, p.08: "A literal '10x'. It's discipline, not a
miracle").

**Audit note on the claim:** the "ports vs stays" split is asserted, never
evidenced. There is no benchmark, no A/B, no eval showing that these five behaviors
actually improve an Opus run, nor that the four "stays with Fable" properties are
truly prompt-inaccessible. It is a plausible and honestly-*framed* claim, but it is a
claim, not a measured result. The README's own Status section concedes this: "this
has been tabletop-tested against real prompts, not yet hammered end-to-end"
(`README.md:241`).

---

## 8. Contradictions, duplications, and drift between skills

1. **Duplicated CDP logic (3 copies).** The full CDP action template, tab-selection
   rule, selector ladder, and wait strategy exist independently in
   `chrome-cdp-control/SKILL.md:110-254`, `full-qa/SKILL.md:119-178` + `:361-391`.
   The conductor's own anti-duplication rule (`fable-it/SKILL.md:31`, "duplicated
   logic is the same failure mode as a duplicated schema — two sources of truth that
   drift") is violated by its own bundle. The KICKOFF doc confirms the drift is real:
   "Loose vs plugin skills have already drifted (`full-qa`, `launch` differ)"
   (`parallel-lifecycle-KICKOFF.md:275`).

2. **Hardcoded `localhost:9222` / port 3000.** `full-qa` hardcodes CDP `:9222`
   (`full-qa/SKILL.md:51`, `:127`, `:367`) and `chrome-cdp-control` does the same
   (`chrome-cdp-control/SKILL.md:24`, `:88`, `:231`). KICKOFF flags this as the
   actual parallel-run collision point (`parallel-lifecycle-KICKOFF.md:24-28`,
   `:272-273`). No skill reads a contract/env for port or CDP URL. Directly blocks
   the parallelism the conductor's Guardrail-1/Step-3 posture assumes.

3. **Manual-loop vs orchestrated-QA tension.** `chrome-cdp-control` forbids `for`
   loops and unattended looping and re-confirms *every* write
   (`chrome-cdp-control/SKILL.md:16`, `:168`), but the conductor routes UI *tests* to
   `/full-qa` which runs many browser actions autonomously on localhost without
   per-action confirmation (`full-qa/SKILL.md:294-312`). The boundary (localhost test
   vs authenticated real-account write) is stated but subtle; an agent could
   plausibly route an authenticated-session task to `/full-qa` and lose the
   per-write gate. No hard guard enforces "authenticated real Chrome ⇒ cdp-control,
   never full-qa."

4. **Report-format proliferation.** Three different final-report templates:
   conductor's DoD table (`fable-it/SKILL.md:170-195`), iterate's Results block
   (`iterate/SKILL.md:144-164`), full-qa's QA Report (`full-qa/SKILL.md:256-290`).
   The conductor says its report "supersedes `/iterate`'s plain final report"
   (`fable-it/SKILL.md:168`) but says nothing about reconciling `/full-qa`'s Go-Live
   verdict — so a fable-it run that delegates QA can surface two verdicts.

5. **`.taskstate/` vs `.claude/` inconsistency inside launch itself.** Launch
   mandates `.taskstate/` for features/progress to avoid VS Code prompts
   (`launch/SKILL.md:69`) yet still writes eval scenarios, runner, and hooks into
   `.claude/` (`launch/SKILL.md:437`, `:461`, `:477`) — the very folder it warns
   about. Mixed guidance.

6. **Approval-model contradiction: `/launch` waits, the conductor doesn't.**
   `/launch` Phase 2 "Present recommendations… **Wait for approval** before
   proceeding" and Phase 4 "Ready to launch?" (`launch/SKILL.md:94`, `:672-681`).
   The conductor's autonomous posture explicitly says don't wait for confirmation —
   the user is asleep (`fable-it/SKILL.md:65`, `:71`). When fable-it delegates to
   `/launch`, `/launch`'s interactive gates would stall an unattended run. Nothing in
   the conductor tells `/launch` to run non-interactively.

---

## 9. The field-guide PDF — sources analysis (KEY FINDING)

The research brief assumed the PDF "documents the papers/claims the plugin was
derived from." **It does not.** The 8-page `fable-it-field-guide.pdf` is a
**her0-studio-branded marketing/design one-pager**, not a derivation document:

- p.01 cover "Make Opus behave like Fable"; author her0, "for Claude Code builders".
- p.02 "One idea does the work" — the discipline-not-magic thesis.
- p.03 the honest-claim ports/stays table (identical to README).
- p.04 "One command, four tools" conductor diagram.
- p.05 the posture blocks (autonomous posture, don't-fake-confidence,
  don't-gold-plate, pre-grounding gate).
- p.06 the three guardrails.
- p.07 install & run.
- p.08 "The whole thing, one card" + CTA `github.com/your-handle/fable-it`.

**Sources cited: none.** Zero papers, zero blog posts, zero URLs, zero benchmarks
appear anywhere in the PDF. The document *asserts* "Behavior transfers… What does
*not* transfer is the underlying capability… That comes from training, not a prompt"
(p.02) with no reference. So the plugin's foundational premise — "we did it from
papers that explain how Fable works" (SHARED-CONTEXT demand) — is **not substantiated
by any artifact in this repo**. The field guide is downstream marketing, and it and
the README/SKILL/root-SKILL are all restatements of the *same* self-authored claim.
There is no primary source, external citation, or empirical result anywhere in the
audited material.

Stale/placeholder items in the PDF:
- p.08 CTA still reads `github.com/your-handle/fable-it` (unfilled template
  placeholder) while the real repo is `github.com/DevOtts/fable-it`.
- p.07 install shows only the loose `~/.claude/skills/fable-it/SKILL.md` drop, not the
  plugin-marketplace path the README calls the "full experience" — the two install
  stories are inconsistent.

---

## 10. Structural weaknesses — behaviors stated once, never enforced with a gate

The plugin is almost entirely **prose instruction with no checkable enforcement**.
The behaviors most likely to be dropped under load are exactly the ones with no gate:

1. **Guardrail 3 (honest status) has no mechanical check.** The single most important
   behavior (`fable-it/SKILL.md:132`) relies on the model choosing not to fake green.
   There is no hook that inspects the report for VERIFIED-without-evidence, no
   schema requiring an evidence field to be non-empty. `/launch` ships a Stop hook
   that checks taskstate/commits (`launch/SKILL.md:485-490`) but nothing verifies the
   *truthfulness* of a VERIFIED status. Compare to `/launch`'s external eval runner
   (`launch/SKILL.md:461-473`) which *is* a real gate — the conductor never wires it
   in as the honesty check it could be.

2. **Pre-grounding gate is unpersisted.** The grounding statement
   (`fable-it/SKILL.md:88`) is written "short" but has no file, no template, and no
   later step reads it back. Under compaction it evaporates. Contrast the shared
   decision contract, which at least names a file (`.taskstate/decisions.md`).

3. **Verifiability precheck has no artifact.** `fable-it/SKILL.md:147` tells the agent
   to confirm reachability but records nothing; a later phase can't tell whether a
   precheck happened. No IMPLEMENTED-NOT-VERIFIED routing is logged until the final
   report.

4. **"Re-ground each major phase" (C17) has no trigger.** No hook, no phase counter,
   no SessionStart-compact re-injection of the grounding statement (though
   `/launch:509` shows the team already knows the compact-reinjection pattern — it's
   just not applied to grounding).

5. **Decomposition/breakdown file is optional in practice.** `.taskstate/breakdown`
   is named once (`fable-it/SKILL.md:99`) with no schema and no consumer step that
   fails if it's missing.

6. **No model-adaptive branching anywhere.** Despite the planning goal (tune for both
   Sonnet 5 and Opus 4.8), the current plugin has **zero** per-model conditioning.
   Model only appears as a team-role label in `/launch` (`launch/SKILL.md:308`,
   `:633`). Every guardrail is written as if one fixed model runs it; there is no
   "if Sonnet, tighten X" logic. This is the largest gap relative to the v2 goal.

7. **Autonomy last-paragraph check (C10) is self-policed.** It asks the model to
   inspect its own final paragraph — a behavior a drifting model is exactly likely to
   skip. No Stop hook enforces "did the turn end on a promise?"

8. **Graceful-degradation path is untested prose.** `README.md:241` admits it's
   tabletop-tested only; the inline-execution fallback (`fable-it/SKILL.md:33`) has no
   example of what "run the phase inline" concretely means for, e.g., `/full-qa`'s
   6-phase pipeline.

---

## Biggest gaps (10-line summary)

1. **The premise is unsourced.** The field-guide PDF cites zero papers/URLs/benchmarks; the "derived from papers on how Fable works" story has no supporting artifact in the repo — it's self-authored marketing restated across README/SKILL/PDF.
2. **No model-adaptive logic exists at all.** Zero per-model conditioning; model appears only as a team-role label in `/launch`. This is the single largest gap vs the v2 goal of tuning for both Sonnet 5 and Opus 4.8.
3. **The core honesty guardrail (Guardrail 3) has no mechanical enforcement** — no hook or schema checks a VERIFIED status for real evidence; it's pure self-policing, the easiest thing to drift under load.
4. **The conductor violates its own anti-duplication rule:** CDP logic is triplicated across `chrome-cdp-control` and `full-qa`, and KICKOFF confirms the copies have already drifted.
5. **Hardcoded `:9222`/port-3000 everywhere** blocks the very parallelism Guardrail 1 assumes; nothing reads a contract/env.
6. **Approval-model contradiction:** `/launch` waits for human approval at two gates while the conductor's whole posture is "the user is asleep" — an unattended run would stall on delegation.
7. **Pre-grounding statement and verifiability precheck are unpersisted** — no file, no consumer, no compaction survival; they evaporate exactly when long runs need them.
8. **Three competing final-report formats** (conductor / iterate / full-qa) with no reconciliation — a delegated QA run can surface two verdicts.
9. **Degraded/portable mode is aspirational prose** — carries guardrail descriptions but none of the operational mechanics, and is admitted to be tabletop-tested only.
10. **Autonomy self-checks (last-paragraph, re-grounding each phase) have no triggers** — the behaviors most load-bearing for long runs are the ones with the least enforcement.
