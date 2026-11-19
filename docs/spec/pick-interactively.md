# Spec table: pick-interactively

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/pick-interactively.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-FZF-01 | D1 | fzf matches any line that contains the characters in order, so a short query returns lines `grep` would not; `-e` gives exact matching, and `--filter` reads fzf syntax, not a regex, with ` \| ` as OR | 例 |
| CLI-FZF-02 | D2 | A space separates terms that must all match | 例 |
| CLI-FZF-03 | D2 | To search for text that contains a space, escape it with a backslash or quote the term with `'` | 本文のみ (the escaping rules of the query syntax are not exercised by an example) |
| CLI-FZF-04 | D3 | The output is sorted by score, so it differs from the input order and from `grep`; `--no-sort` keeps the input order | 例 |
| CLI-FZF-05 | D4 | Matching is case-insensitive unless the query has an uppercase letter | 例 |
| CLI-FZF-06 | D5 | `--filter` prints the matching lines whole with nothing added, and without it fzf draws its interface | 例 |
| CLI-FZF-07 | D6 | fzf prints one line per match, so `xargs` without `-0` splits a name with a space; `--read0 --print0` and `xargs -0` keep it | 例 |
| CLI-FZF-08 | D7 | The status is 0 when a match was printed, 1 for no match, 2 for an error and 130 when interrupted | 例 |
| CLI-FZF-09 | D8 | With no pipe fzf runs `$FZF_DEFAULT_COMMAND` or a file walk and lists the files under the current directory | 本文のみ (needs a terminal as standard input, which an example does not have) |
| CLI-FZF-10 | D9 | Interactive mode reads the keyboard from the terminal, so cron and CI use `--filter` | 本文のみ (needs a terminal) |
| CLI-FZF-11 | K1 | Keep `grep` in POSIX scripts, CI images and servers without fzf | 本文のみ (advice on when to choose, not a result) |
| CLI-FZF-12 | K2 | Keep `grep -F` when the match must be exact and the order the input order | 本文のみ (advice on when to choose, not a result) |
| CLI-FZF-13 | K3 | Keep `grep -E` or `rg` when a regular expression is needed | 本文のみ (advice on when to choose, not a result) |
| CLI-FZF-14 | K4 | Keep an exact pattern when taking the first line of `fzf --filter` would give the best fuzzy match, not the line the pattern names | 本文のみ (advice on when to choose, not a result) |
