#!/bin/bash
# resolve-conflicts.sh

set -e

BRANCH=$(git branch --show-current)

echo "Rebasing $BRANCH..."

# Rebase with ours strategy (keep local)
git rebase main -X ours || {
    # If conflicts occur
    git checkout --ours .
    git add .
    git rebase --continue
}

# Force push
git push -f origin $BRANCH

echo "✓ Conflicts resolved. Local changes kept."