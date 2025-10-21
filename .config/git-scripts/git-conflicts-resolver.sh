#!/bin/bash
# auto-resolve-rebase.sh

set -e

BRANCH=$(git branch --show-current)
TARGET="main"

echo "🔄 Fetching latest changes..."
git fetch origin

echo "📍 Current branch: $BRANCH"
echo "🎯 Target branch: $TARGET"

# Rebase with ours strategy
echo "⚡ Rebasing with local changes priority..."
git rebase origin/$TARGET -X ours || {
    echo "⚠  Conflicts detected. Auto-resolving..."

    # Keep all local changes
    git checkout --ours .
    git add -A

    # Continue rebase
    git rebase --continue || {
        # If still issues, skip and continue
        git rebase --skip
    }
}

# Force push
echo "🚀 Force pushing to origin/$BRANCH..."
git push -f origin $BRANCH

echo "✅ Done! Merge conflicts resolved."

╭─ ~/Tools ───────────────────────────────────────