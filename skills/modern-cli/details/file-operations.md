# Copy, move, remove and link files: cp, mv, rm, mkdir, ln, touch

## Intent

Copy, move, delete, create and link files and directories with the classic tools, knowing which
forms behave differently when the target exists, when a path ends in a slash, or when a variable is
empty, and where BSD (macOS) differs from GNU.

## Classic and modern

| classic | modern |
|---|---|
| `cp`, `mv`, `rm`, `mkdir`, `ln`, `touch` | none (keep the classic tool) |

## Commands

All examples run in a throwaway copy of the fixture tree. `cp -R` copies a directory with its
contents (`-r` is accepted but `-R` is the POSIX flag). Whether the source ends in a slash and
whether the target exists decide where the files land. BSD `cp -R s/ t` copies the contents of `s`
into `t`, and `cp -R s e` with an existing `e` creates `e/s`:

```sh
# spec: CLI-FILE-01
mkdir s && echo 1 > s/f
cp -R s t
cp -R s/ u
ls t u
mkdir e
cp -R s e
cp -R s/ e/x
ls e e/x
```
```text
t:
f

u:
f
e:
s
x

e/x:
f
```

`cp` and `mv` overwrite an existing target without asking. `-n` refuses to overwrite: `mv -n`
leaves both files in place and exits 0, BSD `cp -n` leaves the target and exits 1. `-i` asks
first (the question goes to standard error, the answer is read from standard input):

```sh
# spec: CLI-FILE-02
echo a > f; echo b > g
mv -n f g; echo "status: $?"
cat g; ls f
cp -n f g; echo "status: $?"
cat g
echo y | cp -i f g; cat g
```
```text
status: 0
b
f
status: 1
b
a
```

A plain `cp` gives the copy a new modification time; `-p` keeps the times and the mode (the owner
only as root). Symlinks inside a copied tree are copied as links, and `-L` follows them:

```sh
# spec: CLI-FILE-03
echo a > f; touch -t 200001010000 f
cp f g; cp -p f h
test "$(stat -f %m f)" = "$(stat -f %m h)" && echo same
test "$(stat -f %m f)" = "$(stat -f %m g)" || echo different
mkdir x y; echo 1 > x/f; ln -s x lnk
cp -R lnk y/P; cp -RL lnk y/L
test -L y/P && echo link
ls y/L
```
```text
same
different
link
f
```

`mkdir -p` creates the missing parents and is not an error when the directory exists; without
`-p`, an existing directory is an error (status 1) and a missing parent too. `rmdir` removes only an
empty directory:

```sh
# spec: CLI-FILE-04
mkdir -p a/b/c && ls -R a
mkdir -p a; echo "status: $?"
mkdir a 2>/dev/null; echo "status: $?"
rmdir a 2>/dev/null; echo "status: $?"
```
```text
b

a/b:
c

a/b/c:
status: 0
status: 1
status: 1
```

`rm` needs `-r` for a directory (`rm d` fails with `is a directory`), `-f` ignores files that do not
exist (and does not ask), and there is no trash: a removed file is gone. A name that begins with `-`
is read as an option, so put `--` before it or write `./-x`:

```sh
# spec: CLI-FILE-05
mkdir d && touch d/x
rm d 2>/dev/null; echo "status: $?"
rm -r d; ls d 2>/dev/null; echo "status: $?"
rm nofile 2>/dev/null; echo "status: $?"
rm -f nofile; echo "status: $?"
touch ./-x; rm -- -x; echo "status: $?"
echo y | rm -i debug.log; test -e debug.log || echo removed
```
```text
status: 1
status: 1
status: 1
status: 0
status: 0
removed
```

A variable that may be empty must never decide what `rm -rf` removes: `rm -rf "$dir/build"` with an
empty `dir` is `rm -rf /build`, and `rm -rf "$dir/"` is `rm -rf /`. `${dir:?}` makes the shell stop
with an error when `dir` is empty or unset, so `rm` never runs:

```sh
# spec: CLI-FILE-06
dir=
( rm -rf "${dir:?}/build" ) 2>/dev/null
[ $? -ne 0 ] && echo refused
ls -d build
```
```text
refused
build
```

`ln -s TARGET LINK` stores the text `TARGET` in the link, and a relative target is resolved from the
directory that holds the link, not from where `ln` ran. Moving the link breaks it. `ln` without
`-s` makes a hard link, a second name for the same content:

```sh
# spec: CLI-FILE-07 CLI-FILE-08
ln -s todo.txt notes/nr
cat notes/nr | head -n 1
mkdir sub; mv notes/nr sub
cat sub/nr 2>/dev/null; echo "status: $?"
test -L sub/nr && test ! -e sub/nr && echo dangling
echo 1 > a; ln a b; echo 2 >> a; cat b
```
```text
TODO: buy milk
status: 1
dangling
1
2
```

`touch` creates an empty file when it does not exist and only updates the times of one that does,
leaving the content; `-c` creates nothing; `-t` sets the time (`CCYYMMDDhhmm`). `mv` into an
existing directory moves into it, otherwise it renames:

```sh
# spec: CLI-FILE-09 CLI-FILE-10
touch new; wc -c < new | tr -d ' '
echo hi > new; touch new; cat new
touch -c nofile; ls nofile 2>/dev/null; echo "status: $?"
mkdir d; mv README.md d; ls d
mv d notes; ls notes
```
```text
0
hi
status: 1
README.md
d
meeting notes.txt
todo.txt
日本語.txt
```

## Differences that change results

- **Trailing slash on the source of `cp -R`.** BSD `cp -R s/ t` copies the contents of `s` into
  `t`, while `cp -R s t` copies `s` itself (into `t/s` when `t` exists, or as `t` when it does not).
  GNU `cp -R s/ t` treats the slash like `s`, so the same command gives a different tree on Linux;
  write the target explicitly (`cp -R s/. t/` copies the contents on both).
- **Overwriting.** `cp` and `mv` replace an existing target silently. `-n` skips it, `-i` asks;
  the exit status of a skipped `cp -n` is 1 on macOS, `mv -n` exits 0 and moves nothing. GNU
  `cp -n` and `mv -n` are the same idea but have changed their exit status between versions, so do
  not test it in a portable script.
- **Metadata.** `cp` without `-p` stamps the copy with the time of the copy and applies the umask
  (see `permissions.md`); `-p` keeps modification time and mode, and the owner only for root.
  `-R` copies a symlink as a link; `-L` follows it, `-H` follows only the ones named on the
  command line.
- **`mkdir`.** Without `-p` it fails when the directory exists or a parent is missing; with `-p` it
  creates every missing parent and succeeds when the directory already exists, which makes it safe
  to repeat in a script.
- **`rm` has no undo.** It does not use a trash. `-r` is needed for directories, `-f` hides a
  missing file (status 0) and skips prompts, and `-i` asks on standard input. `rm` removes a
  symlink, not what it points to. BSD and GNU `rm` both read a leading `-` as an option, so use `--`
  or `./` before such names.
- **Empty variables.** An unquoted or empty `$dir` in `rm -rf $dir/*` or `rm -rf "$dir/"` turns
  into a path at the root of the filesystem. Guard it with `"${dir:?}"`, which aborts the shell
  command with a non-zero status when `dir` is empty or unset.
- **Symlink targets.** A relative target is read from the link's directory, so `ln -s notes/todo.txt
  nr` made in the current directory works there and breaks as soon as `nr` moves. A dangling link
  still exists (`test -L`) but `test -e` is false.
- **Hard links.** `ln a b` gives two names for one file; a change through one shows in the other, and
  the content is freed only when both names are gone. They cannot cross filesystems or point at
  directories, and `ln -s` can.
- **`touch`.** An existing file keeps its content, a missing one is created empty (`-c` forbids
  that). BSD `touch -t` takes `[[CC]YY]MMDDhhmm[.SS]`; GNU `touch -d` accepts free-form dates that
  BSD `touch` does not.
- **`mv`.** `mv a b` renames when `b` is not a directory and moves into `b` when it is, so the same
  command gives two results depending on the target. `mv -T` and `mv -t DIR` are GNU only.

## When to keep the classic command

- These six tools are the right ones: there is no modern replacement for them here. In a POSIX
  script use only `cp -R -p -i`, `mv -i`, `rm -r -f -i`, `mkdir -p`, `ln -s`, `touch`; `cp -a`,
  `cp --parents`, `mv -t`, `rm --preserve-root` and `touch -d` are GNU or BSD extras.
- To act on files chosen by a name, size or age, select them with `fd` and pass them on (`fd`
  `-x`, `find-files.md`) instead of a glob in `rm`, which expands to whatever the shell finds
  and can exceed the argument limit.
- To copy a tree again and again, or to a remote machine, `rsync` copies only what changed; `cp -R`
  copies everything every time.
- To keep a state you may want back, commit it first (`version-control.md`): `rm` and an
  overwriting `cp` or `mv` have no undo.

## Pitfalls

An empty variable turns the removal into a removal at the root, and the command raises no error of
its own:

```sh bad
rm -rf $dir/build
```
```sh
# spec: CLI-FILE-06
dir=
( rm -rf "${dir:?}/build" ) 2>/dev/null
[ $? -ne 0 ] && echo refused
ls -d build
```
```text
refused
build
```

## Sources

- `5fcf61afb6b336b9` GNU Coreutils manual
