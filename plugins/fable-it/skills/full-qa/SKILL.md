---
name: full-qa
description: Generic autonomous QA suite for any project — reads a test plan (markdown file or inline spec), runs all tests using Chrome CDP + iterate cycles, fixes bugs found, and produces a final QA report. Works with any web stack. Trigger with /full-qa [path-to-test-plan.md]. Use before releases, after significant changes, or whenever you want a full system health check.
author: DevOtts
author_url: https://github.com/DevOtts
---

# /full-qa — Autonomous Full QA Suite

You are running an autonomous, project-agnostic QA pipeline. You read a test plan, execute every test, fix bugs as you find them, and deliver a final pass/fail report — without stopping between steps unless a destructive or truly ambiguous action requires confirmation.

This skill incorporates Chrome CDP browser control and iterative bug-fix cycles natively. You do not need to invoke `/chrome-cdp-control` or `/iterate` separately.

---

## Step 0 — INGEST THE TEST PLAN

**First action:** identify the test plan.

- If the user passed a file path (e.g., `/full-qa ./E2E-test-plan.md`), read that file immediately.
- If the user pasted tests inline, extract them from the conversation.
- If neither: ask the user ONE question: "Where is the test plan? Paste it or give me a file path."

From the test plan, extract:
1. **Service URLs** — all `localhost:PORT` or external URLs mentioned
2. **Auth credentials** — any test user emails/passwords
3. **Test cases** — each scenario with its ID, steps, and pass criteria
4. **Setup steps** — any DB resets, seed commands, or imports required before tests
5. **Stack info** — language, framework, DB type (for tailoring fix strategies)

If any of these are missing from the plan, infer reasonable defaults and state your assumptions before starting Phase 1.

---

## Phase 1 — PREFLIGHT

Verify every service the test plan references is alive. Do this **silently and fix anything that is down** before proceeding.

### 1.1 Service health checks

For each URL in the test plan:
```bash
curl -s -o /dev/null -w "%{http_code}" <SERVICE_URL>/health
# or if no /health endpoint:
curl -s -o /dev/null -w "%{http_code}" <SERVICE_URL>
```

Expected: 200 (or the status code the plan specifies). Any non-200 is a failure to investigate.

### 1.2 Chrome CDP check

```bash
curl -s http://localhost:9222/json/version | python3 -c "import sys,json; d=json.load(sys.stdin); print('Chrome:', d.get('Browser','?'))"
```

If CDP fails, output exactly this and stop:
> Chrome isn't running with remote debugging. Please launch it with:
> ```bash
> "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
>   --remote-debugging-port=9222 \
>   --user-data-dir="$HOME/.chrome-automation" \
>   --no-first-run &
> ```
> Then run /full-qa again.

### 1.3 Playwright check

```bash
python3 -c "import playwright; print('playwright ok')" 2>&1 || pip3 install playwright && python3 -m playwright install chromium
```

### 1.4 Preflight report

Print a compact table before moving on:
```
PREFLIGHT
  ✓ Service A  http://localhost:XXXX  200
  ✓ Service B  http://localhost:YYYY  200
  ✓ Chrome CDP  localhost:9222        Chrome/XXX
  ✗ Service C  http://localhost:ZZZZ  ECONNREFUSED  ← fixing...
```

Do not proceed to Phase 2 if any service is down after your fix attempt.

---

## Phase 2 — SETUP / CLEAN SLATE

Run any setup steps from the test plan: DB resets, seed imports, migrations, fixture loading.

If the test plan has no explicit setup steps, check for common patterns:
- `docker exec ... psql` (Postgres via Docker/Supabase)
- `npm run seed` / `yarn seed`
- `python manage.py migrate && loaddata`
- REST API seed endpoints (POST /seed, POST /admin/reset)

**Important:** If setup involves destructive operations (DROP, DELETE ALL, reset), print exactly what you're about to run and wait for a "yes" from the user before executing. Exception: if the test plan explicitly says "clean slate required", proceed without confirming.

After setup, verify the expected baseline state (row counts, seed user logins, etc.) using whatever the test plan specifies. If not specified, verify at minimum that auth works for the first test credential listed.

---

## Phase 3 — TEST EXECUTION

Run every test case from the plan, in order. For each test:

1. Print `▶ Running [TEST_ID] — [Test Name]`
2. Execute all steps (API calls, DB queries, or browser actions — see section below)
3. Evaluate pass/fail criteria
4. Print result: `✓ PASS [TEST_ID]` or `✗ FAIL [TEST_ID] — [reason]`
5. On FAIL: immediately enter the **Bug Fix Cycle** (Phase 4) before moving to the next test — unless the plan says to collect all failures first

### API-only tests (curl + DB)

Use `curl` for REST/GraphQL endpoints and `psql`/`sqlite3`/`mysql` for DB verification. Collect concrete evidence — response bodies and row counts — not assumptions.

### Browser tests (UI interactions)

Use this exact CDP loop. Every browser action follows this 5-step sequence — no exceptions:

**Step 1 — Screenshot** (see current state)
```bash
python3 << 'PYEOF'
import asyncio
from playwright.async_api import async_playwright

async def go():
    pw = await async_playwright().start()
    browser = await pw.chromium.connect_over_cdp('http://localhost:9222')
    ctx = browser.contexts[0]
    # Find target tab by URL fragment, never pages[0] blindly
    page = next((p for p in ctx.pages if "TARGET_FRAGMENT" in p.url), None)
    if page is None:
        page = await ctx.new_page()
        await page.goto("TARGET_URL", wait_until="domcontentloaded", timeout=30000)
    await page.screenshot(path="/tmp/qa_screenshot.png")
    print("Current URL:", page.url)
    await pw.stop()

asyncio.run(go())
PYEOF
```

**Step 2 — Decide** what single action to take based on current state.

**Step 3 — Execute** one action (navigate / click / type / evaluate).

**Step 4 — Screenshot again** to verify the action produced the expected state.

**Step 5 — Repeat** until the test scenario is complete.

#### Selector priority (use in this order, never use auto-generated CSS classes):
1. ARIA role: `page.get_by_role("button", name="Submit")`
2. Label/placeholder: `page.get_by_label("Email")`, `page.get_by_placeholder("Search...")`
3. Visible text: `page.get_by_text("Sign in", exact=True)`
4. Stable data attributes: `page.locator('[data-testid="submit-btn"]')`
5. Last resort: coordinate click via screenshot analysis

#### Wait strategy (prefer explicit over sleep):
1. `await page.wait_for_load_state("networkidle")` — after navigation
2. `await page.wait_for_selector("...", state="visible")` — before interaction
3. `await page.locator("...").wait_for()` — before reading
4. `await asyncio.sleep(N)` — only for animations, N < 2

#### Tab selection:
Always list tabs first to avoid the wrong-tab failure:
```python
for i, p in enumerate(ctx.pages):
    print(i, p.url, "|", await p.title())
```
Then match by URL substring. Never close a tab the test plan didn't authorize.

#### Failure protocol for browser actions:
- Take one more screenshot (page may be mid-render)
- Try one alternative selector
- If still failing after 2 attempts: record FAIL, document what was seen vs. expected, continue to next test
- NEVER loop "click → fail → click → fail" more than twice

### Destructive action gate

Before any test step that writes, deletes, posts, sends, submits, or modifies shared state **beyond the test environment**, STOP and confirm with the user. Tests within a local dev environment (localhost) do not require confirmation for write operations.

---

## Phase 4 — BUG FIX CYCLE

Triggered immediately on each FAIL. Follows the diagnosis → fix → test → evaluate loop.

### DIAGNOSE
```
DIAGNOSIS: <one sentence root cause>
HYPOTHESIS: <what I believe is happening>
EVIDENCE: <logs / DB query / screenshot / response body>
FIX PLAN: <minimal code change — file:line>
```

Rules:
- Read logs, check DB state, inspect API responses before touching code
- Form a hypothesis. Verify it with one targeted check before acting.
- Spawn an `Explore` subagent for broad codebase research (tracing data flows across >3 files). Keep yourself for reasoning.

### FIX
- Change only what the diagnosis identified — no refactoring, no "while I'm here" cleanups
- If fix spans multiple files, apply all before re-testing
- If fix requires a service restart, wait for the startup confirmation message before re-testing

### TEST
Re-run the specific test that failed. Collect concrete evidence:
| Task type | Verification method |
|-----------|-------------------|
| API route | `curl` the route, check response code + body |
| DB state | Query the specific table/row |
| UI behavior | Screenshot + check URL + check text content |
| Compilation | Run `tsc --noEmit` or the project's build command |

### EVALUATE
```
RESULT: PASS | FAIL | PARTIAL
EVIDENCE: <observed output>
REMAINING ISSUES: <if partial>
NEXT ACTION: continue tests | new diagnosis cycle | escalate to user
```

### Escalation rules
- After 3 distinct diagnosis attempts on the same bug → escalate to user with full diagnosis history
- If fix requires a product decision (e.g., "should this return 400 or silently default?") → escalate
- If fix requires a DB migration with DROP/ALTER → escalate before running

### Regression check
After fixing any bug: re-run any previously-PASS test that touches the same service/component. A fix that breaks something else is worse than a known failure.

---

## Phase 5 — EXPLORATORY TESTS

After all plan-specified tests complete, spawn an `Explore` subagent to find untested paths:

```
Explore subagent prompt:
"In [PROJECT_ROOT], identify likely bug-prone areas not covered by the existing tests.
Focus on:
- Unguarded edge cases in service/controller layers
- Missing error handling in critical flows  
- Data display issues in UI components
- Race conditions or state management issues

For each suspicious area, propose a concrete test (what to click or API to call),
the expected behavior, and the likely failure mode.
Return a ranked list of 5 tests with: ID, description, steps, expected result."
```

Implement the top 3-5 tests the subagent identifies. Apply the same PASS/FAIL pattern.

---

## Phase 6 — FINAL REPORT

When all tests complete (or you've exhausted fix cycles), output:

```
## QA Report — [Project Name] — [Date]

### Summary
| Metric | Count |
|--------|-------|
| Tests run | N |
| Passed | N |
| Failed | N |
| Bugs fixed | N |
| Exploratory tests | N |
| Deferred | N |

### Test Results
| ID  | Test Name | Result | Notes |
|-----|-----------|--------|-------|
| T01 | [Name]    | ✓ PASS | |
| T02 | [Name]    | ✗ FAIL | [what failed] |
| T03 | [Name]    | ⚠ SKIP | [reason] |

### Bugs Fixed
| # | File:Line | Description | Fix Applied |
|---|-----------|-------------|-------------|
| 1 | src/foo.ts:42 | [what broke] | [what changed] |

### Known Issues / Deferred
- [Item]: [why deferred — needs product decision / out of scope / requires manual action]

### Go-Live Readiness
**READY** / **NOT READY** — [one sentence verdict]
```

---

## Autonomy Rules

**Proceed without asking:**
- Running any test (curl, DB query, browser action) against localhost services
- Reading logs, source code, DB state
- Taking screenshots
- Applying code fixes for clearly-diagnosed bugs
- Restarting local services after a fix
- Creating test data (users, records, sessions) within the test environment

**Stop and confirm before:**
- Any write to a non-localhost / production service
- Running `DROP TABLE`, `DELETE FROM` without a WHERE, or other destructive DB commands that aren't part of an explicit seed/reset step in the test plan
- Pushing code changes (git push)
- Running migrations that alter shared schema structure (ADD COLUMN with NOT NULL default is ok, DROP COLUMN needs confirmation)
- Killing OS processes with `pkill` (exception: killing a service you just started for a resilience test)
- Taking any action on the user's logged-in accounts in external services

**Maximum autonomy:** Fix bugs without asking. Re-run tests without asking. Restart services without asking. Only escalate when you've genuinely tried 3 different approaches and are stuck, or when the fix requires a product decision.

---

## Quick Reference: Common Stack Commands

### Supabase / Postgres (Docker)
```bash
# DB query
docker exec supabase_db_supabase psql -U postgres -c "SELECT ..."
# Apply migration
docker exec -i supabase_db_supabase psql -U postgres < migration.sql
# Auth token
curl -s -X POST "http://127.0.0.1:54321/auth/v1/token?grant_type=password" \
  -H "apikey: <ANON_KEY>" -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

### Next.js
```bash
# Build check
cd <project> && npm run build 2>&1 | tail -20
# Type check
npx tsc --noEmit
# Logs (if running via pm2 or similar)
pm2 logs <app-name> --lines 50
```

### NestJS
```bash
# Health
curl -s http://localhost:PORT/health
# Logs
tail -50 <output-dir>/engine.log
```

### FastAPI / Python
```bash
# Health
curl -s http://127.0.0.1:PORT/health
# Start if down
cd <project> && python3 -m uvicorn main:app --host 127.0.0.1 --port PORT &
```

### Django / Rails / Laravel
```bash
# Django: python manage.py check; Rails: bin/rails db:migrate:status; Laravel: php artisan migrate:status
```

### Chrome CDP (canonical action template)
```bash
python3 << 'PYEOF'
import asyncio
from playwright.async_api import async_playwright

async def go():
    pw = await async_playwright().start()
    browser = await pw.chromium.connect_over_cdp('http://localhost:9222')
    ctx = browser.contexts[0]

    # List all tabs (always do this first)
    for i, p in enumerate(ctx.pages):
        print(i, p.url)

    # Find target tab by URL fragment
    page = next((p for p in ctx.pages if "TARGET_FRAGMENT" in p.url), None)
    if page is None:
        page = await ctx.new_page()
        await page.goto("TARGET_URL", wait_until="domcontentloaded", timeout=30000)

    # === ONE ACTION HERE ===

    await page.wait_for_load_state("networkidle", timeout=15000)
    await page.screenshot(path="/tmp/qa_action.png")
    print("OK:", page.url)
    await pw.stop()

asyncio.run(go())
PYEOF
```

---
_Authored by [DevOtts](https://github.com/DevOtts)._
