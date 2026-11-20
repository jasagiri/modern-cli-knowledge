# Spec table: command-help

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/command-help.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-TLDR-01 | D1 | A tldr page lists the common uses, not every option or the exact behaviour, and `man` is authoritative | 本文のみ (通信: what a page says depends on the downloaded community pages) |
| CLI-TLDR-02 | D2 | The pages are written by a community and can be out of date for a version of the tool | 本文のみ (通信: depends on the downloaded community pages) |
| CLI-TLDR-03 | D3 | `tldr` is implemented by several clients whose options and cache behaviour differ | 例 |
| CLI-TLDR-04 | D4 | tlrc keeps a local copy of the pages: with an empty cache it downloads them on first run, updates when older than `max_age`, and `--offline` never downloads | 例 |
| CLI-TLDR-05 | D5 | `tldr --list` lists the pages of the platform and `tldr --search keyword` finds pages whose text contains the word; neither searches manual pages | 例 |
| CLI-TLDR-06 | D6 | Pages are grouped by operating system, so the page shown may describe the GNU or the BSD form | 本文のみ (通信: needs the downloaded pages) |
| CLI-TLDR-07 | K1 | Keep `man` when the exact option, exit status or rare behaviour matters | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TLDR-08 | K2 | Keep `man` and `--help` on servers and in containers without tldr, and offline | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TLDR-09 | K3 | Keep `tool --help` or `man` when the page must match the installed version | 本文のみ (助言: advice on when to choose, not a result) |
