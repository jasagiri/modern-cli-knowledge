# Jump to a frequently used directory: zoxide

Status: 未検証 (not installed)

## Intent

Change directory by typing a part of the name, with the shell remembering which directories you
use most and most recently, instead of typing the full path.

## Classic and modern

| classic | modern |
|---|---|
| `cd /long/path/to/project` | `z project` |
| `cd -` | `z -` |
| `cd` then a list of candidates | `zi project` (interactive, needs fzf) |
| `pushd`, `popd` to return | `z` jumps by history, no stack |

## Commands

Set up once in the shell's start-up file (here zsh). This defines `z` and `zi` and records each
directory you enter:

```sh unverified
eval "$(zoxide init zsh)"
```

Jump to the best match for a word. Several words must all appear in the path, in that order:

```sh unverified
z project
z my proj
```

Choose among the matches interactively:

```sh unverified
zi project
```

Print the best match without changing directory, for use in a script or another command:

```sh unverified
zoxide query project
```

## Differences that change results

- **History based.** zoxide only knows directories you have entered since it was installed (or
  added with `zoxide add`). A new project is not found until you `cd` into it once.
- **Ranking.** Matches are ranked by frecency (frequency and recency), so the same word can lead to
  different directories over time. `cd` always goes to the one path you typed.
- **A shell function.** `z` is defined by `zoxide init` in the interactive shell. It does not exist
  in a script or under `xargs`, so scripts use `zoxide query` or a full path.
- **Several words.** `z a b` requires both words in the path, in order; the last word must
  match the last part of the path.
- **No stack.** `cd -` and `pushd`/`popd` return to the previous directory; zoxide has `z -` for the
  previous one, but no stack.

## When to keep the classic command

- Scripts: `cd` with an explicit path is deterministic, `z` depends on a history.
- Servers and containers where zoxide is not installed or its database is empty.
- When the directory is new or the path is short, and when a wrong jump would be costly
  (a deletion or a build in the wrong directory).

## Pitfalls

Do not put `z` in a script or a non-interactive command. It is not defined there, and its answer
changes with the history. Resolve the directory once, then use the path:

```sh unverified
cd "$(zoxide query project)"
```

## Sources

- `b96090a5ddb86b38` zoxide
- `e2b344d7c00bdbf6` GNU Bash manual
