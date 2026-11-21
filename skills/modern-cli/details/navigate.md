# Jump to a frequently used directory: zoxide

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

Set up once in the shell's start-up file. For zsh the line is `eval "$(zoxide init zsh)"`: it
defines `z` and `zi` and records each directory you enter (the examples below use
`zoxide init posix --hook none`, which defines `z` the same way for `sh` but records nothing on
its own, so that each example controls its history with `zoxide add`).

`z word` jumps to the best match, and `zi word` chooses among the matches with fzf; both change
the directory of the interactive shell, so they cannot be shown with output. `zoxide query` prints
the match instead of jumping, and it only knows directories that were recorded (entered once with
the hook, or added with `zoxide add`):

```sh
# spec: CLI-ZOXIDE-01
zoxide query notes 2>/dev/null || echo "not recorded"
zoxide add notes
zoxide query notes | sed "s#.*/##"
```
```text
not recorded
notes
```

Several words must all appear in the path, in that order, and the last word must match the last
part of the path. Here `my proj` finds `my/project` (`my/projects/x` ends in `x`), `my x` finds
the other one, and the reversed order finds nothing:

```sh
mkdir -p my/project my/projects/x
zoxide add my/project
zoxide add my/projects/x
zoxide query my proj | sed "s#.*/##"
zoxide query my x | sed "s#.*/##"
zoxide query proj my 2>/dev/null || echo "no match"
```
```text
project
x
no match
```

Matches are ranked by how often and how recently each directory was recorded, so the same word
leads elsewhere once the history changes. `z` also leaves out the directory you are in, which
`zoxide query --exclude` shows:

```sh
# spec: CLI-ZOXIDE-04
mkdir -p a/lib b/lib
zoxide add a/lib; zoxide add b/lib; zoxide add b/lib
zoxide query lib | sed "s#$(pwd)/##"
zoxide add a/lib; zoxide add a/lib
zoxide query lib | sed "s#$(pwd)/##"
zoxide query --exclude "$(pwd)/a/lib" lib | sed "s#$(pwd)/##"
```
```text
b/lib
a/lib
b/lib
```

`z` itself also works like `cd` on a real path (`z ~/foo`, `z foo/`, `z ..`, `z -`), which needs
no history. `zoxide query` does not do that: it only searches the database, so a path that was
never recorded finds nothing:

```sh
# spec: CLI-ZOXIDE-02
eval "$(zoxide init posix --hook none)"
ROOT=$(pwd)
z notes
echo "${PWD#"$ROOT"/}"
z ..
[ "$PWD" = "$ROOT" ] && echo "back at the top"
zoxide query ./notes 2>/dev/null || echo "no match"
```
```text
notes
back at the top
no match
```

`zoxide import` brings in the data of another tool once, so that a history built elsewhere is not
lost. Its sources are listed by its help:

```sh
# spec: CLI-ZOXIDE-01
zoxide import --help | sed -n 10,16p
```
```text
Commands:
  atuin     Import from atuin
  autojump  Import from autojump
  fasd      Import from fasd
  z         Import from z
  z.lua     Import from z.lua
  zsh-z     Import from zsh-z
```

## Differences that change results

- **History based for keywords.** A keyword search only finds directories zoxide has recorded:
  those you entered since it was installed, added with `zoxide add`, or brought in with
  `zoxide import` from atuin, autojump, fasd, z, z.lua or zsh-z data. A new project is not found
  by keyword until you `cd` into it once.
- **Real paths work like `cd`.** The README says `z ~/foo`, `z foo/` and `z ..` work like a
  regular `cd`. The `z` function does this when it gets exactly one argument that `cd` accepts, so
  such a path needs no history; with no argument it goes to the home directory, and `z -` goes to
  the previous directory. `zoxide query` has no such rule.
- **A directory in the current directory wins.** Because of that rule, `z lib` goes to `./lib` if
  it exists, even when the history ranks another `lib` higher.
- **Ranking.** Matches are ranked by frecency (frequency and recency), so the same word can lead to
  different directories over time. `z` leaves out the directory you are in. `cd` always goes to
  the one path you typed.
- **A shell function.** `z` is defined by `zoxide init` in the interactive shell. It does not exist
  in a script or under `xargs`, so scripts use `zoxide query` or a full path.
- **No stack.** `z -` returns to the previous directory, like `cd -`; zoxide has no stack, so
  there is nothing like `pushd` and `popd`.

## When to keep the classic command

- Scripts: `cd` with an explicit path is deterministic, `z` depends on a history.
- Servers and containers where zoxide is not installed or its database is empty.
- When the directory is new (not recorded yet) or the path is short, and when a wrong jump would be costly
  (a deletion or a build in the wrong directory).

## Pitfalls

Do not put `z` in a script or a non-interactive command. It is not defined there, and its answer
changes with the history:

```sh bad
z notes
```
Resolve the directory once, then use the path:

```sh
# spec: CLI-ZOXIDE-05
z notes 2>/dev/null || echo "z is not defined here"
zoxide add notes
cd "$(zoxide query notes)" && basename "$PWD"
```
```text
z is not defined here
notes
```

A word that names a directory of the current directory does not search the history at all. With
`./lib` and a recorded `app/lib`, `z lib` goes to `./lib`:

```sh bad
z lib
```
The first command goes to `./lib`. Give a second word, or a path, to reach the recorded one (two words always search the history):

```sh
# spec: CLI-ZOXIDE-03
eval "$(zoxide init posix --hook none)"
ROOT=$(pwd)
mkdir -p app/lib lib
zoxide add app/lib
z lib
echo "${PWD#"$ROOT"/}"
cd "$ROOT"
z app lib
echo "${PWD#"$ROOT"/}"
```
```text
lib
app/lib
```

## Sources

- `b96090a5ddb86b38` zoxide
- `b24f2dbb9d888e27` GNU Bash manual
