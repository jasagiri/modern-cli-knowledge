# Read differences between files: delta

## Intent

Read a diff comfortably (syntax colours, word-level highlights, line numbers, file headers) in a
terminal or as a pager for `git diff`, without changing what the diff says.

delta is a viewer: it reads a diff (or two file names) and prints it again for people. Its output is
for reading, not for `patch`.

## Classic and modern

| classic | modern |
|---|---|
| `diff -u old new` | `delta old new` |
| `diff -u old new \| less` | `diff -u old new \| delta` |
| `git diff` (with the default pager) | `git diff` with `core.pager = delta` |
| `git diff \| less -R` | `git diff \| delta --paging=never` |
| `diff -y old new` (side by side) | `delta --side-by-side old new` |

## Commands

The data on this page: `old.txt` has the lines `a b c`, `new.txt` has `a B c d`. The classic
unified diff, with the two timestamp lines cut off because they change on every run (`tail -n +3`):

```sh
# spec: CLI-DELTA-04
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
diff -u old.txt new.txt | tail -n +3
```
```text
@@ -1,3 +1,4 @@
 a
-b
+B
 c
+d
```

The same change through delta. delta writes colour even when `NO_COLOR` is set and the output is a
pipe, so the examples remove the escape sequences with `perl`. What is left is what a reader without
colour sees: a file header, a hunk header, and no `+` or `-` markers at all:

```sh
# spec: CLI-DELTA-01 CLI-DELTA-04
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta --no-gitconfig old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
```
```text

old.txt ⟶   new.txt
────────────────────────────────────────────────────────────────────────────────

───┐
1: │
───┘
a
b
B
c
d
```

Line numbers show which side each line belongs to (old number, new number); a line with a number
on one side only was removed or added:

```sh
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta --no-gitconfig --line-numbers --file-style omit --hunk-header-style omit --file-decoration-style none --hunk-header-decoration-style none old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
```
```text

  1 ⋮  1 │a
  2 ⋮    │b
    ⋮  2 │B
  3 ⋮  3 │c
    ⋮  4 │d
```

With `NO_COLOR=1` set (the examples run with it) delta still writes escape sequences into a pipe:

```sh
# spec: CLI-DELTA-02
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta --no-gitconfig old.txt new.txt | grep -q "$(printf '\033')" && echo "escapes present"
```
```text
escapes present
```

`--color-only` keeps the diff text as it came in and only adds colour, so `+` and `-` stay (here the
input is the `git diff --no-index` form that delta builds for two file names):

```sh
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta --no-gitconfig --color-only old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
```
```text
diff --git a/old.txt b/new.txt
index de98044..a7bc997 100644
--- a/old.txt
+++ b/new.txt
@@ -1,3 +1,4 @@
 a
-b
+B
 c
+d
```

The exit status of `delta old new` is 1 when the files differ and 0 when they are equal, like
`diff`; as the end of a pipe (`diff -u … | delta`) it is delta's own status, 0, even though the
files differ:

```sh
# spec: CLI-DELTA-05 CLI-DELTA-06
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta old.txt new.txt > /dev/null; echo "files differ: $?"
delta old.txt old.txt > /dev/null; echo "files equal: $?"
diff -u old.txt new.txt | delta > /dev/null; echo "after a pipe: $?"
```
```text
files differ: 1
files equal: 0
after a pipe: 0
```

Two directories are compared file by file, and the file header shows the path inside them:

```sh
# spec: CLI-DELTA-06
mkdir a b && printf 'x\ny\n' > a/f && printf 'x\nz\n' > b/f
delta --no-gitconfig a b | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g'
```
```text

a/f ⟶   b/f
────────────────────────────────────────────────────────────────────────────────

───┐
1: │
───┘
x
y
z
```

For two paths delta runs `git diff --no-index` when `git` is on `PATH` (the header then starts with
`diff --git`), and `diff -u` when it is not (the header is diff's `--- old.txt` with a timestamp,
cut off here). With neither it prints nothing and exits 2. The second command gives delta a `PATH`
that holds only `diff`; the third one with nothing:

```sh
# spec: CLI-DELTA-07
printf 'a\nb\n' > old.txt && printf 'a\nB\n' > new.txt
d=$(command -v delta) && mkdir only && ln -s "$(command -v diff)" only/diff
delta --no-gitconfig --color-only old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g' | head -n 1
PATH=$PWD/only "$d" --no-gitconfig --color-only old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g' | head -n 1 | cut -f 1
PATH=/nonexistent "$d" --no-gitconfig old.txt new.txt 2>/dev/null; echo "status $?"
```
```text
diff --git a/old.txt b/new.txt
--- old.txt
status 2
```

The user's git configuration changes delta's output: here a `[delta]` section in `~/.gitconfig`
turns on line numbers. `--no-gitconfig` ignores it, which is why every example on this page passes
it:

```sh
# spec: CLI-DELTA-08
printf 'a\nb\n' > old.txt && printf 'a\nB\n' > new.txt
printf '[delta]\n    line-numbers = true\n' > "$HOME/.gitconfig"
delta old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g' | tail -n 3
echo ---
delta --no-gitconfig old.txt new.txt | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g' | tail -n 3
```
```text
  1 ⋮  1 │a
  2 ⋮    │b
    ⋮  2 │B
---
a
b
B
```

As a pager for git, delta is set in the git configuration (`core.pager = delta` and
`interactive.diffFilter = delta --color-only`), and then `git diff`, `git log -p` and `git show`
print through it. That setup changes a user's git configuration and shows a pager, so it is
described here and not run.

## Differences that change results

- **No `+` and `-` markers.** In delta's default view an added or removed line is told apart by
  background colour only. Captured to a file, a log, a CI step or a terminal with colours off, the
  markers are gone and the output reads as the new file mixed with the old one.
- **Colour is not controlled by `NO_COLOR` or a pipe.** Redirecting delta's output still writes
  escape sequences (checked here with `NO_COLOR=1`). Decide with `--color-only`, `--paging=never`
  and the colour options, not with environment variables, when the output goes to a file.
- **Not a patch.** delta's default output cannot be applied with `patch` or `git apply`;
  `--color-only` output can, once the escape sequences are removed.
- **Extra lines.** It adds a file header, a rule, and a boxed hunk header (`1: │`) where `diff -u`
  has `---`, `+++` and `@@ -1,3 +1,4 @@`; scripts that match `^@@` or `^+++` find nothing.
- **Exit status.** With two file names it exits 1 when they differ, as `diff` does; at the end of
  a pipe it reports its own status (0), so `diff … | delta` cannot be used to test for a difference.
  Use `diff -q` or `cmp -s` for that.
- **Input.** It takes two files, two directories (example below), or a diff on standard input.
  For two paths delta runs `git diff --no-index` when `git` is on `PATH` and `diff -u` otherwise,
  so the header differs between machines; with neither it exits 2. To get the same input
  everywhere, pipe `diff -u` (or `diff -ru` for directories) into delta.
- **Configuration is read from git.** The `[delta]` section of the user's git configuration changes
  colours, line numbers and layout; use `--no-gitconfig` when an output must be reproducible, as the
  examples do.
- **Paging.** On a terminal delta starts a pager; in a pipe it does not. `--paging=never` makes
  that explicit.
- **Version.** The examples were checked with `delta 0.20.1`.

## When to keep the classic command

- Any script that reads a diff, builds a patch, tests for a difference, or checks `+`/`-` lines:
  use `diff -u`, `diff -q`, `cmp`, or `git diff`.
- Output that is stored or emailed as plain text and reviewed without colour.
- Servers, containers and CI images without delta: the diff is still readable with `diff -u`.

## Pitfalls

delta's output is a view, so saving it as a patch gives a file that `patch` cannot read:

```sh bad
delta old.txt new.txt > review.patch
```
```sh
# spec: CLI-DELTA-03
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
diff -u old.txt new.txt > review.patch; patch -s old.txt review.patch && cmp old.txt new.txt && echo applied
```
```text
applied
```

The view, saved the same way, is not a patch: `patch` finds nothing to apply and ends with status 2.

```sh
# spec: CLI-DELTA-03
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
delta --no-gitconfig old.txt new.txt > review.patch; patch -s old.txt review.patch > /dev/null 2>&1; echo "status: $?"
```
```text
status: 2
```

## Sources

- `c0e9beb59305b739` delta
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
