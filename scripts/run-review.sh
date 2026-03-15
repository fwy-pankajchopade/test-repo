#!/bin/bash
# Usage: bash scripts/run-review.sh BUG-123
# Run this AFTER you have the fix, BEFORE raising Bitbucket PR

TICKET_ID=$1

if [ -z "$TICKET_ID" ]; then
  echo "❌ Usage: bash scripts/run-review.sh <TICKET_ID>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"
CONTEXT_FILE="context/${TICKET_ID}-full-context.md"
OUTPUT_FILE="outputs/${TICKET_ID}-review.md"

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🔍 Pre-PR Review Starting...          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket:  $TICKET_ID"
echo ""

# Step 1: Get the current diff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 CURRENT DIFF (staged + unstaged changes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DIFF_OUTPUT=$(git --no-pager diff HEAD 2>/dev/null)
if [ -z "$DIFF_OUTPUT" ]; then
  DIFF_OUTPUT=$(git --no-pager diff --cached HEAD 2>/dev/null)
fi
if [ -z "$DIFF_OUTPUT" ]; then
  echo "⚠️  No uncommitted changes detected."
  echo "    If you have already committed, run: git diff HEAD~1"
  DIFF_OUTPUT="No diff available — changes may already be committed."
else
  echo "$DIFF_OUTPUT"
fi
echo ""

# Step 2: Show lessons-learned for review context
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 KNOWN RISKY PATTERNS (lessons-learned)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "context/lessons-learned.md" ]; then
  cat "context/lessons-learned.md"
else
  echo "No lessons learned yet."
fi
echo ""

# Step 3: Build review prompt file for Copilot Chat
mkdir -p outputs
REVIEW_PROMPT_FILE="prompts/review_ticket_prompt.md"
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null || echo "None yet.")

cat > "$OUTPUT_FILE" << EOF
# Pre-PR Review: $TICKET_ID

## Ticket Summary
$(cat "$TICKET_FILE")

## Proposed Fix (diff)
\`\`\`diff
$DIFF_OUTPUT
\`\`\`

## Known Risky Patterns
$LESSONS_CONTENT

## Review Checklist
You are a senior engineering reviewer.

Review the proposed fix above and check:
1. Does it actually fix the root cause?
2. Does it introduce any regressions?
3. Are there missing null/edge case checks?
4. Does it follow the existing architecture?
5. Is it the MINIMAL change needed?
6. Does it violate any known risky patterns?

Rate the solution: APPROVE / REVISE / REJECT

If REVISE or REJECT, explain exactly what must change.
EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Review prompt built: $OUTPUT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 4: Run Copilot CLI review
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 COPILOT CLI — REVIEW ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
gh copilot suggest "Review this code diff for a Spring Boot bug fix. Ticket: $(cat "$TICKET_FILE"). Diff: $DIFF_OUTPUT. Check: (1) fixes root cause, (2) no regressions, (3) null safety, (4) minimal change. Rate: APPROVE / REVISE / REJECT."
echo ""

echo "╔══════════════════════════════════════════╗"
echo "║   ✅ REVIEW COMPLETE                    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  📋 Paste $OUTPUT_FILE into Copilot Chat in IntelliJ"
echo "     for detailed APPROVE / REVISE / REJECT verdict"
echo ""
echo "  If APPROVED:"
echo "  1. Raise Bitbucket PR"
echo "  2. After merge: bash scripts/post-merge.sh $TICKET_ID"
echo ""
