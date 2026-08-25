# Commit Message Conventions

The agent composes commit messages itself following Conventional Commits.

## Format

```
<type>(<optional scope>): <short imperative subject>

<optional body — what and why, not how; wrap at 72 chars>

<optional footer — BREAKING CHANGE: ..., Refs: #123>
```

## Types

| Type       | Use for                                              |
|------------|------------------------------------------------------|
| `feat`     | New user-facing functionality                        |
| `fix`      | A bug fix                                            |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `docs`     | Documentation-only changes                           |
| `style`    | Formatting, whitespace — no code meaning change      |
| `perf`     | Performance improvement                              |
| `test`     | Adding or correcting tests                           |
| `build`    | Build system or external dependency changes          |
| `ci`       | CI configuration and scripts                         |
| `chore`    | Maintenance that doesn't modify src or tests         |
| `revert`   | Reverting a previous commit                          |

## Rules

- Subject line: imperative mood ("add", not "added"/"adds"), ≤ 72 chars, no trailing period.
- Scope: the module or area touched, e.g. `feat(auth):`, `fix(parser):`. Omit if unclear.
- Pick the type from the *primary intent* of the change, not from file extensions alone
  (a `.md` file inside a feature change does not make the commit `docs`).
- Multiple unrelated changes → suggest splitting into multiple commits.
- Checkpoint commits made during agent sessions still get a real, specific message —
  never "WIP", "changes", or "checkpoint".

## Examples

```
feat(search): rank results by recency

fix(api): return 400 on missing query param

The endpoint crashed with an unhandled KeyError; now validated up front.

chore: bump eslint to v9
```
