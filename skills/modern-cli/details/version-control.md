# Record and rewrite changes: jj

## Intent

Record, describe, reorder and undo changes in a repository with Jujutsu (`jj`), which works on top
of a git repository, knowing where its model differs from git's: no staging area, a working copy
that is itself a commit, bookmarks that stay put, conflicts stored in commits and an undo for every
operation.

## Classic and modern

| classic | modern |
|---|---|
| `git status` | `jj status`, or `jj diff --summary` for the file list alone |
| `git add -A && git commit -m MSG` | `jj commit -m MSG` |
| `git commit --amend -m MSG` | `jj describe -r @- -m MSG`; edit, then `jj squash` to move the edit into `@-` |
| `git log --oneline` | `jj log` |
| `git ls-files` | `jj file list` |
| `git diff` | `jj diff --git` (plain `jj diff` is not a patch) |
| `git branch -f main HEAD` | `jj bookmark set main -r @-` |
| `git rebase --onto B A^ A` | `jj rebase -r A -d B` (`-s` moves descendants too, `-b` a whole branch) |
| `git stash` | `jj new @-` (the change stays behind as a commit) |
| `git reflog` and `git reset --hard` | `jj op log` and `jj undo` |
| `git push` | `jj git push` |

## Commands

The examples run in a copy of the fixture tree, whose `.git` is an empty placeholder: each one
removes it, runs `jj git init` (which makes a colocated repository, with `.git` beside `.jj`), and
sets the author with `JJ_USER` and `JJ_EMAIL` because the sandbox has no jj configuration. jj
writes its status lines ("Working copy now at …") to standard error, which the examples discard.

`jj log` and `jj status` print change IDs, commit IDs and times, which differ on every machine and
every run. The examples ask for descriptions instead, with a template (`-T`), and leave out the root
commit (`root()`) and the empty working-copy commit on top (`@`) with the revset `::@- ~ root()`.

The working copy is a commit. There is no `git add`: every jj command first records the files as
they are, and a file that `.gitignore` does not list is tracked as soon as it exists, hidden files
included. `build/` and `debug.log` are ignored here; `.env.example` and `.hidden/secret.txt` are
not:

```sh
# spec: CLI-JJ-01
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj diff --summary
```
```text
A .env.example
A .gitignore
A .hidden/secret.txt
A README.md
A config/app.json
A config/app.yaml
A data/blob.bin
A data/people.json
A notes/meeting notes.txt
A notes/todo.txt
A notes/日本語.txt
A src/legacy.py
A src/main.nim
A src/util.nim
```

The list of tracked files is the same as git's once everything is added. `core.quotePath=false`
makes git print the Japanese name as it is, as jj does:

```sh classic
rmdir .git && git init -q && git add -A && git -c core.quotePath=false ls-files
```
```sh
# spec: CLI-JJ-01
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj file list
```
```text
.env.example
.gitignore
.hidden/secret.txt
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

Adding a path to `.gitignore` does not stop tracking a file jj has already recorded: it stays in
the working-copy commit. `jj file untrack PATH` removes it from tracking and leaves the file on
disk, and it refuses (exit 1) a path that `.gitignore` does not list, so ignore first:

```sh
# spec: CLI-JJ-19
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
mkdir dist && echo obj > dist/app.o
jj diff --summary
jj file untrack dist/app.o 2>/dev/null; echo "untrack before ignoring: exit $?"
printf 'dist/\n' >> .gitignore
jj diff --summary
jj file untrack dist/app.o 2>/dev/null; echo "untrack after ignoring: exit $?"
jj diff --summary
ls dist
```
```text
A dist/app.o
untrack before ignoring: exit 1
M .gitignore
A dist/app.o
untrack after ignoring: exit 0
M .gitignore
app.o
```

`jj commit -m` gives the working-copy commit its description and starts a new, empty one on top.
A file created afterwards belongs to the new commit, with no command to add it:

```sh
# spec: CLI-JJ-01 CLI-JJ-02
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo x > new.txt
jj diff --summary
jj log --no-graph -r '::@- ~ root()' -T 'description.first_line() ++ "\n"'
```
```text
A new.txt
Import the tree
```

`jj describe` only sets the description and stays in the same commit, so whatever you edit next
joins it. Here `README.md` was meant for a later commit and ended up in "Add new.txt":

```sh
# spec: CLI-JJ-03
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo x > new.txt
jj describe -m 'Add new.txt' 2>/dev/null
echo more >> README.md
jj log --no-graph -r @ -T 'description.first_line() ++ "\n"'
jj diff --summary -r @
```
```text
Add new.txt
M README.md
A new.txt
```

Every commit has two IDs. The change ID stays the same when the commit is rewritten (a new
description, a rebase, a squash); the commit ID, a hash of the content, changes. Refer to work in
progress by its change ID:

```sh
# spec: CLI-JJ-04
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
before=$(jj log --no-graph -r @ -T 'change_id ++ " " ++ commit_id')
jj describe -m 'Import the tree' 2>/dev/null
after=$(jj log --no-graph -r @ -T 'change_id ++ " " ++ commit_id')
[ "${before% *}" = "${after% *}" ] && echo "change ID: same"
[ "${before#* }" != "${after#* }" ] && echo "commit ID: different"
```
```text
change ID: same
commit ID: different
```

`jj commit -m MSG PATH…` puts only the named paths in the commit; the other changes stay in the new
working-copy commit. `jj bookmark set` creates the bookmark when it does not exist yet:

```sh
# spec: CLI-JJ-20 CLI-JJ-21
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo more >> README.md && echo x > new.txt
jj commit -m 'Update README' README.md 2>/dev/null
jj diff --summary -r @-
echo ---
jj diff --summary
jj bookmark set feature -r @- 2>/dev/null
jj log --no-graph -r feature -T 'description.first_line() ++ "\n"'
```
```text
M README.md
---
A new.txt
Update README
```

A bookmark (git's branch) does not move when you commit on top of it. Move it yourself, to `@-`
after `jj commit`, before pushing or comparing with it:

```sh
# spec: CLI-JJ-05
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
jj bookmark create main -r @- 2>/dev/null
echo x > new.txt && jj commit -m 'Add new.txt' 2>/dev/null
jj log --no-graph -r main -T 'description.first_line() ++ "\n"'
jj bookmark set main -r @- 2>/dev/null
jj log --no-graph -r main -T 'description.first_line() ++ "\n"'
```
```text
Import the tree
Add new.txt
```

A conflict does not stop a rebase. It is stored in the commit, the rebase exits 0, and the
commits on top of it (here the working copy, moved along by `-s`) are marked as conflicted too
until it is resolved. `conflicts()` finds them:

```sh
# spec: CLI-JJ-06
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
printf 'theirs\n' > notes/todo.txt && jj commit -m 'Rewrite todo' 2>/dev/null
jj new 'description(substring:"Import")' 2>/dev/null
printf 'mine\n' > notes/todo.txt && jj commit -m 'Replace todo' 2>/dev/null
jj rebase -s @- -d 'description(substring:"Rewrite")' 2>/dev/null; echo "rebase exit $?"
jj log --no-graph -r '::@- ~ root()' -T 'description.first_line() ++ if(conflict, " (conflict)") ++ "\n"'
echo ---
jj log --no-graph -r 'conflicts()' -T 'if(current_working_copy, "(working copy)", description.first_line()) ++ "\n"'
```
```text
rebase exit 0
Replace todo (conflict)
Rewrite todo
Import the tree
---
(working copy)
Replace todo
```

Every command that changes the repository is an operation in `jj op log`, and `jj undo` takes back
the last one, `abandon` included. In jj 0.46 and 0.47 the command is `jj undo` (and `jj redo`); the
older `jj op undo` is gone and exits 2:

```sh
# spec: CLI-JJ-07
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo x > new.txt && jj commit -m 'Add new.txt' 2>/dev/null
jj abandon @- 2>/dev/null
jj log --no-graph -r '::@- ~ root()' -T 'description.first_line() ++ "\n"'
echo ---
jj undo 2>/dev/null
jj log --no-graph -r '::@- ~ root()' -T 'description.first_line() ++ "\n"'
jj op undo 2>/dev/null; echo "jj op undo: exit $?"
```
```text
Import the tree
---
Add new.txt
Import the tree
jj op undo: exit 2
```

`jj diff` shows words and line numbers, not a patch; `--git` prints the format that `patch` and
`git apply` read:

```sh
# spec: CLI-JJ-08
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo 'TODO: write tests' >> notes/todo.txt
jj diff | tail -n 1
jj diff --git | grep -E '^(diff|\+[^+])'
```
```text
        4: TODO: write tests
diff --git a/notes/todo.txt b/notes/todo.txt
+TODO: write tests
```

A path that matches nothing is only a warning: `jj commit -m MSG PATH` still exits 0 and makes an
empty commit with that description. Check what a commit holds with `jj diff --stat -r @-`:

```sh
# spec: CLI-JJ-09
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo x > new.txt
jj commit -m 'Add new.txt' nwe.txt 2>/dev/null; echo "exit $?"
jj diff --stat -r @- | tail -n 1
jj log --no-graph -r '@ ~ empty()' -T '"still uncommitted\n"'
```
```text
exit 0
0 files changed, 0 insertions(+), 0 deletions(-)
still uncommitted
```

Commands that need a message or a choice open an editor: `jj describe` without `-m`, `jj split`,
`jj squash` with several sources. Without a terminal give `-m`, or set `JJ_EDITOR=true` to accept
what the editor would start with. `jj split FILE` puts FILE in a first commit and leaves the rest
in the working copy:

```sh
# spec: CLI-JJ-10
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo a > a.txt && echo b > b.txt
JJ_EDITOR=true jj split a.txt 2>/dev/null; echo "split exit $?"
jj diff --summary -r @-
jj diff --summary -r @
```
```text
split exit 0
A a.txt
A b.txt
```

A string in a revset function is a glob over the whole text, and a description ends with a
newline, so `description("Add new.txt")` matches nothing. Use `substring:` (or `exact:` with the
newline):

```sh
# spec: CLI-JJ-11
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
echo x > new.txt && jj commit -m 'Add new.txt' 2>/dev/null
jj log --no-graph -r 'description("Add new.txt")' -T '"glob: found\n"'
jj log --no-graph -r 'description(substring:"Add new")' -T '"substring: found\n"'
```
```text
substring: found
```

jj does not run git hooks. A `pre-commit` hook that always fails does not stop `jj commit`:

```sh
# spec: CLI-JJ-12
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
printf '#!/bin/sh\nexit 1\n' > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
jj commit -m 'Import the tree' 2>/dev/null; echo "exit $?"
jj log --no-graph -r @- -T 'description.first_line() ++ "\n"'
```
```text
exit 0
Import the tree
```

Before ending a session, check that nothing is left in the working copy. `@ ~ empty()` prints the
working-copy commit only when it holds changes:

```sh
# spec: CLI-JJ-13
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj log --no-graph -r '@ ~ empty()' -T '"uncommitted changes\n"'
jj commit -m 'Import the tree' 2>/dev/null
jj log --no-graph -r '@ ~ empty()' -T '"uncommitted changes\n"'; echo "after commit: nothing above"
```
```text
uncommitted changes
after commit: nothing above
```

## Differences that change results

- **No staging area.** The working copy is a commit that every jj command updates first; a file
  `.gitignore` does not list is tracked as soon as it exists, hidden files and build output
  included. Add build directories to `.gitignore` before running jj; a file tracked before it was
  ignored stays tracked until `jj file untrack PATH`, which refuses a path that is not ignored.
- **Committing.** `jj commit -m` describes the working copy and starts a new empty one; with paths
  it takes only those and leaves the rest in the new working copy. `jj describe` alone stays in the
  same commit, so the next edits join it.
- **Two IDs.** The change ID survives rewrites; the commit ID changes with every rewrite.
- **Bookmarks stay put.** A bookmark does not follow new commits as a git branch follows `HEAD`;
  move it with `jj bookmark set NAME -r @-`, which also creates a missing bookmark.
- **Conflicts are stored.** A rebase or merge that conflicts exits 0 and records the conflict in
  the commit and its descendants; find them with `conflicts()`.
- **Undo.** `jj undo` takes back the last operation, whatever it was; in jj 0.46 and 0.47 `jj op undo`
  no longer exists.
- **Diff format.** `jj diff` is not a patch; use `jj diff --git` for one.
- **Paths that match nothing.** `jj commit -m MSG PATH` with a mistyped PATH warns on standard error,
  exits 0 and makes an empty commit.
- **Editors.** `jj describe` without `-m`, `jj split` and `jj squash` from several sources open an
  editor; set `JJ_EDITOR=true` or pass `-m` when there is no terminal.
- **Revset strings are globs.** `description("x")` must match the whole description, which ends with
  a newline; use `substring:`.
- **No git hooks.** `jj commit` does not run `pre-commit` or `commit-msg` hooks.
- **Finding leftovers.** `jj log -r '@ ~ empty()'` prints something only when the working copy has
  changes.
- **Pager.** On a terminal jj pages long output and colours it; in a pipe it does neither.
- **Version.** The examples were checked with `jj 0.47.1`; commands change between versions
  (`jj op undo` became `jj undo`).

## When to keep the classic command

- Scripts, CI jobs and machines others run: use git, which is installed where jj is not, and whose
  commands do not change between versions as jj's still do.
- A repository whose checks live in git hooks (`pre-commit`, `commit-msg`): run them yourself
  before `jj commit`, or commit with git.
- Submodules, LFS and other git features jj does not handle: use git for those operations.

## Pitfalls

Describing the working copy and then going on editing puts the next change in the same commit.
Finish a commit with `jj commit -m`, so the next edit starts a new one:

```sh bad
jj describe -m 'Import the tree'
echo x > new.txt
```
```sh
export JJ_USER=Ada JJ_EMAIL=ada@example.org
rmdir .git && jj git init 2>/dev/null
jj commit -m 'Import the tree' 2>/dev/null
echo x > new.txt
jj diff --summary -r @- | grep -c .
jj diff --summary -r @
```
```text
14
A new.txt
```

## Sources

- `d3e08a7505856df3` Jujutsu (jj)
- `e52e6b835f6d8607` Pro Git
