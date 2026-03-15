#!/bin/bash
# Usage: bash scripts/post-merge.sh BUG-123
# Run this AFTER merging your Bitbucket PR
# Updates lessons-learned.md with any new patterns discovered

TICKET_ID=$1

if [ -z "$TICKET_ID" ]; then
  echo "❌ Usage: bash scripts/post-merge.sh <TICKET_ID>"
  exit 1
fi

TICKET_FILE="tickets/${TICKET_ID}.txt"
LESSONS_FILE="context/lessons-learned.md"
TODAY=$(date +%Y-%m-%d)

if [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Ticket not found: $TICKET_FILE"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   📚 Post-Merge Lessons Update          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📋 Ticket: $TICKET_ID"
echo "📅 Date:   $TODAY"
echo ""

# Step 1: Show the ticket for context
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 TICKET SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$TICKET_FILE"
echo ""

# Step 2: Show recent diff for pattern discovery
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 MERGED CHANGES (last commit)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git --no-pager show --stat HEAD 2>/dev/null || echo "No recent commit found."
echo ""

# Step 3: Ask Copilot CLI to identify risky patterns
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 COPILOT CLI — PATTERN ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LAST_DIFF=$(git --no-pager show HEAD -- '*.java' 2>/dev/null | head -100)
if [ -n "$LAST_DIFF" ]; then
  gh copilot suggest "Analyze this merged bug fix diff and identify any risky patterns a developer should remember for future bugs. List as 2-3 concise bullet points. Diff: $LAST_DIFF"
else
  echo "No Java diff found in last commit."
fi
echo ""

# Step 4: Prompt developer to record the lesson
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✏️  ADD LESSON TO lessons-learned.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Enter a short lesson learned (or press Enter to skip):"
echo "  Example: Never use Optional.get() without isPresent()"
echo ""
printf "  Lesson: "
read -r LESSON

if [ -n "$LESSON" ]; then
  # Ensure lessons file exists
  if [ ! -f "$LESSONS_FILE" ]; then
    mkdir -p context
    cat > "$LESSONS_FILE" << 'HEADER'
# Lessons Learned — Risky Patterns

This file is appended after every bug fix merge.
It is automatically included in every future bug fix context.

## Template Entry Format
## YYYY-MM-DD — TICKET-ID
- Pattern discovered and why it is risky

---
HEADER
  fi

  # Append new lesson
  cat >> "$LESSONS_FILE" << EOF

## $TODAY — $TICKET_ID
- $LESSON
EOF

  echo ""
  echo "✅ Lesson added to $LESSONS_FILE"
else
  echo "⏭️  Skipped — no lesson recorded."
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ Post-Merge Complete                ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  lessons-learned.md is updated for future bug fixes."
echo "  Every future 'bugfix' command will include these patterns."
echo ""
