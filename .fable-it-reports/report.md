# Fable-it Report — Save reports to `.fable-it-reports/` instead of repo root

Run window: 2026-06-25 → 2026-06-25   |   Approach: single

## DoD status
| # | Criterion | Status | Evidence / Blocker |
|---|-----------|--------|--------------------|
| 1 | Plugin skill report-location default is `.fable-it-reports/` (default line + Step 6 + credentials artifact) | VERIFIED | `plugins/fable-it/skills/fable-it/SKILL.md` lines 50, 168, 197 all updated; confirmed in merged diff. |
| 2 | Portable root `SKILL.md` and `README.md` document the new default consistently | VERIFIED | `SKILL.md:51` and `README.md:205` updated; confirmed in merged diff. |
| 3 | Committed on a feature branch, pushed, PR opened against main and merged | VERIFIED | Branch `feat/reports-folder` → PR [#4](https://github.com/DevOtts/fable-it/pull/4), state=MERGED (2026-06-25T14:29:12Z), fast-forwarded to `main` (commit `64a59d2`), branch deleted. |

## Could not be verified (and why)
- None. All targets were local files plus the GitHub repo (gh authenticated as DevOtts), all reachable.

## What changed
- `plugins/fable-it/skills/fable-it/SKILL.md` — report-location default, Step 6 delivery, and credentials-artifact location now point to `.fable-it-reports/`.
- `SKILL.md` (portable root) — getting-started default note updated.
- `README.md` — getting-started default note updated.

## Decisions made
- Default path is `.fable-it-reports/` at the **workspace root** (not repo root, not `.taskstate/`). Skill instructs the agent to create the folder if absent and tell the user the exact paths on completion.
- Did **not** add `.fable-it-reports/` to this repo's own `.gitignore` — this is the skill source repo and does not generate its own runs; adding it would be unrequested scope. Users `.gitignore` the folder in their own target projects at their discretion.

## Surprises / risks found
- The installed copy of the skill at `~/.claude/skills/fable-it` still carries the old "workspace root" text; the marketplace serves from this repo's `main`, so a reinstall/update picks up the change. No action needed unless you want the local install refreshed now.

## Recommended next actions
- Optionally re-pull/reinstall the plugin (`/plugin install fable-it@devotts`) to refresh the local copy with the merged change.

## Credentials
- No credentials were created this run; no credentials artifact written.
