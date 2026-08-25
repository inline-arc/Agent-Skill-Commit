---
name: agent-skill-commit
description: >
  Automatic checkpoint system for agent-assisted coding. Activates when the agent
  writes, edits, or refactors code. Prompts the user to commit and push meaningful
  changes at natural breakpoints (after completing a feature, before risky operations,
  when tests pass, or when user says 'checkpoint', 'save progress', 'commit', or 'push').
  Prevents lost work by ensuring good changes are backed up to GitHub/GitLab.
  The agent composes commit messages itself following the repo conventions.
  Do NOT use for non-coding tasks, documentation-only edits, or when the user
  explicitly says 'no commits' or 'draft mode'.
license: MIT
metadata:
  author: user
  version: "1.1"
  category: developer-tools
allowed-tools: Bash Read Glob Edit
---

# Agent Commit Skill — Checkpoint System

## Purpose
Prevent lost work during agent-assisted coding by prompting the user to commit and push
meaningful changes at the right moments. Acts as a safety net, not an autopilot.
The agent (LLM) always composes the commit message itself — there is no message-generation
script. Follow `references/git-convention.md` and `assets/commit-template.txt`.

## When to Trigger This Skill

Activate when:
- The agent completes a **functional feature, bug fix, or refactor**
- The agent finishes a **task that required 3+ file changes**
- The agent is about to perform a **risky operation** (major rewrite, dependency upgrade, deletion)
- The user explicitly says: **"checkpoint", "save", "commit", "push", "backup"**
- Tests pass after a significant change
- The agent has been working for **10+ turns** without any commit

Do NOT activate when:
- The user says **"draft mode"**, **"no commits"**, or **"WIP"**
- Only **documentation, comments, or config files** were changed (unless user asks)
- The change is **broken, incomplete, or failing tests**
- The task is **non-coding** (research, planning, data analysis)

## Workflow

### Step 1: Verify repo state
Run `scripts/verify-repo.sh`. It prints one finding per line and exits non-zero on blockers:
- `ERROR|...` — blocking problem (not a git repo, merge/rebase in progress). Stop and tell the user.
- `WARNING|...` — non-blocking issue (no remote, no git identity, pre-existing changes,
  repo has no commits yet). Surface these to the user.
The script works on repos with zero commits and needs only git + bash.

### Step 2: Summarize pending changes
Run `scripts/checkpoint.sh`. It runs the verification, then prints:
- `STATUS|blocked` — verification failed; do not continue.
- `STATUS|clean` — nothing to commit; tell the user and stop.
- `STATUS|pending_changes` followed by `git status --porcelain` output and a diff stat —
  this covers staged, modified, and untracked files.

If there are changes from BEFORE the agent started (check the verification warnings),
ask the user how to handle them: include, stash, or ignore.

### Step 3: Compose the commit message (agent-authored)
Write the message yourself based on the actual diff:
- Follow `references/git-convention.md` (Conventional Commits) and `assets/commit-template.txt`.
- Read `git diff` for the files you changed — do not guess from the file list alone.
- One logical change per commit; stage only the files the agent touched unless the user said otherwise.

### Step 4: Ask the user to confirm
Present the proposed message and the exact file list. Example:
> Checkpoint ready — 3 files changed. Proposed commit:
> `feat(parser): handle empty query strings`
> Commit and push? (yes / edit message / commit only / skip)

Never commit or push without explicit confirmation.

### Step 5: Commit and push
- Stage the agent-touched files and commit with the confirmed message:
  ```bash
  git add <files>
  git commit -m "<message>"
  ```
- Push only if `verify-repo.sh` reported a remote AND the user confirmed:
  ```bash
  GIT_TERMINAL_PROMPT=0 git ls-remote origin   # fail-fast auth probe (no 30s credential hang)
  git push
  ```
- If the auth probe fails (credentials missing), report it to the user instead of retrying.
- After pushing, report the commit hash (`git log --oneline -1`) so the user can verify on GitHub/GitLab.
