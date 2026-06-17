---
name: chrome-cdp-control
description: Drive the user's real, logged-in Chrome browser via Chrome DevTools Protocol on localhost:9222 using Playwright. Trigger this skill when the user explicitly asks to "use my Chrome", "use my browser", "log into", "post on" (X, Reddit, LinkedIn, etc.), or any task that requires an authenticated session, persistent cookies, or bot-detection evasion that headless scraping cannot provide. Also trigger when the user references their CDP setup, their `~/.chrome-automation` profile, or asks Claude to manually walk through actions on a real site one step at a time. Do NOT use this skill for: simple unauthenticated content fetches (use `web_fetch`), bulk headless scraping (use a standalone Playwright script), or anything where a fresh Chromium instance would suffice. Do NOT use for tasks that can be solved by an API call to the same service.
author: DevOtts
author_url: https://github.com/DevOtts
---

# Chrome CDP Control

Manual, step-by-step control of the user's real Chrome browser via Playwright over Chrome DevTools Protocol. Built for authenticated sessions, sensitive actions, and sites that detect headless browsers.

---

## Operating principle

**This skill is a manual loop, not an automation framework.** One action, one screenshot, one decision. Never batch. Never loop unattended. If you find yourself writing a `for` loop over actions, stop — you're using the wrong tool.

---

## 0. Preflight (run at the start of every session)

Before any action, verify CDP is reachable:

```bash
curl -s http://localhost:9222/json/version
```

If this fails, **stop** and tell the user:

> Chrome isn't running with remote debugging. Relaunch it with:
> ```bash
> "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
>   --remote-debugging-port=9222 \
>   --user-data-dir="$HOME/.chrome-automation" \
>   --no-first-run &
> ```

Do not try to start Chrome yourself — the user launches it manually so they control which profile is exposed.

Also confirm Playwright is installed:

```bash
python3 -c "import playwright" 2>&1 || pip3 install playwright
```

---

## 1. The core loop

Every interaction follows this sequence — no exceptions:

1. **Screenshot** with `mcp__computer-use__screenshot` to see current state
2. **Decide** what single action moves the task forward
3. **Execute** one Playwright action via `python3 << 'PYEOF' ... PYEOF`
4. **Screenshot again** to verify the action produced the expected state
5. **Repeat**

If step 4 doesn't show what you expected, see the **Failure protocol** below.

---

## 2. Statelessness — read this carefully

**Each bash command is a fresh CDP connection.** No Python variables, page objects, or browser state persist between commands. Every action must:

- Re-import Playwright
- Re-connect to CDP
- Re-resolve the target tab
- Re-find the target element

Do not write code that assumes continuity from a previous command. There is no continuity.

---

## 3. Tab selection — never trust `pages[0]`

The user may have many tabs open. Picking the wrong one is the most common failure mode.

**Always list tabs first and match by URL substring:**

```python
python3 << 'PYEOF'
import asyncio
from playwright.async_api import async_playwright

async def go():
    pw = await async_playwright().start()
    browser = await pw.chromium.connect_over_cdp('http://localhost:9222')
    ctx = browser.contexts[0]
    for i, p in enumerate(ctx.pages):
        print(i, p.url, "|", await p.title())
    await pw.stop()

asyncio.run(go())
PYEOF
```

Then in subsequent actions, find the tab by URL match:

```python
target = next((p for p in ctx.pages if "x.com" in p.url), None)
if target is None:
    target = await ctx.new_page()
    await target.goto("https://x.com", wait_until="domcontentloaded")
```

**Never close a tab the user didn't ask you to close.** Closing tabs is a destructive action and falls under the gate in section 6.

---

## 4. Selector strategy — in priority order

Sites like X, Reddit, and LinkedIn ship obfuscated CSS classes that change between deploys. Use selectors in this order:

1. **ARIA role** — `page.get_by_role("button", name="Post")`
2. **Label / placeholder** — `page.get_by_label("Search")`, `page.get_by_placeholder("What's happening?")`
3. **Visible text** — `page.get_by_text("Sign in", exact=True)`
4. **Stable `data-*` attributes** — `page.locator('[data-testid="tweetButton"]')`
5. **Last resort: screenshot + computer-use coordinate click** — when the DOM is unreachable or React has shadow-rooted everything

**Forbidden**: auto-generated class names like `.css-1k2n3j4` or `.r-1loqt21`. They will break.

**When in doubt, inspect first:**

```python
# Print the accessible tree of a region to find the right selector
snapshot = await page.locator('main').aria_snapshot()
print(snapshot[:3000])
```

---

## 5. Waits — earn the wait, don't sleep blindly

Prefer in this order:

1. `await page.wait_for_load_state("networkidle")` — after navigation
2. `await page.wait_for_selector("...", state="visible")` — before interaction
3. `await page.locator("...").wait_for()` — before reading
4. `await asyncio.sleep(...)` — only for short animations (<1s) and only when nothing else works

`asyncio.sleep(2)` scattered through your actions is a smell. Replace with explicit waits.

---

## 6. Destructive action gate — MANDATORY

Before any of the following, **STOP**, summarize the exact action in plain language, and wait for the user to say "go" / "yes" / "do it":

- Posting, tweeting, replying, commenting
- Sending DMs or messages
- Liking, following, subscribing, joining
- Deleting anything
- Submitting forms (especially payment, signup, settings)
- Closing tabs
- Logging out
- Clicking anything labeled "Delete", "Remove", "Unfollow", "Block", "Pay", "Confirm", "Submit"
- Uploading files
- Any action that writes to a service the user is logged into

Format the confirmation like this:

> **About to:** Post the following tweet to the user's account on X:
> > "Testing the new SEMrush connector — domain resolution working end to end."
>
> **Confirm to proceed?**

No exceptions. Even if the user said "yes" to a similar action earlier in the conversation, re-confirm for each new write.

---

## 7. Failure protocol

If a screenshot after an action does **not** show the expected state:

1. **Take one more screenshot** — sometimes the page is mid-render
2. **Try one alternative selector** (e.g., role instead of text)
3. **If still failing: STOP.** Do not retry a third time. Report:
   - What you tried to do
   - What you see on screen now
   - What you expected to see
   - Two or three options for how to proceed

Common failure causes — check for these before retrying:
- CAPTCHA or bot challenge appeared → STOP, tell the user, do not attempt to solve
- Login wall / session expired → STOP, ask the user to log in manually
- Modal / cookie banner blocking the target → handle the modal first (with user's approval if it's destructive)
- Element re-rendered with new attributes → re-snapshot the DOM
- Wrong tab → list tabs, verify

**Never** loop "click → fail → click → fail" more than twice.

---

## 8. Clipboard pasting (macOS)

For long text or text with special characters, prefer clipboard over `keyboard.type`:

1. `mcp__computer-use__write_clipboard` with the text
2. Focus the target element via Playwright: `await page.locator('[contenteditable]').focus()`
3. Trigger paste: `await page.keyboard.press("Meta+v")`
4. Screenshot to verify

**Caveat:** OS-level focus must be on Chrome. If the user is in another app, the paste lands in the wrong window. When in doubt, ask the user to confirm Chrome is the foreground window.

---

## 9. Action log

For any session that touches a logged-in account, append a one-line audit entry per action:

```bash
echo "$(date -u +%FT%TZ) [chrome-cdp] $ACTION_DESCRIPTION" >> ~/.chrome-automation-actions.log
```

Cheap insurance. Helps debugging and gives the user a paper trail of what was done on their behalf.

---

## 10. Canonical action template

Use this exact wrapper for every Python action. Fill in the `=== ACTION ===` block.

```bash
python3 << 'PYEOF'
import asyncio
from playwright.async_api import async_playwright

async def go():
    pw = await async_playwright().start()
    browser = await pw.chromium.connect_over_cdp('http://localhost:9222')
    ctx = browser.contexts[0]

    # Find target tab by URL substring (NEVER pages[0] blindly)
    page = next((p for p in ctx.pages if "TARGET_URL_FRAGMENT" in p.url), None)
    if page is None:
        page = await ctx.new_page()
        await page.goto("https://TARGET_URL", wait_until="domcontentloaded", timeout=30000)

    # === ACTION ===
    # Exactly ONE of: navigate, click, type, evaluate, read
    # Example:
    await page.get_by_role("button", name="Post").click()
    # ==============

    # Verify with an explicit wait, not a sleep
    await page.wait_for_load_state("networkidle", timeout=10000)

    print("OK:", page.url)
    await pw.stop()

asyncio.run(go())
PYEOF
```

**JS inside `page.evaluate()`:** use double quotes for JS strings, since the outer wrapper is triple-double-quoted heredoc:

```python
await page.evaluate('document.querySelector("[contenteditable]").focus()')
```

---

## 11. Hard rules — never violate

- ❌ Never run a `for` loop over actions
- ❌ Never run more than ~20 actions in a session without checking in with the user
- ❌ Never solve CAPTCHAs or bot challenges
- ❌ Never close tabs the user didn't authorize
- ❌ Never retry a failed action more than twice
- ❌ Never skip the destructive action gate, even for "small" writes
- ❌ Never assume `pages[0]` is the right tab
- ❌ Never trust auto-generated CSS class names
- ✅ Always screenshot before and after every action
- ✅ Always preflight CDP at session start
- ✅ Always re-resolve page and elements (no state persists)
- ✅ Always log writes to `~/.chrome-automation-actions.log`

---

## 12. When NOT to use this skill

- Fetching public, unauthenticated content → use `web_fetch`
- Scraping hundreds of pages → use a standalone headless Playwright script outside this loop
- Anything the target service exposes via API → use the API (faster, safer, auditable)
- Anything that doesn't need the user's logged-in session

If you're not sure whether this skill applies, ask the user before connecting to CDP.

---
_Authored by [DevOtts](https://github.com/DevOtts)._
