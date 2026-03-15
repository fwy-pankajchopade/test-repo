#!/bin/bash
# Usage: bash scripts/run-bug.sh BUG-123 PaymentService.java
# Or with alias: bugfix BUG-123 PaymentService.java

TICKET_ID=$1
FILE=$2

if [ -z "$TICKET_ID" ] || [ -z "$FILE" ]; then
  echo "❌ Usage: bugfix <TICKET-ID> <FileName.java>"
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
echo "║   🚀 Level 4 Bug Fix Flow Starting...    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"
echo "📄 File:   $FOUND_FILE"
echo ""

# Step 1: Show ticket summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 TICKET SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$TICKET_FILE"
echo ""

# Step 2: Append lessons-learned context
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 KNOWN RISKY PATTERNS (lessons-learned)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "context/lessons-learned.md" ]; then
  cat "context/lessons-learned.md"
else
  echo "No lessons learned yet."
fi
echo ""

# Step 3: CLI explains the file
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 COPILOT CLI — EXPLAINING: $FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v gh &>/dev/null; then
  gh copilot explain < "$FOUND_FILE"
else
  echo "⚠️  gh CLI not found. Install: https://cli.github.com"
  echo "    Then run: gh extension install github/gh-copilot"
fi
echo ""

# Step 4: CLI suggests fix strategy (not code — just strategy)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 COPILOT CLI — FIX STRATEGY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TICKET_SUMMARY=$(grep -A2 "## Summary" "$TICKET_FILE" 2>/dev/null | tail -1)
if command -v gh &>/dev/null && [ -n "$TICKET_SUMMARY" ]; then
  SUGGEST_PROMPT_FILE=$(mktemp /tmp/copilot-suggest-XXXXXX.txt)
  {
    printf 'Given this Java Spring Boot file:\n\n'
    cat "$FOUND_FILE"
    printf '\n\nThe bug is: %s\n' "$TICKET_SUMMARY"
    printf 'What is the minimal safe fix strategy? List in 3 bullet points only. Do not write code.\n'
  } > "$SUGGEST_PROMPT_FILE"
  gh copilot suggest < "$SUGGEST_PROMPT_FILE"
  rm -f "$SUGGEST_PROMPT_FILE"
elif ! command -v gh &>/dev/null; then
  echo "⚠️  gh CLI not found — skipping fix strategy step."
else
  echo "⚠️  No '## Summary' section found in $TICKET_FILE — skipping fix strategy step."
fi
echo ""

# Step 5: Build context file for IntelliJ Chat
mkdir -p context outputs
CONTEXT_FILE="context/${TICKET_ID}-full-context.md"

# Cap total context at ~600 lines (token discipline)
FILE_CONTENT=$(head -n 400 "$FOUND_FILE")
LESSONS_CONTENT=$(cat context/lessons-learned.md 2>/dev/null | head -n 100 || echo "None yet.")
TICKET_CONTENT=$(cat "$TICKET_FILE")

cat > "$CONTEXT_FILE" << ENDOFCONTEXT
# Bug Fix Context: ${TICKET_ID}

## Ticket
${TICKET_CONTENT}

## File Under Investigation
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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PHASE 1 COMPLETE — Context built"
echo "   Context saved: $CONTEXT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 6: Open file in IntelliJ automatically
echo "🚀 Opening $FILE in IntelliJ..."
idea "$FOUND_FILE" 2>/dev/null || \
  open -a "IntelliJ IDEA" "$FOUND_FILE" 2>/dev/null || \
  echo "⚠️  Could not auto-open IntelliJ. Open manually: $FOUND_FILE"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ NOW IN INTELLIJ — 3 STEPS ONLY     ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  1. Open Copilot Chat panel in IntelliJ"
echo "  2. Paste contents of: context/${TICKET_ID}-full-context.md"
echo ""
echo "  Step 1 → /explain  (confirm root cause)"
echo "  Step 2 → /fix      (get minimal fix)"
echo "  Step 3 → /tests    (generate edge case tests)"
echo ""
echo "  Then run: bash scripts/run-review.sh $TICKET_ID"
echo ""
