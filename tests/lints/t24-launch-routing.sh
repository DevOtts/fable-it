#!/usr/bin/env bash
# T24 (E3, grep-lint): launch/SKILL.md team templates reference the spec §4.1 tier
# table (no divergent copy); default-inherit rule present; no remaining ad-hoc
# model labels outside the routing rule.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
F="$REPO/plugins/fable-it/skills/launch/SKILL.md"
fail=0
[ -f "$F" ] || { echo "FAIL: $F missing"; exit 1; }

# reference to the canonical table
if grep -q "03-enhancement-spec.md" "$F" && grep -q "§4.1" "$F"; then
  echo "ok: references canonical tier table (spec §4.1)"
else
  echo "FAIL: no reference to spec §4.1 tier table"; fail=1
fi

# no divergent copy: the table's distinctive row markers must not be duplicated here
if grep -qi "error-amplifying\|mechanical, low-ambiguity, high-volume" "$F"; then
  echo "FAIL: tier table appears copied into launch (drift risk)"; fail=1
else
  echo "ok: no copied tier table"
fi

# default-inherit rule present
if grep -qi "default.*inherit" "$F"; then
  echo "ok: default-inherit rule present"
else
  echo "FAIL: default-inherit rule missing"; fail=1
fi

# no ad-hoc model labels (the v1 pattern was "(Model: Sonnet/Opus)" / "([Model])")
adhoc=$(grep -n "(Model:\|(\[Model\])" "$F" || true)
if [ -z "$adhoc" ]; then
  echo "ok: no ad-hoc model labels"
else
  echo "FAIL: ad-hoc model labels remain:"; echo "$adhoc"; fail=1
fi

if [ $fail -eq 0 ]; then echo "T24 PASS"; else echo "T24 FAIL"; exit 1; fi
