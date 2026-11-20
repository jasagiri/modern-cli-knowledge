# Spec table: find-files

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/find-files.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-FD-01 | D1 | fd skips what `.gitignore`, `.ignore` and `.fdignore` list (inside a repository) and hidden entries, where `find` lists everything; `-H -I` lists them | 例 |
| CLI-FD-02 | D2 | fd takes a regex on the file name, case-insensitive without an uppercase letter, and an invalid regex is an error with status 1; `-g` takes a glob | 例 |
| CLI-FD-03 | D3 | fd walks in parallel, so its order changes between runs and the output must be piped to `sort` | 本文のみ (非決定: the order of parallel walks is not deterministic, so no example can show it; the examples sort) |
| CLI-FD-04 | D4 | With `-x` (and `-0`, `-X`) paths keep the `./` prefix that plain output drops, and directories print with a trailing `/` | 例 |
| CLI-FD-05 | D5 | Like `find`, fd prints files, directories and symlinks unless `-t` narrows it | 例 |
| CLI-FD-06 | D6 | The pattern comes first and then the paths (`fd . src`) | 例 |
| CLI-FD-07 | D7 | No match exits 0 and an error exits 1 | 例 |
| CLI-FD-08 | D8 | Output is one path per line, names with spaces included | 例 |
| CLI-FD-09 | D9 | Symlinks are not followed unless `-L` is given | 例 |
| CLI-FD-10 | K1 | Keep `find` in POSIX scripts, CI images and servers without fd | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-FD-11 | K2 | Keep `find` for tests beyond the name such as `-mtime`, `-size`, `-perm`, `-newer` and `-prune` logic | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-FD-12 | K3 | Keep `find` when every file must be listed regardless of `.gitignore` and hidden entries | 本文のみ (助言: advice on when to choose, not a result) |
