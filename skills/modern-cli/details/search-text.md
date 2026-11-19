# Search text in files: rg

## Intent

Find lines that match a pattern across a source tree, quickly, without searching generated files,
dependencies or version-control internals.

## Classic and modern

| classic | modern |
|---|---|
| `grep -rn PATTERN .` | `rg -n PATTERN` |
| `grep -rl PATTERN .` | `rg -l PATTERN` |
| `grep -rn --include='*.py' PATTERN .` | `rg -n -t py PATTERN` |
| `grep -F 'a.b(' file` | `rg -F 'a.b(' file` |

## Commands

List the files that mention TODO. Both commands print the same list here, but the classic one has
to spell out what rg skips by itself (the `.gitignore` entries, hidden directories, binary files):

```sh classic
grep -rlI --exclude-dir=build --exclude-dir=.hidden --exclude-dir=.git --exclude='*.log' TODO . | sed 's|^\./||' | sort
```
```sh
# spec: CLI-RG-01
rg -l --sort path TODO
```
```text
README.md
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
src/legacy.py
src/main.nim
src/util.nim
```

Search everything, ignored, hidden and binary files included (`-uuu`):

```sh
# spec: CLI-RG-01 CLI-RG-02 CLI-RG-03
rg -l -uuu --sort path TODO
```
```text
.hidden/secret.txt
README.md
build/out.txt
data/blob.bin
debug.log
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
src/legacy.py
src/main.nim
src/util.nim
```

`--sort path` orders the files inside each path you give, in the order you give the paths; it does
not merge them. With `src` before `notes`, every `src/` line comes first:

```sh
# spec: CLI-RG-06
rg -n --sort path TODO src notes
```
```text
src/legacy.py:2:    # TODO: port to Nim
src/main.nim:4:  # TODO: parse arguments
src/util.nim:4:proc unused() = discard  # TODO: remove
notes/meeting notes.txt:2:TODO: send minutes
notes/todo.txt:1:TODO: buy milk
notes/todo.txt:3:TODO: fix the parser
notes/日本語.txt:1:メモ: TODO を減らす
```

For one order across several paths, give no `--sort` and sort the whole output by path, then by line
number. `LC_ALL=C` makes `sort` compare bytes, so the order does not change with the locale:

```sh
# spec: CLI-RG-06
rg -H -n TODO src notes | LC_ALL=C sort -t: -k1,1 -k2,2n
```
```text
notes/meeting notes.txt:2:TODO: send minutes
notes/todo.txt:1:TODO: buy milk
notes/todo.txt:3:TODO: fix the parser
notes/日本語.txt:1:メモ: TODO を減らす
src/legacy.py:2:    # TODO: port to Nim
src/main.nim:4:  # TODO: parse arguments
src/util.nim:4:proc unused() = discard  # TODO: remove
```

The sort keys split on `:`, so this assumes no path contains a colon; for such paths use
`rg --json` and sort in jq.

Only one language, with line numbers:

```sh
rg -n --sort path -t nim TODO
```
```text
src/main.nim:4:  # TODO: parse arguments
src/util.nim:4:proc unused() = discard  # TODO: remove
```

A literal string that contains regex characters, counted per file:

```sh
rg -F -c --sort path 'greet('
```
```text
src/main.nim:1
```

When the output is not a terminal (a pipe, a file, a script), rg prints no line numbers, and for a
single file no file name either:

```sh
# spec: CLI-RG-05
rg TODO src/main.nim
```
```text
  # TODO: parse arguments
```

Ask for them explicitly when another program reads the output; then rg and grep agree:

```sh classic
grep -Hn TODO src/main.nim
```
```sh
# spec: CLI-RG-05
rg -H -n TODO src/main.nim
```
```text
src/main.nim:4:  # TODO: parse arguments
```

Paths: `grep -r` prints the `./` prefix of the path it was given, rg does not:

```sh
# spec: CLI-RG-04
grep -rl TODO . --include=todo.txt
rg -l TODO -g todo.txt
```
```text
./notes/todo.txt
notes/todo.txt
```

Standard input: when it is a pipe or a file, rg searches it and not the directory. When it is neither
(here `/dev/null`) rg searches the current directory, so the path is still best written:

```sh
# spec: CLI-RG-08
rg TODO < notes/todo.txt
echo "TODO from a pipe" | rg TODO
rg -l TODO | wc -l | tr -d ' '
```
```text
TODO: buy milk
TODO: fix the parser
TODO from a pipe
7
```

`(` opens a group in rg's regex, which makes `rg 'greet('` an error with status 2; BSD `grep` (basic
regex) takes `(` literally:

```sh
# spec: CLI-RG-07 CLI-RG-09
rg 'greet(' src/main.nim > /dev/null 2>&1; echo "rg status: $?"
grep -c 'greet(' src/main.nim
```
```text
rg status: 2
1
```

No match is not an error to hide: rg exits 1, as grep does, and 2 on a real error.

```sh
# spec: CLI-RG-09
# exit: 1
rg NOPE
```
```text
```

## Differences that change results

To see what the defaults leave out of your paths, compare `rg --files src notes` with
`rg -uuu --files src notes`; when the lists are equal, the default and `-uuu` give the same matches.

- **Ignored files.** rg skips what `.gitignore`, `.ignore` and `.rgignore` list, and only inside a
  repository (a directory with `.git`; an empty `.git` directory is enough, rg does not check it further). The same tree without `.git` gives more matches. grep reads
  every file it is given.
- **Hidden files and directories** (names starting with `.`) are skipped by rg unless `--hidden` or
  `-uu`; grep reads them.
- **Binary files.** rg skips files that look binary; grep prints "Binary file … matches" unless `-I`.
- **Paths.** `grep -r PATTERN .` prints `./path`; `rg PATTERN` prints `path`. Scripts that strip or
  match the `./` prefix break when switching.
- **Output when piped.** On a terminal rg shows line numbers and groups matches under a file
  heading; when piped it prints `path:line` without line numbers, and only the line for a single
  file. A script that splits on `:` (`awk -F:`) must pass `-H -n` (or `--vimgrep`) to get a fixed
  shape.
- **Order.** rg searches in parallel, so its output order changes between runs. Add `--sort path`
  (single-threaded) or pipe to `sort` when the order matters. `--sort path` sorts within each path
  argument and keeps the arguments in the order given; for one order across several paths, pipe to
  `sort`.
- **Regex dialect.** rg uses Rust regex: `(` groups, so `rg 'greet('` is an error, where BSD and GNU
  `grep` (basic regex) treat `(` literally. No backreferences or look-around unless `-P`.
- **Standard input.** With no path, rg searches standard input when it is a pipe or a file, not the
  current directory. Under cron, CI or `xargs`, where standard input is not a terminal, write the
  path: `rg TODO .`.
- **Exit status.** 0 found, 1 not found, 2 error, for both; with `-q` both stop at the first match.

## When to keep the classic command

- POSIX shell scripts that must run where rg is not installed (minimal containers, rescue shells,
  most CI images without a setup step): use `grep`.
- When every file must be searched, ignored or not, and you do not want to remember `-uuu`.
- When a script depends on basic-regex semantics or the `./` prefix.

## Pitfalls

`(` opens a group in rg's regex, so a pattern copied from code fails:

```sh bad
rg 'greet(' src/main.nim
```
```sh
# spec: CLI-RG-07
rg -n -F 'greet(' src/main.nim
```
```text
5:  echo greet("world")
```

## Sources

- `2dd384575394f4b1` ripgrep user guide
- `96b00026b5d224fd` GNU grep manual
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `01551884d3377e93` Regular Expressions for Regular Folk
- `e372d8114adfc35f` The Linux Command Line
