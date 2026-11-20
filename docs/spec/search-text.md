# Spec table: search-text

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/search-text.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-RG-01 | D1 | rg skips what `.gitignore`, `.ignore` and `.rgignore` list, only inside a repository, and grep reads every file it is given; `-uuu` searches them all | 例 |
| CLI-RG-02 | D2 | Hidden files and directories are skipped by rg unless `--hidden` or `-uu` | 例 |
| CLI-RG-03 | D3 | rg skips files that look binary, where grep prints "Binary file matches" unless `-I` | 例 |
| CLI-RG-04 | D4 | `grep -r PATTERN .` prints `./path` and `rg PATTERN` prints `path` | 例 |
| CLI-RG-05 | D5 | When piped rg prints no line numbers and, for a single file, no file name; `-H -n` gives a fixed shape | 例 |
| CLI-RG-06 | D6 | rg searches in parallel so its order changes between runs; `--sort path` sorts within each path argument and a pipe to `sort` gives one order across paths | 例 |
| CLI-RG-07 | D7 | rg uses Rust regex, so `rg 'greet('` is an error where basic-regex `grep` takes `(` literally | 例 |
| CLI-RG-08 | D8 | With no path rg searches standard input when it is a pipe or a file, not the directory | 例 |
| CLI-RG-09 | D9 | The status is 0 for found, 1 for not found and 2 for an error, for both rg and grep | 例 |
| CLI-RG-10 | K1 | Keep `grep` in POSIX scripts that must run where rg is not installed | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-RG-11 | K2 | Keep `grep` when every file must be searched, ignored or not | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-RG-12 | K3 | Keep `grep` when a script depends on basic-regex semantics or the `./` prefix | 本文のみ (助言: advice on when to choose, not a result) |
