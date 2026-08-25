#!/usr/bin/env bash
# Pre-flight checks before any checkpoint operation.
# Output: one line per finding as "ERROR|<msg>" or "WARNING|<msg>".
# Exit code: 0 = no errors (warnings allowed), 1 = at least one error.
# No external dependencies beyond git and bash (no jq, no python).

ERRORS=()
WARNINGS=()

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    ERRORS+=("Not a git repository. Ask the user before running 'git init'.")
    echo "ERROR|${ERRORS[0]}"
    exit 1
fi

if [ -z "$(git config user.name 2>/dev/null)" ] || [ -z "$(git config user.email 2>/dev/null)" ]; then
    WARNINGS+=("Git user.name or user.email is not set; the commit may fail or use a fallback identity.")
fi

if ! git remote get-url origin > /dev/null 2>&1; then
    WARNINGS+=("No remote 'origin' configured; the commit will stay local.")
fi

# Works on repos with zero commits: diff-index against HEAD fails there,
# so fall back to porcelain status which covers untracked files too.
if git rev-parse --verify HEAD > /dev/null 2>&1; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        WARNINGS+=("Pre-existing uncommitted changes detected; confirm with the user whether to include them.")
    fi
    STAGED=$(git diff --cached --name-only 2>/dev/null)
    if [ -n "$STAGED" ]; then
        WARNINGS+=("Staged changes already present; review 'git diff --cached' before adding more.")
    fi
else
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        WARNINGS+=("Repository has no commits yet; everything is uncommitted (first commit).")
    fi
fi

GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ -f "$GIT_DIR/MERGE_HEAD" ]; then
    ERRORS+=("Merge in progress; resolve conflicts before checkpointing.")
fi
if [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ]; then
    ERRORS+=("Rebase in progress; finish or abort it before checkpointing.")
fi

for e in "${ERRORS[@]}"; do echo "ERROR|$e"; done
for w in "${WARNINGS[@]}"; do echo "WARNING|$w"; done

[ ${#ERRORS[@]} -eq 0 ]
