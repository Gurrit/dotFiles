#!/bin/bash

set -e

CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

PROTECTED_BRANCHES=("master" "main" "develop" "staging" "$CURRENT_BRANCH")

echo "Fetching remote information"
git fetch --prune

echo "Finding branches to delete"

BRANCHES_TO_DELETE=()

for branch in $(git branch --format='%(refname:short)' | grep -v "^$CURRENT_BRANCH$"); do
    if [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${branch} " ]]; then
        echo "⚠️  Skipping protected branch: $branch"
        continue
    fi

    # Get the upstream branch for this local branch
    upstream=$(git rev-parse --abbrev-ref "$branch@{upstream}" 2>/dev/null || echo "")

    if [[ -z "$upstream" ]]; then
        echo "❌ $branch - No remote tracking branch"
        BRANCHES_TO_DELETE+=("$branch")
    else
        # Check if the remote branch exists
        if ! git show-ref --quiet --verify "refs/remotes/$upstream" 2>/dev/null; then
            echo "❌ $branch - Tracks non-existent remote: $upstream"
            BRANCHES_TO_DELETE+=("$branch")
        else
            echo "✅ $branch - Tracks existing remote: $upstream"
        fi
    fi
done

if [[ ${#BRANCHES_TO_DELETE[@]} -eq 0 ]]; then
    echo "No branches to delete! All local branches are properly tracked."
    exit 0
fi

echo "${#BRANCHES_TO_DELETE[@]} branch(es) to delete:"
for branch in "${BRANCHES_TO_DELETE[@]}"; do
    echo "  - $branch"
done

echo "Deleting branches..."

for branch in "${BRANCHES_TO_DELETE[@]}"; do
    echo "Deleting: $branch"
    git branch -D "$branch"
done

echo "✅ Cleanup complete! Deleted ${#BRANCHES_TO_DELETE[@]} branch(es)."