# KICKOFF — fable-it v2 build

**One-liner:** upgrade the fable-it plugin from postures to checkable gates with
disk-backed run state, a fresh-context verifier, model-adaptive tuning
(Sonnet 5 / Opus 4.8), and optional hooks enforcement — built from firsthand
Fable 5 research, not secondhand papers.

## Read in this order
1. `delivery/CONTRACT.md` — the law (vocabulary, artifacts, definition of shipped)
2. `delivery/prd-fable-it-v2.md` — decisions SD1–SD9, epic table, risks
3. `delivery/epics-fable-it-v2.md` — scope + the 26-case binding test contract
4. `docs/03-enhancement-spec.md` — the design (incl. §4 model-adaptive table, §5 hooks)
5. Research (evidence behind everything): `docs/research/01-fable5-vs-opus.md`,
   `docs/research/02-gap-analysis.md`, `docs/research/_streams/*`

## Locked decisions (do not re-litigate)
- G2.1 hooks hardened mode: YES, optional/opt-in/fail-open
- G2.2 rebrand: "Make your model behave like Fable"
- G2.3 memory: per-run `.taskstate/run-memory.md` + cross-run `.fable-it-reports/lessons.md`
- G2.4 field-guide PDF: DEFERRED (only fix README/SKILL text)
- G2.5 cost-aware delegation routing: YES (CONTRACT v1.1) — tier table in spec
  §4.1; default-inherit when unsure; never downgrade the verifier or
  contract-writing packets; per-agent cost table in the report
- Waves: W0 = E1+E5 · W1 = E2+E3+E4+E7 · W2 = E6 (file-ownership driven)

## Gotchas from the planning session
- The conductor file has a hard budget (~300 lines, lint ≤330): gates must be
  terse trigger/test/action lines; the posture table lives in the spec and is
  *referenced*, never copied (copies drift — that's defect D3's lesson).
- `/launch` interactive gates are the silent killer of unattended runs (D2) — E3
  must keep them for direct human use; condition, don't delete.
- full-qa is co-owned by E4 (QA logic) and E5 (CDP sections) — E5 merges first.
- Keep DevOtts authorship (frontmatter `author`/`author_url` + footer) on every
  SKILL.md touched; the root SKILL.md is what non-Claude-Code users run — its
  degraded mechanics are a deliverable, not documentation.
- Tabletop-golden cases: register the expected transcript BEFORE implementing;
  judge with a fresh-context agent, not the implementer.
- `[REAL]` cases (T4, T9) need a live Sonnet 5 / Opus 4.8 session; if unavailable,
  report IMPLEMENTED-NOT-VERIFIED — never a fake green.

## State at handoff
- Planning docs + delivery package written, **uncommitted** on `main` (docs/,
  delivery/ are new). First build step: branch, commit the package, then W0.
- Nothing in `plugins/` has been modified yet.

---

## Copy-paste launch prompt (run in a FRESH session at the repo root)

```
/fable-it

Goal: Build fable-it v2 per the frozen delivery package in this repo
(/Users/macbook/Workspace/Devotts/fable-it).

Before writing any code, read in order:
1. delivery/KICKOFF.md  (hard-won context: locked decisions, gotchas, waves)
2. delivery/CONTRACT.md (v1.1 — the law: vocabulary, artifacts, shipped def)
3. delivery/prd-fable-it-v2.md and delivery/epics-fable-it-v2.md (scope + the
   26-case binding test contract)
4. docs/03-enhancement-spec.md (design; §4 posture table, §4.1 routing table)

Then play back, in a few lines: the one-line thing being built, the wave
order, and the non-negotiables (gates not vibes; VERIFIED = evidence-ledger
lookup; never re-litigate G2.1–G2.5; conductor ≤ ~300 lines, reference the
spec tables, never copy them). After the playback, proceed autonomously to
the DoD — do not wait for further approval.

Code lives here on branch main (base SHA cb1b17a). First action: commit the
delivery package + docs on main, then execute epics in waves (W0: E1+E5,
W1: E2+E3+E4+E7, W2: E6), one branch per epic (epic/E<N>-<slug>), PR to main.
Start with E1. Do NOT paste posture prose back into the conductor — E1
replaces postures with the 5-gate catalog; and do NOT copy the spec §4/§4.1
tables into skills (reference them — copies drift, that is defect D3).

Definition of Done:
1. All 7 epics implemented on their branches and merged to main.
2. The 26-case test contract in delivery/epics-fable-it-v2.md passes 100% —
   tabletop-golden cases judged by a fresh-context agent against registered
   expected transcripts; grep-lints scripted and green; E7 unit tests green;
   [REAL] cases run live or honestly reported IMPLEMENTED-NOT-VERIFIED.
3. Consistency lint clean per CONTRACT §7.2 (no duplicated CDP core, no
   reachable interactive gate in unattended mode, one report verdict, no stale
   "Make Opus behave like Fable"-only claims).
4. Root SKILL.md gate coverage equals the conductor catalog (CONTRACT §7.3).
5. README rebranded + SOURCES section linking docs/research/01 and 02;
   plugin.json at 2.0.0.
6. delivery/STATUS.md reflects final per-epic status; final report in
   .fable-it-reports/ with per-criterion evidence.

Constraints: do not re-litigate locked decisions (KICKOFF list); do not modify
docs/research/*; keep DevOtts authorship on all SKILL.md files; never mark a
test contract case passed without registered evidence.
```
