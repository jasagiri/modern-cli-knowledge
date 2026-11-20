# Find files by name: fd

## Intent

List files and directories whose name or path matches a pattern, skipping ignored and hidden
entries, in the form a person or an agent usually wants.

## Classic and modern

| classic | modern |
|---|---|
| `find . -type f` | `fd -t f -H -I` |
| `find . -name '*.nim'` | `fd -e nim` |
| `find . -name 'main.*'` | `fd -g 'main.*'` |
| `find . -iname '*todo*'` | `fd todo` |
| `find . -type d` | `fd -t d` |
| `find . -maxdepth 1` | `fd -d 1` |
| `find . -name '*.nim' -exec CMD {} \;` | `fd -e nim -x CMD {}` |

## Commands

List every regular file. fd skips what `.gitignore` lists and hidden entries, so the classic
command has to exclude them by hand to print the same list. fd has no sort option, so both lists
go through `sort`:

```sh classic
find . -type f -not -path './.git/*' -not -path './build/*' -not -path './.hidden/*' -not -name '.*' -not -name '*.log' | sed 's|^\./||' | sort
```
```sh
# spec: CLI-FD-01
fd -t f . | sort
```
```text
README.md
config/app.json
config/app.yaml
data/blob.bin
data/people.json
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
src/legacy.py
src/main.nim
src/util.nim
```

Everything, ignored and hidden files included (`-H` hidden, `-I` ignored), which is what plain
`find` prints:

```sh classic
find . -type f | sed 's|^\./||' | sort
```
```sh
# spec: CLI-FD-01
fd -t f -H -I . | sort
```
```text
.env.example
.gitignore
.hidden/secret.txt
README.md
build/out.txt
config/app.json
config/app.yaml
data/blob.bin
data/people.json
debug.log
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
src/legacy.py
src/main.nim
src/util.nim
```

Inside a repository, `-H -I` also lists everything under `.git` (measured with fd 10.5.0:
`.git/HEAD` appears). To list every file, ignored and hidden ones included, but not `.git`, exclude
it by name with `-E`; the classic form prunes it and strips the `./` that `find` prints:

```sh classic
find . -name .git -prune -o -type f -print | sed 's|^\./||' | LC_ALL=C sort
```
```sh
# spec: CLI-FD-01
fd -t f -H -I -E .git . | LC_ALL=C sort
```
```text
.env.example
.gitignore
.hidden/secret.txt
README.md
build/out.txt
config/app.json
config/app.yaml
data/blob.bin
data/people.json
debug.log
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
src/legacy.py
src/main.nim
src/util.nim
```

To print a count next to each name, read the names with `while IFS= read -r f` (spaces stay
intact; a name containing a newline does not) and strip the spaces BSD `wc -l < "$f"` pads its
count with (`| tr -d ' '`).

By extension, and by glob on the name (`-g`):

```sh
# spec: CLI-FD-02
fd -e nim | sort && fd -g 'main.*'
```
```text
src/main.nim
src/util.nim
src/main.nim
```

A bare pattern is a case-insensitive regex searched in the file name only; `-s` makes it
case-sensitive and `-p` matches the whole path instead of the name:

```sh
# spec: CLI-FD-08
fd todo && fd -p 'notes/.*\.txt$' | sort
```
```text
notes/todo.txt
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
```

Directories, with a trailing slash, limited in depth, and with an exclusion (`-E` glob):

```sh
# spec: CLI-FD-04 CLI-FD-06
fd -t d | sort && fd -t f -d 1 . src | sort && fd -t f -E '*.py' . src | sort
```
```text
config/
data/
notes/
src/
src/legacy.py
src/main.nim
src/util.nim
src/main.nim
src/util.nim
```

Run a command for each result (`-x`, `{/}` is the file name; see `combine.md` for pipelines):

```sh
fd -e nim -x echo {/} | sort
```
```text
main.nim
util.nim
```

With `-x` the substituted path keeps the `./` prefix, unlike plain output:

```sh
# spec: CLI-FD-04
fd -e nim -x echo {} | sort
```
```text
./src/main.nim
./src/util.nim
```

Smart case: a pattern without an uppercase letter ignores case, and `-s` always respects it. An
invalid regex is an error with status 1 (fd names the literal and glob options):

```sh
# spec: CLI-FD-02 CLI-FD-07
fd readme
fd -s readme
fd '(' 2>/dev/null; echo "status: $?"
```
```text
README.md
status: 1
```

Symlinks are listed but not followed unless `-L` is given:

```sh
# spec: CLI-FD-05 CLI-FD-09
mkdir tl && ln -s ../src tl/s
fd . tl
fd -L . tl | sort
```
```text
tl/s
tl/s/
tl/s/legacy.py
tl/s/main.nim
tl/s/util.nim
```

No match is not an error: fd exits 0 and prints nothing, as `find` does, where `grep` exits 1.

```sh
# spec: CLI-FD-07
fd NOPE
```
```text
```

## Differences that change results

- **Ignored and hidden entries.** fd skips what `.gitignore`, `.ignore` and `.fdignore` list (only
  inside a repository, a directory with `.git`) and hidden entries (`-H`, `-I`, or `-u` for both).
  `find` lists everything.
- **Pattern, not a test.** fd takes a regex (Rust dialect, so `fd '('` is an error with status 1)
  matched against the file name, case-insensitively when the pattern has no uppercase letter
  (smart case), where `find -name` takes a glob, case-sensitive. `-g` for a glob, `-F` for a
  literal string.
- **Order.** fd walks in parallel and its order changes between runs. There is no sort option:
  pipe to `sort`. `find` order is directory order, stable on one filesystem but not sorted.
- **Paths.** `find .` prints `./src/main.nim`; fd prints `src/main.nim` on a terminal or a pipe, but
  with `-0`, `-x` and `-X` it prints `./src/main.nim` (the prefix is kept so a name cannot be taken for
  an option). `--strip-cwd-prefix=never` gives the prefix back in plain output, `always` removes it
  everywhere. Directories print with a trailing `/`; `find` has none.
- **Type.** Like `find`, fd prints files, directories and symlinks unless told; add `-t f` for files only.
- **Search path.** `fd PATTERN PATH...`: the pattern comes first, then paths. `fd . src` lists all
  of `src`; `find src` has the path first. With no pattern, `fd` lists everything.
- **Exit status.** 0 for found and not found, 1 on error (also invalid regex). `find` exits 0 too
  for no match.
- **Names with spaces.** Output is one path per line like `find`; use `-0` with `xargs -0` for safe
  piping (`find -print0`).
- **Symlinks** are not followed by default (`-L` follows), as with `find`.

## When to keep the classic command

- POSIX scripts, CI images and servers without fd: use `find`.
- When tests beyond the name matter (`-mtime`, `-size`, `-perm`, `-newer`, `-prune` logic): fd has
  `--changed-within` and `-S`, but `find` expresses combined conditions with `-a`/`-o`.
- When every file must be listed regardless of `.gitignore` and hidden entries and you do not want
  to remember `-H -I`.

## Pitfalls

A pattern copied from a glob is read as a regex, so `*.nim` fails (a leading `*` has nothing to
repeat) and an unanchored `nim` matches any name containing it:

```sh bad
fd '*.nim'
```
```sh
fd -e nim | sort
```
```text
src/main.nim
src/util.nim
```

## Sources

- `1b998e95b8fb679f` fd
- `95006c1c8e56e8ac` GNU findutils manual
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `e372d8114adfc35f` The Linux Command Line
