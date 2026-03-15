# Lessons Learned — Risky Patterns

This file is appended after every bug fix merge.
It is automatically included in every future bug fix context so that
Copilot Chat is aware of your team's known failure modes.

Run `bash scripts/post-merge.sh <TICKET-ID>` to add a new entry after each merge.

## Entry Format
```
## YYYY-MM-DD — TICKET-ID
- Pattern discovered and why it is risky
```

---

## Examples (replace with real entries after your first fix)

## 2026-01-01 — EXAMPLE
- Never use `Optional.get()` without `isPresent()` — causes prod NPEs
- `EmailService` is async — do not assume synchronous completion in callers
- Repository uses soft deletes — always filter by `deleted_at IS NULL`
- Threshold checks using `>` instead of `>=` cause off-by-one boundary bugs
- `@Transactional` on private methods is silently ignored by Spring AOP
- Avoid `new Date()` — use `LocalDateTime.now()` for timezone safety
