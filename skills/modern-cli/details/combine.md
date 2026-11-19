# Combine the tools in pipelines: fd, rg, sd, jq with xargs

## Intent

Pass the result of one tool to the next without breaking on spaces or non-ASCII characters in
file names: list with `fd` or `rg`, then act with `xargs`, `fd -x`, `sd` or `jq`, using NUL as the
separator end to end.

## Classic and modern

| classic | modern |
|---|---|
| `find . -type f -name '*.txt' -print0 \| xargs -0 CMD` | `fd -0 -t f -e txt \| xargs -0 CMD` |
| `find . -name '*.txt' -exec CMD {} \;` | `fd -e txt -x CMD {}` |
| `find . -name '*.txt' -exec CMD {} +` | `fd -e txt -X CMD` |
| `grep -rl --null PATTERN . \| xargs -0 sed -i '' 's/A/B/'` | `rg -l0 PATTERN \| xargs -0 sd A B` |
| `grep -rn PATTERN . \| awk -F: '{print $1}'` | `rg --json PATTERN \| jq ...` |

## Commands

Count the TODO lines in each text file. The producer ends every name with NUL (`-print0`, `-0`)
and the consumer splits on NUL (`xargs -0`), so `meeting notes.txt` stays one argument. Both
print the same here:

```sh classic
find notes -type f -name '*.txt' -print0 | sort -z | xargs -0 grep -c TODO
```
```sh
fd -0 -t f -e txt . notes | sort -z | xargs -0 grep -c TODO
```
```text
notes/meeting notes.txt:1
notes/todo.txt:2
notes/日本語.txt:1
```

`fd -x` runs the command once per file, in parallel, and takes no NUL care: each path is one
argument. The placeholders are `{}` (the path), `{/}` (file name), `{//}` (directory) and `{.}`
(path without extension). Parallel jobs finish in any order, so sort the output:

```sh
fd -t f -e txt . notes -x echo '{/}' '{//}' '{.}' | sort
```
```text
meeting notes.txt notes notes/meeting notes
todo.txt notes notes/todo
日本語.txt notes notes/日本語
```

`fd -X` runs the command once with all the paths as arguments, like `find -exec ... {} +`.
Put the paths and options before `-x`/`-X`: everything after it belongs to the command.

```sh
fd -t f -e txt . notes -X wc -l | sort -k2
```
```text
       2 notes/meeting notes.txt
       3 notes/todo.txt
       1 notes/日本語.txt
       6 total
```

Rewrite the files that contain a pattern. `rg -l0` prints only the names, NUL separated, and
`sd` edits them in place. The classic version needs `sed -i ''` on BSD (macOS); GNU `sed -i`
takes no argument. Both leave the same counts:

```sh classic
grep -rl --null TODO notes | xargs -0 sed -i '' 's/TODO/DONE/' && grep -rc DONE notes | sort
```
```sh
rg -l0 --sort path TODO notes | xargs -0 sd TODO DONE && rg -c --sort path DONE notes
```
```text
notes/meeting notes.txt:1
notes/todo.txt:2
notes/日本語.txt:1
```

The same edit as a step that can be repeated: after the first run no file contains the pattern,
so the second run finds no names and changes nothing. BSD `xargs` does not run the command when
its input is empty; GNU `xargs` does, unless given `-r`, so add `-r` when the script may run on Linux:

```sh idempotent
rg -l0 --sort path TODO notes | xargs -0 sd TODO DONE; rg -c --sort path DONE notes
```
```text
notes/meeting notes.txt:1
notes/todo.txt:2
notes/日本語.txt:1
```

Use `rg --json` when a script needs fields (path, line number) instead of parsing `path:line:text`.
Each line of the output is one JSON event; the matches have `"type":"match"`:

```sh
rg --json --sort path TODO notes | jq -r 'select(.type == "match") | "\(.data.path.text):\(.data.line_number)"'
```
```text
notes/meeting notes.txt:2
notes/todo.txt:1
notes/todo.txt:3
notes/日本語.txt:1
```

Run `jq` over the files `fd` finds, passing each path with `{}` (once for `--arg`, once as
the input file):

```sh
fd -t f -e json . config -x jq -c --arg f {} '{file: $f, keys: keys}' {}
```
```text
{"file":"config/app.json","keys":["debug","name","ports","version"]}
```

## Differences that change results

- **NUL or newline.** `fd`, `rg -l` and `fzf` end lines with `\n` by default; a name with a space
  splits in `xargs` and in `for f in $(...)`. Use `-0` / `--null` / `-l0` on the producer and
  `-0` on `xargs`, and `sort -z` when sorting between them.
- **The `./` prefix.** With a path argument (`fd . notes`) names start with that path. With none,
  `fd` prints `notes/todo.txt` when piped, but `./notes/todo.txt` with `-0`, `-x` and `-X`
  (fd 10.5.0). `find .` always prints `./`. Add `--strip-cwd-prefix` to drop it everywhere.
- **Order.** `fd -x` runs jobs in parallel and `fd` itself has no sort option; `rg` needs
  `--sort path`. `find` lists in directory order. Sort the final output (`sort`, `sort -z`).
- **One command per file or one for all.** `-x` is like `-exec {} \;`, `-X` like `-exec {} +`.
  A command that needs all the files at once (`wc -l`, `tar`) wants `-X` or `xargs`; one that
  must see each file alone (`jq` with `--arg`) wants `-x`.
- **Ignored and hidden files.** `fd` and `rg` skip them, `find` and `grep -r` do not, so the two
  halves of a pipeline can disagree about which files exist. Give both `-u` (or `-H -I` for `fd`)
  when the whole tree is meant.
- **Edit in place.** `sd` writes the file and prints nothing; `sed -i ''` is BSD, `sed -i` is GNU.
  Neither keeps a backup unless asked, so check the list first (`rg -l ...`).
- **Exit status.** A pipeline reports the status of its last command. `rg -l NOPE | xargs -0 sd ...`
  succeeds when nothing matched (BSD `xargs`), which hides the missing match.
- **Regex dialect.** `sd` uses Rust regex like `rg`, and `$1` in the replacement is a capture;
  `sed` uses basic regex and `\1`. Use `sd -F` (fixed strings) for text copied from code.

## When to keep the classic command

- POSIX scripts and servers that have `find`, `xargs` and `sed` but not `fd`, `rg` or `sd`.
- When every file must be touched, ignored and hidden ones too, and the pipeline should not
  depend on ignore rules (`find ... -print0`).
- When the script must run unchanged on Linux and macOS: `sed -i` differs (BSD needs `-i ''`);
  `find -exec ... +` and `xargs -0` are specified by POSIX or common to both.
- When a one-file edit is enough: `sd A B file` needs no pipeline at all.

## Pitfalls

Names are separated by newlines, so a name with a space becomes two arguments (`sd` reports
`invalid path: notes/meeting`) and no file is changed:

```sh bad
rg -l TODO notes | xargs sd TODO DONE
```
```sh
rg -l0 --sort path TODO notes | xargs -0 sd TODO DONE && rg -c --sort path DONE notes
```
```text
notes/meeting notes.txt:1
notes/todo.txt:2
notes/日本語.txt:1
```

## Sources

- `1b998e95b8fb679f` fd
- `2dd384575394f4b1` ripgrep user guide
- `d917c9834bea2bed` sd
- `40610646b614d8d6` jq manual
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `07c024119cc4d6ce` The Art of Unix Programming
- `0fcd5e4bf264865c` Data Science at the Command Line
