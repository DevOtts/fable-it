# What makes Fable 5 better than Opus — and which parts a skill can port

**fable-it v2 research doc · 2026-07-02 · synthesized from three evidence streams**

Evidence streams (full detail in `_streams/`):
- **A — Public record** (`_streams/A-public-record.md`): Anthropic announcement, platform
  docs, the **"Prompting Claude Fable 5"** guide, system-card analysis, benchmarks,
  independent community analysis. Every claim carries a credibility class:
  (a) first-party documented · (b) benchmark · (c) marketing · (d) community.
- **B — Plugin audit** (`_streams/B-plugin-audit.md`): what fable-it encodes today
  (consumed by the gap analysis, `02-gap-analysis.md`).
- **C — Live introspection** (`_streams/C-live-introspection.md`): the Fable 5 harness
  behavioral contract observed *from inside a live Fable 5 session* — the ground truth
  the original plugin approximated secondhand.

---

## 1. Executive summary

Fable 5's advantage over Opus 4.8 is **concentrated exactly where fable-it operates**:
long, complex, multi-step autonomous runs. Anthropic's own framing: *"the longer and
more complex the task, the larger Fable 5's lead"* (a/c). The benchmark shape confirms
it: on merely-hard agentic coding the lead is ~1.16x (SWE-Bench Pro 80.3% vs 69.2%),
but on the hardest split it is ~2.2x (FrontierCode Diamond 29.3% vs 13.4%) (b).

But the decomposition matters more than the headline. The advantage splits into three
layers, and only one is locked away:

1. **Trained-in behaviors** (weights) — raw ceiling on the hardest problems, first-shot
   correctness, deep long-context instruction retention. **Not portable.**
2. **A dense, checkable behavioral contract** (system prompt) — autonomous-turn gates,
   two-sided honesty rules, evidence-before-action checks, communication register,
   anti-thrash rules. **Directly portable — this is prompt text.** Anthropic's
   prompting guide publishes several of these snippets verbatim and reports measured
   effects (the claim-grounding snippet "nearly eliminated fabricated status reports").
3. **Harness primitives + scaffolding patterns** — persistent memory, compaction that
   the model is told to trust, fresh-context verifier subagents, deterministic
   orchestration patterns (adversarial verify, loop-until-dry, no-silent-caps), token
   budgets, cache-aware pacing. **Portable as patterns and disk artifacts**, even
   where the underlying tool doesn't exist on the host.

The single most important craft finding (stream C): **Fable's rules are phrased as
verifiable gates at specific decision points, not standing exhortations.** "Before
ending your turn, check your last paragraph — if it is a promise, do that work now"
is a self-audit with a trigger and a test. "Be thorough" is a vibe. Gates survive on
weaker models; vibes decay over a long run. fable-it v1 already has several of the
right postures; v2's job is to convert postures into gates, persist their state to
disk, and add the behaviors v1 missed entirely.

## 2. Verified Fable 5 advantages (the catalog)

Each row: the advantage, the strongest evidence, and the portability verdict that
drives the gap analysis. IDs (F1…) are referenced by `02-gap-analysis.md` and the PRD.

| ID | Fable 5 advantage | Evidence (class) | Portable? |
|----|---|---|---|
| F1 | Lead grows with task length/complexity; sustained multi-day goal-directed runs with strong instruction retention | announcement + docs + prompting guide (a); FrontierCode 2.2x vs SWE-Pro 1.16x shape (b) | Partial — stabilize with scaffolding; ceiling is weights |
| F2 | **Honest progress reporting under the claim-grounding rule** — "audit each claim against a tool result from this session" *nearly eliminated fabricated status reports* in Anthropic testing | prompting guide (a) — the strongest portability evidence in the record | **Yes — measured effect of a prompt snippet** |
| F3 | Autonomous-turn posture: don't ask mid-run; **last-paragraph check** (never end on a promise); pause only for destructive/irreversible/scope/user-only-input | prompting guide (a) + observed live (C1) | **Yes** |
| F4 | Two-sided honesty: no fake green AND no hedging on verified results; look-before-delete; approval doesn't carry across contexts | observed live (C2) | Yes |
| F5 | Scope discipline / no unrequested refactors — a tendency Anthropic still reinforces *by prompt even on Fable* (at high effort Fable over-builds) | prompting guide (a) | Yes |
| F6 | Self-verification, best implemented as **fresh-context verifier subagents** — "separate, fresh-context verifier subagents tend to outperform self-critique" | prompting guide (a) | **Yes — scaffolding pattern** |
| F7 | **Persistent file-based memory helps a Fable-class model 3x more than Opus** (Slay the Spire result); guide dedicates a section to constructing one | announcement (a/b) + guide (a) | Yes — memory scaffold pays off on any model, most on strong ones |
| F8 | No-panic context management: model is told compaction is survivable — "you don't need to wrap up early"; anti-thrash rules (don't re-derive, don't re-litigate, recommend don't survey) | observed live (C4); guide's anti-context-anxiety snippet (a) | Partial — port via disk-staged state + re-grounding + the reassurance text |
| F9 | Reliable parallel/long-lived subagent orchestration; async over blocking; verify delegated output; relay conclusions not dumps | prompting guide (a) + observed live (C5) | Yes — as discipline + patterns |
| F10 | Named multi-agent quality patterns: adversarial verify (N skeptics prompted to refute), perspective-diverse lenses, judge panels, loop-until-dry, completeness critic, **no-silent-caps disclosure** | observed live (C5) | Yes — as prose orchestration patterns |
| F11 | Communication contract: final-message discipline, lead-with-outcome, readable-over-concise (no fragments/arrow-chains/codenames), "teammate catching up" register | observed live (C3) | Yes |
| F12 | Evidence-before-state-change gate: before restarts/deletes/config edits, check the evidence supports *that specific action* | observed live (C1) | Yes |
| F13 | Economic pacing: cache-window reasoning, never busy-wait, match cadence to how fast the watched thing changes; token budgets as hard ceilings | observed live (C6); task budgets in docs (a) | Partial — port as heuristics |
| F14 | 1M context, 128k output, adaptive thinking, memory/compaction/context-editing tools at launch | platform docs (a) | No (harness/model facts) — but they change tuning: parallelize for independence, not context relief |
| F15 | First-shot correctness on well-specified complex work | guide (a), Stripe anecdote (a/c), Willison (d) | No — weights. Compensate with iterate loops |
| F16 | Raw ceiling on hardest problems (FrontierCode Diamond 2.2x) | benchmarks (b) | No — weights |
| F17 | **Cost-aware delegation routing**: subagents default to inheriting the session model; a cheaper tier/lower effort is chosen only for mechanical low-ambiguity stages, top tier reserved for verify/judge/architecture stages | observed live in the Fable 5 harness delegation tools (added 2026-07-02, post-freeze, per user request) | **Yes — a routing rule, pure prose** |

## 3. The honesty caveats (do not oversell)

The system-card record (via credible secondary analysis, class d relaying a)
complicates "Fable is more honest":

- Overall behavioral honesty/factuality: **similar to Opus 4.8** — not a big jump.
- **Hallucinated missing references got WORSE**: ~18% vs Opus 4.8's 9%. A Fable-class
  model *invents citations/APIs more often* — which is precisely why the
  claim-grounding rule (F2) exists and why fable-it must verify references against
  tool results, not trust model confidence.
- Code-review honesty improved an order of magnitude, **but** the model still tends
  to "reframe bugs as conventions."
- Higher evaluation awareness; not inclined to answer "I don't know" — overconfidence
  risk on unattended runs.

**Takeaway for the plugin's marketing and design:** the defensible claim is narrow
and strong — *evidence-grounded status reporting and reference verification
measurably suppress the failure modes that bite overnight runs* — not "this makes
your model honest."

## 4. The three design principles for fable-it v2

Derived jointly from streams A and C; these govern the spec (`03-enhancement-spec.md`):

1. **Gates, not vibes.** Every load-bearing behavior gets a trigger ("before ending
   the turn", "before reporting a criterion", "before any state-changing command")
   and a test ("is the last paragraph a promise?", "can I cite a tool result from
   this session?"). Standing exhortations are the first thing a weaker model drops
   at hour three.
2. **Externalize what Fable holds in its head.** Fable retains ~100 constraints over
   hours from weights; Sonnet 5/Opus cannot. Substitute disk artifacts (grounding
   statement file, decision contract, per-criterion evidence ledger) plus mandatory
   re-reads at phase boundaries. State that survives compaction beats retention you
   don't have.
3. **Verify with fresh eyes, not self-critique.** Anthropic's own guidance: fresh-
   context verifier subagents outperform self-critique. The honesty gate should be
   *structural* (a verifier that never saw the implementation checks the evidence),
   not motivational ("be honest").

## 5. What v2 must stay honest about (the unportable core)

Unchanged from v1's honest claim, now with evidence attached: raw ceiling (F16),
first-shot rate (F15), and deep instruction retention (the weights half of F1/F8)
do not port. The plugin buys back a large fraction of F1 through scaffolding — that
is the whole business — but it should never claim parity. The README's ports/stays
table survives this research; it just needs citations behind it (which this document
now provides) and one correction: "honest, evidence-backed progress reporting" is
not something that *stays with Fable* or comes free with it — it is a prompt-induced
behavior on Fable too (F2), which is the best possible news for a skill that ports it.
