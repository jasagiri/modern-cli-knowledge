# List directories: eza

## Intent

List the entries of a directory, or a whole tree, in a stable order, with the choices that matter
to a reader: hidden entries, directories first, depth, and what to leave out.

## Classic and modern

| classic | modern |
|---|---|
| `ls -1 .` | `eza -1 --sort=Name .` |
| `ls -1A .` | `eza -1 -a --sort=Name .` |
| `ls -d */` | `eza -1 -D .` |
| `ls -1r .` | `eza -1 -r --sort=Name .` |
| `tree` / `find . -print` | `eza --tree .` |
| `tree -L 2` | `eza --tree -L 2 .` |
| `tree -I 'build'` | `eza --tree -I build .` |

## Commands

List a directory, one name per line. The default order of eza ignores case, so `README.md` sorts
among the lowercase names; `--sort=Name` is the case-sensitive byte order that `ls` uses in the C
locale, so both commands print the same here:

```sh classic
ls -1 .
```
```sh
# spec: CLI-EZA-01 CLI-EZA-04
eza -1 --sort=Name .
```
```text
README.md
build
config
data
debug.log
notes
src
```

Show hidden entries (`-a`, like `ls -A`: no `.` and `..`). `-I` hides entries by glob, here the
repository directory and the sandbox's own `.home`, which the classic command removes with
`grep`:

```sh classic
ls -1A . | grep -v -e '^.git$' -e '^.home$'
```
```sh
# spec: CLI-EZA-05
eza -1 -a --sort=Name -I '.git|.home' .
```
```text
.env.example
.gitignore
.hidden
README.md
build
config
data
debug.log
notes
src
```

Directories first, and only the directories:

```sh
eza -1 --sort=Name --group-directories-first .
```
```text
build
config
data
notes
src
README.md
debug.log
```
```sh
eza -1 -D --sort=Name .
```
```text
build
config
data
notes
src
```

Sort by extension, or reverse any sort with `-r`:

```sh
# spec: CLI-EZA-01
eza -1 --sort=extension src && eza -1 -r --sort=Name src
```
```text
main.nim
util.nim
legacy.py
util.nim
main.nim
legacy.py
```

A tree, limited in depth (`-T`/`--tree`, `-L`), leaving out entries by glob (`-I`, `|` separates
patterns):

```sh
# spec: CLI-EZA-02 CLI-EZA-09
eza --tree --sort=Name -L 2 -I 'build|data|*.log' .
```
```text
.
├── README.md
├── config
│   ├── app.json
│   └── app.yaml
├── notes
│   ├── 'meeting notes.txt'
│   ├── todo.txt
│   └── 日本語.txt
└── src
    ├── legacy.py
    ├── main.nim
    └── util.nim
```

`--git-ignore` hides what `.gitignore` lists, but only in a real git repository. The `.git` of this
fixture is an empty directory, which eza does not accept as a repository (rg and fd do), so
`build` and `debug.log` are still listed:

```sh
# spec: CLI-EZA-06
eza -T -L1 --sort=Name --git-ignore .
```
```text
.
├── README.md
├── build
├── config
├── data
├── debug.log
├── notes
└── src
```

In a real repository the entries of `.gitignore` (`build/` and `*.log` in the fixture) are hidden.
An empty `.git` directory is not a repository, so `--git-ignore` hides nothing there. Here
`git init` makes the directory a repository, and `build` and `debug.log` are gone from the same
listing:

```sh
# spec: CLI-EZA-06 CLI-EZA-06
rm -rf .git
git init -q
eza -T -L1 --sort=Name --git-ignore .
```
```text
.
├── README.md
├── config
├── data
├── notes
└── src
```

The long format with its changing columns (permissions, owner, dates) switched off leaves the size
and the name:

```sh
# spec: CLI-EZA-08
eza -l --no-permissions --no-user --no-time --sort=Name notes
```
```text
36 'meeting notes.txt'
53 todo.txt
26 日本語.txt
```

Mark directories with a slash. The value must be attached with `=`; `eza -1 -F notes` would take
`notes` as the value of `-F` and fail with status 2:

```sh
# spec: CLI-EZA-07
eza -1 --sort=Name --classify=always .
```
```text
README.md
build/
config/
data/
debug.log
notes/
src/
```

A path after `-F` is read as its value, so this is a usage error:

```sh
# spec: CLI-EZA-07
# exit: 2
eza -1 -F notes
```
```text
```

Without a path and with standard input that is not a terminal (here `/dev/null`), eza lists the
paths read from it, which are none: nothing is printed and the status is 0:

```sh
# spec: CLI-EZA-03
eza -1 --sort=Name; echo "status: $?"
```
```text
status: 0
```

A path that does not exist is an error (status 2; BSD `ls` uses 1), and nothing goes to standard
output:

```sh
# spec: CLI-EZA-10
# exit: 2
eza nope
```
```text
```

## Differences that change results

- **Order.** eza sorts by name ignoring case by default (`README.md` after `notes`), `ls` in the C
  locale puts uppercase first and in other locales follows the collation. Say the order:
  `--sort=Name` (case-sensitive), `--sort=name` (case-insensitive), `--sort=extension`, `-r`.
  Directories are not grouped unless `--group-directories-first`.
- **Quoting.** eza puts quotes around names with spaces or special characters even when the output
  is piped (`'meeting notes.txt'`); `ls` does not when piped. Use `--no-quotes` for plain names
  (see Pitfalls).
- **Standard input.** With no path, eza reads the paths to list from standard input when it is not a
  terminal (a pipe, `/dev/null` under cron, CI or an agent shell), and prints nothing when there are
  none. Always write the path: `eza .`.
- **One per line.** Piped, eza prints one name per line like `ls`; on a terminal it uses columns.
  `-1` makes it explicit.
- **Hidden entries.** `-a` includes dotfiles and, as `ls -A` does, no `.` and `..` entries; `ls -a`
  includes them.
- **`.gitignore`.** eza lists ignored files unless `--git-ignore` is given, and then only in a real
  git repository. `tree` and `ls` never read it.
- **Trailing slash.** `ls -d */` and `ls -F` mark directories with `/`; eza does not unless
  `-F` (`--classify`) is given. `-F` takes an optional value (`always`, `auto`, `never`), so a path
  right after it is read as that value and is an error (status 2): write `-F=always`, `--classify=always`,
  or put the path before `-F`.
- **Long format.** `-l` adds permissions, owner, size and dates that change per machine and per
  run; do not copy them into tests or documents. Use `--no-permissions --no-user --no-time` to
  trim the columns that vary, or the long format only to read it.
- **Tree output.** `--tree` draws with box characters; `tree` counts the entries at the end, eza does
  not. The `.` root is printed for the directory you start from.
- **Exit status.** 0 on success, 2 for a missing path (BSD `ls` exits 1 for it).

## When to keep the classic command

- POSIX scripts, CI images and servers without eza: use `ls`, or better `find` or a shell glob,
  since parsing `ls` is fragile anyway.
- When a script parses the output and needs unquoted names, byte order or the exact `ls -l`
  columns.
- When you need a list for further processing, not for reading: `fd` or `find` with `-print0`,
  not a listing tool.

## Pitfalls

eza quotes a name that contains a space, even in a pipe, so a pattern for the start of the name
misses it:

```sh bad
eza -1 notes | grep '^meeting'
```
```sh
# spec: CLI-EZA-02
eza -1 --no-quotes notes | grep '^meeting'
```
```text
meeting notes.txt
```

Without a path, eza takes the list of paths from standard input when it is not a terminal; here
that is empty, so nothing is printed and the status is still 0:

```sh bad
eza -1 --sort=Name
```
```sh
# spec: CLI-EZA-01 CLI-EZA-04
eza -1 --sort=Name .
```
```text
README.md
build
config
data
debug.log
notes
src
```

## Sources

- `aed4c5853a286846` eza
- `5fcf61afb6b336b9` GNU Coreutils manual
- `9847b24a1da661bb` tree(1), Ubuntu 24.04 manual page
