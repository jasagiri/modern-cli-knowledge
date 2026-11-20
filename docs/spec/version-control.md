# Spec table: version-control

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/version-control.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-JJ-01 | D1 | The working copy is a commit that every command updates; a file `.gitignore` does not list is tracked as soon as it exists, hidden files included, with no add step | 例 |
| CLI-JJ-02 | D2 | `jj commit -m` describes the working copy and starts a new empty commit, so the next file belongs to the new one | 例 |
| CLI-JJ-03 | D2 | `jj describe` alone stays in the same commit, so later edits join it | 例 |
| CLI-JJ-04 | D3 | The change ID survives a rewrite and the commit ID changes | 例 |
| CLI-JJ-05 | D4 | A bookmark does not follow new commits; `jj bookmark set NAME -r @-` moves it | 例 |
| CLI-JJ-06 | D5 | A conflicting rebase exits 0, stores the conflict in the commit and its descendants, and `conflicts()` finds them | 例 |
| CLI-JJ-07 | D6 | `jj undo` takes back the last operation, `abandon` included, and `jj op undo` exits 2 in jj 0.46 and 0.47 | 例 |
| CLI-JJ-08 | D7 | `jj diff` is not a patch and `jj diff --git` is | 例 |
| CLI-JJ-09 | D8 | A path that matches nothing makes `jj commit -m MSG PATH` exit 0 with an empty commit | 例 |
| CLI-JJ-10 | D9 | `JJ_EDITOR=true` lets `jj split FILE` run without a terminal, FILE in the first commit and the rest left in the working copy | 例 |
| CLI-JJ-11 | D10 | A revset string is a glob over the whole description, which ends with a newline, so a plain string misses and `substring:` matches | 例 |
| CLI-JJ-12 | D11 | `jj commit` does not run git hooks | 例 |
| CLI-JJ-13 | D12 | `jj log -r '@ ~ empty()'` prints the working copy only when it has changes | 例 |
| CLI-JJ-14 | D13 | On a terminal jj pages and colours long output; in a pipe it does neither | 本文のみ (端末: a pager and colour need a terminal) |
| CLI-JJ-15 | D14 | The examples were checked with jj 0.47.1, and commands change between versions | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-JJ-16 | K1 | Keep git for scripts, CI jobs and machines others run | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-JJ-17 | K2 | In a repository whose checks are git hooks, run them yourself or commit with git | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-JJ-18 | K3 | Use git for submodules, LFS and other features jj does not handle | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-JJ-19 | D1 | A file tracked before it was ignored stays tracked; `jj file untrack PATH` stops tracking it and keeps the file, and exits 1 for a path that is not ignored | 例 |
| CLI-JJ-20 | D2 | `jj commit -m MSG PATH` commits only the named paths and leaves the other changes in the new working copy | 例 |
| CLI-JJ-21 | D4 | `jj bookmark set` creates a bookmark that does not exist | 例 |
| CLI-JJ-22 | D1 | `jj file untrack` records the removal in the working-copy commit only; the parent keeps the file until `jj squash PATH` moves the removal into it, and the file stays on disk | 例 |
| CLI-JJ-23 | D6 | After a file was edited, `jj undo` takes back the snapshot of that edit (removing it from disk) instead of the earlier mistake; `jj op revert ID` reverts the chosen operation and keeps the edit | 例 |
