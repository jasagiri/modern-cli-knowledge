# Pick from a list by fuzzy matching: fzf

## Intent

Narrow a list of lines (file names, search hits, history) to the ones that match what you type,
ranked by how well they match, either by choosing in a terminal or, in scripts, with `--filter`.

## Classic and modern

| classic | modern |
|---|---|
| `grep PATTERN list.txt` | `fzf --filter PATTERN < list.txt` |
| `grep -F PATTERN list.txt` | `fzf -e --filter PATTERN < list.txt` |
| `grep -v PATTERN list.txt` | `fzf --filter '!PATTERN' < list.txt` |
| `history \| grep PATTERN` | Ctrl-R in the shell (interactive) |
| `find . -type f \| grep PATTERN` | `fd -t f \| fzf --filter PATTERN` |

Interactive use is not run on this page, because it needs a terminal. In a shell with the fzf
integration loaded, Ctrl-R searches the command history, Ctrl-T inserts a chosen file path and
Alt-C changes into a chosen directory (on macOS Terminal and iTerm2 the Option key does not send
Meta by default: enable that in the terminal's settings, or press Esc and then c). `fzf --preview 'bat --color=always {}'` shows a preview
of the highlighted line beside the list, and `--multi` lets Tab mark several lines. The examples
below use `--filter`, which prints the matching lines and exits without a terminal.

## Commands

Keep the lines that match a word. The list comes from `fd`, sorted so that the input order is fixed:

```sh
# spec: CLI-FZF-06
fd -t f . | sort | fzf --filter todo
```
```text
notes/todo.txt
```

Several terms separated by spaces must all match (AND), in any order:

```sh
# spec: CLI-FZF-02
fd -t f . | sort | fzf --filter 'src nim'
```
```text
src/main.nim
src/util.nim
```

A backslash keeps a space inside one term, in the default fuzzy mode and with `-e` alike. Without
it, `g n` is two terms and also matches `config/app.json`; a leading `'` only makes the first term
exact:

```sh
# spec: CLI-FZF-03
fd -t f . | sort | fzf --filter 'g\ n'
echo ---
fd -t f . | sort | fzf --filter "'g n"
echo ---
fd -t f . | sort | fzf -e --filter 'meeting\ notes'
```
```text
notes/meeting notes.txt
---
notes/meeting notes.txt
config/app.json
config/app.yaml
---
notes/meeting notes.txt
```

A bar with a space on each side (` | `) means OR: lines that match either term.

```sh
# spec: CLI-FZF-01
fd -t f . | sort | fzf --filter 'todo | main'
```
```text
src/main.nim
notes/todo.txt
```

By default the match is fuzzy: the characters only have to appear in order, not next to each
other. `mnn` matches `src/main.nim` and `notes/meeting notes.txt`. With `-e` (exact) the same
query matches nothing, and the status is 1:

```sh
# spec: CLI-FZF-01
fd -t f . | sort | fzf --filter mnn
```
```text
src/main.nim
notes/meeting notes.txt
```
```sh
# spec: CLI-FZF-01 CLI-FZF-08
# exit: 1
fd -t f . | sort | fzf -e --filter mnn
```
```text
```

The output is ordered by match score, not by input order. Here `foo` comes first because it is
the shortest line with the best match, and the fuzzy hit `fxoxo` comes after `foo bar`.
`--no-sort` keeps the input order, and `grep` (no fuzzy matches) always does:

```sh
# spec: CLI-FZF-04
printf 'xxfoo\nfoo bar\nfoo\nfxoxo\n' | fzf --filter foo
```
```text
foo
foo bar
fxoxo
xxfoo
```
```sh
# spec: CLI-FZF-04
printf 'xxfoo\nfoo bar\nfoo\nfxoxo\n' | fzf --filter foo --no-sort
```
```text
xxfoo
foo bar
foo
fxoxo
```

Matching is case-insensitive unless the query has an uppercase letter (smart case):

```sh
# spec: CLI-FZF-05
printf 'README.md\nreadme.txt\n' | fzf --filter readme
echo ---
printf 'README.md\nreadme.txt\n' | fzf --filter README
```
```text
README.md
readme.txt
---
README.md
```

Anchors and negation: `^` matches the start, `$` the end, `!` excludes. A term that starts
with `'` or is used with `-e` is exact. Here, lines under `src/` that do not contain `.py`:

```sh
fd -t f . | sort | fzf --filter '^src !.py'
```
```text
src/main.nim
src/util.nim
```

File names with spaces or non-ASCII characters stay intact when the list is separated by NUL
(`--read0` for input, `--print0` for output) and the consumer reads NUL (`xargs -0`):

```sh
# spec: CLI-FZF-07
fd -t f -0 . notes | fzf --read0 --print0 --filter 日本 | xargs -0 cat
```
```text
メモ: TODO を減らす
```

## Differences that change results

- **Fuzzy by default.** `grep` matches the pattern literally (or as a regex); fzf matches any line
  that contains the characters in order, so a short query returns lines grep would not. Use `-e`
  for substring matching. `--filter` always treats the query as fzf syntax, not as a regex:
  `.` is a plain character and ` | ` (a bar with spaces on both sides) between terms means OR; a bar
  without spaces is not an operator.
- **Terms.** A space separates terms that must all match. To search for text that contains a
  space, escape it with a backslash (`g\ n`); a leading `'` makes a term exact but does not keep
  the space.
- **Order.** The output is sorted by score (ties by line length, then by input position), so it
  differs from the input order and from `grep`. Add `--no-sort` or `--tiebreak=index` when the
  input order must win ties.
- **Case.** Matching is case-insensitive unless the query has an uppercase letter (smart case).
  `grep` is case-sensitive unless `-i`.
- **Output when piped.** `--filter` prints the matching lines, whole, with nothing added. Without
  `--filter` fzf draws its interface on the terminal and prints only the line you choose.
- **Lines with spaces.** fzf prints one line per match, so `xargs` without `-0` splits a name that
  contains a space into two arguments. Use `--read0 --print0` and `xargs -0`.
- **Exit status.** 0 a match was printed, 1 no match, 2 an error, 130 interrupted (Esc or Ctrl-C
  in interactive use). `grep` uses 0, 1, 2 as well, but never 130.
- **Without input.** With no pipe, fzf runs `$FZF_DEFAULT_COMMAND` (or a built-in file walk) and
  lists the files under the current directory. A script that expects fzf to read standard input
  gets the file walk instead when standard input is a terminal.
- **Needs a terminal.** Interactive mode reads the keyboard from the terminal. In cron or CI, use
  `--filter` or do not use fzf.

## When to keep the classic command

- POSIX scripts, CI images and servers without fzf: `grep` is always there.
- When the match must be exact and the order must stay the input order: `grep -F`.
- When a regular expression is needed: fzf's query syntax is not a regex (`grep -E`, `rg`).
- When the fuzzy result is wrong for the task: a script that takes the first line of
  `fzf --filter` gets the best fuzzy match, which may not be the line the pattern names.

## Pitfalls

The matches are separated by newlines, so a name with a space becomes two arguments:

```sh bad
fd -t f . notes | fzf --filter meeting | xargs cat
```
```sh
# spec: CLI-FZF-07
fd -t f -0 . notes | fzf --read0 --print0 --filter meeting | xargs -0 cat
```
```text
Meeting with Bob
TODO: send minutes
```

A bar without spaces is not OR, so `todo|main` is one fuzzy term that matches nothing here and the
status is 1. Write the bar with a space on each side:

```sh bad
fd -t f . | sort | fzf --filter 'todo|main'
```
```sh
# spec: CLI-FZF-01
fd -t f . | sort | fzf --filter 'todo | main'
```
```text
src/main.nim
notes/todo.txt
```

## Sources

- `1095557a697a522a` fzf
- `96b00026b5d224fd` GNU grep manual
