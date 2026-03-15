# Lessons Learned — Risky Patterns

This file is appended after every bug fix merge.
It is automatically included in every future bug fix context.

## Template Entry Format
## YYYY-MM-DD — TICKET-ID
- Pattern discovered and why it is risky

---

## Examples (remove these after first real entry)

## 2026-01-01 — EXAMPLE
- Never use `Optional.get()` without `isPresent()` — causes prod NPEs
- `EmailService` is async — do not assume synchronous completion
- Repository uses soft deletes — always filter by `deleted_at IS NULL`
- Threshold checks using `>` instead of `>=` cause off-by-one bugs
