# Outputs

This directory stores Copilot Chat solutions and review results.

## Naming Convention

- `BUG-123-review.md` — pre-PR review output from `run-review.sh`
- `BUG-123-solution.md` — save your Copilot Chat /fix output here
- `FEAT-456-review.md` — pre-PR review for feature tickets

## Usage

After running `bash scripts/run-review.sh BUG-123`, the review prompt
is automatically saved here as `BUG-123-review.md`.

Paste this file into Copilot Chat in IntelliJ for APPROVE / REVISE / REJECT verdict.
