#!/bin/bash
# Usage: bash scripts/build-context.sh BUG-123 PaymentService.java
# Standalone context builder — use this to rebuild context without
# running gh copilot CLI steps (e.g., on first run or offline).

TICKET_ID=$1
FILE=$2

if [ -z "$TICKET_ID" ] || [ -z "$FILE" ]; then
  echo "❌ Usage: bash scripts/build-context.sh <TICKET-ID> <FileName.java>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"
FOUND_FILE=$(find . -name "$FILE" -not -path '*/test/*' -not -path '*/.git/*' | head -1)

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

if [ -z "$FOUND_FILE" ]; then
  echo "❌ File not found in project: $FILE"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🔧 Building Context File...            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"
echo "📄 File:   $FOUND_FILE"
echo ""

mkdir -p context outputs
CONTEXT_FILE="context/${TICKET_ID}-full-context.md"

# Cap file content at 400 lines (token discipline, total ~600 lines)
FILE_CONTENT=$(head -n 400 "$FOUND_FILE")
FILE_LINES=$(wc -l < "$FOUND_FILE")
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null | head -n 100 || echo "None yet.")
TICKET_CONTENT=$(cat "$TICKET_FILE")

cat > "$CONTEXT_FILE" << ENDOFCONTEXT
# Bug Fix Context: ${TICKET_ID}

## Ticket
${TICKET_CONTENT}

## File Under Investigation
> File: ${FOUND_FILE} (${FILE_LINES} lines total, showing first 400)

\`\`\`java
${FILE_CONTENT}
\`\`\`

## Known Risky Patterns
${LESSONS_CONTENT}

## Instructions For Copilot Chat
You are a senior Spring Boot engineer.
Fix the bug described in the ticket above.
Constraints:
- Minimal change only
- Backward compatible
- Follow existing patterns
- Add defensive null checks
- Do NOT change API contracts
ENDOFCONTEXT

CONTEXT_LINES=$(wc -l < "$CONTEXT_FILE")

echo "✅ Context file built: $CONTEXT_FILE"
echo "   Lines: $CONTEXT_LINES (target: ≤600)"
echo ""

if [ "$CONTEXT_LINES" -gt 600 ]; then
  echo "⚠️  Context exceeds 600 lines ($CONTEXT_LINES). Consider:"
  echo "    - Reducing the file to the relevant method/class only"
  echo "    - Trimming lessons-learned.md to the most relevant entries"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Open IntelliJ and the Copilot Chat panel"
echo "  2. Paste contents of: $CONTEXT_FILE"
echo "  3. Step 1 → /explain  (confirm root cause)"
echo "  4. Step 2 → /fix      (get minimal fix)"
echo "  5. Step 3 → /tests    (generate edge case tests)"
echo "  6. Apply fix manually"
echo "  7. bash scripts/run-review.sh $TICKET_ID"
echo ""
