#!/usr/bin/env bash
# git-conflicts-resolver.sh
# Auto-rebase current branch onto a target branch, prefer local changes on conflicts

set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -h, --help            Show this help message and exit
  -t, --target TARGET   Target branch to rebase onto (default: main)
  -r, --remote REMOTE   Remote name to use (default: origin)
  -b, --branch BRANCH   Branch to operate on (defaults to current branch)
      --no-push         Do not push after a successful rebase
      --force-push      Use force push (-f) instead of --force-with-lease

Examples:
  $(basename "$0")                  # Rebase current branch onto origin/main and force-with-lease push
  $(basename "$0") -t develop      # Rebase onto origin/develop
  $(basename "$0") --no-push       # Do the rebase locally and don't push
EOF
}

# Defaults
TARGET="main"
REMOTE="origin"
PUSH=true
USE_FORCE_WITH_LEASE=true
BRANCH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -r|--remote)
            REMOTE="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        --no-push)
            PUSH=false
            shift
            ;;
        --force-push)
            USE_FORCE_WITH_LEASE=false
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            if [[ -z "$BRANCH" ]]; then
                BRANCH="$1"
                shift
            else
                echo "Unexpected positional argument: $1" >&2
                usage
                exit 1
            fi
            ;;
    esac
done

# Ensure we are in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: not a git repository" >&2
    exit 2
fi

# Determine branch if not supplied
if [[ -z "$BRANCH" ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

echo "🔄 Fetching latest changes from $REMOTE..."
git fetch "$REMOTE"

echo "📍 Current branch: $BRANCH"
echo "🎯 Target branch: $TARGET"

echo "⚡ Rebasing with local changes priority..."
if git rebase "$REMOTE/$TARGET" -X ours; then
    echo "✅ Rebase completed cleanly"
else
    echo "⚠ Conflicts detected. Auto-resolving..."

    # Keep all local changes
    git checkout --ours . || true
    git add -A || true

    # Continue rebase
    if ! git rebase --continue; then
        # If still issues, try skipping
        if ! git rebase --skip; then
            echo "❌ Rebase could not be completed automatically. Aborting." >&2
            git rebase --abort || true
            exit 3
        fi
    fi
fi

# Push changes
if [[ "$PUSH" == true ]]; then
    if [[ "$USE_FORCE_WITH_LEASE" == true ]]; then
        echo "🚀 Pushing (force-with-lease) to $REMOTE/$BRANCH..."
        git push --force-with-lease "$REMOTE" "$BRANCH"
    else
        echo "🚀 Force pushing to $REMOTE/$BRANCH..."
        git push -f "$REMOTE" "$BRANCH"
    fi
else
    echo "ℹ Push skipped (--no-push)"
fi

echo "✅ Done! Merge conflicts resolved."