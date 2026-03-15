# IntelliJ Live Templates Setup

Add these in IntelliJ → **Settings → Editor → Live Templates → Create Group "Copilot"**

Each template lets you type a short abbreviation + **Tab** to expand a full Copilot Chat prompt.
No copy-paste needed after initial setup.

---

## Template 1: copilotfix

| Field | Value |
|---|---|
| **Abbreviation** | `.copilotfix` |
| **Description** | Copilot fix prompt |
| **Applicable in** | Any file (or Copilot Chat input) |

**Template text:**
```
/fix
Fix this bug with minimal change.
Constraints: backward compatible, follow existing patterns, add null checks, do not change API contracts.
```

---

## Template 2: copilotexplain

| Field | Value |
|---|---|
| **Abbreviation** | `.copilotexplain` |
| **Description** | Copilot explain prompt |
| **Applicable in** | Any file (or Copilot Chat input) |

**Template text:**
```
/explain
Why would this code cause the bug described above? Identify the exact method and line.
```

---

## Template 3: copilottests

| Field | Value |
|---|---|
| **Abbreviation** | `.copilottests` |
| **Description** | Copilot tests prompt |
| **Applicable in** | Any file (or Copilot Chat input) |

**Template text:**
```
/tests
Generate JUnit 5 tests covering:
- happy path
- boundary values (at threshold, below, above)
- null input handling
- exception scenarios
```

---

## Template 4: copilotreview

| Field | Value |
|---|---|
| **Abbreviation** | `.copilotreview` |
| **Description** | Copilot pre-PR review prompt |
| **Applicable in** | Any file (or Copilot Chat input) |

**Template text:**
```
You are a senior engineering reviewer.
Review the diff I will paste. Check:
1. Does it fix the root cause?
2. Any regressions?
3. Missing null/edge cases?
4. Follows existing architecture?
5. Is it the minimal change?
Rate: APPROVE / REVISE / REJECT
```

---

## How to Add Live Templates in IntelliJ

1. Open **Settings** (`Cmd+,` on macOS / `Ctrl+Alt+S` on Windows/Linux)
2. Navigate to **Editor → Live Templates**
3. Click **+** → **Template Group** → name it `Copilot`
4. Select the `Copilot` group → click **+** → **Live Template**
5. Fill in:
   - **Abbreviation**: `.copilotfix` (etc.)
   - **Description**: as above
   - **Template text**: paste the template text above
6. Set **Applicable in**: `Other` (works in Copilot Chat input box)
7. Click **OK** → **Apply**

After setup: type `.copilotfix` + **Tab** in Copilot Chat = instant prompt. Zero copy-paste.
