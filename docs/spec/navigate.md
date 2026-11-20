# Spec table: navigate

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/navigate.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-ZOXIDE-01 | D1 | A keyword search only finds recorded directories (entered with the hook, added with `zoxide add` or imported from atuin, autojump, fasd, z, z.lua or zsh-z) | 例 |
| CLI-ZOXIDE-02 | D2 | `z` works like `cd` on one argument that `cd` accepts (`z ~/foo`, `z foo/`, `z ..`), `zoxide query` does not | 例 |
| CLI-ZOXIDE-03 | D3 | A directory in the current directory wins: `z lib` goes to `./lib` even when the history ranks another `lib` higher | 例 |
| CLI-ZOXIDE-04 | D4 | Matches are ranked by frecency, so the same word can lead to different directories over time, and `z` leaves out the directory you are in | 例 |
| CLI-ZOXIDE-05 | D5 | `z` is a shell function defined by `zoxide init`, so it does not exist in a script or under `xargs` | 例 |
| CLI-ZOXIDE-06 | D6 | `z -` returns to the previous directory like `cd -`, and zoxide has no stack like `pushd` and `popd` | 本文のみ (端末: needs an interactive shell with a directory history) |
| CLI-ZOXIDE-07 | K1 | Keep `cd` with an explicit path in scripts, since `z` depends on a history | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-ZOXIDE-08 | K2 | Keep `cd` on servers and containers where zoxide is not installed or its database is empty | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-ZOXIDE-09 | K3 | Keep `cd` when the directory is new or the path short, and when a wrong jump would be costly | 本文のみ (助言: advice on when to choose, not a result) |
