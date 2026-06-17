# Drop your reviewed `chrome-cdp-control` SKILL.md here

This directory must contain your `chrome-cdp-control` skill as `SKILL.md` (same folder name as
the skill `name` in its frontmatter). `fable-it` delegates to it by name.

Before committing, review the skill for anything machine-specific or private:
absolute paths, profile locations, tenant names, credentials filenames, internal
hostnames. Strip or parameterize them. `chrome-cdp-control` in particular drives a
real logged-in browser and likely encodes your local setup — review it closely.

If you choose NOT to ship one of these, `fable-it` still works: it degrades and runs
that phase inline (see the "If a delegated skill is not installed" rule in
`skills/fable-it/SKILL.md`), noting the absence in its report.

Delete this PLACEHOLDER.md once the real SKILL.md is in place.
