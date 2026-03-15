# Level 4 Bug Fix Workflow
## IntelliJ + Bitbucket + Copilot Pro + Copilot CLI

> One command. File opens in IntelliJ. Three steps in Copilot Chat. PR raised.

---

## Setup (One Time)

```bash
git clone https://github.com/fwy-pankajchopade/test-repo.git
cd test-repo
bash setup.sh
source ~/.zshrc  # or source ~/.bashrc
```

---

## Daily Usage

### Bug Fix
```bash
bugfix BUG-123 PaymentService.java
```

### Feature
```bash
featfix FEAT-456 payment-service
```

### Pre-PR Review
```bash
reviewfix BUG-123
```

### Post-Merge (update lessons)
```bash
postmerge BUG-123
```

---

## The Flow

```
bugfix BUG-123 PaymentService.java
         ↓
CLI explains the file (gh copilot explain)
CLI suggests fix strategy (gh copilot suggest)
         ↓
File auto-opens in IntelliJ
         ↓
Paste context/BUG-123-full-context.md into Copilot Chat
         ↓
Step 1: /explain → confirm root cause
Step 2: /fix     → get minimal fix
Step 3: /tests   → generate edge case tests
         ↓
Apply fix manually (you are in control)
         ↓
reviewfix BUG-123 → paste into Copilot Chat → APPROVE/REVISE/REJECT
         ↓
Raise Bitbucket PR
         ↓
postmerge BUG-123 → update lessons-learned.md
```

---

## Folder Structure

```
├── tickets/               ← one .txt file per ticket (from Bitbucket)
│   ├── BUG-123.txt        ← example bug ticket
│   └── FEAT-456.txt       ← example feature ticket
├── prompts/               ← Copilot Chat prompt templates
│   ├── bug_fix_ticket_prompt.md
│   ├── feature_ticket_prompt.md
│   ├── review_ticket_prompt.md
│   └── intellij-live-templates.md
├── scripts/               ← automation scripts
│   ├── run-bug.sh         ← main bug fix entry point
│   ├── run-feature.sh     ← feature ticket workflow
│   ├── run-review.sh      ← pre-PR review
│   ├── post-merge.sh      ← post-merge lessons update
│   └── build-context.sh   ← context builder utility
├── context/               ← auto-generated context files + lessons-learned.md
│   └── lessons-learned.md ← risky patterns discovered from past fixes
├── outputs/               ← save Copilot solutions and review results here
└── setup.sh               ← one-time idempotent setup
```

---

## IntelliJ Live Templates

See `prompts/intellij-live-templates.md` for zero-copy-paste shortcuts.

Type `.copilotfix` + `Tab` in Copilot Chat = instant fix prompt.
Type `.copilotexplain` + `Tab` = instant explain prompt.
Type `.copilottests` + `Tab` = instant test generation prompt.

---

## Tool Responsibilities

| Tool | Job | When |
|---|---|---|
| `gh copilot explain` | Understand the file fast | Before opening IntelliJ |
| `gh copilot suggest` | Get fix strategy (no code) | Before opening IntelliJ |
| IntelliJ Copilot Chat | `/explain` `/fix` `/tests` | During the fix |
| IntelliJ Inline Copilot | Line-by-line completion | While writing the fix |
| `review_ticket_prompt.md` | Pre-PR review | Before raising Bitbucket PR |
| `lessons-learned.md` | Feedback loop | After every merge |

---

## Adding a New Ticket

1. Create `tickets/YOUR-TICKET-ID.txt` using this format:

```
## Ticket: YOUR-TICKET-ID
## Summary
<one sentence description of the bug>

## Service
<service name>

## Steps To Reproduce
1. ...

## Expected Behavior
...

## Actual Behavior
...

## Suspected Root Cause
<file and method name>

## Constraints
- Do NOT modify <file>
- Backward compatible fix only

## Definition of Done
- Fix applied
- Tests pass
```

2. Run: `bugfix YOUR-TICKET-ID FileName.java`

---

## Why This Is Level 4

| Criteria | Status |
|---|---|
| Steps to start | 1 command |
| Copy-paste required | Zero (after setup) |
| Leaves IDE | No |
| Token discipline | 600-line cap on context |
| Feedback loop | `lessons-learned.md` updated after every merge |
| Works daily | Yes |
| Manual control | Developer applies fix — Copilot advises |
