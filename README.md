# Agent Skill Commit

**A skill for AI agents that checkpoints your work with meaningful commits — so you never lose progress.**

---

## Install

```bash
npx skill add https://github.com/inline-arc/Agent-Skill-Commit.git
```

---

## How It Helps Your Agent

When coding with an AI agent, work happens fast — files get edited, features get built, bugs get fixed. The problem: if you don't commit, you lose everything when something goes wrong.

This skill teaches your agent to:

- **Detect natural breakpoints** — feature done, tests pass, about to do something risky
- **Check repo safety** — catches merge conflicts, missing git identity, dirty state
- **Write proper commit messages** — follows Conventional Commits, never "WIP" or "updates"
- **Ask before committing** — you review and confirm, always in control

---

## Usage

Just say a trigger word while your agent is working:

| Say This | What Happens |
|----------|--------------|
| `checkpoint` | Agent summarizes changes, proposes a commit |
| `save` | Same as checkpoint |
| `commit` | Proposes commit with conventional message |
| `push` | Commits and pushes to remote |
| `backup` | Commits and pushes |

The agent will show you what changed and ask: **"Commit and push?"** — then wait for your answer.

---

## Workflow

1. Agent writes or edits code
2. You say **"checkpoint"**
3. Agent runs `verify-repo.sh` to check for issues
4. Agent runs `checkpoint.sh` to list all changes
5. Agent proposes a commit message and waits for your confirmation

---

## Use Cases

- **Long sessions** — checkpoint after 10+ turns so nothing is lost
- **Before risky changes** — backup before rewrites or upgrades
- **Team projects** — clean commit history that CI understands
- **New contributors** — proper commits without knowing git conventions
