#!/bin/bash
# Usage: bash scripts/run-feature.sh FEAT-456 payment-service
# Or with alias: featfix FEAT-456 payment-service

TICKET_ID=$1
SERVICE=$2

if [ -z "$TICKET_ID" ] || [ -z "$SERVICE" ]; then
  echo "❌ Usage: featfix <TICKET_ID> <service-name>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

# Find service directory
SERVICE_DIR=$(find . -type d -name "$SERVICE" -not -path '*/.git/*' | head -1)
if [ -z "$SERVICE_DIR" ]; then
  echo "⚠️  Service directory not found for: $SERVICE"
  echo "    Continuing with ticket only..."
  SERVICE_DIR="."
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   🚀 Level 4 Feature Flow Starting...   ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket:  $TICKET_ID"
echo "📦 Service: $SERVICE ($SERVICE_DIR)"
echo ""

# Step 1: Show ticket
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 FEATURE TICKET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$TICKET_FILE"
echo ""

# Step 2: Show existing architecture
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  SERVICE STRUCTURE: $SERVICE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
find "$SERVICE_DIR" -name "*.java" -not -path '*/.git/*' | head -30
echo ""

# Step 3: Build context file for IntelliJ Chat
mkdir -p context outputs
CONTEXT_FILE="context/${TICKET_ID}-full-context.md"
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null || echo "None yet.")

# Collect key service files (cap at 600 lines total for token discipline)
JAVA_FILES=$(find "$SERVICE_DIR" -name "*.java" -not -path '*/test/*' -not -path '*/.git/*' | head -5)
FILE_CONTENTS=""
LINE_COUNT=0
for f in $JAVA_FILES; do
  LINES=$(wc -l < "$f")
  if [ $((LINE_COUNT + LINES)) -lt 600 ]; then
    FILE_CONTENTS="${FILE_CONTENTS}
### $(basename "$f")
\`\`\`java
$(cat "$f")
\`\`\`
"
    LINE_COUNT=$((LINE_COUNT + LINES))
  fi
done

cat > "$CONTEXT_FILE" << EOF
# Feature Context: $TICKET_ID

## Ticket
$(cat "$TICKET_FILE")

## Service: $SERVICE
$FILE_CONTENTS

## Known Risky Patterns
$LESSONS_CONTENT

## Instructions For Copilot Chat
You are a senior Spring Boot engineer implementing a feature.
Follow the feature_ticket_prompt.md constraints:
- Follow existing architecture patterns
- Maintain backward compatibility
- Avoid unnecessary refactoring
- Keep implementation modular
- Identify: Controller / Service / Repository / DTO changes needed
EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Feature context built: $CONTEXT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 4: Open IntelliJ
echo "🚀 Opening service in IntelliJ..."
idea "$SERVICE_DIR" 2>/dev/null || \
  open -a "IntelliJ IDEA" "$SERVICE_DIR" 2>/dev/null || \
  echo "⚠️  Could not auto-open IntelliJ. Open manually: $SERVICE_DIR"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ NOW IN INTELLIJ — 3 STEPS ONLY     ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Open Copilot Chat panel in IntelliJ"
echo "  Paste: context/${TICKET_ID}-full-context.md"
echo ""
echo "  Step 1 → /explain  (understand existing architecture)"
echo "  Step 2 → /fix      (get implementation plan)"
echo "  Step 3 → /tests    (generate integration tests)"
echo ""
echo "  Then: bash scripts/run-review.sh $TICKET_ID"
echo ""
