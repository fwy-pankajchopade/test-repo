#!/bin/bash
# Usage: bash scripts/run-review.sh BUG-123
# Run this AFTER you have applied the fix, BEFORE raising the Bitbucket PR.
# It captures the current git diff and builds a review context for Copilot Chat.

TICKET_ID=$1

if [ -z "$TICKET_ID" ]; then
  echo "❌ Usage: bash scripts/run-review.sh <TICKET-ID>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🔎 Pre-PR Review Flow Starting...      ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"
echo ""

# Capture staged + unstaged changes relative to HEAD
GIT_DIFF_UNSTAGED=$(git diff HEAD 2>/dev/null)
GIT_DIFF_STAGED=$(git diff --cached HEAD 2>/dev/null)

if [ -n "$GIT_DIFF_STAGED" ] && [ -n "$GIT_DIFF_UNSTAGED" ]; then
  GIT_DIFF="${GIT_DIFF_STAGED}
${GIT_DIFF_UNSTAGED}"
elif [ -n "$GIT_DIFF_STAGED" ]; then
  GIT_DIFF="$GIT_DIFF_STAGED"
elif [ -n "$GIT_DIFF_UNSTAGED" ]; then
  GIT_DIFF="$GIT_DIFF_UNSTAGED"
else
  GIT_DIFF=$(git diff HEAD~1 HEAD 2>/dev/null)
fi

if [ -z "$GIT_DIFF" ]; then
  echo "⚠️  No diff detected. Make sure you have applied and saved the fix."
  echo "    If changes are committed, the diff is against HEAD~1."
  GIT_DIFF="No diff available — please paste your fix manually."
fi

# Load lessons learned
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null || echo "None yet.")

# Build review context file
mkdir -p outputs
REVIEW_FILE="outputs/${TICKET_ID}-review-context.md"

cat > "$REVIEW_FILE" << ENDOFCONTEXT
# Pre-PR Review Context: ${TICKET_ID}

## Ticket
$(cat "$TICKET_FILE")

## Proposed Fix (diff)
\`\`\`diff
${GIT_DIFF}
\`\`\`

## Known Risky Patterns
${LESSONS_CONTENT}

## Review Checklist (answer each)
1. Does it actually fix the root cause?
2. Does it introduce any regressions?
3. Are there missing null/edge case checks?
4. Does it follow the existing architecture?
5. Is it the MINIMAL change needed?
6. Does it violate any known risky patterns?

Rate the solution: **APPROVE / REVISE / REJECT**

If REVISE or REJECT, explain exactly what must change.
ENDOFCONTEXT

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Review context built"
echo "   File: $REVIEW_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Diff preview (first 40 lines):"
echo ""
echo "$GIT_DIFF" | head -40
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Option A — Copilot Chat review (IntelliJ):"
echo "    1. Open Copilot Chat in IntelliJ"
echo "    2. Paste contents of: $REVIEW_FILE"
echo "    3. Ask: 'Review this fix. Rate APPROVE / REVISE / REJECT.'"
echo ""
echo "  Option B — CLI review:"
if command -v gh &>/dev/null; then
  echo "    gh copilot suggest \"\$(cat $REVIEW_FILE)\""
else
  echo "    ⚠️  gh CLI not found. Install: https://cli.github.com"
fi
echo ""
echo "  After APPROVE → raise your Bitbucket PR"
echo "  After merge  → run: bash scripts/post-merge.sh $TICKET_ID"
echo ""
