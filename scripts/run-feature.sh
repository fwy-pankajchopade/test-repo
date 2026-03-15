#!/bin/bash
# Usage: bash scripts/run-feature.sh FEAT-456 payment-service
# Or with alias: featfix FEAT-456 payment-service

TICKET_ID=$1
SERVICE=$2

if [ -z "$TICKET_ID" ] || [ -z "$SERVICE" ]; then
  echo "❌ Usage: featfix <TICKET-ID> <service-name>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🚀 Level 4 Feature Flow Starting...    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket:  $TICKET_ID"
echo "📦 Service: $SERVICE"
echo ""

# Step 1: Show ticket summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 TICKET SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$TICKET_FILE"
echo ""

# Step 2: Discover service files (cap at 50 for token discipline)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗂  SERVICE FILES DISCOVERED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SERVICE_FILES=$(find . -path "*${SERVICE}*" -name "*.java" \
  -not -path '*/.git/*' \
  -not -path '*/test/*' \
  -not -path '*/target/*' \
  2>/dev/null | head -50)

if [ -z "$SERVICE_FILES" ]; then
  echo "⚠️  No Java files found for service: $SERVICE"
  echo "    Make sure the service directory or file name matches."
else
  echo "$SERVICE_FILES"
fi
echo ""

# Step 3: Show lessons-learned context
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 KNOWN RISKY PATTERNS (lessons-learned)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "context/lessons-learned.md" ]; then
  cat "context/lessons-learned.md"
else
  echo "No lessons learned yet."
fi
echo ""

# Step 4: Build context file for IntelliJ Chat
mkdir -p context outputs
CONTEXT_FILE="context/${TICKET_ID}-full-context.md"

TICKET_CONTENT=$(cat "$TICKET_FILE")
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null | head -n 100 || echo "None yet.")

# Build file listing with first 50 lines of each (token discipline)
FILES_SNAPSHOT=""
if [ -n "$SERVICE_FILES" ]; then
  while IFS= read -r f; do
    FILES_SNAPSHOT="${FILES_SNAPSHOT}
### ${f}
\`\`\`java
$(head -n 50 "$f")
\`\`\`
"
  done <<< "$SERVICE_FILES"
fi

cat > "$CONTEXT_FILE" << ENDOFCONTEXT
# Feature Context: ${TICKET_ID}

## Ticket
${TICKET_CONTENT}

## Service: ${SERVICE}
${FILES_SNAPSHOT}

## Known Risky Patterns
${LESSONS_CONTENT}

## Instructions For Copilot Chat
You are a senior Spring Boot engineer implementing a new feature.
Follow the requirements in the ticket above.
Constraints:
- Follow existing architecture patterns
- Maintain backward compatibility
- Avoid unnecessary refactoring
- Keep implementation modular
- Minimal safe code additions only
- Do NOT touch unrelated files

Output format:
## Implementation Plan
## Files To Modify
## Code Changes
## API Example
## Testing Strategy
ENDOFCONTEXT

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PHASE 1 COMPLETE — Context built"
echo "   Context saved: $CONTEXT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 5: Open service directory in IntelliJ
FIRST_FILE=$(echo "$SERVICE_FILES" | head -1)
if [ -n "$FIRST_FILE" ]; then
  echo "🚀 Opening ${SERVICE} in IntelliJ..."
  idea "$FIRST_FILE" 2>/dev/null || \
    open -a "IntelliJ IDEA" "$FIRST_FILE" 2>/dev/null || \
    echo "⚠️  Could not auto-open IntelliJ. Open manually: $FIRST_FILE"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ NOW IN INTELLIJ — 3 STEPS ONLY     ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  1. Open Copilot Chat panel in IntelliJ"
echo "  2. Paste contents of: context/${TICKET_ID}-full-context.md"
echo ""
echo "  Step 1 → /explain  (understand current architecture)"
echo "  Step 2 → /fix      (get implementation plan + code)"
echo "  Step 3 → /tests    (generate unit + integration tests)"
echo ""
echo "  Then run: bash scripts/run-review.sh $TICKET_ID"
echo ""
