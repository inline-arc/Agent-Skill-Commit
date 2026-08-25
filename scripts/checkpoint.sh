#!/usr/bin/env bash
# Checkpoint orchestrator: verifies repo state and summarizes pending changes.
# It does NOT generate a commit message — the agent composes the message itself
# (see references/git-convention.md) and asks the user to confirm before committing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Pre-flight checks (runs from anywhere; path resolved relative to this script)
VERIFY=$("$SCRIPT_DIR/verify-repo.sh")
VERIFY_EXIT=$?
[ -n "$VERIFY" ] && echo "$VERIFY"
if [ $VERIFY_EXIT -ne 0 ]; then
    echo "STATUS|blocked"
    exit 1
fi

# 2. Pending changes — porcelain covers staged, modified, AND untracked files
CHANGED=$(git status --porcelain)
if [ -z "$CHANGED" ]; then
    echo "STATUS|clean"
    exit 0
fi

# 3. Summary for the agent to present to the user
echo "STATUS|pending_changes"
echo "CHANGED_FILES_BEGIN"
echo "$CHANGED"
echo "CHANGED_FILES_END"
echo "DIFF_STAT_BEGIN"
if git rev-parse --verify HEAD > /dev/null 2>&1; then
    git diff --stat HEAD
else
    echo "(no commits yet — all listed files are new)"
fi
echo "DIFF_STAT_END"
