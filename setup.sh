#!/bin/bash
# setup.sh — One-time setup for the Level 4 Bug Fix Workflow
# Safe to run multiple times (idempotent).

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ⚡ Level 4 Workflow Setup              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Make scripts executable ────────────────────────────────────────
chmod +x scripts/run-bug.sh
chmod +x scripts/run-feature.sh
chmod +x scripts/run-review.sh
chmod +x scripts/post-merge.sh
chmod +x scripts/build-context.sh
echo "✅ Scripts made executable"

# ── Step 2: Ensure required directories exist ───────────────────────────────
mkdir -p context outputs tickets
echo "✅ Directories ensured: context/ outputs/ tickets/"

# ── Step 3: Add shell aliases (idempotent — skip if already present) ────────
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
  WORKFLOW_DIR=$(pwd)
  MARKER="# Level 4 Bug Fix Workflow"

  if grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
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
  echo "⚠️  Could not find .zshrc or .bashrc."
  echo "   Add these aliases manually:"
  WORKFLOW_DIR=$(pwd)
  echo "   alias bugfix='bash $WORKFLOW_DIR/scripts/run-bug.sh'"
  echo "   alias featfix='bash $WORKFLOW_DIR/scripts/run-feature.sh'"
  echo "   alias reviewfix='bash $WORKFLOW_DIR/scripts/run-review.sh'"
  echo "   alias postmerge='bash $WORKFLOW_DIR/scripts/post-merge.sh'"
fi

# ── Step 4: Check optional dependencies ────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Dependency Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v gh &>/dev/null; then
  echo "✅ gh CLI found: $(gh --version | head -1)"
  if gh extension list 2>/dev/null | grep -q "gh-copilot"; then
    echo "✅ gh copilot extension found"
  else
    echo "⚠️  gh copilot extension not installed."
    echo "    Install: gh extension install github/gh-copilot"
  fi
else
  echo "⚠️  gh CLI not found."
  echo "    Install: https://cli.github.com"
  echo "    Then:    gh extension install github/gh-copilot"
fi

if command -v idea &>/dev/null; then
  echo "✅ IntelliJ 'idea' command found in PATH"
else
  echo "⚠️  IntelliJ 'idea' command not in PATH."
  echo "    In IntelliJ: Tools → Create Command-line Launcher"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅ Setup Complete. You are Level 4.    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
