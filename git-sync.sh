#!/usr/bin/env bash
# =============================================================================
# git-sync.sh — Push/Pull between your fork (origin) and the original author (upstream)
# Usage:
#   ./git-sync.sh push          Push your local changes to your fork
#   ./git-sync.sh pull          Pull latest updates from original author into your fork
#   ./git-sync.sh status        Show remote info and latest commits from both
# =============================================================================

set -e

ORIGIN_URL="https://github.com/Smiffeed/worldquant-miner"
UPSTREAM_URL="https://github.com/zhutoutoutousan/worldquant-miner"

case "$1" in

  push)
    echo "📤 Pushing your changes to YOUR fork (origin)..."
    git add .
    git status --short
    echo ""
    read -rp "Commit message: " MSG
    if [ -n "$MSG" ]; then
      git commit -m "$MSG"
    else
      echo "No message provided — skipping commit (will still push existing commits)."
    fi
    git push origin master
    echo ""
    echo "✅ Pushed to $ORIGIN_URL"
    ;;

  pull)
    echo "📥 Pulling updates FROM original author (upstream)..."
    git fetch upstream
    echo ""
    echo "🔍 New commits from upstream:"
    git log HEAD..upstream/master --oneline
    echo ""
    git merge upstream/master --no-edit
    echo ""
    echo "📤 Pushing merged updates to YOUR fork..."
    git push origin master
    echo ""
    echo "✅ Your fork is now up-to-date with $UPSTREAM_URL"
    ;;

  status)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔗 Remotes:"
    git remote -v
    echo ""
    echo "📌 Your fork — last 5 commits (origin/master):"
    git log origin/master --oneline -5
    echo ""
    echo "📌 Original author — last 5 commits (upstream/master):"
    git fetch upstream --quiet
    git log upstream/master --oneline -5
    echo ""
    echo "🔍 Commits you have that upstream doesn't:"
    git log upstream/master..HEAD --oneline
    echo ""
    echo "🔍 Upstream commits you don't have yet:"
    git log HEAD..upstream/master --oneline
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ;;

  *)
    echo "WorldQuant Miner Git Sync Tool"
    echo ""
    echo "Usage:"
    echo "  ./git-sync.sh push      Push your local changes to your fork"
    echo "  ./git-sync.sh pull      Pull upstream updates into your fork"
    echo "  ./git-sync.sh status    Show sync status between fork and upstream"
    echo ""
    echo "Remotes:"
    echo "  origin   = YOUR fork  → $ORIGIN_URL"
    echo "  upstream = original   → $UPSTREAM_URL"
    ;;

esac
