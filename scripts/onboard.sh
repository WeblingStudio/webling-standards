#!/usr/bin/env bash
# Webling Studio developer onboarding script.
# Clones the webling-config repo to ~/.webling and configures the webling-claude alias.
# Safe to run multiple times — all steps are idempotent.

set -euo pipefail

REPO_URL="git@github.com:WeblingStudio/webling-config.git"
INSTALL_DIR="$HOME/.webling"
ALIAS_DEF="alias webling-claude='git -C ~/.webling pull --quiet && claude --append-system-prompt-file ~/.webling/CONVENTIONS.md'"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}✔${NC}  $*"; }
warning() { echo -e "${YELLOW}!${NC}  $*"; }
error()   { echo -e "${RED}✘${NC}  $*" >&2; exit 1; }

# ── Dependency checks ─────────────────────────────────────────────────────────
command -v git  >/dev/null 2>&1 || error "git is required but not installed."
command -v claude >/dev/null 2>&1 || warning "claude CLI not found — install it before using webling-claude."

# ── Clone or update repo ──────────────────────────────────────────────────────
if [ -d "$INSTALL_DIR/.git" ]; then
  info "Updating existing repo at $INSTALL_DIR"
  git -C "$INSTALL_DIR" pull --quiet
else
  info "Cloning webling-config to $INSTALL_DIR"
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# ── Detect shell rc file ──────────────────────────────────────────────────────
if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "${BASH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "bash" ]; then
  RC_FILE="$HOME/.bashrc"
else
  warning "Unknown shell. Add the following alias to your shell rc file manually:"
  echo "  $ALIAS_DEF"
  exit 0
fi

# ── Add alias if not already present ─────────────────────────────────────────
if grep -qF "webling-claude" "$RC_FILE" 2>/dev/null; then
  info "webling-claude alias already present in $RC_FILE"
else
  {
    echo ""
    echo "# Webling Studio — Claude Code with shared conventions"
    echo "$ALIAS_DEF"
  } >> "$RC_FILE"
  info "Added webling-claude alias to $RC_FILE"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Onboarding complete.${NC}"
echo ""
echo "  Next steps:"
echo "  1. Reload your shell:  source $RC_FILE"
echo "  2. Start Claude with Webling conventions:  webling-claude"
echo ""
