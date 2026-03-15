#!/bin/bash
# Usage: bash scripts/build-context.sh BUG-123 [optional/path/to/file.java]
# Builds a context file for Copilot Chat WITHOUT running the full workflow
# Useful for pre-flight checks before writing a structured issue

TICKET_ID=$1
SPECIFIC_FILE=$2

if [ -z "$TICKET_ID" ]; then
  echo "❌ Usage: bash scripts/build-context.sh <TICKET_ID> [file.java]"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

mkdir -p context outputs

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🔨 Building Context File...           ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"

CONTEXT_FILE="context/${TICKET_ID}-full-context.md"
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null || echo "None yet.")
FILE_SECTION=""

# If a specific file is given, find and include it
if [ -n "$SPECIFIC_FILE" ]; then
  FOUND_FILE=$(find . -name "$SPECIFIC_FILE" -not -path '*/test/*' -not -path '*/.git/*' | head -1)
  if [ -n "$FOUND_FILE" ]; then
    echo "📄 File:   $FOUND_FILE"
    FILE_CONTENT=$(head -600 "$FOUND_FILE")
    FILE_SECTION="## File Under Investigation
\`\`\`java
$FILE_CONTENT
\`\`\`"
  else
    echo "⚠️  File not found: $SPECIFIC_FILE — building context without file content."
  fi
fi

cat > "$CONTEXT_FILE" << EOF
# Bug Fix Context: $TICKET_ID

## Ticket
$(cat "$TICKET_FILE")

$FILE_SECTION

## Known Risky Patterns
$LESSONS_CONTENT

## Instructions For Copilot Chat
You are a senior Spring Boot engineer.
Fix the bug described in the ticket above.
Constraints:
- Minimal change only
- Backward compatible
- Follow existing patterns
- Add defensive null checks
- Do NOT change API contracts
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Context file built: $CONTEXT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Next steps:"
echo "  1. Review: cat $CONTEXT_FILE"
echo "  2. Use as prompt in Copilot Chat (IntelliJ)"
echo "  3. Or run the full flow: bash scripts/run-bug.sh $TICKET_ID <FileName.java>"
echo ""
