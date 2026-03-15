# Review Ticket Prompt

You are a senior engineering reviewer.

Review the following proposed fix and check:
1. Does it actually fix the root cause?
2. Does it introduce any regressions?
3. Are there missing null/edge case checks?
4. Does it follow the existing architecture?
5. Is it the MINIMAL change needed?
6. Does it violate any known risky patterns?

Rate the solution: APPROVE / REVISE / REJECT

If REVISE or REJECT, explain exactly what must change.

---

Known Risky Patterns:
{{lessons-learned.md}}

---

Proposed Fix (diff):
```diff
{{diff}}
```

---

Output format:

## Verdict
APPROVE / REVISE / REJECT

## Root Cause — Fixed?
(yes/no + explanation)

## Regressions Introduced
(list any, or "None detected")

## Missing Checks
(list any null/edge cases not handled)

## Architecture Compliance
(does it follow existing patterns?)

## Minimality
(is this the smallest possible change?)

## Risky Pattern Violations
(does it violate anything in lessons-learned.md?)

## Required Changes (if REVISE or REJECT)
(exact list of what must be changed before this can be approved)
