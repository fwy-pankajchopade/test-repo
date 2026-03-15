# IntelliJ Live Templates Setup

Add these in IntelliJ → Settings → Editor → Live Templates → Create Group "Copilot"

## Template 1: copilotfix
Abbreviation: `.copilotfix`
Description: Copilot fix prompt
Template text:
```
/fix
Fix this bug with minimal change.
Constraints: backward compatible, follow existing patterns, add null checks, do not change API contracts.
```

---

## Template 2: copilotexplain
Abbreviation: `.copilotexplain`
Description: Copilot explain prompt
Template text:
```
/explain
Why would this code cause the bug described above? Identify the exact line.
```

---

## Template 3: copilottests
Abbreviation: `.copilottests`
Description: Copilot tests prompt
Template text:
```
/tests
Generate JUnit 5 tests covering:
- happy path
- boundary values (at threshold, below, above)
- null input handling
- exception scenarios
```

---

## How To Add Live Templates In IntelliJ

1. Open **Settings** (`Cmd+,` on macOS / `Ctrl+Alt+S` on Windows/Linux)
2. Navigate to **Editor → Live Templates**
3. Click **+** → **Template Group** → name it `Copilot`
4. With the `Copilot` group selected, click **+** → **Live Template**
5. Fill in:
   - **Abbreviation**: `.copilotfix` (or `.copilotexplain`, `.copilottests`)
   - **Description**: as above
   - **Template text**: paste the text above
6. Set **Applicable in**: `Other` (for Copilot Chat input field)
7. Click **OK**

## Usage

In the IntelliJ Copilot Chat input field:
- Type `.copilotfix` + `Tab` → expands to the fix prompt
- Type `.copilotexplain` + `Tab` → expands to the explain prompt
- Type `.copilottests` + `Tab` → expands to the tests prompt

Zero copy-paste. Zero context switching.
