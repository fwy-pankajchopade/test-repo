# Level 4 Bug Fix Workflow
## IntelliJ + Bitbucket + Copilot Pro + Copilot CLI

> One command. File opens in IntelliJ automatically. Three steps in Copilot Chat. PR raised.

---

## Setup (One Time)

```bash
git clone https://github.com/fwy-pankajchopade/test-repo.git
cd test-repo
bash setup.sh
source ~/.zshrc   # or: source ~/.bashrc
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
Ticket summary printed to terminal
Lessons-learned context shown
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
Apply fix manually (you are always in control)
         ↓
reviewfix BUG-123 → paste into Copilot Chat → APPROVE / REVISE / REJECT
         ↓
Raise Bitbucket PR
         ↓
postmerge BUG-123 → append new lesson to lessons-learned.md
```

---

## Folder Structure

```
├── tickets/               ← one .txt file per ticket (from Bitbucket)
│   └── BUG-123.txt        ← example ticket
├── prompts/               ← Copilot Chat prompt templates
│   ├── bug_fix_ticket_prompt.md
│   ├── feature_ticket_prompt.md
│   ├── review_ticket_prompt.md
│   └── intellij-live-templates.md
├── scripts/               ← automation scripts
│   ├── run-bug.sh         ← main bug fix entry point
│   ├── run-feature.sh     ← feature workflow
│   ├── run-review.sh      ← pre-PR review
│   ├── post-merge.sh      ← update lessons after merge
│   └── build-context.sh   ← standalone context builder
├── context/               ← auto-generated context files
│   └── lessons-learned.md ← cumulative risky-pattern knowledge base
├── outputs/               ← save Copilot Chat responses here
└── setup.sh               ← one-time setup
```

---

## Ticket Format

Create one file per ticket in `tickets/`:

```
tickets/BUG-123.txt
tickets/FEAT-456.txt
```

See `tickets/BUG-123.txt` for the full example format.

---

## IntelliJ Live Templates

See `prompts/intellij-live-templates.md` for zero-copy-paste shortcuts.

Type `.copilotfix` + **Tab** in Copilot Chat = instant fix prompt. No copy-paste required after setup.

---

## Tool Responsibilities

| Tool | Job | When |
|---|---|---|
| Copilot CLI (`gh copilot explain`) | Understand file fast | Automatically, before IntelliJ opens |
| Copilot CLI (`gh copilot suggest`) | Fix strategy (no code) | Automatically, before IntelliJ opens |
| IntelliJ Copilot Chat | `/explain` `/fix` `/tests` | During the fix, inside IntelliJ |
| IntelliJ Inline Copilot | Line-by-line completion | While manually writing the fix |
| `review_ticket_prompt.md` | Pre-PR quality gate | Before raising Bitbucket PR |
| `lessons-learned.md` | Feedback loop | After every merge — improves future fixes |

---

## Why This Is Level 4

| Criteria | Value |
|---|---|
| Steps to start a bug fix | 1 command |
| Copy-paste to Copilot Chat | Zero after IntelliJ setup |
| IDE you leave | Never — IntelliJ auto-opens |
| Token discipline | 600-line context cap |
| Feedback loop | `lessons-learned.md` grows with every fix |
| Control | Always manual — you apply every change |
| Works daily | Yes — no external dependencies beyond `gh` CLI |
