# View files: bat

## Intent

Show the contents of a file with syntax highlighting, line numbers and paging when a person reads
it in a terminal, and nothing but the bytes when a program reads it.

## Classic and modern

| classic | modern |
|---|---|
| `cat FILE` | `bat -p FILE` (plain, always) or `bat FILE` (decorated on a terminal) |
| `less FILE` | `bat FILE` (pages by itself when the output is longer than the screen) |
| `sed -n 3,4p FILE` | `bat -p -r 3:4 FILE` |
| `cat -n FILE` | `bat -n FILE` |
| `cat -e FILE` (show line ends) | `bat -A FILE` |

## Commands

Print a file. When standard output is not a terminal (a pipe, a file, a test) bat turns off its
decoration, colour and pager and prints the bytes as `cat` does, so both commands print the same
text here. On a terminal, `bat FILE` adds a header, a grid, line numbers and colour:

```sh classic
cat src/main.nim
```
```sh
# spec: CLI-BAT-01
bat src/main.nim
```
```text
import util

proc main() =
  # TODO: parse arguments
  echo greet("world")

main()
```

Plain output on a terminal too (`-p`, `--plain`): no header, no numbers, no grid. A second `-p`
(`-pp`) also turns the pager off.

```sh
# spec: CLI-BAT-01
bat -p notes/todo.txt
```
```text
TODO: buy milk
done: call Alice
TODO: fix the parser
```

Print a range of lines (`-r START:END`, 1-based and inclusive; `START:` goes to the end, `:END` from
the start):

```sh classic
sed -n 3,4p src/main.nim
```
```sh
# spec: CLI-BAT-06
bat -p -r 3:4 src/main.nim
```
```text
proc main() =
  # TODO: parse arguments
```

Line numbers. `-n` shows them even when the output is piped:

```sh
# spec: CLI-BAT-01
bat -n -r 4: src/main.nim
```
```text
   4   # TODO: parse arguments
   5   echo greet("world")
   6 
   7 main()
```

Style options are ignored when piped unless `--decorations=always` is given: `--style=numbers`
prints no number, `-n` does. `cat -n` numbers with a tab (shown as `>`) and a wider pad:

```sh
# spec: CLI-BAT-02 CLI-BAT-06
bat --style=numbers src/util.nim | head -1
bat -n src/util.nim | head -1
cat -n src/util.nim | head -1 | tr '\t' '>'
```
```text
proc greet*(name: string): string =
   1 proc greet*(name: string): string =
     1>proc greet*(name: string): string =
```

Several files are joined with no header when piped, as `cat` does; the status is 1 when any file
cannot be read, and the readable ones are still printed:

```sh
# spec: CLI-BAT-04 CLI-BAT-07
bat notes/todo.txt README.md | head -4
bat -p nope.txt notes/todo.txt 2>/dev/null; echo "status: $?"
```
```text
TODO: buy milk
done: call Alice
TODO: fix the parser
# Demo project
TODO: buy milk
done: call Alice
TODO: fix the parser
status: 1
```

Show invisible characters (`-A`, `--show-all`): spaces as `·`, line ends as `␊`, carriage returns as
`␍`:

```sh
printf 'a b\r\nc\n' | bat -A
```
```text
a·b␍␊
c␊
```

Read standard input and name its language yourself (`-l`), since there is no file name to guess
from:

```sh
printf '{"a": 1}\n' | bat -p -l json
```
```text
{"a": 1}
```

A missing file is an error: the message goes to standard error, nothing to standard output, and
the status is 1, as for `cat`:

```sh
# spec: CLI-BAT-07
# exit: 1
bat -p nope.txt
```
```text
```

## Differences that change results

- **Output depends on where it goes.** On a terminal bat prints a header, a grid, line numbers,
  colour and uses a pager; piped, it prints the file unchanged. `NO_COLOR` removes colour only, not
  the grid or numbers. The same command can therefore look different when a script copies a
  terminal session. Ask for what you want explicitly: `-p` for plain, `-n` for numbers,
  `--decorations=always --style=numbers` to force decoration when piped.
- **Style options are ignored when piped** unless `--decorations=always` is given: `bat
  --style=numbers FILE | cat` prints no numbers, `bat -n FILE | cat` does.
- **Pager.** On a terminal, output longer than the screen opens `less`; a script or an agent that
  waits for the command to end hangs. Use `-p -p`, `--paging=never` or `PAGER=cat`/`BAT_PAGER=`.
- **Several files.** `cat` joins them with no marker; bat on a terminal prints a header per file
  (piped, none, as `cat`). `-p` removes the headers.
- **Binary files.** `cat` prints the bytes; bat refuses to print binary content to a terminal
  unless asked (`--binary=as-text`).
- **Line ranges and numbers** exist only in bat (`-r`, `-n`); `cat -n` uses a tab after a
  right-aligned number, `bat -n` a space and wider padding, so output is not interchangeable.
- **Exit status.** 0 when all files were printed, 1 when any file could not be read.
- **Syntax detection** uses the file name and first line; a wrong guess only changes colour.

## When to keep the classic command

- POSIX scripts, CI images and servers where bat is not installed: use `cat`.
- Concatenating files into a file or a pipe where any decoration would corrupt the data
  (`cat a b > c`): use `cat`, or `bat -p` if you accept the dependency.
- Printing lines from the middle of a stream that is not a file: `sed -n` or `head`/`tail`.
- When the exact bytes matter (binary data, `\r`, no trailing newline): `cat` does not interpret
  anything, bat's text handling is for reading.

## Pitfalls

An agent or script that reads `bat FILE` through a terminal-like session gets a header, a grid and
line numbers, which break parsing and copy into code:

```sh bad
bat --decorations=always --style=numbers src/util.nim
```
```sh
bat -p src/util.nim
```
```text
proc greet*(name: string): string =
  "hello, " & name

proc unused() = discard  # TODO: remove
```

## Sources

- `0236c1696550e790` bat
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `e372d8114adfc35f` The Linux Command Line
