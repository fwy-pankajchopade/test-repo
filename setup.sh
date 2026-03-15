#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ⚡ Level 4 Workflow Setup             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Make scripts executable
chmod +x scripts/run-bug.sh
chmod +x scripts/run-feature.sh
chmod +x scripts/run-review.sh
chmod +x scripts/post-merge.sh
chmod +x scripts/build-context.sh

echo "✅ Scripts made executable"

# Ensure required directories exist
mkdir -p context outputs tickets
echo "✅ Directories ensured: context/ outputs/ tickets/"

# Add aliases (idempotent — only add if not already present)
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
  WORKFLOW_DIR=$(pwd)
  MARKER="# Level 4 Bug Fix Workflow"

  if grep -q "$MARKER" "$SHELL_RC" 2>/dev/null; then
    echo "✅ Aliases already present in $SHELL_RC (skipping)"
  else
    {
      echo ""
      echo "$MARKER"
      echo "alias bugfix='bash $WORKFLOW_DIR/scripts/run-bug.sh'"
      echo "alias featfix='bash $WORKFLOW_DIR/scripts/run-feature.sh'"
      echo "alias reviewfix='bash $WORKFLOW_DIR/scripts/run-review.sh'"
      echo "alias postmerge='bash $WORKFLOW_DIR/scripts/post-merge.sh'"
    } >> "$SHELL_RC"

    echo "✅ Aliases added to $SHELL_RC"
  fi

  echo ""
  echo "  Run: source $SHELL_RC"
  echo "  Then use:"
  echo "    bugfix BUG-123 PaymentService.java"
  echo "    featfix FEAT-456 payment-service"
  echo "    reviewfix BUG-123"
  echo "    postmerge BUG-123"
else
  echo "⚠️  Could not find .zshrc or .bashrc. Add aliases manually:"
  WORKFLOW_DIR=$(pwd)
  echo ""
  echo "  alias bugfix='bash $WORKFLOW_DIR/scripts/run-bug.sh'"
  echo "  alias featfix='bash $WORKFLOW_DIR/scripts/run-feature.sh'"
  echo "  alias reviewfix='bash $WORKFLOW_DIR/scripts/run-review.sh'"
  echo "  alias postmerge='bash $WORKFLOW_DIR/scripts/post-merge.sh'"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ Setup Complete. You are Level 4.   ║"
echo "╚══════════════════════════════════════════╝"
echo ""
