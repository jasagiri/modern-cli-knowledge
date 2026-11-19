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
- **Input.** It takes two files, or a diff on standard input; for a directory comparison use
  `diff -ru` and pipe it in.
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
printf 'a\nb\nc\n' > old.txt && printf 'a\nB\nc\nd\n' > new.txt
diff -u old.txt new.txt > review.patch; patch -s old.txt review.patch && cmp old.txt new.txt && echo applied
```
```text
applied
```

## Sources

- `c0e9beb59305b739` delta
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
