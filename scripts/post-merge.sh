#!/bin/bash
# Usage: bash scripts/post-merge.sh BUG-123
# Or with alias: postmerge BUG-123
# Run this AFTER your Bitbucket PR is merged.
# It prompts you to append new learnings to lessons-learned.md.

TICKET_ID=$1

if [ -z "$TICKET_ID" ]; then
  echo "❌ Usage: bash scripts/post-merge.sh <TICKET-ID>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"
LESSONS_FILE="context/lessons-learned.md"
TODAY=$(date +%Y-%m-%d)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   📚 Post-Merge Lessons Update           ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"
echo "📅 Date:   $TODAY"
echo ""

if [ ! -f "$TICKET_FILE" ]; then
  echo "⚠️  Ticket file not found: $TICKET_FILE"
  echo "    Continuing without ticket context."
fi

# Show current lessons-learned.md
if [ -f "$LESSONS_FILE" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📖 CURRENT LESSONS LEARNED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat "$LESSONS_FILE"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✍️  ADD NEW LESSON"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "What risky pattern did you discover in this fix?"
echo "(Press Enter twice when done, or type 'skip' to skip)"
echo ""

LESSON_TEXT=""
LINE_COUNT=0
BLANK_LINES=0

while IFS= read -r line; do
  if [ "$line" = "skip" ]; then
    LESSON_TEXT="skip"
    break
  fi

  if [ -z "$line" ]; then
    BLANK_LINES=$((BLANK_LINES + 1))
    if [ $BLANK_LINES -ge 2 ]; then
      break
    fi
  else
    BLANK_LINES=0
    LINE_COUNT=$((LINE_COUNT + 1))
  fi

  LESSON_TEXT="${LESSON_TEXT}
${line}"
done

if [ "$LESSON_TEXT" = "skip" ] || [ -z "$(echo "$LESSON_TEXT" | tr -d '[:space:]')" ]; then
  echo ""
  echo "⏭  Skipped — no new lesson added."
else
  # Append new lesson entry
  mkdir -p context
  cat >> "$LESSONS_FILE" << ENDOFLESSON

## ${TODAY} — ${TICKET_ID}
${LESSON_TEXT}
ENDOFLESSON

  echo ""
  echo "✅ Lesson appended to $LESSONS_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Commit updated lessons-learned.md:"
echo "     git add context/lessons-learned.md"
echo "     git commit -m 'docs: update lessons-learned after $TICKET_ID'"
echo ""
echo "  2. Archive the ticket (optional):"
echo "     mv tickets/${TICKET_ID}.txt tickets/done/${TICKET_ID}.txt"
echo ""
echo "  ✅ Workflow complete for $TICKET_ID"
echo ""
