# 🏗️ test-repo — Level 4 AI Bug Fix & Feature Workflow

> **One command. File opens in IntelliJ automatically. Three steps in Copilot Chat. PR raised.**

**Stack:** IntelliJ IDEA + Bitbucket + GitHub Copilot Pro + Copilot CLI

---

## 🎯 What Is This Repo?

This is a **developer productivity toolkit** — not an application. It gives every developer on the team a **single command** to start any bug fix or feature, with:

- ✅ AI-powered file explanation (Copilot CLI)
- ✅ AI-suggested fix strategy (Copilot CLI)
- ✅ Auto-generated context file for IntelliJ Copilot Chat
- ✅ Pre-PR review gate (APPROVE / REVISE / REJECT)
- ✅ Lessons-learned feedback loop (gets smarter every merge)

---

## 🗺️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPER MACHINE                            │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │  Terminal    │    │  Copilot CLI │    │  IntelliJ IDEA   │  │
│  │  (bugfix...) │───▶│  (explain +  │───▶│  Copilot Chat    │  │
│  │              │    │   suggest)   │    │  (/explain /fix) │  │
│  └──────────────┘    └──────────────┘    └──────────────────┘  │
│         │                                        │             │
│         ▼                                        ▼             │
│  ┌──────────────┐                    ┌──────────────────────┐  │
│  │  tickets/    │                    │  context/            │  │
│  │  BUG-123.txt │                    │  BUG-123-context.md  │  │
│  └──────────────┘                    └──────────────────────┘  │
│                                               │                │
│                                               ▼                │
│                                   ┌──────────────────────┐     │
│                                   │  Bitbucket PR Raised │     │
│                                   └──────────────────────┘     │
│                                               │                │
│                                               ▼                │
│                                   ┌──────────────────────┐     │
│                                   │  lessons-learned.md  │     │
│                                   │  (grows every merge) │     │
│                                   └──────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Folder Structure

```
test-repo/
│
├── 📂 tickets/                  ← INPUT: One file per Bitbucket ticket
│   └── BUG-123.txt              ← Summary, steps to reproduce, expected vs actual
│
├── 📂 scripts/                  ← AUTOMATION: Shell scripts (the brain)
│   ├── run-bug.sh               ← bugfix command
│   ├── run-feature.sh           ← featfix command
│   ├── run-review.sh            ← reviewfix command
│   ├── post-merge.sh            ← postmerge command
│   └── build-context.sh        ← rebuild context offline
│
├── 📂 prompts/                  ← AI PROMPTS: Templates for Copilot Chat
│   ├── bug_fix_ticket_prompt.md
│   ├── feature_ticket_prompt.md
│   ├── review_ticket_prompt.md
│   └── intellij-live-templates.md  ← IntelliJ Tab-expand shortcuts
│
├── 📂 context/                  ← AUTO-GENERATED: One context file per ticket
│   └── lessons-learned.md      ← Cumulative risky patterns (grows every PR)
│
├── 📂 outputs/                  ← SAVE HERE: Copilot Chat responses
│
├── setup.sh                     ← One-time setup for macOS / Linux
├── setup.ps1                    ← One-time setup for Windows / PowerShell
└── .gitattributes               ← Enforces LF line endings for all .sh files
```

---

## 🖥️ Setup (One Time)

### ⚠️ Windows (PowerShell)

```powershell
git clone https://github.com/fwy-pankajchopade/test-repo.git
cd test-repo
.\setup.ps1
. $PROFILE
```

### 🍎 macOS / Linux

```bash
git clone https://github.com/fwy-pankajchopade/test-repo.git
cd test-repo
bash setup.sh && source ~/.zshrc
```

---

## 🚀 Daily Usage

| Command | What It Does |
|---|---|
| `bugfix BUG-123 PaymentService.java` | Full bug fix flow |
| `featfix FEAT-456 payment-service` | Feature workflow |
| `reviewfix BUG-123` | Pre-PR review gate |
| `postmerge BUG-123` | Append lesson after merge |

---

## ⚙️ Scripts Deep-Dive

### 1️⃣ `scripts/run-bug.sh` → `bugfix` command

```bash
bugfix BUG-123 PaymentService.java
```

| Step | Action |
|---|---|
| 1 | Reads `tickets/BUG-123.txt` and prints ticket summary |
| 2 | Shows `context/lessons-learned.md` (known risky patterns) |
| 3 | Runs `copilot explain` on the file (AI explains the code) |
| 4 | Runs `copilot suggest` for fix strategy (no code — strategy only) |
| 5 | Builds `context/BUG-123-full-context.md` (capped at 600 lines) |
| 6 | Auto-opens the file in **IntelliJ** (`idea` command) |

---

### 2️⃣ `scripts/run-feature.sh` → `featfix` command

```bash
featfix FEAT-456 payment-service
```

- Reads the feature ticket
- Discovers all `.java` files in the named service (max 50 files)
- Shows lessons-learned context
- Builds a full context file with architecture snapshot for IntelliJ Chat

---

### 3️⃣ `scripts/run-review.sh` → `reviewfix` command

```bash
reviewfix BUG-123
```

- Captures `git diff` (staged + unstaged changes)
- Builds `outputs/BUG-123-review-context.md`
- Includes a **6-point review checklist** for Copilot Chat:
  1. Does it actually fix the root cause?
  2. Does it introduce any regressions?
  3. Are there missing null/edge case checks?
  4. Does it follow the existing architecture?
  5. Is it the MINIMAL change needed?
  6. Does it violate any known risky patterns?
- Returns: **APPROVE / REVISE / REJECT**

---

### 4️⃣ `scripts/post-merge.sh` → `postmerge` command

```bash
postmerge BUG-123
```

- Shows the current `lessons-learned.md`
- Prompts: *"What risky pattern did you discover?"*
- Appends your answer to `context/lessons-learned.md` with today's date
- This file is **auto-injected** into every future bug fix context — the system gets smarter over time!

---

### 5️⃣ `scripts/build-context.sh` — Offline Context Builder

```bash
bash scripts/build-context.sh BUG-123 PaymentService.java
```

- Same as `bugfix` but **without** the Copilot CLI steps
- Use when offline or to rebuild context without re-running AI steps
- Enforces the **600-line token discipline** (first 400 lines of file + 100 lines of lessons)

---

## 📝 Prompts (Copilot Chat Templates)

| File | Used When | Purpose |
|---|---|---|
| `bug_fix_ticket_prompt.md` | IntelliJ Copilot Chat | `/explain` → `/fix` → root cause + minimal fix |
| `feature_ticket_prompt.md` | IntelliJ Copilot Chat | Implementation plan + files to modify + API example |
| `review_ticket_prompt.md` | IntelliJ Copilot Chat | APPROVE / REVISE / REJECT gate with structured output |
| `intellij-live-templates.md` | IntelliJ Settings | Tab-expand shortcuts — zero copy-paste |

### ⚡ IntelliJ Live Templates Setup

Set up once in **IntelliJ → Settings → Editor → Live Templates → Group: Copilot**:

| Type This | Press | Expands To |
|---|---|---|
| `.copilotfix` | **Tab** | Full `/fix` prompt with constraints |
| `.copilotexplain` | **Tab** | Full `/explain` prompt |
| `.copilottests` | **Tab** | Full `/tests` prompt (JUnit 5) |
| `.copilotreview` | **Tab** | Full review prompt |

See [`prompts/intellij-live-templates.md`](prompts/intellij-live-templates.md) for step-by-step setup guide.

---

## 🔄 Full End-to-End Workflow

```
Developer runs:  bugfix BUG-123 PaymentService.java
                          │
              ┌───────────▼───────────┐
              │  Terminal Output:     │
              │  • Ticket printed     │
              │  • Lessons shown      │
              │  • Copilot explains   │
              │  • Fix strategy shown │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  context/BUG-123-     │
              │  full-context.md      │
              │  (built, ≤600 lines)  │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  IntelliJ auto-opens  │
              │  PaymentService.java  │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  In Copilot Chat:     │
              │  1. /explain (why?)   │
              │  2. /fix (minimal)    │
              │  3. /tests (JUnit 5)  │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  Developer applies    │
              │  fix manually         │
              │  (full control)       │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  reviewfix BUG-123    │
              │  → paste into Chat    │
              │  → APPROVE / REVISE / │
              │    REJECT             │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  Raise Bitbucket PR   │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  postmerge BUG-123    │
              │  → append lesson to   │
              │  lessons-learned.md   │
              └───────────────────────┘
```

---

## 🔧 Tool Responsibilities

| Tool | Job | When |
|---|---|---|
| Copilot CLI (`copilot explain`) | Understand file fast | Automatically, before IntelliJ opens |
| Copilot CLI (`copilot suggest`) | Fix strategy (no code) | Automatically, before IntelliJ opens |
| IntelliJ Copilot Chat | `/explain` `/fix` `/tests` | During the fix, inside IntelliJ |
| IntelliJ Inline Copilot | Line-by-line completion | While manually writing the fix |
| `review_ticket_prompt.md` | Pre-PR quality gate | Before raising Bitbucket PR |
| `lessons-learned.md` | Feedback loop | After every merge — improves future fixes |

---

## 🧠 Key Design Principles

| Principle | How It's Applied |
|---|---|
| **Developer is always in control** | No automation applies code — developer manually applies every fix |
| **Token discipline** | Context capped at 600 lines — AI gets relevant, focused context |
| **Feedback loop** | `lessons-learned.md` grows with every merged PR |
| **Cross-platform** | `setup.sh` for Mac/Linux, `setup.ps1` for Windows |
| **Works with both CLIs** | Scripts try `copilot` first, fall back to `gh copilot` |
| **Idempotent setup** | Running setup multiple times is safe — no duplicate aliases |

---

## 🏆 Why This Is Level 4

| Criteria | Value |
|---|---|
| Steps to start a bug fix | **1 command** |
| Copy-paste to Copilot Chat | **Zero** after IntelliJ setup |
| IDE you leave | **Never** — IntelliJ auto-opens |
| Token discipline | 600-line context cap |
| Feedback loop | `lessons-learned.md` grows with every fix |
| Control | Always manual — you apply every change |
| Works daily | Yes — no external dependencies beyond `copilot` CLI |

---

## 📋 Ticket Format

Create one `.txt` file per ticket in `tickets/`:

```
tickets/BUG-123.txt
tickets/FEAT-456.txt
```

See `tickets/BUG-123.txt` for the full example format.

---

> 📂 **Repo:** [github.com/fwy-pankajchopade/test-repo](https://github.com/fwy-pankajchopade/test-repo)