# Replace text in files: sd

## Intent

Replace a pattern with new text in a stream or in files, with the regex dialect of Rust, no
delimiter to escape and no BSD/GNU split in how files are edited in place.

## Classic and modern

| classic | modern |
|---|---|
| `sed 's/OLD/NEW/g'` (stream) | `sd OLD NEW` |
| `sed -i '' 's/OLD/NEW/g' FILE` (BSD) / `sed -i 's/OLD/NEW/g' FILE` (GNU) | `sd OLD NEW FILE` |
| `sed -E 's/(a) (b)/\2 \1/'` | `sd '(a) (b)' '$2 $1'` |
| `sed 's/a\.b/X/'` | `sd -F 'a.b' X` |
| `sed -n 's/OLD/NEW/p'` (preview) | `sd -p OLD NEW FILE` |

## Commands

Replace in a stream. sd replaces every match by default, where sed needs the `g` flag:

```sh classic
printf 'a.b.c\n' | sed 's/\./-/g'
```
```sh
printf 'a.b.c\n' | sd '\.' '-'
```
```text
a-b-c
```

Match a literal string, without escaping the dot (`-F`):

```sh
printf 'axb a.b\n' | sd -F 'a.b' X
```
```text
axb X
```

Reorder with capture groups. Quote the replacement with single quotes so the shell does not expand
`$1` and `$2`:

```sh classic
printf 'John Smith\n' | sed -E 's/([A-Za-z]+) ([A-Za-z]+)/\2, \1/'
```
```sh
printf 'John Smith\n' | sd '(\w+) (\w+)' '$2, $1'
```
```text
Smith, John
```

Edit a file in place. sd writes the file when it is given one (there is no `-i`); the second
command shows the result:

```sh classic
sed -i '' 's/TODO/DONE/g' README.md && cat README.md
```
```sh
sd TODO DONE README.md && cat README.md
```
```text
# Demo project

A tiny tree for the examples. DONE: write docs.
```

The same edit is idempotent: once the pattern is gone, a second run changes nothing and still
exits 0.

```sh idempotent
sd 'TODO:' 'DONE:' README.md && cat README.md
```
```text
# Demo project

A tiny tree for the examples. DONE: write docs.
```

Preview without writing (`-p`): the file stays as it was. The preview format is documented as
subject to change, so scripts should not parse it.

```sh
sd -p TODO DONE notes/todo.txt && cat notes/todo.txt
```
```text
DONE: buy milk
done: call Alice
DONE: fix the parser
TODO: buy milk
done: call Alice
TODO: fix the parser
```

Match across lines with `-A`; without it sd works line by line and `\n` matches nothing:

```sh
printf 'a\nb\n' | sd -A 'a\nb' X
```
```text
X
```

Limit the number of replacements per input with `-n`, and ignore case with `-f i`:

```sh
printf 'aaa\n' | sd -n 2 a b && printf 'aXb\n' | sd -f i x -- '-'
```
```text
bba
a-b
```

## Differences that change results

- **In-place editing is the default for files.** `sd OLD NEW FILE` overwrites FILE with no backup
  and no `-i`. With no file, sd reads standard input and prints to standard output. Use `-p` to
  look first.
- **BSD and GNU `sed -i` differ, sd does not.** BSD (macOS) `sed -i` requires a suffix argument,
  possibly empty: `sed -i '' 's/a/b/' f`. GNU `sed -i 's/a/b/' f` has an optional attached suffix
  (`-i.bak`). On BSD, `sed -i 's/a/b/' f` takes `s/a/b/` as the suffix and then fails with
  "invalid command code f"; `sed -i '' ...` on GNU treats `''` as the script and fails.
- **Every match is replaced.** sed replaces the first match per line unless `g` is given; sd always
  replaces all, and `-n N` limits the total.
- **Regex dialect.** sd uses Rust regex: `(` groups, `\d` `\w` `\s` work, `+` and `?` need no
  backslash, no backreferences in the pattern. BSD `sed` uses basic regex (`\(`, `\)`), and `sed -E`
  is extended regex with `\1` in the replacement.
- **Replacement syntax.** Groups are `$1` or `${1}` and `$name`; sed uses `\1`. `$1USD` is read as
  the group named `1USD`, which sd rejects as ambiguous (exit 1): write `${1}USD`. A literal `$`
  is `$$`.
- **Line by line by default.** sd 1.0.0 processes each line separately, so `\n` never matches and a
  pattern cannot span lines; `^` and `$` match at every line (multi-line matching is on, `-f e`
  turns it off). `-A` (`--across`) reads each input as a whole, so `sd -A 'a\nb' X` joins across
  lines (the trailing newline of the input is then part of the text, and `^` also matches after
  it). sed is line-oriented as well, and needs tricks (`N`, `H`/`G`) to match across lines.
- **Delimiter.** sd has none, so a `/` in the pattern or replacement needs no escaping; in sed it
  must be escaped or another delimiter chosen.
- **Exit status.** No match is not an error: sd exits 0 and leaves the input unchanged, as sed
  does. An invalid regex exits 1 with the message on standard error.
- **Pattern that starts with `-`.** Put `--` before it (`sd -- '-x' y`), as with most CLIs.

## When to keep the classic command

- POSIX shell scripts that run on machines without sd: use `sed` (and `sed -i.bak` with a suffix,
  which works on both BSD and GNU, then remove the backup).
- Line-oriented edits that sed does well: `sed -n '5,10p'`, `sed '/pat/d'`, `sed '3i\text'`;
  sd only substitutes.
- When the script relies on basic-regex semantics or on `\1` in the replacement.

## Pitfalls

GNU-style `sed -i` fails on macOS, where the argument after `-i` is the backup suffix:

```sh bad
sed -i 's/TODO/DONE/' README.md
```
```sh
sd TODO DONE README.md && cat README.md
```
```text
# Demo project

A tiny tree for the examples. DONE: write docs.
```

## Sources

- `d917c9834bea2bed` sd
- `6f5694b2556b9b45` GNU sed manual
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `01551884d3377e93` Regular Expressions for Regular Folk
