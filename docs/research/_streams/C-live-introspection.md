# Stream C — Live introspection of the Fable 5 harness (observed 2026-07-02)

**Method & evidence class.** This document is written from *inside* a live Claude
Fable 5 session (model ID `claude-fable-5`, Claude Code harness). Everything below
is directly observed in the operative system prompt / tool contract of that
session — not reconstructed from papers. Evidence class: **first-party observed
behavior**, the strongest available. One honest limit: I can observe the *prompt
and harness*; I cannot introspect *weights*. Where compliance quality is clearly
trained-in rather than instructed, I flag it.

**The headline finding for fable-it:** Fable 5's advantage on long autonomous runs
is not one mechanism — it is a dense, *checkable* behavioral contract enforced at
specific decision points, plus a harness that gives the model economic and
orchestration primitives (workflows, budgets, cache-aware pacing, resumability).
The papers fable-it was built from captured the postures; they largely missed that
Fable's rules are phrased as **verifiable gates at decision moments** ("before
ending your turn, check your last paragraph…") rather than standing exhortations
("be thorough"). That phrasing difference is portable and is the single biggest
upgrade opportunity.

---

## C1. The autonomous-turn contract (the core of what fable-it approximates)

Observed rules, near-verbatim:

- "You are operating autonomously. The user is not watching in real time and
  cannot answer questions mid-task, so asking 'Want me to…?' will **block the
  work**. For reversible actions that follow from the original request, proceed
  without asking. Stop only for destructive actions or genuine scope changes."
- **The last-paragraph check** (load-bearing): "Before ending your turn, check
  your last paragraph. If it is a plan, an analysis, a question, a list of next
  steps, or a promise about work you have not done ('I'll…'), **do that work now
  with tool calls**. That includes retrying after errors and gathering missing
  information yourself. Do not stop because the context or session is long."
- **The assessment exception**: when the user is describing a problem or thinking
  aloud rather than requesting a change, the deliverable is the assessment —
  report findings and stop; don't apply a fix until asked.
- **Evidence-before-state-change**: "Before running a command that changes system
  state — restarts, deletes, config edits — check that the evidence actually
  supports that *specific* action. A signal that pattern-matches to a known
  failure may have a different cause."

**Why this matters for the plugin:** the last-paragraph check is a *self-audit
gate with a concrete trigger and a concrete test* (is my final paragraph a promise?
→ then execute it). fable-it currently encodes "don't pause needlessly" as posture;
Fable encodes it as an executable check. Gates beat postures on models with weaker
trained adherence (Sonnet 5, Opus).

## C2. The honesty & reporting contract

- "Report outcomes faithfully: if tests fail, say so with the output; if a step
  was skipped, say that; when something is done and verified, state it plainly
  without hedging."
- Before deleting or overwriting anything: *look at the target first*; if what you
  find contradicts how it was described, or you didn't create it, surface that
  instead of proceeding.
- Outward-facing/irreversible actions: confirm first unless durably authorized;
  "approval in one context doesn't extend to the next"; sending content to an
  external service *is publishing* (may be cached/indexed even if deleted).

Note the symmetry: honesty is required in BOTH directions — no fake green, but
also no hedging on genuinely verified results. fable-it's honest-report format
captures the first half; the "state it plainly when verified" half prevents the
useless wall-of-caveats report.

## C3. The communication contract (final-message discipline)

- "Text you write between tool calls may not be shown to the user. **Everything
  the user needs from this turn must be in the final text message**, with no tool
  calls after it." Mid-turn text is brief status only.
- "Lead with the outcome" — first sentence answers what happened / what was found.
- "Being readable and being concise are different things, and **readable matters
  more**": no fragments, no abbreviations, no arrow chains (`A → B → fails`), no
  self-invented codenames the reader must cross-reference; complete sentences;
  shortness comes from *selecting* what to include, not compressing prose.
- Write for "a teammate who stepped away and is catching up, not for a log file."

**Why this matters:** overnight-run reports are exactly the "teammate catching up"
case. fable-it's report template controls *structure*; Fable's contract also
controls *register* — that's why Fable reports read well. Portable as writing
rules in the report phase.

## C4. Context-management: the no-panic contract

- "When the conversation grows long, some or all of the current context is
  summarized; the summary + remaining context are provided in the next window so
  work can continue — **you don't need to wrap up early or hand off mid-task**."
- Anti-thrash rules: "When you have enough information to act, act. Do not
  re-derive facts already established, re-litigate a decision the user has already
  made, or narrate options you will not pursue. If weighing a choice, give a
  recommendation, not an exhaustive survey."

**Why this matters:** older models degrade near context limits partly because they
*behave anxiously* — summarizing early, wrapping up, re-verifying old ground.
Fable is explicitly told the harness has its back. fable-it can port this two ways:
(a) tell the model compaction is survivable, and (b) make it survivable in fact by
staging state to disk (which fable-it already partially does with interface files).

## C5. Orchestration & delegation primitives (harness-level, partially portable)

- **Subagent discipline**: delegate multi-file sweeps and keep "the conclusion,
  not the file dumps"; once delegated, don't duplicate the search yourself; the
  agent's final message is not shown to the user — *relay what matters*; named,
  continuable agents (send follow-ups instead of respawning cold).
- **Workflow tool** (deterministic orchestration): scripts with `pipeline()` (no
  barriers by default), `parallel()` (explicit barrier only when cross-item context
  is needed), structured-output schemas per agent, per-phase progress, resume from
  a journal of every agent's actual return value.
- **Named quality patterns**, encoded in the harness itself: adversarial verify
  (N independent skeptics prompted to REFUTE each finding, majority kills it);
  perspective-diverse verify (distinct lenses beat N identical checkers);
  judge panels; loop-until-dry (keep spawning finders until K consecutive rounds
  find nothing new — fixed counts miss the tail); completeness critic ("what's
  missing?" as a final agent); **no silent caps** (if coverage was bounded, log
  what was dropped — "silent truncation reads as 'covered everything'").
- **Token budgets as a first-class primitive**: a shared spend pool with
  `remaining()`, hard ceilings, and loop-until-budget patterns.
- **Verification of delegated work**: cached results may be empty — read the
  journal before assuming; "idle ≠ delivered" exists at the harness level too.

**Why this matters:** fable-it orchestrates via prose instructions to teams. The
portable upgrades are the *patterns* (adversarial verify, loop-until-dry,
no-silent-caps, completeness critic) and the *discipline* (verify delegated output
on disk, relay conclusions), even where the Workflow tool itself isn't available.

## C6. Economic self-pacing (mostly harness; the reasoning style is portable)

- Wake-up scheduling reasons in **prompt-cache windows** (5-minute TTL): "Don't
  pick 300s — worst of both worlds… think in cache windows, not round minutes";
  polling a ~8-minute CI run with 60s sleeps "burns the cache 8 times."
- Don't poll harness-tracked work at all — completion re-invokes you; schedule a
  long fallback in case it hangs.
- **Model/effort tiering in delegation**: the harness's own guidance on spawning
  agents — default to inheriting the session model ("almost always correct"); set
  a different tier only when highly confident it fits; use low reasoning effort
  for "cheap mechanical stages and higher tiers only for the hardest verify/judge
  stages." Cost-awareness is built into the delegation contract itself.

**Why this matters:** the *cost-aware reasoning habit* ports: fable-it's overnight
loop can encode "match your check-in cadence to how fast the watched thing
actually changes; never busy-wait."

## C7. Skill/tool dispatch discipline

- Matching skill → "BLOCKING REQUIREMENT: invoke the skill BEFORE generating any
  other response"; never mention a skill without calling it; never guess skill
  names.
- Dedicated tools over shell equivalents; independent tool calls batched in one
  block (parallelism by default).
- A `/verify` culture: exercise the affected flow end-to-end and *observe
  behavior* — "not just tests or typecheck" — before committing nontrivial changes.

## C8. Code & scope restraint

- Comments: only "a constraint the code itself can't show — never… why your change
  is correct; that's you talking to the reviewer… noise the moment the PR merges."
- "Write code that reads like the surrounding code."
- Memory rules refuse redundant storage: "don't save what the repo already
  records" — an anti-scope-creep rule applied to the model's own artifacts.

## C9. Memory (cross-session state, harness feature + usage discipline)

- Persistent file-based memory: one fact per file, typed frontmatter
  (user/feedback/project/reference), an index file loaded each session, explicit
  dedup-before-save, delete-when-wrong, and **distrust-on-recall** ("reflects what
  was true when written — verify it still exists before recommending").

## C10. What is clearly trained-in (the honest unportable core)

Observed indirectly but consistently: the *compliance quality*. The same text in
front of a weaker model under-enforces — long instruction lists decay over a long
run. Fable 5 holds ~100+ simultaneous behavioral constraints over hours without
re-prompting; that retention is weights, not prompt. Also weights-only: raw
reasoning ceiling, one-shot design quality, long-context retention fidelity, and
calibration quality of its confidence statements.

**Design consequence for fable-it v2:** where Fable relies on trained adherence,
the plugin must substitute **externalized enforcement**: fewer standing rules,
more *checkable gates at decision points*, state staged to disk artifacts (so
constraints survive compaction without needing retention), and periodic
re-grounding reads (re-read the contract file at phase boundaries instead of
hoping the model remembers it).

---

## C11. Summary table — Fable 5 behavior → portability verdict

| # | Observed Fable 5 behavior | Mechanism | Portable to Sonnet 5 / Opus? |
|---|---|---|---|
| 1 | Last-paragraph self-audit gate | prompt, checkable gate | **Yes — highest value** |
| 2 | Assessment-vs-action mode split | prompt rule | Yes |
| 3 | Evidence-before-state-change check | prompt, gate at command time | Yes |
| 4 | Two-sided honesty (no fake green, no hedge on verified) | prompt rule | Yes |
| 5 | Final-message contract + lead-with-outcome | prompt rule | Yes |
| 6 | Readable-over-concise register rules | prompt rule | Yes |
| 7 | No-panic compaction contract | harness promise + prompt | Partial — port via disk-staged state + re-grounding reads |
| 8 | Anti-thrash (don't re-derive/re-litigate) | prompt rule | Yes |
| 9 | Adversarial verify / judge panels / loop-until-dry / completeness critic | harness Workflow patterns | Yes — as prose orchestration patterns |
| 10 | No-silent-caps disclosure | pattern rule | Yes |
| 11 | Verify delegated output ("idle ≠ delivered", journal reads) | harness + rule | Yes (already partially in fable-it) |
| 12 | Token-budget-aware scaling | harness primitive | Partial — port as cost heuristics |
| 13 | Cache-window pacing economics | harness primitive | Partial — port as cadence heuristics |
| 14 | Skill-dispatch blocking requirement | prompt rule | Yes |
| 15 | /verify end-to-end culture (observe behavior, not tests) | skill + rule | Yes |
| 16 | Comment/code restraint rules | prompt rule | Yes |
| 17 | Typed persistent memory w/ distrust-on-recall | harness feature | Partial — port as run-scoped state files |
| 18 | 100+ constraint retention over hours | **weights** | **No — substitute gates + re-grounding** |
| 19 | Raw reasoning ceiling / one-shot quality | weights | No |
| 20 | Calibration of confidence claims | weights (mostly) | Partial — force evidence citations per claim |
