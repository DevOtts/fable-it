# plan-it v3 Research Brief (shared by all analyst agents)

## Mission
Fernando has been using the **plan-it** plugin (v2) all week across 4 Claude subscriptions.
We are comparing PLAN sessions with their EXECUTION sessions to find what the planning
phase failed to enforce, forgot, or could do better — inputs for **plan-it v3**.

## What plan-it v2 already does (don't re-propose these)
- ~10-phase pipeline: discovery → spec → agile split; pre-grounds the codebase first
- Fans out parallel research teams (xhigh) for independent subsystems
- Authors design docs in dependency order
- ONE batched human-decision gate (all decisions asked at once)
- Freezes a shared CONTRACT before squads write PRDs + epics against it
- Each epic ends in a BINDING Test Contract (≤ ~20 type-selected use-cases; build must pass 100%)
- Auto-sizes: single feature (1 design note + 1 PRD + 1 epic) → full program (7-doc set + 4 squads + waves)
- v2 deterministic core: explicit statechart (machine.json), run persists its position, gate-check + hook

## How to read a session
Transcript paths are in `/tmp/planit-v3-research/title-paths.txt` (format: `title :: /abs/path.jsonl`).
For EACH assigned session:
1. Distill it (NEVER read the .jsonl raw):
   `python3 ~/.claude/skills/read-chat/distill_session.py --distill="<transcript path>"`
   → prints JSON with a `digest` path (usually /tmp/read-chat-*.md)
2. Read the digest (chunked with offset/limit if large).

## Analysis rubric — for each PLAN → EXECUTION pair
Answer with EVIDENCE (quote file paths, epic IDs, error messages, user corrections):
1. **Plan fidelity**: did execution follow the plan? Where did it deviate and why?
2. **Late discoveries**: what did execution discover that planning SHOULD have caught
   (missing env/creds, unknown schema, undocumented dependency, wrong assumption about
   existing code, missing non-functional requirement, integration surprise)?
3. **Test Contract health**: were the epic Test Contracts used? Were they well-sized?
   Any cases untestable, trivially green, or missing critical scenarios? Did "done"
   claims get accepted without the contract passing?
4. **Human friction**: how many times did Fernando have to intervene mid-execution to
   clarify/redirect something the plan should have pinned down? Quote the interventions.
5. **Rework**: work thrown away or redone because the plan under/over-specified.
6. **Cross-session handoff**: did the execution session struggle to load the plan
   (missing context, ambiguous doc locations, contract not found, stale paths)?
7. **Wins to keep**: what plan artifacts demonstrably paid off (execution cited them)?

## Output contract (STRICT)
Write findings to `/tmp/planit-v3-research/findings-<YOUR-LETTER>.md`:
```
# Findings <LETTER>: <pair names>
## Pair: <plan-title> → <exec-title(s)>
### Verdict (1 line): plan quality grade A–F + why
### Evidence table: | # | rubric item | finding | evidence quote/path |
### Enhancement candidates (max 5 per pair):
- **EC-<letter><n>: <name>** — problem (evidence) → proposed plan-it mechanism → which phase it belongs to
```
End the file with a `## TL;DR` of ≤10 bullets. Facts only, no narration.
Final chat reply: just 5-bullet summary + confirmation the file is written.
