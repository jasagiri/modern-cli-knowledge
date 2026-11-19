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
rg -H -n TODO src/main.nim
```
```text
src/main.nim:4:  # TODO: parse arguments
```

No match is not an error to hide: rg exits 1, as grep does, and 2 on a real error.

```sh
# exit: 1
rg NOPE
```
```text
```

## Differences that change results

- **Ignored files.** rg skips what `.gitignore`, `.ignore` and `.rgignore` list, and only inside a
  repository (a directory with `.git`). The same tree without `.git` gives more matches. grep reads
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
  (single-threaded) or pipe to `sort` when the order matters.
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
