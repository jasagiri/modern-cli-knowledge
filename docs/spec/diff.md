# Spec table: diff

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/diff.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-DELTA-01 | D1 | In delta's default view added and removed lines carry no `+` or `-` marker, only background colour | 例 |
| CLI-DELTA-02 | D2 | delta writes escape sequences even with `NO_COLOR=1` and into a pipe | 例 |
| CLI-DELTA-03 | D3 | delta's default output is not a patch; `diff -u` output can be applied with `patch` | 例 |
| CLI-DELTA-04 | D4 | delta adds a file header, a rule and a boxed hunk header where `diff -u` has `---`, `+++` and `@@` | 例 |
| CLI-DELTA-05 | D5 | With two file names delta exits 1 when they differ and 0 when equal; at the end of a pipe it exits 0 | 例 |
| CLI-DELTA-06 | D6 | delta takes two files, two directories or a diff on standard input | 例 |
| CLI-DELTA-07 | D6 | For two paths delta runs `git diff --no-index` when `git` is on `PATH`, `diff -u` otherwise, and exits 2 with neither | 例 |
| CLI-DELTA-08 | D7 | The `[delta]` section of the user's git configuration changes the output, so `--no-gitconfig` makes it reproducible | 例 |
| CLI-DELTA-09 | D8 | On a terminal delta starts a pager and in a pipe it does not | 本文のみ (端末: a pager needs a terminal) |
| CLI-DELTA-10 | D9 | The examples were checked with delta 0.20.1 | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-DELTA-11 | K1 | Keep `diff -u`, `diff -q`, `cmp` or the git diff for any script that reads a diff, builds a patch or tests for a difference | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DELTA-12 | K2 | Keep the classic diff for output stored or emailed as plain text | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DELTA-13 | K3 | Keep `diff -u` on servers, containers and CI images without delta | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DELTA-14 | D5 | A pipeline reports its last command's status, so `diff -u a b \| tail` exits 0; writing the diff to a file keeps diff's status 1 | 例 |
